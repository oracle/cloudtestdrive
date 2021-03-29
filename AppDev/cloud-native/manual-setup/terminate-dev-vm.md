![](../../../common/images/customer.logo2.png)

# Finished with the developer virtual machine

This is an **optional** step, only follow it if you are sure you no longer want to use the developer VM.

We've finished the steps using the developer virtual machine now. You can of course leave it and the database running, or if you prefer you can delete it. If you are running this in a Oracle tenancy (e.g. Live labs or the cloud test drive) then these resources will be automatically deleted shortly after the labs finish, so in that case you do not need to do anything unless you chose to export the Eclipse projects for your later use.

## Introduction

This is an optional module

**Estimated module duration** 5 mins.

### Objectives

If you chose to follow the instructions this optional module will guide you through the process of terminating the resources you have been using.

### Prerequisites

**If** you decide to do this then you should have finished the Helidon and Docker lab modules you have chosen to do. Once you delete these resources you will not be able to recover them except by doing the lab again.

## Step 1: Saving your Eclipse projects

This is an optional step.

If you want to you can export the eclipse projects for use in your own environment. The simplest approach is to use Eclipse to export them as a zip file. 

  1. In the Eclipse menu do `File` -> `Export`, then Expand the `General` tab and select the `Archive file` option.

  2. Select the projects you wish to export with the project tick boxes on the left.

  3. It's not required, but to reduce the size of the resulting file we recommend removing the compiled classes and libraries (Maven will re-create them for you in your environment) To do this expand each of the projects you wish to export, then for each project Uncheck the `target` folder - this will cause the tickbox for the top level project to become a `-` instead of a tick.

  4. Use the Browse option to Navigate to the Desktop
  
  5. At the top of the Browse windo enter a suitable name, for example `Helidon-labs.zip` 
  
  6. Click `Save` to close the Browse popup. 
  
  7. Click the `Finish` button to export the data
  
  8. Use the web email client from your email provider to email the exported file. Please remember that this is a zip file, so chose an address where you can receive it as some email services will block zip files. We advise that you check the receipt of the email **before** you destroy the virtual machine.
  
## Step 2: Terminating the virtual machine

This will destroy the virtual machine you have been using for development, and all work done within it. Be sure you want to do this!

  1. Log in to your Oracle Cloud account in the web browser **on your computer** not the one in the virtual machine.
  
  2. Click the `Hamburger` menu, then in the `Core Infrastructure` section navigate to `Compute` -> `Instances`.
  
  3. Make sure you are in the `CTDOKE` compartment (chose this on the left)
  
  4. Locate **your** virtual machine in the list, if you are using a shared tenancy, for example a company paid tenancy then **double check** that you have chosen the right instance
  
  5. Click the name of **your** virtual machine in the list, this will take you to the instance page for the VM
  
  6. Double check that this is the instance page for **your** VM, best way to do this is to check the public IP address vs the one you've been using for VNC.
  
  7. Having made sure that this is **your** VM (and remember, if it's not someone is going to be extremely cross with you) click the `More Actions` button, and in the resulting drop down chose the `Terminate` option
 
  8. IN the popup **confirm** that the name is the name you used (check your initials) and if you are **absolutley** sure check the `Permenantly delete the attached boot volume` check box, then the `Terminate instance` button
  
OCI will then start the termination process. This can take a short while. If you change your mind it's now to late.

## What's next

Depending on the modules you have done you may wish to also delete the Kubernetes cluster and the database, network resources and compartment.

## Acknowledgements

* **Author** - Tim Graves, Cloud Native Solutions Architect, EMEA OCI Centre of Excellence
* **Last Updated By** - Tim Graves, November 2020

