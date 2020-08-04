# WebLogic for OCI - non JRF prerequisites

### Prerequisites for using own environment



## Objective

If you want go through the Hands on Lab (*WebLogic for OCI Instance - non JRF using Oracle Cloud Marketplace*) using your cloud environment, follow this guide to setup some prerequisites. If you are going to use the Cloud Test Drive environment (CTD), skip this Lab.



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

Go to *Governance and Administration* > *Security* > *Key Management*:

![](images/wlscnonjrfwithenvprereq/image010.png)



Create a new Shared Vault (leave the *Make it a Virtual Private Vault* option unchecked):

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



## Step 3. Network Configuration

The Hands on Lab guide uses an existing Virtual Cloud Network and pre-configured Subnets for the WebLogic compute nodes and for the Load Balancer.

 If running the lab in a different cloud environment, the easiest way is to choose for creation of required network resources during provisioning.



When filling in Stack form choose to *Create New VCN* for Virtual Cloud Network Strategy. Setup a VCN name. You can leave default Network CIDR value or change it.

![](images/wlscnonjrfwithenvprereq/image600.png)



You can leave default options for Subnet configuration:

![](images/wlscnonjrfwithenvprereq/image610.png)



Also for the Load Balancer (make sure to select **100Mbps** for the *Load Balancer Shape* as instructed in the lab):

![](images/wlscnonjrfwithenvprereq/image620.png)



##  Step 4. Create ssh keys

You need to generate a public and private ssh key pair. During provisioning using Marketplace, you have to specify the ssh public key that will be associated with each of the WebLogic VM nodes.

You can choose one of the options below:

### A) Using ssh-keygen

> ssh-keygen -t rsa -b 4096 -f weblogic_ssh_key

This will create the **weblogic_ssh_key** containing the private key. The public key will be saved at the same location, with the .pub extension added to the private key filename (**weblogic_ssh_key.pub**).

If you don't have `ssh-keygen` installed, you can use the Cloud Shell:

![](images/wlscnonjrfwithenvprereq/image520.png)



### B) Using PuTTYgen

Launch the PuTTYgen tool and use the *Generate* button to generate a new private/public key pair.

![](images/wlscnonjrfwithenvprereq/image500.png)



After key generation, don't forget to save the public and private key. If not using Putty as ssh client, you'll need to save the key in OpenSSH format (*Conversions* -> *Export OpenSSL key*).

![](images/wlscnonjrfwithenvprereq/image510.png)



The public key filename is referred as **weblogic_ssh_key.pub** in the Hands on Lab.



## Step 5. Load balancer SSL configuration

For security reasons it's a good practice - if not mandatory - to allow only secured traffic between clients and WebLogic Server applications. Therefore, after provisioning WebLogic for OCI by choosing to setup a Load Balancer, it's necessary to manually finish SSL configuration by adding a SSL certificate to the load balancer's listener.



### Create Self Signed certificate

We can use Openssl tool (and Cloud Shell!) to generate a Self Signed certificate:

> openssl req -x509 -newkey rsa:4096 -keyout weblogic_cert_key.pem -out weblogic_cert.pem -days 365

![](images/wlscnonjrfwithenvprereq/image530.png)



The openssl dialog will request setting up a PEM pass phrase and several fields for certificate information. You may setup **weblogic** as the value for *Common Name (e.g. server FQDN or YOUR name)* field.

You may setup any pass phrase, don't forget it. In the Hands on Lab it's mentioned to be provided in the **weblogic_cert_key_passphrase.txt** text file.

![](images/wlscnonjrfwithenvprereq/image540.png)



Next, we need to decrypt the private key:

> openssl rsa -in weblogic_cert_key.pem -out weblogic_cert_key_dec.pem



Note: that above examples generate the same file names for the certificate and private key as in the Hands on Lab: **weblogic_cert.pem** and **weblogic_cert_key_dec.pem**.



You should be able now to run the Hands on Lab on your own cloud environment.