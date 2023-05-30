![Title image](../../../common/images/customer.logo2.png)

# Setting up the OCI Kubernetes environment using scripts

For people who have already done the main Kubernetes lab they will have setup the OCI environment, however to speed things up for people who are only doing a specific lab (or have deleted their environment) I have provided some scripts that you can use to set things up.

If you have already created a kubernetes cluster in a previous lab and not deleted it you should skip this module.

**IMPORTANT** You must have setup a compartment, database and have configured your initials and extracted the user info

## Task 1: Downloading the latest scripts

There are a number of scripts that we have created for this lab to make life easier, if you have previously downloaded those recently (in the last few hours) then you can skip this Task and go to task 2. If you downloaded them longer ago then you should ensure you have the latest version, if you haven't downloaded them then you will need to do so.

If you have recently downloaded the scripts then please jump to **Task 2**, and skip the remainder of task 1.

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

### Task 1b: Updating the scripts

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

## Task 2: Creating the Kubernetes cluster

We're now going to create the Kubernetes cluster where the microservices will run. The script we use will allow us to create (or re-use) a Kubernetes cluster in the compartment we created earlier, it will then download the config file for that cluster (if needed merging it into any existing cluster configurations) and will re-name the context (which describes a configuration) to `one` so we can easily identify it.

While gathering the information on an existing cluster is fast, unlike the creation of the database and compartment creating a Kubernetes cluster can require a lot of interactions, so we are going to use a Terraform script to do the work for us here. This process can also take a while (usually of the order of 10 minutes) so once the script has started the creation process you may wish to take a short break, or if you'd prefer you can open another browser window and continue with the remainder of the setup tasks, then come back before you need to use the Kubernetes cluster to check that it was successfully created

### Task 2a: Running the script

<details><summary><b>What does this script actually do ?</b></summary>  

The script first of all checks by ooking in the  to see if you've already setup a cluster (or told it about a specific cluster to use) if so it will use that and just exit

It then checks for the required resources to make sure that you have enough to create the cluster (there's no point in starting something that won't complete.)

After checking it downloads a teraform file and set's up the terraform config based on the environment you're running in, and them dopes a terraform plan and apply to actually build the cluster.

Once the cluster exists it captures the information on the clusters (OCID) and sets up the kube config file renamign the cluster form the ranxom set of latters to the name you specified (this default to one if not specified)

</details>

This script will do some data gathering and then if a new cluster is required will create it (or you can re-use an existing one if you already have one). It then downloads and sets up the configuration to let you interact with the Kubernetes cluster.

  1. If you are not already there open the OCI cloud shell and go to the scripts directory, type
  
  ```bash
  <copy>cd $HOME/helidon-kubernetes/setup/common/oke-setup</copy>
  ```
  
  2. Run the script, in the OCI Cloud Shell type
  
  ```bash
  <copy>bash ./oke-cluster-setup.sh</copy>
  ```
  
  If you have just created the compartment get a message "Authorization failed or requested resource not found" and that "The provided COMPARTMENT_OCID or ocid1.co....oycu3a cant be located" then please wait a short while for the compartment information to propagate and try running the script again. 

```
Using default context name of one
Loading existing settings information
No reuse information for OKE context one
Using context name of one
Operating in compartment CTDOKE
Do you want to use tglab as the name of the Kubernetes cluster to create or re-use in CTDOKE?
```
  3. If you already have an existing cluster in this compartment with a different name you want to reuse, or you just want a different name then type `n` and when prompted enter the name for the cluster to create or reuse. If you do not have an existing cluster to reuse and are happy with the proposed name type `y`
  
  ```
OK, going to use tglab as the Kubernetes cluster name
Checking for active cluster named tglab
Checking for VCN availability
You asked for 1 of resource vcn-count in service vcn in region congratulations 50 are available
You have enough Virtual CLoud Networks to create the OKE cluster
Checking for E4 or E3 processor core availability for Kubernetes workers
You asked for 3 of resource standard-e4-core-count in service compute in availability domain gKLQ:ME-DUBAI-1-AD-1, congratulations 100 are available
You asked for 3 of resource standard-e3-core-ad-count in service compute in availability domain gKLQ:ME-DUBAI-1-AD-1, congratulations 100 are available
Creating cluster tglab
Preparing terraform directory
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
  
  ```bash
  <copy>kubectl get nodes</copy>
  ```

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

  1. Open up the VCN for the cluster you just created - Go to the clusters page (Hamburger -> Developer Services -> Kubernetes Clusters -> your cluster) and in the Network Information click on the VCN Name link.
  
  2. On the Resources menu on the left side click **Security Lists**, Then in the resulting list click `oke-control-plane`
  
  3. Once on the `oke-control-plane` page on the Resoruces menu on the left click **Ingress rules
  
  4. Click **Add Ingress Rules** to add a new ingress rule 
  
  5. In the resulting popup ensure that Stateless is unchecked, the Source type is set to CIDE, enter `0.0.0.0/0` in the Source CIDR field, the IP Protocol should be `TCP`, leaf the Source port range blank (all), enter `6443` in the Destination port range field, put `Allows access to the Kubernetes API endpoint` in the Description field, then click the **Add Ingress Rules** button

---
</details>
 
**IMPORTANT** This script takes a while to run, usually around 10 mins. You can of course wait while it's running, however once running it's best to continue with the lab steps in a different cloud shell instance.

## Acknowledgements

* **Author** - Tim Graves, Cloud Native Solutions Architect, Oracle EMEA Cloud Native Application Development specialists Team
* **Kubernetes Terraform Script author** Ali Mukadam, Cloud Native Solutions Architect, OCI Strategic Engagements Team, Open Source program
* **Last Updated By** - Tim Graves, May 2023