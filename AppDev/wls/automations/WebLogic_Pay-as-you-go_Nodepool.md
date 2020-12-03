# Using Terraform to launch the WebLogic Marketplace Stack - Part 3

This article is the **third chapter** in a series that will explore your options to work with Terraform and the Marketplace Stacks and Images of WebLogic as provided on the Marketplace, offering you the ability to spin up your own customized stacks using the "Pay-as-you-go" consumption of WebLogic licenses.

You will learn how to add a **WebLogic Pay-as-you-go Node Pool** to an existing OKE cluster, thus allowing to easily switch an existing custom setup of WebLogic running on OKE into a pay-as-you-go type of consumption

- In [the first article](Automated_wls_stack_launch.md) you could read how to **automate the launch of the WebLogic stack** as it is provided on Marketplace, using Terraform and a bit of OCI Command Line.
- In [the second article](WebLogic_Pay-as-you-go_Image.md) you learned how to omit the provided automation of the stack, and spin up a UC consumping instance as part of a **custom configuration of WLS** you might already have



## Convert a Customer WebLogic setup running on OKE into Pay-as-you-go

For customers that already have done the work of setting up their own configuration of WebLogic running on OKE, and have **not** used the marketplace images, it is now possible to migrate their setup into a **Pay-as-you-go** UC consuming instance, by simply switching the WLS configuration onto a new Node Pool that is running the UCM licensed (and billed) marketplace image.

The basic principle has already been used in Option 2 of this article : obtain the required "Terms and Conditions" agreements using Terraform, download the Marketplace stack to obtain the OCID's of the correct images.  But instead of spinning up a compute instance, we will now add a node pool to an existing cluster.

Of course you can integrate this logic in your existing automation scripts, allowing you to spin up from scratch a new environment using your existing automation, but nowbased on UC consuming Node Pools.  

For the sake of example, I will do this on an existing running Kubernetes cluster.

### Get the T&C agreements in place

First we need to obtain the required T&C agreements and the URL to the WLS for OKE stack you require (this can be Enterprise Edition or Suite).  This is basically the exact same operation as demonstrated in the previous examples, but now using a different image name as a filter:

```
# DATA 1 - Get a list of element in Marketplace, using filters, eg name of the stack
data "oci_marketplace_listings" "test_listings" {
  name = ["Oracle WebLogic Server Enterprise Edition for OKE UCM"]
  compartment_id = var.compartment_ocid
}
```

As a result, you will obtain the usual URL to the Stack configuration in the **Data 4** element.

Download and unzip the stack, and locate the values you need to subscribe to the image : 

- Open the file **mp-subscription-variables.tf**

  - Locate the lines defining the variable **mp_wls_node_pool_image_id**, and note the default value of the image OCID.

  - Locale the lines defining the **mp_wls_node_pool_listing_id** and note down the App Catalog Listing OCID

  - Locate the line containing the **mp_wls_node_pool_listing_resource_version**, this is a value that looks like :
    `20.4.1-201103061109`


### Setting up the agreement for the image

As already described in Option 2, you can now use these variables to subscribe to this image : 

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

### Creating the Node Pool

With all the element we have collected, you can now spin up a new node pool in an existing OKE cluster.  All you need is the OKE OCID as well as the workernode subnet OCID.

Below a sample of the code required to do this :

```
locals {
    oke_id = "ocid1.cluster.oc1.eu-frankfurt-1.ocid_of_existing OKE"
    subnet_id = "ocid1.subnet.oc1.eu-frankfurt-1.ocid_of_worker_subnet"
	}
	
resource "oci_containerengine_node_pool" "K8S_pool1" {
	cluster_id = local.oke_id
	compartment_id = var.compartment_ocid

  kubernetes_version = "v1.18.10"
	name = "wls_uc_pool"
	node_shape = var.compute_shape

	node_config_details {
	
		dynamic "placement_configs" {
				for_each = local.ad_nums2
				content {
	  		availability_domain = placement_configs.value
	  		subnet_id           = local.subnet_id
					}
			}
   size = 1
	}
  node_source_details {
    image_id    = data.oci_core_app_catalog_listing_resource_version.test_catalog_listing.listing_resource_id
    source_type = "IMAGE"
  }
}

```

Please make sure to use the **same version** for the Node pool as the version of the Kubernetes Cluster you are attaching it to. 

Rerun the Terraform script with the image_subscription.tf file included and your cluster will be extended with a new node pool.  You can now shut down the old node pools, to only run on your new Node pool.

An **example of the Terrafor script** can be found in the folder [wls_nodepool](wls_nodepool)

### Pinning your WebLogic Pods to the new Node Pool

Alternatively you can use the "pinning" mechanism to only run your WebLogic pods on this new "Pay-as-you-go" infrastructure, while keeping other node pools in your cluster for non-WLS workloads.  

To achieve this we will be using node labels and the **nodeSelector** parameter in the WebLogic Domain definition file deployed on the cluster.

- Label your nodes that are running the Pay-as-you-go WebLogic image:

  ```
  kubectl label nodes 130.61.84.41 licensed-for-weblogic=true
  ```

- Change the definition file of your WebLogic domain to include the **nodeSelector** parameter in the **serverPod** section:

  ```
  serverPod:
    env:
    [...]
    nodeSelector:
      licensed-for-weblogic: true
  ```

- Update your domain definition file on the cluster and your WebLogic pods should start migrating to the labeled nodes !

