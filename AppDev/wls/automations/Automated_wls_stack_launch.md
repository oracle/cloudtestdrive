# Using Terraform to launch the WebLogic Marketplace Stack - Part 1

Using Marketplace to launch Marketplace Images is one thing, and a few blogs have already been written on that topic.  But what about automating the launch of a Marketplace **Stack**, in particular a "Pay-as-you-go" stack like WebLogic ?

This article is the first in a series that will explore your options to work with Terraform and the Marketplace Stacks and Images of WebLogic as provided on the Marketplace, offering you the ability to spin up your own customized stacks using the "Pay-as-you-go" consumption of WebLogic licenses.

- In this first article, I will focus on how you can **automate the launch of the WebLogic stack** as it is provided on Marketplace, using Terraform and a bit of OCI Command Line.

- In a second article, I will detail how you can omit the provided automation of the stack, and spin up a UC consumping instance as part of a **custom configuration of WLS** you might already have
- And finally in a third article I'll explain how you can **add Kubernetes node pools consuming the UC flavor** of WebLogic to an existing, customer-build setup of WebLogic on Kubernetes.



## Obtaining the required data from Marketplace

Before you can start creating resources from Marketplace, you need to locate the ID's of the correct Image or Stack you want to launch.  This can be done through a series of Terraform Data Sources that are available.  Because the names of the data elements are long and very similar, I tagged them with *Data 1*, *Data 2*, ...  labels for easy reference.



### Data 1 - List the Marketplace Images available

You can use the **oci_marketplace_listings** Data Source element to get a full list of all entries in marketplace.  Please note these entries are called *Listings* in the interface.  

Using the ***name*** filter you can find the entry you are interested in.  To find the exact name of an image, simplest trick is to go throught the normal Marketplace wizard and accept the T&C manually, this will create an *Marketplace Agreement* entry in your compartment with the exact name you need.  

```
# DATA 1 - Get a list of element in Marketplace, using filters, eg name of the stack
data "oci_marketplace_listings" "test_listings" {
  name = ["Oracle WebLogic Server Enterprise Edition UCM"]
  compartment_id = var.compartment_ocid
}
```

Alternatively you can omit the *name* filter and display the full list of entries.  To show these, use below output command:

```
# DATA 1 : List of entries in Marketplace
output "data_1_oci_marketplace_listings" {
  sensitive = false
  value = data.oci_marketplace_listings.test_listings
}
```



### Data 2 - Details of a single Marketplace Listing

Now that you've located the entry you are interested in, you can get more details on this entry with the **oci_marketplace_listing** Data Source element.  Notice the singular Data 2 *listing* as opposed to the initial plural Data 1 *listings*.

```
# DATA 2 - Get details cf the specific listing you are interested in
data "oci_marketplace_listing" "test_listing" {
  listing_id     = data.oci_marketplace_listings.test_listings.listings[0].id
  compartment_id = var.compartment_ocid
}
```

###  

### Data 3 - List and filter the available versions of the stack

A stack will probably be offering a series of versions.  For example the WebLogic Stack is available in version 10.3.6, 12.2.1.3, 12.2.1.4 and more.  The **oci_marketplace_listing_packages** Data Source allows you to list and filter the version you want, using either an explicit version or to use the ***default_package_version*** of the stack as provided in the Data 2 element *oci_marketplace_listing.default_package_version* (in comment in the code below)

```
# DATA 3 - Get the list of versions for the specific entry (11.3, 12.2.1, ....)
data "oci_marketplace_listing_packages" "test_listing_packages" {
  #Required
  listing_id = data.oci_marketplace_listing.test_listing.id

  #Optional
  compartment_id = var.compartment_ocid
  package_version = "WLS 10.3.6.0.200714.05(11.1.1.7)"
  #package_version = data.oci_marketplace_listing.test_listing.default_package_version
} 
```



### Data 4 - Get details about a specfic version

To get the details of your chosen version, we will use the ***oci_marketplace_listing_package*** Data Source element.  Again, notice the use of the singular *package*.

```
# DATA 4 - Get details about a specfic version
data "oci_marketplace_listing_package" "test_listing_package" {
  #Required
  listing_id      = data.oci_marketplace_listing.test_listing.id
  package_version = data.oci_marketplace_listing_packages.test_listing_packages.package_version

  #Optional
  compartment_id = var.compartment_ocid
}
```

Of particular interest is the ***resource_link*** element: this contains the URL to download the actual Terraform Stack of the Marketplace image !  You can visualize this element by including the below output element.

```
# DATA 4 : Single version of an entry (11g)
output "DATA_4_oci_marketplace_listing_package" {
  sensitive = false
  value = data.oci_marketplace_listing_package.test_listing_package.resource_link
}
```

As a result, you will get a URL that looks like :

```
https://objectstorage.us-ashburn-1.oraclecloud.com/n/marketplaceprod/b/oracleapps/o/orchestration%2F85315320%2Fwlsoci-resource-manager-ee-ucm-mp-10.3.6.0.211714-20.3.3-201018183753.zip
```

Download this file, either to your local PC using a brower, or into the Cloud Shell with a curl command.



## Accepting the License Agreement

Before you can run the stack you downloaded, you first need to accept the Terms and Conditions associated with the software of your choice.  Do do this, you first need to locate the correct agreement data using the ***oci_marketplace_listing_package_agreements***, then create your agreement with the reqource type ***oci_marketplace_listing_package_agreement***, and finally accept the Terms and Conditions throught the creation of a ***oci_marketplace_accepted_agreement***.  After completing this last step you can see your agreement in the Marketplace Accepted Agreements list.



```
# DATA 5 - agreement for a specific version
data "oci_marketplace_listing_package_agreements" "test_listing_package_agreements" {
  #Required
  listing_id      = data.oci_marketplace_listing.test_listing.id
  package_version = data.oci_marketplace_listing_packages.test_listing_packages.package_version

  #Optional
  compartment_id = var.compartment_ocid
}
```



```
# RESOURCE 1 - agreement for a specific version
resource "oci_marketplace_listing_package_agreement" "test_listing_package_agreement" {
  #Required
  agreement_id    = data.oci_marketplace_listing_package_agreements.test_listing_package_agreements.agreements[0].id
  listing_id      = data.oci_marketplace_listing.test_listing.id
  package_version = data.oci_marketplace_listing_packages.test_listing_packages.package_version
}
```



```
# RESOURCE 2 - Accepted agreement
resource "oci_marketplace_accepted_agreement" "test_accepted_agreement" {
  agreement_id    = oci_marketplace_listing_package_agreement.test_listing_package_agreement.agreement_id
  compartment_id  = var.compartment_ocid
  listing_id      = data.oci_marketplace_listing.test_listing.id
  package_version = data.oci_marketplace_listing_packages.test_listing_packages.package_version
  signature       = oci_marketplace_listing_package_agreement.test_listing_package_agreement.signature
}
```

A **sample terraform configuration** can be found [on Github](https://github.com/oracle/cloudtestdrive/tree/master/AppDev/wls/automations/wls_stack), you just need to fill in your authentication info and tenancy ocid's to try this out.



## Running the default stack with Resource Manager

You just collected all the required elements to run your stack with resource manager !

Unfortunately, the Terraform OCI Adaptor does not support the creation of a Stack nor a Job, only to list these elements.  

To complete the automation, we'll switch to the **OCI CLI** to create the stack and run the Apply action.  Once the **Create Stack**  and **create Job** will have been added to the Terraform OCI provider this part can be included in the Terraform script we used so far. 

### Create the Stack

Below you can see the command to create the stack, using the zip file of the Stack definition you previously downloaded, and the target compartment OCID. 

```
oci resource-manager stack create --config-source stack.zip --compartment-id ocid1.compartment.oc1..your_compartment_ocid
```

Next you need to set all the parameters of the stack, as these would normally be asked interactively when staring a new Job.  Easiest way to do this is using a JSON formatted file with all elements included.  Below you can see a sample of the file:

```
{
"compartment_ocid": "ocid1.compartment.oc1..your_compartment_ocid",
"region": "eu-frankfurt-1",
"tenancy_ocid": "ocid1.tenancy.oc1..your_tenancy_ocid",
"wls_node_count": "2",
"wls_admin_password_ocid": "ocid1.vaultsecret.oc1.eu-frankfurt-1.your_secret_ocid",
"use_advanced_wls_instance_config": "false",
"vcn_strategy": "Create New VCN",
"add_load_balancer": "true",
"lb_shape": "100Mbps",
"is_idcs_selected": "false",
"create_policies": "true",
"add_JRF": "false",
"configure_app_db": "false",
"defined_tag": "",
"defined_tag_value": "",
"free_form_tag": "",
"free_form_tag_value": "",
"network_compartment_id": "ocid1.compartment.oc1..your_network_compartment_ocid",
"subnet_strategy_new_vcn": "Create New Subnet",
"wls_subnet_cidr": "10.0.3.0/24",
"lb_subnet_1_cidr": "10.0.4.0/24",
"service_name": "jlewls",
"instance_shape": "VM.Standard2.1",
"ssh_public_key": "ssh-rsa AAAAB3NzaC1yc2EA...your_public_key...FEkVLdsdfgsdfgdfsg5ES1 ATPKey",
"wls_vcn_name": "wlsvcn"
}
```

Please note there are more parameters available, for example when using the JRF type of installation including a database, or for integrating with IDCS.  You can find the details in the README file included in the stack you downloaded.

You can now update your job with the above parameters using the below *update* command:

```
oci resource-manager stack update --stack-id ocid1.ormstack.oc1.eu-frankfurt-1.aaaaaaaa34p65jokvrtsa5q57t7mnxvo22abxm43fzgosfoxw3zws7yhifwa --variables file://vars.json
```



### Create the Apply job

Next you need to create the apply job to trigger the execution of the stack creation.  

```
oci resource-manager job create \
	--stack-id ocid1.ormstack.oc1.eu-frankfurt-1.aaaaaaaa34p65jokvrtsa5q57t7mnxvo22abxm43fzgosfoxw3zws7yhifwa \
	--operation APPLY \
	--apply-job-plan-resolution '{"isAutoApproved": true }'
```

And voila, you just launched the creation of a WebLogic stack using terraform and the OCI CLI only !



## Next reads

Make sure to check out my follow-up articles on this topic:

- How to spin up a UC consumping instance as part of a **custom configuration of WLS** you might already have, omitting the standard Marketplace automation but **using pay-as-you-go**.
- How to **add Kubernetes node pools consuming the UC flavor** of WebLogic to an existing, customer-build setup of WebLogic on Kubernetes.