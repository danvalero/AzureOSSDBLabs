# Create a Read replica for an Azure Database for MySQL Single Server

**Introduction**

During this lab, you will learn how to create a Read replica for an Azure Database for MySQL Single Server using the Azure Portal

**Objectives**

After completing this lab, you will be able to: 

- Set a read replica for an Azure Database for MySQL Single Server
- Read from an Azure Database for MySQL read replica

**Considerations**

This lab considers that an Azure Database for MySQL Single Server named mysqlserver[your name initials] exists with a server admin login named *admmysql*, if not, create it or use another existing server before continuing with the lab.

**Estimated Time:** 50 minutes

---

# Exercise 1: Create a sample schema on the Azure Database for MySQL Single Server

This exercise shows how to create a sample schema on the Azure Database for MySQL Single Server

**Tasks**

1. Create the employees schema on the Azure Database for MySQL Single Server
    
   Locate the connection information for your Azure Database for MySQL Single Server in the **Overview** page of the server. If you do not have an Azure Database for MySQL Single Server, create one.
   
   Open a Windows Prompt and execute a script to create the employees schema, create objects and load the demo employee data using:
    
   ```nocolor-wrap
   mysql -h <your_azure_mysql_server>.mysql.database.azure.com -u <username>@<your_azure_mysql_server> -p employees < C:\MySQLSSLabFiles\create_employees.sql
   ```

   For example:
    
   ```bash
   mysql -h mysqldemoirts.mysql.database.azure.com -u myadmin@mysqldemoirts -p < C:\MySQLSSLabFiles\create_employees.sql
   ```
    
   >IMPORTANT: This is destructive action. If there is a database named moviesdb in the Azure Database for MySQL Single Server, the existing moviesdb will be dropped and replace
    
   ![](Media/image0082.png)
    
   >If the operation does not seem to complete after 5 minutes, press enter again
    
   If you get a message like:
   
   Client with IP address **40.124.1.212** is not allowed to connect to this MySQL server.
   
   You must allow access from the Virtual Machine to the Azure Database for MySQL by adding a rule for the client machine IP address. Go to Connection security in Settings, add the rule and click Save.
   
   ![](Media/image0083.png)

Congratulations!. You have successfully completed this exercise. 

---

# Exercise 2: Add a replica

This exercise shows how to add a read replica for an Azure Database for MySQL Single Server.

**Tasks**

1. Connect to Microsoft Azure Portal
    
   Open Microsoft Edge and navigate to the [Azure Portal](http://ms.portal.azure.com) to connect to Microsoft Azure Portal. Login with your subscriptions credential.

1. Go to your MySQL Server

   Go to your Azure Database for MySQL Single Server in any way you prefer to look for a resource on Azure

1. Got to Replication
    
   Select **Replication** from the menu, under **SETTINGS**
    
   ![](Media/image0084.png)
    
   Notice that no replica has been set.

1. Add a replica
    
   Click on **Add Replica**.
    
   Configure the new server using the following instruction:

   - Name your server using the same name of the master server and add -r1 at the end.
    
     NOTE: This is just a suggestion for the lab. You can name your server in any way you want as long as it not used by you or any other Azure customer.

   - The default location is the same as the master server. You can select any other region. For this lab, use the same region as the master server

   - Notice that you cannot select the tier.
    
     Read replicas are created with the same server configuration as the master. The replica server configuration can be changed after it has been created. It is recommended that the replica server's configuration should be kept at equal or greater values than the master to ensure the replica is able to keep up with the master.
    
   ![](Media/image0085.png)
    
   Click **OK** and wait until the server creation finishes. It can take up to 30 minutes, this is good time to take a break, or even better, use this time to ask questions to the instructor.
    
   When you create a replica for a master that has no existing replicas, the master will first restart to prepare itself for replication. Please take this into consideration and perform these operations during an off-peak period.

1. Review the replication configuration
    
   In the replication panel you will see that the replica is now listed.
    
   ![](Media/image0086.png)
    
   You have configured a read replica for your Azure Database MySQL Server.

Congratulations!. You have successfully completed this exercise.

---

# Exercise 3: Read from a replica

This exercise shows a data notification being replicated a how to red from a replica server.

**Tasks**

1. Query the master replica
    
   Register your Azure Database for MySQL on MySQL Workbench and connect to it.
    
   ![](Media/image0087.png)
    
   Create a New SQL Tab by pressing **Ctrl+T**, and execute:
    
   ```sql
   SELECT * FROM employees.departments;
   ```

   ![](Media/image0088.png)
    
   9 rows must be returned.

1. Query the read replica
    
   Register your Azure Database for MySQL replica on MySQL Workbench and connect to it.
    
   ![](Media/image0089.png)
    
   You will not be able to connect as your IP is not authorized on the replica server.
    
   When you create a replica, it doesn't inherit the firewall rules or VNet service endpoint of the master server. These rules must be set up independently for the replica.
    
   You must allow access from the Virtual Machine to the Azure Database for MySQL by adding a rule for the client machine IP address. Go to Connection security in Settings, add the rule and click Save.
    
   ![](Media/image0083.png)
    
   Once the firewall rules are set, connect to the server and create a New SQL Tab for executing queries by pressing **Control+T**, and execute:
    
   ```sql
   SELECT * FROM employees.departments;
   ```
    
   ![](Media/image0090.png)
    
   9 rows must be returned. You see the same data than in the master server.

1. Insert a new record on the master server
    
   Connect to your master server and create a New SQL Tab for executing queries by pressing Ctrl+T, and execute:
    
   ```sql
   INSERT INTO employees.departments VALUES ('d025 ', 'IT ');
   ```

   ![](Media/image0091.png)

1. Verify the replication is working
    
    Go back to the tab where you queried the employees.departments table on the read replica server and execute again:
    
   ```sql
   SELECT * FROM employees.departments;
   ```
    
   ![](Media/image0092.png)
    
   Now the query returns 10 rows, including the row you just inserted on the master. The row inserted on the master server was already replicated to the replica.

Congratulations!. You have successfully completed this exercise.

---

# Exercise 4: Stop Replication 

This exercise shows how to stop the replication

**Tasks**

1. Connect to Microsoft Azure Portal
    
   Open Microsoft Edge and navigate to the [Azure Portal](http://ms.portal.azure.com) to connect to Microsoft Azure Portal. Login with your subscriptions credential.

1. Go to your master PostgreSQL Server

   Go to your master Azure Database for PostgreSQL Single Server in any way you prefer to look for a resource on Az

1. Stop replication
    
   To stop replication between the primary and replica server:

   - Go to the master Azure Database for MySQL Single Server

   - Select **Replication** from the menu, under **SETTINGS**

   - Select the replica server you wish to stop replication for. In this case, you only have one replica.
    
     ![](Media/image0093.png)

   - Click **Stop Replication** and click on **OK** to confirm the operation.
    
     ![](Media/image0094.png)
   
   >The stop action causes the replica to restart and to remove its replication settings. Once you stopped the replication, the former replica server became a regular standalone server.

Congratulations!. You have successfully completed this exercise and the Lab.
