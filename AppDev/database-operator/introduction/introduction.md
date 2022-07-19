# Introduction

## About this Workshop

This lab shows you how to deploy and run an Oracle Database inside a Kubernetes cluster, using the Oracle Database Kubernetes Operator (the "operator").

The Database operator offers more deployment options that will not be covered in this lab : running an Autonomous database, or running an on-premise PDB on a CDB.  See the [Oracle Database Operator for Kubernetes](https://github.com/oracle/oracle-database-operator) documentation for more details.

We'll be using 2 types of persistant storage : first a dynamic Block Volume, that will be deleted automatically once the database is deleted, and seond using a static NFS filesystem, which allows to have automatic failover between nodes of the kubernetes cluster.

This lab will explain in detail all the steps required to set up the environment using an Oracle OCI trial environment, using the Oracle Ku

### About Product/Technology

A WebLogic domain can be located either in a persistent volume (PV) or in a Docker image. There are advantages to both approaches, and sometimes there are technical limitations of various cloud providers that may make one approach better suited to your needs. See
[Choose a model](https://oracle.github.io/weblogic-kubernetes-operator/userguide/managing-domains/choosing-a-model/).

This tutorial uses the Docker image with the WebLogic domain inside the image deployment. This means that all the artifacts and domain-related files are stored within the image. There is no central, shared domain folder from the pods. This is similar to the standard installation topology where you distribute your domain to different hosts to scale out Managed Servers. The main difference is that by using a container-packaged WebLogic domain, you don't need to use the pack/unpack mechanism to distribute domain binaries and configuration files between multiple hosts.

![](images/architecture.png)

In a Kubernetes environment, the operator ensures that only one Administration Server and multiple Managed Servers will run in the domain. An operator is an application-specific controller that extends Kubernetes to create, configure, and manage instances of complex applications. The Oracle WebLogic Server Kubernetes Operator simplifies the management and operation of WebLogic domains and deployments.

Helm is a framework that helps you manage Kubernetes applications, and helm charts help you define and install Helm applications in a Kubernetes cluster.

This tutorial has been tested on the Oracle Cloud Infrastructure Container Engine for Kubernetes (OKE).

[](youtube:yVdr4GmpxqY)

### Objectives

* Set up an Oracle Kubernetes Engine instance on the Oracle Cloud Infrastructure
* Install the WebLogic Server Kubernetes Operator
* Install a Traefik software load balancer
* Deploy a WebLogic domain
* Scale a WebLogic cluster
* Update a deployed application by a rolling restart of the new image
* Assign WebLogic pods to nodes (a scenario simulating a cluster spanning 2 data centers)](node.selector.ocishell.md)

### Prerequisites

Access to an Oracle Cloud account

This version of the lab is created for running a hands-on lab **under the guidance of Oracle Experts**, who will provide you with access to an individual Cloud Account during the live session.

If you want to run this lab **independantly**, please use the [LiveLab version](https://apexapps.oracle.com/pls/apex/dbpm/r/livelabs/view-workshop?wid=567&clear=180&session=109068004389019), which includes a section on how to obtain a free Oracle Cloud Trial account.

## Learn More

* [WebLogic Kubernetes Operator Documentation](https://oracle.github.io/weblogic-kubernetes-operator)

## Acknowledgements
* **Author** - Maciej Gruszka, Peter Nagy, September 2020
* **Last Updated By/Date** - Jan Leemans, January 2022
