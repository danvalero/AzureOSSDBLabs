# Create a Read replica for an Azure Database for PostgreSQL Single Server

**Introduction**

During this lab, you will learn how to create a Read replica for an Azure Database for PostgreSQL Single Server using the Azure Portal

The read replica feature allows you to replicate data from an Azure Database for PostgreSQL server to a read-only server. Replicas are updated asynchronously with the PostgreSQL engine native physical replication technology. You can replicate from the primary server to up to five replicas.

The read replica feature helps to improve the performance and scale of read-intensive workloads. Read workloads can be isolated to the replicas, while write workloads can be directed to the primary. Read replicas can also be deployed on a different region and can be promoted to be a read/write server in the event of a disaster recovery.

A common scenario is to have BI and analytical workloads use the read replica as the data source for reporting.

Because replicas are read-only, they don't directly reduce write-capacity burdens on the primary.

The feature is meant for scenarios where the lag is acceptable and meant for offloading queries. It isn't meant for synchronous replication scenarios where the replica data is expected to be up-to-date. There will be a measurable delay between the primary and the replica. This can be in minutes or even hours depending on the workload and the latency between the primary and the replica. The data on the replica eventually becomes consistent with the data on the primary. Use this feature for workloads that can accommodate this delay.

**Objectives**

After completing this lab, you will be able to: 

- Set a read replica for an Azure Database for PostgreSQL Single Server
- Read from an Azure Database for PostgreSQL Single Server read replica

**Considerations**

This lab considers that an Azure Database for PostgreSQL Single Server named pgserver[your name initials] exists with a server admin login named *admpg*, if not, create it or use another existing server before continuing with the lab.

**Estimated Time:** 50 minutes

---

## Exercise 1: Create a sample database on the Azure Database for PostgreSQL Single Server

**Tasks**

1. Create the *adventureworks* database on the Azure Database for PostgreSQL Single Server
   
   Download the [adventureworks demo database](https://github.com/danvalero/AzureOSSDBLabs/raw/main/Azure%20Database%20for%20PostgreSQL%20Single%20Server/PostgresSQLSSLabFiles/adventureworks.dump) in **C:\\PostgresSQLSSLabFiles** folder

   Open a Windows Prompt and execute a script to create the *adventureworks* schema, create objects and load the demo employee data using:
   
   >This is a destructive action. If there is a database named *adventureworks* in the Azure Database for PostgreSQL Single Server, the existing *adventureworks* database will be dropped and replaced.
   
   ```bash
   psql --host=<server_name>.postgres.database.azure.com --port=5432 --username=<admin_user>@<server_name> --dbname=postgres -c "DROP DATABASE IF EXISTS adventureworks;" -c "CREATE DATABASE adventureworks;"
   ```

   ```bash
   pg_restore -v --no-owner --host=<server_name>.postgres.database.azure.com --port=5432 --username=<admin_user>@<server_name> --dbname=adventureworks C:\PostgresSQLSSLabFiles\adventureworks.dump
   ```
    
   for example:

   ```bash
   psql --host=pgserverms.postgres.database.azure.com --port=5432 --username=admpg@pgserverms --dbname=postgres -c "DROP DATABASE IF EXISTS adventureworks;" -c "CREATE DATABASE adventureworks;"
   ```

   ```bash
   pg_restore -v --no-owner --host=pgserverms.postgres.database.azure.com --port=5432 --username=admpg@pgserverms --dbname=adventureworks C:\PostgresSQLSSLabFiles\adventureworks.dump
   ```
    
   For both commands, you need to enter password when prompted. 
       
   ![Image0001](Media/Image0001.png)
       
   If you get a message like:
    
   *Psql: FATAL:  no pg_hba.conf entry for host "45.23.185.251", user "admpg", database "postgres",  SSL on*
    
   You must allow access from the Virtual Machine to the Azure Database for PostgreSQL by adding a rule for the client machine IP address. Go to **Connection security** in **Settings**, add the rule and click **Save**.
    
   ![Image0002](Media/Image0002.png)

Congratulations!. You have successfully completed this exercise.

---

## Exercise 2: Add a replica

This exercise shows how to add a read replica for an Azure Database for PostgreSQL Single Server.

**Tasks**

1. Connect to Microsoft Azure Portal
    
   Open Microsoft Edge and navigate to the [Azure Portal](http://ms.portal.azure.com) to connect to Microsoft Azure Portal. Login with your subscriptions credential.

1. Go to your PostgreSQL Single Server

   Go to your Azure Database for PostgreSQL Single Server in any way you prefer to look for a resource on Azure

1. Go to Replication
    
   Select **Replication** from the menu, under **Settings**
    
   ![image0010](Media/image0010.png)
    
   Notice that no replica has been set.

1. Add a replica
    
   If **Azure replication support** is not set to at least *Replica*, set it to *Replica*. Select **Save**.
 
   >Read replicas also work at this setting if **Azure replication support** is set to *Logical*.

   ![image0011](Media/image0011.png)
    
   >When you modifiy the set the **Azure replication support** configuration, the server is restarted. Please take this into consideration and perform these operations during an off-peak period.
    
   
   After replication support is enabled, click on **Add Replica**.
    
   Configure the new server using the following instruction:

   - Name your server using the same name of the master server and add *-r1* at the end.
        
     NOTE: This is just a suggestion for the lab. You can name your server in any way you want as long as it not used by you or any other Azure customer.

   - The default location is the same as the master server. You can select any other region. For this lab, use the same region as the master server

     You can create a read replica in a different region from your primary server. Cross-region replication can be helpful for scenarios like disaster recovery planning or bringing data closer to your users.

     >Basic tier servers only support same-region replication.

   - Notice that you cannot select the tier.
    
     Read replicas are created with the same server configuration as the master. The replica server configuration can be changed after it has been created. 
     
     >It is recommended that the replica server's configuration should be kept at equal or greater values than the master to ensure the replica is able to keep up with the master.
    
   ![image0013](Media/image0013.png)
    
   Click **OK** and wait until the server creation finishes. It can take several minutes, this is good time to take a break.

1. Review the replication configuration
    
   In the replication panel you will see that the replica is now listed.
    
   ![image0014](Media/image0014.png)
    
   You have configured a read replica for your Azure Database PostgreSQL Single Server.

Congratulations!. You have successfully completed this exercise.

---

## Exercise 3: Read from a replica

This exercise shows a data motification being replicated a how to red from a replica server.

**Tasks**

1. Query the master replica
    
   Open **pgAdmin**. 

   If you have not done it yet, register your Azure Database for PostgreSQL on pgAmdin and connect to it.
    
   ![image0020](Media/image0020.png)
    
   Connect to *adventureworks* and open a Query Tool. Execute:
    
   ```sql
    Select * from largetable where id<5;
   ```
    
   ![image0021](Media/image0021.png)

   4 rows must be returned.

1. Query the read replica
    
   Register your Azure Database for PostgreSQL replica on pgAdmin and connect to it. Use the same user and password you use to connect to the source server.

   You will not be able to connect as your IP is not authorized on the replica server.
    
   ![image0022](Media/image0022.png)
   
   >When you create a replica, it doesn't inherit the firewall rules or VNet service endpoint of the master server. These rules must be set up independently for the replica.
    
   You must allow access to the Azure Database for PostgreSQL by adding a rule for the client machine IP address. In the Azure Database for PostgreSQL replica server, go to **Connection security** in **Settings**, add the rule and click **Save**.
    
   ![image0023](Media/image0023.png)
    
   Once the firewall rules are set, connect to *adventureworks* on the read replica, open a Query Tool and Execute:
    
   ```sql
   Select * from largetable where id<5;
   ```
    
   ![image0024](Media/image0024.png)
   
   4 rows must be returned. You see the same data than in the master server.

1. Insert a new record on the master server and check the row was inserted
    
   Connect to *adventureworks* on the master replica, open a Query Tool and Execute:

   ```sql
   INSERT INTO largetable (id, largecolum) VALUES (2,'Replica-test');
   Select * from largetable where id<5;
   ```

   ![image0025](Media/image0025.png)

1. Verify replication is working
    
   Go back to the tab where you queried the *largetable* table on the read replica server and execute again:
    
   ```sql
   Select * from largetable where id<5;
   ```
    
   ![image0026](Media/image0026.png)
    
   Now the query returns 5 rows, including the row you just inserted on the master. The row inserted on the master server was already replicated to the replica.

Congratulations!. You have successfully completed this exercise.

---

## Exercise 4: Stop Replication 

This exercise shows how to stop the replication

**Tasks**

1. Connect to Microsoft Azure Portal
    
   Open Microsoft Edge and navigate to the [Azure Portal](http://ms.portal.azure.com) to connect to Microsoft Azure Portal. Login with your subscriptions credential.

1. Go to your master PostgreSQL Single Server

   Go to your master or replica Azure Database for PostgreSQL Single Server in any way you prefer to look for a resource on Azure

1. Go to Replication
    
   Select **Replication** from the menu, under **Settings**

1. Stop replication
    
   To stop replication between the primary and replica server:

   - Go to the master Azure Database for Postgres Single Server

   - Select **Replication** from the menu, under **SETTINGS**

   - Select the replica server you wish to stop replication for. In this case, you only have one replica.
    
     ![image0030](Media/image0030.png)

   - Click **Stop Replication** and click on **OK** to confirm the operation.
    
     ![image0031](Media/image0031.png)
    
     >The stop action causes the replica to restart and to remove its replication settings. Once you stopped the replication, the former replica server became a regular standalone server.
    
     Wait until replication is stopped
    
     ![image0032](Media/image0032.png)

1. Clean up environment.
1.  
   To save money, delete the server you created to be a read replica (pgserver[your name initials]-r1)
    
   On the Overview Pane, select **Delete**. Type the server name and click on **Delete**
    
   ![image0035](Media/image0035.png)

Congratulations!. You have successfully completed this exercise and the Lab. 
