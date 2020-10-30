# WebLogic for OCI - Introduction



## Objective

This lab will guide you through the steps to create a WebLogic for OCI Instance, more specifically using the *Virtual Machine* flavor, and using the non-JRF option (so no database required).

- If you are running this lab on a personal **free tier** account, you will need to do some initial setup in order to prepare your tenancy for this lab.  These steps are described in the first chapter of this lab, called **WebLogic for OCI as a VM - Prerequisites**.  You can obtain a **free tier** account via [this link](https://signup.oraclecloud.com/).
- The actual creation of the WLS instance is descibed in the second chapter of this lab, called **WebLogic for OCI as a VM**.  Once the WLS instance is up and running, you can access the management console and deploy a test application.  In case you are running this lab on a shared instance, your instructor will provide you with the required information to be able to start this part immediately.



## 1. Overview of the WebLogic for OCI - VM flavor

In this lab we will spin up a simple configuration of WebLogic, composed of the following elements : 

<img src="images/image-20201027145036593.png" alt="image-20201027145036593" style="zoom:50%;" />

We will be using the "WebLogic for OCI" Marketplace to select an image with the following properties:

- Running as a Virtual Machine on the Infrastructure
- Using the EE edition of WebLogic
- Using the **UCM** or **Universal Credits Model** license model
- Running in a public network

Much more sophisticated setups are possible, you can explore thes on your own adfter the initial lab :

- Using a Repository database
- Using a private network and a *bastion host* to access this network

Below an example of a setup with private networks and a Database:

 <img src="images/image-20201027150146747.png" alt="image-20201027150146747" style="zoom:50%;" />



## 2. Logging in to your tenancy



- Open the console of your cloud tenancy via https://www.oracle.com/cloud/sign-in.html and login to your tenancy

  ![](images/image010.png)



- Choose Single Sign On:

![](images/image020.png)



- Login with your cloud account *User Name* and *Password* 

![](images/image030.png)



