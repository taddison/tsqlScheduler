Param(
    [string][parameter(mandatory=$true)] $agName
    ,[parameter(mandatory=$true)] $replicas
    ,[string][parameter(mandatory=$true)] $server
    ,[string][parameter(mandatory=$true)] $database
    ,[string][parameter(mandatory=$true)] $agDatabase
    ,[string][parameter(mandatory=$true)] $notifyOperator
)

Install-SchedulerSolution -Server $server -Database $agDatabase -agMode $true -AvailabilityGroup $agName

foreach($replica in $replicas){
    $serverName = $replica.Name
    Install-SchedulerSolution -server $serverName -database $database -agMode $false
    Install-AutoUpsertJob -server $serverName -database $database -TargetDatabase $agDatabase -notifyOperator $notifyOperator
}

Install-ReplicaStatusJob -Server $server -Database $agDatabase -NotifyOperator $notifyOperator
