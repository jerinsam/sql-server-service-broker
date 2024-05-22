#### Problem Statement
Overall time to complete a Stored Procedure is 30 mins. In order to reduce the execution time, Queries are optimized with Columnstore index along with NonClustered Indexes, which helped to reduce the execution time by 10 mins, now new execution time is 20 mins. While evaluating the queries further, It's been identified, if queries can be executed parallel then it will help to execute the procedure in 5 mins but in SQL Server Stored Procedures, all the queries are executed sequentially.


#### Solutions
Assessed following solutions to execute the queries in the SP parallelly.
 - SSIS : SQL Server Integration Services, Queries can be parallelized using SSIS tasks.
 - Python : Async programming can be used to parallelize the queries.
 - SQL Server Service Broker : Messaging queue in SQL Server, It will parallelly send the messages for further processing.

It's been decided to go with Service Broker as Python and SSIS is kind of introducing new tools in the tech stack of the project and Service Broker is a integrated part of SQL Server. 


#### Implementation
In this POC, Service Broker is used to parallelly execute the Stored Procedures. 

Following Steps are taken in the POC:
1. Create of two tables, 1 table to log the execution of SP start and end time and another for inserting the processed messages by the Service Broker.
2. Create Test SPs. The name of the SP will be sent to Queue which will further execute the SP which will insert SP Name , Start and End Time.
3. Create Service Broker Objects. i.e.
     - Message
     - Contract
     - Queue
     - Service
 4. Create Activation SP, when a new message (Test SP Name as message) is sent to Service Broker's Queue, this Activation SP will be automatically triggered and execute the Test SP. This will also insert the processed message (Test SP Name as message) to a table created in step 1. 
 5. Alter the queue created in Step 3 to include activation procedure name in the configration of queue.
 6. Test the parallel execution of SP using Service Broker.

/main/ folder consists of SQL scripts for all the above steps.

Tying it with our problem statement each queries from the SP will be sent as message and will be further executed by Activation SP.