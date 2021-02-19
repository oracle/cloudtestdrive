# Using Terraform to launch a WebLogic Pay-as-you-go Image - Part 2

This article is the **second chapter** in a series that will explore your options to work with Terraform and the Marketplace Stacks and Images of WebLogic as provided on the Marketplace, offering you the ability to spin up your own customized stacks using the "Pay-as-you-go" consumption of WebLogic licenses.

You will learn how to launch an **individual Pay-as-you-go image** with full control of the setup process, omitting the standard Stack provided on Marketplace.

- In [the first article](Automated_wls_stack_launch.md) you could read how to **automate the launch of the WebLogic stack** as it is provided on Marketplace, using Terraform and a bit of OCI Command Line.
- In the third article I will be adding a **WebLogic Pay-as-you-go Node Pool** to an existing OKE cluster, thus allowing to easily switch an existing custom setup of WebLogic running on OKE into a pay-as-you-go type of consumption



## Launch a Pay-as-you-go image 

In the first article of this series you learned how to use the normal stack with the out-of-the-box automation provided by Oracle.  But what if you want to fully customize the install, but still use an instance that has a Pay-as-you-go license entitlement for WebLogic ?

Easy ! Using the image information included in the stack definition you can obtain via the **oci_marketplace_listing_package** Data field, you can  easily spin up any configuration you fancy, from an single image up to much more complex set-ups.  See  [the first article](Automated_wls_stack_launch.md) in this series for all the details on obtaining the necessary information from Marketplace, and accepting the Terms & Conditions via Terraform.



### Locating 3 important parameters in the stack definition

To be able to do this operation you need to locate 3 hard-coded parameters inside the Stack definition.

These parameters will change with each new version, so each initial setup of an automation will need to be done manually.  Ideally the required parameters should be provided in the stack definition itself, which would allow you to automate this process entirely [ ==> Enhancement request addressed to Product Management ... !]

After running the Terraform script from Article 1, download the stack zip file (a filename looking like : https://objectstorage.us-ashburn-1.oraclecloud.com/n/marketplaceprod/b/oracleapps/o/orchestration%2F85315320%2Fwlsoci-resource-manager-ee-ucm-mp-10.3.6.0.211714-20.3.3-201018183753.zip), and unzip the file.

- Open the file **variables.tf**

  - Locate the lines defining the variable **instance_image_id**, and note the default value of the OCID.

- Open the file **mp-variables.tf**

  - Locale the lines defining the **mp_listing_id** and note down the App Catalog Listing OCID

  - Locate the line containing the **mp_listing_resource_version**, this is a value that looks like :
     `20.4.1-201103061109`

### Subscribing to the image

Although we already subscribed to the WebLogic Marketplace Stack Listing, we now need to subscribe (also) to this specific image in order to be abl to use it in our tenancy and compartment.

This can be achieved by running the following commands:

- Get the partner image subscription data

  ```
  data "oci_core_app_catalog_subscriptions" "mp_image_subscription" {
    #Required
    compartment_id = var.compartment_ocid
  
    #Optional
    listing_id = var.mp_listing_id
    filter {
      name = "listing_resource_version"
      values = [var.mp_listing_resource_version]
    }
  }
  ```

  

- Obtain the Image Agreement using the parameters we just located : 

  ```
  #Get Image Agreement
  resource "oci_core_app_catalog_listing_resource_version_agreement" "mp_image_agreement" {
    listing_id               = var.mp_listing_id
    listing_resource_version = var.mp_listing_resource_version
  }
  ```

- Agree to the Terms and Conditions:

  ```
  #Accept Terms and Subscribe to the image, placing the image in a particular compartment
  resource "oci_core_app_catalog_subscription" "mp_image_subscription" {
    compartment_id           = var.compartment_ocid
    eula_link                = oci_core_app_catalog_listing_resource_version_agreement.mp_image_agreement[0].eula_link
    listing_id               = oci_core_app_catalog_listing_resource_version_agreement.mp_image_agreement[0].listing_id
    listing_resource_version = oci_core_app_catalog_listing_resource_version_agreement.mp_image_agreement[0].listing_resource_version
    oracle_terms_of_use_link = oci_core_app_catalog_listing_resource_version_agreement.mp_image_agreement[0].oracle_terms_of_use_link
    signature                = oci_core_app_catalog_listing_resource_version_agreement.mp_image_agreement[0].signature
    time_retrieved           = oci_core_app_catalog_listing_resource_version_agreement.mp_image_agreement[0].time_retrieved
  
    timeouts {
      create = "20m"
    }
  }
  ```

### Creating the Compute instance

Finally we are able to start using the image, using the parameter **data.oci_core_app_catalog_listing_resource_version.test_catalog_listing.listing_resource_id** as the image reference to create : 

```
resource "oci_core_instance" "MyWLS" {
  compartment_id      = var.compartment_ocid
  display_name        = var.hostname_1
  shape               = var.sql_shape

  create_vnic_details {
    subnet_id        = var.my_subnet_ocid
    display_name     = "jle-wls"
    hostname_label   = "jle-wls"
  }

  source_details {
    source_id   = data.oci_core_app_catalog_listing_resource_version.test_catalog_listing.listing_resource_id
    source_type = "image"
  }
  lifecycle {
    ignore_changes = [
      source_details[0].source_id,
    ]
  }
}
```

A **sample terraform configuration** can be found in the folder [wls_image](wls_image) of this repository, you just need to fill in your authentication info and tenancy ocid's to try this out.

Attention : You need to run this script 2 times : 

- a first time to obtain the stack parameters, with the file **image_subscription.tff** not taken into account (Terraform will ignore the .tff files)
- then download the stack and fill in the 3 missing parameters in the file **image_subscription.tff**, then rename the file to **image_subscription.tf** for terraform to take it into account
- Now run your `terraform apply` a second time, and the image will be created.



## Next read

Make sure to check out my follow-up article on this topic:

- How to **add Kubernetes node pools consuming the UC flavor** of WebLogic to an existing, customer-build setup of WebLogic on Kubernetes.

