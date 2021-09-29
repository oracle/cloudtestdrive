![](../../../../common/images/customer.logo2.png)

# Cloud Native - Service mesh uninstall


<details><summary><b>Self guided student - video introduction</b></summary>


This video is an introduction to the uninstalling the service mesh module. Depending on your browser settings it may open in this tab / window or open a new one. Once you've watched it please return to this page to continue the labs.

[![Uninstalling the service mesh Video](https://img.youtube.com/vi/Hx0amwN3Zjs/0.jpg)](https://youtu.be/Hx0amwN3Zjs "Uninstalling the service mesh")

---

</details>
## Introduction

This is one of the optional sets of Kubernetes labs

**Estimated module duration** 5 mins.

### Objectives

This module shows how to remove the Linkerd service mesh from the pods and the Kubernetes cluster.

### Prerequisites

You need to complete the **Rolling update** module (last of the core Kubernetes labs modules). You must have completed the **Installing the Linkerd service mesh** module. You can have done any of the other optional module sets, or any combination of the other service mesh modules.

## Task 1: Do I need to uninstall the service mesh ?

Leaving the service mesh installed will not cause problems in the rest of the labs, however other lab modules may have been written without the linkerd service mesh installed, and you may in some cases see slightly different output or need to slightly modify your commands in those labs if you leave the linkerd service mesh installed.

For example with the service mesh installed you may see multiple containers in a pod when using `kubectl get pods`

```
NAME                            READY   STATUS    RESTARTS   AGE
stockmanager-7945b54576-9f7q7   2/2     Running   0          173m
storefront-7667fc5fdc-5zwbr     2/2     Running   0          173m
zipkin-7db7558998-c5b5j         2/2     Running   0          173m
```

But if the service mesh was not installed you'd only see one container in the pods

```
NAME                            READY   STATUS    RESTARTS   AGE
stockmanager-7945b54576-9f7q7   1/1     Running   0          173m
storefront-7667fc5fdc-5zwbr     1/1     Running   0          173m
zipkin-7db7558998-c5b5j         1/1     Running   0          173m
```

Also for some tasks kubectl will require you to provide the container name in the pod, for example looking at the logs with the service mesh installed you need to do 

```
kubectl logs stockmanager-7945b54576-9f7q7 stockmanager
```

But if the service mesh was not installed you only need to do

```
kubectl logs stockmanager-7945b54576-9f7q7
```
If you are confident you can handle this (and not complain about the labs being buggy because of these minor changes!) then please feel free to leave linkerd installed, and carry on with the labs.

If however this will cause you problems you can remove the service mesh


## Task 2: Uninstalling the service mesh

First remove the linkerd annotation on the namespaces

  1. In the OCI Cloud shell type the following (replace <ns-name with your namespace)
  
  - `kubectl get namespace <ns-name> -o yaml | linkerd uninject - | kubectl replace -f -`

  ```
namespace "usernameecho" uninjected

namespace/usernameecho replaced
```

Now restart the deployments to remove the linkerd-proxy sidecar container, as the namespace is no longer annotated as having linkerd enabled the new version will not have the proxy injected automatically.

  2. Let's get the list of deployments. In the OCI Cloud shell type 
  
  - `kubectl get deployments`

  ```
NAME           READY   UP-TO-DATE   AVAILABLE   AGE
stockmanager   1/1     1            1           14d
storefront     1/1     1            1           14d
zipkin         1/1     1            1           14d
```

We can see in this case we have deployments for stockmanager, storefront and zipkin. Depending on which other optional modules you've done there may be additional deployments in the list.

Sadly there doesn't seem to be a way to restart all of the deployments in a namespace (maybe that will be added in a future Kubernetes release) so we have to restart each one by it's individual name.

  3.In the OCI Cloud shell type the following, if you have additional deployments from other modules add them to the list

  - `kubectl rollout restart deployments storefront stockmanager zipkin`

  ```
deployment.apps/storefront restarted
deployment.apps/stockmanager restarted
deployment.apps/zipkin restarted
```


Let's do the same process for the ingress controller  namespace

First update the ingress-nginix namespace to remove the linkerd annotation

  4. In the OCI Cloud shell type the following 

  - `kubectl get namespace ingress-nginx -o yaml | linkerd uninject - | kubectl replace -f -`

  ```
namespace "ingress-nginx" uninjected

namespace/ingress-nginx replaced
```

Now get the list of deployments in the ingress-nginx namespace

  5. In the OCI Cloud shell type :

  - `kubectl get deployments -n ingress-nginx`

  ```
NAME                       READY   UP-TO-DATE   AVAILABLE   AGE
ingress-nginx-controller   1/1     1            1           21h
```

And next update them so the proxy will be removed.

  6. In the OCI Cloud shell type :

  - `kubectl rollout restart deployments -n ingress-nginx ingress-nginx-controller`

  ```
deployment.apps/ingress-nginx-nginx-ingress-controller restarted
deployment.apps/ingress-nginx-nginx-ingress-default-backend restarted
```

Now the data plane elements have been removed let's remove the linkerd control plane and extensions (Yes, I know that the linkerd command is install, but the kubectl command is delete, so what happens is the linkerd command generates what it would as if it were doing an install, but the kubectl command takes this input as sequence of things to delete)

  

  7. In the OCI Cloud shell type 

  - `linkerd viz install | kubectl delete -f -`

There will be lots of messages about deleting resources, you may get warnings about attempts to delete resources that are not there, these can be ignored.

  8. In the OCI Cloud shell type 

  - `linkerd install --ignore-cluster | kubectl delete -f -`
  
There will be lots of messages about deleting resources, you may get warnings about attempts to delete resources that are not there, these can be ignored.

At the end check to see if the linkerd namespaces are still there, they may have been removed, but as we added additional resources (secrets for the ingress rules and the rules themselves) they may still be there

  9. In the OCI Cloud shell type 
  
  - `kubectl get namespaces`

  ```
NAME              STATUS   AGE
default           Active   49d
ingress-nginx     Active   48d
kube-node-lease   Active   49d
kube-public       Active   49d
kube-system       Active   49d
linkerd           Active   20d
tg-helidon        Active   48d
```

If you don't see `linkerd` or `linkerd-viz` in the list then remove you're done, if (in the example above the `linkerd` namespace remains) you do then remove them

  10. In the OCI Cloud shell type 

  - `kubectl delete namespace linkerd-viz`

  ```
namespace "linkerd-viz" deleted
```

  11. In the OCI Cloud shell type 

  - `kubectl delete namespace linkerd`

 ```
namespace "linkerd" deleted
```

Now you have completed the uninstall process

## End of the module, What's next ?

You can chose from the other Kubernetes optional module sets.

## Acknowledgements

* **Author** - Tim Graves, Cloud Native Solutions Architect, EMEA OCI Centre of Excellence
* **Contributor** - Charles Pretzer, Bouyant, Inc for reviewing and sanity checking parts of this document.
* **Last Updated By** - Tim Graves, April 2021
