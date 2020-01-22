[Go to the Cloud Test Drive Welcomer Page](../../readme.md)

![](../../common/images/customer.logo2.png)

# Migration of Monolith to Cloud Native

## Migrate a "Monolith" style Java application to a Microservices style architecture using Helidon

## Introduction

This is the project for the Migration of a Monolith (well actually quite a simple "Monolith" web app that provides a REST API and a basic database service) into a web service comprised of two microservices using the Helidon framework. The microservices are then extended to provide monitoring capabilities such as metrics and tracing, then to prepare them for cloud native capabilities such as health checks, automatic service restart etc.

The next part of the lab goes through the process of **packaging those services up into Docker containers** and externalizing configuration such as the database connection details and pushing to a docker repository.

Then we look at how to **run the docker containers in Kubernetes**, examining how to set up a Kubernetes cluster with basic capabilities, then creating a basic deployment of the services behind an Ingress controller. The labs then examine how to make use of cloud native capabilities in Kubernetes such as horizontal scaling and using the support in Helidon for things like service liveness, readiness and how those combine to enable continuous service delivery using rolling upgrades. 

Finally we look at **monitoring and graphing** to extract data on how the system operates.

In the future the labs will include sections on auto-scaling and the use of a Service Mesh, and other Kuberneties based cloud native capabilities such as A/B testing of new releases etc.

### Lab conventions

This is a rather long lab, therefore we used a few layout tricks to make the reading of this tutorial more intuitive : 

- If you see a "Bullet" sign, this means ***you*** need to perform some sort of **action**.  This can be 
  - Opening a window and navigating to some point in a file system
  - Executing some command on the command line of a terminal window :
    -  For example : `ls -al`

As we cover quite some theoretical concepts, we included pretty verbose explanations.  To make the lab easier to grasp, we placed the longer parts in *Collapsibles*:

---

<details><summary><b>Click this part to expand !</b></summary>
<p>

If you feel you are already pretty familiar with a specific concept, you can just skip it, or read quickly through the text, then re-collapse the text section by re-clicking on the title. 

</p>

</details>

---





# A. Helidon labs
The Helidon part of the labs show how to split the Monolith into microservices using Helidon REST, to access data and to extend the microservices to suppport cloud native capabilities

To do these labs you must be familiar with Java at a basic lavel (able to understand classes, constructors, methods etc.) and a bit familiar with the Eclipse IDE

Follow the link to [the Helidon labs](Helidon/Helidon-labs.md) to get started !



# B. Using Docker
The Docker part of the labs covers how we use JIB to create a docker image, run it, then to move the configuration and secrets externally to the docker image, finally we look at how to push the docker image to a repository

Go to [the Docker Labs](Docker/DockerLabs.md)



# C. Deploying in Kubernetes
These labs cover how to deploy our docker continers in Kubernetes and how to make use of the cloud native capabilities of Kubernetes.

Go to [the Kubernetes Labs](Kubernetes/Kubernetes-labs.md)







---

[Go to the Cloud Test Drive Welcomer Page](../../readme.md)



#### [License](../../LICENSE)

Copyright (c) 2014, 2016 Oracle and/or its affiliates
The Universal Permissive License (UPL), Version 1.0
