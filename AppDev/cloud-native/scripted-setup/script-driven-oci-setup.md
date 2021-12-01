![](../../../common/images/customer.logo2.png)

# Setting up the OCI environment using scripts

For people who have done the main Kubernrtes lab they will have setup the OCI environment, however to speed things up for people who are only doing a specific lab I have provided some scripts that you can use to set things up.

If you want to get a better understanding of the steps involved follow the instructions in the Kubernetes labs for manually setting up the environment.

## Task 1: Downloading the latest scripts

There are a number of scripts that we have created for this lab to make life easier, if you have previously downloaded those then you should ensure you have the latest version, if you haven't downloaded them then you will need to do so.

If you are not sure if you have downloaded the lates version then you can check

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

Please go to **Task 2**

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

## Task 2: Downloading step certificate tools

The `step` command is used to create a root certificate, you will need this for secure connections

If you have already downloaded `step` as part of a previous lab and have setup a root certificate then you can move on to Task 3

If you do not know if you have downloaded `step` then you can check

 - In the OCI CLoud shell type
 
 - `ls $HOME/keys`

If you get output like this then you have setup both the `step` command and the root certificate, in this case go to **Task 3**

```
root.crt  root.key  step
```

If you get output like this then you have the `step` command you just need to setup the root certificate, please go to **Task 2a**

```
step
```


If you get output like this then you need to download `step` and create the root certificate, follow the process in **Task 2b**

```
ls: cannot access /home/tim_graves/key: No such file or directory
```

### Task 2a: Creating the root certificate

Assuming you have `step` you can easily create the self signed root certificate

  1. Open the OCI Cloud shell and type
    
  - `./step certificate create root.cluster.local root.crt root.key --profile root-ca --no-password --insecure`
  
  ```
  Your certificate has been saved in root.crt.
  Your private key has been saved in root.key.
```

Your root certificate is now created and you're ready to go.

Now please go to **Task 3**

### Task 2b: Downloading step and creating the root certificate

To make setting `step` up easier (manually it requires a lot of visits to different pages to get the download details) I have created a script that will dso the page navigation, parsing, downloads, unpacking, and installation of `step` for you.

  1. Open the OCI cloud shall and go to the scripts directory, type
  
  - `cd $HOME/helidon-kubernetes/setup/common`
  
  2. Run the download script, In the OCI cloud shell type
  
  - `bash ./download-step.sh`
  
  ```
  /home/tim_graves/keys does not exist creating
Locating download page for latest version of step and removing whitespace
Latest version location page is https://github.com/smallstep/cli/releases/tag/v0.18.0
Identifying latest Version of step download linkk
Latest step download location is https://dl.step.sm/gh-release/cli/gh-release-header/v0.18.0/step_linux_0.18.0_amd64.tar.gz
... 
... Lots of output
...
Root certificate processing
Creating root certificate
Your certificate has been saved in root.crt.
Your private key has been saved in root.key.
```

This output is for `step` version 0.18.0 the output you get will probably vary.

This has downloaded the latest version of `step` and created the root certificate, please continue with **Task 3**

## Task 3: Recording your initials

For a number of activities in the lab we use your initials to identify instances (database, Kubernetes etc.) We do this to enable multiple user to operate in the same tenancy withouth conflict (This is only for some versions of the lab, in most cases you will be using your own free trial tenancy). 

We need to capture your initials and save them. It is important that when you enter your initials you use lower case only and only the letters a-z, no numbers of special characters

  1. If you are not already there open the OCI cloud shall and go to the scripts directory, type
  
  - `cd $HOME/helidon-kubernetes/setup/common`
  
  2. Run the script to gather and save your initials, when prompted by the script enter your initials and press return, in the example below as my name is Tim Graves I used `tg` as the initials
  
  - `bash ./initials-setup.sh`
  
  ```
  Please can you enter your initials - use lower case a-z only and no spaces, for example if your name is John Smith your initials would be js. This will be used to do things like name the database
tg
OK, using tg as your initials
```

Of course unless your initials are also `tg` you would enter something different !

## Task 4: Creating the compartment

In OCI all resources live in compartments, we are going to create a compartment for this lab. If you have already created a compartment in the past when doing other parts of this lab then please re-use the same one when prompted.

The following instructions follow through the prompts one at a time, unless you have specific requirements (usually because you are not running in a free trial account) then just take the defaults.

  1. If you are not already there open the OCI cloud shall and go to the scripts directory, type
  
  - `cd $HOME/helidon-kubernetes/setup/common`
  
  2. Run the compartment setup script
  
  - `bash ./compartment-setup.sh`
  
  ```
  Loading existing settings
No reuse information for compartment
Parent is tenancy root
This script will create a compartment called CTDOKE for you if it doesn't exist, this will be in the Tenancy root. If a compartment with the same name already exists you can re-use change the name to create or re-use a different compartment.
If you want to use somewhere different from Tenancy root as the parent of the compartment you are about to create (or re-use) then enter n, if you want to use Tenancy root for your parent then enter y
Use the Tenancy root (y/n) ?
```

  3. At this prompt unless you want to create the compartment somewhere else please enter `y` and press return. You should chose the tenancy root unless you are in a shared or commercial tenancy and you explicitly understand you need to work somewhere other than the tenancy root. If you really want to create or reuse a compartment somewhere other than the tenancy root enter `n` and follow the instructions that will be displayed.
  
  ```
  We are going to create or if it already exists reuse use a compartment called CTDOKE in Tenancy root, if you want you can change the compartment name from CTDOKE - this is not recommended and you will need to remember to use a different name in the lab.
 Do you want to use CTDOKE as the compartment name (y/n) ? 
 ```
 
  4. You are being asked if you want to use `CTDOKE` as the name of the compartment to use (or if it already exists re-use). If you have chosen a different compartment as the parent that will be displayed instead of `Tennancy root`. Unless you explicitly know you need to use a different compartment then please enter `y` here. If you really want a different name for your compartment (perhaps because you are re-using one with a different name, or `CTDOKE` is in use for something else) then type `n` and follow the prompts to enter a different name.
  
  ```
  OK, going to use CTDOKE as the compartment name
Compartment CTDOKE, doesn't already exist in the Tenancy root, creating it
Created compartment CTDOKE in the Tenancy root It's OCID is ocid1.compartment.oc1..aaaaabaas5lazl434a7oizjiuife3tjffwucxrbom2zdhyhvh5t66mb75olq
It may take a short while before new compartment has propogated and the web UI reflects this
```
  
  In this case the compartment `CTDOKE` (or whatever name you entered if you chose to override it) did not exist in the tenancy root, so the compartment was created, If it had existed then the script would have retrieved it's information for re-use.
  
  **Important** It can take a short while for the compartment information to be propagated to all OCI regions and environments.
 
## Task 5: Creating the Kubernetes cluster

We're now going to create (or re-use) the Kubernetes cluster where the microservices will run. The script we use will allow us to create (or re-use) a Kubernetes cluster in the compartment we created earlier, it will then download the config file for that cluster (if needed merging it into any existing cluster configurations) and will re-name the context (which describes a configuration) to `one` so we can easily identify it.

While gathering the information on an existing cluster is fast, unlike the creation of the database and compartment creating a Kubernetes cluster can require a lot of interactions, so we are going to use a Terraform script to do the work for us here. This process can also take a while (usually of the order of 10 minutes) so once the script has started the creation process you may wish to take a short break, or if you'd prefer you can open another browser window and continue with the remainder of the setup tasks, then come back before you need to use the Kubernetes cluster to check that it was successfully created

### Task 5a: Running the script

This script will do some data gathering and then if a new cluster is required will create it (or you can re-use an existing one if you already have one). It then downloads and sets up the configuration to let you interact with the Kubernetes cluster.

  1. If you are not already there open the OCI cloud shell and go to the scripts directory, type
  
  - `cd $HOME/helidon-kubernetes/setup/common`
  
  2. Run the script, in the OCI Cloud Shell type
  
  - `bash ./kubernetes-setup.sh`
  
  If you have just created the compartment get a message "Authorization failed or requested resource not found" and that "The provided COMPARTMENT_OCID or ocid1.co....oycu3a cant be located" then please wait a short while for the compartment information to propagate and try rtunning the script again. 

```
Loading existing settings information
No reuse information for OKE
Operating in compartment CTDOKE
Do you want to use tglab as the name of the Kubernetes cluster to create or re-use in CTDOKE?
```
  3. If you already have an existing cluster in this compartment with a different name you want to reuse, or you just want a different name then type `n` and when prompted enter the name for the cluster to create or reuse. If you do not have an existing cluster to reuse and are happy with the proposed name type `y`
  
  ```
Checking for cluster tglab
Creating cluster tglab
Downloading terraform
Cloning into 'terraform-oci-oke'...
...
<Git download information for the terraform module>
...
Resolving deltas: 100% (2190/2190), done.
Configuring terraform
Update provider.tf set OCI_REGION to eu-frankfurt-1
Updating /home/tim_graves/helidon-kubernetes/setup/common/terraform-oci-oke/provider.tf replacing OCI_REGION with eu-frankfurt-1
...
<Updates as the scripts configures the terraform parameters>
...
Initialising Terraform
Initializing modules...
Downloading oracle-terraform-modules/bastion/oci 3.0.0 for bastion...
- bastion in .terraform/modules/bastion
...
<Lots of terraform output about initialising>
...
  # module.vcn.oci_core_vcn.vcn will be created
  + resource "oci_core_vcn" "vcn" {
      + cidr_block               = (known after apply)
      + cidr_blocks              = [
          + "10.0.0.0/16",
        ]
      + compartment_id           = "ocid1.compartment.oc1..aaaaaaaa6rceeuqppqj5oqrmfq55sus7juaiklpjsyl5ps2dvqxuk3ilczia"
      + default_dhcp_options_id  = (known after apply)
      + default_route_table_id   = (known after apply)
      + default_security_list_id = (known after apply)
      + defined_tags             = (known after apply)
      + display_name             = "oke_-oke-vcn-tglab"
      + dns_label                = "oke"
      + freeform_tags            = {
          + "environment" = "dev"
        }
      + id                       = (known after apply)
      + ipv6cidr_blocks          = (known after apply)
      + is_ipv6enabled           = (known after apply)
      + state                    = (known after apply)
      + time_created             = (known after apply)
      + vcn_domain_name          = (known after apply)
    }
...
<Lots of terraform output about what it plans on doing>
...
module.vcn.oci_core_internet_gateway.ig[0]: Creation complete after 0s [id=ocid1.internetgateway.oc1.eu-frankfurt-1.aaaaaaaaigrb67idaauxrvz76pwdxrtw6p3ao5jck3wgujh4ndpqnaekqefa]
module.vcn.oci_core_route_table.ig[0]: Creating...
module.vcn.oci_core_default_security_list.lockdown[0]: Creation complete after 1s [id=ocid1.securitylist.oc1.eu-frankfurt-1.aaaaaaaaj5n3ld3zz2ecnzdlcrg74z35tgtq5tei665giysnci7sf7btkvcq]
module.vcn.oci_core_route_table.ig[0]: Creation complete after 1s [id=ocid1.routetable.oc1.eu-frankfurt-1.aaaaaaaabk3toup5tmehpgs22lo5uiq56turjw2fqj5jj4p3x26bhmsyln7a]
module.vcn.oci_core_service_gateway.service_gateway[0]: Creation complete after 1s [id=ocid1.servicegateway.oc1.eu-frankfurt-1.aaaaaaaa4s6wkacak2vuqbqs4fid5u3jcj44i24ijavuchkeuehd2gs2itxa]
module.vcn.oci_core_nat_gateway.nat_gateway[0]: Creation complete after 2s [id=ocid1.natgateway.oc1.eu-frankfurt-1.aaaaaaaa2xxdm26jq5bdivwl46h3k6e72l5drrlekhp7pojbwum3f7tzwwzq]
module.vcn.oci_core_route_table.nat[0]: Creating...
module.vcn.oci_core_route_table.nat[0]: Creation complete after 0s [id=ocid1.routetable.oc1.eu-frankfurt-1.aaaaaaaar6dsg3kh4633uspoimhqijsgg7qlss6hnjcm2cr76l4fiv3imlaq]
module.network.data.oci_core_services.all_oci_services: Reading...
module.network.data.oci_core_vcn.vcn: Reading...
module.network.data.oci_core_subnets.oke_subnets: Reading...
module.network.oci_core_network_security_group.pub_lb[0]: Creating...
...
<Lots of Terraform output showing you its progress>
...
module.extensions.time_sleep.wait_30_seconds: Still creating... [30s elapsed]
module.extensions.time_sleep.wait_30_seconds: Creation complete after 30s [id=2021-11-20T17:54:08Z]

Apply complete! Resources: 45 added, 0 changed, 0 destroyed.

Outputs:

bastion_public_ip = ""
bastion_service_instance_id = "null"
cluster_id = "ocid1.cluster.oc1.eu-frankfurt-1.aaaaaaaaww7i75d2ilsi5hgfihmfjdrtcccjh64qqsjwayl2wcwy64pje7gq"
ig_route_id = "ocid1.routetable.oc1.eu-frankfurt-1.aaaaaaaabk3toup5tmehpgs22lo5uiq56turjw2fqj5jj4p3x26bhmsyln7a"
int_lb_nsg = ""
kubeconfig = "export KUBECONFIG=generated/kubeconfig"
nat_route_id = "ocid1.routetable.oc1.eu-frankfurt-1.aaaaaaaar6dsg3kh4633uspoimhqijsgg7qlss6hnjcm2cr76l4fiv3imlaq"
nodepool_ids = {
  "oke_-pool1" = "ocid1.nodepool.oc1.eu-frankfurt-1.aaaaaaaa4hcew76aodj42r3knq3wzzn2g3x4a6eka3qfi7fv4nuvjgznz7cq"
}
operator_private_ip = ""
pub_lb_nsg = "ocid1.networksecuritygroup.oc1.eu-frankfurt-1.aaaaaaaahnomdy6y7fususol7w4xzaxrjogqdaqbujcyoy4735iw4gx4prxa"
ssh_to_bastion = "ssh -i none opc@"
ssh_to_operator = "ssh -i none -J opc@ opc@"
subnet_ids = {
  "cp" = "ocid1.subnet.oc1.eu-frankfurt-1.aaaaaaaav7lllr6assk7knofqu5alc4t6abyqsa24qwneual2poawc6bho4a"
  "int_lb" = ""
  "pub_lb" = "ocid1.subnet.oc1.eu-frankfurt-1.aaaaaaaarurciqmmxckechmtbr6ptjidbvr5i44672hkw2dmtnayn4zipmwq"
  "workers" = "ocid1.subnet.oc1.eu-frankfurt-1.aaaaaaaag7mnecm2hg7yjvvit3vs3v2mzbpauovseiuuyvdrn7ghypstqpia"
}
vcn_id = "ocid1.vcn.oc1.eu-frankfurt-1.amaaaaaaqrgb7baaif3nw7lqq7ixxkpzbylmg3feo5tvmtw7i44sjskb446q"
Retrieving cluster OCID from Terraform
Downloading the kube config file
Existing Kubeconfig file found at /home/tim_graves/.kube/config and new config merged into it
Renaming context
Context "context-cwy64pje7gq" renamed to "one".
```

You can see the progress of Terraform, and that it spends time waiting for the actions it initiates to complete, but after a while (and assuming you have enough resources available to you) you will see that the process completes. Terraform displays it's outputs and then the script finished the work of setting up your configuration so it's ready to use.


### Task 5b: Confirming that the cluster was created and is running.

Once the scripts have completed you can check that the cluster is responding.
  
  1. Use the Kubernetes control program `kubectl` to check on the nodes, in the OCI Cloud shell type
  
  - `kubectl get nodes`

```
NAME          STATUS   ROLES   AGE   VERSION
10.0.10.157   Ready    node    92s   v1.20.11
10.0.10.158   Ready    node    98s   v1.20.11
10.0.10.152   Ready    node    84s   v1.20.11
```

The nodes will be listed, in this case I was using a cluster with three workers, Of course the specifics (Name, Age, Version) may vary in your output, but really what we are checking is that there *is* output as this shows you can connect to the Kubernetes cluster management system and you can see that there are nodes available in the `Ready` state.


<details><summary><b>If kubectl get nodes doesn't respond within a few minutes</b></summary>  

The Terraform script we are using to create the cluster aims to be create a secure configuration, this means that it won't allow anyone to connect to the Kubernetes management API endpoint. We have added settings that should set this up for you, nbut this may have failed. For the purposes of these labs however we are focused on teaching you how to do certain tasks, and to make that easier we want you to be able to easily use the `kubectl` command.

Thus we need to enable access to the Kubernetes management API endpoint from any location (it will still be secure as you'll need the configuration which includes your credentials) to do this we need to :

  1. Open up the VCN for the cluster you just created - Go to the clusters page (Hamburger -> Developer Services -> Kubernrtes Clusters -> your cluster) and in the Network Information click on the VCN Name link.
  
  2. On the Resources menu on the left side click **Security Lists**, Then in the resulting list click `oke-control-plane`
  
  3. Once on the `oke-control-plane` page on the Resoruces menu on the left click **Ingress rules
  
  4. Click **Add Ingress Rules** to add a new ingress rule 
  
  5. In the resulting popup ensure that Stateless is unchecked, the Source type is set to CIDE, enter `0.0.0.0/0` in the Source CIDR field, the IP Protocol should be `TCP`, leaf the Source port range blank (all), enter `6443` in the Destination port range field, put `Allows access to the Kubernrtes API endpoint` in the Description field, then click the **Add Ingress Rules** button

---
</details>
 
## Task 6: Creating the database

The microservices that form the base content of these labs use a database to store their data, so we need to create a database. The Following script will create the database in the compartment we just created, then download the connection information (the "Wallet") and use that to connect to the database and create the user used by the labs.

  1. If you are not already there open the OCI cloud shall and go to the scripts directory, type
  
  - `cd $HOME/helidon-kubernetes/setup/common`
  
  2. Run the script to create or re-use the database
  
  - `bash ./database-setup.sh`
  
  ```
  Loading existing settings information
No reuse information for database
Operating in compartment CTDOKE
Do you want to use tgdb as the name of the databse to create or re-use in CTDOKE?
```

  3. if you are creating a new database then enter `y` if however you have an existing database in this compartment, perhaps created doing another part of these Kubernetes labs which used a different name then please enter `n` and when prompted enter that name - you will need to know the ADMIN password for that database and will be prompted for it.
  
  ```
  OK, going to use tgdb as the database name
Checking for database tgdb in compartment CTDOKE
Database named tgdb doesn't exist, creating it, there may be a short delay
The generated database admin password is 2005758405_SeCrEt Please ensure that you save this information in case you need it later
```

  4. The database will be created for you unless you chose a name that already exists, **IMPORTANT** you are **strongly** recommended to save the generated database password (`2005758405_SeCrEt` in this case) in case you need to administer the database later. If there is an existing `$HOME/Wallet.zip` then it will be saved before downloading the new wallet.
  
  
  ```
  Downloaded Wallet.zip file
Preparing temporary database connection details
Getting wallet contents for temporaty processing
Archive:  Wallet.zip
  inflating: README                  
  inflating: cwallet.sso             
  inflating: tnsnames.ora            
  inflating: truststore.jks          
  inflating: ojdbc.properties        
  inflating: sqlnet.ora              
  inflating: ewallet.p12             
  inflating: keystore.jks            
updating temporary sqlnet.ora
Connecting to database to create labs user

SQL*Plus: Release 19.0.0.0.0 - Production on Fri Nov 19 21:22:24 2021
Version 19.13.0.0.0

Copyright (c) 1982, 2021, Oracle.  All rights reserved.


Connected to:
Oracle Database 19c Enterprise Edition Release 19.0.0.0.0 - Production
Version 19.13.0.1.0


User created.


Grant succeeded.


Grant succeeded.


Grant succeeded.


Grant succeeded.

Disconnected from Oracle Database 19c Enterprise Edition Release 19.0.0.0.0 - Production
Version 19.13.0.1.0
Deleting temporary database connection info
```
  
  The script will then setup a temporary set of access credentials using the wallet, connect to the database using the password it generated (or in the case of a database that you are re-using the password you provided) and setup the labs user in the database.
  
  If you are reusing a database and had already setup the labs user then you may get error messages that the user conflicts with the existing one.
  
  

## Acknowledgements

* **Author** - Tim Graves, Cloud Native Solutions Architect, EMEA OCI Centre of Excellence
* **Kubernetes Terraform Script author** Ali Mukadam
* **Last Updated By** - Tim Graves, November 2021