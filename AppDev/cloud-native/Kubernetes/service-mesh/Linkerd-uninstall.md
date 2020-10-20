[Go to Overview Page](../Kubernetes-labs.md)

![](../../../../common/images/customer.logo2.png)

# Migration of Monolith to Cloud Native

## C. Deploying to Kubernetes

## Optional 3e. Service mesh uninstall


<details><summary><b>Self guided student - video introduction</b></summary>
<p>

This video is an introduction to the uninstalling the service mesh module. Once you've watched it please press the "Back" button on your browser to return to the labs.

[![Uninstalling the service mesh Video](https://img.youtube.com/vi/Hx0amwN3Zjs/0.jpg)](https://youtu.be/Hx0amwN3Zjs "Uninstalling the service mesh")

</p>
</details>

---

## Do I need to uninstall the service mesh ?

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
If you are confident you can handle this (and not complain about the labs being buggy because of these minor changes !) then please feel free to leave linkerd installed, and carry on with the labs.

If however this will cause you problems you can remove the service mesh


## Uninstalling the service mesh

First remove the linkerd annotation on the namespaces

- In the OCI Cloud shell type the following (replace <ns-name with your namespace)
  - `kubectl get namespace <ns-name> -o yaml | linkerd uninject - | kubectl replace -f -`

```
namespace "usernameecho" uninjected

namespace/usernameecho replaced
```

Now restart the deployments to remove the linkerd-proxy sidecar container, as the namespace is no longer annotated as having linkerd enabled the new version will not have the proxy injected automatically.

Let's get the list of deplpyments

- In the OCI Cloud shell type :
  - `kubectl get deployments`

```
NAME           READY   UP-TO-DATE   AVAILABLE   AGE
stockmanager   1/1     1            1           14d
storefront     1/1     1            1           14d
zipkin         1/1     1            1           14d
```

We can see in this case we have deployments for stockmanager, storefront and zipkin. Depending on which other optional modules you've done there may be additional deployments in the list.

Sadly there doesn't seem to be a way to restart all of the deployments in a namespace (maybe that will be added in a future Kubernetes release) so we have to restart each one by it's individual name.

- In the OCI Cloud shell type the following, if you have additional deployments add them to the list

  - `kubectl rollout restart deployments storefront stockmanager zipkin`

```
deployment.apps/storefront restarted
deployment.apps/stockmanager restarted
deployment.apps/zipkin restarted
```


Let's do the same process for the ingress controller  namespace

First update the ingress-nginix namespace to remove the linkerd annotation

- In the OCI Cloud shell type the following 
  - `kubectl get namespace ingress-nginx -o yaml | linkerd uninject - | kubectl replace -f -`

```
namespace "ingress-nginx" uninjected

namespace/ingress-nginx replaced
```

Now get the list of deployments in the ingress-nginx namespace
- In the OCI Cloud shell type :

  - `kubectl get deployments -n ingress-nginx`

```
NAME                                          READY   UP-TO-DATE   AVAILABLE   AGE
ingress-nginx-nginx-ingress-controller        1/1     1            1           35d
ingress-nginx-nginx-ingress-default-backend   1/1     1            1           35d
```

And next update them so the proxy will be removed.


- In the OCI Cloud shell type :

  - `kubectl rollout restart deployments -n ingress-nginx ingress-nginx-nginx-ingress-controller ingress-nginx-nginx-ingress-default-backend`

```
deployment.apps/ingress-nginx-nginx-ingress-controller restarted
deployment.apps/ingress-nginx-nginx-ingress-default-backend restarted
```

Now the data plane elements have been removed let's remove the linkerd control plane (Yes, I know that the linkerd command is install, but the kubectl command is delete, so what happens is the linkerd command generates what it would as if it were doing an install, but the kubectl command takes this input as sequence ot things to delete)

- In the OCI Cloud shell type :

  - `linkerd install --ignore-cluster | kubectl delete -f -`
  
There will be lots of messages about deleting resources, you may get warnings about attempts to delete resources that are not there, these can be ignored.

At the end check to see if the linkerd namespace is still there, it may have been removed, but as we added additional resources (secrets for the ingress rules and the rules themselves) it may still be there

In the OCI Cloud shell type :
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

If you don't see `linkerd` in the list then remove you're done, if (as above) you do then remove it

In the OCI Cloud shell type :
  - `kubectl delete namespace linkerd`

```
namespace "test" deleted
```

Now you have completed the uninstall process

---

You have reached the end of this lab module !!

Use your **back** button to return to the lab sequence document to access further service mesh modules.