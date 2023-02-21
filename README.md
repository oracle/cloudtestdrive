![](common/images/customer.logo2.png)
---
# Cloud Test Drive Overview page #

## Introduction ##

This project contains the lab materials for the Cloud Test Drive events organized in various locations.  Participants can experiment through these labs with a series of Oracle Cloud Services.  

![](common/images/Introslide.PNG)

During this day you will be able to experience the various cloud services hands-on.  Below you find the link to all labs available : 


## Application Development ##
- [Getting started with Kubernetes Clusters on OCI](https://www.oracle.com/webfolder/technetwork/tutorials/obe/oci/oke-full/index.html)
  A simple lab spinning up a Kubernetes container and deploying a hello-world application 
- [Microservices using Autonomous ATP and Managed Containers](https://oracle.github.io/cloudtestdrive/AppDev/ATP-OKE/livelabs-trial/)
  This lab will cover the complete setup of Developer Cloud, a Kubernetes Cluster and an Autonomous Database, and then build the CI/CD flow to deploy a Node-based microservice onto this infrastructure, starting from a fresh Cloud Free Trial.  If you are joining an instructor-led Cloud Test Drive lab, your instructor might ask you to follow [this](https://oracle.github.io/cloudtestdrive/AppDev/ATP-OKE/livelabs-ctdenv) alternative version of the lab.
- [GitOps with Oracle Kubernetes Engine](AppDev/OKE-GitOps/README.md) (OKE) : learn how to use Oracle managed Kubernetes with the  GitOps approach, a new paradigm of implementing Continuous Delivery (CD) for cloud-native applications.

+ Run your first **serverless Functions** [using the Opensource FnProject](AppDev/functions/function2_lab.md) or by using the Oracle Managed service called [Oracle Functions](https://www.oracle.com/webfolder/technetwork/tutorials/infographics/oci_faas_gettingstarted_quickview/functions_quickview_top/functions_quickview/index.html#).  Or optionally [create a function from an exiting Docker](https://github.com/shaunsmith/functionslab-codeone19/blob/master/6-Container-as-Function.md) container.

+ [Functions and Events](AppDev/functionsandevents/FnHandson.md): showcasing event-driven serverless functions and an Autonomous database. 

+ Discover the **Helidon Microservices framework for Java** by running through the 2 Getting Started [Quickstarts](https://helidon.io/docs/latest/#/guides/01_overview) for the SE and MP flavour, and then continue with more advanced features like Metrics and Healthchecks in [this tutorial](https://github.com/tomas-langer/helidon-conference/blob/master/README.md)

+ [Building Multi-Cloud Apps on Microsoft Azure and Oracle Cloud Infrastructure](AppDev/OCI-Azure-Interconnection/README.md)
  Develop .NET web application hosted on Azure and connect it to Oracle Autonomous Database on OCI through a private cross-cloud interconnection link
  
+ [Use Rancher to monitor your OKE deployments](https://github.com/oracle/cloudtestdrive/blob/master/AppDev/oke-rancher/readme.md)

+ Running a **Helidon** microservice on **Verrazzano** lab](https://oracle.github.io/cloudtestdrive/AppDev/wls/helidon-verrazzano/workshops/)

+ ***New!***   [Deploying an Oracle **Database on Kubernetes** with the Database Operator for Kubernetes lab](https://oracle.github.io/cloudtestdrive/AppDev/database-operator/workshops/freetier/)

  



## WebLogic Labs

+ **WebLogic for OCI** marketplace to automate setting up WebLogic with VM's on Oracle Cloud
  
  + Run the [non-JRF version of the lab](https://oracle.github.io/cloudtestdrive/AppDev/wls/ll-nonjrf), (no database setup)
  + Run the [JRF version of the lab](https://oracle.github.io/cloudtestdrive/AppDev/wls/ll-jrf) including database creation and deployment of an ADF application
  
+ ***New!***  [WebLogic for OKE](https://oracle.github.io/cloudtestdrive/AppDev/wls/ll-wls-for-oke-nonjrf/livelab/) - running WLS on Kubernetes via Marketplace
  Launch WebLogic on a Managed Kubernes cluster (OKE), using the pre-configured image provided by Oracle in the Marketplace.

+ [Running WebLogic on Kubernetes](https://oracle.github.io/cloudtestdrive/AppDev/wls/ll-oke/) with a customer managed Operator
  Launch WebLogic on a Kubernetes cluster, using the WebLogic Operator to control your WebLogic environment.
  
+ [Migrating Java EE "Monolith" application libraries to Cloud Native development using Microservices and Helidon](AppDev/cloud-native/README.md)

  

## Data Integration & Data Mesh

- [Data Mesh Lab](https://oracle.github.io/cloudtestdrive/DataManagement/DataMesh/DataMeshMonolithMicro/workshops/freetier2/) : connecting a Monolith application with a Microservice




## Autonomous Databases

- [Develop APEX applications](ATP/APEX/readme.md) running on top of the Autonomous Transaction Processing Database.



## BlockChain ##

+ [Set up a Blockchain network, and experiment with some transactions and Smart Contracts](BlockChain/readme.md)

  

## Data Science ##

+ [Follow a series of Data Science labs (now on LiveLabs)](https://apexapps.oracle.com/pls/apex/dbpm/r/livelabs/view-workshop?wid=788)

  

## Enterprise JavaScript User Interface Development ##

+ [Web Component Development with Oracle JET](https://github.com/geertjanw/ojet-training/blob/master/README.md)

## Contributing

This project welcomes contributions from the community. Before submitting a pull request, please [review our contribution guide](./CONTRIBUTING.md)

## Security

Please consult the [security guide](./SECURITY.md) for our responsible security vulnerability disclosure process

## Installation

This repo only contains lab instructions, there is no installation needed.

## License

Copyright (c) 2014, 2022 Oracle and/or its affiliates
The Universal Permissive License (UPL), Version 1.0
