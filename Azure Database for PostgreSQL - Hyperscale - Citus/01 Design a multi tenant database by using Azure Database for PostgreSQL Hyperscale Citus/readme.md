# Design a multi tenant database by using Azure Database for PostgreSQL Hyperscale Citus

**Introduction**

In this Lab, we will walk through designing a multi-tenant database by using Azure Database for PostgreSQL – Hyperscale.

**Objectives**

After completing this lab, you will be able to: 

- Create a Hyperscale (Citus) server group.
- Use psql utility to create a schema.
- Shard tables across nodes.
- Query tenant data.
- Share data between tenants.
- Customize the schema per-tenant.
- Rebalance shards across nodes.

**Estimated Time:** 90 minutes

**Scenario:**
This lab walks you through creating schema and structure that allows advertisers to track their campaigns through the application.

**Exercise list**
 - [Exercise 1: Create an Azure Database for PostgreSQL - Hyperscale (Citus)](#exercise-1-create-an-azure-database-for-postgresql---hyperscale-citus)
 - [Exercise 2: Connect to the database using psql and Create Schema](#exercise-2-connect-to-the-database-using-psql-and-create-schema)
 - [Exercise 3: Create distributed tables](#exercise-3-create-distributed-tables)
 - [Exercise 4: Create reference tables](#exercise-4-create-reference-tables)
 - [Exercise 5: Customize the schema per-tenant](#exercise-5-customize-the-schema-per-tenant)
 - [Exercise 6: Viewing Metadata Information and Distributed Query Execution](#exercise-6-viewing-metadata-information-and-distributed-query-execution)
 - [Exercise 7: add new workers](#exercise-7-add-new-workers)

---

## Exercise 1: Create an Azure Database for PostgreSQL - Hyperscale (Citus)

Azure Database for PostgreSQL is a managed service that you use to run, manage, and scale highly available PostgreSQL databases in the cloud. This exercise shows you how to create an Azure Database for PostgreSQL - Hyperscale (Citus) server group using the Azure portal.

**Tasks**

1. Connect to Microsoft Azure Portal
    
   Open Microsoft Edge and navigate to the [Azure Portal](http://ms.portal.azure.com) to connect to Microsoft Azure Portal. Login with your subscriptions credential.

1. Create an Azure Database for PostgreSQL - Hyperscale (Citus) server group.
    
   Select **+ Create a resource** in the upper-left corner of the portal.
   
   Select **Databases** from the New page and select **Azure Database for PostgreSQL** from the Databases page.
      
   ![Image0362](Media/image0362.png)

   For the deployment option, select the **Create** button under **Hyperscale (Citus) server group**.
   
   ![Image0363](Media/image0363.png)
    
   Fill out the new server details form with the following information:
   - **Subscription**: Select your subscription
   - **Resource group:** Create a new resource group named *labpgcitus*
   - **Server group name:** cituslab[your name initials]
   - **PostgreSQL version:** 13
   - **Admin username:** Currently required to be *citus* and can't be changed.
   - **Password:** Must be at least eight characters long and contain characters from three of the following categories – English uppercase letters, English lowercase letters, numbers (0-9), and non-alphanumeric characters ("\!, $, \#, %," and so on.)
   
     Note: the password that you specify here is required to sign into the server and its databases. Remember or record this information for later use.

   - **Location:** Use the location that is closest to your users to give them the fastest access to the data
    
   ![Image0364](Media/image0364.png)
    
   Select **Configure server group**.
   
   Set the server group using the information below:

   - **Tiers:** Standard
   - **Worker node count:** 2
   - Use 4 vCores and 0.5TiB for both worker and coordinators nodes
   - Use default values for all other configurations 

   ![Image0365](Media/image0365.png)
    
   Click on **Save**.
     
   Click on **Next: Networking >**

   Select **Public access (allowed IP addresses)**

   Click on **+Add current client IP address (xxx.xxx.xxx.xx)**

   ![Image0366](Media/image0366.png)

   Click on **Review + create** 
    
   Review the configuration and click on **Create** to provision the server. It can take up to 15 minutes for the provisioning to complete.
   
   ![Image0367](Media/image0367.png)

   The page will redirect to monitor deployment. 
    
   ![Image0368](Media/image0368.png)
   
   Wait until the server is created. When the live status changes from **Deployment is in Progress** to **Your deployment is complete**, go to the Azure Database for PostgreSQL Servers, the new server will be listed there.

   ![Image0369](Media/image0369.png)

   Go to the new Azure Database for PostgreSQL server group.
       
   In the **Overview** panel, you will see the server group nodes. The server name ending with **-C** indicates the **coordinator node** and **-w(n)** indicates the **worker nodes.**
   
   ![Image0370](Media/image0370.png)

Congratulations!. You have successfully completed this exercise.

---

## Exercise 2: Connect to the database using psql and Create Schema

When you create your Azure Database for PostgreSQL Hyperscale server, a default database named **citus** is created. 

You can connect to the server group by connecting to the coordinator node using any PostgreSQL client tool.

>Optionally, access to all worker nodes can be enabled. In this case, public IP addresses are assigned to the worker nodes and are secured by the same firewall. Refer to [Public access in Azure Database for PostgreSQL - Hyperscale (Citus)](https://docs.microsoft.com/en-us/azure/postgresql/hyperscale/concepts-firewall-rules) for further information

In this Exercise, you will use the [psql](https://www.postgresql.org/docs/current/app-psql.html) utility, but you can execute all commands by using any other tools such as pgAdmin.

**Tasks**

1. Connect to the database using psql.
    
   Obtain the connection string. In the server group page, under **Settings**, select **Connection strings**. 
    
   Find the string for **psql**.
    
   ![Image0372](Media/image0372.png)
    
   Notice that you connect to the Coordinator node to interact with the cluster.
    
   Copy the connection string. Open a command window and execute the modified command
   
   >You will need to replace {your_password} with the administrative password you chose earlier. The system doesn't store your plain text password and so can't display it for you in the connection string.
    
   For example:
    
   ```bash
   psql "host=c.cituslabdvvr.postgres.database.azure.com port=5432 dbname=citus user=citus password={your_password} sslmode=require"
   ```
    
   If the connection is successful, you will see the prompt *citus=\>*
    
   ![Image0373](Media/image0373.png)

1. Create the database structure.
    
   For this lab, create structure that allows advertisers to track their campaigns through the application.
    
   Multiple companies can use the app, so let's create a table to hold companies and another for their campaigns. In the psql console, run these commands:

   ```sql
   CREATE TABLE companies (
     id bigserial PRIMARY KEY,
     name text NOT NULL,
     image_url text,
     created_at timestamp without time zone NOT NULL,
     updated_at timestamp without time zone NOT NULL
   );

   CREATE TABLE campaigns (
     id bigserial,
     company_id bigint REFERENCES companies (id),
     name text NOT NULL,
     cost_model text NOT NULL,
     state text NOT NULL,
     monthly_budget bigint,
     blacklisted_site_urls text[],
     created_at timestamp without time zone NOT NULL,
     updated_at timestamp without time zone NOT NULL,
     PRIMARY KEY (company_id, id)
   ); 
   ```

   ![Image0374](Media/image0374.png)

   Each campaign will pay to run ads. Add a table for ads too, by running the following code in psql:

   ```sql
    CREATE TABLE ads (
     id bigserial,
     company_id bigint,
     campaign_id bigint,
     name text NOT NULL,
     image_url text,
     target_url text,
     impressions_count bigint DEFAULT 0,
     clicks_count bigint DEFAULT 0,
     created_at timestamp without time zone NOT NULL,
     updated_at timestamp without time zone NOT NULL,
     PRIMARY KEY (company_id, id),
     FOREIGN KEY (company_id, campaign_id) REFERENCES campaigns (company_id, id)
    ); 
    ```

   ![Image0375](Media/image0375.png)

   Finally, we'll track statistics about **clicks** and **impressions** for each ad:

   ```sql
   CREATE TABLE clicks (
     id bigserial,
     company_id bigint,
     ad_id bigint,
     clicked_at timestamp without time zone NOT NULL,
     site_url text NOT NULL,
     cost_per_click_usd numeric(20,10),
     user_ip inet NOT NULL,
     user_data jsonb NOT NULL,
     PRIMARY KEY (company_id, id),
     FOREIGN KEY (company_id, ad_id) REFERENCES ads (company_id, id)
    );

    CREATE TABLE impressions (
      id bigserial,
      company_id bigint,
      ad_id bigint,
      seen_at timestamp without time zone NOT NULL,
      site_url text NOT NULL,
      cost_per_impression_usd numeric(20,10),
      user_ip inet NOT NULL,
      user_data jsonb NOT NULL,
      PRIMARY KEY (company_id, id),
      FOREIGN KEY (company_id, ad_id) REFERENCES ads (company_id, id));
   ```

   ![Image0376](Media/image0376.png)

   You can see the newly created tables in the list of tables now in psql by running the command 

   ```sql
   \dt
   ```

   ![Image0377](Media/image0377.png)
 
   Multi-tenant applications can enforce uniqueness only per tenant, which is why all primary and foreign keys include the company ID.

Congratulations!. You have successfully completed this exercise.

---

## Exercise 3: Create distributed tables

There are three types of tables in a Hyperscale server group, each used for different purposes.

- **Distributed tables:** The first type, and most common, is *distributed* tables. They appear to be normal tables to SQL statements, but are horizontally *partitioned* across worker nodes. What this means is that the rows of the table are stored on different nodes, in fragment tables called *shards*.
- **Reference tables:** A reference table is a type of distributed table whose entire contents are concentrated into a single shard. The shard is replicated on every worker, so queries on any worker can access the reference information locally, without the network overhead of requesting rows from another node. Reference tables have no distribution column because there is no need to distinguish separate shards per row. Reference tables are typically small and are used to store data that is relevant to queries running on any worker node. For example, enumerated values like order statuses, or product categories.
- **Local tables:** When you use Hyperscale, the coordinator node you connect to is a regular PostgreSQL database. You can create ordinary tables on the coordinator and choose not to shard them. A good candidate for local tables would be small administrative tables that don't participate in join queries. For example, a user's table for application login and authentication.

In this exercise, you will configure tables to be distributed, reference or local depending on the needs.

A hyperscale deployment stores table rows on different nodes based on the value of a user-designated column. This distribution column marks which tenant owns which rows.

Let's set the distribution column to be **company_id** the tenant identifier.

Finishing the previous exercises are the pre-requisites for completing this exercise.

**Tasks**

1. Shard tables across nodes.
    
   Connect to the database using psql (following the same steps mentioned in the previous exercise).
    
   Let's set the distribution column to be *company_id* the tenant identifier. In psql, run:

   ```sql
   SELECT create_distributed_table('companies', 'id');
   ```

   ```sql
   SELECT create_distributed_table('campaigns', 'company_id');
   ```

   ```sql
   SELECT create_distributed_table('ads', 'company_id');
   ```

   ```sql
   SELECT create_distributed_table('clicks', 'company_id');
   ```

   ```sql
   SELECT create_distributed_table('impressions', 'company_id');
   ```

   ![Image0378](Media/image0378.png)

   By executing the previous commands, the five tables have been configured as distributed tables.

1. Load and query sample data.
    
   Create a folder named **cituslab** on C: drive.
    
   Click on the links below one by one to download the respective CSV files in the **C:\\cituslab** folder
    
   - https://examples.citusdata.com/mt_ref_arch/companies.csv
   - https://examples.citusdata.com/mt_ref_arch/campaigns.csv
   - https://examples.citusdata.com/mt_ref_arch/ads.csv
   - https://examples.citusdata.com/mt_ref_arch/clicks.csv
   - https://examples.citusdata.com/mt_ref_arch/impressions.csv
    
   ![](Media/image0379.png)
    
   Connect back to psql to bulk load the data by executing the following commands:

   ```nocolor
   \copy companies from 'C:\cituslab\companies.csv' with csv
   ```

   ```nocolor
   \copy campaigns from 'C:\cituslab\campaigns.csv' with csv
   ```

   ```nocolor
   \copy ads from 'C:\cituslab\ads.csv' with csv
   ```

   ```nocolor
   \copy clicks from 'C:\cituslab\clicks.csv' with csv
   ```

   ```nocolor
   \copy impressions from 'C:\cituslab\impressions.csv' with csv
   ```

   ![Image0380](Media/image0380.png)

   This data has been spread across worker nodes.

   When the application requests data for a single tenant, the database can execute the query on a single worker node. Single-tenant queries filter by a single tenant ID. For example, the following query filters company_id = 5 for ads and impressions. 
   
   Try running it in psql to see the results.

   ```sql
   SELECT a.campaign_id, 
          RANK() OVER ( 
            PARTITION BY a.campaign_id 
            ORDER BY a.campaign_id, count(*) desc), 
            count(*) as n_impressions, a.id 
   FROM ads as a 
        JOIN impressions as I  
        ON i.company_id = a.company_id AND i.ad_id = a.id 
   WHERE a.company_id = 5 
   GROUP BY a.campaign_id, a.id 
   ORDER BY a.campaign_id, n_impressions desc;
   ```

   You will see the output like following:

   ![Image0381](Media/image0381.png)

Congratulations!. You have successfully completed this exercise.

---

## Exercise 4: Create reference tables

Until now all tables have been distributed by company_id, but some data doesn't naturally "belong" to any tenant in particular and can be shared. For instance, all companies in the example ad platform might want to get geographical information for their audience based on IP addresses.

Finishing the previous exercises are the pre-requisites for completing this exercise.

**Tasks**

1. Share data between tenants.
    
   Connect to the database using psql (following the same steps mentioned in the previous exercise).
    
   Create a table to hold shared geographic information. Run the following commands in psql:

   ```sql
   CREATE TABLE geo_ips (
     addrs cidr NOT NULL PRIMARY KEY,
     latlon point NOT NULL
       CHECK (-90  <= latlon[0] AND latlon[0] <= 90 AND
              -180 <= latlon[1] AND latlon[1] <= 180)
   );
   CREATE INDEX ON geo_ips USING gist (addrs inet_ops);
   ```

   ![Image0382](Media/image0382.png)

   Next make geo_ips a *reference table* to store a copy of the table on every worker node. To do it, execute:

   ```sql
   SELECT create_reference_table('geo_ips');
   ```
    
   ![Image0383](Media/image0383.png)

1. Load and query sample data.
    
   Click on https://examples.citusdata.com/mt_ref_arch/geo_ips.csv to download the respective CSV file in the **C:\cituslab** folder.
    
   Then load the data using the copy command in psql.

   ```sql
   \copy geo_ips from 'C:\cituslab\geo_ips.csv' with csv
   ```
  
   ![Image0384](Media/image0384.png)
    
   Now, there is local copy of *geo_ips* in all nodes. Joining the *clicks* table with *geo_ips* is efficient on all nodes.
    
   To find the locations of everyone who clicked on ad 290, execute:

   ```sql
   SELECT c.id, clicked_at, latlon 
   FROM geo_ips, clicks c 
   WHERE addrs >> c.user_ip 
         AND c.company_id = 5 
         AND c.ad_id = 290;
   ```

   ![Image0385](Media/image0385.png)

Congratulations!. You have successfully completed this exercise.

---

## Exercise 5: Customize the schema per-tenant

Each tenant may need to store special information not needed by others. However, all tenants share a common infrastructure with an identical database schema. Where can the extra data go?

One trick is to use an open-ended column type like PostgreSQL's JSONB. Our schema has a JSONB field in clicks called *user_data*. A company (say company 5), can use the column to track whether the user is on a mobile device.

Finishing the previous exercises are the pre-requisites for completing this exercise.

**Task**

1. Customize the schema per tenant.
    
   Connect to the database using psql (following the same steps mentioned in the previous exercise).
    
   Here's a query to find who clicks more: mobile, or traditional visitors.

   ```sql
   SELECT
     user_data->>'is_mobile' AS is_mobile,
     count(*) AS count 
   FROM clicks 
   WHERE company_id = 5 
   GROUP BY user_data->>'is_mobile' 
   ORDER BY count DESC;
   ```

   ![Image0386](Media/image0386.png)

   The query can be optimized for a single company by creating the following [partial index](https://www.postgresql.org/docs/current/static/indexes-partial.html):

   ```sql
   CREATE INDEX click_user_data_is_mobile 
   ON clicks ((user_data->>'is_mobile')) 
   WHERE company_id = 5;
   ```

   ![Image0387](Media/image0387.png)![](Media/image0387.png)

   More generally, we can create a [GIN index](https://www.postgresql.org/docs/current/static/gin-intro.html) on every key and value within the column.

   ```sql
   CREATE INDEX click_user_data 
   ON clicks USING gin (user_data);
   ```

Congratulations!. You have successfully completed this exercise.

---

## Exercise 6: Viewing Metadata Information and Distributed Query Execution

Each distributed table is divided into multiple logical shards based on the distribution column. The coordinator maintains metadata tables to track statistics and information about the health and location of these shards. 

In this exercise, you will explore these metadata tables and their schema. You will view and query these tables and see how you can see the details of the Distributed query execution.

For further information refer to:
- [Citus Tables and Views](https://docs.citusdata.com/en/v11.0/develop/api_metadata.html)
- [Query Performance Tuning](https://docs.citusdata.com/en/v11.0/performance/performance_tuning.html)

Finishing the previous exercises are the pre-requisites for completing this exercise.

**Tasks**

1. Viewing Metadata Information.

   Connect to the database using psql (following the same steps mentioned in the previous exercise).
    
   **PARTITION TABLE**
    
   The **pg\_dist\_partition** table stores metadata about which tables in the database are distributed. For each distributed table, it also stores information about the distribution method and detailed information about the distribution column.

   | Name          | Type      | Description |
   |:--------------|:----------|:------------|
   | Logicalrelid  | regclass  | Distributed table to which this row corresponds. This value references the relfilenode column in the pg_class system catalog table. |
   | Partmethod    | char      | The method used for partitioning / distribution. The values of this column corresponding to different distribution methods are hash (h) and reference table (n) |
   | partkey       | text      | Detailed information about the distribution column including column number, type and other relevant information.| 
   | colocationid  | integer   | Co-location group to which this table belongs. Tables in the same group allow co-located joins and distributed rollups among other optimizations. This value references the colocationid column in the pg_dist_colocation table. |
   | repmodel      | char      | The method used for data replication. The values of this column corresponding to different replication methods are postgresql streaming replication (s) and two-phase commit for reference tables (t) |

   Query the **pg_dist_partition** table 

   ```sql
   select * from pg_dist_partition;
   ```

   ![Image0390](Media/image0390.png)

   You can see the rows for all the tables created in previous exercise. You can also see that the method used for partitioning in the partmethod column: 'h' for all the distributed tables and 'n' for the reference table geo_ips.
    
   For further information refer to [Partition table](https://docs.citusdata.com/en/v11.0/develop/api_metadata.html#partition-table)

   **SHARD TABLE**
    
   The **pg_dist_shard** table stores metadata about individual shards of a table. This includes information about which distributed table the shard belongs to and statistics about the distribution column for that shard. For append distributed tables, these statistics correspond to min / max values of the distribution column. In case of hash distributed tables, they are hash token ranges assigned to that shard.
    
   These statistics are used for pruning away unrelated shards during SELECT queries.

   | Name          | Type      | Description |
   |:--------------|:----------|:------------|
   | logicalrelid  | regclass  | Distributed table to which this shard belongs. This value references the relfilenode column in the pg_class system catalog table. |
   | shardid       | bigint    | Globally unique identifier assigned to this shard |
   | shardstorage  | char      | Type of storage used for this shard. Different storage types are discussed later. | 
   | shardminvalue | text      | For hash distributed tables, minimum hash token value assigned to that shard (inclusive). |
   | shardmaxvalue | text      | For hash distributed tables, maximum hash token value assigned to that shard (inclusive).|

   The shardstorage column in pg_dist_shard indicates the type of storage used for the shard. A brief overview of different shard storage types and their representation is below.

   |Storage Type | Shardstorage value | Description|
   |-------------|--------------------|------------|
   |TABLE        |‘t’                 |Indicates that shard stores data belonging to a regular distributed table.|
   |COLUMNAR     |‘c’                 |Indicates that shard stores columnar data. (Used by distributed cstore_fdw tables)|
   |FOREIGN      |‘f’                 |Indicates that shard stores foreign data. (Used by distributed file_fdw tables)|

   Query the **pg_dist_shard** table 

   ```sql
   select * from pg_dist_shard;
   ```

   You will see rows like below (Shown only sample rows and not all rows). You can see individual shards for each distributed table.
       
   ![Image0391](Media/image0391.png)

   **SHARD INFORMATION VIEW**

   In addition to the low-level shard metadata table described above, Citus provides a citus_shards view to easily check:
   - Where each shard is (node, and port),
   - What kind of table it belongs to, and
   - Its size

   This view helps you inspect shards to find, among other things, any size imbalances across nodes.


   Query the **citus_shards** table 

   ```sql
   SELECT * FROM citus_shards;
   ```

   ![Image0391](Media/image0391.png)

   **SHARD PLACEMENT TABLE**
    
   The **pg_dist_placement** table tracks the location of shard replicas on worker nodes. Each replica of a shard assigned to a specific node is called a shard placement. This table stores information about the health and location of each shard placement.

   | Name          | Type      | Description |
   |:--------------|:----------|:------------|
   | shardid       | bigint    | Shard identifier associated with this placement. This value references the shardid column in the pg_dist_shard catalog table. |
   | shardstate    | int       | Describes the state of this placement. |
   | shardlength   | bigint    | For hash distributed tables, zero. |
   | placementid   | bigint    | Unique auto-generated identifier for each individual placement. |
   | groupid       | int       | Identifier used to denote a group of one primary server and zero or more secondary servers. |

   Query the **pg_dist_placement** table (Shown only sample rows)

   ```sql
   select * from pg_dist_placement;
   ```

   ![Image0392](Media/image0392.png)  

   You will see 
   - the values in the **shardid** column references the shardid column in the **pg\_dist\_shard** table we had seen earlier in this section.
   - the values in the **shardlength** column as always **'0'** as all our tables are hash distributed tables.
   - the **shardstate** column values mostly **'1'** which indicates the Shard Placement state as **"FINALIZED"**
    
   There are 3 different Shard Placement states.
   - **(1) FINALIZED:** This corresponds to shardstate column value as '1'. This is the state new shards are created in. Shard placements in this state are considered up-to-date and are used in query planning and execution.
   - **(3) INACTIVE:** This corresponds to shardstate column value as '3'. Shard placements in this state are considered inactive due to being out-of-sync with other replicas of the same shard. This can occur when an append, modification (INSERT, UPDATE or DELETE ) or a DDL operation fails for this placement. The query planner will ignore placements in this state during planning and execution. Users can synchronize the data in these shards with a finalized replica as a background activity.
   - **(4) TO_DELETE:** This corresponds to shardstate column value as '4'. If Citus attempts to drop a shard placement in response to a master\_apply\_delete\_command call and fails, the placement is moved to this state. Users can then delete these shards as a subsequent background activity.
    
   **WORKER NODE TABLE**
    
   The **pg_dist_node** table contains information about the worker nodes in the cluster.

   | Name          | Type      | Description |
   |:--------------|:----------|:------------|
   | nodeid        | int       | Auto-generated identifier for an individual node. |
   | groupid       | int       | Identifier used to denote a group of one primary server and zero or more secondary servers. By default it is the same as the nodeid. |
   | nodename      | text      | Host Name or IP Address of the PostgreSQL worker node. |
   | nodeport      | int       | Port number on which the PostgreSQL worker node is listening. |
   | noderack      | text      | (Optional) Rack placement information for the worker node. |
   | hasmetadata   | boolean   | Reserved for internal use. |
   | isactive      | boolean   | Whether the node is active accepting shard placements. |
   | noderole      | text      | Whether the node is a primary or secondary |
   | nodecluster   | text      | The name of the cluster containing this node |
   | metadatasynced| boolean   | Reserved for internal use. |
   |shouldhaveshards| boolean  | If false, shards will be moved off node (drained) when rebalancing, nor will shards from new distributed tables be placed on the node, unless they are colocated with shards already there |

   Query the **pg_dist_node**

   ```sql
   select * from pg_dist_node;
   ```

   ![Image0398](Media/image0398.png)

   
   **SHARD PLACEMENTS**
    
   The mapping of shard to worker is known as the shard placement.
    
   Query the **pg_dist_shard** table and pick up any **shardid** for table *companies*. For example, take **shardid – 102008** (first row in the below screen shot)
    
   ```sql
   select * from pg_dist_shard;
   ```

   ![Image0399](Media/image0399.png)
    
   Suppose that shard **102008** is associated with the row in question. The row is read or written in a table called **companies\_102008** in one of the workers. Which worker is determined entirely by the metadata tables. The mapping of shard to worker is known as the shard placement.
   
   The coordinator node rewrites queries into fragments that refer to the specific tables like **companies_102008** and runs those fragments on the appropriate workers. Here's an example of a query run behind the scenes to find the node holding shard ID **102008**.

   ```sql
   SELECT
       shardid,
       node.nodename,
       node.nodeport 
   FROM pg_dist_placement placement 
   JOIN pg_dist_node node 
     ON placement.groupid = node.groupid
    AND node.noderole = 'primary'::noderole 
   WHERE shardid = 102008;
   ```

   ![Image0400](Media/image0400.png)

1. Getting information about the Distributed Query Execution
    
   **EXPLAIN** command provides information about distributed query execution. The **EXPLAIN** output shows how each worker processes the query and also a little about how the coordinator node combines their results.
    
   Connect to the database using psql (following the same steps mentioned in the previous exercise).
    
   Run an example, query like below and use EXPLAIN command to view the query execution plan:

   ```sql
   EXPLAIN select company_id, sum (cost_per_click_usd) as Totalcost_perclick 
   from clicks 
   group by company_id 
   order by Totalcost_perclick desc;
   ```

   ![Image0401](Media/image0401.png)

   The plan explains that there are 32 shards and planner choose the Citus Adaptive executor to execute this query

   ![Image0402](Media/image0402.png)

   Then we can see that we have details about the how query behaves in one of the worker and shows details on the host, port and DBname.

   ![Image0403](Media/image0403.png)

   Distributed EXPLAIN shows the results of running a normal PostgreSQL EXPLAIN on that worker for the fragment query

   ![Image0404](Media/image0404.png)

 Congratulations!. You have successfully completed this exercise.

---

## Exercise 7: add new workers

Azure Database for PostgreSQL - Hyperscale (Citus) provides self-service scaling to deal with increased load. Adding nodes causes no downtime.

To take advantage of newly added nodes, rebalance distributed table shards. Rebalancing moves shards from existing nodes to the new ones. Hyperscale (Citus) offers zero-downtime rebalancing, meaning queries continue without interruption during shard rebalancing.

Finishing the previous exercises are the pre-requisites for completing this exercise.

**Task**

1. Connect to Microsoft Azure Portal
    
   Open Microsoft Edge and navigate to the [Azure Portal](http://ms.portal.azure.com) to connect to Microsoft Azure Portal. Login with your subscriptions credential.

1. Go to your Citus server group.

   Go to your Azure Database for PostgreSQL - Hyperscale (Citus) server group in any way you prefer to look for a resource on Azure

1. Add two worker nodes

   Under **Settings** go to **Compute + storage**

   Increase the number of worker nodes to 4. Then Click **Save**

   >Once increased and saved, the number of worker nodes cannot be decreased using the slider.

   ![Image0405](Media/image0405.png)

   Wait for the deployment to finish

   Go to the server group overview page and confirm the nodes were added

   ![Image0406](Media/image0406.png)

1. Run the Shard rebalancer

   Check how many shards there are in each node

   ```sql
   SELECT table_name,nodename, count(*) as shard_count
   FROM citus_shards
   GROUP BY table_name,nodename
   ORDER BY table_name,nodename;
   ```
    
   ![Image0407](Media/image0407.png)

   Notice there is no shard on the new worker nodes

   To start the shard rebalancer, connect to the coordinator node of the server group and then run the rebalance_table_shards SQL function on distributed tables.

   The function rebalances all tables in the colocation group of the table named in its argument. You don't have to call the function for every distributed table. Instead, call it on a representative table from each colocation group.

   ```sql
   SELECT rebalance_table_shards('companies');
   ```
  
   ![Image0408](Media/image0408.png)

   Check again how many shards there are in each node. The shards have been balanced

   ```sql
   SELECT table_name,nodename, count(*) as shard_count
   FROM citus_shards
   GROUP BY table_name,nodename
   ORDER BY table_name,nodename;
   ```

   ![Image0409](Media/image0409.png)

1. Cleanup the environment, delete the resource group

   In this lab, you created an Azure resource group to host the Azure Database for PostgreSQL server group. If you don't expect to need these resources in the future, delete the resource group.

Congratulations!. You have successfully completed this exercise and the Lab.
