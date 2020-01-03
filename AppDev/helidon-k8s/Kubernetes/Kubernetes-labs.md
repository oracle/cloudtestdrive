#Kubernetes labs
The Kubernetes labs are broken down into several sections

#Basic Kuberneties
This section covers how to run the docker images in kubenetes, how to use kuberneties secrets to hold configuration and access information, how to use an ingress to expose your application on a web port. Basically this covers how to make your docker based services run in in a kubernetes cluster.

We also look at using Helm to install kubernetes "infractructure" such as the ingress server
[The basic kubernetes labs](base-kubernetes/KubernetesBaseLabs.md)

#Monitoring services in Kubernetes
Once a service is running in Kubernetes we want to start seeing how well it's working in terms of the load on the service. At a basic level this is CPU / IO's but more interesting are things like the number of requests being serviced.

Monitoring metrics may also help us determining things like how changes when releasing a new version of the service may effect it's operation, for example does adding a database index increase the services efficiency by reducing lookup times, or increase it by adding extra work when updating the data. With this information you can determine if a change is worthwhile keeping.

[The monitoring labs](monitoring-kubernetes/MonitoringLabs.md)
#Cloud Native capabilities in Kubernetes

Kubernetes has a number of features which go beyond just running containers. These are covered in the [Kubernetes cloud native labs.](cloud-native-labs/KubernetesCloudNativeLabs.md)

#Further Information
For links to useful web pages and other information that I found while writting these labs see [further information](further-information/further-information.md)