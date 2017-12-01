Function Install-SchedulerSolution 
{
    [cmdletbinding()]
    Param (
        [string] $server
        ,[string] $database
        ,[boolean] $agMode = $false
        ,[string] $availabilityGroup
        ,[boolean] $versionBump = $false
    )

    $deployMode = if($agMode){"IsAGMode"}else{"IsStandaloneMode"}
    $compileInclude = Import-Csv ..\deploy\compileInclude.csv

    if($versionBump){
        $files += $compileInclude | Where-Object { 
            ($_."$deployMode" -match $true) -and
            (($_.fileName).StartsWith(".\Tables") -eq $false) # ignore stateful data objs on version bump
        }
    }else{
        $files += $compileInclude | Where-Object { $_."$deployMode" -match $true } 
    }

    Write-Verbose ">>>>>>> $server"
    Write-Verbose ">>>>>>> $database"
    Write-Verbose "--------------------------------------------------------------------"

    $files | foreach-object { 
        Write-Verbose $_.fileName
        Invoke-SqlCmd -ServerInstance $server -Database $database -InputFile $_.fileName 
    }

    Write-Verbose "--------------------------------------------------------------------"

    $instanceGuid = [System.Guid]::NewGuid().ToString()
    $instanceFunction = @"
    create or alter function scheduler.GetInstanceId()
    returns table
    as
    return (
        select cast('$instanceGuid' as uniqueidentifier) as Id
    );
"@
    Invoke-SqlCmd -ServerInstance $server -Database $database -Query $instanceFunction

    if($agMode)
    {
        $availabilityGroupFunction = @"
        create or alter function scheduler.GetAvailabilityGroup()
        returns table
        as
        return (
            select cast('$availabilityGroup' as nvarchar(128)) as AvailabilityGroup
        );
"@
        Invoke-SqlCmd -ServerInstance $server -Database $database -Query $availabilityGroupFunction
    }
    
}

Function Install-AutoUpsertJob 
{
    [cmdletbinding()]
    Param (
        [string] $Server
        ,[string] $Database
        ,[string] $TargetDatabase
        ,[string] $NotifyOperator
    )

    # conform to naming convention of $ownLocation-$target-$task
    # but do not double-prefix self-reference/standalone AutUpsert jobs
    if($Database -eq $TargetDatabase){
        $prefix = $TargetDatabase
    }else{
        $prefix = $Database + "-" + $TargetDatabase
    }

    $jobIdentifier = $prefix + "-UpsertJobsForAllTasks"
    $query = "
exec scheduler.UpsertTask
    @action = 'INSERT', 
    @jobIdentifier = '$jobIdentifier', 
    @tsqlCommand = N'exec $TargetDatabase.scheduler.UpsertJobsForAllTasks;', 
    @startTime = '00:00', 
    @frequencyType = 3, 
    @frequencyInterval = 1, 
    @notifyOperator = '$NotifyOperator', 
    @isNotifyOnFailure = 0,
    @overwriteExisting = 1;" # allow error-free redeploy of same AG after logical delete of local upsert job

    Invoke-SqlCmd -ServerInstance $Server -Database $Database -Query $query
    Invoke-SqlCmd -ServerInstance $Server -Database $Database -Query "exec scheduler.CreateJobFromTask @identifier = '$jobIdentifier', @overwriteExisting = 1;"
}

Function Install-ReplicaStatusJob 
{
    [cmdletbinding()]
    Param (
        [string] $Server
        ,[string] $Database
        ,[string] $NotifyOperator
    )

    $jobIdentifier = $Database + "-RecordReplicaStatus"
    $query = "
exec scheduler.UpsertTask
    @action = 'INSERT', 
    @jobIdentifier = '$jobIdentifier', 
    @tsqlCommand = N'exec $Database.scheduler.UpdateReplicaStatus;', 
    @startTime = '00:00', 
    @frequencyType = 3, 
    @frequencyInterval = 1, 
    @notifyOperator = '$NotifyOperator', 
    @isNotifyOnFailure = 0;"

    Invoke-SqlCmd -ServerInstance $Server -Database $Database -Query $query
    Invoke-SqlCmd -ServerInstance $Server -Database $Database -Query "exec scheduler.CreateJobFromTask @identifier = '$jobIdentifier', @overwriteExisting = 1;"
}

Function UnInstall-SchedulerSolution
{
    [cmdletbinding()]
    Param (
        [string] $agName
        ,[boolean] $agMode=$true
        ,[string] $Server
        ,[string] $Database
    )

    $setTaskDeletedQuery = "update scheduler.task set IsDeleted = 1;"
    $deleteAllHAJobsQuery = "exec scheduler.UpsertJobsForAllTasks;"
    $removeAllObjectsQuery = Get-Content "RemoveAllObjects.sql" | Out-String

    if($agMode){
        ..\deploy\setInput -agMode $agMode -agName $agName
        $deleteLocalUpsertJobQuery="update top(1) scheduler.task set IsDeleted = 1 where Identifier='$Database-$agDatabase-UpsertJobsForAllTasks';"
    }

    if($agMode){
        $Server=($replicas | Where-Object "Role" -eq "Primary").Name
        Write-Verbose $setTaskDeletedQuery
        Invoke-SqlCmd -ServerInstance $Server -Database $agDatabase -Query $setTaskDeletedQuery

        foreach($replica in $replicas){
            Write-Verbose $_.Name
            Write-Verbose $agDatabase
            Invoke-SqlCmd -ServerInstance $replica.Name -Database $agDatabase -Query $deleteAllHAJobsQuery
            Write-Verbose $Database
            Invoke-SqlCmd -ServerInstance $replica.Name -Database $Database -Query $deleteLocalUpsertJobQuery
        }

        Write-Verbose "Removing all objects..."
        Invoke-SqlCmd -ServerInstance $Server -Database $agDatabase -Query $removeAllObjectsQuery
    }else{ 
        Write-Verbose $Server
        Write-Verbose $Database
        Write-Verbose $setTaskDeletedQuery
        Invoke-SqlCmd -ServerInstance $Server -Database $Database -Query $setTaskDeletedQuery
        Write-Verbose $deleteAllHAJobsQuery
        Invoke-SqlCmd -ServerInstance $Server -Database $Database -Query $deleteAllHAJobsQuery
        Write-Verbose "Removing all objects..."
        Invoke-SqlCmd -ServerInstance $Server -Database $Database -Query $removeAllObjectsQuery
    }
}

Export-ModuleMember Install-SchedulerSolution
Export-ModuleMember Install-AutoUpsertJob
Export-ModuleMember Install-ReplicaStatusJob
Export-ModuleMember UnInstall-SchedulerSolution