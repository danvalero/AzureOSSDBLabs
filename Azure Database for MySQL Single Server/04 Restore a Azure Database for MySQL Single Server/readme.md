# Restore an Azure Database for MySQL Single Server to a point in time

**Introduction**

During this lab, you will learn how to restore an Azure Database for MySQL Single Server to a point in time and how to restore a deleted server

**Objectives** 

After completing this lab, you will be able to: 

- Restore an Azure Database for MySQL Single Server to a point in time
- Restore a Deleted Azure Database for MySQL Single Server

**Considerations**

This lab considers that an Azure Database for MySQL Single Server named mysqlserver[your name initials] exists with a server admin login named *admmysql*, if not, create it or use another existing server before continuing with the lab.

**Estimated Time:** 60 minutes

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
    
   ![Image0062](Media/image0062.png)

   Select the recovery point and the name for the new server. The last recovery points depend on when the server was created and the retention policy. 
   
   >For lab purposes, if you server was created recently, select a recovery point not older than 5 minutes.

   Notice that a message indicates the retention policy configured for this server. You will see the following message, however, you can see a different message if using another server or have not completed previous labs.

   ![Image0063](Media/image0063.png)

   As the name of the server, use the name of your server and add *-recovered* at the end.

   Notice that the new server will be created on the same location and using the same pricing tier than the original server (but you can change it later)

   ![Image0064](Media/image0064.png)

   Click **OK**

   Wait for the new server to be created

   ![Image0065](Media/image0065.png)

1. Access the restored server
    
   Go to the MySQL Server you create on the previous step using your preferred method.
    
   ![Image0066](Media/image0066.png)

   >Now you can administer and access this server as you do with any other Azure Database for MySQL. You can change the administrator password, change the backup retention policies, change the pricing tier and do any administrative task you want as this is server independent to the one you restored from.

1. Delete the Azure Database for MySQL Single Server
    
   To save money, delete the server you created as part of the restore operation
    
   On the Overview Pane, select **Delete** and then confirm deletion.

Congratulations! You have successfully completed this exercise.

---

## Exercise 2: Restore a Deleted Azure Database for MySQL Single Server

This exercise shows how to restore a Deleted Azure Database for MySQL Single Server

When a server is deleted, the database server backup can be retained up to five days in the service a nd will work only if the backup for the server is still available and not deleted from the system.

>For lab purposes you will delete the server used for this lab. 

**Tasks**

1. Connect to Microsoft Azure Portal
    
   Open Microsoft Edge and navigate to the [Azure Portal](http://ms.portal.azure.com) to connect to Microsoft Azure Portal. Login with your subscriptions credential.
    
1. Go to your MySQL Server

   Go to your Azure Database for MySQL Single Server in any way you prefer to look for a resource on Azure

1. Delete the Azure Database for MySQL Single Server
 
   On the Overview Pane, select **Delete** and then confirm deletion.
   
   ![Image0067](Media/image0067.png)

   >NOOOO!!! You deleted a production server... now you need to recover it.

1. Get the deletion details

   Go to the **Activity Log** and identify the event for the server deletion. 

   ![Image0068](Media/image0068.png)

   Click on the event, select the **JSON** option and note the *resourceId* and *submissionTimestamp* attributes in JSON output

   ![Image0069](Media/image0069.png)

1. Recover the deleted server 

   Go to Create Server [REST API Page](https://docs.microsoft.com/en-us/rest/api/mysql/singleserver/servers(2017-12-01)/create?tabs=HTTP)  and click on "Try It" tab highlighted in green and login in with your Azure account.

   Provide the resourceGroupName, serverName (deleted server name), subscriptionId, derived from resourceId attribute captured in task 4

   ![Image0070](Media/image0070.png)

   Scroll below on **Body** section and paste the following:

   ```JSON
   {
    "location": "Dropped Server Location",  
    "properties": 
        {
            "restorePointInTime": "submissionTimestamp - 15 minutes",
            "createMode": "PointInTimeRestore",
            "sourceServerId": "resourceId"
        }
   }
   ```

   Replace the following values in the above request body:
   - "Dropped server Location" with the Azure region where the deleted server was originally created
   - "submissionTimestamp", and "resourceId" with the values captured in task 4
   - For "restorePointInTime", specify a value of "submissionTimestamp" minus 15 minutes to ensure the command does not error out.

   ![Image0071](Media/image0071.png)
   
   Click on **Run**. If you see Response Code 201 or 202, the restore request is successfully submitted.

   The restore status can be monitored from Activity log by filtering for:
   - Subscription = Your Subscription
   - Resource Type = Azure Database for MySQL servers (Microsoft.DBforMySQL/servers)
   - Operation = Update MySQL Server Create

   ![Image0072](Media/image0072.png)

   >The server creation can take time depending on the database size and compute resources provisioned on the original server

   When the restore is done the operation will be marked as **Succeeded**

   ![Image0073](Media/image0073.png)

1. Explore your restored server

   Go to your Azure Database for MySQL Single Server in any way you prefer to look for a resource on Azure

   ![Image0074](Media/image0074.png)

   The server has been restored!!!!

1. Bonus: Prevent accidental deletion of servers

   To prevent accidental deletion of servers, we highly recommend using Resource Locks.

   Go to your Azure Database for MySQL Single Server in any way you prefer to look for a resource on Azure

   Click on **Locks** under **Settings**

   Click on **+ Add**

   Set a lock name, select lock type *Delete* and add a note that explain the purpose of the lock

   ![Image0080](Media/image0080.png)

   Click **OK**

   Go to the **Overview** panel ant try to delete the server. You delete operation will not succeed with message

   ![Image0081](Media/image0081.png)

   To delete the server you must delete the lock first, so if the server is deleted it won´t be accidental.


Congratulations!. You have successfully completed this exercise and the Lab. 