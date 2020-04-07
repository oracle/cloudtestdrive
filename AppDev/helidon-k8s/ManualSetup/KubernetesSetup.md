[Go to Overview Page](../README.md)

![](../../../common/images/customer.logo2.png)

# Migration of Monolith to Cloud Native

## Setting up for the Kubernetes section

### Introduction

This page explains the steps to set up your **Oracle Cloud Tenancy** so you are ready to run the **C. Helidon lab**. 

**If you are attending an instructor-led lab**, your instructor will detail steps you need to execute and which ones you can skip.

### 1. Create the CTDOKE compartment

- Click the `hamburger` menu (three bars on the upper left)

- Scroll down the list to the `Governance and Administration` section

- Under the `Identity` option chose `Compartments`

- You should see a screen that looks like this : 

  ![](images/compartments.png)

  

- **ATTENTION** : if the compartment **CTDOKE** already exists, please move to the next item on this page
- If the **CTDOKE** compartment is not yet there, **create it** : 
  - Click the `Create Compartment` button
  - Provide a name, description
  - Chose **root** as the parent compartment
  - Click the `Create Compartment` button.



### 2. Create a database

- Use the Hamburger menu, and select the Database section, **Autonomous Transaction Processing**
- Click **Create DB**

- Make sure the **CTDOKE** compartment is selected
- Fill in the form, and make sure to give the DB a unique name for you in case multiple users are running the lab on this tenancy.

- Make the workload type `Transaction Processing` 
- Set the deployment type `Shared Infrastructure` 

- Chose the most recent option for the database version, allocate 1 OCPU and 1 GB of storage (this lab only requires a very small database)

- Turn off auto scaling

- Make sure that the `Allow secure access from everywhere` is enabled.

- Chose the `License included` option

Be sure to remember the **admin password**, save it in a notes document for later reference.

- Once the instance is running go to the database details page, on the center left of the general information column there will be the label OCID and the start of the OCID itself. Click the **Copy** just to the left and then save the ODIC together with the password.



### 3. Setup your user

- On the details page for the database, click the **Service Console** button

- On the left side click the **Development** option

- Open up the **SQL Developer Web** console

- Login as admin, using the appropriate password

- Copy and paste the below SQL instructions:

```CREATE USER HelidonLabs IDENTIFIED BY H3lid0n_Labs;
CREATE USER HelidonLabs IDENTIFIED BY H3lid0n_Labs;
GRANT CONNECT TO HelidonLabs;
GRANT CREATE SESSION TO HelidonLabs;
GRANT DWROLE TO HelidonLabs ;
GRANT UNLIMITED TABLESPACE TO HelidonLabs;
```

- Run the script (The Page of paper with the green "run" button.) if it works OK you will see a set of messages in the Script Output window saying the User has been created and grants made.



### 4. Getting your docker credentials and other information

There are a few details (registry id, authentication tokens and the like) you will need to get before you push your images. 

- Please follow the instructions in this document for [getting your docker details](../ManualSetup/GetDockerDetailsForYourTenancy.md)

As there are may be many attendees doing the lab going through the same tenancy we need to separate the different images out, so we're also going to use your initials / name / something unique 

Your full repo will be a combination of the repository host name (e.g. fra.ocir.io for an Oracle Cloud Infrastructure Registry) the tenancy storage name (for example oractdemeabdmnative) and the  details you've chosen

### 5. Docker login in to the Oracle Container Image Registry (OCIR)

We need to tell docker your username and password for the registry. 

You will have gathered the information needed in the previous step. You just need to execute the following command, of course you need to substitute the fields

`docker login <region-code>.ocir.io --username=<tenancy object storage name>/oracleidentitycloudservice/<user name> --password='<auth token>'`

where :

- `<region-code>` : 3-letter code of the region you are using
- `<tenancy object storage name>` : name of your tenancy's Object Storage namespace
- `<user name>` : user name you used to register
- `<auth token>`: Auth token you associated with your username

All of this is information you gathered when you were [getting your docker details](../ManualSetup/GetDockerDetailsForYourTenancy.md)

For example a completed version may look like this (this is only an example, use your own values) **Important** The auth token being used for the password may well contain characters with special meaning to the shell, so it's important to include it in single quotes as in the example below ( ' )

`docker login fra.ocir.io --username=cdtemeabdnse/oracleidentitycloudservice/my.email@company.com --password='q)u70[]eUkM1u}zu;:[L'`

Enter the command with **your** details into a terminal in the Oracle Cloud Shell to log in to the Oracle Cloud Image Registry


### 6. Copy the pre-built Docker images  

- Download the pre-built docker images by executing following commands: **IMPORTANT** run these exactly as they are, don't change any of the parameters as here you are downloading from an existing repository

```
docker pull fra.ocir.io/oractdemeabdmnative/h-k8s_repo/storefront:0.0.1
docker pull fra.ocir.io/oractdemeabdmnative/h-k8s_repo/storefront:0.0.2
docker pull fra.ocir.io/oractdemeabdmnative/h-k8s_repo/stockmanager:0.0.1
```

- Change the docker image tags as follows, replacing following strings:
  - the target OCIR name  **\<myregion\>** with your datacenter name (for example fra.ocir.io)
  - the tenancy Object Storage Namespace (**\<mytenancystoragenamespace\>** in the example)
  - your chosen repository name (**\<myrepo\>** in the example)

```
docker tag fra.ocir.io/oractdemeabdmnative/h-k8s_repo/storefront:0.0.1 <myregion>.ocir.io/<mytenancystoragenamespace>/<myrepo>/storefront:0.0.1
docker tag fra.ocir.io/oractdemeabdmnative/h-k8s_repo/storefront:0.0.2 <myregion>.ocir.io/<mytenancystoragenamespace>/<myrepo>/storefront:0.0.2
docker tag fra.ocir.io/oractdemeabdmnative/h-k8s_repo/stockmanager:0.0.1 <myregion>.ocir.io/<mytenancystoragenamespace>/<myrepo>/stockmanager:0.0.1
```



- Push the images up to your tenancy repo
  - Again changing the myregion, mytenancystoragenamespace and myrepo parameters in the following commands to match the ones you used when you tagged the images

```
  docker push <myregion>.ocir.io/<mytenancystoragenamespace>/<myrepo>/storefront:0.0.1
  docker push <myregion>.ocir.io/<mytenancystoragenamespace>/<myrepo>/storefront:0.0.2
  docker push <myregion>.ocir.io/<mytenancystoragenamespace>/<myrepo>/stockmanager:0.0.1
```

<details><summary><b>Upload denied error?</b></summary>
<p>

If during the docker push stage you get image upload denied errors then it means that you do not have the right policies set for your groups in your tenancy. This can happen in existing tenancies if you are not an admin or been given rights via a policy. (In a trial tenancy you are usually the admin with all rights so it's not generally an issue there.) You will need to ask your tenancy admin to add you to a group which has rights to create repos in your OCIR instance and upload them. See the [Policies to control repository access](https://docs.cloud.oracle.com/en-us/iaas/Content/Registry/Concepts/registrypolicyrepoaccess.htm) document.

</p></details>

## End of the setup

Congratulations, you have successfully prepared your tenancy ! 

Hit the **Back** button of your browser to return to the top level and start the Helidon lab !




```

```