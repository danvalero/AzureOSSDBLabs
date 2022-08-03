# Restore a Azure Database for MySQL Single Server to a point in time

**Introduction**

During this lab, you will learn how to restore an Azure Database for MySQL Single Server to a point in time and how to restore a deleted server

**Objectives** 

After completing this lab, you will be able to: 

- Restore an Azure Database for MySQL Single Server to a point in time
- Restore a Deleted Azure Database for PostgreSQL Single Server

**Considerations**

This lab considers that an Azure Database for MySQL Single Server named mysqlserver[your name initials] exists with a server admin login named *admmysql*, if not, create it or use another existing server before continuing with the lab.

**Estimated Time:** 10 minutes

---

## Exercise 1: Restore a server to a point in time

This exercise shows how to restore an Azure Database for MySQL Single Server to a point in time

**Tasks**

1. Connect to Microsoft Azure Portal
    
   Open Microsoft Edge and navigate to the [Azure Portal](http://ms.portal.azure.com) to connect to Microsoft Azure Portal. Login with your subscriptions credential.
    
1. Go to your MySQL Server

   Go to your Azure Database for MySQL Single Server in any way you prefer to look for a resource on Azure

1. Restore the server to a point in time
    
   Click **Restore**
    
   ![](Media/image0062.png)

   Select the recovery point and the name for the new server. The last recovery points depend on when the server was created and the retention policy. If you server was created recently, select a recovery point not older than 5 minutes.

   Notice that a message indicates the retention policy configured for this server. You will see the following message, however, you can see a different message if using another server or have not completed previous labs.

   ![](Media/image0063.png)

   As the name of the server, use the name of your server and add *-recovered* at the end.

   Notice that the new server will be created on the same location and using the same pricing tier than the original server (but you can change it later)

   ![](Media/image0064.png)

   Click **OK**

   Wait for the new server to be created and pin it to the dashboard

   ![](Media/image0065.png)

1. Access the restored server
    
   Go to the MySQL Server you create on the previous step using your preferred method.
    
   Now you can administer and access this server as you do with any other Azure Database for MySQL. You can change the administrator password, change the backup retention policies, change the pricing tier and do any administrative task you want as this is server independent to the one you restored from.
    
   ![](Media/image0066.png)

1. Delete the Azure Database for MySQL Single Server
    
   To save money, delete the server you created as part of the restore operation
    
   On the Overview Pane, select **Delete**. Type the server name and click on **Delete**

Congratulations! You have successfully completed this exercise.

---

## Exercise 2: Restore a Deleted Azure Database for PostgreSQL Single Server

This exercise shows how to restore a Deleted Azure Database for PostgreSQL Single Server

**Tasks**

1.

1.

1.

Congratulations!. You have successfully completed this exercise and the Lab. 