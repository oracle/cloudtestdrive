[Go to Overview Page](../README.md)

![](../../../common/images/customer.logo2.png)

# Migration of Monolith to Cloud Native

## A. Helidon for Cloud Native

This set of lab instructions is based on the virtual machine image dated 2020-10-09 (9th October 2020)

### Setup for the Helidon labs

You will need to import the template code you will be using into eclipse, and do some small VM configurations.

Please follow [the setup instructions.](setup/setup.md) When you've completed them click the `back` button on your browser to return to this page.

### **Introduction**

<details><summary><b>Self guided student - video introduction</b></summary>
<p>

This video is an introduction to the Helidon labs. Once you've watched it please press the "Back" button on your browser to return to the labs.

[![Helidon labs Introduction Video](https://img.youtube.com/vi/182KYHSrf5A/0.jpg)](https://youtu.be/182KYHSrf5A "Helidon labs introduction video")

</p>
</details>

---

<details><summary><b>What is Helidon?</b></summary>
<p>

[Helidon](https://helidon.io) is an open source implementation of [Eclipse Microprofile](https://microprofile.io/) from Oracle. Through these labs we talk about Helidon, but it's key to remember that the work we're doing is applicable to *any* microprofile implementation, of which Helidon is one.

Microprofile (and thus Helidon) are designed to be lighter weight than things like Java EE or Spring Boot, but also more standards based than Spring, so it has more stability from an API change perspective.

Microprofile is built on other pre-existing standards, for example the `@GET` annotation is used by microprofile (Helidon uses it to indicate a method respond to a http GET request), but the annotation itself is actually a Java web services annotation that microprofile uses. 

This lab aims to introduce you to the major capabilities provided by the Helidon implementation of Microprofile. It does this in a number of stages, starting with core capabilities such as REST enabling a class and moving on to features such as building clients to talk to other REST services and how to use Helidon to quickly create service elements that support Cloud Native tools such as Kubernetes.

We are using Helidon MP, this is an annotation based framework, where to utilize it you just place annotations (e.g. `@Path("/mypath"`) on a class or method. There is no need to modify the code beyond that. Helidon also comes in a variety called Helidon SE. The SE framework however requires you to actually make the Java method calls yourself, so you'd have to change your code. Helidon MP actually converts the annotations at runtime into calls to the Helidon SE Java API, so there is no need to change your logic. Helidon MP is also similar in style to frameworks like __Spring__ which are also annotation based, so we've chosen the MP version for these labs.

</p></details>



---

<details><summary><b>Requirements for this Lab</b></summary>
<p>

We have assumed you understand the basic concepts of what a REST service is.

The labs **do require basic programming knowledge**. As Helidon is a Java set of libraries then of course you need to have an understanding of simple Java programming. The labs are deliberately designed not to require detailed understanding of complex Java technologies, though if you do happen to be a Java expert you may be able to apply that knowledge to gain deeper understanding of how Helidon operates.

The labs were developed using the Eclipse IDE. Again you don't need to be an expert here, but you need to have some familiarity with how to navigate using the IDE (It's very similar to other IDE's like Netbeans or InteliJ) and how to compile and run things.

We do not expect you to know the details of the Maven build / packaging tool. In particular we are **not** going to be getting you to edit the pom.xml file (the Maven configuration file) for these projects. If you are familiar with Maven and the pom.xml file please feel free to explore it, or copy it for your own projects as a start point, but please do not make any changes to it in this lab. The only exception to this is in some of the optional modules, in which case we will be clear on the changes you need to make.

</p></details>

---


<details><summary><b>How to do the coding in the labs</b></summary>
<p>

Most of the labs explain what a specific Helidon features is and why it's useful, then there is a coding example with explanation of the feature. The coding example will usually tell you to modify a particular class (usually by providing you with the fully qualified name of the class, for example `com.oracle.labs.helidon.stockmanager.Main`) and make a specific change to a certain method (e.g. the `buildConfig` method or the constructor.) 

Occasionally it will tell you to just modify the class itself, for example adding an annotation on the class declaration. We try to be clear what the project is for each set of labs, but expect you to be able to use eclipse to open the right .java file (which is referred to but it's fully qualified class name to you can navigate to it) and find the method.

</p></details>



---

<details><summary><b>Java Imports</b></summary>
<p>

We have tried to ensure that the imports you need are already in the source code, however in some cases when we create the initial state or the code for you Eclipse may have removed imports that are not used in the initial state but you will need to use.

If you have problems with missing classes and imports we have added expanding sections for you detailing the imports you will need to add. Note that in some sections where we are re-using something that's already imported we will not tell you to add a duplicate import.

</p></details>



---

<details><summary><b>Testing your service as you go</b></summary>
<p>

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

</p></details>

---



<details><summary><b>The Monolith application we will decompose</b></summary>
<p>
The labs follow the migration of a (admittedly) simple Java program to being a couple of separate microservices. The related Docker and Kubenetes labs then take the microservices, show how to package and run them in Docker and then deploy on Kubernetes in a Cloud Native format.

At it's core the program allows a caller to request the levels of stock items held in a database, and to record items as having been removed. Think of this as perhaps a system that handles consumable items in a post room or something. People may lookup what's there, take stationary and update the database when they do so. As a separate function not included here (but just to explain the scenario) the facilities manager may look at the database, order replacement items and update the stock levels when they are delivered.

Fortunately this company is not run by people who think that the cost of a inter-departmental cross charge for a box of paper clips is good use of people's (or developer's) time, so when someone updates the database having taken stock there is no need to record who took what :-)

The code does not provide a front end UI. It would normally be libraries that are used part of a larger function and the external interface.

The basic program has two sets of functionality, split into two projects in Eclipse. A module (stockmanager) that interacts with a database table. This module allows Create Delete, Update and Deletes to be made on a table. A second module (storefront) provides a bit of business logic and processing, for example ensuring that business rules around minimum quantities are applied when taking stock.

This is a deliberately simple example, the goal is to see how these two modules can be converted from a traditional **Monolith** type of approach into cloud native ready microservices, with as little as possible being changed in the actual code - we actually don't make *any* changes to the code logic, all of the modifications are done by adding annotations.

Also we are not addressing how to split any existing monolith into modules, hopefully you will have done that when you created the initial program and functionally decomposed your original requirements. There is no single "right" or "wrong" way to decompose your monolith functionally, but I do recommend reading up on the "Strangler Pattern" and the "Anti Corruption Pattern" as they are very useful architectural approaches to take.
</p></details>

---

## The labs

### 1. Core Helidon
The core labs are designed to show how you can take a some existing Java code and REST enable it so it can operate as a standalone service. This includes not just the REST API, but also configuration, error handling and security.

[The core Helidon lab](Helidon-core/helidon-core.md)



### 2. Databases and Helidon
This looks at how you can access databases within a Helidon based application.

[The database lab](Helidon-data/helidon-data.md)



### 3. Communicating services with Helidon
This lab shows the support in Helidon for switching from a direct method call to using a REST call without modifying the calling method.

[The cross service communication lab](Helidon-to-Other-Microservices/helidon-to-other-microservices.md)



### 4. Supporting operations activities with Helidon
This labs looks at how Helidion can help you gather data on the fow of operating when you make a call and how your program is being used. This information can help you learn how to optimize your miroservices, especially in deployments where you have a request propagating across many separate microservices.

[The Helidon support for Ops lab](Helidon-Operations/helidon-operations.md)



### 5. Cloud Native support in Helidon - Kubernetes support
This Helidon lab looks as the features in Helidon that are designed to provide support for cloud native functionality in deployment systems like Kubernetes. For example to help report if a program is still running, but is actually failing to operate (for example it's in a deadlock)

[The Helidon support for Cloud Native Operations lab](Helidon-cloud-native/helidon-cloud-native.md)


---



## Optional Lab modules

The following modules are in **some** cases optional, this is because some of the later modules may depend on these (For example the Visual Builder module relies on the completion of the OpenAPI module.) If you are in a guided lab with an instructor they will tell you which of the optional modules you need to complete, if you are doing this in a self-guided mode then please read the descriptions below to determine which optional modules you should do.


### 	Optional 1. Cloud Native support in Helidon - Self describing API's

This is an optional lab if you chose to do it. If you are going to do the Visual Builder optional module (it shows how to create a mobile / browser based application, with form like capabilities) then you will need to do this module.

To enable a service to be easily consumed Helidon provides support for the dynamic creation of Open API documents (previously known as Swagger)  that document the REST APIs provided by a micro-service. This lab looks at how configure your Helidon projects to generate this information. 

[The Helidon support for Open API Document generation](Helidon-open-api/helidon-open-api.md)

---





### What's next
Once you've finished these labs then it's time for a cup of tea (or other beverage of your choice.)

Please look at the follow-on lab focusing [packaging these new microservices in Docker](../Docker/DockerLabs.md) and deploying them in Kubernetes.



------

[Go to Overview Page](../README.md)

