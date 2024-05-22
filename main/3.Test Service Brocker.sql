--USE master
--ALTER DATABASE TryIt
--SET ENABLE_BROKER; -- Enable Service Broker at DB Level 


USE [TRYIT]
GO


---------------------------------- Send Messages to Broker ------------------------------------------

-------Send messgaes : SP name is sent as message and activation SP [dbo].[parallel_proc_receiver] will be automatically called and execute the SP 
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

-- dbo.StoredProcedureLog : Is populated through Test SPs
-- dbo.messageProcessed : Is populated through Activation SP , to track the processed messages


SELECT * FROM dbo.StoredProcedureLog
SELECT * FROM dbo.messageProcessed


