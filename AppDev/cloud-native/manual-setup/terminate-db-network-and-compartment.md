![](../../../common/images/customer.logo2.png)

# Releasing the database, network and compartment resources

We've reached the end of the labs, and if you wish you can reclaim the resources by deleting the database, 

If you are running the lab in an Oracle provided tenancy (e.g. live labs or cloud test drive) then these resources will be automatically terminated shortly after the completion of the lab session.

## Introduction

This is an optional module

**Estimated module duration** 5 mins.

### Objectives

If you chose to follow the instructions this optional module will guide you through the process of terminating the resources you have been using.

### Prerequisites

**If** you decide to do this then you should have finished the all of the lab modules (Helidoon, Docker, Kubernetes etc. and any optional modules in those) Once these resources have been terminated you will not be able to recover them and will have to do the lab again to re-create them.

## Step 1: Terminating the database

**DO NOT** do this step unless you are **certain** that you have finished with the database, and in particular have decided they you **will not** be doing the associated Kubernetes labs (which also use the database)

  1. Click the `Hamburger` menu, then in the `Oracle Database` section click the `Autonomous Transaction Processing` option.

  2. Make sure you are in the `CTDOKE` compartment (or the one you chose to use) Check this using the compartment option on the left of the page.
  
  3. Click on the name of the database in the list. **Make sure it's your database**
  
  4. Click the `More Actions` button and in the resulting menu chose the `Terminate` option
  
  5. In the confirmation popup you will nedd to type the name of the database. This will be displayed in the popup, double check you are deleting **your** database **not** someone elses.
  
  6. Click the `Terminate Autonomous Database` button. In the `Xore Infrastructure` section chose `Networking` then 
  
OCI will then start the termination process. This can take a short while. If you change your mind it's now to late.

## Step 2: Terminating the Virtual Cloud Network

Do not do this step if you are running in an Oracle provided shared tenancy (e.g. live labs, cloud test drive)

If you are in a shared tenancy **make sure that no one else is still doing the lab.**

You only be able to complete this step if you have terminated **all** of the resources using the VCN, this includes the developer VM, database, Kubernetes cluster etc.

  1. Click the `Hamburger` menu, Under the `Core Infrastructure` section chose `Networking` then `Virtual Cloud Networks`

  2. Make sure you are in the `CTDOKE` compartment (or the one you chose to use) Check this using the compartment option on the left of the page.
  
  3. Click on the name of **your** VCN in the list, be sure it's the one you created. 
  
  4. In the details page for **your** VNC (** check it's yours** and that no one else is using it, or there will be very unhappy people) click the `Terminate` button
  
  5. A list or resources using thre VCN will be displayed, check that this only includes Subnets, Security lists, Route tables and gateways. If other resoruces are listed you will be unable to terminate the VCN
  
  6. Click the `Terminate all` button
  
OCI will then start the termination process. This can take a short while. If you change your mind it's now to late.

  7. Once the resources are terminated then click the `Close` button
  
## Step 3: Terminating the compartment

Do not do this step if you are running in an Oracle provided shared tenancy (e.g. live labs, cloud test drive)

If you are running in a paid tenancy your tenancy admin may have created the compartment for you, in which case they will have to delete it.

If you are in a shared tenancy **make sure that no one else is still doing the lab.**

  1. Click the `Hamburger` menu, scroll down to the `Governance and administration` section, then chose `Identity` -> `Compartments`
  
  2. Locate and click the `CTKOKE` compartment in the list (or the name of your compartment if you chose a different one)
  
  3. In the compartment details page click the `Delete` button
  
  4. In the popup **double check** you are deleting the right compartment 
  
  5. Click the `Delete` button, this will only succeed if you have deleted all other resources in it.
  
  6. In the confirmation popup confirm that you want to delete the compartment.
  
This will only succeed if you have deleted all other resources in it.
  
## What's next

That's all folks, you're finished. We hope that you have enjoyed doing the labs.

## Acknowledgements

* **Author** - Tim Graves, Cloud Native Solutions Architect, EMEA OCI Centre of Excellence
* **Last Updated By** - Tim Graves, November 2020
