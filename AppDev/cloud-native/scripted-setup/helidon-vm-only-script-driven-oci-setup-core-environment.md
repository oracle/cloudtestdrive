![](../../../common/images/customer.logo2.png)

# Setting up the core OCI environment using scripts (Helidon VM only)

This module walks you through the process of setting up the core OCI features needed for all of the related labs.

Note that at some points you will need to say if you are in a `free trial tenancy`. This is referring to the 30 day free trial tenancies that Oracle offers with a few hundred US$ of resources available to you at no cost. In most cases for these labs you will be using a `free trial tenancy`, but it is also possible to run these labs where multiple people are sharing a free trial tenancy, or you are using a commercial (paid for) tenancy to run the labs (this is usually if a dedicated session is being rub for your organization). In that case you may be told to follow slightly different instructions, for example to ensure that you each use a different compartment to separate your work for each other or anything that your company may have already setup.

To speed things up for people who are just starting with this set of labs (or deleted their previously created environment) we have provided some scripts that you can use to set things up quickly, consistently and with less opportunity for mistakes.

<details><summary><b>Already done some of the labs ?</b></summary>

If you have done some of the other Helidon and Kubernetes labs connected to the one you are currently doing you will have setup the core OCI environment in those labs and perhaps retained it, as long as you have the following setup you're fine and you can proceed with setting up your virtual machine int he next module. If all of the following are missing it's easiest to just proceed with running the tasks below starting at  Task 1.)

User information captured (initials and user identity) Entries for `USER_INITIALS` and `USER_OCID` in `$HOME/hk8sLabsSettings`

<details><summary><b>User information or initials missing ?</b></summary>

Can setup the user initials using the `$HOME/helidon-kubernetes/setup/common/initials-step.sh` script

Can setup the user ocid using the `$HOME/helidon-kubernetes/setup/common/user-identity-step.sh` script

</details>

Compartment created - Entry for `COMPARTMENT_OCID`  in `$HOME/hk8sLabsSettings`

<details><summary><b>Compartment info missing ?</b></summary>

Can setup the compartment (or re-use and existing one) using the `$HOME/helidon-kubernetes/setup/common/compartment-step.sh` script

</details>

Database created - Entry for `ATPDB_OCID`  in `$HOME/hk8sLabsSettings` and `$HOME/Wallet.zip` exists

<details><summary><b>Database info missing ?</b></summary>

Can setup the database (or re-use and existing one) using the `$HOME/helidon-kubernetes/setup/common/database-step.sh` script

</details>
---
</details>

## Task 1: Downloading the latest scripts

There are a number of scripts that we have created for this lab to make life easier, if you have previously downloaded those then you should ensure you have the latest version, if you haven't downloaded them then you will need to do so.

If you are not sure if you have downloaded the latest version then you can check

  - In the OCI Cloud shell type 
  
  - `ls $HOME/helidon-kubernetes`

If you get output like this then you need to download the scripts, follow the process in **Task 1a**

```
ls: cannot access /home/tim_graves/helidon-kubernetes: No such file or directory
```

If you get output similar to this (the file names and count may vary slightly as the lab evolves) then you have downloaded the scripts previously, but you should get the latest versions, please follow the steps in **Task 1b**

```
base-kubernetes          configurations       deploy.sh   monitoring-kubernetes  README.md     servicesClusterIP.yaml  stockmanager-deployment.yaml  undeploy.sh
cloud-native-kubernetes  create-test-data.sh  management  README                 service-mesh  setup                   storefront-deployment.yaml    zipkin-deployment.yaml
```

### Task 1a: Downloading the scripts

We will use git to download the scripts

  1. Open the OCI Cloud Shell

  2. Make sure you are in the top level directory
  
  - `cd $HOME`
  
  3. Clone the repository with all scripts from github into your OCI Cloud Shell environment
  
  - `git clone https://github.com/CloudTestDrive/helidon-kubernetes.git`
  
  ```
  Cloning into 'helidon-kubernetes'...
remote: Enumerating objects: 723, done.
remote: Counting objects: 100% (723/723), done.
remote: Compressing objects: 100% (452/452), done.
remote: Total 723 (delta 423), reused 537 (delta 249), pack-reused 0
Receiving objects: 100% (723/723), 110.23 KiB | 0 bytes/s, done.
Resolving deltas: 100% (423/423), done.
```

Note that the precise details will vary as the lab is updated over time.

Please go to **Task 2** Do not continue with anything else in task 1

### Task 1b: Updating previously downloaded scripts

We will use git to update the scripts

  1. Open the OCI Cloud shell type
  
  2. Make sure you are in the home directory
  
  - `cd $HOME/helidon-kubernetes`
  
  3. Use git to get the latest updates
  
  - `git pull`

```
remote: Enumerating objects: 21, done.
remote: Counting objects: 100% (21/21), done.
remote: Compressing objects: 100% (8/8), done.
remote: Total 14 (delta 6), reused 14 (delta 6), pack-reused 0
Unpacking objects: 100% (14/14), done.
From https://github.com/CloudTestDrive/helidon-kubernetes
   51c1ba8..f3845ad  master     -> origin/master
Updating 51c1ba8..f3845ad
Fast-forward
 setup/common/compartment-destroy.sh                 | 50 ++++++++++++++++++++++++++++++++++++++++++++++++++
 setup/common/compartment-setup.sh                   | 14 ++++++++++++++
 setup/common/database-destroy.sh                    | 38 ++++++++++++++++++++++++++++++++++++++
 setup/common/database-setup.sh                      | 15 ++++++++++++++-
 setup/common/delete-from-saved-settings.sh          | 12 ++++++++++++
 setup/common/initials-destroy.sh                    |  3 +++
 setup/common/{get-initials.sh => initials-setup.sh} |  2 +-
 setup/common/kubernetes-destroy.sh                  | 57 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 setup/common/kubernetes-setup.sh                    | 24 ++++++++++++++++++------
 setup/common/oke-terraform.tfvars                   |  2 ++
 10 files changed, 209 insertions(+), 8 deletions(-)
 create mode 100644 setup/common/compartment-destroy.sh
 create mode 100644 setup/common/database-destroy.sh
 create mode 100644 setup/common/delete-from-saved-settings.sh
 create mode 100644 setup/common/initials-destroy.sh
 rename setup/common/{get-initials.sh => initials-setup.sh} (89%)
 create mode 100644 setup/common/kubernetes-destroy.sh
```

Note that the output will vary depending on exactly what changes have been made since you first download the scripts or last updated them.

Please continue with **Task 2**
  
## Task 2: Configuring the core environment in one go

If you are running in a free trial tenancy allocated to you then follow the process outlined below, so please skip over the expansion.

<details><summary><b>Only read if you are not in a free trial tenancy, or are sharing a free trial with other people !</b></summary>

If you are running in a shared or commercial tenancy, or are sharing your free trial tenancy with other users then the process below will generally work, however you will want to be sure to say that you are not in a free trial when asked and follow the instructions given to perform the required processes step by step, there is more information on those individual steps [at this location](https://github.com/oracle/cloudtestdrive/blob/master/AppDev/cloud-native/scripted-setup/per-script-instructions-core-environment.md) if you chose to follow them rather than these instructions then when you have completed them skip to Task 4

---

</details>

There are a number of activities required to configure the core environment, these include identifying your self by your initials, locating your user information, setting up compartments, and creating a database. The core-environment-setup script will gather some information and then do the core work for you. You may have already done this as part of a related lab in your tenancy, if so the scripts will recognize previously created resources (provided they have not been destroyed of course) so there is no harm in re-running the scripts.

  1. If you are not already there open the OCI cloud shall and go to the scripts directory, type
  
  - `cd $HOME/helidon-kubernetes/setup/common`
  
  2. Run the script
  
  - `bash ./core-environment-setup.sh`
  
  3. When asked if you are in a Free trial tenancy enter `y` if you are (if you are not sure what type of tenancy you have then you probably are in a free trial tenancy, in a taught class your instructor will make it clear if you are not). If you are not then enter `n` and follow the instructions (possibly also doing this step by step, see the link in the expansion if you need more information n this)
  
  ```
  This script will run the required commands to setup your core environment
  It assumes you are working in a free trial tenancy exclusively used by yourself
  If you are not you will need to exit at the prompt and follow the lab instructions for setting up the configuration separatly
  Are you running in a free trial environment (y/n) ?
```
   
  4.  to gather and save your initials, when prompted by the script enter your initials and press return, in the example below as my name is Tim Graves I used `tg` as the initials. Of course unless your initials are also `tg` you would enter something different !
  
  
  ```
  Please can you enter your initials - use lower case a-z only and no spaces, for example if your name is John Smith your initials would be js. This will be used to do things like name the database
tg
OK, using tg as your initials
```
  5. The script will then locate your user information, this is automatic and doesn't require any input, you will see output similar to 
  
  ```
  Loading existing settings
No existing user info, retrieving
Checking for local user
Checking for federated user
You are a federated user, getting information
You are a federated user, your user name is oracleidentitycloudservice/tim.graves@oracle.com, saved details
```

  6. The script next creates a compartment to work in, you will be asked if you want to use the tenancy root as the parent, if you are in a free trial tenancy then enter `y` 
  
<details><summary><b>Only read if you are not in a free trial tenancy, or are sharing a free trial with other people !</b></summary>

  You should chose the tenancy root unless you are in a shared trial or a commercial tenancy and you explicitly understand you need to work somewhere other than the tenancy root. If you really want to create or reuse a compartment somewhere other than the tenancy root enter `n` and follow the instructions that will be displayed.
  
</details>
  
  ```
  Loading existing settings
No reuse information for compartment
Parent is tenancy root
This script will create a compartment called CTDOKE for you if it doesn't exist, this will be in the Tenancy root. If a compartment with the same name already exists you can re-use change the name to create or re-use a different compartment.
If you want to use somewhere different from Tenancy root as the parent of the compartment you are about to create (or re-use) then enter n, if you want to use Tenancy root for your parent then enter y
Use the Tenancy root (y/n) ?
```

  7. You will be asked if you want to use CTDOKE as the compartment name, if you are in a free trial tenancy and not sharing it with other people enter `y`
  
<details><summary><b>Only read if you are not in a free trial tenancy, or are sharing a free trial with other people !</b></summary>

Unless you are in a shared free trial or are in a commercial tenancy you can use CTDOKE as the compartment name, just enter `y`. If you know you need to use a different compartment (perhaps there are multiple users in the 30 day free trial doing the lab, or a commercial tenancy admin has told you to do it elsewhere) then please enter `n` here, and follow the prompts to enter a different name.
  
If you have chosen a different compartment as the parent (by setting COMPARTMENT_PARENT_OCID in $HOME/hk8sLabsSettings that will be displayed instead of `Tennancy root`. 
  
</details>
  
  ```
  We are going to create or if it already exists reuse use a compartment called CTDOKE in Tenancy root, if you want you can change the compartment name from CTDOKE - this is not recommended and you will need to remember to use a different name in the lab.
 Do you want to use CTDOKE as the compartment name (y/n) ? 
 ```
 
  8. The script will create the compartment. 
  
  ```
  OK, going to use CTDOKE as the compartment name
Compartment CTDOKE, doesn't already exist in the Tenancy root, creating it
Created compartment CTDOKE in the Tenancy root It's OCID is ocid1.compartment.oc1..aaaaabaas5lazl434a7oizjiuife3tjffwucxrbom2zdhyhvh5t66mb75olq
It may take a short while before new compartment has propogated and the web UI reflects this
```
  
 9. The microservices that form the base content of these labs use a database to store their data, so we need to create a database. The  script will create the database in the compartment we just created, then download the connection information (the "Wallet") and use that to connect to the database and create the user used by the labs.

 10. If you are in a free trial tenancy you will be creating a new database so enter `y` 
  
<details><summary><b>Only read if you are not in a free trial tenancy or know you have an existing database to reuse</b></summary>
 
If you have an existing database in this compartment, perhaps created doing another lab which used a different database then please enter `n` and when prompted enter that name - you will need to know the ADMIN password for that database and will be prompted for it.

</details>
 
  ```
  Loading existing settings information
No reuse information for database
Operating in compartment CTDOKE
Do you want to use tgdb as the name of the database to create or re-use in CTDOKE?
```
 
  11. The script will create the database 
   
  ```
OK, going to use tgdb as the database name
Checking for database tgdb in compartment CTDOKE
Database named tgdb doesn't exist, creating it, there may be a few minutes delay
Action completed. Waiting until the resource has entered state: ('AVAILABLE',)
Database creation started
The generated database admin password is 19342873846_SeCrEt Please ensure that you save this information in case you need it later
Downloading DB Wallet file
There may be a delay of several minutes while the database completes its creation process, dont worry.
  
  ```
  
  12.   The script will then setup a temporary set of access credentials using the wallet, connect to the database using the password it generated (or in the case of a database that you are re-using the password you provided) and setup the labs user in the database.
  
  If you are reusing a database and had already setup the labs user then you may get error messages that the user conflicts with the existing one.
  
  ```
  Downloaded Wallet.zip file
Preparing temporary database connection details
Getting wallet contents for temporaty processing
Archive:  Wallet.zip
  inflating: README                  
  inflating: cwallet.sso             
  inflating: tnsnames.ora            
  inflating: truststore.jks          
  inflating: ojdbc.properties        
  inflating: sqlnet.ora              
  inflating: ewallet.p12             
  inflating: keystore.jks            
updating temporary sqlnet.ora
Connecting to database to create labs user

SQL*Plus: Release 19.0.0.0.0 - Production on Fri Nov 19 21:22:24 2021
Version 19.13.0.0.0

Copyright (c) 1982, 2021, Oracle.  All rights reserved.


Connected to:
Oracle Database 19c Enterprise Edition Release 19.0.0.0.0 - Production
Version 19.13.0.1.0


User created.


Grant succeeded.


Grant succeeded.


Grant succeeded.


Grant succeeded.

Disconnected from Oracle Database 19c Enterprise Edition Release 19.0.0.0.0 - Production
Version 19.13.0.1.0
Deleting temporary database connection info
The database admin password is 2005758405_SeCrEt Please ensure that you save this information in case you need it later
```
  
  12. **IMPORTANT** The database password is auto-generated and will not be displayed again. you are **strongly** recommended to save the generated database password (`2005758405_SeCrEt` in this case) in case you need to administer the database later. If there is an existing `$HOME/Wallet.zip` then it will be saved before downloading the new wallet.
```


## Acknowledgements

* **Author** - Tim Graves, Cloud Native Solutions Architect, EMEA OCI Centre of Excellence
* **Last Updated By** - Tim Graves, February 2022