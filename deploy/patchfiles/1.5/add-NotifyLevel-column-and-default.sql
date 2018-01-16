if col_length(N'scheduler.Task',N'NotifyLevelEventlog') is null
    alter table scheduler.Task add NotifyLevelEventlog int not null default 2
go

alter table scheduler.Task alter column NotifyLevelEventlog int not null;
go

if exists( select * 
            from sys.default_constraints dc
            where dc.parent_object_id = object_id(N'scheduler.Task',N'U')
                and dc.parent_column_id = try_convert(int,columnproperty(object_id(N'scheduler.Task',N'U'),'NotifyLevelEventlog','ColumnId')))
begin; -- default exists, drop & re-create to ensure accuracy
    declare @dSql nvarchar(max);

    select @dSql='alter table scheduler.Task drop constraint ['+dc.[name]+'];'
    from sys.default_constraints dc
    where dc.parent_object_id = object_id(N'scheduler.Task',N'U')
        and dc.parent_column_id = columnproperty(object_id(N'scheduler.Task',N'U'),'NotifyLevelEventlog','ColumnId');

    exec sys.sp_executesql @dSql;
end;

alter table scheduler.Task add constraint DF_Task_NotifyLevelEventlog default (2) for NotifyLevelEventlog;
go
