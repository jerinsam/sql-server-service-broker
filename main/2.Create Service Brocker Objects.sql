--USE master
--ALTER DATABASE TryIt
--SET ENABLE_BROKER; -- Enable Service Broker at DB level
 
USE [TRYIT]
GO 

--------------------------------------------------- Create Service Broker Objects --------------------------------------------------

-- Message Type --
CREATE MESSAGE TYPE TestMessage
AUTHORIZATION dbo
VALIDATION = None;


-- Contract for Message Type --
CREATE CONTRACT MessageContract
(TestMessage SENT BY ANY)


-- Message Queue --
CREATE QUEUE QueryQueue
WITH STATUS = ON, RETENTION = OFF


-- Queue Service for the Messgae Queue--
CREATE SERVICE QueryService
AUTHORIZATION dbo 
ON QUEUE QueryQueue(MessageContract)



------------------------------- Create Activation SP to Receive the Message and Process it --------------------------------------------
--SP - [dbo].[parallel_proc_receiver] will auto execute when new message is received in the Queue 

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

  


---- Alter Queue to add Activation SP in its properties so that it auto send the received message (SP Name) to Activation SP , which will further be executed-----
 

ALTER QUEUE QueryQueue
    WITH ACTIVATION
    ( STATUS = ON,
        PROCEDURE_NAME = [dbo].[parallel_proc_receiver],
        MAX_QUEUE_READERS = 10,
        EXECUTE AS SELF
    );
GO 

