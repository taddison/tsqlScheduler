function CleanupExistingAgentJob {
	$query = "exec sp_delete_job @job_name = 'CreateAgentJobTestJob';"
    # Ignore any errors if the job doesn't already exist
    Invoke-Sqlcmd -ServerInstance . -Database msdb -Query $query -ErrorAction SilentlyContinue
}

function CreateAgentJob {
    $query = "exec scheduler.CreateAgentJob @jobname = 'CreateAgentJobTestJob', @command = N'select @@servername', @frequencyType = 'hour', @frequencyInterval = 1, @startTime = '00:00', @notifyOperator = 'Test Operator', @overwriteExisting = 0";
    Invoke-Sqlcmd -ServerInstance . -Database tsqlscheduler -Query $query
}

function CheckIfAgentJobExists {
    $query = "select count(*) as JobCount from msdb.dbo.sysjobs as j where j.name = 'CreateAgentJobTestJob'"
    $result = Invoke-Sqlcmd -ServerInstance . -Database msdb -Query $query 
    $count = $result.JobCount
    return ($result.JobCount -eq 1)
}