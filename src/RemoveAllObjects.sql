/*** PROCEDURES ***/

drop procedure if exists scheduler.CreateAgentJob;
drop procedure if exists scheduler.CreateJobFromTask;
drop procedure if exists scheduler.DeleteAgentJob;
drop procedure if exists scheduler.ExecuteTask;
drop procedure if exists scheduler.RemoveJobFromTask;
drop procedure if exists scheduler.UpsertJobsForAllTasks;
go

/*** FUNCTIONS ***/

drop function if exists scheduler.GetAvailabilityGroupRole;
go

/*** TABLES ***/

/* If system versioning is on turn it off or the drop will fail */
if exists (
	select 1
	from sys.tables as t
	where t.temporal_type <> 0 
	and t.name = 'task'
	and t.schema_id = schema_id('scheduler')
)
begin
	alter table scheduler.task set (system_versioning = off);
end
go
drop table if exists scheduler.Task;
drop table if exists scheduler.TaskHistory;
drop table if exists scheduler.TaskExecution;
go

/*** SCHEMA ***/
drop schema if exists scheduler;