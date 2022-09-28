# Review the different access controls for Azure Database for PostgreSQL Single Server

**Introduction**

During this lab, you will learn how to configure Firewall and Virtual Network rules for Azure Database for PostgreSQL

**objectives**

After completing this lab, you will be able to: 

- Configure Firewall rules
- Understand and implement Virtual Network access

**Considerations**

This lab considers that an Azure Database for PostgreSQL Single Server named pgserver[your name initials] exists with a server admin login named *admpg*, if not, create it or use another existing server before continuing with the lab.

**Estimated Time:** 120 minutes

----

## Exercise 1: Create a firewall rule in the Azure portal

This exercise shows how to create a server-level firewall rule in the Azure portal for Azure Database for PostgreSQL.

**Tasks**

1. Connect to Microsoft Azure Portal
    
   Open Microsoft Edge and navigate to the [Azure Portal](http://ms.portal.azure.com) to connect to Microsoft Azure Portal. Login with your subscriptions credential.
![Image116](Media/image116.png)

1. Configure a server-level firewall rule

   The Azure Database for PostgreSQL service creates a firewall at the server level. It prevents external applications and tools from connecting to the server and any databases on the server, unless a firewall rule is created to open the firewall for specific IP addresses.

   Go to your Azure Database for PostgreSQL Single Server in any way you prefer to look for a resource on Azure
   
   Select **Connection security** under **Settings**
![Image117](Media/image117.png)


   If no rule exists, click **Add client IP** on the toolbar. This automatically creates a firewall rule with the public IP address of your computer, as perceived by the Azure system. Change the name of the rule to “Lab-VM-Public-IP”.

   ![Image0118](Media/image0118.png)
   As you can see the IP address of my computer is 99.66.180.17

   After adding it make sure you click save or else the rule will not be added.

 If not enabled, configure the server to  Allow access to Azure services

![Image0119](Media/image0119.png)

   Add to new rule for a single IP: Rule-1-Single-Address from 73.109.45.192 to 73.109.45.192

   Add to new rule for an IP range: Rule-2-Range-of-IP-Addresses from 73.109.44.0 to 73.109.44.255

   The final configuration must look like:

  ![Image0120](Media/image0120.png)

   Click **Save**

   To allow applications from Azure to connect to your Azure Database for PostgreSQL Single Server, Azure connections must be enabled. For example, to host an Azure Web Apps application, or an application that runs in an Azure VM, or to connect from an Azure Data Factory data management gateway. The resources do not need to be in the same Virtual Network (VNet) or Resource Group for the firewall rule to enable those connections. When an application from Azure attempts to connect to your database server, the firewall verifies that Azure connections are allowed. There are a couple of methods to enable these types of connections:
   - A firewall setting with starting and ending address equal to 0.0.0.0 indicates these connections are allowed. 
   - You can set the **Allow access to Azure services** option to **Yes** in the portal from the **Connection security** pane and hit **save**. 
    
   ![Image0121](Media/image0121.png)

   If the connection attempt is not allowed, the request does not reach the Azure Database for PostgreSQL Single Server.

   Setting **Allow access to Azure services** option to **ON** configures the firewall to allow all connections from Azure including connections from the subscriptions of other customers. When selecting this option, make sure your login and user permissions limit access to only authorized users.

Congratulations!. You have successfully completed this exercise.

---

## Exercise 2: Connect to an Azure Database for PostgreSQL Single Server from a VM in Azure thought the VNET 

This exercise shows how to connect to Azure Database for PostgreSQL Single Server from a VM in a VNET.

**Tasks**

1. Connect to Microsoft Azure Portal
    
   Open Microsoft Edge and navigate to the [Azure Portal](http://ms.portal.azure.com) to connect to Microsoft Azure Portal. Login with your subscriptions credential.

1. Create a VNET for your Azure Virtual Machine

   Click on **+ Create a resource** and look for **virtual network**

  ![Image0122](Media/image0122.png) 

   Select **Virtual Network**

   On the **Virtual Network** screen, make sure the **Resource Manager** deployment model is selected and click on **Create**

   ![](Media/image0096.png)

   Configure the VNET using the following information:
    
   In the **Basics** tab
   - **Resource group**: Create a new one named *rgvms**
   - **Name**: VNETDB
   - **Location**: use the same location as your Azure Database for PostgreSQL Single Server

   ![Image0123](Media/image0123.png) 
![Image0124](Media/image0124.png)

   In the **IP Addresses** tab
   - **Address Space**: 10.1.0.0/22
   - **Subnet/Name**: Add a subnet named **default**
   - **Subnet/Address range**: 10.1.0.0/24
   - Use default values for all other settings

   Click next it will take you to the security tab that has options on how to enhance the security of your virtual network. Click next again and it take take you to the IP addresses tab.

   ![Image0126](Media/image0126.png)
   
![Image0127](Media/image0127.png)
   
   Click **Review and Create** and wait for the deployment to complete

![Image0128](Media/image0128.png)

1. Create a JumpBox VM to manage Azure Database for PostgreSQL.

   Click on **+ Create a resource** and look for **windows 10.**

   Select the latest version (it can be different from the one in the image below)

   ![Imge0128](Media/imge0128.png)

   Click on **Create**

   Configure the VM using the following information on the **Basic** tab:
   - **Resource group:** rgvms (the same used by the VNET created in the previous task)
   - **Name:** VMWin10PG
   - **Region:** use the same region as your Azure Database for PostgreSQL Single Server and the VNET created in the previous task
   - **Size:** Standard D2
   - **Administrator Account**: define it yourself. Take note of the user and the password
   - **Inbound port rules**: allow RDP (3389)
   - Use default values for all other settings

   ![Image0129](Media/image0129.png)
   
   Make sure you confirm that you have an eligible Windows 10/11 license with multi-tenant hosting rights.
   
   Click next it will take you to the Disk tab. Click next to Networking. 
   On the **Networking** tab, make sure the VNET created in the previous task is selected (VNETDB on this manual)

   ![Image0130](Media/image0130.png)

   Click on **Review + create**

![Image0131](Media/image0131.png)



   Click **Create** and wait until the VM is created. It can take up to 10 minutes. This is a good time to take a break.

   ![](Media/image0103.png)

1. Connect to the Azure VM and install pgAdmin
    
   Go to the Azure VM you just created. Click on **Connect**.
    
   ![Image0132](Media/image0132.png)
    
   Click on **Download RDP File**
    
   ![](Media/image0105.png)
   
   A Remote Desktop Protocol (.rdp) file is created and downloaded to your computer.
    
   Open the downloaded rdp file. If prompted, select **Connect**. Enter the username and password you specified when creating the VM. You may need to select **More choices**, then **Use a different account**, to specify the credentials you entered when you created the VM.
    
   Select **OK**.
    
   You may receive a certificate warning during the sign-in process. If you receive the warning, select **Yes** or **Continue**, to proceed with the connection.
    
   ![](Media/image0106.png)

   After this go back to the VM

![Image0133](Media/image0133.png)

Click on Add an inbound network security group rule with destination port 3389

![Image0134](Media/image0134.png)

Click on add Inbound port rule

For service select RDP and destination port will be selected

![Image0135](Media/image0135.png)

After this go back to the VM and test if you can connect now. 

![Image0136](Media/image0136.png)

    
   In the VM, open Microsoft Edge and go to [https://www.pgadmin.org/download/](https://www.pgadmin.org/download/)
    
   Download the last version available and install it
    
   ![](Media/image0107.png)

1. Connect to the Azure Database for PostgreSQL from the VM in the VNET
    
   In the VM, open pgAdmin
    
   ![](Media/image0108.png)
    
   When you open pgAdmin for the first time you might to set a master password, use *Password1!*

![Image0137](Media/image0137.png)

Please make sure you enter the master key otherwise you will have a crypto key missing error when you try connecting.

   Register your Azure Database for PostgreSQL Single Server
    
   ![](Media/image0109.png)

   After entering all the credentials, click test connection

   I am able to connect to My Azure database For PostgreSQL through my VM. 

   Take note: I was able to connect because I have set Allow access to Azure services to YES on my Azure database for PostgreSQL
    
![Image0140](Media/image0140.png)

    If this was set to NO, then the connection will fail in which case you will need to add a VNET Rule to your Azure database for PostgreSQL  as below

![Image0138](Media/image0138.png)

![Image0139](Media/image0139.png)

  
    
   Why does this happen?

1. Create a VNET rule

   You cannot connect to the Azure Database for PostgreSQL Single Server because:
   - Allow access to Azure services is disabled.
   - There is no firewall rule for the IP used by this VM.
   - There is no VNET rule for the Virtual Network used by this VM.

   You could enable **Allow access to Azure services** but this option configures the firewall to allow all connections from Azure including connections from the subscriptions of other customers. In this lab, we want to limit the access to the server for security reasons.

   You could create a rule for the Public IP of the virtual machine, but you need to make sure it is a statics IP or you will need to update the rule if the VM gets a different IP in the future

   In this lab, you will create a VNET rule to allow connections from the VNET used by the Virtual Machine.

   Go to your Azure Database for PostgreSQL Single Server. Select **Connection security** under **Settings**

   Click on **+ Adding existing virtual network** in the **VNET Rules** section

   Set a name for the rule, select your subscription and the VNET you created in task 3.

   ![Image0141](Media/image0141.png)
   
  

   The rule will be listed for the server


   >Notice that you were connected to Azure Database for PostgreSQL Server without specify a firewall rule, you are connected to the server because the VM is joined to the subnet where you have configured the VNET Rule.

Congratulations!. You have successfully completed this exercise.

---


## Exercise 4: Cleanup the environment

To save money, delete the VM you created in this lab.

To make the process simpler, delete the Resource Group you created to contain the VM and the Virtual Network. Deleting a resource group deletes all the resources contained within it.

**Tasks**

1. Connect to Microsoft Azure Portal
    
   Open Microsoft Edge and navigate to the [Azure Portal](http://ms.portal.azure.com) to connect to Microsoft Azure Portal. Login with your subscriptions credential.

1. Delete the resource group
    
   On the left blade click on **Resource Groups**
    
   Click on the resource group *rgvms* (or the resource group you created on exercise 2)
    
   In the upper menu click on **Delete resource group**.
   
   ![](Media/image0115.png)
    
   Type the name of the resource group and click **Delete**

Congratulations!. You have successfully completed this exercise and the Lab.

