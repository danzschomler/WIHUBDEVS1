IF NOT EXISTS (SELECT * FROM master.dbo.syslogins WHERE loginname = N'sqllink')
CREATE LOGIN [sqllink] WITH PASSWORD = 'p@ssw0rd'
GO
CREATE USER [sqllink] FOR LOGIN [sqllink]
GO
