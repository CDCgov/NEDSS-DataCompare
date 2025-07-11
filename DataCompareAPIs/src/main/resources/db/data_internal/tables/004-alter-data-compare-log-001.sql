
if not exists (select 1 from sys.columns where object_id = object_id(N'Data_Compare_Log') and name = N'batch_id')
    begin
        alter table Data_Compare_Log   add  batch_id bigint
    end

if  not exists(select 1 from sys.foreign_keys where name ='fk_batch_id')
    begin
        alter table Data_Compare_Log add constraint fk_batch_id FOREIGN KEY (batch_id) REFERENCES Data_Compare_Batch(batch_id)
    end

if not exists (select 1 from sys.columns where object_id = object_id(N'Data_Compare_Log') and name = N'rows_compared')
    begin
        alter table Data_Compare_Log   add  rows_compared bigint
    end