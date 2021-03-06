
create or alter proc scheduler.CreateTask  
    @jobIdentifier     sysname,
    @tsqlCommand       nvarchar(max),
    @startTime         time,
    @frequencyType     tinyint,
    @frequencyInterval smallint,
    @notifyOperator    sysname,
    @isNotifyOnFailure bit = 1,
	@notifyLevelEventlog int =2,
    @IsEnabled         bit = 1,
--    @IsCachedRoleCheck bit = 1,
    @IsDeleted         bit = 0
as
begin
    set nocount on;

    insert scheduler.Task ( 
           Identifier,
           TSQLCommand,
           StartTime,
           FrequencyType,
           FrequencyInterval,
           NotifyOnFailureOperator,
		   NotifyLevelEventlog,
           IsNotifyOnFailure,
           IsEnabled,
--           IsCachedRoleCheck, 
           IsDeleted )
    select Identifier              = @jobIdentifier,
           TSQLCommand             = @tsqlCommand,
           StartTime               = @startTime,
           FrequencyType           = @frequencyType,
           FrequencyInterval       = @frequencyInterval,
           NotifyOnFailureOperator = @notifyOperator,
		   NotifyLevelEventlog	   = @notifyLevelEventlog,
           IsNotifyOnFailure       = @isNotifyOnFailure,
           IsEnabled               = @IsEnabled,
           --IsCachedRoleCheck       = @IsCachedRoleCheck,
           IsDeleted               = @IsDeleted;
    
    return;
end;
go
