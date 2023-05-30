![](../../../../common/images/customer.logo2.png)

# DevOps Lab Setup introduction

## Introduction

Welcome to the setup part of this lab

There is some setup required before we can start using the DevOps service to build our pipelines service. 

This setup covers :
  
  - Creating a Vault to securely hold our configuration information

  - Configuring an ssh identification token to enable code to be pushed into a git repository in the DevOps service
  
  - Defining dynamic groups to identify DevOps services running in your compartment
  
  - Defining policies that allow the dynamic groups to control services in your compartment 
  
  - Creating a notifications topic which is used by the individual parts of the DevOps service to communicate with each other
  
  - Creating a DevOps project for you to use in the rest of the lab
  
### A note on notes

In the text you may come across lines that look like the following. You can click on the arrow to expand them, try it with this one.

<details><summary><b>Click the arrow to expand me</b></summary>

Congratulations, you have clicked on the arrow and can now see this additional text.

These details sessions usually contain explanatory text that goes into more detail than some people want to know or they may provide guidance on unexpected situations  that may occur in the lab and how to address them.

To close the expansion band these these details just click the arrow again.

---

</details>

### The OCI Support box	

In the OCI Web interface you may encounter the OCI Help box as in the image below. This can use used to contact OCI support if you have questions on the operation of OCI. Please **do not** try and use it for help on this lab though, the team can only support the OCI functionality itself.

![](images/oci-bui-help-box.png)

It may sometimes be in a rather inconveniently placed and obscuring part of the screen to want to access, but if you want to move it simply click the section containing the grey dots and move it up or down.


### Prerequisites

You must have an existing Oracle Kubernetes  cluster with the storefront and stockmanmager microservices deployed and connected to an Oracle Autonomous Transaction Processing database. If you are running this as part of the larger Kubernetes or Helidon and Kubernetes labs you will have already created that environment, if you are doing this as a standalone lab then you should have completed the **Creating the environment** modules and tested that you can retrieve data from the microservices.

Right, let's get started with the lab setup, please click the **Devops setup - setting up your vault** in the labs modules list to get going on the lab specific setup.

## Acknowledgements

* **Author** - Tim Graves, Cloud Native Solutions Architect, Oracle EMEA Cloud Native Application Development specialists Team
* **Last Updated By** - Tim Graves, May 2023