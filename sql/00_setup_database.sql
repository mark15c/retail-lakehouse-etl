IF DB_ID('RetailLakehouse') IS NULL
BEGIN
    CREATE DATABASE RetailLakehouse;
END;
GO

USE RetailLakehouse;
GO

IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'raw')
BEGIN
    EXEC('CREATE SCHEMA raw');
END;
GO

IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'stage')
BEGIN
    EXEC('CREATE SCHEMA stage');
END;
GO

IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'analytics')
BEGIN
    EXEC('CREATE SCHEMA analytics');
END;
GO

SELECT name
FROM sys.schemas
WHERE name IN ('raw', 'stage', 'analytics');





