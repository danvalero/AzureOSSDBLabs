# Add additional users to an Azure Database for MySQL Single Server Single Server

**Introduction** 

During this lab, you will review how to add additional users for application connectivity

**Objectives**

After completing this lab, you will be able to: 

- Create database users in Azure Database for MySQL
- Magane database users with Azure Active Directory (AAD) authentication

**Considerations**

This lab considers that an Azure Database for MySQL Single Server named mysqlserver[your name initials] exists with a server admin login named *admmysql*, if not, create it or use another existing server before continuing with the lab.

**Estimated Time:** 1 hour and 30 minutes

---

## Exercise 1: Create additional admin users in Azure Database for MySQL

This exercise shows how to create additional admin users in Azure Database for MySQL

**Tasks**

1. Connect to Microsoft Azure Portal
    
   Open Microsoft Edge and navigate to the [Azure Portal](http://ms.portal.azure.com) to connect to Microsoft Azure Portal. Login with your subscriptions credential.

1. Connect to your Azure Database for MySQL Single Server

   Open **MySQL Workbench** and connect to your server using the admin user. 

1. Review the default users defined when The Azure Database for MySQL Single Server is created
           
   The Azure Database for MySQL Single Server is created with the 2 default users defined.
    
   Run the following command:
    
   ```sql
   use sys;

   SELECT user, host FROM mysql.user;
   ```
   
   You will see the two default users defined on every Azure Database for MySQL Single Server:
   - azure_superuser
   - your server admin user
   
   ![](Media/image0201.png)
    
   
   In Azure Database for MySQL, the server admin user is granted these privileges: 
   - SELECT
   - INSERT
   - UPDATE
   - DELETE
   - CREATE
   - DROP
   - RELOAD
   - PROCESS
   - REFERENCES
   - INDEX
   - ALTER
   - SHOW DATABASES
   - CREATE TEMPORARY TABLES
   - LOCK TABLES
   - EXECUTE
   - REPLICATION SLAVE
   - REPLICATION CLIENT
   - CREATE VIEW
   - SHOW VIEW
   - CREATE ROUTINE
   - ALTER ROUTINE
   - CREATE USER
   - EVENT
   - TRIGGER
   - CREATE ROLE
   - DROP ROLE
   - ROLE_ADMIN
   - XA_RECOVER_ADMIN
    
   The server admin user account can be used to create additional users and grant those users into the *azure_pg_admin* role. Also, the server admin account can be used to create less privileged users and roles that have access to individual databases and schemas.

1. Create a new admin user
   
   1. Before creating the new admin user, check the current privileges of the admin user:
      ```sql
      SHOW GRANTS;
      ```

   1. Copy each line from the results, you may have multiple lines, and paste it back to MySQL Workbench (to copy right click and use 'Copy Row (unquoted)')
      ![](Media/image0202.png)

   1. In each of the lines, replace the current admin user with the new admin user:
      ![](Media/image0203.png)

   1. Create the new admin user, on the **MySQL** database, execute:
    
      ```sql
      CREATE USER 'new_master_user'@'%' IDENTIFIED BY 'StrongPassword!';
      ```

   1. Copy the GRANTs from (iii) to MySQL Workbench and execute them (add ; by the end of each GRANT):
      ![](Media/image0204.png)

    
   >IMPORTANT: Replace *[new_user]* with your new username and replace *[StrongPassword]* with your own strong password.
    

Congratulations!. You have successfully completed this exercise.

---

## Exercise 2: Create database users in Azure Database for MySQL

This exercise shows how to Create less privileged users and roles that have access to individual databases and schemas

**Tasks**

1. Connect to Microsoft Azure Portal
    
   Open Microsoft Edge and navigate to the [Azure Portal](http://ms.portal.azure.com) to connect to Microsoft Azure Portal. Login with your subscriptions credential.

1. Go to your MySQL Server

   Go to your Azure Database for MySQL Single Server in any way you prefer to look for a resource on Azure

1. Create new database users

   To create a new user and grant connect privileges to the new database for that user, on the **postgres** database, execute:

   ```sql
   CREATE DATABASE testdb;
   CREATE USER 'db_user'@'%' IDENTIFIED BY 'StrongPassword!';
   GRANT ALL PRIVILEGES ON testdb . * TO 'db_user'@'%';
   FLUSH PRIVILEGES;
   ```

   ![](Media/image0205.png)

   Refer to the [MySQL documentation](https://www.MySQL.org/docs/current/static/ddl-priv.html) for further details on database roles and privileges.

1. Verify the grants within the database.
    
   Run "Show Grants For" to get the permissions for the database user.

   ```sql
   USE testdb;
   SHOW GRANTS FOR 'db_user'@'%';
   ```

   ![](Media/image0206.png)

1. Log in to your server, using the new username and create a table
    
   Using MySQL Workbench, connect to your database with *db_user*.
    
   When registering the server, make sure you set the database where you granted permission in the previous tasks in the **Maintenance Database** field
    
   ![](Media/image0207.png)
    
   Explore the database

   ![](Media/image0208.png)

   Connected to the database, open the query tool. Create a table by executing:

    ```sql
    USE testdb;

    CREATE TABLE testtable
    (   id integer not null,
        name character varying(25) not null,
        primary key (id)
    )
    ```

    List the tables in the database, you will see the table you just created.

    ![](Media/image0209.png)

Congratulations!. You have successfully completed this exercise.

---

## Exercise 3: Setting and connecting with the Azure AD Admin user

This exercise shows how to configure Azure Active Directory access with Azure Database for MySQL, and how to connect using an Azure AD token

**Tasks**

1. Connect to Microsoft Azure Portal
    
   Open Microsoft Edge and navigate to the [Azure Portal](http://ms.portal.azure.com) to connect to Microsoft Azure Portal. Login with your subscriptions credential.

1. Go to your MySQL Server

   Go to your Azure Database for MySQL Single Server in any way you prefer to look for a resource on Azure

1. Set the Azure Active Directory admin user
    
   Under the **Settings** section in the sidebar, select **Active Directory admin**
    
   Click on **Set Admin**
   
   ![](Media/image0210.png)
   
   Look for the user you want to add. For this lab, look for the user you are logged in with. Click **Select**
    
   ![](Media/image0125.png)
   
   You will see the selected user as the Active Directory Admin. Click on **Save**
    
   ![](Media/image0211.png)

   >Only one Azure AD admin can be created per MySQL server and selection of another one will overwrite the existing Azure AD admin configured for the server. You can specify an Azure AD group instead of an individual user to have multiple administrators. Note that you will then sign in with the group name for administration purpose

1. Click **Save**

   ![](Media/image0216.png)

1. Install Azure CLI

   If you have not done it yet. Isntall Azure CLI following the instrcutions at [How to install the Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli) 

1. Connect Azure Database for MySQL Single Server using Azure Active Directory
    
   Open the **Powershell**
    
   Invoke the Azure CLI tool to authenticate with Azure AD. It requires you to give your Azure AD user ID (the one you set as Azure Active Directory admin in the previous step) and the password:
    
   ```bash
   az login
   ```
    
   ![](Media/image0212.png)
    

    
   Acquire an access token for the Azure AD authenticated user to access Azure Database for MySQL by executing:

   ```bash
   az account get-access-token --resource-type oss-rdbms
   ```

   ![](Media/image0214.png)
    
   Using PowerShell, you can use the following command to acquire access token:
   ```bash
   $accessToken = Get-AzAccessToken -ResourceUrl https://ossrdbms-aad.database.windows.net
   $accessToken.Token | out-file C:\\windows\\temp\\MySQLAccessToken.txt   
   ```

    ![](Media/image0215.png)
   
   Connect to MySQL Workbench:
   - Launch MySQL Workbench and Click the Database option, then click "Connect to database"
   - In the hostname field, enter the MySQL FQDN eg. mydb.mysql.database.azure.com
   - In the username field, enter the MySQL Azure Active Directory administrator name and append this with MySQL server name, not the FQDN e.g. user@tenant.onmicrosoft.com@mydb
   - In the password field, click "Store in Vault" and paste in the access token from file e.g. C:\\\windows\\\temp\\\MySQLAccessToken.txt
   - Click the advanced tab and ensure that you check "Enable Cleartext Authentication Plugin"
   - Click OK to connect to the database
   
   Get a list of databases just to validate you have successfully logged in using the Azure Active Directory admin by executing:

   ```sql
   SHOW DATABASES;
   ``` 

   ![](Media/image0217.png)

   You have successfully set an Azure Active Directory admin and logged to the Azure Database for MySQL Single Server with it.

Congratulations!. You have successfully completed this exercise.

---

## Exercise 4: setting and connecting with regular Azure AD users in Azure Database for MySQL

This exercise shows how to configure Azure Active Directory access with Azure Database for MySQL, and how to connect using an Azure AD token for a regular user.

> For this exercise you will need to use your user as the Administrator for the datbase server and another user in Azure Active Directory to log into the database, if you cannot add another user into your Azure Active Directory you may add a colleague to help you test, in that case you may need to also add yours colleague IP address into the MySQL sever firewall [https://docs.microsoft.com/en-us/azure/mysql/single-server/concepts-firewall-rules](https://docs.microsoft.com/en-us/azure/mysql/single-server/concepts-firewall-rules)

**Tasks**

1. Connect to Microsoft Azure Portal
    
   Open Microsoft Edge and navigate to the [Azure Portal](http://ms.portal.azure.com) to connect to Microsoft Azure Portal. Login with your subscriptions credential.

1. Go to your MySQL Server

   Go to your Azure Database for MySQL Single Server in any way you prefer to look for a resource on Azure

1. Set the Azure Active Directory admin user
    
   Under the **Settings** section in the sidebar, select **Active Directory admin**
    
   Click on **Set Admin**
   
   ![](Media/image0210.png)
   
   Look for the your user. For this lab, look for the user you are logged in with. Click **Select**
    
   ![](Media/image0125.png)
   
   You will see the selected user as the Active Directory Admin. Click on **Save**
    
   ![](Media/image0211.png)

   >Only one Azure AD admin can be created per MySQL server and selection of another one will overwrite the existing Azure AD admin configured for the server. You can specify an Azure AD group instead of an individual user to have multiple administrators. Note that you will then sign in with the group name for administration purpose

1. Click **Save**

   ![](Media/image0216.png)

1. Connect Azure Database for MySQL Single Server using Azure Active Directory
    
   Open the **Powershell**
    
   Invoke the Azure CLI tool to authenticate with Azure AD. It requires you to give your Azure AD user ID (the one you set as Azure Active Directory admin in the previous step) and the password:
    
   ```bash
   az login
   ```
    
   ![](Media/image0212.png)
    

    
   Acquire an access token for the Azure AD authenticated user to access Azure Database for MySQL by executing:

   ```bash
   az account get-access-token --resource-type oss-rdbms
   ```

   ![](Media/image0214.png)
    
   Using PowerShell, you can use the following command to acquire access token:
   ```bash
   $accessToken = Get-AzAccessToken -ResourceUrl https://ossrdbms-aad.database.windows.net
   $accessToken.Token | out-file C:\\windows\\temp\\MySQLAccessToken.txt   
   ```

    ![](Media/image0215.png)
   
   Connect to MySQL Workbench:
   - Launch MySQL Workbench and Click the Database option, then click "Connect to database"
   - In the hostname field, enter the MySQL FQDN eg. mydb.mysql.database.azure.com
   - In the username field, enter the MySQL Azure Active Directory administrator name and append this with MySQL server name, not the FQDN e.g. user@tenant.onmicrosoft.com@mydb
   - In the password field, click "Store in Vault" and paste in the access token from file e.g. C:\\\windows\\\temp\\\MySQLAccessToken.txt
   - Click the advanced tab and ensure that you check "Enable Cleartext Authentication Plugin"
   - Click OK to connect to the database

1. In MySQL Workbench, add the user you want log in, this is not the admin user, it can be the user you just added to the Azure Active Directory or your colleague's user:

   ```SQL
   CREATE AADUSER 'user1@yourtenant.onmicrosoft.com';
   ```

   ![](Media/image0218.png)

1. Connect Azure Database for MySQL Single Server using Azure Active Directory with the user added in the previous step.
    
   Open the **Powershell**
    
   Invoke the Azure CLI tool to authenticate with Azure AD. It requires you to give your Azure AD user ID (the one you set as Azure Active Directory admin in the previous step) and the password:
    
   ```bash
   az login
   ```
    
   ![](Media/image0212.png)
    

    
   Acquire an access token for the Azure AD authenticated user to access Azure Database for MySQL by executing:

   ```bash
   az account get-access-token --resource-type oss-rdbms
   ```

   ![](Media/image0214.png)
    
   Using PowerShell, you can use the following command to acquire access token:
   ```bash
   $accessToken = Get-AzAccessToken -ResourceUrl https://ossrdbms-aad.database.windows.net
   $accessToken.Token | out-file C:\\windows\\temp\\MySQLAccessToken.txt   
   ```

    ![](Media/image0215.png)
   
   Connect to MySQL Workbench:
   - Launch MySQL Workbench and Click the Database option, then click "Connect to database"
   - In the hostname field, enter the MySQL FQDN eg. mydb.mysql.database.azure.com
   - In the username field, enter the MySQL Azure Active Directory administrator name and append this with MySQL server name, not the FQDN e.g. user@tenant.onmicrosoft.com@mydb
   - In the password field, click "Store in Vault" and paste in the access token from file e.g. C:\\\windows\\\temp\\\MySQLAccessToken.txt
   - Click the advanced tab and ensure that you check "Enable Cleartext Authentication Plugin"
   - Click OK to connect to the database

Congratulations! You have successfully completed this exercise and the Lab. 
