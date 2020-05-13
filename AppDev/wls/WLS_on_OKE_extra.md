[Go to the Cloud Test Drive Welcomer Page](../../readme.md)

![](../../common/images/customer.logo2.png)

# Running WebLogic on Kubernetes

## Manipulating your WebLogic deployment
Once you have your WbebLogic environment operational on Kubernets, you can perform a series of interesting operations that illustrate the flexibility of this setup.

- Scaling your WebLogic cluster via the Operator
- Labeling your nodes to assign WebLogic to specific servers


These operations have been described in a generic way in [this excellent lab](https://github.com/nagypeter/weblogic-operator-tutorial/blob/master/tutorials/domain.home.in.image_short.md) by Peter Nagy.  Below you find a simplified version, using the setup of the Cloud Test Drive environment.

#### Prerequisites

To run this lab, you need to have performed the [Running WebLogic on Kubernetes](WLS_on_OKE.md) lab.



### Scaling your WebLogic cluster

The easiest way to scale a WebLogic cluster in Kubernetes is to simply edit the replicas property within a domain resource. 

- First cd into the correct folder :

  ```
  cd /home/oracle/weblogic-kubernetes-operator/kubernetes/samples/scripts/create-weblogic-domain/domain-home-in-image/out_dir/weblogic-domains/sample-domain1
  ```

- Edit the domain definition file called **domain.yaml**, and find the following part:

```
clusters:
- clusterName: cluster-1
  serverStartState: "RUNNING"
  replicas: 2
```

Modify `replicas` to 3 and save changes. Apply the changes using `kubectl`:

```
kubectl apply -f domain.yaml
```

Check the changes in the number of pods using `kubectl`:

```
kubectl get po -n sample-domain1-ns
NAME                             READY     STATUS        RESTARTS   AGE
sample-domain1-admin-server      1/1       Running       0          57m
sample-domain1-managed-server1   1/1       Running       0          56m
sample-domain1-managed-server2   1/1       Running       0          55m
sample-domain1-managed-server3   1/1       Running       0          1m
```

Soon the managed server 3 will appear and will be ready within a few minutes. You can also check the managed server scaling action using the WebLogic Administration console:

[![alt text](https://github.com/nagypeter/weblogic-operator-tutorial/raw/master/tutorials/images/scaling/check.on.console.png)](https://github.com/nagypeter/weblogic-operator-tutorial/blob/master/tutorials/images/scaling/check.on.console.png)





### Assigning WebLogic Pods to Licensed Node

This lab will illustrate how to assign all WebLogic pods of the WebLogic domain to particular nodes of your cluster..

To assign pod(s) to node(s) you need to label the desired node with a custom tag. Then you can use the `nodeSelector` property in the domain resource definition and set the value of the label you applied on the node.

First get the node names using `kubectl get node`:

```
$ kubectl get node
NAME             STATUS    ROLES     AGE       VERSION
130.61.110.174   Ready     node      11d       v1.11.5
130.61.52.240    Ready     node      11d       v1.11.5
130.61.84.41     Ready     node      11d       v1.11.5
```

In case of OKE the node name can be the Public IP address of the node or the subnet's CIDR Block's first IP address. But obviously a unique string which identifies the node.

Now check the current pod allocation using the detailed pod information `kubectl get pod -n sample-domain1-ns -o wide`:

```
$ kubectl get pod -n sample-domain1-ns -o wide
NAME                             READY     STATUS    RESTARTS   AGE       IP            NODE             NOMINATED NODE
sample-domain1-admin-server      1/1       Running   0          2m        10.244.2.33   130.61.84.41     <none>
sample-domain1-managed-server1   1/1       Running   0          1m        10.244.1.8    130.61.52.240    <none>
sample-domain1-managed-server2   1/1       Running   0          1m        10.244.0.10   130.61.110.174   <none>
sample-domain1-managed-server3   1/1       Running   0          1m        10.244.2.34   130.61.84.41     <none>
```

As you can see from the result Kubernetes evenly deployed the 3 managed servers to the 3 worker nodes. In this scenario choose one of the node where you want to move all pods.

###### Labelling

In this example the licensed node will be: `130.61.84.41`

Label this node. The label can be any string, but now use `licensed-for-weblogic`. Execute `kubectl label nodes  =true` command but replace your node name and label properly:

```
$ kubectl label nodes 130.61.84.41 licensed-for-weblogic=true
node/130.61.84.41 labeled
```

###### Modify domain resource definition

Open your `domain.yaml` in text editor and find the `serverPod:` entry and insert a new property inside:

```
serverPod:
  env:
  [...]
  nodeSelector:
    licensed-for-weblogic: true
```

Be careful with the indentation. The result should look similar to this section, with **spaces** before the insterted parts (not tabs!)

```
  ...
  
  serverStartPolicy: "IF_NEEDED"

  serverPod:
    # an (optional) list of environment variable to be set on the servers
    env:
    - name: JAVA_OPTIONS
      value: "-Dweblogic.StdoutDebugEnabled=false"
    - name: USER_MEM_ARGS
      value: "-XX:+UseContainerSupport -Djava.security.egd=file:/dev/./urandom "
    nodeSelector:
      licensed-for-weblogic: true
    # volumes:
    
...
```

​	

Save the changes and apply the new domain resource definition.

```
$ kubectl apply -f ~/git.repos/@nagypeter/weblogic-operator-tutorial/k8s/domain.yaml
domain.weblogic.oracle/sample-domain1 configured
```

The operator according to the changes will start to relocate servers. Poll the pod information and wait until the expected result:

```
$ kubectl get po -n sample-domain1-ns -o wide
NAME                             READY     STATUS    RESTARTS   AGE       IP            NODE           NOMINATED NODE
sample-domain1-admin-server      1/1       Running   0          4h        10.244.2.40   130.61.84.41   <none>
sample-domain1-managed-server1   1/1       Running   0          4h        10.244.2.43   130.61.84.41   <none>
sample-domain1-managed-server2   1/1       Running   0          4h        10.244.2.42   130.61.84.41   <none>
sample-domain1-managed-server3   1/1       Running   0          4h        10.244.2.41   130.61.84.41   <none>
```

##### Delete label and `nodeSelector` entries in `domain.yaml`

To delete the node assignment delete the node's label using `kubectl label node  -` command but replace the node name properly:

```
$ kubectl label nodes 130.61.84.41 licensed-for-weblogic-
node/130.61.84.41 labeled
```

Delete or turn into comment the entries you added for node assignment in your `domain.yaml` and apply:

```
$ kubectl apply -f /u01/domain.yaml
domain.weblogic.oracle/sample-domain1 configured
```

The pod reallocation/restart can happen based on the scheduler decision.





---

Use the ***Back*** button of your browser to return to the home page of the tutorials.
