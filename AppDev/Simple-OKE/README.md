[Go to the Cloud Test Drive Welcomer Page](../../readme.md)

![](../../common/images/customer.logo2.png)

# Getting started with Kubernetes Clusters on OCI

## Setting up a Managed Kubernetes cluster, push a container image to the repository, and deploy the container on OKE

## Introduction

Oracle Cloud Infrastructure Container Engine for Kubernetes is a fully-managed, scalable, and highly available service that you can use to deploy your containerized applications to the cloud. Use Container Engine for Kubernetes together with Oracle Cloud Infrastructure Registry when your development team wants to reliably deploy, and manage cloud / container-native applications.

This lab is a simplified version of the original [Oracle Learning path](https://apexapps.oracle.com/pls/apex/f?p=44785:50:15890561538718:::50:P50_COURSE_ID,P50_EVENT_ID:256,5935), specifically written to be run on an Oracle provided test tenancy where users, policies and certificates have already been created for you.  If you are planning to run this lab on a **Free Tier** tenancy, please use the [original version](https://apexapps.oracle.com/pls/apex/f?p=44785:50:15890561538718:::50:P50_COURSE_ID,P50_EVENT_ID:256,5935) and execute all the initial setup steps.

## Prerequisites

To run these labs you will need access to an Oracle Cloud Account.  We have prepared this lab for the following situation: 

- <u>You are joining an in-person Oracle event</u>: your instructor will provide you the required credentials to access an environment that has already been prepared with the minimum policies, account credentials etc.  
- You will be using a Linux desktop running on OCI with all software pre-installed.  See [these instructions ](../cloud-native/ManualSetup/CreateClientVm.md)to get started.

## Components of this lab

This lab is composed of the steps outlined below.  Please walk through the various labs in a sequential order, as the different steps depend on each other:

- [Creating a Cluster with Oracle Cloud Infrastructure Container Engine for Kubernetes](createcluster.md)
- [Pushing an Image to Oracle Cloud Infrastructure Registry](uploadimage.md)
- [Pulling an Image from Oracle Cloud Infrastructure Registry when Deploying a Load-Balanced Application to a Cluster](runcontainer.md)



[Go to the Cloud Test Drive Welcomer Page](../../readme.md)



#### [License](../../LICENSE)

Copyright (c) 2014, 2020 Oracle and/or its affiliates
The Universal Permissive License (UPL), Version 1.0