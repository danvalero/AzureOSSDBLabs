# Add additional users to an Azure Database for PostgreSQL Single Server Single Server

**Introduction** 

During this lab, you will review how to add additional users for application connectivity

**Objectives**

After completing this lab, you will be able to: 

- Create database users in Azure Database for PostgreSQL
- Magane database users with Azure Active Directory (AAD) authentication

**Prerequisites**

This lab considers that an Azure Database for PostgreSQL Single Server named pgserver[your name initials] exists with a server admin login named *admpg*, if not, create it or use another existing server before continuing with the lab.

**Estimated Time:** 60 minutes

**Exercise list**
- [Add additional users to an Azure Database for PostgreSQL Single Server Single Server](#add-additional-users-to-an-azure-database-for-postgresql-single-server-single-server)
  - [Exercise 1: Create additional admin users in Azure Database for PostgreSQL](#exercise-1-create-additional-admin-users-in-azure-database-for-postgresql)
  - [Exercise 2: Create database users in Azure Database for PostgreSQL](#exercise-2-create-database-users-in-azure-database-for-postgresql)
  - [Exercise 3: Setting and connecting with the Azure AD Admin user](#exercise-3-setting-and-connecting-with-the-azure-ad-admin-user)
  - [Exercise 4: Setting and connecting with Azure AD regular users in Azure Database for PostgreSQL](#exercise-4-setting-and-connecting-with-azure-ad-regular-users-in-azure-database-for-postgresql)

---

## Exercise 1: Create additional admin users in Azure Database for PostgreSQL

This exercise shows how to create additional admin users in Azure Database for PostgreSQL

**Tasks**

1. Connect to Microsoft Azure Portal
    
   Open Microsoft Edge and navigate to the [Azure Portal](http://ms.portal.azure.com) to connect to Microsoft Azure Portal. Login with your subscriptions credential.

1. Go to your Azure Database for PostgreSQL Single server in any way you prefer to look for a resource on Azure. Get the connection information as you will use it during the lab

   ![Image0208](Media/image0208.png)

1. Connect to your Azure Database for PostgreSQL Single Server using the details from the previous step

   Open **pgAdmin** and connect to your server using the admin user.

   ![Image0209](Media/image0209.png)
   
   Expand the server just registered, right click to the *postgres* database and open the **Query Tool**

   ![Image0212](Media/image0212.png)

1. Review the default roles defined when The Azure Database for PostgreSQL Single Server is created
           
   The Azure Database for PostgreSQL Single Server is created with the 3 default roles defined.
   - azure_pg_admin
   - azure_superuser
   - your server admin user
    
   To see all existing roles, execute:
    
   ```sql
   SELECT rolname FROM pg_roles;
   ```
   
   You will see the three default roles defined on every Azure Database for PostgreSQL Single Server:
    
   ![Image0213](Media/image0213.png)
    
   >Your server admin user is a member of the *azure_pg_admin* role. However, the server admin account is not part of the azure_superuser role. Since this service is a managed PaaS service, only Microsoft is part of the super user role.
    
   In Azure Database for PostgreSQL, the server admin user is granted these privileges: 
   - LOGIN 
   - NOSUPERUSER 
   - INHERIT 
   - CREATEDB 
   - CREATEROLE 
   - NOREPLICATION
    
   The server admin user account can be used to create additional users and grant those users into the *azure_pg_admin* role. Also, the server admin account can be used to create less privileged users and roles that have access to individual databases and schemas.

1. Create a new admin user
    
   To create a new admin user, on the **postgres** database, execute:
    
   ```sql
   CREATE ROLE [new_user] WITH LOGIN NOSUPERUSER INHERIT CREATEDB CREATEROLE NOREPLICATION PASSWORD '[StrongPassword]';
   GRANT azure_pg_admin TO [new_user];
   ```
   >IMPORTANT: Replace *[new_user]* with your new username and replace *[StrongPassword]* with your own strong password.

   For example:

   ```sql
   CREATE ROLE admin2 WITH LOGIN NOSUPERUSER INHERIT CREATEDB CREATEROLE NOREPLICATION PASSWORD 'SuperStrongPassword!';
   GRANT azure_pg_admin TO admin2;
   ```
    
   ![Image0118](Media/image0118.png)

Congratulations!. You have successfully completed this exercise.

---

## Exercise 2: Create database users in Azure Database for PostgreSQL

This exercise shows how to Create less privileged users and roles that have access to individual databases and schemas

**Tasks**

1. Connect to your Azure Database for PostgreSQL Single Server using the information retrieved in the previous exercise. 

   Using **pgAdmin**, connect to your server using the admin user.

   Right click to the *postgres* database and open the **Query Tool**
 
1. Create new database users

   Create a new database, by executing:

   ```sql
   CREATE DATABASE testdb;
   ```

   Create a new user and grant CONNECT and CREATE privileges to the new user on the database, by executing:

   >  Refer to the [PostgreSQL Privileges](https://www.postgresql.org/docs/current/ddl-priv.html) for further details on database roles and privileges.

   ```sql
   CREATE ROLE [new_user] WITH LOGIN NOSUPERUSER INHERIT NOCREATEROLE NOREPLICATION PASSWORD '[StrongPassword]';
   GRANT CONNECT, CREATE ON DATABASE [database_name] TO [new_user];
   ```

   >Replace *[new_user]* with the name of the user you want to create. Replace *[your initials]* with your initials if the database [your initials]db exists, if not, use a different database. Replace *[StrongPassword]* with your own strong password.

   For example:

   ```sql
   CREATE ROLE dbuser WITH LOGIN NOSUPERUSER INHERIT NOCREATEROLE NOREPLICATION PASSWORD 'A43.adjsa8.!s';
   GRANT CONNECT, CREATE ON DATABASE testdb TO dbuser;
   ```

   ![Image0119](Media/image0119.png)
 
1. Log in to your server, using the new username and create a table
    
   Using **pgAdmin**, connect to your database with the user created in the previous task
    
   When registering the server, make sure you set the database where you granted permission in the previous tasks in the **Maintenance Database** field
    
   ![Image0121](Media/image0121.png)
    
   Right click on your database (*testdb* in this example) and open the **Query Tool**

   Create a table by executing:

   ```sql
   CREATE TABLE public.testtable
   (   id integer not null,
       name character varying(25) not null,
       primary key (id)
   );
   ```

   ![Image0122](Media/image0122.png)

   List the tables in the database, you will see the table you just created.

   ![Image0123](Media/image0123.png)

Congratulations!. You have successfully completed this exercise.

---

## Exercise 3: Setting and connecting with the Azure AD Admin user

This exercise shows how to configure Azure Active Directory access with Azure Database for PostgreSQL, and how to connect using an Azure AD token

**Tasks**

1. Connect to Microsoft Azure Portal
    
   Open Microsoft Edge and navigate to the [Azure Portal](http://ms.portal.azure.com) to connect to Microsoft Azure Portal. Login with your subscriptions credential.

1. Go to your PostgreSQL Server 

   Go to your Azure Database for PostgreSQL Single server in any way you prefer to look for a resource on Azure.

1. Set the Azure Active Directory admin user
    
   Under the **Settings** section in the sidebar, select **Active Directory admin**
    
   Click on **Set Admin**
    
   ![](Media/image0124.png)
    
   Look for the user you want to add. For this lab, look for the user you are logged in with. Click **Select**
    
   ![](Media/image0125.png)
    
   You will see the selected user as the Active Directory Admin. Click on **Save**
    
   ![](Media/image0126.png)

   >Only one Azure AD admin can be created per PostgreSQL single server and selection of another one will overwrite the existing Azure AD admin configured for the server. You can specify an Azure AD group instead of an individual user to have multiple administrators. Note that you will then sign in with the group name for administration purpose

1. Install Azure CLI

   If you have not done it yet. Install Azure CLI following the instructions at [How to install the Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli) 

1. Connect Azure Database for PostgreSQL Single Server using Azure Active Directory
    
   Open the **Windows Powershell**
    
   Invoke the Azure CLI tool to authenticate with Azure AD. It requires you to give your Azure AD user ID (the one you set as Azure Active Directory admin in the previous step) and the password:
    
   ```bash
   az login
   ```
    
   ![](Media/image0201.png)
    
   Acquire an access token for the Azure AD authenticated user to access Azure Database for PostgreSQL by executing:

   ```bash
   az account get-access-token --resource-type oss-rdbms
   ```

   ![](Media/image0203.png)
   
   Copy the token from the previous command (do not include the quotes " on the beginning and the end)

   Connect to the PostgreSQL using **pgAdmin**. To connect using Azure AD token with pgAdmin you need to follow the next steps:
   - Uncheck the connect now option at server creation.
   
     ![Image0204](Media/image0204.png)

   - Enter your server details in the connection tab and save.
        
     ![Image0205](Media/image0205.png)

   - From the browser menu, select connect to the Azure Database for PostgreSQL server
   
   - Enter the AD token password when prompted.

   ![Image0206](Media/image0206.png)

 You have successfully set an Azure Active Directory admin and logged to the Azure Database for PostgreSQL Single Server with it.

Congratulations!. You have successfully completed this exercise.

---

## Exercise 4: Setting and connecting with Azure AD regular users in Azure Database for PostgreSQL

This exercise shows how to configure Azure Active Directory access with Azure Database for PostgreSQL to add a non-admin user

> For this exercise you will need to have completed the previous exercise

**Tasks**

1. Connect Azure Database for PostgreSQL Single Server using Azure Active Directory admin user

   Connect Azure Database for PostgreSQL Single Server using Azure Active Directory admin user as explained in the previous exercise.

   Right click to the *postgres* database and open the **Query Tool**

1. Add the Azure AAD non admin user

   Create the Azure AAD non admin user by executing: 
   
   >Don'tt use the name of a user or group already set at Admin User for the server:

   ```SQL
   CREATE ROLE "<userid>@<domain>" WITH LOGIN IN ROLE azure_ad_user;
   ```

   >IMPORTANT: Replace *\<userid\>@\<domain\>* with the user you want to add.

   ![Image0214](Media/image0214.png)

Now the user that you just added can connect to the PostgreSQL database using AAD authentication.   

Congratulations! You have successfully completed this exercise and the Lab. 