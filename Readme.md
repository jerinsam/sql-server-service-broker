**Problem Statement** 
Overall time to complete a Stored Procedure is 30 mins. In order to reduce the execution time, Queries are optimized with Columnstore index along with NonClustered Indexes, which helped to reduce the execution time by 10 mins, now new execution time is 20 mins. While evaluating the queries further, It's been identified, if queries can be executed parallel then it will help to execute the procedure in 5 mins but in SQL Server Stored Procedures, all the queries are executed sequentially.


**Solutions**
Assessed following solutions to execute the queries in the SP parallelly.
 - SSIS : SQL Server Integration Services, Queries can be parallelized using SSIS tasks.
 - Python : Async programming can be used to parallelize the queries.
 - SQL Server Service Broker : Messaging queue in SQL Server

It's been decided to go with Service Broker as Python and SSIS is kind of introducing new tools in the tech stack of the project and Service Broker is a integrated part of SQL Server. 


**Implementation**
In this POC, Data is pushed from SQL Server to SingleStore DB, Following Services are used:

- SingleStoreDB docker container - Use /install_and_config/ folder to understand the docker container license and setup.
- SQL Server - Installed in Windows, Developer Edition is free to use.
- Python - - -
 