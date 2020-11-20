![](../../../common/images/customer.logo2.png)

# Creating your own Kubernetes cluster

**ATTENTION !!!** 

If you are doing the lab self guided, or the instructor does not tell you they have created a cluster for you then you need to complete this section.

If you are in an instructor led lab they **may** have already created Kubernetes clusters for you, **only** in the situation where you have been given a kubeconfig file and you do not need to continue with this section.



## Introduction

**Estimated module duration** 5 mins.

### Objectives

Creating a Managed Kubernetes cluster on the Oracle Cloud.  

### Prerequisites

If you are doing the full labs (these include modules on Helidon and Docker) you need to have completed the steps in the **Helidon** modules (including the setup)

If you are only doing the Kubernetes based labs you need to have completed the steps in the **Tenancy Setup for the Kubernetes Labs** module.

## Step 1: Creating your Kubernetes cluster

### Step 1a: Navigate to the Managed Kubernetes dashboard

  1. Log into the **OCI Console** 

  2. Once on the **OCI infrastructure** page, click on the "Hamburger" menu  
  
  3. Scroll down to **Solutions and Platform** section, Click **Developer services**, then **Container Clusters (OKE)**

  4. In the **List Scope** section, use the dropdown to select the `CTDOKE` compartment
  
  - You may have to expand the tree nodes to locate this compartment

  5. Click the **Create Cluster** button at the top of the clusters list

  6. Choose the option for the **Quick Create**, then click the **Launch workflow** button



### Step 1b: Creating the cluster

Fill in the form with following parameters:

  1. Set the cluster **Name** to be something like `Helidon-Lab-YOUR-INITIALS`
  
  2.  Make sure the **Compartment** is `CTDOKE`
  
  3.  Make sure the **Kubernetes version** is the highest on the list (at the time of the last update of this document in November 2020 that was 1.18.10, but it may have been updated since then)
  
  4. Check the **Visibility type** is **Private**
  
  5. Set the **Shape** dropdown to VM.Standard2.1
  
  6. Set the **Number of nodes** to be 2

There is no need to do anything in the Advanced Options section.

These images are for creating a 1.16.8 cluster, they may be slightly different for later versions.
 
  ![](images/create-k8s-cluster.png)

  7. Click the **Next** button to go to the review page.

  8. On the review page check the details you have provided are correct

  9. Click the **Create Cluster** button.

You'll be presented with a progress option, if you want read what's happening

  10. Scroll to the bottom and click the **Close** button

The state will be "Creating" for a few minutes (usually 3-4 mins)

## End of the cluster setup, What's next ?

You can move on to the **Cloud Shell Setup for the Kubernetes Labs** module while the cluster continues to be provisioned.

## Acknowledgements

* **Author** - Jan Leemans, Director Business Development, EMEA Divisional Technology
* **Contributor** - Tim Graves, Cloud Native Solutions Architect, EMEA OCI Centre of Excellence
* **Last Updated By** - Tim Graves, November 2020

## Need Help ?

If you are doing this module as part of an instructor led lab then please just ask the instructor.

If you are working through this module self guided then please submit feedback or ask for help using our [LiveLabs Support Forum](https://community.oracle.com/tech/developers/categories/OCI%20Native%20Development). Please click the **Log In** button and login using your Oracle Account. Click the **Ask A Question** button to the left to start a *New Discussion* or *Ask a Question*.  Please include your workshop name and lab name.  You can also include screenshots and attach files.  Engage directly with the author of the workshop.