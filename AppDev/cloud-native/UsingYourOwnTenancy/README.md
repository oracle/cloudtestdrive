[Go to Helidon for Cloud Native Page](../Helidon-labs.md)

![](../../../common/images/customer.logo2.png)

# Running the Helidon labs in your own tenancy

In some cases you may wish to run the Helidon labs in your own tenancy, this might be a **Oracle Free Tier** account or your own organization tenancy. This document and the ones it connects to show you how to configure your own tenancy.

Please note that you will still need details from your instructor on the location of the VM image export and other details. 

This document *currently* only covers setting the environment up for runnign the Helidon labs as part of your tenancy. You won't be able to use the VM image for the Docker or Kubernetes sections of the labs. This ie because the Helidon section (apart form the database) is mostly self contained. We are working on updating the instructions for the other labs so they are no longer dependent on the specific cloud configuration in the virtual machine, but as they involve a lot of interactions with the cloud configuration that's currently still in progress.

There are three steps you need fo follow

## 1/ Import the image and create the client VM
To import the client VM image and create a VM instance follow [these instructions](LoadClientVMInYourTenancy.md)

## 2/ Create the database and a user

To create a database instance and setup a user follow [these instructions](CreateATPDatabaseAndSetupUser.md)

## 3/ Load the database credentials into the VM

To download the database wallet and install it in the VM follow [these instructions](GetYourATPDatabaseWalletFile.md)

## 4/ Do the Helidon labs 

You can now start [The helidon labs](../README.md)