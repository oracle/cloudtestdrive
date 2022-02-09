![](../../../common/images/customer.logo2.png)

# Setting up the OCI container images using scripts

If you have already created the container images in a previous Kubernetes lab and not deleted them you can skip this module.

**IMPORTANT** You must have setup a compartment, database and have configured your initials and extracted the user info

## Task 1: Downloading the latest scripts

There are a number of scripts that we have created for this lab to make life easier, if you have previously downloaded those recently (in the last few hours) then you can skip this Task and go to task 2. If you downloaded them longer ago then you should ensure you have the latest version, if you haven't downloaded them then you will need to do so.

If you have recently downloaded the scripts then please jump to **Task 2**

If you are not sure if you have downloaded the latest version then you can check

  - In the OCI Cloud shell type 
  
  - `ls $HOME/helidon-kubernetes`

If you get output like this then you need to download the scripts, follow the process in **Task 1a**

```
ls: cannot access /home/tim_graves/helidon-kubernetes: No such file or directory
```

If you get output similar to this (the file names and count may vary slightly as the lab evolves) then you have downloaded the scripts previously, but you should get the latest versions, please follow the steps in **Task 1b**

```
base-kubernetes          configurations       deploy.sh   monitoring-kubernetes  README.md     servicesClusterIP.yaml  stockmanager-deployment.yaml  undeploy.sh
cloud-native-kubernetes  create-test-data.sh  management  README                 service-mesh  setup                   storefront-deployment.yaml    zipkin-deployment.yaml
```

### Task 1a: Downloading the scripts

We will use git to download the scripts

  1. Open the OCI Cloud Shell

  2. Make sure you are in the top level directory
  
  - `cd $HOME`
  
  3. Clone the repository with all scripts from github into your OCI Cloud Shell environment
  
  - `git clone https://github.com/CloudTestDrive/helidon-kubernetes.git`
  
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

### Task 1b: Updating the scripts

We will use git to update the scripts

  1. Open the OCI Cloud shell type
  
  2. Make sure you are in the home directory
  
  - `cd $HOME/helidon-kubernetes`
  
  3. Use git to get the latest updates
  
  - `git pull`

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

## Task 2: Creating the container images

Due to legal restrictions we can no longer provide pre-built container images, we can however provide scripts and source code to let you build your own images (No, I don't understand that either)

To do this we need to obtain an authentication token (needed to push the images to a OCIR repo) to create the OCIR repos and then build and push the images to the OCIR repos.

We have provided a script that will do all of this.

**If your Kubernetes cluster creation script is still running** you do not need to wait for it to complete, simply open another window onto the OCI console then open a cloud shell in it (The precise mechanism is browser specific, but often Shift clicking on the [Oracle Cloud logo](images/oracle-cloud-logo.png) on the upper left will open a new window, then just open a new cloud shell) 

  1. If you are not already there open the OCI cloud shell and go to the scripts directory, type
  
  - `cd $HOME/helidon-kubernetes/setup/common`
  
  2. Run the script, in the OCI Cloud Shell type
  
  - `bash ./image-environment-setup.sh`
  
  ```
  Getting region environment details
This script will run the required commands to setup your own images
It assumes you are working in a free trial environment
If you are not you will need to exit at the prompt and follow the lab instructions for setting up the configuration separatly
Are you running in a free trial environment (y/n) ? 
```

  3. If you are in a free trial environment enter `y` If you are not the script will check if it can continue, and if not it will provide you with instructions. The text below is assuming it is able to proceed
  
  ```
  Thank you for confirming you are in a free trial, let's set your container image environment up
Loading existing settings information
No existing auth token.
No existing auth token OCID.
Checking region
You are in your home region and this script will continue
No existing auth tokens, will create a new one
Creating a new auth token for you
Your new auth token is oyUA9FOAtL):94Lt<+LW It is critical that you do not lose this information so please take note of it.
if needed you can delete the token by running the auth-token-destroy.sh script and then create a new one, but you will have
to repeat all of the processes that use it if you do.
Do you want to save the auth token value to make later reuse easier ?
This will make doing the lab easier as otherwise you will have to re-enter it when its needed, but 
it is not good security practice, the token will not be accessible unless logged in as
you so its not a major risk, but you should not do this if you are using this tenancy for
anything other than lab work
Save the auth token ?
```

  4. The script will create a auth token for you automatically if you don't have one, if you do it will let you chose between creating a new one (if possible) or selecting an existing one. In the example above it created a new one.
  
  5. You are asked if you want to save the auth token, If you are running in a free trial account I would recommend doing so by entering `y` at the prompt, however in a non trial tenancy you should not save it. **IMPORTANT** this is the only time you will see the value of the auth token, unless you chose to save it you **MUST** be sure to save the value somewhere save as you will need to provide it later on, and you cannot get this value again later.
  
  In this case I chose to save it.
  
  ```
  Your new auth token is has been saved in the /home/tim_graves/hk8sLabsSettings file its a good idea for you to
still take note of it as you may want it for other situations.
Loading existing settings information
Determining settings
Do you want to use tg_labs_base_repo as the base for naming your repo ? 
```
  
  6. The script will now setup some OCIR repositories to hold the base container images. by default it will use `<your-initials>_labs_base_repo` as the start of the name (it will create two repos under that called `stockmanager` and `storefront`) you will need to confirm if you are OK with this by entering `y` if not you can enter a new repo base name
  
  ```
  OK, going to use tg_labs_base_repo as the container image repo name
Using the saved auth token for the docker login
Checking for existing stockmanager repo
Creating OCIR repo named tg_labs_base_repo/stockmanager for the stock manager in your tenancy in compartment CTDOKE1
Action completed. Waiting until the resource has entered state: ('AVAILABLE',)
removing OCIR_STOCKMANAGER_LOCATION from /home/tim_graves/hk8sLabsSettings
Checking for existing storefront repo
Creating OCIR repo named tg_labs_base_repo/storefront for the storefront in your tenancy in compartment CTDOKE1
Action completed. Waiting until the resource has entered state: ('AVAILABLE',)
removing OCIR_STOREFRONT_LOCATION from /home/tim_graves/hk8sLabsSettings
About to docker login for stockmanager repo to iad.ocir.io and object storage namespace idi2cuxxbkto with username oracleidentitycloudservice/tim.graves@oracle.com using your auth token ads the password
Please ignore warnings about insecure password storage
WARNING! Your password will be stored unencrypted in /home/tim_graves/.docker/config.json.
Configure a credential helper to remove this warning. See
https://docs.docker.com/engine/reference/commandline/login/#credentials-store

Login Succeeded
About to docker login for storefront repo to iad.ocir.io and object storage namespace idi2cuxxbkto with username oracleidentitycloudservice/tim.graves@oracle.com using your auth token ads the password
Please ignore warnings about insecure password storage
WARNING! Your password will be stored unencrypted in /home/tim_graves/.docker/config.json.
Configure a credential helper to remove this warning. See
https://docs.docker.com/engine/reference/commandline/login/#credentials-store

Login Succeeded
```

  7. Once the OCI repos have been configured the script will then download the source code and Java, build the images, push them to the OCIR repos it's just created and update template deployment files with ones containing the image location. This will take about 5 mins and there will be lot's of outout.
  
## Acknowledgements

* **Author** - Tim Graves, Cloud Native Solutions Architect, EMEA OCI Centre of Excellence
* **Last Updated By** - Tim Graves, February 2022