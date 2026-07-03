use master;
go

--drop and recreate the 'DataWarehouse' database
if exists ( select 1 from sys.databases where name = 'DataWarehouse')
begin
	alter database DataWarehouse set single_user with rollback immediate;
	drop database DataWarehouse;
end;
go


create database DataWarehouse;
go

use DataWarehouse;
go

CREATE SCHEMA Bronze;
go

CREATE SCHEMA Silver;
go

CREATE SCHEMA Gold;
go
