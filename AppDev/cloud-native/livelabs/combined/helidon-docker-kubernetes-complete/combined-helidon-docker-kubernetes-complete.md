![](../../../images/customer.logo2.png)

# Cloud Native - Helidon for Cloud Native microservices, packaging in Docker containers, deploying in Kubernetes

This set of lab instructions is based on the virtual machine image dated 2020-10-29 (29th October 2020)

**Lab conventions**

We have used a few layout tricks to make the reading of this tutorial more intuitive : 

- If you see a "Bullet" sign, this means **you** need to perform some sort of **action**.  This can be 
  - Opening a window and navigating to some point in a file system
  - Executing some command on the command line of a terminal window :
    -  For example : `ls -al`

As we cover quite some theoretical concepts, we included pretty verbose explanations.  To make the lab easier to grasp, we placed the longer parts in *Collapsibles*:

<details><summary><b>Click this title to expand!</b></summary>


If you feel you are already pretty familiar with a specific concept, you can just skip it, or read quickly through the text, then re-collapse the text section by re-clicking on the title. 

---

</details>



**Video introductions**

These labs were designed in part to be delivered in a classroom environment where we would do a short presentation to introduce the labs, and also each section.

To support those who are doing the labs in a self-guided mode we have created an introduction video to the entire labs, and short videos for each lab section. If you are doing the labs with an instructor you don't need to review these, but for self guided students we **strongly** recommend that you review the videos.

Each video is in a expandable section, see the one below. If you are a self guided student (you are **not** part of an instructor led lab) expand it and click on the video image to be taken to the video streaming web site where you can play it. Once you've finished just click the back button to return to these instructions.

<details><summary><b>Self guided student - Cloud Native video introduction</b></summary>


This video is an introduction to Cloud native architectures and processing. Depending on your browser settings it may open in this tab / window or open a new one. Once you've watched it please return to this page to continue the labs.

Note. The current videos were recorded during the lock down, hence the poor sound quality, you may need to turn up the volume on your computer to hear them properly.

[![Introduction Video](https://img.youtube.com/vi/9bYn7huyQ5g/0.jpg)](https://youtu.be/9bYn7huyQ5g "Labs introduction video")

---

</details>

## Prerequisites

These labs can be run in many different ways, but in all cases you will need access to a Oracle Cloud Tenancy and be signed in to it.

Please look at the instructions in the Prerequisites section for details of how to sign up for a free trial tenancy and how to log into it. If you already have access to a tenancy (you may be in an instructor led lab, or have a pre-existing tenancy) then go direct to Prerequisites Step 2 which covers how to login to the tenancy.

## Getting Help

If you are in an instructor led lab then clearly just ask your instructor, if you are working through this self guided then each module has a section at the end for getting help. 

## Introduction to this page

This document explains the contents of the various lab modules, the modules themselves are accessed via the menu on the left. 

## Setting up the core OCI environment using scripts

You will need to do a number of tasks to setup your tenancy, creating the compartment, creating and configuring a Autonomous Transaction Processing database etc.

Please follow the tasks in the **Setting up the core OCI environment using scripts** section (click the name in the labs index) then return to this page when complete

## Setting up your Development VM core

This lab uses a virtual machine to provide a consistent environment, this module takes you through the process of creating and doing the common configuration tasks for this virtual machine.

Please follow the tasks in the **Setting up your Development VM core** section (click the name in the labs index) then when you've done it come back to this page.

## Configure your Developer VM for the Helidon Labs

You will need to import the template code you will be using into eclipse, and do some small VM configurations. This is in addition to setting up the VM you did earlier.

Please follow **Configure your Developer VM for the Helidon Labs** section. When you've completed them click the `back` button on your browser to return to this page.

## Introduction to Heldon labs

<details><summary><b>Self guided student - Helidon lab video introduction</b></summary>

This video is an introduction to the Helidon labs. Depending on your browser settings it may open in this tab / window or open a new one. Once you've watched it please return to this page to continue the labs.

[![Helidon labs Introduction Video](https://img.youtube.com/vi/182KYHSrf5A/0.jpg)](https://youtu.be/182KYHSrf5A "Helidon labs introduction video")


</details>

---

<details><summary><b>What is Helidon?</b></summary>


[Helidon](https://helidon.io) is an open source implementation of [Eclipse Microprofile](https://microprofile.io/) from Oracle. Through these labs we talk about Helidon, but it's key to remember that the work we're doing is applicable to *any* microprofile implementation, of which Helidon is one.

Microprofile (and thus Helidon) are designed to be lighter weight than things like Java EE or Spring Boot, but also more standards based than Spring, so it has more stability from an API change perspective.

Microprofile is built on other pre-existing standards, for example the `@GET` annotation is used by microprofile (Helidon uses it to indicate a method respond to a http GET request), but the annotation itself is actually a Java web services annotation that microprofile uses. 

This lab aims to introduce you to the major capabilities provided by the Helidon implementation of Microprofile. It does this in a number of stages, starting with core capabilities such as REST enabling a class and moving on to features such as building clients to talk to other REST services and how to use Helidon to quickly create service elements that support Cloud Native tools such as Kubernetes.

We are using Helidon MP, this is an annotation based framework, where to utilize it you just place annotations (e.g. `@Path("/mypath"`) on a class or method. There is no need to modify the code beyond that. Helidon also comes in a variety called Helidon SE. The SE framework however requires you to actually make the Java method calls yourself, so you'd have to change your code. Helidon MP actually converts the annotations at runtime into calls to the Helidon SE Java API, so there is no need to change your logic. Helidon MP is also similar in style to frameworks like __Spring__ which are also annotation based, so we've chosen the MP version for these labs.

</details>



---

<details><summary><b>Requirements for this Lab</b></summary>


We have assumed you understand the basic concepts of what a REST service is.

The labs **do require basic programming knowledge**. As Helidon is a Java set of libraries then of course you need to have an understanding of simple Java programming. The labs are deliberately designed not to require detailed understanding of complex Java technologies, though if you do happen to be a Java expert you may be able to apply that knowledge to gain deeper understanding of how Helidon operates.

The labs were developed using the Eclipse IDE. Again you don't need to be an expert here, but you need to have some familiarity with how to navigate using the IDE (It's very similar to other IDE's like Netbeans or InteliJ) and how to compile and run things.

We do not expect you to know the details of the Maven build / packaging tool. In particular we are **not** going to be getting you to edit the pom.xml file (the Maven configuration file) for these projects. If you are familiar with Maven and the pom.xml file please feel free to explore it, or copy it for your own projects as a start point, but please do not make any changes to it in this lab. The only exception to this is in some of the optional modules, in which case we will be clear on the changes you need to make.

</details>

---


<details><summary><b>How to do the coding in the labs</b></summary>


Most of the labs explain what a specific Helidon features is and why it's useful, then there is a coding example with explanation of the feature. The coding example will usually tell you to modify a particular class (usually by providing you with the fully qualified name of the class, for example `com.oracle.labs.helidon.stockmanager.Main`) and make a specific change to a certain method (e.g. the `buildConfig` method or the constructor.) 

Occasionally it will tell you to just modify the class itself, for example adding an annotation on the class declaration. We try to be clear what the project is for each set of labs, but expect you to be able to use eclipse to open the right .java file (which is referred to but it's fully qualified class name to you can navigate to it) and find the method.

</details>



---

<details><summary><b>Java Imports</b></summary>


We have tried to ensure that the imports you need are already in the source code, however in some cases when we create the initial state or the code for you Eclipse may have removed imports that are not used in the initial state but you will need to use.

If you have problems with missing classes and imports we have added expanding sections for you detailing the imports you will need to add. Note that in some sections where we are re-using something that's already imported we will not tell you to add a duplicate import.

</details>



---

<details><summary><b>Testing your service as you go</b></summary>


These labs were designed so that at each stage as you add functionality you will have a working program. To test that you need to make REST calls. 

As an **explanation of the document** (so please don't do this bit)

When you make REST calls in the examples we show the the curl command line call you should use in a terminal, along with sample output. 

*Example:*

```
    $ curl -i -X GET -u jack:password http://localhost:80/store/stocklevel
    HTTP/1.1 200 OK
    Server: openresty/1.15.8.2
    Date: Mon, 30 Dec 2019 19:16:20 GMT
    Content-Type: application/json
    Content-Length: 184
    Connection: keep-alive

    [{"itemCount":4980,"itemName":"rivet"},{"itemCount":4,"itemName":"chair"},{"itemCount":981,"itemName":"door"},   {"itemCount":25,"itemName":"window"},{"itemCount":20,"itemName":"handle"}]
```

If you want to use other REST client tools available to you feel free to use them as long as you are skilled in doing so, but be aware that the tutors may not be able to assist you with those tools. 

</details>

---



<details><summary><b>The Monolith application we will decompose</b></summary>

The labs follow the migration of a (admittedly) simple Java program to being a couple of separate microservices. The related Docker and Kubenetes labs then take the microservices, show how to package and run them in Docker and then deploy on Kubernetes in a Cloud Native format.

At it's core the program allows a caller to request the levels of stock items held in a database, and to record items as having been removed. Think of this as perhaps a system that handles consumable items in a post room or something. People may lookup what's there, take stationary and update the database when they do so. As a separate function not included here (but just to explain the scenario) the facilities manager may look at the database, order replacement items and update the stock levels when they are delivered.

Fortunately this company is not run by people who think that the cost of a inter-departmental cross charge for a box of paper clips is good use of people's (or developer's) time, so when someone updates the database having taken stock there is no need to record who took what :-)

The code does not provide a front end UI. It would normally be libraries that are used part of a larger function and the external interface.

The basic program has two sets of functionality, split into two projects in Eclipse. A module (stockmanager) that interacts with a database table. This module allows Create Delete, Update and Deletes to be made on a table. A second module (storefront) provides a bit of business logic and processing, for example ensuring that business rules around minimum quantities are applied when taking stock.

This is a deliberately simple example, the goal is to see how these two modules can be converted from a traditional **Monolith** type of approach into cloud native ready microservices, with as little as possible being changed in the actual code - we actually don't make *any* changes to the code logic, all of the modifications are done by adding annotations.

Also we are not addressing how to split any existing monolith into modules, hopefully you will have done that when you created the initial program and functionally decomposed your original requirements. There is no single "right" or "wrong" way to decompose your monolith functionally, but I do recommend reading up on the "Strangler Pattern" and the "Anti Corruption Pattern" as they are very useful architectural approaches to take.
</details>

---

## The Helidon labs

This section describes the labs, you will need to do them in the order shown. There are optional labs described, the ones that are connected with a core lab should be done in the order shown **if you decide to to them.** Optional labs that are not attached to a lab can be done once the core labs are completed.

### Helidon - Part 1. Core Helidon
The core labs are designed to show how you can take a some existing Java code and REST enable it so it can operate as a standalone service. This includes not just the REST API, but also configuration, error handling and security.


### Helidon - Part 2. Databases and Helidon
This looks at how you can access databases within a Helidon based application.

### Helidon - Optional lab 2a Accessing the request context
This looks at how you can access the context of the request to find out information not directly available from the core API. This lab looks at how to get the identity of the user making the request.


### Helidon - Part 3. Communicating between microservices with Helidon
This lab shows the support in Helidon for switching from a direct method call to using a REST call without modifying the calling method.

### Helidon - Part Optional lab 3a - Communicating from non Helidon clients
Much though we would like everything talking to our mciroservices to be Helidon based in the real world this wont; be the case. This module discusses how you can use the RestClient interface described in **Communicating between microservices with Helidon** to easily connect your non Helidon Java code to a Helidon based microservice.


### Helidon - Part 4. Supporting operations activities with Helidon
This labs looks at how Helidion can help you gather data on the fow of operating when you make a call and how your program is being used. This information can help you learn how to optimize your miroservices, especially in deployments where you have a request propagating across many separate microservices.


### Helidon - Part 5. Cloud Native support in Helidon - Kubernetes support
This Helidon lab looks as the features in Helidon that are designed to provide support for cloud native functionality in deployment systems like Kubernetes. For example to help report if a program is still running, but is actually failing to operate (for example it's in a deadlock)


## Helidon - Part Optional Lab modules

The following modules are in **some** cases optional, this is because some of the later modules may depend on these (For example the Visual Builder module we acre working on relies on the completion of the OpenAPI module.) If you are in a guided lab with an instructor they will tell you which of the optional modules you need to complete, if you are doing this in a self-guided mode then please read the descriptions below to determine which optional modules you should do.


### Helidon - Optional 1. Cloud Native support in Helidon - Self describing API's

This is an optional lab if you chose to do it. If you are going to do the Visual Builder optional module we are working on and will be released soon (it shows how to create a mobile / browser based application, with form like capabilities) then you will need to do this module.

To enable a service to be easily consumed Helidon provides support for the dynamic creation of Open API documents (previously known as Swagger)  that document the REST APIs provided by a micro-service. This lab looks at how configure your Helidon projects to generate this information. 


## Docker - Using Docker
The Docker part of the labs covers how we use JIB to create a docker image, run it, then to move the configuration and secrets externally to the docker image, finally we look at how to push the docker image to a repository


## Introduction to Kubernetes labs

In this series of labs we will focus on the specific features of Kubernetes to run Microservices.  These labs use a pre-built set of docker images but you use the images you created in the  **Helidon** and **Docker** if you wish. 

<details><summary><b>Self guided student - Kubernetes video introduction</b></summary>

This video is an introduction to the Kubernetes labs. Once you've watched it please press the "Back" button on your browser to return to the labs.

[![Kubernetes labs Introduction Video](https://img.youtube.com/vi/6Kg-zH6h3Is/0.jpg)](https://youtu.be/6Kg-zH6h3Is "Kubernetes labs introduction video")

---

</details>

## What you are about to create

You will be deploying the storefront and stockmanger microservices (well an image we have provided, though you can use the images you just build if you like) into a Kubernetes cluster. 

Once they are running you will look at how Kubernetes delivers high availability, horizontal scaling and rolling upgrades. There will also be the System services of an Ingress controller with associated load balancer and the Kubernetes dashboard.

Depending on what optional modules you do you may also explore the use of Prometheus and Grafana to capture and visdualize metrics data, Fluend to capture and store log data in Elastic Stack or Object Storage and how the Linkerd service mesh can be used to help monitor and manage your network traffic.

![](../../images/kubernetes-labs-what-will-be-built-incl-optional.png)


## Create your Kubernetes cluster

You will of course need a cluster to work with. Follow the instructions in this module to do that.

## Cloud shell and setup for Kubernetes labs

You will be using the OCI Cloud Shell to execute commands and scripts during these labs. 

You need to follow the cloud shell setup instructions to download the scripts and template files into the cloud shell before you continue with the labs.

## The Kubernetes labs

### Basic Kubernetes - Setting up your cluster and running your services

This section covers how to run the docker images in kubenetes, how to use Kubernetes secrets to hold configuration and access information, how to use an ingress to expose your application on a web port. Basically this covers how to make your docker based services run in in a Kubernetes cluster.

We also look at using Helm to install Kubernetes "infrastructure" such as the ingress server

### Cloud Native with Kubernetes

#### Is it running, and what to do if it isn't

Kubernetes doesn't just provide a platform to run containers in, it also provides a base for many other things including a comprehensive service availability framework which handles monitoring containers and services to see if they are still running, are still alive and are capable of responding to requests.

### Horizontal and Auto Scaling

Kubernetes also supports horizontal scaling of services, enabling multiple instances of a service to run with the load being shared amongst all of them. 

This horizontal scaling lab shows how you can manually control the number of instances.

Horizontal scaling provides you with a manual process to control how many instances of a microservice you have running, but Kubernetes also offers a mechanism to automatically change the number of instances.

This auto scaling labs shows how you can have Kubernetes automatically scale the number of instances for you.

### Rolling out deployment updates

Commonly when a service is deployed it will be updated, Kubernetes provides support for performing rolling upgrades, ensuring that the service continues running during the upgrade. Built into this are easy ways to reverse a deployment roll out to one of it's previous states.


### Optional Lab modules

The following modules are in **some** cases optional, this is because some of the later modules may depend on these (For example the Grafana module relies on the completion of the Prometheus module.) If you are in a guided lab with an instructor they will tell you which of the optional modules you need to complete, if you are doing this in a self-guided mode then please read the descriptions below to determine which optional modules you should do.

These optional modules are grouped by subject area. Unless there are dependencies specified you should be able to do the module groups in any order, though the labs were written following the order defined below, so if you don't do all of them, or in a different order the visuals may differ slightly.

#### Optional labs group 1. Monitoring your services

##### Optional 1a. Monitoring services -  Prometheus for data gathering

Once a service is running in Kubernetes we want to start seeing how well it's working in terms of the load on the service. At a basic level this is CPU / IO's but more interesting are things like the number of requests being serviced. You will need to do this module if you are going to do the Grafana for data display module.

Monitoring metrics may also help us determining things like how changes when releasing a new version of the service may effect it's operation, for example does adding a database index increase the services efficiency by reducing lookup times, or increase it by adding extra work when updating the data. With this information you can determine if a change is worthwhile keeping.

The process for installing and using Prometheus is detailed in the Prometheus module.

##### Optional 1b. Monitoring services - Grafana for data display
To do this optional module you will have to have completed the optional Promtheus for data gathering module.

As you've seen Prometheus is great at capturing the data, but it's not the worlds best tool for displaying the data. Fortunately for us there is an open source tool called **Grafana** which is way better than Prometheus at this.

The process for installing and using Grafana is detailed in the Visualising with Grafana module

#### Optional labs group 2. Capturing log data
These labs are self standing, you can do either of them, or both. They have no dependencies and currently there are no other optional modules dependent on them.

Both these lab modules use fluentd to read the log data within the Kuberntes environment

##### Optional 2a. Log Capture for processing

This optional module shows how you can use fluentd to capture the log data, and then write the output to Elastic Search (often used to help process log data in Cloud Native deployments.) The module is intended as an example of how to handle log data for people who will need instant indexed access to the log data.

To understand how to do do this look at the Log capture for processing module.


##### Optional 2b. Log Capture for long term storage (archive)

This optional module shows how you can use fluentd to capture the log data, and then write the output to a long term storage offering, In this case we will be writing to the S3 compatible Oracle Object Storage Service. The module is intended as an example to how to handle log data for people that need to retain log data for the long term (perhaps for legal reasons) but don't need instant access, so can use the most cost effective long term storage.

The process here is covered in the Log Capture For Archive module.

#### Optional labs group 3 Service meshes

These labs are semi-independent, You must do the 3a Service mesh install and setup module, but after that you can do most of the Service mesh modules in any order order listed, the exception is if you want to do the traffic split module you must have done the troubleshooting module. If you don't want to do all of them you can stop at any point. If you decide to uninstall the linkerd service mesh then obviously (I hope!) do that once you have completed the all service mesh labs you want to do!

A service mesh is two parts, a control plane that manages the mesh, and a data layer that is automatically added to your Kubernetes deployments by the control plane (usually by what's known as a sidecar container.) The data plane sits between your micro-service implementations and the underlying network, and manages your network activities. Depending on the implementation the data plane can even cross multiple Kubernetes clusters, making them appear as one. 

The data plane provides support for things like automatically encrypting traffic exiting your micro-service implementation and decrypt it on arrival at the next (whilst automatically handling certificate management for you.) It can also do things like traffic management functions where it implements the service balancing (again this can be cross cluster for some service mesh implementations) and traffic balancing where a portion of the traffic is diverted to a test instance, perhaps for automated A/B testing or for a canary rollout where a CI/CD toolkit triggers a deployment, and the tooling in conjunction with the service mesh tests it out on a small subset of the traffic, automatically canceling the rollout if there are problems.

Service meshes can also monitor the traffic flowing throughout your clusters, enabling the gathering of detailed request / response statistics, for example what the failure rate is of requests to a particular endpoint.

As they are part of the network they can also split the network traffic, enabling activities like canary rollouts and testing the system by injecting faults.


##### Optional 3a Service mesh install and setup

You must do this module before you can do any of the other service mesh modules

This module shows how to install the Linkerd service mesh, and enable it on the micro-servcies we have been using for this lab.

Installation is covered in the Installing the Linkerd service mesh module

##### Optional 3b. Monitoring traffic with the service mesh

You must have done the service mesh install and setup module before this one.

This module shows how to use the service mesh we installed in Optional lab 3a to report on the traffic between the micro-services in our application on the cluster.

You can see how to do traffic monitoring in the Traffic monitoring with a Linkerd service mesh module.

##### Optional 3c. Using the service mesh to troubleshoot problems

You must have done the service mesh install and setup module before this one.

This modules uses a simulated "broken" implementation of the stockmanager service to generate errors, then we use the service mesh monitoring capabilities to see where the error is and the conditions around it.

To understand how to troubleshoot using the service mesh see the  service mesh see the Using the Linkerd service mesh for troubleshooting module.

##### Optional 3d. Using the traffic split facility of the service mesh

You must have done the service mesh install and setup module, and the service mesh troubleshooting module before this one.

This module looks at the traffic split capability in the service mesh implementations to see how it can be used for testing purposes, for example injecting faults to do some chaos engineering and test out the overall environment.

This module also used the traffic split capability of the service mesh to show how you can do a canary deployment

Discover what you can do with a service mesh traffic splits in the Traffic splits with the Linkerd service mesh (Canary deployments, and chaos engineering) module.

##### Optional 3e Uninstalling the service mesh

**Only** do this after you have completed the service mesh lab modules you want to do.

To learn how to uninstall the service mesh see the it Uninstalling the Linkerd service mesh module.


### Additional optional modules in development.

We are working on or exploring the possibility of a number of additional optional modules, these include integrating micro-services and serveless as part of your overall architecture, using an API Gateway, accessing your service with a chatbot, and building simple web front ends for your service. As these (and other) are completed they modules will be added here. If you have an interest in further additional modules please let us know and we'll see what we can do.

---



## Further Information

For links to useful web pages and other information that I found while writing these labs see the further information on Kubernetes section


## End of this tutorial

We hope you enjoy doing the labs, and that they will be useful to you. 

When you finish the modules in this lab the take the time for a cup of tea (or other beverage of your choice). While you're having that well earned break we recommend that you visit the [Oracle live labs site](https://apexapps.oracle.com/pls/apex/dbpm/r/livelabs/home) for a wide range of other labs on a variety of subjects.

## Acknowledgements

* **Author** - Tim Graves, Cloud Native Solutions Architect, EMEA OCI Centre of Excellence
* **Last Updated By** - Tim Graves, November 2020


