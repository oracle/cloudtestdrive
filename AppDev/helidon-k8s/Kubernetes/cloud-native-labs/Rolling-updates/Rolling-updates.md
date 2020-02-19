[Go to Overview Page](../Kubernetes-labs.md)

![](../../../../../common/images/customer.logo2.png)

# Migration of Monolith to Cloud Native

## C. Deploying to Kubernetes
## 6. Rolling Updates

### **Introduction**

One of the problems when deploying an application is how to update it while still delivering service, and perhaps more important (but usually given little consideration) how to revert the changes in the event that the update fails to work in some way.

Changes by the way come in multiple areas, it could be application code changes (Kubernetes sees these as a change in the container image) or it could be a change in the configuration defining a deployment (and it's replica sets / pods)

The update process for code changes involves using your development tooling to create a new container based on the changed code (You presumably have separate processes for managing your source code versions.) As part of your container creation process you **must** give it a different version number so it's easy to identify which container comes from which version of your source code, and also to ensure you differentiate between different releases at the image level. You'd then update the service definition to use the new image by editing and applying the yaml file or using kubectl to directly change the container image.

The update process for configuration changes is to modify the yaml file that defines your service, for example defining different volume mounts, and then applying the change, or to issue a kubectl command to directly update the change.

For *both* cases Kubernetes will keep track of the changes and will undetake a rolling upgrade strategy.

As a general observation though it may be tempting to just go in and modify the configuration directly with kubectl ... this is a **bad** thing to do, it's likely to lead to unrecorded changes in your configuration management system so in the event that you had to do a complete restart of the system changes manually done with kubectl are likely to be forgotten. It is **strongly** recommended that you make changes by modifying your yaml file, and that the yaml file itself has a versioning scheme so you can identify exactly what versions of the service a given yaml file version provides. If you must make changes using kubectl (say you need to make a minor change in a test environment) then as soon as you decide it should be permanent then make the corresponding change in the yaml file *and do a rolling upgrade using the yaml file to ensure you are using the correct configuration* (after all, you may have made a typo in either the kubectl or yaml file.)

### How to do a rolling upgrade in our setup

So far we've been stopping our services (the undeploy.sh script deletes the deployments) and then creating new ones (the deploy.sh script applies the deployment configurations for us) This results in service down time, and we don't want that. But before we can switch to properly using rolling upgrades there are a few bits of configuration we should do

####Pod counts
Kubernetes aims to keep a service running during the rolling upgrade, it does this by starting new pods to run the service, then stopping old ones once the new ones are ready. Through the magic of services and using labels as selectors the Kubernetes run time adds and removed pods from the service. This will work with a deployment whose replica sets only contain a single pod (the new pod will be started before the old one is stopped) but if your service contains multiple pods it will use some configuration rules to try and manage the process in a more balanced manner.

We are going to once again edit the storefront-deployment.yaml file to give Kubernetes some rules to follow when doing a rolling upgrade. Importantly however we're going to edit a *Copy* of the file so we have a history.

- In a terminal window navigate to the folder **helidon-kubernetes**
- Copy the storefront-deployment yaml file:
  -  `cp storefront-deployment.yaml storefront-deployment-v0.0.1.yaml`

- Edit the new file **storefront-deployment-v0.0.1.yaml** for editing

The current contents of the section of the file looks like this:

```
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: storefront
spec:
  replicas: 1 
  selector:
    matchLabels:
      app: storefront
  template:
    metadata:
      labels:
        app: storefront
```

- Set the number of replicas to 4:
  -  `replicas: 4`

We're now going to force any upgrades to be rolling upgrades 

- After the replicas:4 line,  add

  ```
    strategy:
      type: RollingUpdate
  ```

Finally we're going to tell kubernetes what limits we want to place on the rolling upgrade. 

- Under the type line above, and **at the same indent** add the following

  ```
      rollingUdate:
        maxSurge: 1
        maxUnavailable: 1
  ```

This limits the rollout process to having no more than 1 additional pods online above the normal replicas set, and only one pod below that specified in the replica set unavailable. So the roll out (in this case) allows us to have up to 5 pods running during the rollout and requires that at least 3 are running.

Note that unless you have very specific needs the default settings for strategy type and maxSurge / minUnavailable. We are setting these for two reasons. First to show that the settings are available, and secondly for the purposes of this lab to show the roll out process in a way that let's us actually see what's happening by slowing things down (of course in a production you'd want it to run as fast as possible, so think about the settings used if you do override the defaults)

The section of the file after the changes will look like this

```
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: storefront
spec:
  replicas: 1 
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 1
  selector:
    matchLabels:
      app: storefront
  template:
    metadata:
      labels:
        app: storefront
```

- Save the changes



### Actually doing the rollout
To do the roll out we're just going to apply the new file. Kubernetes will compare that to the old config and update appropriately.

- Apply the new config
  -  `kubectl apply -f storefront-deployment-v0.0.1.yaml`

```
deployment.extensions/storefront configured
```

-  We can have a look at the status of the rollout
  -  `kubectl rollout status deployment storefront`

```
deployment "storefront" successfully rolled out
```

All went well, and let's also look at the history of this and previous roll outs:

-  `kubectl rollout history  deployment storefront`

```
deployment.extensions/storefront 
REVISION  CHANGE-CAUSE
1         kubectl apply --filename=storefront-deployment.yaml --record=true
```

We can see that the previous state of the deployment resulted from us doing the initial apply. Note that the filename is specified in the rollout, as long as we version our file names we will be able to know exactly what configuration was applied to different versions of the deployment.

One point to note here, these changes *only* modified the deployment roll out configuration, there was no need to actually stop or start any pods as those were unchanged.

### Making a change that updates the pods

**Preparing our new image**
Let's do something that will trigger the pods to update : change the image.  The **buildV0.0.2PushToRepo.sh** script will create and push a new version of the container image for version 0.0.2

We will change the version text of the data returned by the isAlive method to see the difference:

- In Eclipse, navigate to the **helidon-labs-storefront** project
  - Then navigate to **src/main/java**, then **com.oracle.labs.helidon.storefront**, then **resources**
  - Open the file **StatusResource.java** 
  - Change the version in the below part of the code to **0.0.2** 

  ```
	  public JsonObject isAlive() throws InterruptedException {
		  return JSON.createObjectBuilder().add("name", storename).add("alive", true).add("version", "0.0.2").build();
	  }
  ```

  - Save the changes

- In a terminal window, let's build the new version of the container:

  -  Change to folder **helidon-labs-storefront**
  - Run the v2 script:
    -  `./buildV0.0.2PushToRepo.sh `

```
Using repository fra.ocir.io/oractdemeabdmnative/tg_repo
[MVNVM] Using maven: 3.5.2
[INFO] Scanning for projects...

<Lots of Maven output removed>

[INFO] Total time: 23.872 s
[INFO] Finished at: 2020-01-03T12:13:40Z
[INFO] Final Memory: 39M/188M
[INFO] ------------------------------------------------------------------------
Sending build context to Docker daemon  112.1kB
Step 1/3 : FROM jib-storefront:latest
 ---> d31de67d9272
Step 2/3 : RUN cp -r /app/resources/* /app/classes
 ---> Running in 818de3f3faec
Removing intermediate container 818de3f3faec
 ---> 121bb2f37bb7
Step 3/3 : RUN rm -rf /app/resources
 ---> Running in 9d650231ec09
Removing intermediate container 9d650231ec09
 ---> df30253a82ec
Successfully built df30253a82ec
Successfully tagged fra.ocir.io/oractdemeabdmnative/tg_repo/storefront:latest
Successfully tagged fra.ocir.io/oractdemeabdmnative/tg_repo/storefront:0.0.2
The push refers to repository [fra.ocir.io/oractdemeabdmnative/tg_repo/storefront]
7f699cf87b87: Pushed 
76ad72d8097b: Pushed 
b158b5f94634: Pushed 
341c644e75cf: Pushed 
84fad9f97da3: Layer already exists 
2f6d5006f5d1: Layer already exists 
1608029e89ad: Layer already exists 
03ff63c55220: Layer already exists 
bee1e39d7c3a: Layer already exists 
1f59a4b2e206: Layer already exists 
0ca7f54856c0: Layer already exists 
ebb9ae013834: Layer already exists 
latest: digest: sha256:65db7b35e2f2bd73f0010771f66794034eecddb6b10b69a3f34b9a8ffd16d8f5 size: 2839
The push refers to repository [fra.ocir.io/oractdemeabdmnative/tg_repo/storefront]
7f699cf87b87: Layer already exists 
76ad72d8097b: Layer already exists 
b158b5f94634: Layer already exists 
341c644e75cf: Layer already exists 
84fad9f97da3: Layer already exists 
2f6d5006f5d1: Layer already exists 
1608029e89ad: Layer already exists 
03ff63c55220: Layer already exists 
bee1e39d7c3a: Layer already exists 
1f59a4b2e206: Layer already exists 
0ca7f54856c0: Layer already exists 
ebb9ae013834: Layer already exists 
0.0.2: digest: sha256:65db7b35e2f2bd73f0010771f66794034eecddb6b10b69a3f34b9a8ffd16d8f5 size: 2839
built and pushed v0.0.2

```

There is a lot of output, most of which has been removed in the example output above. You can see that the 0.0.2 version has been pushed to the repo.

(Note the Maven output may refer to v0.0.1, don't worry this is because we haven't changes the version details in the maven pom.xml file. The later stages of the process override this.)

### Applying our new image
To apply the new v0.0.2 image we need to upgrade the configuration again. As discussed above this we would *normally* and following best practice do this by creating a new version of the deployment yaml file (say storefront-deploymentv0.0.2.yaml to match the container and code versions)

However ... for the purpose of showing how this can be done using kubectl we are going to do this using the command line, not a configuration file change. This **might** be somethign you'd do in a test environment, but **don't** do it in a production environment or your change management processes may end up broken.

- Execute the command : 
  -  `kubectl set image deployment storefront storefront=fra.ocir.io/oractdemeabdmnative/tg_repo/storefront:0.0.2`

```
deployment.extensions/storefront image updated
```

- Let's look at the status of our setup during the roll out
  -  `kubectl get all`

```
NAME                                READY   STATUS    RESTARTS   AGE
pod/stockmanager-6759d989bf-mtn76   1/1     Running   0          28m
pod/storefront-5f777cb4f5-7tlkb     1/1     Running   0          28m
pod/storefront-5f777cb4f5-8wnfm     1/1     Running   0          27m
pod/storefront-5f777cb4f5-gsbwd     1/1     Running   0          27m
pod/storefront-79d7d954d6-5g5ng     0/1     Running   0          5s
pod/storefront-79d7d954d6-m6qrg     0/1     Running   0          5s
pod/zipkin-88c48d8b9-r9vx2          1/1     Running   0          28m

NAME                   TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)             AGE
service/stockmanager   ClusterIP   10.110.224.255   <none>        8081/TCP,9081/TCP   28m
service/storefront     ClusterIP   10.99.139.139    <none>        8080/TCP,9080/TCP   28m
service/zipkin         ClusterIP   10.104.158.61    <none>        9411/TCP            28m

NAME                           READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/stockmanager   1/1     1            1           28m
deployment.apps/storefront     3/4     2            3           28m
deployment.apps/zipkin         1/1     1            1           28m

NAME                                      DESIRED   CURRENT   READY   AGE
replicaset.apps/stockmanager-6759d989bf   1         1         1       28m
replicaset.apps/storefront-5f777cb4f5     3         3         3       28m
replicaset.apps/storefront-79d7d954d6     2         2         0       5s
replicaset.apps/zipkin-88c48d8b9          1         1         1       28m
```

We're going to look at these in a different order to the output

Firstly the deployments info. We can see that 3 out of 4 pods are available, this is because we specified a maxUnavailable of 1, so as we have 4 replicas we must always have 3 of them available.

If we look at the replica sets we seem something unusual. There are *two* replica sets for the storefront. the origional replica set (`storefront-5f777cb4f5z`) has 3 pods available and running, one of them was stopped as we allow one a maxUnavailable of 1. There is however an additional storefront replica set `storefront-79d7d954d6` This has 2 pods in it, at the time the data was gathered neither of them was ready. But why 2 pods when we'd only specified a surge over the replicas count of 1 pod ? That's because we have one pod count "available" to us form the surge, and another "available" to us because we're allowed to kill of one pod below the replicas count, making a total of two new pods that can be started.

Finally if we look at the pods themselves we see that there are five storefront pods. A point on pod naming, the first part of the pod name is actually the replica set the pod is in, so the three pods starting `storefront-5f777cb4f5-` are actually in the replic set `storefront-5f777cb4f5` (the old one) and the two pods starting `storefront-79d7d954d6-` are in the `storefront-79d7d954d6` replica set (the new one)

Basically what kuberntes has done is created a new replica set and started some new pods in it by adjusting the number of pod replicas in each set, maintaingi the overall count of having 3 pods available at all times, and only one additional pod over the replica count set in the deployment. Over time as those new pods come onlinein the nre replica set **and** pass their readiness test, then they can provide the service and a the **old** replica set will be reduced by one pod, allowing another new pod to be started.

- Rerun the status command a few times to see the changes 
  -  `kubectl get all`

If we look at the output again we can see the progress (note that the exact results will vary depending on how long after the previous kubectl get all command you ran this one.)

```
NAME                                READY   STATUS    RESTARTS   AGE
pod/stockmanager-6759d989bf-mtn76   1/1     Running   0          29m
pod/storefront-5f777cb4f5-7tlkb     1/1     Running   0          29m
pod/storefront-79d7d954d6-5g5ng     1/1     Running   0          63s
pod/storefront-79d7d954d6-7z2df     0/1     Running   0          17s
pod/storefront-79d7d954d6-h6qv7     0/1     Running   0          16s
pod/storefront-79d7d954d6-m6qrg     1/1     Running   0          63s
pod/zipkin-88c48d8b9-r9vx2          1/1     Running   0          29m

NAME                   TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)             AGE
service/stockmanager   ClusterIP   10.110.224.255   <none>        8081/TCP,9081/TCP   29m
service/storefront     ClusterIP   10.99.139.139    <none>        8080/TCP,9080/TCP   29m
service/zipkin         ClusterIP   10.104.158.61    <none>        9411/TCP            29m

NAME                           READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/stockmanager   1/1     1            1           29m
deployment.apps/storefront     3/4     4            3           29m
deployment.apps/zipkin         1/1     1            1           29m

NAME                                      DESIRED   CURRENT   READY   AGE
replicaset.apps/stockmanager-6759d989bf   1         1         1       29m
replicaset.apps/storefront-5f777cb4f5     1         1         1       29m
replicaset.apps/storefront-79d7d954d6     4         4         2       63s
replicaset.apps/zipkin-88c48d8b9          1         1         1       29m
```

Kubectl provides an easier way to look at the status of our rollout

- Issue the command : `kubectl rollout status deployment storefront`

```
Waiting for deployment "storefront" rollout to finish: 3 out of 4 new replicas have been updated...
Waiting for deployment "storefront" rollout to finish: 3 out of 4 new replicas have been updated...
Waiting for deployment "storefront" rollout to finish: 1 old replicas are pending termination...
Waiting for deployment "storefront" rollout to finish: 1 old replicas are pending termination...
Waiting for deployment "storefront" rollout to finish: 1 old replicas are pending termination...
Waiting for deployment "storefront" rollout to finish: 3 of 4 updated replicas are available...
deployment "storefront" successfully rolled out
```
Kubectl provides us with a monitor which updates over time. Once all of the deployment is updated then kubectl returns.

If we look at the setup now we can see that the storefront is running only the new pods, and that there are 4 pods providing the service.

-  `kubectl get all`

```
NAME                                READY   STATUS    RESTARTS   AGE
pod/stockmanager-6759d989bf-mtn76   1/1     Running   0          30m
pod/storefront-79d7d954d6-5g5ng     1/1     Running   0          108s
pod/storefront-79d7d954d6-7z2df     1/1     Running   0          62s
pod/storefront-79d7d954d6-h6qv7     1/1     Running   0          61s
pod/storefront-79d7d954d6-m6qrg     1/1     Running   0          108s
pod/zipkin-88c48d8b9-r9vx2          1/1     Running   0          30m

NAME                   TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)             AGE
service/stockmanager   ClusterIP   10.110.224.255   <none>        8081/TCP,9081/TCP   30m
service/storefront     ClusterIP   10.99.139.139    <none>        8080/TCP,9080/TCP   30m
service/zipkin         ClusterIP   10.104.158.61    <none>        9411/TCP            30m

NAME                           READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/stockmanager   1/1     1            1           30m
deployment.apps/storefront     4/4     4            4           30m
deployment.apps/zipkin         1/1     1            1           30m

NAME                                      DESIRED   CURRENT   READY   AGE
replicaset.apps/stockmanager-6759d989bf   1         1         1       30m
replicaset.apps/storefront-5f777cb4f5     0         0         0       30m
replicaset.apps/storefront-79d7d954d6     4         4         4       108s
replicaset.apps/zipkin-88c48d8b9          1         1         1       30m
```

One important point is that you'll see that the **old** replica set is still around, even though it hasn't got any pods assigned to it. This is because it still holds the configuration that was in place before if we wanted to rollback (we'll see this later)

- if we now look at the history we see that there have been two sets of changes
  -  `kubectl rollout history deployment storefront`

```
deployment.extensions/storefront 
REVISION  CHANGE-CAUSE
1         kubectl apply --filename=storefront-deployment.yaml --record=true
2         <none>
```

Note that the 2nd revision doesn't tell us what change, another reason we should use configuration files to do this !

- Let's check on our deployment to make sure that the image is the v0.0.2 we expect
  -  `kubectl describe deployment storefront`

```
Name:                   storefront
Namespace:              tg-helidon
CreationTimestamp:      Fri, 03 Jan 2020 11:58:05 +0000
Labels:                 app=storefront
Annotations:            deployment.kubernetes.io/revision: 2
                        kubectl.kubernetes.io/last-applied-configuration:
                          {"apiVersion":"extensions/v1beta1","kind":"Deployment","metadata":{"annotations":{},"name":"storefront","namespace":"tg-helidon"},"spec":{...
Selector:               app=storefront
Replicas:               4 desired | 4 updated | 4 total | 4 available | 0 unavailable
StrategyType:           RollingUpdate
MinReadySeconds:        0
RollingUpdateStrategy:  1 max unavailable, 1 max surge
Pod Template:
  Labels:  app=storefront
  Containers:
   storefront:
    Image:       fra.ocir.io/oractdemeabdmnative/tg_repo/storefront:0.0.2
    Ports:       8080/TCP, 9080/TCP
    Host Ports:  0/TCP, 0/TCP
    Limits:
      cpu:        250m
    Liveness:     http-get http://:health-port/health/live delay=60s timeout=5s period=5s #success=1 #failure=3
    Readiness:    exec [/bin/bash -c curl -s http://localhost:9080/health/ready | json_pp | grep "\"outcome\" : \"UP\""] delay=15s timeout=5s period=10s #success=1 #failure=1
    Environment:  <none>
    Mounts:
      /conf from sf-config-map-vol (ro)
      /confsecure from sf-conf-secure-vol (ro)
  Volumes:
   sf-conf-secure-vol:
    Type:        Secret (a volume populated by a Secret)
    SecretName:  sf-conf-secure
    Optional:    false
   sf-config-map-vol:
    Type:      ConfigMap (a volume populated by a ConfigMap)
    Name:      sf-config-map
    Optional:  false
Conditions:
  Type           Status  Reason
  ----           ------  ------
  Available      True    MinimumReplicasAvailable
OldReplicaSets:  storefront-79d7d954d6 (4/4 replicas created)
NewReplicaSet:   <none>
Events:
  Type    Reason             Age   From                   Message
  ----    ------             ----  ----                   -------
  Normal  ScalingReplicaSet  51m   deployment-controller  Scaled up replica set storefront-5f777cb4f5 to 1
  Normal  ScalingReplicaSet  50m   deployment-controller  Scaled up replica set storefront-5f777cb4f5 to 4
  Normal  ScalingReplicaSet  23m   deployment-controller  Scaled up replica set storefront-79d7d954d6 to 1
  Normal  ScalingReplicaSet  23m   deployment-controller  Scaled down replica set storefront-5f777cb4f5 to 3
  Normal  ScalingReplicaSet  23m   deployment-controller  Scaled up replica set storefront-79d7d954d6 to 2
  Normal  ScalingReplicaSet  22m   deployment-controller  Scaled down replica set storefront-5f777cb4f5 to 2
  Normal  ScalingReplicaSet  22m   deployment-controller  Scaled up replica set storefront-79d7d954d6 to 3
  Normal  ScalingReplicaSet  22m   deployment-controller  Scaled down replica set storefront-5f777cb4f5 to 1
  Normal  ScalingReplicaSet  22m   deployment-controller  Scaled up replica set storefront-79d7d954d6 to 4
  Normal  ScalingReplicaSet  21m   deployment-controller  Scaled down replica set storefront-5f777cb4f5 to 0
```

We see the usual deployment info, the Image is indeed the new one we specified, `fra.ocir.io/oractdemeabdmnative/tg_repo/storefront:0.0.2` and the events log section shows us the various stages of rolling out the update.

We should of course check that out update is correctly delivering a service

```
$ curl -i -X GET -u jack:password http://localhost:80/store/stocklevel
HTTP/1.1 200 OK
Server: openresty/1.15.8.2
Date: Fri, 03 Jan 2020 12:56:24 GMT
Content-Type: application/json
Content-Length: 184
Connection: keep-alive

[{"itemCount":4980,"itemName":"rivet"},{"itemCount":4,"itemName":"chair"},{"itemCount":981,"itemName":"door"},{"itemCount":25,"itemName":"window"},{"itemCount":20,"itemName":"handle"}]
```
- Now let's check the output form the StausResource:
  -  `curl -i -X GET http://my-ip:80/sf/status`

```
HTTP/1.1 200 OK
Server: openresty/1.15.8.2
Date: Fri, 03 Jan 2020 12:56:15 GMT
Content-Type: application/json
Content-Length: 49
Connection: keep-alive

{"name":"My Shop","alive":true,"version":"0.0.2"}
```
As expected it's reporting version 0.0.2

### Rolling back a update
In this case the update worked, but what would happen if it had for some reason failed. Fortunately for us Kubernetes keeps the old replica set around, which includes the config for just this reason. 

- Let's get the replica set list:
  -  `kubectl get replicaset`

```
NAME                                                     DESIRED   CURRENT   READY   AGE
ingress-nginx-nginx-ingress-controller-57747c8999        1         1         1       4m44s
ingress-nginx-nginx-ingress-default-backend-54b9cdbd87   1         1         1       4m44s
stockmanager-6759d989bf                                  1         1         1       61m
storefront-5f777cb4f5                                    0         0         0       61m
storefront-79d7d954d6                                    4         4         4       33m
zipkin-88c48d8b9                                         1         1         1       61m
```

- And let's look at the latest storefront replica
  -  `kubectl describe replicaset storefront-79d7d954d6`

```
Name:           storefront-79d7d954d6
Namespace:      tg-helidon
Selector:       app=storefront,pod-template-hash=79d7d954d6
Labels:         app=storefront
                pod-template-hash=79d7d954d6
Annotations:    deployment.kubernetes.io/desired-replicas: 4
                deployment.kubernetes.io/max-replicas: 5
                deployment.kubernetes.io/revision: 2
Controlled By:  Deployment/storefront
Replicas:       4 current / 4 desired
Pods Status:    4 Running / 0 Waiting / 0 Succeeded / 0 Failed
Pod Template:
  Labels:  app=storefront
           pod-template-hash=79d7d954d6
  Containers:
   storefront:
    Image:       fra.ocir.io/oractdemeabdmnative/tg_repo/storefront:0.0.2
    Ports:       8080/TCP, 9080/TCP
    Host Ports:  0/TCP, 0/TCP
    Limits:
      cpu:        250m
    Liveness:     http-get http://:health-port/health/live delay=60s timeout=5s period=5s #success=1 #failure=3
    Readiness:    exec [/bin/bash -c curl -s http://localhost:9080/health/ready | json_pp | grep "\"outcome\" : \"UP\""] delay=15s timeout=5s period=10s #success=1 #failure=1
    Environment:  <none>
    Mounts:
      /conf from sf-config-map-vol (ro)
      /confsecure from sf-conf-secure-vol (ro)
  Volumes:
   sf-conf-secure-vol:
    Type:        Secret (a volume populated by a Secret)
    SecretName:  sf-conf-secure
    Optional:    false
   sf-config-map-vol:
    Type:      ConfigMap (a volume populated by a ConfigMap)
    Name:      sf-config-map
    Optional:  false
Events:
  Type    Reason            Age   From                   Message
  ----    ------            ----  ----                   -------
  Normal  SuccessfulCreate  33m   replicaset-controller  Created pod: storefront-79d7d954d6-m6qrg
  Normal  SuccessfulCreate  33m   replicaset-controller  Created pod: storefront-79d7d954d6-5g5ng
  Normal  SuccessfulCreate  33m   replicaset-controller  Created pod: storefront-79d7d954d6-7z2df
  Normal  SuccessfulCreate  33m   replicaset-controller  Created pod: storefront-79d7d954d6-h6qv7
```

If we look at the Image we can see it's my v0.0.2 image. We can also see stuff like the pods being added during the update

- But let's look at the old replica set:
  -  `kubectl describe replicaset storefront-5f777cb4f5`

```
Name:           storefront-5f777cb4f5
Namespace:      tg-helidon
Selector:       app=storefront,pod-template-hash=5f777cb4f5
Labels:         app=storefront
                pod-template-hash=5f777cb4f5
Annotations:    deployment.kubernetes.io/desired-replicas: 4
                deployment.kubernetes.io/max-replicas: 5
                deployment.kubernetes.io/revision: 1
                kubernetes.io/change-cause: kubectl apply --filename=storefront-deployment.yaml --record=true
Controlled By:  Deployment/storefront
Replicas:       0 current / 0 desired
Pods Status:    0 Running / 0 Waiting / 0 Succeeded / 0 Failed
Pod Template:
  Labels:  app=storefront
           pod-template-hash=5f777cb4f5
  Containers:
   storefront:
    Image:       fra.ocir.io/oractdemeabdmnative/tg_repo/storefront:0.0.1
    Ports:       8080/TCP, 9080/TCP
    Host Ports:  0/TCP, 0/TCP
    Limits:
      cpu:        250m
    Liveness:     http-get http://:health-port/health/live delay=60s timeout=5s period=5s #success=1 #failure=3
    Readiness:    exec [/bin/bash -c curl -s http://localhost:9080/health/ready | json_pp | grep "\"outcome\" : \"UP\""] delay=15s timeout=5s period=10s #success=1 #failure=1
    Environment:  <none>
    Mounts:
      /conf from sf-config-map-vol (ro)
      /confsecure from sf-conf-secure-vol (ro)
  Volumes:
   sf-conf-secure-vol:
    Type:        Secret (a volume populated by a Secret)
    SecretName:  sf-conf-secure
    Optional:    false
   sf-config-map-vol:
    Type:      ConfigMap (a volume populated by a ConfigMap)
    Name:      sf-config-map
    Optional:  false
Events:
  Type    Reason            Age   From                   Message
  ----    ------            ----  ----                   -------
  Normal  SuccessfulDelete  35m   replicaset-controller  Deleted pod: storefront-5f777cb4f5-24mjr
  Normal  SuccessfulDelete  34m   replicaset-controller  Deleted pod: storefront-5f777cb4f5-8wnfm
  Normal  SuccessfulDelete  34m   replicaset-controller  Deleted pod: storefront-5f777cb4f5-gsbwd
  Normal  SuccessfulDelete  33m   replicaset-controller  Deleted pod: storefront-5f777cb4f5-7tlkb
```

In this case we see it's showing the old 0.0.1 image.

So we can see how kuberntes keeps the old configurations around (the different revisions are tied to the replica sets)

If we undo the rollout Kubernetes will revert to the previous version

- Undo the rollout : 
  -  `kubectl rollout undo deployment storefront`

```
deployment.extensions/storefront rolled back
```

The rollback process follows the same process as the update process, gradually moving resources between the replica sets by creating pods in one and once they are ready deleting in the other.

- Let's monitor the status
  -  `kubectl rollout status deployment storefront`

```
... 
Waiting for deployment "storefront" rollout to finish: 3 out of 4 new replicas have been updated...
Waiting for deployment "storefront" rollout to finish: 1 old replicas are pending termination...
Waiting for deployment "storefront" rollout to finish: 1 old replicas are pending termination...
Waiting for deployment "storefront" rollout to finish: 1 old replicas are pending termination...
Waiting for deployment "storefront" rollout to finish: 3 of 4 updated replicas are available...
deployment "storefront" successfully rolled out
```

- Once it's finished if we now look at the namespace
  -  `kubectl get all`

```
NAME                                                               READY   STATUS    RESTARTS   AGE
pod/ingress-nginx-nginx-ingress-controller-57747c8999-sn9nc        1/1     Running   0          12m
pod/ingress-nginx-nginx-ingress-default-backend-54b9cdbd87-cv6zs   1/1     Running   0          12m
pod/stockmanager-6759d989bf-mtn76                                  1/1     Running   0          69m
pod/storefront-5f777cb4f5-lk6gl                                    1/1     Running   0          2m6s
pod/storefront-5f777cb4f5-p8b4h                                    1/1     Running   0          2m6s
pod/storefront-5f777cb4f5-xp5ls                                    1/1     Running   0          90s
pod/storefront-5f777cb4f5-zxmvz                                    1/1     Running   0          87s
pod/zipkin-88c48d8b9-r9vx2                                         1/1     Running   0          69m

NAME                                                  TYPE           CLUSTER-IP       EXTERNAL-IP   PORT(S)                      AGE
service/ingress-nginx-nginx-ingress-controller        LoadBalancer   10.97.138.159    localhost     80:30071/TCP,443:30666/TCP   12m
service/ingress-nginx-nginx-ingress-default-backend   ClusterIP      10.102.87.209    <none>        80/TCP                       12m
service/stockmanager                                  ClusterIP      10.110.224.255   <none>        8081/TCP,9081/TCP            69m
service/storefront                                    ClusterIP      10.99.139.139    <none>        8080/TCP,9080/TCP            69m
service/zipkin                                        ClusterIP      10.104.158.61    <none>        9411/TCP                     69m

NAME                                                          READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/ingress-nginx-nginx-ingress-controller        1/1     1            1           12m
deployment.apps/ingress-nginx-nginx-ingress-default-backend   1/1     1            1           12m
deployment.apps/stockmanager                                  1/1     1            1           69m
deployment.apps/storefront                                    4/4     4            4           69m
deployment.apps/zipkin                                        1/1     1            1           69m

NAME                                                                     DESIRED   CURRENT   READY   AGE
replicaset.apps/ingress-nginx-nginx-ingress-controller-57747c8999        1         1         1       12m
replicaset.apps/ingress-nginx-nginx-ingress-default-backend-54b9cdbd87   1         1         1       12m
replicaset.apps/stockmanager-6759d989bf                                  1         1         1       69m
replicaset.apps/storefront-5f777cb4f5                                    4         4         4       69m
replicaset.apps/storefront-79d7d954d6                                    0         0         0       40m
replicaset.apps/zipkin-88c48d8b9                                         1         1         1       69m
```
We see that all of the pods are not the origional replica set version, and there are no pods in the new one.

- If we check this by going to the status we can see the rollback has worked :
  -  `curl -i -X GET http://my-ip:80/sf/status`

```
HTTP/1.1 200 OK
Server: openresty/1.15.8.2
Date: Fri, 03 Jan 2020 13:08:54 GMT
Content-Type: application/json
Content-Length: 31
Connection: keep-alive

{"name":"My Shop","alive":true,"version":"0.0.2"}
```

Normally of course the testing of the pods would be linked into CI/CD automated tooling that would trigger the rollback if it detected a problem automatically, but here we're trying to show you the capabilities of Kubernetes rather than just run automation.

#### Important note on external services
Kubernetes can manage changes and rollbacks within it's environment, provided the older versions of the changes are available. So don't delete your old container images unless you're sure you won't need them ! Kubernetes can handle the older versions of the config itself, but always a good idea to keep an archive of them anyway, in case your cluster crashes and takes your change history with it.

However, Kubernetes itself cannot manage changes outside it's environment. It may seem obvious, but Kubernetes is about compute, not persistence, and in most cases the persistence layer is external to Kubernetes on the providers storage environments.

This is especially critical for data in databases. You need to coordinate changes to the database, especially changes to the database schema (which is outside Kubernetes) with changes to the code in the services that access the database (usually running in Kubernetes.) Kubernetes can handle the rolling upgrades of the *services*, but if different versions of your service have incompatible data requirements you've got a problem. Equally if you do an upgrade that changes the database scheme in a way that's incompatible with earlier versions of the service, and then you need to roll back to a previous version you've got a problem.

These issues are not unique to Kubernetes, they have always existed when a new version of some code that interacts with the persistence layer is deployed, but the very fast deployment cycle of microservices enabled my Kubernetes makes this more of a critical issue to consider (in 2016 Netflix were doing thousands of deployments a day, admittedly not all of them would involve persistence system changes.) 

The newer automated tooling integrating CI/CD with automated A/B resting means that even larger numbers of deployments are coming, and some of those will involve persistence changes. 

The important thing is to have a strategy for combining microservice rollouts (and roll backs) with persistence (or other external to Kubernetes) changes is critical.

See the further info for links on this.





---

You have reached the end of this lab !!

Use your **back** button to return to the **C. Deploying to Kubernetes** section