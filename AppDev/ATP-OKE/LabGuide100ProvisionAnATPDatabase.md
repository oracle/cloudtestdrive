[Go to Overview Page](README.md)

![](../../common/images/customer.logo2.png)

# Microservices on ATP

## Provisioning an Autonomous Transaction Processing Database


#### **Introduction**

This lab walks you through the steps to get started using the Oracle Autonomous Transaction Processing Database on Oracle Cloud Infrastructure (OCI). You will provision a new database, and connect to it using SQL Developer



## Steps



### **STEP 1: Create an ATP Instance**

-  Click on the hamburger menu icon on the top left of the screen

![](./images/100/Picture100-20.jpeg)

-  Click on **Autonomous Transaction Processing** from the menu

![](./images/100/Picture100-21.jpeg)



- Select the compartment you created previously 
- Click on **Create Autonomous Database** button to start the instance creation process

![](./images/100/DemoComp-1.png)



-  This will bring up Create Autonomous Database screen where you specify the configurations of the instance
   -  Verify your compartment is selected
   -  Specify a name for the instance, for example containing your initials for easy reference
   -  Select **Transaction Processing**
   -  Select **Serverless**

![](./images/100/Picture100-24-1.png)



- Select a OCPU Count of 1
- Select 1 TB of storage
- Specify the password for the instance, for example : 

```
WElcome_123#
```



![](./images/100/Picture100-28-2.png)



- Select 







- Choose a license type: You will see 2 options.   
  - **Bring Your Own License (BYOL)** :  Oracle allows you to bring your unused on-prem licenses to the cloud and your instances are billed at a discounted rate. This is the default option so ensure you have the right license type for this subscription.
  - If you do not have available on-premise Licenses, select the option **License Included**, in this case License fees will be included in the hourly rate of your database.

![](./images/100/Picture100-34.png)





- Click on **Create Autonomous Database** to start provisioning the instance






- Once you create ATP Database it would take 2-3 minutes for the instance to be provisioned.

![](./images/100/Picture100-32.jpeg)

-  Once it finishes provisioning, you can click on the instance name to see details of it

![](./images/100/Picture100-33.jpeg)

You now have created your first Autonomous Transaction Processing Cloud instance.



## Secure Connectivity and Data Access

Now you will configure a secure connection to your Database using Oracle SQL Developer.



### **STEP 2: Download the secure connection wallet for your provisioned instance**

- Log into your cloud account using your tenant name, username and password.
- Click on Menu and select Autonomous Transaction Processing
- On the ATP console, select your ATP instance provisioned in Step 1

![](images/200/Picture200-1.png)

- Click on  **DB Connection** to open up Database Connection pop-up window

![](images/200/picture200-2-2.png)

- Click on **Download Wallet** to supply a password for the wallet and download your client credentials, using the default "Instance Wallet" type.

#### Example password:

```
WElcome_123#
```

![](images/200/Picture200-3.png)

- Once you have downloaded your wallet, you will be navigated to ATP overview page
- The credentials zip file contains the encryption wallet, Java keystore and other relevant files to make a secure TLS 1.2 connection to your database from client applications. Store this file in a secure location.

### **STEP 3: Connect to the ATP instance with SQL Developer** Web

Lets connect to the database you just created using the build-in **SQL Developer Web** tool.

- Navigate to your OCI console, and select the ATP database you are using

  ![](images/400/db_select.png)

  

- On the Database Details page, navigate to the **Service Console**, 

  ![](images/400/service_console.png)

  

- Then select **Development** in the left-hand menu, and then the tile labeled **SQL Developer Web** 

  ![](images/400/DB_console.png)

- You can now visualize the tables in the database, and execute queries.  Of course this is an empty database for now, we will reuse this tool later to check you have deployed objects into the database via Developer Cloud.





Congratulations, you are now ready to move to the next lab.



------

[Go to Overview Page](README.md)

