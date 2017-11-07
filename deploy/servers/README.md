# The AG Config File 

You can create your own AG config file by executing the below query on your AG.
	
```sql
declare 
	@agName sysname = 'AvailabilityGroup.sample',
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
for json path; 
```

Simply add `"IsSchedulerExcluded":true` for any replica which you do wish to deploy the HA Scheduler Solution. 
