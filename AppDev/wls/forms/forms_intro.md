# A simple automation script for Oracle Forms on WebLogic for OCI pay-as-you-go

## Summary

Since a few months Oracle has included the licenses entitlement of Internet Application Server EE (iAS EE) as part of the WebLogic Suite for OCI pay-as-you-go subscription. This means **you can now run Oracle Forms** without the need to purchase traditional licenses, and simply **use the WLS Suite for OCI UCM edition** of the Marketplace service, paying for your Forms per hour and per ocpu.  This gives you increased flexibility: you can scale up and down your environment as required, or shut it down completely, and only pay for the hours you were running the service.

From a license perspective this solved the problem, but technically you need to install the Forms environment manually into the VM's of your WLS setup.  

This article will explain an example automation based on an extension of the standard WebLogic Marketplace terraform script, only requiring you to manually obtain the Forms installation download script from the edelivery website.  Please note this is just an example, **not** an officially Oracle supported procedure.  To be adapted to fit your specific needs.

A big thanks to Marc Gueury who wrote the initial version of this script !

## Overview of the automation steps

**Step 1: Prepare your environment**

As for every WebLogic on OCI installation there are a few preparation steps needed before you can initiate the creation of a new environment.  We'll be using the Cloud Console and the Cloud shell for this, so no need to install anything on your laptop.

On the cloud console :

- Collect a few OCID's of your tenancy: tenancy OCID, Compartment OCID and the region identifier
- To manage the passwords of the weblogic and database administrator, create a vault with an encryption key to hold two secrets containing these passwords

Next you will use the Cloud Shell 

- to download the [automation scripts](https://github.com/CloudTestDrive/forms_wls.git) from GitHub,
- to create a ssh key pair to access your VM's
- edit the script `env.sh` to include the OCID's of the above collected objects.  These will be used to pass the correct parameters for your tenancy to terraform stack.



**Step 2: Run the Edelivery terraform script to create initial artefacts:**

In a first script, a temporary **Build** VM will be created, that will be used to download and prepare the Forms installation files.  This setup will be done on a **shared filesystem**, that will later be mounted on each WLS instance that is part of the cluster.

Apart from the Build VM, the script will also create the necessary **Virtual Network** and an **Autonomous Database** to be used for the Forms installation RCU.  The setup of these elements is just provided as an example, you might want to customize these to fit your needs.



**Step 3: Download and prepare the Forms software** 

Once your Build VM is up and running, you need to obtain the Forms Installation package download script from the Oracle edelivery websites, as well as 2 patches to be obtained from the Oracle Support website.

Copy over these files to the Build VM and run the download script to obtain the binaries and prepare them on the shared file system.



**Step 4: Run the WebLogic Stack terraform script**

Now you are ready to run the actual WebLogic for OCI automation script.  This script has been complemented with an extra step to include the mounting of the shared file system we prepared in the previous step, and to execute the actual installation of the Forms.

The creation of the WLS environment is done in 2 distinct steps: 

- First the creation of all the OCI objects, like the VM's, the loadbalancers, policies etc.
- Next a cloud_init script is used to launch the actual creation of the WLS domain on each virtual machine.  

It's in this second part that the extra step to install Forms has been included.



**Step 5: Validate you can access a test Form running on the installation**

Once the installation has finished, you can try to access a test form that has been deployed on the server.

In case something went wrong, all the steps generate extensive log files, so you can easily debug where a possible issue has occurred, and what the cause of the problem might be.



You can find the detailed instructions to execute this installation on the [next page of the tutorial](https://oracle.github.io/cloudtestdrive/AppDev/wls/forms/?lab=creating-forms-environment)



## Rebuild the Forms automation based on a new version of WLS on OCI stack.

The example script provided is based on the WebLogic Marketplace automation version available at the time of creation of the tutorial (March 2021).  As this script is updated regularly, you might want to rebase your Forms automation to be based on the latest version.  

A script is provided to modify a freshly downloaded version of the standard OCI Marketplace script to include the required steps to launch the Forms installation at the end of the process.

One of the key drivers is the use of newer images of the the WLS VM Image, with newer patch sets or higher versions of the JDK.