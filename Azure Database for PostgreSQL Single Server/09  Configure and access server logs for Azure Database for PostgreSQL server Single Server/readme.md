# Configure and access server logs for Azure Database for PostgreSQL Single Server Single Server

**Introduction**

During this lab, you will learn how to Configure and access server logs in Azure Database for PostgreSQL.

**Objectives**

After completing this lab, you will be able to: 

- Configure server logs in Azure Database for PostgreSQL from the Azure portal
- Access server logs in Azure Database for PostgreSQL from the Azure portal

**Considerations**

This lab considers that an Azure Database for PostgreSQL Single Server named pgserver[your name initials] exists with a server admin login named *admpg*, if not, create it or use another existing server before continuing with the lab.

**Estimated Time:** 30 minutes

---

## Exercise 1: Configure server logs in Azure Database for PostgreSQL from the Azure portal

This exercise shows how to, configure server logs in Azure Database for PostgreSQL from the Azure portal and to enable the logging of DDL sentences.

**Tasks**

1. Connect to Microsoft Azure Portal
    
   Open Microsoft Edge and navigate to the [Azure Portal](http://ms.portal.azure.com) to connect to Microsoft Azure Portal. Login with your subscriptions credential.

1. Go to your PostgreSQL Server

   Go to your Azure Database for PostgreSQL Single Server in any way you prefer to look for a resource on Azure

1. Under the **Monitoring** section in the sidebar, select **Server Logs**.
    
   ![](Media/image0159.png)

1. Select the heading **Click here to enable logs and configure log parameters** to see the server parameters.
    
   ![](Media/image0160.png)
    
   Explore the parameters that control logging behavior

1. Change the **log_statement** parameter to **DDL** then click **Save**.
    
    ![](Media/image0161.png)

Congratulations!. You have successfully completed this exercise.

---

## Exercise 2: Test logging for DDL statements and access server logs

This exercise you will execute a DDL operation and then access the server logs in Azure Database for PostgreSQL from the Azure portal to see the entry for the operation.

**Tasks**

1. Connect to Microsoft Azure Portal
    
   Open Microsoft Edge and navigate to the [Azure Portal](http://ms.portal.azure.com) to connect to Microsoft Azure Portal. Login with your subscriptions credential.

1. Go to your PostgreSQL Server

   Go to your Azure Database for PostgreSQL Single Server in any way you prefer to look for a resource on Azure

1. Identify the connection information for the Azure Database for PostgreSQL Single Server

   Make a note of the **Server name** and the **Server admin login name**.

   ![](Media/image0162.png)

1. Register your Azure Database for PostgreSQL on pgAdmin.

   Open pgAdmin and register your Azure Database for PostgreSQL using the admin user. If you are asked to set a master password, use *Password1!*

   From the toolbar go to **Object**, hover over **Create**, and select **Server**.

   In the **Create - Server dialog** box, on the **General** tab, enter a unique friendly name for the server, such as *pgserver[your name initials]*.

   ![](Media/image0163.png)

   In the **Create - Server** dialog box, on the **Connection** tab, fill in the settings table.

   ![](Media/image0164.png)

   In the **Create - Server** dialog box, on the **SSL** tab, select SSL mode *Require*.

   ![](Media/image0165.png)

   Click **Save**

   If you get a message like:

   ![](Media/image0166.png)

   You must allow access from the Virtual Machine to the Azure Database for PostgreSQL by adding a rule for the client machine IP address. Go to **Connection security** in **Settings**, add the rule and click **Save**.

   ![](Media/image0167.png)

1. Execute some DLL operations
    
   Let's create a database and a table.
    
   Right click **Databases** then **Create > Database**
    
   ![](Media/image0168.png)
    
   Use *customer* as database name and then click **Save**.
    
   ![](Media/image0169.png)
    
   Right click on *customers* database and select **Query Tool**
    
   ![](Media/image0170.png)
    
   Execute the following script to create a schema called *person* and create a table called *person*:
    
   ```sql
   CREATE SCHEMA person;
   
   CREATE TABLE person.person
   (
       person_id int not null,
       person_name varchar(100) not null
   );
   ```
    
   ![](Media/image0171.png)

1. Examine the server log and find the DLL operations entries
    
   Open Microsoft Edge and navigate to the [Azure Portal](http://ms.portal.azure.com) to connect to Microsoft Azure Portal. Login with your subscriptions credential.

   Go to your Azure Database for PostgreSQL Single Server in any way you prefer to look for a resource on Azure

   Under the **Monitoring** section in the sidebar, select **Server Logs**. The page shows a list of your log files, as shown:

   ![](Media/image0172.png)

   >The naming convention of the log is postgresql-yyyy-mm-dd_hh0000.log. The date and time used in the file name is the time is when the log was issued. The log files rotate every hour or 100-MB size, whichever comes first.

   Download individual log files using the download button (down arrow icon) next to each log file in the table row.

   ![](Media/image0173.png)

   Open the file you just downloaded and review that the DDL statements were logged.

   ![](Media/image0174.png)

Congratulations!. You have successfully completed this exercise and the Lab.