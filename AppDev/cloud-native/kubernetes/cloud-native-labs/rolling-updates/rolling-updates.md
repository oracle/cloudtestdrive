# Cloud Native - Rolling Updates

<details><summary><b>Self guided student - video introduction</b></summary>


This video is an introduction to the Kubernetes rolling upgrades lab. Depending on your browser settings it may open in this tab / window or open a new one. Once you've watched it please return to this page to continue the labs.

[![Kubernetes rolling upgrades lab Introduction Video](https://img.youtube.com/vi/x2hXZrUWM0c/0.jpg)](https://youtu.be/x2hXZrUWM0c "Kubernetes rolling upgrades lab introduction video")

---

</details>

## Introduction

This is one of the core Kubernetes labs

**Estimated module duration** 20 mins.

### Objectives

This module demonstrates how the rolling update capabilities in Kubernetes can be used to update a microservice container or configuration with no service interruption. It also looks at how to undo an update if there is a problem with it.

### Prerequisites

You need to complete the **Auto Scaling** module.

## Task 1: Why Rolling updates

One of the problems when deploying an application is how to update it while still delivering service, and perhaps more important (but usually given little consideration) how to revert the changes in the event that the update fails to work in some way.

Changes by the way come in multiple areas, it could be application code changes (Kubernetes sees these as a change in the container image) or it could be a change in the configuration defining a deployment (and it's replica sets / pods)

The update process for code changes involves using your development tooling to create a new container based on the changed code (You presumably have separate processes for managing your source code versions). As part of your container creation process you **must** give it a different version number so it's easy to identify which container comes from which version of your source code, and also to ensure you differentiate between different releases at the image level. You'd then update the service definition to use the new image by editing and applying the yaml file or using kubectl to directly change the container image.

The update process for configuration changes is to modify the yaml file that defines your service, for example defining different volume mounts, and then applying the change, or to issue a kubectl command to directly update the change.

For *both* approaches Kubernetes will keep track of the changes and will undertake a rolling upgrade strategy.

As a general observation though it may be tempting to just go in and modify the configuration directly with kubectl ... this is a **bad** thing to do, it's likely to lead to unrecorded changes in your configuration management system so in the event that you had to do a complete restart of the system changes manually done with kubectl are likely to be forgotten. It is **strongly** recommended that you make changes by modifying your yaml file, and that the yaml file itself has a versioning scheme so you can identify exactly what versions of the service a given yaml file version provides. If you must make changes using kubectl (say you need to make a minor change in a test environment) then as soon as you decide it should be permanent then make the corresponding change in the yaml file *and do a rolling upgrade using the yaml file to ensure you are using the correct configuration* (after all, you may have made a typo in either the kubectl or yaml file).

## Task 2: How to do a rolling upgrade in our setup

So far we've been stopping our services (the undeploy.sh script deletes the deployments) and then creating new ones (the deploy.sh script applies the deployment configurations for us) This results in service down time, and we don't want that. But before we can switch to properly using rolling upgrades there are a few bits of configuration we should do

### Task 2a: Defining the rolling upgrade
Kubernetes aims to keep a service running during the rolling upgrade, it does this by starting new pods to run the service, then stopping old ones once the new ones are ready. Through the magic of services and using labels as selectors the Kubernetes run time adds and removed pods from the service. This will work with a deployment whose replica sets only contain a single pod (the new pod will be started before the old one is stopped) but if your service contains multiple pods it will use some configuration rules to try and manage the process in a more balanced manner and sticking reasonably closely to the number of pods you've asked for (or the auto scaler has).

We are going to once again edit the storefront-deployment.yaml file to give Kubernetes some rules to follow when doing a rolling upgrade. Importantly however we're going to edit a *Copy* of the file so we have a history.

  1. In the OCI Cloud Shell navigate to the folder `$HOME/helidon-kubernetes`

  2. Copy the storefront-deployment yaml file:
  
  -  `cp storefront-deployment.yaml storefront-deployment-v0.0.1.yaml`

  3. Edit the new file `storefront-deployment-v0.0.1.yaml`

The current contents of the section of the file looks like this:

```
apiVersion: apps/v1
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

  4. Set the number of replicas to 4:

  ```
  replicas: 4
```

We're now going to tell Kubernetes to use a rolling upgrade strategy for any upgrades. 

  5. After the replicas:4 line,  add

  ```
    strategy:
      type: RollingUpdate
```

Finally we're going to tell Kubernetes what limits we want to place on the rolling upgrade. 

  6. Under the type line above, and **at the same indent** add the following

  ```
      rollingUpdate:
        maxSurge: 1
        maxUnavailable: 1
```

This limits the rollout process to having no more than 1 additional pods online above the normal replicas set, and only one pod below that specified in the replica set unavailable. So the roll out (in this case) allows us to have up to 5 pods running during the rollout and requires that at least 3 are running.

Note that unless you have very specific reasons don't change the default settings for strategy type and maxSurge / minUnavailable. We are setting these for two reasons. First to show that the settings are available, and secondly for the purposes of this lab to show the roll out process in a way that let's us actually see what's happening by slowing things down (of course in a production you'd want it to run as fast as possible, so think about the settings used if you do override the defaults)

The section of the file after the changes will look like this

```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: storefront
spec:
  replicas: 4 
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

  7. Save the changes


### Task 2b: Applying the rollout strategy

To do the roll out we're just going to apply the new file. Kubernetes will compare that to the old config and update appropriately.

  1. Apply the new config
  
  -  `kubectl apply -f storefront-deployment-v0.0.1.yaml --record`

  ```
deployment.apps/storefront configured
```

  2.  We can have a look at the status of the rollout
  -  `kubectl rollout status deployment storefront`

  ```
deployment "storefront" successfully rolled out
```

If you get a message along the lines of `Waiting for deployment "storefront" rollout to finish: 3 of 4 updated replicas are available...` this just means that the roll out is still in progress, once it's complete you should see the success message.

  3. Let's also look at the history of this and previous roll outs:

  -  `kubectl rollout history  deployment storefront`

  ```
deployment.apps/storefront 
REVISION  CHANGE-CAUSE
1         kubectl apply --filename=storefront-deployment.yaml --record=true
```

(The `--record` tells Kubernetes to keep track of the change)

We can see that the previous state of the deployment resulted from us doing the initial apply. Note that the filename is specified in the rollout, as long as we version our file names we will be able to know exactly what configuration was applied to different versions of the deployment.

One point to note here, these changes *only* modified the deployment roll out configuration, so there was no need for Kubernetes to actually restart any pods as those were unchanged, however additional pods may have needed to be started to meet the replica count.

### Making a change that updates the pods

Of course normally you would make a change, test it and build it, then push to the registry, you would probably use some form of CI/CD tooling to manage the process, for example a pipeline built using the Oracle Developer Cloud Service (other options include the open source tools Jenkins / Hudson and Ansible). 

For this lab we are focusing on Helidon and Kubernetes, not the entire CI/CD chain so like any good cooking program we're going to use a v0.0.2 image that we created for you. For the purposes of this module the image is basically the same as the v0.0.1 version, except it reports it's version as 0.0.2 


Applying our new image

To apply the new v0.0.2 image we need to upgrade the configuration again. As discussed above this we would *normally* and following best practice do this by creating a new version of the deployment yaml file (say storefront-deploymentv0.0.2.yaml to match the container and code versions)

However ... for the purpose of showing how this can be done using kubectl we are going to do this using the command line, not a configuration file change. This **might** be something you'd do in a test environment, but **don't** do it in a production environment or your change management processes will almost certainly end up damaged.

  1. In the OCI cloud shell Execute the command 
  -  `kubectl set image deployment storefront storefront=fra.ocir.io/oractdemeabdmnative/h-k8s_repo/storefront:0.0.2 --record`

  ```
deployment.apps/storefront image updated
```

  2. Let's look at the status of our setup during the roll out
  
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
replicaset.apps/storefront-6ha27g8ef4     0         0         0       35m
replicaset.apps/storefront-5f777cb4f5     3         3         3       28m
replicaset.apps/storefront-79d7d954d6     2         2         0       5s
replicaset.apps/zipkin-88c48d8b9          1         1         1       28m
```

We're going to look at these in a different order to the output

Firstly the deployments info. We can see that 3 out of 4 pods are available, this is because we specified a maxUnavailable of 1, so as we have 4 replicas we must always have 3 of them available.

If we look at the replica sets we seem something unusual. There are *two* replica sets for the storefront. the original replica set (`storefront-5f777cb4f5z`) has 3 pods available and running, one of them was stopped as we allow one a maxUnavailable of 1. There is however an additional storefront replica set `storefront-79d7d954d6` This has 2 pods in it, at the time the data was gathered neither of them was ready. But why 2 pods when we'd only specified a surge over the replicas count of 1 pod ? That's because we have one pod count "available" to us from the surge, and another "available" to us because we're allowed to kill of one pod below the replicas count, making a total of two new pods that can be started.

Finally if we look at the pods themselves we see that there are five storefront pods. A point on pod naming, the first part of the pod name is actually the replica set the pod is in, so the three pods starting `storefront-5f777cb4f5-` are actually in the replic set `storefront-5f777cb4f5` (the old one) and the two pods starting `storefront-79d7d954d6-` are in the `storefront-79d7d954d6` replica set (the new one)

Basically what Kuberntes has done is created a new replica set and started some new pods in it by adjusting the number of pod replicas in each set, maintaining the overall count of having 3 pods available at all times, and only one additional pod over the replica count set in the deployment. Over time as those new pods come online in the new replica set **and** pass their readiness test, then they can provide the service and the **old** replica set will be reduced by one pod, allowing another new pod to be started. At all times there are 3 pods running.

  3. Rerun the status command a few times to see the changes 
  
  -  `kubectl get all`

If we look at the output again we can see the progress (note that the exact results will vary depending on how long after the previous kubectl get all command you ran this one).

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
replicaset.apps/storefront-6ha27g8ef4     0         0         0       36m
replicaset.apps/storefront-5f777cb4f5     1         1         1       29m
replicaset.apps/storefront-79d7d954d6     4         4         2       63s
replicaset.apps/zipkin-88c48d8b9          1         1         1       29m
```

  4. Kubectl provides an easier way to look at the status of our rollout

  - `kubectl rollout status deployment storefront`

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

During the rollout if you had accessed the status page for the storefront (on /sf/status) you would sometimes have got a version 0.0.1 in the response, and other times 0.0.2 This is because during the rollout there are instances of both versions running.

  5. If we look at the setup now we can see that the storefront is running only the new pods, and that there are 4 pods providing the service.

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
replicaset.apps/storefront-6ha27g8ef4     0         0         0       37m
replicaset.apps/storefront-5f777cb4f5     0         0         0       30m
replicaset.apps/storefront-79d7d954d6     4         4         4       108s
replicaset.apps/zipkin-88c48d8b9          1         1         1       30m
```

One important point is that you'll see that the **old** replica set is still around, even though it hasn't got any pods assigned to it. This is because it still holds the configuration that was in place before if we wanted to rollback (we'll see this later)

  6. if we now look at the history we see that there have been two sets of changes
  
  -  `kubectl rollout history deployment storefront`

  ```
deployment.apps/storefront 
REVISION  CHANGE-CAUSE
1         kubectl apply --filename=storefront-deployment-v0.0.1.yaml --record=true
2         kubectl set image deployment storefront storefront=fra.ocir.io/oractdemeabdmnative/h-k8s_repo/storefront:0.0.2 --record=true
```

Note that to get the detail of the change you have to use the --record flag

  7. Let's check on our deployment to make sure that the image is the v0.0.2 we expect
  
  -  `kubectl describe deployment storefront`

  ```
Name:                   storefront
Namespace:              tg-helidon
CreationTimestamp:      Fri, 03 Jan 2020 11:58:05 +0000
Labels:                 app=storefront
Annotations:            deployment.kubernetes.io/revision: 2
                        kubectl.kubernetes.io/last-applied-configuration:
                          {"apiVersion":"apps/v1","kind":"Deployment","metadata":{"annotations":{},"name":"storefront","namespace":"tg-helidon"},"spec":{...
Selector:               app=storefront
Replicas:               4 desired | 4 updated | 4 total | 4 available | 0 unavailable
StrategyType:           RollingUpdate
MinReadySeconds:        0
RollingUpdateStrategy:  1 max unavailable, 1 max surge
Pod Template:
  Labels:  app=storefront
  Containers:
   storefront:
    Image:       fra.ocir.io/oractdemeabdmnative/h-k8s_repo/storefront:0.0.2
... 
Lots of output 
... 
  Normal  ScalingReplicaSet  23m   deployment-controller  Scaled up replica set storefront-79d7d954d6 to 1
  Normal  ScalingReplicaSet  23m   deployment-controller  Scaled down replica set storefront-5f777cb4f5 to 3
  Normal  ScalingReplicaSet  23m   deployment-controller  Scaled up replica set storefront-79d7d954d6 to 2
  Normal  ScalingReplicaSet  22m   deployment-controller  Scaled down replica set storefront-5f777cb4f5 to 2
  Normal  ScalingReplicaSet  22m   deployment-controller  Scaled up replica set storefront-79d7d954d6 to 3
  Normal  ScalingReplicaSet  22m   deployment-controller  Scaled down replica set storefront-5f777cb4f5 to 1
  Normal  ScalingReplicaSet  22m   deployment-controller  Scaled up replica set storefront-79d7d954d6 to 4
  Normal  ScalingReplicaSet  21m   deployment-controller  Scaled down replica set storefront-5f777cb4f5 to 0
```

We see the usual deployment info, the Image is indeed the new one we specified (in this case `fra.ocir.io/oractdemeabdmnative/h-k8s_repo/storefront:0.0.2`) and the events log section shows us the various stages of rolling out the update.

If your cloud shell session is new or has been restarted then the shell variable `$EXTERNAL_IP` may be invalid, expand this section if you think this may be the case to check and reset it if needed.

<details><summary><b>How to check if $EXTERNAL_IP is set, and re-set it if it's not</b></summary>

**To check if `$EXTERNAL_IP` is set**

If you want to check if the variable is still set type `echo $EXTRNAL_IP` if it returns the IP address you're ready to go, if not then you'll need to re-set it.

**To get the external IP address if you no longer have it**

In the OCI Cloud shell type

  -  `kubectl --namespace ingress-nginx get services -o wide ingress-nginx-controller`
  
  ```
NAME                       TYPE           CLUSTER-IP    EXTERNAL-IP      PORT(S)                      AGE   SELECTOR
ingress-nginx-controller   LoadBalancer   10.96.61.56   132.145.235.17   80:31387/TCP,443:32404/TCP   45s   app.kubernetes.io/component=controller,app.kubernetes.io/instance=ingress-nginx,app.kubernetes.io/name=ingress-nginx
```

The External IP of the Load Balancer connected to the ingresss controller is shown in the EXTERNAL-IP column.

**To set the variable again**

  - `export EXTERNAL_IP=<External IP>`
  
---

</details>

  8. We should of course check that our update is correctly delivering a service.
  
  - `curl -i -k -X GET -u jack:password https://store.$EXTERNAL_IP.nip.io/store/stocklevel`

  ```
HTTP/2 200 
server: nginx/1.17.8
date: Fri, 27 Mar 2020 10:33:47 GMT
content-type: application/json
content-length: 220
strict-transport-security: max-age=15724800; includeSubDomains

[{"itemCount":4980,"itemName":"rivet"},{"itemCount":4,"itemName":"chair"},{"itemCount":981,"itemName":"door"},{"itemCount":25,"itemName":"window"},{"itemCount":20,"itemName":"handle"}]
```

  9. Now let's check the output from the StatusResource
  
  -  `curl -i -k -X GET https://store.$EXTERNAL_IP.nip.io/sf/status`

  ```
HTTP/2 200 
server: nginx/1.17.8
date: Fri, 27 Mar 2020 10:34:05 GMT
content-type: application/json
content-length: 51
strict-transport-security: max-age=15724800; includeSubDomains

{"name":"My Shop","alive":true,"version":"0.0.2"}
```
Now the rollout has completed and all the instances are running the updated image as expected it's reporting version 0.0.2

If you had checked this during the rollout you would have got 0.0.1 or 0.0.2 versions returned depending on which pod you connected to and what version it was running.

## Task 3: Rolling back a update
In this case the update worked, but what would happen if it had for some reason failed. Fortunately for us Kubernetes keeps the old replica set around, which includes the config for just this reason. 

  1. Let's get the replica set list
  
  -  `kubectl get replicaset`

  ```
NAME                                                     DESIRED   CURRENT   READY   AGE
stockmanager-6759d989bf                                  1         1         1       61m
storefront-6ha27g8ef4                                    0         0         0       68m
storefront-5f777cb4f5                                    0         0         0       61m
storefront-79d7d954d6                                    4         4         4       33m
zipkin-88c48d8b9                                         1         1         1       61m
```

  2. And let's look at the latest storefront replica
  
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
    Image:       fra.ocir.io/oractdemeabdmnative/h-k8s_repo/storefront:0.0.2
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

  3. But let's look at the old replica set
  
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
    Image:       fra.ocir.io/oractdemeabdmnative/h-k8s_repo/storefront:0.0.1
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

  4. Undo the rollout 
  
  -  `kubectl rollout undo deployment storefront`

  ```
deployment.apps/storefront rolled back
```

The rollback process follows the same process as the update process, gradually moving resources between the replica sets by creating pods in one and once they are ready deleting in the other.

  5. Let's monitor the status
  
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

  6. Once it's finished if we now look at the namespace
  
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
replicaset.apps/storefront-6ha27g8ef4                                    0         0         0       76m
replicaset.apps/storefront-5f777cb4f5                                    4         4         4       69m
replicaset.apps/storefront-79d7d954d6                                    0         0         0       40m
replicaset.apps/zipkin-88c48d8b9                                         1         1         1       69m
```
We see that all of the pods are now the original replica set version, and there are no pods in the new one.

  7. If we check this by going to the status we can see the rollback has worked.
  
  -  `curl -i -k -X GET https://store.$EXTERNAL_IP.nip.io/sf/status`

  ```
HTTP/2 200 
server: nginx/1.17.8
date: Fri, 27 Mar 2020 10:34:43 GMT
content-type: application/json
content-length: 51
strict-transport-security: max-age=15724800; includeSubDomains

{"name":"My Shop","alive":true,"version":"0.0.1"}
```

Normally of course the testing of the pods would be linked into CI/CD automated tooling that would trigger the rollback if it detected a problem automatically, but here we're trying to show you the capabilities of Kubernetes rather than just run automation.

<details><summary><b>What if I do new update while another is still in progress ?</b></summary>

If you change a different deployment then that will proceed in the same way, the different deployment will create the replica sets and gradually increase the side of the new one while reducing the size of the old one as above (this hopefully is what you'd expect!)

If you changed and started a rollout of a deployment that was currently in the process of being upgraded  then Kubernetes still does the right thing. You will have the old replica set (let's call that replica set 1) and the new one (let's call that replica set 2) Kubernetes will stop the transition from replicas set 1 to replica set 2, and will create another replica set (let's call this replica set 3) for the latest version of the deployment. It will then transition both replica set 1 and 2 to the new replica set 3.

Obviously this is not something you're likely to be doing often, but it's quite possible that you may have realized there was a mistake part way through the upgrade (say you pointed to the wrong image, or there was a config error and the containers in the pods kept failing) so re-doing the deployment with a fix can help you keep the services available.

---

</details>


## Task 4: Important note on external services
Kubernetes can manage changes and rollbacks within it's environment, provided the older versions of the changes are available. So don't delete your old container images unless you're sure you won't need them! Kubernetes can handle the older versions of the config itself, but always a good idea to keep an archive of them anyway, in case your cluster crashes and takes your change history with it.

However, Kubernetes itself cannot manage changes outside it's environment. It may seem obvious, but Kubernetes is about compute, not persistence, and in most cases the persistence layer is external to Kubernetes on the providers storage environments.

Persistence is by definition about making things persistent, they exist outside the compute operation, and that can cause problems if other elements also use the stored data.

This is especially critical for data in databases. You need to coordinate changes to the database, especially changes to the database schema (which is outside Kubernetes) with changes to the code in the services that access the database (usually running in Kubernetes). Kubernetes can handle the rolling upgrades of the *services*, but if different versions of your service have incompatible data requirements you've got a problem. Equally if you do an upgrade that changes the database scheme in a way that's incompatible with earlier versions of the service, and then you need to roll back to a previous version you've got a problem.

These issues are not unique to Kubernetes, they have always existed when a new version of some code that interacts with the persistence layer is deployed, but the very fast deployment cycle of microservices enabled my Kubernetes makes this more of a critical issue to consider (in 2016 Netflix were doing thousands of deployments a day, admittedly not all of them would involve persistence system changes). 

One common approach used is the have the microservices support different versions of the scheme, and then only upgrade to the new version once all of the microservices that access the data have support for the new version, and sufficient testing has shown that there is likely to be no need to roll back to old versions which wouldn't support the updated schema. Than, and only then is the database (or other persistence) updates to reflect the new structure.

To assist with this you might like to consider and approach to limit access to the data to a single microservice (obviously for resillience there would be multiple instances) which then presents the data to the other consumers, potentially using different API endpoints to reflect the data structure. The new microservices use the new API and the old microservices can continue to use the old API's with the data microservice converting between them and the data. Of course for this to work there needs to be ways to map both API's on to a common data representation (e.g. by using default values for additional fields required by t                                                                                         he new API) and it may not always be possible.

The newer automated tooling integrating CI/CD with automated A/B resting means that even larger numbers of deployments are coming, and some of those will involve persistence changes. 

The important thing is to have a strategy for combining microservice rollouts (and roll backs) with persistence (or other external to Kubernetes) changes is critical.

See the further info for links on this.

<details><summary><b>What other update strategies are there ?</b></summary>

Kubernetes has native support for two strategies, the rolling upgrade we've seen above, but also a strategy type called recreate. 

The rolling upgrade strategy attempts to keep the microservice responding without excess use of resources.

The recreate strategy focuses on the resource usage and basically stops the exiting microservices before it then starts the new ones. This strategy means there is a reduction in performance as the pods in the original replica set are stopped before the new replica set is created and pods started in it. 

There are several other options which require additional external actions.

The Blue / Green (also known as red / black) focuses on the performance at the cost of processing. It creates a new replica set with all of the required pods, then switches all the traffic from the old replica set to the new one before stopping the old one. To do this all the deployments have a specific version and the service is configured with additional selectors for the version/ When the new replica set is up and running and time comes to switch the service selector is updated to refer to the new version and it will thus no longer match the pods of the old version, but will instead match the pods of the new one and switch all traffic to that. Note that this may require the creation of additional deployments.

One major benefit of the blue / green approach is that if your new version of the service means that the persistence required an incompatible change then you won't have to worry about old / new versions of persisted data (though you will have to work out a strategy for actually updating the data itself)

Other rollout types exist, though these do require the use of a service mesh (e.g. [Linkerd](https://linkerd.io/) or [Istio](https://istio.io/)to split the request flow between different versions. Examples include :

Canary rollouts where the new services instances are created, then a limited amount of traffic is diverted to them by the service mesh (the bulk of the traffic going to the original version). Once the new version has been tested for a while and shown to meet the release criteria for quality then traffic is switched to the new version is ramped up quickly and the old version stopped. If the quality metrics turn out not to be met then all of the traffic is redirected to the old version.

A/B testing is a variant of canary testing, and also requires a service mesh. Like canary testing both versions of the microservice exist at the same time, and the traffic is shared between them. But for A/B testing instead of the quality being the focus the switch is driven by some form of business metric, for example the new version results in 5% more orders than the old one.

Shadow deployments (also known as mirror or dark deployments) which also requires a servcie mesh are where you recreate the entire deployment (as with blue/green testing) but have the service mesh mirror the traffic to both the old and new versions. This is good is you want to test the performance of the new deployment, but of course you also need mechanisms to ensure that only one version is actually applied (customers would not want two orders just because you are mirroring)

Another version that doesn't really have a name is when you deploy a microservice instance, and then use the service mesh to divert traffic based on headers. For example if you make a request with a header that indicates it should be sent to the test version of the service. This is really useful as it allows you to test a microservice that may be way down the flow of processing in the actuall production environment, but without end users being impacted by it.

Canary testing and A/B testing require a service mesh to handle the split of the requests between versions, but also a mechanism to gather metrics (quality / business etc.) and then adjust the split. These metrics are unlikely to be the type of thing gathered by standard Prometheus and specialized tools like [Spinaker](https://www.spinnaker.io/) may be used to help with managing the service mesh configuration.

---

</details>

## End of the module, what's next ?

You have reached the end of this section of the lab and of the core Kubernetes modules.

If you are doing the optional modules version of this course then you can chose from the varions Kubernetes optional modules.

## Acknowledgements

* **Author** - Tim Graves, Cloud Native Solutions Architect, EMEA OCI Centre of Excellence
* **Contributor** - Jan Leemans, Director Business Development, EMEA Divisional Technology
* **Last Updated By** - Tim Graves, August 2021
