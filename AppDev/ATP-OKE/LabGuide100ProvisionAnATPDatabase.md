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

![](./images/100/DemoComp.png)

-  Click on **Create Autonomous Transaction Processing Database** button to start the instance creation process

![](./images/100/Picture100-23.jpeg)

-  This will bring up Create ATP Database screen where you specify the configurations of the instance

![](./images/100/Picture100-24.jpeg)


#### Note: Oracle Cloud Infrastructure allows logical isolation of users within a tenant through Compartments. This allows multiple users and business units to share a tenant account while being isolated from each other.

If you have chosen the compartment you do not have privileges on, you will not be able to see or provision instance in it.

More information about Compartments and Policies is provided in the OCI Identity and Access Management documentation [here](https://docs.cloud.oracle.com/iaas/Content/Identity/Tasks/managingcompartments.htm?tocpath=Services%7CIAM%7C_____13).

-  Verify your own compartment is selected

![](./images/100/Picture100-26.jpeg)

-  Specify a name for the instance, for example containing your initials for easy reference

![](./images/100/Picture100-27.jpeg)

- For this lab we are not checking Dedicate Infrastructure

-  You can choose an instance shape, specified by the CPU count and storage size. Default CPU count is 1 and storage is 1 TB.

![](./images/100/Picture100-28.jpeg)

-  Specify the password for the instance

#### For this lab, we will be using the following as password

```
WElcome_123#
```

![](./images/100/Picture100-29.jpeg)

- License Type: You will see 2 options under licensing options. 

**My organization already owns Oracle database software licenses**: Oracle allows you to bring your unused on-prem licenses to the cloud and your instances are billed at a discounted rate. This is the default option so ensure you have the right license type for this subscription.

![](./images/100/Picture100-34.jpeg)



**Subscribe to new database software licenses and the database cloud service**: Your cloud service instance should include database license. This is an all-inclusive cost and you do not need to bring any additional licenses to cloud.

![](./images/100/Picture100-35.jpeg)

- Tagging is a metadata system that allows you to organize and track resources within your tenancy. Tags are composed of keys and values that can be attached to resources. 

More information about Tags and Tag Namespaces is provided in the OCI Identity and Access Management documentation [here](https://docs.cloud.oracle.com/iaas/Content/Identity/Concepts/taggingoverview.htm).


![](./images/100/Picture100-36.jpeg)

For this workshop we will not be creating any TAG NAMESPACE. 

- Make sure you have everything filled all required details

-  Click on **Create Autonomous Transaction Processing Database** to start provisioning the instance

![](./images/100/Picture100-31.jpeg)

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

![](images/200/Picture200-2.png)

- Click on **Download** to supply a password for the wallet and download your client credentials.

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

- On the Database Details page, navigate to the **Service Console**, then select **SQL Developer Web**

![](images/400/DB_Console.png)

- You can now visualize the tables in the database, and execute queries.  Of course this is an empty database for now, we will reuse this tool later to check you have deployed objects into the database via Developer Cloud.





Congratulations, you are now ready to move to the next lab.



------

[Go to Overview Page](README.md)

