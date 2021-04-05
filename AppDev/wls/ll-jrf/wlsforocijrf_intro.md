# WebLogic for OCI (JRF) - Introduction



## Objective

This lab will guide you through the steps to create a WebLogic for OCI Instance, more specifically using the *Virtual Machine* flavor, and using the JRF option (repository database required).

- If you are running this lab on a personal **free tier** account, you will need to do some initial setup in order to prepare your tenancy for this lab.  These steps are described in the first chapter of this lab, called **WebLogic for OCI as a VM - Prerequisites**.  You can obtain a **free tier** account via [this link](https://signup.oraclecloud.com/).
- The actual creation of the WLS instance is described in the second chapter of this lab, called **WebLogic for OCI as a VM**.  Once the WLS instance is up and running, you can access the management console and deploy several test applications.  In case you are running this lab on a shared instance, your instructor will provide you with the required information to be able to start this part immediately.



## 1. Overview of the WebLogic for OCI - VM flavor

In this lab we will spin up a simple configuration of WebLogic, composed of the following elements : 

<img src="images/image040.png" alt="image-20201027145036593" />

We will be using the "WebLogic for OCI" Marketplace to select an image with the following properties:

- Running as a Virtual Machine on the Infrastructure
- Using the EE edition of WebLogic
- Using the **UCM** or **Universal Credits Model** license model
- Running in a public network
- Using a Repository database

Much more sophisticated setups are possible, you can explore these on your own after the initial lab :

- Using a private network and a *bastion host* to access this network

Below an example of a setup with private networks and a Database:

 <img src="images/image050.png" alt="image-20201027150146747" style="zoom:50%;" />



## 2. Logging in to your tenancy



- Open the console of your cloud tenancy via https://www.oracle.com/cloud/sign-in.html and login to your tenancy

  - **Cloud Account Name** : this is the name of your tenancy, not your username!
  
  <img src="images/image010.png" style="zoom:33%;" />



- Choose Single Sign On:

<img src="images/image020.png" style="zoom:33%;" />



- Login with your cloud account *User Name* and *Password* 

![](images/image030.png)





## 3. Using a corporate Tenancy

**If you are running this lab via a Free Tier tenancy**, you will be the administrator of that tenancy, and have all the required rights to run this lab.  A Free Tier also has the required service limits to instantiate all the objects you will need.

==> In this case **you can skip the remainder steps on this page**.



If you are running this lab on a **corporate tenancy**, you will need to ensure you are entitled with the appropriate rights and privileges, and have sufficient service limits to instantiate the objects for this lab.

==> Please **validate the below elements**, probably together with the **administrator of your tenancy**, before attempting to run this lab.



### 3.1 Required policies for non-Admin users

You must be an Oracle Cloud Infrastructure <u>administrator</u> in order to perform the below set-up steps.  As we assume you are familiar with the basic activities like creating compartments and defining policies, these will not be explained in detail.  Please refer to the documentation [here](https://docs.oracle.com/en/cloud/paas/weblogic-cloud/user/you-begin-oracle-weblogic-cloud.html#GUID-C4EC8702-CB1E-4B6D-BC50-CC008F3B5247).

You will need to create a number of objects in order to enable users to create WebLogic instances:

**Create a compartment**

- In the below example we used the compartment name **CTDOKE**
- Take a note of the **OCID** of the compartment, as you will need it in the dynamic group definition

**Create a group**

- In the example we used the name **wlslabs**

**Create a dynamic group**

- In the example we use the name **wlslabsdyn**
- Example rule definition :
- ```
  instance.compartment.id='ocid1.compartment.oc1..yourcompartmentocid'
  ```
  where you replace the OCID by the one you noted after creating the compartment

**Using IDCS for user management ?**

- In case you want to use IDCS to manage your users, create a group in your IDCS and set up the mapping between the IDCS group and the OCI group

**Create a policy statement**

- Create a policy statement on the root level for the group and the dynamic group

  Below an example of the policy statement to create :

```
Allow group wlslabs to use app-catalog-listing in compartment CTDOKE
Allow group wlslabs to manage instance-family in compartment CTDOKE
Allow group wlslabs to manage virtual-network-family in compartment CTDOKE
Allow group wlslabs to manage volume-family in compartment CTDOKE
Allow group wlslabs to manage load-balancers in compartment CTDOKE
Allow group wlslabs to manage orm-family in compartment CTDOKE
Allow group wlslabs to manage vaults in compartment CTDOKE
Allow group wlslabs to manage keys in compartment CTDOKE
Allow group wlslabs to manage secret-family in compartment CTDOKE
Allow group wlslabs to read metrics in compartment CTDOKE
Allow group wlslabs to inspect limits in tenancy
Allow group wlslabs to manage all-resources IN COMPARTMENT CTDOKE
Allow group wlslabs to read all-resources IN tenancy
Allow group wlslabs to use cloud-shell in tenancy
Allow dynamic-group wlslabsdyn to use secret-family in compartment CTDOKE
Allow dynamic-group wlslabsdyn to use keys in compartment CTDOKE
Allow dynamic-group wlslabsdyn to use vaults in compartment CTDOKE
Allow dynamic-group wlslabsdyn to manage instance-family in compartment CTDOKE
Allow dynamic-group wlslabsdyn to manage virtual-network-family in compartment CTDOKE
Allow dynamic-group wlslabsdyn to manage volume-family in compartment CTDOKE
Allow dynamic-group wlslabsdyn to manage load-balancers in compartment CTDOKE
Allow dynamic-group wlslabsdyn to use autonomous-transaction-processing-family in compartment CTDOKE
Allow dynamic-group wlslabsdyn to inspect database-family in compartment CTDOKE
Allow dynamic-group wlslabsdyn use osms-managed-instances in compartment CTDOKE
Allow dynamic-group wlslabsdyn to read instance-family in compartment CTDOKE
```



### 3.2 Service limits

Going through the hands on lab you will create the following main components in your tenancy **for every participant**:

- two Compute instances
- one Virtual Cloud Network (VCN)
- one Load Balancer
- one Vault
- reserve two Public IPs

Check your tenancy Service limits, current usage (*Governance and Administration* > *Governance* > *Limits, Quotas and Usage*) and make sure you have enough room for: 

- Compute Service: VM.Standard2.1 (you may consider choosing a specific AD)
- Virtual Cloud Network Service: Virtual Cloud Networks
- Virtual Cloud Network Service: Reserved Public IP
- LbaaS Service: 
  - Flexible LB bandwidth total sum : 40Mbps 
  - Flexible Load Balancer Count : 2

