# WebLogic for OCI - non JRF prerequisites

### Prerequisites for using own environment



## Objective

If you want go through the Hands on Lab (*WebLogic for OCI Instance - non JRF using Oracle Cloud Marketplace*) using your cloud environment, follow this guide to setup some prerequisites. If you are going to use the Cloud Test Drive environment (CTD) provided by an Oracle instructor, you can skip this part of the Lab.



## Step 1. Prepare OCI Compartment

When provisioning WebLogic for OCI through Marketplace, you need to specify an OCI Compartment where all resources will be created.

Make sure you have a Compartment that you can use or create a new one.

Take note of the compartment **OCID**:

![](images/wlscnonjrfwithenvprereq/image550.png)



The Compartment name is referred as **CTDOKE** in the Hands on Lab.



### 1.1 Required root level policies for WebLogic for OCI

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



### 1.2 Required compartment level policies for WebLogic for OCI

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
```



### 1.3 Service limits

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



## Step 2. Create OCI Secret for WebLogic Admin password

When you provision WebLogic for you need to pass the WebLogic Admin password. An OCI Secret is required for this.  



### 2.1 Create a Security Vault

Go to *Governance and Administration* > *Security* > Vault

![](images/wlscnonjrfwithenvprereq/image010-1.png)



Create a new Shared Vault (leave the *Make it a Virtual Private Vault* option **unchecked**):

![](images/wlscnonjrfwithenvprereq/image020.png)



The new Vault should be listed as Active:

![](images/wlscnonjrfwithenvprereq/image030.png)



Take a look at the Vault Information:

![](images/wlscnonjrfwithenvprereq/image035.png)



### 2.2 Create an Encryption Key

Go to *Master Encryption Keys* submenu of the Vault Information page and create an new Key:

![](images/wlscnonjrfwithenvprereq/image040.png)



Give the key a Name and leave the other settings as default:

![](images/wlscnonjrfwithenvprereq/image050.png)



The new key should be listed as *Enabled*:

![](images/wlscnonjrfwithenvprereq/image053.png)



### 2.3 Create an OCI Secret

Go to *Secrets* submenu of the Vault Information page and create an new Secret:

![](images/wlscnonjrfwithenvprereq/image700.png)



Setup a name for the OCI Secret; choose previously created Encryption Key (**WLSKey**) in the *Encryption Key* dropdown. If you leave default value for *Secret Type Template* (**Plain-Text**), you have to enter the plain WebLogic Admin password in the *Secret Contents* aria. If you switch to **Base64** template, you need to provide the password pre-encoded in base64.

> The password must start with a letter, should be between 8 and 30 characters long, should contain at least one number, and, optionally, any number of the special characters ($ # _).

![image-20200526091220470](images/wlscnonjrfwithenvprereq/image710.png)



Shortly, the Secret should be listed as *Active*:

![image-20200526091948283](images/wlscnonjrfwithenvprereq/image720.png)



Click on the Secret name and take note of its **OCID**. We need to provide this value in the WebLogic for OCI Stack configuration form:

![image-20200526092054260](images/wlscnonjrfwithenvprereq/image730.png)



##  Step 3. Create ssh keys

You need to generate a public and private ssh key pair. During provisioning using Marketplace, you have to specify the ssh public key that will be associated with each of the WebLogic VM nodes.

We will be using the **Cloud Shell** to generate the keys in this tutorial.

- Open your Cloud Console by clicking on the **>** icon

- Create a directory to contain your keys

  ```
  mkdir keys
  
  cd keys
  ```

  

- Now create your key set :

  ```
  ssh-keygen -t rsa -b 4096 -f weblogic_ssh_key
  ```



This will create the **weblogic_ssh_key** containing the private key. The public key will be saved at the same location, with the .pub extension added to the filename: **weblogic_ssh_key.pub**.

```
Generating public/private rsa key pair.
Enter passphrase (empty for no passphrase): 
Enter same passphrase again: 
Your identification has been saved in weblogic_ssh_key.
Your public key has been saved in weblogic_ssh_key.pub.
The key fingerprint is:
SHA256:jnmUBEH3HnwxcibOvcpPLi5/c1p55PoE7LNLHRmijRI jan_leeman@5e83aaf6d012
The key's randomart image is:
+---[RSA 4096]----+
|     .+.. o =    |
|       o = * o   |
|        .E* o. . |
|       . o.o+o. o|
|        S..o..oo.|
|       = ... . *.|
|      o o o . * =|
|       .. .+oo.* |
|         +oo+++o.|
+----[SHA256]-----+
```





You should be able now to run the Hands on Lab on your own cloud environment.