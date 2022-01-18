![](../../../common/images/customer.logo2.png)

# Setting up the OCI environment using the individual scripts

For people who have want to run the script manually per script these instructions explain the process

You are assumed to have downloaded the helidon-kubernetes script repo, and to have downloaded step.

## Task 1: Recording your initials

For a number of activities in the lab we use your initials to identify instances (database, Kubernetes etc.) We do this to enable multiple user to operate in the same tenancy withouth conflict (This is only for some versions of the lab, in most cases you will be using your own free trial tenancy). 

We need to capture your initials and save them. It is important that when you enter your initials you use lower case only and only the letters a-z, no numbers of special characters

  1. If you are not already there open the OCI cloud shall and go to the scripts directory, type
  
  - `cd $HOME/helidon-kubernetes/setup/common`
  
  2. Run the script to gather and save your initials, when prompted by the script enter your initials and press return, in the example below as my name is Tim Graves I used `tg` as the initials
  
  - `bash ./initials-setup.sh`
  
  ```
  Please can you enter your initials - use lower case a-z only and no spaces, for example if your name is John Smith your initials would be js. This will be used to do things like name the database
tg
OK, using tg as your initials
```

Of course unless your initials are also `tg` you would enter something different !


## Task 2: Configuring your user identity

A number of processes require knowledge of your users identity, this script will locate that and save it away

1. If you are not already there open the OCI cloud shall and go to the scripts directory, type
  
  - `cd $HOME/helidon-kubernetes/setup/common`
  
  2. Run the compartment setup script, it does not require any input
  
  - `bash ./user-identity-setup.sh`
  
  ```
  Loading existing settings
No existing user info, retrieving
Checking for local user
Checking for federated user
You are a federated user, getting information
You are a federated user, your user name is oracleidentitycloudservice/tim.graves@oracle.com, saved details
```


## Task 3: Creating the compartment

In OCI all resources live in compartments, we are going to create a compartment for this lab. If you have already created a compartment in the past when doing other parts of this lab then please re-use the same one when prompted.

The following instructions follow through the prompts one at a time, unless you have specific requirements (usually because you are not running in a free trial account) then just take the defaults.

  1. If you are not already there open the OCI cloud shall and go to the scripts directory, type
  
  - `cd $HOME/helidon-kubernetes/setup/common`
  
  2. Run the compartment setup script
  
  - `bash ./compartment-setup.sh`
  
  ```
  Loading existing settings
No reuse information for compartment
Parent is tenancy root
This script will create a compartment called CTDOKE for you if it doesn't exist, this will be in the Tenancy root. If a compartment with the same name already exists you can re-use change the name to create or re-use a different compartment.
If you want to use somewhere different from Tenancy root as the parent of the compartment you are about to create (or re-use) then enter n, if you want to use Tenancy root for your parent then enter y
Use the Tenancy root (y/n) ?
```

  3. At this prompt unless you want to create the compartment somewhere else please enter `y` and press return. You should chose the tenancy root unless you are in a shared or commercial tenancy and you explicitly understand you need to work somewhere other than the tenancy root. If you really want to create or reuse a compartment somewhere other than the tenancy root enter `n` and follow the instructions that will be displayed.
  
  ```
  We are going to create or if it already exists reuse use a compartment called CTDOKE in Tenancy root, if you want you can change the compartment name from CTDOKE - this is not recommended and you will need to remember to use a different name in the lab.
 Do you want to use CTDOKE as the compartment name (y/n) ? 
 ```
 
  4. You are being asked if you want to use `CTDOKE` as the name of the compartment to use (or if it already exists re-use). If you have chosen a different compartment as the parent that will be displayed instead of `Tennancy root`. Unless you explicitly know you need to use a different compartment then please enter `y` here. If you really want a different name for your compartment (perhaps because you are re-using one with a different name, or `CTDOKE` is in use for something else) then type `n` and follow the prompts to enter a different name.
  
  ```
  OK, going to use CTDOKE as the compartment name
Compartment CTDOKE, doesn't already exist in the Tenancy root, creating it
Created compartment CTDOKE in the Tenancy root It's OCID is ocid1.compartment.oc1..aaaaabaas5lazl434a7oizjiuife3tjffwucxrbom2zdhyhvh5t66mb75olq
It may take a short while before new compartment has propogated and the web UI reflects this
```
  
  In this case the compartment `CTDOKE` (or whatever name you entered if you chose to override it) did not exist in the tenancy root, so the compartment was created, If it had existed then the script would have retrieved it's information for re-use.
  
  **Important** It can take a short while for the compartment information to be propagated to all OCI regions and environments.
  
## Task 4: Creating the database

The microservices that form the base content of these labs use a database to store their data, so we need to create a database. The Following script will create the database in the compartment we just created, then download the connection information (the "Wallet") and use that to connect to the database and create the user used by the labs.

  1. If you are not already there open the OCI cloud shall and go to the scripts directory, type
  
  - `cd $HOME/helidon-kubernetes/setup/common`
  
  2. Run the script to create or re-use the database
  
  - `bash ./database-setup.sh`
  
  ```
  Loading existing settings information
No reuse information for database
Operating in compartment CTDOKE
Do you want to use tgdb as the name of the databse to create or re-use in CTDOKE?
```

  3. if you are creating a new database then enter `y` if however you have an existing database in this compartment, perhaps created doing another part of these Kubernetes labs which used a different name then please enter `n` and when prompted enter that name - you will need to know the ADMIN password for that database and will be prompted for it.
  
  ```
  OK, going to use tgdb as the database name
Checking for database tgdb in compartment CTDOKE
Database named tgdb doesn't exist, creating it, there may be a short delay
The generated database admin password is 2005758405_SeCrEt Please ensure that you save this information in case you need it later
```

  4. The database will be created for you unless you chose a name that already exists, The script will then setup a temporary set of access credentials using the wallet, connect to the database using the password it generated (or in the case of a database that you are re-using the password you provided) and setup the labs user in the database.
  
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
The generated admin password is 2005758405_SeCrEt Please ensure that you save this information in case you need it later

```
  
  5. **IMPORTANT** you are **strongly** recommended to save the generated database password (`2005758405_SeCrEt` in this case) in case you need to administer the database later. If there is an existing `$HOME/Wallet.zip` then it will be saved before downloading the new wallet.