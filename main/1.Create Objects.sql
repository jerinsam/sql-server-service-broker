USE master
ALTER DATABASE TryIt
SET ENABLE_BROKER; -- Enable Service Broker


USE [TRYIT]
GO



------------------------------- Create DB Objects to store log and check the processed data --------------------------------------------

-- dbo.StoredProcedureLog : Is populated through Test SPs
-- dbo.messageProcessed : Is populated through Activation SP, to track the processed messages


CREATE TABLE [dbo].[messageProcessed](
	[Query] [varchar](max) NULL
) ON [PRIMARY]  
GO


CREATE TABLE [dbo].[StoredProcedureLog](
	[SPName] [nvarchar](255) NULL,
	[StartTime] [datetime] NULL,
	[EndTime] [datetime] NULL
) ON [PRIMARY]
GO




-----------------------------------------------------------------------------------------------------------------------

------------------------------- Create Insert data into SPs for Testing -----------------------------------------------
---- The SP Name will be sent as message , which will just wait for 1 min and do a select. 
---- Logging of SP execution is done, to check whether SP Name sent to Service Broker for execution is executing it Parallelly or Sequentially.
---- Activation SP will execute the SP 

-- SP 1- Define stored procedures 
CREATE PROCEDURE [dbo].[usp_1]
AS
BEGIN
    
    -- Log the start time of the stored procedure
    INSERT INTO dbo.StoredProcedureLog (SPName, StartTime)
    VALUES ('usp_GetSalesForCustomer', GETDATE());

	WAITFOR DELAY '00:00:59';

    SELECT 1 as ID

    -- Log the end time of the stored procedure
    UPDATE dbo.StoredProcedureLog
    SET EndTime = GETDATE()
    WHERE SPName = 'usp_GetSalesForCustomer' AND EndTime IS NULL;
END
GO
 

-- SP 2- Define stored procedures 
CREATE PROCEDURE [dbo].[usp_2]
AS
BEGIN
    
    -- Log the start time of the stored procedure
    INSERT INTO dbo.StoredProcedureLog (SPName, StartTime)
    VALUES ('usp_GetSalesForCustomer2', GETDATE());

	WAITFOR DELAY '00:00:59';
    SELECT 1 as ID

    -- Log the end time of the stored procedure
    UPDATE dbo.StoredProcedureLog
    SET EndTime = GETDATE()
    WHERE SPName = 'usp_GetSalesForCustomer2' AND EndTime IS NULL;
END
GO



-- SP 3- Define stored procedures 
CREATE PROCEDURE [dbo].[usp_3]
AS
BEGIN
    
    -- Log the start time of the stored procedure
    INSERT INTO dbo.StoredProcedureLog (SPName, StartTime)
    VALUES ('usp_GetSalesForCustomer3', GETDATE());

	WAITFOR DELAY '00:00:59';

    SELECT 1 as ID

    -- Log the end time of the stored procedure
    UPDATE dbo.StoredProcedureLog
    SET EndTime = GETDATE()
    WHERE SPName = 'usp_GetSalesForCustomer3' AND EndTime IS NULL;
END

GO


 