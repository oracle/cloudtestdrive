![](../../../common/images/customer.logo2.png)

# Setting up the Kubeflow lab environment using scripts for free trial accounts

This module walks you through the process of setting up the core OCI features and Kubernrtes needed to run a lab that let's you run the DR Kubernetes lab.

To speed things up for people who are just starting with this set of labs (or deleted their previously created environment) we have provided some scripts that you can use to set things up quickly, consistently and with less opportunity for typos.

## Task 1: Downloading the latest scripts

There are a number of scripts that we have created for this lab to make life easier, for the purposes of these instructions we are assuming that you have not previously downloaded the scripts. If you think you may have than open the expansion to check and if needed get the latest version.

Note that if you have just created a free-trial account for a lab then you have **not** downloaded the scripts and will need to follow the steps in **Task 1a**

If you have previously downloaded those then you should ensure you have the latest version, to do this follow the steps in **Task 1b**.

<details><summary><b>How to check if you have already downloaded the scripts ?</b></summary> 


If you are not sure if you have downloaded the latest version then you can check

  - In the OCI Cloud shell type 
  
  ```bash
  <copy>ls $HOME/helidon-kubernetes</copy>
  ```

If you get output like this then you need to download the scripts, follow the process in **Task 1a**

```
ls: cannot access /home/tim_graves/helidon-kubernetes: No such file or directory
```

If you get output similar to this (the file names and count may vary slightly as the lab evolves) then you have downloaded the scripts previously, but you should get the latest versions, please follow the steps in **Task 1b**

```
base-kubernetes          configurations       deploy.sh   monitoring-kubernetes  README.md     servicesClusterIP.yaml  stockmanager-deployment.yaml  undeploy.sh
cloud-native-kubernetes  create-test-data.sh  management  README                 service-mesh  setup                   storefront-deployment.yaml    zipkin-deployment.yaml
```
</details>

### Task 1a: Downloading the scripts

We will use git to download the scripts

  1. Open the OCI Cloud Shell

  2. Make sure you are in the top level directory
  
  ```bash
  <copy>cd $HOME</copy>
  ```
  
  3. Clone the repository with all scripts from github into your OCI Cloud Shell environment
  
  ```bash
  <copy>git clone https://github.com/CloudTestDrive/helidon-kubernetes.git</copy>
  ```
  
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
  
  ```bash
  <copy>cd $HOME/helidon-kubernetes</copy>
  ```
  
  3. Use git to get the latest updates
  
  ```bash
  <copy>git pull</copy>
  ```

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

## Task 2: Running the scripts

We have various levels of scripts, but the basic principle is to setup the lab environment for you.

The script described here is an  "all in one" script that will set things up ready for the lab you are about to start. It is designed to be used in a Free trial account, or an account where you have full administrative rights, can create compartments in the tenancy root and are OK with our naming scheme.

**IMPORTANT** These scripts can take a while to run mostly because they trigger the creation of a number of activities that take time. You are running the scripts in the OCI Cloud shell which has a 20 min timeout if it doesn't get any user input, in some cases the script may not complete before the process completes. To avoid this every few minutes just click in the cloud shell and press return. If you forget and the cloud shell times out then reconnect, switch to the script directory and re-run the script as described below. The script tries to keep track of what has already been done and not to duplicate completed work.

<details><summary><b>What does this script actually do ?</b></summary> 

This script will perform the following tasks, where possible if you have already used the setup script to do a task (and not deleted the resources) then the resource will be re-used.

Firstly setup a Kubernetes environment for you to deploy into :
  - Download the step certificate tools and create a self signed root cert
  - Gather basic information (your initials)
  - Create a compartment for you to work in
  - Create and configure a database for you to use
  - Setup dynamic groups and polices needed to create the K3S cluster
  - Create Kubernetes clusters (OKE and K3S)
  - Create an auth token to use when talking to OCIR
  - Create OCIR repos for the storefront and stockmanager microservices
  - Build, package and upload to OCIR the images you will use
  - Setup YAML files for image locations
  - Setup Helm chart repos
  - Start core Kubernetes services (Ingress contrtoller, Kubernetes dashboard) in both clusters
  - Create service certificates and associated secrets based on Ingress load balancer IP fo both clusters
  - Create ingress rules, secrets and config maps in both clusters based on the above info
  - Start microservices (logger, storefront, stockmanager and zipkin) in both clusters
  - Upload test data to the database
  
</details>

<details><summary><b>Non free trial / Running some where other than the tenancy root compartment ?</b></summary> 

The scripts will create a compartment (it's default name is CTDOKE) in the root of your tenancy. All of the lab work will be done within that compartment. 

If you are in a commercial or non free trial tenancy then you may wish to create the CTDOKE compartment somewhere other than the root of the tenancy (especially if there are multiple folks doing the same lab in the same tenancy)

To do this locate the OCID of the compartment that will be the **PARENT** compartment - i.e. the compartment within which to create the lab compartment

edit (or create) the file `$HOME/hk8sLabsSettings` Add a line of the form `COMPARTMENT_PARENT_OCID=ocid1.compartment.oc1..aaabdtgaeasd342rer463ydquwlln2xunedvtpfixb4hl6wyyvorz4m7sd6xv4k6q` - replace the example OCID for the compartment with the OCID of the compartment you want to use as the parent)

Save the file.

</details>

  First you will need to be in the right directory to run the scripts.
  
  - In the OCI Cloud shell type :
  
  ```bash
  <copy>cd $HOME/helidon-kubernetes/setup/lab-specific</copy>
  ```
  
  
  To run the main script (this will call the other scripts for you in the right order)
  
  - In the OCI Cloud shell type
  
  ```bash
  <copy>bash ./kubeflow-kubernetes-lab-setup.sh</copy>
  ```
  
  The script will ask for a few core bits of information before continuing.
  
  ```
  
Configuring location information
Welcome to the Kubeflow in Kubernrtes specific lab setup script.
You are in your home region and this script will continue
Are you running in a free trial account, or in an account where you have full administrator rights ?
```
  
  First it asks if you are in a free trial or and administrator of your tenancy, this is to make sure you have the appropriate permissions. Assuming you are in a free trial or are and admin using enter `y` and press enter to continue.
  
  ```
This script will:
  Download the step certificate tools and create a self signed root cert
  Gather basic information (your initials)
  Create a compartment for you to work in
  Create a Kubernetes cluster

This script can in most cases automatically apply a sensible default answer to questions (for example the name used
for the database or the compartment location). Alternatively you can specify answers manually which would let you
chose customise names and locations.
Note that for some inputs (e.g. entering your initials) it is not possible to make an automatic guess, in those cases
you will still be prompted for input.
Do you want to use the automatic defaults ?
```

  Next the script asks you if you want to use the automatic defaults, if you do so the case the script will automatically assume the answer to any yes / no question is `y` If you are in a free trial account it's safe to enter `y` as this will significantly speed up the setup process as the script will not have to wait for your inputs - as mentioned above though you will have to interact with the Cloud Shell occasionally while the script is running to prevent it timing out and the scripts being aborted.
    
  ```
  This script can perform certain setup operations in parallel, doing so will speed
the overall process up but you won't see the detailed output unless you look at the
log files (they are in /home/tim_graves/setup-logs)
If you want to follow their progress as script is running (don't interrupt it!) you'll
need to do something like
tail -f <log name>
in a separate cloud shell while this script is running)
Do you want to run the setup in parallel where possible ?
```
  
  If you chose to use the automatic defaults (and only if you did) then you will be asked it you want to do some setup operations in  parallel. This can significantly reduce the time taken to go through the setup steps, though it does mean that the output from those setup stages is written to log files (in `$HOME/setup-logs`) rather than be displayed. Unless you have a particular desire to watch the setup sequence enter `y` at the prompt which will save around 25 - 30 minutes of time while the script sets things up.
  
  The script will perform some actions like downloading the certificate tools, and checking resource availability, this takes about one or two minutes.
  
  ```
  Creating new settings information
Please can you enter your initials - use lower case a-z only and no spaces, for example if your name is John Smith your initials would be js. This will be used to do things like name the database
  ```
  
  Now you may be asked to enter your initials, these should be in lower case and the letters a-z **only**. Enter your initials and press enter. If you enter invalid initials (i.e. any characters other than the lower case letters a-z) you will be asked to enter the initials again

  The script will now run, if you have chosen the automatic defaults you will not need to provide further input (if you chose not to use the automatic defaults please read the various prompts and answer accordingly, in general you should be able to answer `y` to every yes  no question if you are running in a free trial). If there is a problem then the script will stop at that point.
  
## What next ?

The script should have run to completion. It will have setup the environment needed for this lab. Please **skip the remaining setup modules** (they are provided for situations where more precise and non standard configurations are needed) and go direct to the lab module **Part 1** in the modules navigation.

The script will have created two clusters and installed services in them, these clusters will be added to the kubeconfig file under the context names `one` and `two` you can see details of the services in these clusters (e.g. the external LB of the ingress controller, kubernetes dashboard URL and login token etc.) in the info files that are created - these are in your home directory and are of the form `clusterInfo.<context name>` These files also include examples (with the correct IP addresses) to let you go direct to the service endpoints.

There are additional files created, the `clusterSettings.<context name>` file is a script and sets up the NAMESPACE (to the namespace the script setup the services in) and EXTERNAL_IP (of the ingress controller load balancer) variables in case you need to use them in scripts. The `clusterNetwork.<context name>` file is also created which can be sourced by scripts and contains environment variables for the clusters VCN OCID, Load balancer and worker subnet OCID's, and the OCID's of the public (LB) network security group - for some clusters it also provides the NSG of the workers subnet as well.



## Acknowledgements

* **Author** - Tim Graves, Cloud Native Solutions Architect, OCI Strategic Engagements Team, Developer Lighthouse program
* **Last Updated By** - Tim Graves, July 2022