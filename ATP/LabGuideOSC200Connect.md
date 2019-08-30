![customer.logo3](./images/Common/customer.logo3.png)

# Part 2. Securely Connecting to Autonomous Transaction Processing #

**Objectives:**

•                 Learn about the different Consumer Groups in Autonomous Transaction Processing (ATP)

•                 Learn how to download the credential wallet for your ATP instance

•                 Learn how to securely connect desktop tools to ATP

 

Applications and tools connect to ATP databases by using Oracle Net Services (also known as SQL*Net). SQL*Net supports a variety of connection types to ATP databases, including Oracle Call Interface (OCI), ODBC drivers, JDBC OC, and JDBC Thin Driver. Unlike other cloud services you do not get a UNIX command line interface on the system hosting your ATP instance, this reduces the complexity and need of UNIX skills required to administer it.  

 

The sample SQL scripts for this lab are available in your VM under the directory **/home/oracle/labScripts/lab2**.

 

## Managing Priorities on Autonomous Transaction Processing ##

The priority of user requests in ATP is determined by the database service the user is connected to. Users are required to select a service when connecting to the database. The service names are in the format:

•                 *database_name*_tpurgent

•                 *database_name*_tp 

•                 *database_name*_low 

•                 *database_name*_medium 

•                 *database_name*_high 

 

These services map to the LOW, MEDIUM, HIGH, TP and TPURGENT consumer groups.  For example, a user connecting to database_name_low service uses the consumer group LOW.  

 

The basic characteristics of these consumer groups are:

 

- **tpurgent**: The highest priority application connection service for time critical transaction processing operations. This connection      service supports manual parallelism.

 

- **tp**: A typical application connection service for transaction processing operations. Queries run serially.

 

- **high**: A high priority application connection service for reporting and batch operations with low concurrency requirements. All      operations run in parallel  (if you have multiple OCPU assigned to your instance) and are subject to queuing.

 

- **medium**: A typical application connection service for reporting and batch operations. All operations run in parallel and are subject to      queuing.

 

- **low**: A lowest priority application connection service for high concurrency reporting or batch processing operations. Queries run serially.

 

By default, the CPU/IO shares assigned to the consumer groups TPURGENT, TP, HIGH, MEDIUM, and LOW are 12, 8, 4, 2, and 1, respectively. The shares determine how much CPU/IO resources a consumer group can use with respect to the other consumer groups. With the default settings the consumer group TPURGENT will be able to use 12 times more CPU/IO resources compared to LOW, when needed. The consumer group TP will be able to use 4 times more CPU/IO resources compared to MEDIUM, when needed.

To change the default values for the shares you can use the PL/SQL procedure `cs_resource_manager.update_plan_directive` or via the Service Console for your instance.  

![Lab200ResourceManagement](./images/200/Lab200ResourceManagement.png)

 

As a database administrator and an application developer you need to select the database service based on your performance, concurrency and parallelism requirements.

## Downloading the credentials wallet

As ATP only accepts secure connections to the database, you need to download the wallet file containing your credentials first. 

 

The wallet is downloaded from the ATP service console, or from the "**DB Connection**" button on the instance details page. To access the ATP Service console, find your database on the table listing ATP instances and click on the three vertical dots on the right-hand side.

 In the pop-up menu select **Service Console.**

 ![Lab200ServiceConsoleSelect](./images/200/Lab200ServiceConsoleSelect.png)

​                                                  

This will open a new browser tab for the Service Console. 



If you are prompted to do so, sign in to the service console with the following information.

 

**Username:** admin

**Password:** The administrator password you specified during provisioning

 

   ![Lab200SignInAdmin](./images/200/Lab200SignInAdmin.png)

 

You will now see the main **dashboard** page for your instance.  As we have not generated any load into the instance, it may have ‘No data to display’ in the information panes. Other workshops can explore the **Overview** and **Activity** tabs in more detail.

![Lab200ServiceConsoleOverview](./images/200/Lab200ServiceConsoleOverview.png) 

   

 

Click the “**Administration**” link in the left-hand side menu and click “**Download Client Credentials**” to download the wallet. 

 ![Lab200AdminWallet](./images/200/Lab200AdminWallet.png)

   

 

Specify a password for the wallet. Some applications require this password when connecting to the database, for example some JDBC thin applications will require this password to use as the keystore password. Note that this password is separate from the admin password and can be set to a different value. For this lab, you could use the value ATPwelcome-1234 or another memorable password of your choice.

 

Click Download to download the wallet file to your lab virtual machine.

 ![Lab200AdminWalletDownload](./images/200/Lab200AdminWalletDownload.png)

   

Select to Save the file, and then click ok. This will save the file in the default downloads location $HOME/Downloads

 ![Lab200AdminWalletSave](./images/200/Lab200AdminWalletSave.png)

 

   

 

## Connecting to the database using SQL Developer ##

Minimise your Firefox window, and on your Lab VM desktop, start SQL Developer by double clicking on the icon.

 ![Lab200SQLDevIcon](./images/200/Lab200SQLDevIcon.png)

​    

 

Click the Create Connection icon in the Connections toolbox on the top left of the SQL Developer homepage.

 ![Lab200SQLDev](./images/200/Lab200SQLDev.png)

   

 

This will open the **New/Select Database Connection Screen**.  See below the screenshot for information on how to complete this form.

![Lab200SQLDevAddConnection](./images/200/Lab200SQLDevAddConnection.png)   

 

**Connection Name:** admin_high 

**Username:** admin

**Password:** The admin password you specified during the provisioning process.

**Connection Type:** Cloud Wallet

**Configuration File:** Enter the full path for the wallet file you downloaded earlier in the lab or click the Browse button to point to the locate the file (by default it will be under your Downloads directory).

**Service:** The Wallet will contain the service names for all the ATP databases in the tenancy so this list could be long. Please make sure that you are selecting your database.  As discussed previously there are 5 pre-configured database services for each database. Pick *<your databasename>_high* for this lab. For example, if you created a database named **melatptrain01** select **melatptrain01_high** as the service.

 



Test your connection by clicking the Test button, if it succeeds save your connection information by clicking Save, then connect to your database by clicking the Connect button.

 

You can now run a test query using the sample data in the SH schema.

 

In the SQL Worksheet enter the following SQL:

 

`select country_region, count(country_name) from sh.countries group by country_region;`



and press the ‘Run Script’ button or press F5. 

![Lab200SQLDevCountrySQL](./images/200/Lab200SQLDevCountrySQL.png)   

 

*Note – You do not have to use GUI tools to access an ATP instance. Other Oracle Client utilities such as SQL Plus can connect to the ATP instance using a wallet.*

Some extra examples of how to use Access Control lists to manage the access to your database can be found on [this](LabGuideOSC200Connectbis.md) separate page.



You are now finished with this section, please [return to the Lab Introduction Page](readme.md) and go to the next step.

 

 

 

 

 

 



 

 
