![](../../../common/images/customer.logo2.png)

# Finished with the Kubernetes cluster

This is an **optional** step, only follow it if you are sure you no longer want to use the Kubernetes cluster.

We've finished the steps using the Kubernetes cluster now. You can of course leave it running, or if you prefer you can delete it. If you are running this in a Oracle tenancy (e.g. Live labs or the cloud test drive) then these resources will be automatically deleted shortly after the labs finish, so in that case you do not need to do anything.

## Introduction

This is an optional module

**Estimated module duration** 5 mins.

### Objectives

If you chose to follow the instructions this optional module will guide you through the process of terminating the resources you have been using.

### Prerequisites

**If** you decide to do this then you should have finished the Kubernetes lab modules you have chosen to do. Once you delete these resources you will not be able to recover them except by doing the lab again.

## Step 1: Cleaning out your cluster

As some of the resources you've created in the Kubernetes cluster are actually outside the cluster we need to terminate the in cluster elements cleanly so that the cluster management will clean up the OCI level resources (e.g. load balancers, storage reservations etc.)

  1. Get a list of the cluster namespaces
  
  - `kubectl get namespaces`
  
  ```
NAME              STATUS   AGE
default           Active   48d
ingress-nginx     Active   46d
kube-node-lease   Active   48d
kube-public       Active   48d
kube-system       Active   48d
monitoring        Active   46d
tg-helidon        Active   46d
```

If you've been following all of the instructions to tidy up the cluster at the end of the lab modules you should only have the `ingress-nginx` and `<your initials>-helidon` namespaces plus the system namespaces (starting with `kube-`) remaining, however it's quite possible (as in this case) that you haven't remembered to tidy up and there are others remaining (`monitoring` in the example here)

  2. For each of the non `ingress-nginx` and  `<your initials>-helidon` namespaces delete them
  
  - `kubectl delete namespace <name>`
  
  For example :
  
  `kubectl delete namespace monitoring`

  ```
namespace "monitoring" deleted  
```

Once you have finished deleting the non system and `ingress-nginx` and  `<your initials>-helidon` namespaces

  3. Delete your working namespace
  
  - `kubectl delete namespace <your initials>-helidon`
  
  For example :
  
  `kubectl delete namespace tg-helidon`

  ```
namespace "tg-helidon" deleted  
```

  4. Delete the `ingress-nginx` namespace
  
  - `kubectl delete namespace ingress-nginx`

  ```
namespace "ingress-nginx deleted  
```

## Step 2: Terminating the Kubernetes cluster

This will destroy the Kubernetes cluster you have been using.

  1. Log in to your Oracle Cloud account in the web browser **on your computer** not the one in the virtual machine.
  
  2. Click the `Hamburger` menu, then in the `Solutions and Platform` section navigate to `Developer Services` -> `Kubernetes Clusters`.
  
  3. Make sure you are in the `CTDOKE` compartment (chose this on the left)
  
  4. Locate **your** cluster in the list, if you are using a shared tenancy, for example a company paid tenancy then **double check** that you have chosen the right cluster
  
  5. Click the name of **your** cluster in the list, this will take you to the instance page for the cluster
  
  6. Double check that this is the page for **your** cluster.
  
  7. Having made sure that this is **your** cluster (and remember, if it's not someone is going to be extremely cross with you) click the `Delete CLuster` button.
 
  8. In the popup **confirm** that the name is the name you used (check your initials) and if you are **absolutley** sure click the `Delete` button
  
OCI will then start the termination process. This can take a short while. If you change your mind it's now to late.

## What's next

Depending on the modules you have done you may wish to also delete the database, network resources and compartment.

## Acknowledgements

* **Author** - Tim Graves, Cloud Native Solutions Architect, EMEA OCI Centre of Excellence
* **Last Updated By** - Tim Graves, November 2020

