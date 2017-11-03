Param(
    [string] $server
    ,[string] $database
    ,[string] $notifyOperator
)

Install-SchedulerSolution -Server $server -Database $database -agMode $false
Install-AutoUpsertJob -Server $server -Database $database -TargetDatabase $database -NotifyOperator $notifyOperator
