
[Go to Overview Page](../AppDevInfra.md)

![](../../common/images/customer.logo2.png)
## Application Development Infrastructure lab ##
### Create a new Oracle Database instance via the GUI ###

### Introduction ###

Oracle Database Cloud Service provides you the ability to deploy Oracle databases in the Cloud, with each database deployment containing a single Oracle database. You have full access to the features and operations available with Oracle Database, but with Oracle providing the computing power, physical storage and (optionally) tooling to simplify routine database maintenance and management operations.

When you create database deployments, Database Cloud Service creates compute nodes to host the database, using computing and storage resources provided by Oracle Compute Cloud Service. Additionally, it provides access to the compute nodes (and thus to the database) using networking resources provided by Oracle Compute Cloud Service.

### About this tutorial ###
This tutorial demonstrates how to create a Database Cloud Service using the PaaS Cloud Console user interface, running on "OCI", Oracle's second generation Infrastructure.  This ensures we can later use this database to launch a Java Cloud which needs a DB of this type as a prerequisite.

### Prerequisites ###

To run these labs you will need access to an Oracle Cloud Account.  If you are participating in a live event, your instructor will provide you the required credentials.

If you are running these labs on your own, please get a [Oracle Cloud Free Tier account](https://myservices.us.oraclecloud.com/mycloud/signup?sourceType=:ex:tb:::RC_EMMK181016P00010:Virtual_WS_DEV&SC=:ex:tb:::RC_EMMK181016P00010:Virtual_WS_DEV&pcode=EMMK181016P00010) or set up your corporate UC subscription for this lab.

In this lab we will use the option to deploy to "OCI" infrastructure (as opposed to the older OCI-C or Classic).  In order to be able to use OCI, you first need to create a few OCI artefacts: a valid Virtual Network Configuration (VCN) and a Storage Bucket.

#### Prerequisites for OCI-based PaaS Services ####

In order to create PaaS Services based on OCI infrastructure, you must create the following artefacts:  
- Set up a VCN Network
- Create a Object Storage Bucket
- Create an Auth token (Swift Password)
- Set up a PaaS Policy definition

Follow the steps 1 to 6 in [this tutorial](https://docs.cloud.oracle.com/iaas/Content/General/Reference/PaaSprereqs.htm) to create these elements.

### Steps to create a Database ###

Go to the Console (see Access information that was delivered to you in the workshop, or login to your [Oracle Cloud Free Tier environment](https://cloud.oracle.com/sign-in) ). After a successful login you will see your Dashboard.

Make sure you have the tile "Database Classic" displayed.  If this is not the case, use the button "Customize Dashboard", scroll down to the "Database Classic" service in the list, and select "Show".

On dashboard click the hamburger icon on the "Database Classic" tile. Select **Open Service Console**.
![](images/01.png)

This is the Database Cloud Service Console page. To create new instance click **Create Service** button.
![](images/02.png)

Now you can fill in the key parameters for choosing the caracteristics of the database you will create :

+ **Instance Name**: the name of the service instance e.g. techcoDB01.  Please use your participant number in the name of the DB in case you are using a shared instance.

+ **Description**: any description for your service.

+ **Region**: choose one of the available regions.  This will typically be Frankfurt or Ashburn.

    - **Availability Domain**: Select one of the available availability domains.

    - **Subnet**: Select an available subnet.

    - You can also Select "No Preference" to instantiate the DB on Compute Classic (OCI-C). In this case, no Network info needs to be provided.


+ **License Type**: Select "Subscribe to a new Database License".  In case you have existing Oracle Database licenses in your organization that are not in use on your own infrastructure, you can choose the other option.

+ **Software Release**: Select the "Oracle Database 12c Release 1

+ **Software Edition**: Select "Enterprise Edition"

+ **Database Type**: Select "Single Instance".

  You can experiment with these parameters to see the possible options, for example how to set up a RAC environment.

![](images/dbcreate1.png)

The second input page is the Service Details page. The following parameters have to be provided:

+ **DB Name (SID)**: container database service identifier.

+ **PDB Name**: pluggable database service identifier. You can leave the default PDB1

+ **Administrator Password**: database instance's system password. Don't forget to note the provided password.

+ **Compute Shape**: number of OCPU and size of the RAM. Choose the appropriate size for your project, for example an OC4.  Attention, when using a Shared Environment provided by your instructor, use the smallest one: OC3

+ **SSH Public Key**: public key which will be uploaded to the VM during the creation. It allows to connect to the VM through ssh connection using the private key. To avoid additional task to create keypairs select Create a New Key option and download the newly generated keypair for later usage. Download the zip file to your `GIT_REPO_LOCAL_CLONE/cloud-utils` folder and unzip for later usage.
![](images/06.png)

+ **Backup Destination**: Leave default: Both Cloud and Local Storage

+ **Cloud Storage Container**: the name of the container for database instance.

  - For an **OCI**-based instance, the format is the following:
   - https://swiftobjectstorage.REGION.oraclecloud.com/v1/IDENTITYDOMAIN/BUCKETNAME
   - for example:  https://swiftobjectstorage.us-ashburn-1.oraclecloud.com/v1/gse00014344/PaasBucket
   - Replace the REGION and IDENTITYDOMAIN value according to your environment and use the BUCKETNAME you specified when creating the OCI PaaS prerequisite artefacts
  - For an **OCI-Classic**-based instance, the format is the following:
   - Storage-IDENTITYDOMAIN/CONTAINERNAME,
   - for example:  Storage-gse00002323/user01.
   - Replace the IDENTITYDOMAIN value according to your environment and specify a CONTAINERNAME. Container name is up to you. The container don't need to be created in advance, because -see below- there is an option to create automatically.


+ **Cloud Storage User Name and Password**: the credentials for storage. Usually it is the same what was used to sign in to Oracle Cloud Services.

+ **Create Cloud Storage Containers**: check in because the container does not exist what you specified above.

![](images/dbcreate2.png)
For more details about parameters see the [documentation](https://docs.oracle.com/cloud/latest/dbcs_dbaas/CSDBI/GUID-D4A35763-53ED-4FBB-97BF-0366F21B05E0.htm#CSDBI3401). Click **Next**.

The final page is the summary about the configuration before submit the instance creation request.

ATTENTION : In case you are using a shared environment, a database has already been provisioned for you in this environment, so you can Cancel the creation of the database at this point and use the seeded database instead.  If in doubt, check with your instructor.

![](images/dbcreate3.png)

If you should have gone ahead and created the database, the request would have been accepted and the Database Service Console page would  show the new instance. The instance would first be in Maintenance (Progress) mode.
![](images/09.png)

---
## Optional steps using the pre-seeded database ##
Below are some extra exercises you can perform using the already created Database instance.

+ If you are going through this lab as a 1-hour Database Cloud Service  stand-alone exercise, please continue with the below steps.  
+ If you are doing this lab as part of the AppDev Infrastructure lab covering JCS, DBCS, Compute and Container cloud, you can skip these steps.

#### Enabling the Firewall Rules ####

Make sure you are logged-in and the Database Service Console is visible. You should see a window similar to this.  If you are using the "Cloud Test Drive" environment, this pre-seeded database will most likely be called "MyDBCS".

![](images/image042.gif)

+ Click on the ‘Hamburger’ menu for the pre-created service and select ‘Access Rules’
The following screen or similar should be displayed:

![](images/image046.gif)

This screen allows you to change pre-created firewall access rules or allows you to define new ones. In this example, we will enable the firewall rules that allow us to access our tools.

+ Click on the ‘Hamburger menu’ at the right of the rule ‘ora_p2_httpadmin’ and port 4848

Attention: all participants in your group will be using this same pre-seeded database. So this rule might already be "enabled" by someone else.  In that case, just look at the options but DO NOT DISABLE the rule again !

The following screen or similar should be visible:

![](images/image048.gif)

When choosing the "Enable" option, the following pop-up or similar should be displayed:

![](images/image050.gif)

Press ‘Enable’ and wait for the operation to finish.  The pop-up should disappear and the Access Rules page should be updated.

Now please enable the following services in the same way:

+ ora_p2_dbexpress
+ ora_p2_httpssl

#### Working with the available Cloud tools ####
In this part of the hands-on, we will walk-through the various tools available by default. Please make sure you have enabled all required firewall rules as demonstrated in the previous chapter and that you are on the Database Service Console Page:

![](images/image042.gif)

Click on the ‘Hamburger Menu’ for the pre-created Database service and select ‘Open EM Console’
If this is the first time you access the EM Express, your browser might give you a warning that the security certificate of the site is not valid or cannot be checked.

Please, accept the connection and the certificate. This varies by browser, the workshop-assistants should be able to help in case you do not know how to do this.
 
If all went well, the following screen should be displayed:

![](images/image056.gif)

Please login with username / password for the database as detailed in account information you received at the beginning of this lab.  The following screen or similar should be displayed:

![](images/image058.gif)

In this Enterprise Manager Express screen, you can see the status of the database including the number of ‘Pluggable Databases’ that are plugged into this container database:

![](images/image060.gif)

Feel free to click around in the Enterprise Manager Express Console.
When you want to continue, return to the Database Service Console

#### Using the Database Monitor Console ####
This time, we will use another tool available by default, the Database Monitor Console.

+ Return to the Database Service Console
+ Click on the ‘Hamburger Menu’ for the pre-created service and choose Open Database Monitor Console’

You might see a similar certificate error in your browser. Please accept this certificate to continue. The following login-screen should be visible:

![](images/image062.gif)

Login using username ‘dbaas_monitor’ and password as provided in your account information document.  The following overview screen should be visible:

![](images/image064.gif)

You can click around in this tool to see the various options.
If you want to continue, click on the ‘Database’ drop down box in the top of the screen

![](images/image066.gif)

Choose ‘Manage’ from the dropdown box
The following screen or similar should be visible:

![](images/image068.gif)

As a demonstration, we will clone the existing PDB1 into a new PDB.
 
Click on the ‘Hamburger Menu’ in the PDB1 window

![](images/image070.gif)

Select the ‘Clone’ option to continue
The following screen or similar should be visible:

![](images/image072.gif)

Fill in the following values and press Ok:

+ New PDB Name: MyPDB_userxx
+ Keystore Password: use the same password as detailed in your access document
+ keep all other values default

After about 30 seconds you will get the confirmation that the PDB has been created successfully. After clicking on Ok, the following screen (or similar) is visible:

![](images/image074.gif)

You have successfully cloned a PDB using the available cloud tools.


#### SSH Connection and Image Exploration ####

In the upcoming steps you will record the IP addresses of the prebuilt Database Cloud Service Instance, and connect to this Compute node via SSH.

+ Navigate back to the Database Service Console with the list of available database instances
+ Click on the "MyDBCS" instance from the list of Database Services
+ Note the Public IP address of this instance. You will need this later to connect using SSH.

![](images/image016.png)

The Database Cloud Service is secure by default for connections.  Only the management port 22 used by SSH is open.  All other ports are disabled, such as the SQL Net port 1521.  In this exercise we are going to use the management port 22 to explore the virtual image the Database Cloud Service is running on.

+ Make sure you have an SSH tool like Putty or the browser extension FireSSH to set up an SSH session.
+ In this tutorial, we will assume you are using Putty.  If you are using another tool, please perform similar steps as described below to connect to the instance.
+ Run Putty.exe from your laptop.
+ Enter the public IP address of your Database Cloud Service, and Port 22 for SSH.

![](images/image017.png)

+ From the Connection category, expand SSH and select Auth, and browse for your private key labkey.ppk that is provided by your instructor or downloaded when creating your Database instance in the previous chapter.

![](images/image018.png)

+ Click Open and Login as oracle.
+ You may be prompted for a passphrase when logging in.  If not proceed.  

Explore the Database Cloud Service Image

+ Now that you are connected to the instance let’s look around.
+ Issue a df command to see mounted disks.
```
    df
```


![](images/image022.png)

+ Issue the following command to view the Database environment variable :
```
    env | grep ORA
```

![](images/image023.png)

+ Now let’s change directories to the Oracle Home and list the directories.
```
    cd $ORACLE_HOME
    ls
```

![](images/image024.png)

+ Type exit to close the session or explore some more.
```
    exit
```

---
[Go to Overview Page](../AppDevInfra.md)
