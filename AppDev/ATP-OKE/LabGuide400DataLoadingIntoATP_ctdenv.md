![](../../common/images/customer.logo2.png)

# Microservices on ATP - Part 2


## Data Loading into ATP
#### **Introduction**

In this lab, you will be creating a few tables and inserting data into the ATP database using the CI/CD features of Visual Builder Studio.  We'll use the Build engine of Visual Builder Studio to set up a flow that will create the necessary objects in the database, and insert data into the tables.  In case these elements are changed in the repository, the script will trigger again and re-create the database elements.

In real life, you would want to set up a more sophisticated logic to manage your database objects, see [these blogs on the topic by Shay Schmeltzer](https://blogs.oracle.com/shay/devcs).



#### **Objectives**

- Personalize the SQL script with your initials in the db table
- Create and run a Build to create your database objects
- Validate creation via SQL Developer Web



## Step 1: Personalize the table creation script

As all participants will be using the same ATP database, we will first personalize the database table creation script so you can see your table in the database after running the build job.

- Go to the Visual Builder Studio web interface, 
- Navigate to the **aone** folder
- Open the file `create_schema_simple.sql`
  - Hit the Edit pencil 
  - Replace all occurences of  `ITEMS_CTD`  by  `ITEMS_<your_initials>`
- Safe the changes 

![](./images/400/Edit-sql.png)



## Step 2: Set up your ATP Database Wallet

We need to extract the ATP Database wallet file into the OCI Cloud shell. Open the OCI Cloud shell.

```bash
# Position yourself in the git repo, replace ATPDocker with your repo name if you used a different one
cd $HOME/dev/ATPDocker

# Download the file via the OCI CLI, replacing the database OCID with the OCID of your database and the password with the one of the admin user
oci db autonomous-database generate-wallet --file Wallet.zip --password 'Pa$$w0rd' --autonomous-database-id ocid1.autonomousdatabase.oc1.eu-frankfurt-1.abtheljtn3slgmzqr2benreqkrs55gwg3v3tz6lgwhgfgzaccrb

# Unzip the file
unzip Wallet.zip -d Wallet
```

- Note you need to replace the database OCID with the correct OCID of the database you are using.
- In the  above sequence of commands, we used the "OCI CLI", or the **Oracle Cloud Command Line Interface**  to interact with elements in the infrastructure, in this case the database.  For more information on how this works, you can look at the [documentation](https://docs.cloud.oracle.com/en-us/iaas/tools/oci-cli/2.9.9/oci_cli_docs/cmdref/db/autonomous-database/generate-wallet.html).

- Navigate into your database wallet folder, and edit the file **sqlnet.ora**, using your favorite editor (vi or nano)

  - In this file, replace the default line below:

    ```
    WALLET_LOCATION = (SOURCE = (METHOD = file) (METHOD_DATA = (DIRECTORY="?/network/admin")))
    ```

  - by this line:

    ```
    WALLET_LOCATION = (SOURCE = (METHOD = file) (METHOD_DATA = (DIRECTORY=$TNS_ADMIN)))
    ```

  - This will allow us to simply set the environment variable $TNS_ADMIN to the correct path.

- Reposition yourself in the root directory of your project

  ```
  cd ..
  ```

- On the command line, add the new files to the git repository, commit them and push them to Visual Builder Studio with the following commands:

```bash
# add the new files to the git repository
git add .

# Setup git to be able to commit changes
git config --global user.email "you@example.com"
git config --global user.name "Your Name"
git config --global push.default simple

# Commit the change with the appropriate comment
git commit -m "Add wallet"

# Push the change from your laptop back into the repository
git push
```



- Your wallet is now visible in Visual Builder Studio - you might have to refresh your browser window to see the changes

<img src="images/400/wallet_added.png" style="zoom:50%;" />



## Step 3: Create and load your data in the database

- In Visual Builder Studio, navigate to the "Builds" tab and select **+Create Job**.
  - Enter a name : **CreateDBObjects**
  - Select the Software Template **OKE2**
  - Hit **Create Job**

<img src="./images/400/new_job-1.png" style="zoom: 67%;" />



- Add a  GIT Source repository

![](./images/400/add_src-1.png)

- Select your repository from the list
- Do **not** select the Automatic build on Commit



![](./images/400/config_source-1.png)



- Select the tab **Steps** to add a **SQLcl** build step from the dropdown

 ![](./images/400/add_step-1.png)



- Fill in the parameters:
  - username of the ATP instance : **admin**
  - password of the ATP instance (see access document provided by instructor)
  - the wallet .zip file **CTD_OOW.zip** that is already pre-loaded in your repository
  - your connect string, for example **jleoow_high**, where *jleoow* is the name of the database
  - the sql file containing the create script: **aone/create_schema_simple.sql**



![](./images/400/step_details-1.png)

 -   Now save your Build Config and hit the **Build Now** button.  

![](./images/400/build-now-2.png)

In case this is the first build job in your environment, the startup of the Build engine might take up to 10 minutes to complete.  You will notice the build to be "Waiting for Executioner"

![](./images/400/waiting-1.png)



## Step 4: Verify the results

You can visualize the log file of your virtual machine, to check any errors you might encounter on this level: <img src="./images/400/logs.png" style="zoom:25%;" />



Now navigate back to the Build job you launched.

 -   After a successfull build you should see following screen :

![](./images/400/build_result-01.png)

- You can check the detailed content of the SQL execution in the log file of the build job.

![](./images/400/build_result-1.png)



Now validate the table was created successfully using the build in SQL Developer Web tool

- Navigate to your OCI console, and select the ATP database you are using

<img src="./images/400/db_select.png" style="zoom:33%;" />

- On the Database Details page, navigate to the **Service Console**, then select **SQL Developer Web**

<img src="images/400/DB_console.png" style="zoom: 25%;" />

- You can now visualize the tables in the database, and execute a query against the table you just created:

  `select * from items_yourInitials`

  To execute the query, hit the green arrow "Run Statement" icon

  <img src="./images/400/sql_select.png" style="zoom: 25%;" />



---

**Congratulations**, You are now ready to move to the next step of the lab!
