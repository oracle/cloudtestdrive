![](../../../common/images/customer.logo2.png)

# Reseting your environment after the DR labs using scripts for free trial accounts

Firstly congratulations on completing your lab, we hope that you have found it informative and useful.

This module walks you through the process of resetting your tenancy after completing the DR lab **should you wish to do so.**

## Do I need to reset my environment ?

You may be planning on re-using your tenancy for another lab. ALl tenancies have limits on the resources they can use, for example a free trial tenancy limits you to one OKE cluster (in this lab you used an OKE cluster and also a K3S cluster), so if you were going to be doing a completely different lab which requires an OKE cluster then you may want to destroy the one you used for this lab (or of course re-use it)

## I've decided I want to reset my tenancy

The script described here is an  "all in one" script that will reset everything it can after you've finished your lab. It is designed to be used in a Free trial account, or an account where you have full administrative rights, are are running in your home region, **and** used the setup scripts. If you are in a different situation,  or want more precise control (for example you only want to reset the kubernetes microservices, but not destroy the OKE cluster) then please look at the individual scripts in the `$HOME/helidon-kubernetes/setup` directories (but be aware you will have to destroy resources in the reverse of the order they were setup).

**IMPORTANT** These scripts can take a while to run mostly because they trigger the creation of a number of activities that take time. You are running the scripts in the OCI Cloud shell which has a 20 min timeout if it doesn't get any user input, in some cases the script may not complete before the process completes. To avoid this every few minutes just click in the cloud shell and press return. If you forget and the cloud shell times out then reconnect, switch to the directory and re-run the script as described below. The script tries to keep track of what has already been done and not to duplicate completed work.

<details><summary><b>What does this script actually do ?</b></summary> 

This script will perform the following tasks, where possible you have already used the setup script to do a task then the resource will be re-used.

It will remove the following DR services lab specific content by :"
  - Delete the policies based on the dynamic groups which allow the creationof the K3S cluster"
  - Delete the dynamic groups used to identify various K3S cluster service elements"
  - Delete the ssh key to use when connecting to the OCI code repo (note that the $HOME/.ssh/config file will not be modified)"
  - Schedule deletion of the Vault secrets, the master signing key and the Vault"

It will then tidy up the Kubernetes clusters, for both the clusters :
  - It will attempt to delete any namespaces setup in the kubernetes core (ingress-nginx)
  - Delete the microservices images and repos in OCIR
  - Delete the auth token created to access OCIR (it will not logout of docker though)
  - Reset the Kubernetes clusters to it's defult state by deleting the microservices and related objects
  - Reset the Kubernetes configuration files (ingress rules, config info etc.)
  - Terminate the Kubernetes clusters
  - Terminate the database and destroy test data
  - Attempt to remove your working a compartment (this will fail if it contains resources you've created)
  - Remove gathered basic information such as your initials
  - Remove the downloaded step certificate manager and certificates it's generated
  
Note that if a resource was reused (for example the database) then it will not delete those resources.

In some situations the compartment cannot be deleted, this is because some resources are destroyed in the background, of in some cases are scheduled for later deletion, and a compartment cannot be deleted while it contains existing resources (even if they are going through their deletion process)

</details>

**Important** The current script cannot delete objects you created them manually. (The script does not have the identifiers for them). While you do not have to delete these if you want to you will have to do so manually. To do so remove elements the following in order

  You will need to be in the right directory to run the scripts.
  
  - In the OCI Cloud shell type :
  
  ```bash
  <copy>cd $HOME/helidon-kubernetes/setup/lab-specific</copy>
  ```
  
  
  To run the main script (this will call the other scripts for you in the right order)
  
  - In the OCI Cloud shell type
  
  ```bash
  <copy>bash ./kubeflow-kubernetes-lab-destroy.sh</copy>
  ```
  
  The script will ask for a few core bits of information before continuing.
  
  ```
  
Configuring location information
Welcome the the Kubeflow in Kubernrtes specific lab destroy script.
Checking region
You are in your home region and this script will continue
Are you running in a free trial account, or in an account where you have full administrator rights ?
```
  
  First it asks if you are in a free trial or and administrator of your tenancy, this is to make sure you have the appropriate permissions. Assuming you are in a free trial or are and admin using enter `y` and press enter to continue.
  
  ```
At completion this will have removed the resources created by the setup scripts, however any resources that
you configured manually (for example your devops project) will remain

Do you want to proceed ?
```

  The script now asks for your confirmation that you want to destroy these resources, assuming you do enter `y`, but of course if you enter `n` the script will stop and nothing will have been destroyed.

```
Do you want to use the automatic defaults ?
```

  Next the script asks you if you want to use the automatic defaults, if you do so the case the script will automatically assume the answer to any yes / no question is `y` Unless you have specific reasons to retain resources enter `y` as this will significantly speed up the setup process as the script will not have to wait for your inputs.
  
  Assuming you have entered `y` (the recommended choice for free trial users) the script will now run to completion, if you have chosen the automatic defaults you will not need to provide further input (if you chose not to use the automatic defaults please read the various prompts and answer accordingly, in general you should be able to answer `y` to every yes  no question if you are running in a free trial). If there is a problem then the script will stop at that point.
  
## What next ?

The script should have run to completion. It will have reset the environment created for this lab.

## Acknowledgements

* **Author** - Tim Graves, Cloud Native Solutions Architect, OCI Strategic Engagements Team, Developer Lighthouse program
* **Last Updated By** - Tim Graves, September 2022