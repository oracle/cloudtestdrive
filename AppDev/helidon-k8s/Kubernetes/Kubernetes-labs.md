[Go to Overview Page](../README.md)

![](../../../common/images/customer.logo2.png)

# Migration of Monolith to Cloud Native

## C. Deploying to Kubernetes 

### **Introduction**

We have tried to set the labs up so that you do not need to be an expert in Kubernetes to run them. However we do expect that you have some basic knowledge of how to use a computer, open terminals etc.

The host operating system for the virtual machines we use for attendees to run the lab use Linux, we expect you to have some familiarity with Linux, and especially the terminal environment. We assume that you know enough that when you see something like the following instruction and sample text

*In the helidon-labs-stockmananger folder do an ls to see what's there*

```
$ ls
DBScripts			PutObjectStoreDirHere		Wallet_ATP			buildPushToRepo.sh		confsecure			repoConfig.sh			src
Dockerfile			README-Lombok			app.yaml			buildV0.0.2PushToRepo.sh	etc				runLocalExternalConfig.sh	target
ObjectStore			README.md			buildLocalExternalConfig.sh	conf				pom.xml				runRepo.sh
```

That means you will know you need to cd to the folder (if you're not already there !) type ls (not the preceding $) and that the output will be DBScripts et all (so you don't type that)

Also there are a number of situations in the labs where we will be running a command to get some information and then expect you to use the returned information in the next command. For example in the case we say 

*Run the kubectl command to get the pods list on the kubesystem namespace*

```
$ kubectl get pods -n kube-system
NAMESPACE     NAME                                     READY   STATUS    RESTARTS   AGE
kube-system   coredns-6dcc67dcbc-kw9qw                 1/1     Running   0          6h45m
kube-system   coredns-6dcc67dcbc-zlww8                 1/1     Running   0          6h45m
kube-system   etcd-docker-desktop                      1/1     Running   0          6h44m
kube-system   kube-apiserver-docker-desktop            1/1     Running   0          6h44m
kube-system   kube-controller-manager-docker-desktop   1/1     Running   0          6h44m
kube-system   kube-proxy-w9njs                         1/1     Running   0          6h45m
kube-system   kube-scheduler-docker-desktop            1/1     Running   0          6h44m
kube-system   kubernetes-dashboard-58d96f69b8-lgk9t    1/1     Running   0          6h43m
```
*Then let's look at your dashbaord in more detail*

```
$ kubectl describe pod kubernetes-dashboard-58d96f69b8-lgk9t -n kube-system
Name:           kubernetes-dashboard-58d96f69b8-lgk9t
Namespace:      kube-system
Priority:       0
Node:           docker-desktop/192.168.65.3
Start Time:     Fri, 03 Jan 2020 09:54:07 +0000
Labels:         app=kubernetes-dashboard
                pod-template-hash=58d96f69b8
                release=kubernetes-dashboard
<lots of output removed>
```

We do assume that you will recognize that the output of the first command will be different form the output we give, and that in the second command the `kubernetes-dashboard-58d96f69b8-lgk9t` will need to be replaced with whatever the first command returned on your environment when you ran it. We to try to remind folks about this occasionally, but if we did so everywhere it would get tedious for people havign to read it.

## The Labs

### 1. Basic Kubernetes
This section covers how to run the docker images in kubenetes, how to use kubernetes secrets to hold configuration and access information, how to use an ingress to expose your application on a web port. Basically this covers how to make your docker based services run in in a kubernetes cluster.

We also look at using Helm to install kubernetes "infractructure" such as the ingress server

[The basic kubernetes labs](base-kubernetes/KubernetesBaseLabs.md)



### 2. Monitoring services -  Prometheus for data gathering
Once a service is running in Kubernetes we want to start seeing how well it's working in terms of the load on the service. At a basic level this is CPU / IO's but more interesting are things like the number of requests being serviced.

Monitoring metrics may also help us determining things like how changes when releasing a new version of the service may effect it's operation, for example does adding a database index increase the services efficiency by reducing lookup times, or increase it by adding extra work when updating the data. With this information you can determine if a change is worthwhile keeping.

[Prometheus lab](monitoring-kubernetes/MonitoringWithPrometheusLab.md)

### 3. Monitoring services - Grafana for data display
As you've seen Prometheus is great at capturing the data, but it's not the worlds best tool for displaying the data. Fortunately for us there is an open source tool called **Grafana** which is way better than Prometheus at this.

The process for installing and using Grafana is detailed in the next lab :  
[Visualusing with Grafana lab document.](monitoring-kubernetes/VisualizingWithGrafanaLab.md)






## Cloud Native with Kubernetes


### 4. Is it running, and what to do if it isn't

Kubernetes doesn't just provide a platform to run containers in, it also provides a base for many other things including a comprehensive service availability framework which handles monitoring containers and services to see if they are still running, are still alive and are capable of responding to requests.

To understand how this works see the [Health Readiness Liveness labs.](cloud-native-labs/Health-readiness-liveness/Health-liveness-readiness.md)



### 5. Horizontal Scaling

Kubernetes also supports horizontal scaling of services, enabling multiple instances of a service to run with the load being shared amongst all of them.

[The Replica set labs](cloud-native-labs/Horizontal-scaling/Horizontal-scaling.md) 



### 6. Rolling out deployment updates

Commonly when a service is deployed it will be updated, Kubernetes provides support for performing rolling upgrades, ensuring that the service continues running during the upgrade. Built into this are easy ways to reverse a deployment roll out to one of it's previous states.

[Rolling updates labs](cloud-native-labs/Rolling-updates/Rolling-updates.md)




### 7. Sections still to be written in Kubernetes cloud native

The following sections have not yet been written, they will be added in time.

#### Horizontal Autoscaling

Sadly the automatic horizontal scaling capability which would automatically adjust the number of instances of a pod based on it's load seems to currently be unavailable as one of the services it depended on (Heapster) is no longer available in Kubernetes. Once a solution for that is available it will be documented here.

#### Automatic CI/CD and Kubenetes

To be completed.

#### Automatic A/B testing

To be completed.

#### Services Meshes.

The service mesh is one of the latest ideas to come out of the cloud native forum.
To be completed







**Further Information**
For links to useful web pages and other information that I found while writing these labs [see this link](further-information/further-information.md)



## End of this tutorial

Congratulations, you have reached the end of the tutorial !  You are now ready to start refactoring your own applications with the techniques you learned during this session !



------

[Go to Overview Page](../README.md)