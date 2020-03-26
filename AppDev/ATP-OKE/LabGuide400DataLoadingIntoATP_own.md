![](../../common/images/customer.logo2.png)

# Microservices on ATP


## Part 2: Data Loading into ATP
#### **Introduction**

In this lab, you will be creating a few tables and inserting data into the ATP database using the CI/CD features of Developer Cloud.  We'll use the Build engine of DevCS to set up a flow that will create the necessary objects in the database, and insert data into the tables.  In case these elements are changed in the repository, the script will trigger again and re-create the database elements.

In real life, you would want to set up a more sophisticated logic to manage your database objects, see [these blogs on the topic by Shay Schmeltzer](https://blogs.oracle.com/shay/devcs).



#### **Objectives**

- Personalize the SQL script with your initials in the db table
- Create and run a Build to create your database objects
- Validate creation via SQL Developer Web



## Steps



### STEP 1: Set up your ATP Wallet in Developer Cloud

In the ATP Connection step of this lab, you downloaded the ATP Connection wallet zip file into the Downloads folder.  We will now unizp the file and copy both the wallet zip file and the folder into the git repository folder.

```bash
cd Downloads

# List downloaded files
ls -l

unzip Wallet_yourwalletfilename.zip -d Wallet_yourwalletfilename

# Move Wallet file and directory into your git repository - assuming you placed it in "dev"
mv Wallet_yourwalletfilename.zip ~/dev/ATPDocker
mv Wallet_yourwalletfilename ~/dev/ATPDocker
```



- On the command line, add the new files to the git repository, commit them and push them to the Developer Cloud with the following commands:

```bash
# Position yourself in the actual Git directory
cd ~/dev/ATPDocker

# add the new files to the git repository
git add .

# Commit the change with the appropriate comment
git commit -m "Add wallet"

# In case you get an error "Please tell me who you are" at this point, please execute below commands:
git config --global user.email "you@example.com"
git config --global user.name "Your Name"

# Push the change from your laptop back into the DevCS repository
git push
```



- Your wallet is now visible in Developer Cloud - you might have to refresh your browser window to see the changes

![](images/400/wallet_added.png)



### **STEP 2: Create and load your data in the database**

- In Developer Cloud, navigate to the "Builds" tab and select **+Create Job**.
  - Enter a name : **CreateDBObjects**
  - Select the Software Template **OKE2**
  - Hit **Create Job**

![](./images/400/new_job-1.png)



- Add a  GIT Source repository

![](./images/400/add_src-1.png)

- Select your repository from the list
- Do **not** select the Automatic build on Commit



![](./images/400/config_source-1.png)



- Select the tab **Steps** to add a **SQLcl** build step from the dropdown

 ![](./images/400/add_step-1.png)



- Fill in the parameters:
  - username of the ATP instance : **admin**
  - password of the ATP instance
  - your wallet .zip file
  - your connect string, for example **jleoow_high**, where *jleoow* is the name of the database
  - the sql file containing the create script: **aone/create_schema.sql**



![](./images/400/step_details-1.png)

 -   Now save your Build Config and hit the **Build Now** button.  

![](./images/400/build-now-2.png)

In case this is the first build job in your environment, the startup of the Build engine might take up to 10 minutes to complete.  You will notice the build to be "Waiting for Executioner"

![](./images/400/waiting-1.png)



You can visualize the log file of your virtual machine, to check any errors you might encounter on this level: ![](./images/400/logs.png)



Now navigate back to the Build job you launched.

 -   After a successfull build you should see following screen :

![](./images/400/build_result-01.png)

- You can check the detailed content of the SQL execution in the log file of the build job.

![](./images/400/build_result-1.png)



- You can now re-connect with **SQL Developer Web** to your database and verify the objects were created correctly:

`select * from items`

To execute the query, hit the green arrow "Run Statement" icon

![](images/400/sql_2.png)





---

**Congratulations**, You are now ready to move to the next lab.

Use the **Back Button** of your browser to go back to the overview page and select the next lab step to continue.

