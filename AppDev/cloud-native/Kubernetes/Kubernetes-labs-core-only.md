[Go to Overview Page](../README.md)

![](../../../common/images/customer.logo2.png)

# Migration of Monolith to Cloud Native - Kubernetes labs

## Deploying to Kubernetes 

<details><summary><b>Self guided student - video introduction</b></summary>


This video is an introduction to the Kubernetes labs. Once you've watched it please press the "Back" button on your browser to return to the labs.

[![Kubernetes labs Introduction Video](https://img.youtube.com/vi/6Kg-zH6h3Is/0.jpg)](https://youtu.be/6Kg-zH6h3Is "Kubernetes labs introduction video")

---

</details>

## Introduction

In this series of labs we will focus on the specific features of Kubernetes to run Microservices.  These labs use a pre-built set of docker images but you can if you did the **Helidon** and **Docker** modules you can use the images you created there if you wish. 

## Setup your tenancy
If you have previously executed the **Helidon** and **Docker** parts of this lab series you will have created the CTDOKE compartment and ATP database, and are good to go.

If you only want to do the **Kubernetes** labs and have not done the **Helidon** and **Docker** modules you need to perform some [initial steps to setup your tenancy](../ManualSetup/KubernetesSetup.md) to prepare your environment.


## Basic Kubernetes - Setting up your cluster and running your services

This section covers how to run the docker images in kubenetes, how to use Kubernetes secrets to hold configuration and access information, how to use an ingress to expose your application on a web port. Basically this covers how to make your docker based services run in in a Kubernetes cluster.

We also look at using Helm to install Kubernetes "infractructure" such as the ingress server

[The basic Kubernetes labs](base-kubernetes/KubernetesBaseLabs.md)

## Cloud Native with Kubernetes

### Is it running, and what to do if it isn't

Kubernetes doesn't just provide a platform to run containers in, it also provides a base for many other things including a comprehensive service availability framework which handles monitoring containers and services to see if they are still running, are still alive and are capable of responding to requests.

To understand how this works see the [Health Readiness Liveness labs](cloud-native-labs/Health-readiness-liveness/Health-liveness-readiness.md)

### Horizontal and Auto Scaling

Kubernetes also supports horizontal scaling of services, enabling multiple instances of a service to run with the load being shared amongst all of them. 

This first scaling lab shows how you can manually control the number of instances.

[The horizontal scaling labs (3a)](cloud-native-labs/Horizontal-scaling/Horizontal-scaling.md) 

Horizontal scaling provides you with a manual process to control how many instances of a microservice you have running, but Kubernetes also offers a mechanism to automatically change the number of instances.

This second scaling labs shows how you can have Kubernetes automatically scale the number of instances for you.

[The auto scaling labs (3b)](cloud-native-labs/Horizontal-scaling/Auto-scaling.md)


### Rolling out deployment updates

Commonly when a service is deployed it will be updated, Kubernetes provides support for performing rolling upgrades, ensuring that the service continues running during the upgrade. Built into this are easy ways to reverse a deployment roll out to one of it's previous states.

[Rolling updates labs](cloud-native-labs/Rolling-updates/Rolling-updates.md)

---

**Further Information**
For links to useful web pages and other information that I found while writing these labs [see this link](further-information/further-information.md)



## End of this tutorial

Congratulations, you have reached the end of the tutorial !  You are now ready to start refactoring your own applications with the techniques you learned during this session !



------

[Go to Overview Page](../README.md)