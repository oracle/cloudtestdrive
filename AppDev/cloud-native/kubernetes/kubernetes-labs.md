[Go to Overview Page](../README.md)

![](../../../common/images/customer.logo2.png)

# Migration of Monolith to Cloud Native - Kubernetes labs

## Deploying to Kubernetes 

<details><summary><b>Self guided student - video introduction</b></summary>


This video is an introduction to the Kubernetes labs. Depending on your browser settings it may open in this tab / window or open a new one. Once you've watched it please return to this page to continue the labs.

[![Kubernetes labs Introduction Video](https://img.youtube.com/vi/6Kg-zH6h3Is/0.jpg)](https://youtu.be/6Kg-zH6h3Is "Kubernetes labs introduction video")

---

</details>

## Introduction

In this series of labs we will focus on the specific features of Kubernetes to run Microservices.  These labs use a pre-built set of docker images but you can if you did the **Helidon** and **Docker** modules you can use the images you created there if you wish. 

## Setup your tenancy
If you have previously executed the **Helidon** and **Docker** parts of this lab series you will have created the CTDOKE compartment and ATP database, and are good to go.

If you only want to do the **Kubernetes** labs and have not done the **Helidon** and **Docker** modules you need to perform some [initial steps to setup your tenancy](../manual-setup/kubernetes-setup.md) to prepare your environment.

### Create a Kubernetes cluster

You will need a Kubernetes cluster to work with. Follow [these instructions](../manual-setup/create-kubernetes-cluster.md), 

## Cloud shell and setup

You will be using the OCI Cloud Shell to execute commands and scripts during these labs. 

You need to follow the [cloud shell setup instructions](./setup/cloud-shell-setup.md) to download the scripts and template files into the cloud shell before you continue with the labs.


## Basic Kubernetes - Setting up your cluster and running your services

This section covers how to run the docker images in kubenetes, how to use Kubernetes secrets to hold configuration and access information, how to use an ingress to expose your application on a web port. Basically this covers how to make your docker based services run in in a Kubernetes cluster.

We also look at using Helm to install Kubernetes "infrastructure" such as the ingress server

[The basic Kubernetes labs](base-kubernetes/kubernetes-base-labs.md)

## Cloud Native with Kubernetes

### Is it running, and what to do if it isn't

Kubernetes doesn't just provide a platform to run containers in, it also provides a base for many other things including a comprehensive service availability framework which handles monitoring containers and services to see if they are still running, are still alive and are capable of responding to requests.

To understand how this works see the [Health Readiness Liveness labs](cloud-native-labs/health-readiness-liveness/health-liveness-readiness.md)

## Horizontal and Auto Scaling

Kubernetes also supports horizontal scaling of services, enabling multiple instances of a service to run with the load being shared amongst all of them. 

This first scaling lab shows how you can manually control the number of instances.

[The horizontal scaling labs (3a)](cloud-native-labs/horizontal-scaling/horizontal-scaling.md) 

Horizontal scaling provides you with a manual process to control how many instances of a microservice you have running, but Kubernetes also offers a mechanism to automatically change the number of instances.

This second scaling labs shows how you can have Kubernetes automatically scale the number of instances for you.

[The auto scaling labs (3b)](cloud-native-labs/horizontal-scaling/auto-scaling.md)


## Rolling out deployment updates

Commonly when a service is deployed it will be updated, Kubernetes provides support for performing rolling upgrades, ensuring that the service continues running during the upgrade. Built into this are easy ways to reverse a deployment roll out to one of it's previous states.

[Rolling updates labs](cloud-native-labs/rolling-updates/rolling-updates.md)


## Optional Lab modules

The following modules are in **some** cases optional, this is because some of the later modules may depend on these (For example the Grafana module relies on the completion of the Prometheus module). If you are in a guided lab with an instructor they will tell you which of the optional modules you need to complete, if you are doing this in a self-guided mode then please read the descriptions below to determine which optional modules you should do.

These optional modules are grouped by subject area. Unless there are dependencies specified you should be able to do the module groups in any order, though the labs were written following the order defined below, so if you don't do all of them, or in a different order the visuals may differ slightly.

### Optional labs group 1. Monitoring your services

#### Optional 1a. Monitoring services -  Prometheus for data gathering
Once a service is running in Kubernetes we want to start seeing how well it's working in terms of the load on the service. At a basic level this is CPU / IO's but more interesting are things like the number of requests being serviced. You will need to do this module if you are going to do the Grafana for data display module.

Monitoring metrics may also help us determining things like how changes when releasing a new version of the service may effect it's operation, for example does adding a database index increase the services efficiency by reducing lookup times, or increase it by adding extra work when updating the data. With this information you can determine if a change is worthwhile keeping.

[Prometheus lab](monitoring-kubernetes/monitoring-with-prometheus-lab.md)

#### Optional 1b. Monitoring services - Grafana for data display
To do this optional module you will have to have completed the optional Promtheus for data gathering module.

As you've seen Prometheus is great at capturing the data, but it's not the worlds best tool for displaying the data. Fortunately for us there is an open source tool called **Grafana** which is way better than Prometheus at this.

The process for installing and using Grafana is detailed in the next lab :  
[Visualising with Grafana lab document.](monitoring-kubernetes/visualizing-with-grafana-lab.md)

### Optional labs group 2. Capturing log data
These labs are self standing, you can do either of them, or both. They have no dependencies and currently there are no other optional modules dependent on them.


Both these lab modules use fluentd to read the log data within the Kubernetes environment

#### Optional 2a. Log Capture for processing

This optional module shows how you can use fluentd to capture the log data, and then write the output to Elastic Search (often used to help process log data in Cloud Native deployments). The module is intended as an example of how to handle log data for people who will need instant indexed access to the log data.

[Log capture for processing lab](management/logging/log-capture-for-processing.md)


#### Optional 2b. Log Capture for long term storage (archive)

This optional module shows how you can use fluentd to capture the log data, and then write the output to a long term storage offering, In this case we will be writing to the S3 compatible Oracle Object Storage Service. The module is intended as an example to how to handle log data for people that need to retain log data for the long term (perhaps for legal reasons) but don't need instant access, so can use the most cost effective long term storage.

[Log capture for processing lab](management/logging/log-capture-for-archive.md)

### Optional labs group 3 Service meshes

These labs are semi-independent, You must do the 3a Service mesh install and setup module, but after that you can do most of the Service mesh modules in any order order listed, the exception is if you want to do the traffic split module you must have done the troubleshooting module. If you don't want to do all of them you can stop at any point. If you decide to uninstall the linkerd service mesh then obviously (I hope!) do that once you have completed the all service mesh labs you want to do!

A service mesh is two parts, a control plane that manages the mesh, and a data layer that is automatically added to your Kubernetes deployments by the control plane (usually by what's known as a sidecar container). The data plane sits between your micro-service implementations and the underlying network, and manages your network activities. Depending on the implementation the data plane can even cross multiple Kubernetes clusters, making them appear as one. 

The data plane provides support for things like automatically encrypting traffic exiting your micro-service implementation and decrypt it on arrival at the next (whilst automatically handling certificate management for you). It can also do things like traffic management functions where it implements the service balancing (again this can be cross cluster for some service mesh implementations) and traffic balancing where a portion of the traffic is diverted to a test instance, perhaps for automated A/B testing or for a canary rollout where a CI/CD toolkit triggers a deployment, and the tooling in conjunction with the service mesh tests it out on a small subset of the traffic, automatically canceling the rollout if there are problems.

Service meshes can also monitor the traffic flowing throughout your clusters, enabling the gathering of detailed request / response statistics, for example what the failure rate is of requests to a particular endpoint.

As they are part of the network they can also split the network traffic, enabling activities like canary rollouts and testing the system by injecting faults.


#### Optional 3a Service mesh install and setup

You must do this module before you can do any of the other service mesh modules

This module shows how to install the Linkerd service mesh, and enable it on the micro-servcies we have been using for this lab.

[Installing the Linkerd service mesh.](service-mesh/linkerd-install.md)

#### Optional 3b. Monitoring traffic with the service mesh

You must have done the service mesh install and setup module before this one.

This module shows how to use the service mesh we installed in Optional lab 3a to report on the traffic between the micro-services in our application on the cluster.

[Traffic monitoring with the service mesh](service-mesh/linkerd-monitoring-traffic-flows.md)

#### Optional 3c. Using the service mesh to troubleshoot problems

You must have done the service mesh install and setup module before this one.

This modules uses a simulated "broken" implementation of the stockmanager service to generate errors, then we use the service mesh monitoring capabilities to see where the error is and the conditions around it.

[Troubleshooting with the service mesh](service-mesh/linkerd-using-to-troubleshoot-problems.md)

#### Optional 3d. Using the traffic split facility of the service mesh

You must have done the service mesh install and setup module, and the service mesh troubleshooting module before this one.

This module looks at the traffic split capability in the service mesh implementations to see how it can be used for testing purposes, for example injecting faults to do some chaos engineering and test out the overall environment.

This module also uses the traffic split capability of the service mesh to explain how you can use a service mesh to do a canary deployment

[Exploring what you can do with a service mesh traffic splits](service-mesh/linkerd-exploring-traffic-splits.md)

#### Optional 3e Uninstalling the service mesh

**Only** do this after you have completed the service mesh lab modules you want to do.

You do not have to uninstall the service mesh, but can if you wish.

[Uninstalling the linkerd service mesh](service-mesh/linkerd-uninstall.md)


### Additional optional modules in development.

We are working on or exploring the posibility of a number of additional optional modules, these include integrating micro-services and serveless as part of your overall architecture, using an API Gateway, accessing your service with a chatbot, and building simple web front ends for your service. As these (and other) are completed they modules will be added here. If you have an interest in further additional modules please let us know and we'll see what we can do.

---

**Further Information**
For links to useful web pages and other information that I found while writing these labs [see this link](further-information/further-information.md)



## End of this tutorial

Congratulations, you have reached the end of the tutorial!  You are now ready to start refactoring your own applications with the techniques you learned during this session!



------

[Go to Overview Page](../README.md)