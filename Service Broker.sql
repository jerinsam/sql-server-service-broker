USE master
ALTER DATABASE TryIt
SET ENABLE_BROKER; 

USE TryIt;


 
 USE [TRYIT]
GO
/****** Object:  Table [dbo].[messageProcessed]    Script Date: 21-05-2024 9.05.35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--------------------------------------------------- Create Service Broker Objects --------------------------------------------------


CREATE MESSAGE TYPE TestMessage
AUTHORIZATION dbo
VALIDATION = None;


CREATE CONTRACT MessageContract
(TestMessage SENT BY ANY)


CREATE QUEUE QueryQueue
WITH STATUS = ON, RETENTION = OFF


CREATE SERVICE QueryService
AUTHORIZATION dbo 
ON QUEUE QueryQueue(MessageContract)


-------- Create Activation SP ------------
--SP - [dbo].[parallel_proc_receiver] will auto execute when new message is received, Script can be found below ---------------

---------- Alter Queue to Execute the SP when Message is received --------------
 

ALTER QUEUE QueryQueue
    WITH ACTIVATION
    ( STATUS = ON,
        PROCEDURE_NAME = [dbo].[parallel_proc_receiver],
        MAX_QUEUE_READERS = 10,
        EXECUTE AS SELF
    );
GO
----------------------------------------------------------------------------------------------------------------------------------------

------------------------------- Create DB Objects to store log and check the processed data --------------------------------------------


CREATE TABLE [dbo].[messageProcessed](
	[Query] [varchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO


CREATE TABLE [dbo].[StoredProcedureLog](
	[SPName] [nvarchar](255) NULL,
	[StartTime] [datetime] NULL,
	[EndTime] [datetime] NULL
) ON [PRIMARY]
GO


----------------------------------------------------------------------------------------------------------------------------

------------------------------- Create Activation SP to Receive the Message and Process it --------------------------------------------


CREATE PROCEDURE [dbo].[parallel_proc_receiver]
AS
BEGIN
  DECLARE @message_body NVARCHAR(max)
  DECLARE @conversation_handle UNIQUEIDENTIFIER
  
  WHILE (1=1)
  BEGIN
    WAITFOR (
      RECEIVE TOP(1)
        @message_body = message_body,
        @conversation_handle = conversation_handle
      FROM QueryQueue
    ), TIMEOUT 1;
  
    IF (@@ROWCOUNT = 0)
      BREAK;
	
	
	INSERT INTO messageProcessed VALUES (CONVERT(NVARCHAR(MAX), @message_body))

	DECLARE @Query NVARCHAR(MAX) = CONVERT(NVARCHAR(MAX), @message_body)
	 
	--EXECUTE @message_body;
	EXEC sp_executesql @Query;
  
    END CONVERSATION @conversation_handle;
  END
END
 
GO



-----------------------------------------------------------------------------------------------------------------------

------------------------------- Create Insert data into SPs for Testing -----------------------------------------------
---- The SP Name will be sent as message 
---- Activation SP will execute the SP 

--define stored procedures 
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
 

--define stored procedures 
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



--define stored procedures 
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


---------------------------------- Send Messages to Broker ------------------------------------------

-------Send messgaes : SP name is sent as message and activation SP [dbo].[parallel_proc_receiver] will execute the SP 
-------------1----------------

-- Begin Dialog using service on contract
DECLARE @SBDialog1 uniqueidentifier
DECLARE @Message1 NVARCHAR(max)

SET @SBDialog1 = NEWID()  ----- Unique Identifier mapped with the message 

BEGIN DIALOG CONVERSATION @SBDialog1
FROM SERVICE QueryService
TO SERVICE 'QueryService'
ON CONTRACT MessageContract
WITH ENCRYPTION = OFF


SET @Message1 = N'EXEC [dbo].[usp_1]';
SEND ON CONVERSATION @SBDialog1
MESSAGE TYPE TestMessage (@Message1); 


-------------2----------------

-- Begin Dialog using service on contract
DECLARE @SBDialog2 uniqueidentifier
DECLARE @Message2 NVARCHAR(max)

SET @SBDialog2 = NEWID() ----- Unique Identifier mapped with the message 

BEGIN DIALOG CONVERSATION @SBDialog2
FROM SERVICE QueryService
TO SERVICE 'QueryService'
ON CONTRACT MessageContract
WITH ENCRYPTION = OFF


SET @Message2 = N'EXEC [dbo].[usp_2]';
SEND ON CONVERSATION @SBDialog2
MESSAGE TYPE TestMessage (@Message2);



-------------3----------------

-- Begin Dialog using service on contract
DECLARE @SBDialog3 uniqueidentifier
DECLARE @Message3 NVARCHAR(max) ----- Unique Identifier mapped with the message 

SET @SBDialog3 = NEWID()

BEGIN DIALOG CONVERSATION @SBDialog3
FROM SERVICE QueryService
TO SERVICE 'QueryService'
ON CONTRACT MessageContract
WITH ENCRYPTION = OFF


---- Send messages on Dialog
SET @Message3 = N'EXEC [dbo].[usp_3]';
SEND ON CONVERSATION @SBDialog3
MESSAGE TYPE TestMessage (@Message3);


----------------------------------------------------------------------------------------


---- View messages from Receive Queue
--SELECT CONVERT(NVARCHAR(MAX), message_body) AS Message --,*
--FROM QueryQueue
--GO
 

------------------------ Check Log and Output Tables -----------------------
 
--TRUNCATE TABLE dbo.StoredProcedureLog
--TRUNCATE TABLE messageProcessed


SELECT * FROM dbo.StoredProcedureLog
SELECT * FROM messageProcessed


