[Go to Overview Page](../README.md)

![](../../../common/images/customer.logo2.png)

# Migration of Monolith to Cloud Native

## C. Deploying to Kubernetes 

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