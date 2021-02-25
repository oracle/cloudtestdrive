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

  ![](images/image010.png)



- Choose Single Sign On:

![](images/image020.png)



- Login with your cloud account *User Name* and *Password* 

![](images/image030.png)





## 3. Using a corporate Tenancy

**If you are running this lab via a Free Tier tenancy**, you will be the administrator of that tenancy, and have all the required rights to run this lab.  A Free Tier also has the required service limits to instantiate all the objects you will need.

==> In this case **you can skip the remainder steps on this page**.



If you are running this lab on a **corporate tenancy**, you will need to ensure you are entitled with the appropriate rights and privileges, and have sufficient service limits to instantiate the objects for this lab.

==> Please **validate the below elements**, probably together with the administrator of your tenancy, before attempting to run this lab.



### 2.1 Required root level policies for WebLogic for OCI

You must be an Oracle Cloud Infrastructure <u>administrator</u>, or <u>be granted some root-level permissions</u>, in order to create domains with Oracle WebLogic Server for Oracle Cloud Infrastructure.

When you create a domain, Oracle WebLogic Server for Oracle Cloud Infrastructure creates a dynamic group and root-level policies that allow the compute instances in the domain to:

- Access keys and secrets in Oracle Cloud Infrastructure Vault
- Access the database wallet if you're using Oracle Autonomous Transaction Processing (JRF-enabled domains)

In case <u>you are not an OCI administrator</u> and you cannot create dynamic-groups or you cannot create policies at root compartment level, please contact your OCI administrator and request that one  of the groups your cloud user is part of to have the following grants in place:

```
Allow group MyGroup to manage dynamic-groups in tenancy
Allow group MyGroup to manage policies in tenancy
Allow group MyGroup to use tag-namespaces in tenancy
Allow group MyGroup to inspect tenancies in tenancy
```

Also, to be able to use the Cloud Shell you need also:

```
Allow group MyGroup to use cloud-shell in tenancy
```



### 2.2 Required compartment level policies for WebLogic for OCI

If <u>you are not an Oracle Cloud Infrastructure administrator</u>, you must be given management access to resources in the compartment in which you want to create a domain.

Your Oracle Cloud Infrastructure user must have management access for Marketplace applications, Resource Manager stacks and jobs, compute instances, and block storage volumes. If you want Oracle WebLogic Server for Oracle Cloud Infrastructure to create resources for a domain like networks and load balancers, you must also have management access for these resources.

A policy that entitles your OCI user to have the minimum management access for your compartment, needs to have the following grants in place:

```
Allow group MyGroup to manage instance-family in compartment MyCompartment
Allow group MyGroup to manage virtual-network-family in compartment MyCompartment
Allow group MyGroup to manage volume-family in compartment MyCompartment
Allow group MyGroup to manage load-balancers in compartment MyCompartment
Allow group MyGroup to manage orm-family in compartment MyCompartment
Allow group MyGroup to manage app-catalog-listing in compartment MyCompartment
Allow group MyGroup to manage vaults in compartment MyCompartment
Allow group MyGroup to manage keys in compartment MyCompartment
Allow group MyGroup to manage secret-family in compartment MyCompartment
Allow group MyGroup to read metrics in compartment MyCompartment
Allow group MyGroup to manage autonomous-transaction-processing-family in compartment MyDBCompartment
Allow group MyGroup to manage database-family in compartment MyDBCompartment
```



### 2.3 Service limits

Going through the hands on lab you will create the following main components in your tenancy:

- two Compute instances
- one Virtual Cloud Network (VCN)
- one Load Balancer
- one Vault
- reserve two Public IPs

Check your tenancy Service limits, current usage (*Governance and Administration* > *Governance* > *Limits, Quotas and Usage*) and make sure you have enough room for: 

- Compute Service: VM.Standard2.1 (you may consider choosing a specific AD)
- Virtual Cloud Network Service: Virtual Cloud Networks
- Virtual Cloud Network Service: Reserved Public IP
- LbaaS Service: 100Mbps Load Balancer

If you don't have visibility and/or you don't have admin rights for your tenancy, reach out to your administrator.

