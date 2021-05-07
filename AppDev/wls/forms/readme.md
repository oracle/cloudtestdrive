# Forms on OCI with Universal Credits 



## Summary

This tutorial proposes an automation to create a Forms environment using the WLS for OCI Suite UCM Marketplace stack.  This allows you to spin up a new Forms environment, without a need to purchase classic licenses, since the WLS for OCI Suite offers you the entitlement to run Oracle Forms, and pay per use - per OCPU and per hour.

We'll be using the standard WLS for OCI Marketplace Stack terraform script, and ammend it to include the creation of a Forms installation on each WLS node.

To see this tutorial in **LiveLabs** format, click [here](https://oracle.github.io/cloudtestdrive/AppDev/wls/forms).



## Overview of the steps of this tutorial

**Step 1: Prepare your environment**

- Clone the scripts to your cloud shell from github
- Make sure you have a public/private key ssh key pair available
- Set the Terraform environment variables for your tenancy



**Step 2: Run the Edelivery terraform script to create initial artefacts:**

- A Virtual Cloud Network with appropriate subnets, routing rules etc.
- An ATP database to be used for the JRF database
- A shared filesystem that will contain the Forms installation files
- A Build Virtual machine to download the Forms installation software from the eDelivery website



**Step 3: Download and prepare the Forms software** 

- Get the Forms install software install script from the eDelivery website
- Download and prepare the Forms Installation on the shared filesystem



**Step 4: Run the WebLogic Stack terraform script**

- This is the standard WLS for OCI Marketplace teraform script, with the installation of Forms appended at the end.



**Step 5: Validate you can access a test Form running on the installation**



All the steps generate extensive log files, we'll clearly indicate where you can check if everything went OK and how to debug if required.



## Step 1: Preparing the environment

We'll be using the *Cloud Shell* of your tenancy to run most of the commands, as this environment already has all the required utilities installed : terraform, git, jq, ssh, etc.

### Preparing your tenancy

- Log into your tenancy and start the Cloud Shell

- Clone the example scripts from github by issuing the following command:

  ```
  git clone https://github.com/CloudTestDrive/forms_wls.git
  ```

  This will create the folder forms_wls, containing the *bin* directory.

- cd into the bin directory

  ```
  cd forms_wls/bin
  ```

  We'll be editing the file env.sh containing all the variables terraform needs to execute the creation of the environment.  Before doing so we need to collect a number of ID's from our Cloud tenancy.

Collect the following data from your tenancy, navigating the menu of the Cloud Console.

- *Tenancy OCID*: **Governance & Administration**, then **Tenancy Details**
- *User OCID*: use the **Profile** button in the upper right corner of the screen and select your username
- *Compartment OCID*: **Identity & Security**, then **Compartments. Select the compartment you plan to use, or create a new one.
- *Region Identifier*: use the **Region Selector** in the top right, and select **Manage Regions**.  Note the Region Identifier of the region you intend to use (typically your home region)

The WebLogic for OCI stack will use a **Vault** and **Secrets** to store the passwords for the WebLogic administartor and the ATP database administrator.  You need to create the following artefacts and note down the OCID's of the resulting secrets :

- Create a Vault: **Identity & Security**, then **Vault**.  Give your vault a name and use the default parameters
- In your vault, create an encyption key: use the default parameters
- In your vault, create a first secret containing the weblogic Administrator password, using the encryption key you just created.  Note down the OCID of the secret you just created
- Repeat the secret creation for the admin password of the database that will be created.  Note down the OCID of the secret.



### Preparing your terraform script parameters

To access the VM's you will be creating, you need a public/private ssh key pair.  Use the below command and accept the default location (.ssh folder).

```
# generate a ssh key pair
ssh-keygen -t rsa -b 4096
```



Edit the file `env.sh` with your favourite editor : vi or nano

You need at least to change the below variables to correspond with your tenancy ID's :

```
export PREFIX=oblg
export TF_VAR_db_password=yourpwd
export TF_VAR_tenancy_ocid=ocid1.tenancy.oc1..aaaaaaaaabcdefghijklm
export TF_VAR_compartment_ocid=ocid1.compartment.oc1..aaaaaaaaabcdefghijklm
export TF_VAR_region=eu-frankfurt-1
export TF_VAR_wls_admin_password_ocid=ocid1.vaultsecret.oc1.eu-frankfurt-1.aaaaaaaaabcdefghijklm
export TF_VAR_atp_db_password_ocid=ocid1.vaultsecret.oc1.eu-frankfurt-1.aaaaaaaaabcdefghijklm
```

- prefix : *must be 4 characters* 
- db password: must be the password (in clear) you also entered in the 2nd secret you created earlier
- you took a note of all other parameters in the preceding steps, copy them from your notebook into this file.



## Step 2. eDelivery Terraform script
This terraform step is called "Edelivery" since it is the name of the site to download Oracle Software.
This step will prepare your environment for the Forms installation, and create a temporary VM called *Build* that we will use to download the Forms installation files.  Below elements are created through a terraform script:

- A Virtual Cloud Network with appropriate subnets, routing rules etc.

- An ATP database to be used for the JRF database

- A shared filesystem that will contain the Forms installation files called

  ` /mnt/software`

- A *Build* Virtual machine to download the Forms installation software from the eDelivery website

Make sure you are in the correct folder, then launch the terraform script :

```
# make sure you are still in the ~/forms_wls/bin directory
./terraform_apply.sh edelivery
```

There result should look like this:

```
Apply complete! Resources: 11 added, 0 changed, 0 destroyed.

Outputs:

autonomous_database_connection_strings = {
  "HIGH" = "adb.eu-frankfurt-1.oraclecloud.com:1522/iizjplwbmwapsig_oblgatp_high.adb.oraclecloud.com"
  "LOW" = "adb.eu-frankfurt-1.oraclecloud.com:1522/iizjplwbmwapsig_oblgatp_low.adb.oraclecloud.com"
  "MEDIUM" = "adb.eu-frankfurt-1.oraclecloud.com:1522/iizjplwbmwapsig_oblgatp_medium.adb.oraclecloud.com"
  "TP" = "adb.eu-frankfurt-1.oraclecloud.com:1522/iizjplwbmwapsig_oblgatp_tp.adb.oraclecloud.com"
  "TPURGENT" = "adb.eu-frankfurt-1.oraclecloud.com:1522/iizjplwbmwapsig_oblgatp_tpurgent.adb.oraclecloud.com"
}
autonomous_database_wallet = oblgatp_wallet.zip
build_public_ip = [
  [
    "130.61.203.62",
  ],
]
mount_target_IPs = [
  "10.0.2.250",
]
```

Errors should be displayed on the Cloud Shell, or you can look them up in logs/terraform_xxx.

The resulting "Public IP" address displayed is the address of the Build machine - you should also be able to see it in your Cloud Console, navigating to the "Compute" overview.

Try to log into the machine :

```
# replace the below IP address with your IP address
ssh opc@130.61.203.62
```

Also note you don't need the Cloud shell to do this.  If you make sure to copy the private ssh key to your desktop you can also ssh directly from the laptop into the Build machine.





## Step 3. Download Forms and dependecies
Open a new browser window and navigate to [edelivery.oracle.com](http://edelivery.oracle.com)

- Sign-in with your Oracle account (*not* your cloud tenancy account!)
- In the search box, change "All categories" to "Release"
- Search and select: REL: Oracle Forms 12.2.1.4.0
- Click *Continue* on the top op the window
- Choose the platform Linux x86-64
- Click *Continue*
- Accept the License Agreement 
- Click *WGET Options*
- Click the button *Download.sh*
- You will get a file called wget.sh

You also need to download 2 patches

- navigate to [support.oracle.com](http://support.oracle.com)

- Select the tab **Patches and Updates**

- In the patch search box, enter the following 2 patch numbers, separated by a comma : 

  `30613424 , 31225296`

- Hit the **Search** button, you should see the result page with 2 patches

- Click on each patch, and select **Download**, then click on the actual file name to start the download



From your laptop, copy these files on the *Build* host created in the previous step, in the correct directories.

- Drag and drop these 3 files from your local download folder onto the Cloud Shell window.  This will copy the files over to the Cloud shell environment inside your browser.

- In the Cloud Shell, copy the script file to the correct location on the *Build* machine: 

```
# Replace the IP address by the IP address of your Build machine !
scp wget.sh opc@130.61.121.213:/mnt/software/edelivery/.
```

- Copy the patches to the correct location: 

```
# Replace the IP address by the IP address of your Build machine !
scp p30613424_122140_Generic.zip p31225296_122140_Generic.zip opc@130.61.121.213:/mnt/software/install/patches/.
```



Now log into the Build machine. 

```
# log in on the Build machine
ssh opc@130.61.121.213
```

On the Build machine, position yourself in the correct folder and run the script

*Attention!* You need to enter 2 parameters:

- the username you used to login on the eDelivery website
- ***2nd parameter with no prompt*** : the password of this user

```
# Go to the edelivery directory
cd /mnt/software/edelivery
sh wget.sh
   SSO User Name: xxx@xxx.com
   your_password (no prompt for the password !!!!!)
```

Next you need to wait 5 to 10 minutes for the files to download.

Once your prompt is back, unzip the files :

```
# Unzip and rename the files
./unzip_edelivery.sh
```

The resulting folder content should look like below:

```
# check result
ls -al
---------------------
drwxr-xr-x. 7 opc opc       8 Nov 13 12:05 .
drwxr-xr-x. 6 opc opc       4 Nov 13 10:24 ..
drwxr-xr-x. 2 opc opc       3 Nov 12 22:41 forms
-rwxr-xr-x. 1 opc opc     596 Nov 10 22:42 unzip_edelivery.sh
-rw-rw-r--. 1 opc opc 1374387 Nov 13 09:37 wgetlog-11-13-20-09:37.log
-rwxr-xr-x. 1 opc opc    2372 Nov 13 09:36 wget.sh
drwxr-xr-x. 2 opc opc       5 Nov 13 09:38 zip
---------------------
```

Now log out of the Build machine, you don't need it anymore at this point.

```
exit
```

This will return your prompt to the Cloud Shell environment.



## Step 4. Run the terraform stack of WLS on OCI

Next you will run the actual WLS on OCI terraform stack script, that has been slightly changed to include the mounting of the shared volume `/mnt/software` containing the Forms software, and the actual installation of the Forms software on the environment.

Run the following command in the Cloud Shell:

```
# make sure you are still positioned in the forms_wls/bin directory
./terraform_apply.sh wls_stack
```

The output will look like below:
```
Apply complete! Resources: 25 added, 0 changed, 0 destroyed.

Outputs:

Bastion_Instance = ""
FORM_URL = https://129.159.198.67/forms/frmservlet?config=dept
Fusion_Middleware_Control_Console = https://130.61.188.112:7002/em
Is_VCN_Peered = false
Listing_Version = 21.1.3-210316164607

Load_Balancer_Ip = [
  "129.159.198.67",
]
Loadbalancer_Subnets_Id = [
  "ocid1.subnet.oc1.eu-frankfurt-1.aaaaaa",
]
Provisioning_Status = Asynchronous provisioning is enabled. Connect to each compute instance and confirm that the file /u01/data/domains/jltf_domain/provisioningCompletedMarker exists. Details are found in the file /u01/logs/provisioning.log.
Sample_Application = 
Sample_Application_protected_by_IDCS = 
Virtual_Cloud_Network_CIDR = 
Virtual_Cloud_Network_Id = ocid1.vcn.oc1.eu-frankfurt-1.amaaaaaa
WebLogic_Instances = "{       Instance Id:ocid1.instance.oc1.eu-frankfurt-1.anthel,       Instance name:jltf-wls-0,       Availability Domain:ezas:EU-FRANKFURT-1-AD-1,       Instance shape:VM.Standard.E2.2,       Private IP:10.0.0.153,       Public IP:130.61.188.112       }"
WebLogic_Server_Administration_Console = https://130.61.188.112:7002/console
WebLogic_Subnet_Id = [
  "ocid1.subnet.oc1.eu-frankfurt-1.aaaaaaaa",
]
WebLogic_Version = 12.2.1.4 Suite Edition (JRF with ATP DB)
```

The script will signal it it finished in approx. 5 minutes, but the actual installation of WLS and Forms only starts at that point as a init script on the VM machine that was just created.  It can take up to 40 minutes for the whole installation to be finished!



## Step 5: Verify and Test
To make sure the installation has finished correctly, ssh into the VM that was just created.  You can see the public IP address of the WebLogic instance in the above output: note the *public IP* of the instance.

```
ssh opc@<ip_adress_of_WLS_VM>
```

Sequence of Log files to check:

- Bootstrap log in /u01/logs :

  ```
  tail -20 /u01/logs/bootstrap.log
  <2021-05-05 18:58:08.668713408>  /dev/sdb         50G   53M   47G   1% /u01/app
  <2021-05-05 18:58:08.669662377>  /dev/sdc         50G   53M   47G   1% /u01/data
  <2021-05-05 18:58:08.721461644>  Added entry for /u01/app in /etc/fstab
  <2021-05-05 18:58:08.771218866>  Added entry for /u01/data in /etc/fstab
  <2021-05-05 18:59:16.872643342>  Unzipping zip file [/u01/zips/jcs/FMW/12.2.1.4.0/fmiddleware.zip] to destination directory [/]
  <2021-05-05 18:59:16.873899858>  executing: unzip /u01/zips/jcs/FMW/12.2.1.4.0/fmiddleware.zip -d /
  <2021-05-05 18:59:16.875006447>  Unzipping zip file [/u01/zips/jcs/JDK8.0/jdk.zip] to destination directory [/]
  <2021-05-05 18:59:16.876220542>  executing: unzip /u01/zips/jcs/JDK8.0/jdk.zip -d /
  <2021-05-05 18:59:16.877342972>  executing: python /opt/scripts/oci_api_utils.py download_atp_wallet ocid1.autonomousdatabase.oc1.eu-frankfurt-1.abtheljsskjfklit2xxb4tfyp7zg4qwrtefuivbjnepb6y4bqdslecahowla
  <2021-05-05 18:59:16.878472116>  Found provisioning start marker for ATP [/u01/provStartMarker]
  <2021-05-05 18:59:16.879611868>  Unzipping zip file [/tmp/atp_wallet.zip] to destination directory [/u01/app/oracle/private/wallet]
  <2021-05-05 18:59:16.880680515>  executing: unzip /tmp/atp_wallet.zip -d /u01/app/oracle/private/wallet
  <2021-05-05 18:59:16.881774290>  Unpacking archive status [fmiddleware_status=True, jdk_status=True, atp_status=True]
  <2021-05-05 18:59:16.882847816>  Unpacked all archives successfully before provisioning.
  <2021-05-05 18:59:16.887392441>  Executing move_jdk script
  <2021-05-05 18:59:16.909624143>  Executed mov_jdk script with exit code [126]
  <2021-05-05 18:59:20.477489468>  Executing validator script
  <2021-05-05 18:59:21.168698372>  Executed validator script with exit code [0]
  <2021-05-05 18:59:21.170309007>  Executing check_versions script
  <2021-05-05 18:59:21.467849815>  Executed check_versions script with exit code [0]
  ```

  You should see the `Executed check_versions script with exit code [0]` on the last line

- File `part1_root_install.log` in home directory /home/opc:

  ```
  tail -20 part1_root_install.log 
  
  Last Successful login time: Tue May 04 2021 10:23:38 +00:00
  
  Connected to:
  Oracle Database 19c Enterprise Edition Release 19.0.0.0.0 - Production
  
  old   2:   filt varchar2(255) := lower('&1%');
  new   2:   filt varchar2(255) := lower('SP1620241711%');
  FILTER: sp1620241711%
  
  PL/SQL procedure successfully completed.
  
  Disconnected from Oracle Database 19c Enterprise Edition Release 19.0.0.0.0 - Production
  
  Created config file [/home/opc/.patchutils/config]
  -----------------------------------------------------------------------------
  
  Wed May  5 19:08:32 GMT 2021
  Time since start=545 sec
  
  Time since last time=10 sec
  -----------------------------------------------------------------------------
  
  ======== DONE ========
  ```

  You should see `======== DONE ========` on the last line.

- Repository Creation Utility directory and associated logs: check the directory /u01/logs/RCUxxxxx has been created:

  ```
  ll /u01/logs/
  total 24
  -rwxrwxr-x. 1 oracle oracle 10852 May  5 19:08 bootstrap.log
  -rwxrwxr-x. 1 oracle oracle 11495 May  5 19:09 provisioning.log
  drwxrwxr-x. 3 oracle oracle    18 May  5 19:09 RCU2021-05-05_19-09_1056300503
  ```

  The content of the underlying logs folder is only accesible by user oracle, so you need to use sudo to view the content:

  ```
  sudo ls -l /u01/logs/RCU2021-05-05_19-09_1056300503/logs/
  total 44
  -rw-r-----. 1 oracle oracle   575 May  5 19:09 logger8384231280296235038.properties
  -rw-r-----. 1 oracle oracle 40429 May  5 19:13 rcu.log
  -rw-rw-r--. 1 oracle oracle     0 May  5 19:09 rcu.log.lck
  ```

- Second step of the Forms install : check the file `part2_oracle_config.log` in the home directory:

  ```
  tail part2_oracle_config.log
  Time since start=17 sec
  
  Time since last time=17 sec
  -----------------------------------------------------------------------------
  
  /mnt/software/install/bin/part2_oracle_config.sh: line 68: [: ==: unary operator expected
  -----------------------------------------------------------------------------
  
  Wed May  5 19:26:36 GMT 2021
  Time since start=17 sec
  
  Time since last time=0 sec
  -----------------------------------------------------------------------------
  
  ======== DONE ========
  ```

  

Once you are sure everything has been installed without errors, you can check if the test form launches correctly.

- Best use firefox for this test

Navigate to the URL mentionned in the output : 

```
FORM_URL = https://129.159.198.67/forms/frmservlet?config=dept
```

You will need to accept a number of exceptions

- "Warning: Potential security Risk Ahead" : click **Advanced**
- Now hit the button **Accept the Risk and Continue**
- Accept to open the file **frmservlet** with **Java Web Start**
- A popup with **Do you want to Continue?**: hit **Continue**
- Question **Do you want to run this application? OracleForms** : click **Run**

The test form should now appear !





## Some Optional operations
### Rebuild the WLS_STACK based on a new version of WLS on OCI stack.
You need this step when you want/need to install Forms based a newer version of the WLS stack on OCI. For example to get the last version of the JDK and WLS CPU/PSU patches.

* Create a new WLS stack on OCI. When created in resource manager. Download the terraform script. (zip file)

* Rename the file `wls_stack.zip` and place it in directory `WLS_STACK`

* Run below command: 

  ```
  bin/wls_stack_build/terraform_wls_stack_build.sh
  ```

  





## Additional notes
- To restart the domain:
  /opt/scripts/restart_domain.sh
- Tp recreate the domain when the wls instance is created:
  - Drop the domain directory in /u01/data/domain/xxxx
  - Check what terraform/wls_stack/compute/instance/bootstrap does
  - In short, often, it is:
```
    cd /opt/scripts/
    ./terraform_init.sh
    sudo /mnt/software/install_bin/install_part2.sh
```