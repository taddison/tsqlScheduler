# This is a STUB
# TODO: complete & test
Write-Host "Config file for [$agName] not found in deploy/servers."
$global:server=Read-Host "Enter the local server name"
$sqlParseAG="declare 
	@agName sysname = '$agName',
	@agid uniqueidentifier;

select @agid = ag.group_id
from sys.availability_groups ag
where ag.[name] = @agName;

select 
    [Name]=ar.replica_server_name,
    [Role]=case @@servername
            when ar.replica_server_name then 'Primary'
            else 'Secondary'
        end
from sys.availability_replicas ar
where ar.group_id = @agid
for json path;"

Invoke-Sqlcmd -ServerInstance $server -Database master -Query $sqlParseAG | Out-File ..\deploy\servers\$agName.json -Encoding ascii