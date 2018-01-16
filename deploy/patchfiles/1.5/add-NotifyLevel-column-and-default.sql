
if exists( select * 
           from sys.objects o 
           where o.[object_id] = object_id(N'scheduler.Task',N'U'))
begin;
    if col_length(N'scheduler.Task',N'NotifyLevelEventlog') is null
    begin;
        alter table scheduler.Task add NotifyLevelEventlog int;
        update scheduler.Task set NotifyLevelEventlog=2;
        alter table scheduler.Task alter column NotifyLevelEventlog int not null;
    end;

    if exists( select * 
               from sys.default_constraints dc
               where dc.parent_object_id = object_id(N'scheduler.Task',N'U')
                   and dc.parent_column_id = try_convert(int,columnproperty(object_id(N'scheduler.Task',N'U'),'NotifyLevelEventlog','ColumnId')))
    begin; -- default exists, ensure accuracy
        declare @dSql nvarchar(max);
        select @dSql='alter table scheduler.Task drop constraint ['+dc.[name]+'];'+char(10)
                    +'alter table scheduler.Task add constraint DF_Task_NotifyLevelEventlog default (2) for NotifyLevelEventlog;'
        from sys.default_constraints dc
        where dc.[object_id] = object_id(N'scheduler.Task',N'U')
            and dc.parent_column_id = columnproperty(object_id(N'scheduler.Task',N'U'),'NotifyLevelEventlog','ColumnId');

        print @dSql;
        --exec sys.sp_executesql @dSql;
    end;
    else
    begin; -- default does not exist, create it
        alter table scheduler.Task add constraint DF_Task_NotifyLevelEventlog default (2) for NotifyLevelEventlog;
    end;

end;
go
