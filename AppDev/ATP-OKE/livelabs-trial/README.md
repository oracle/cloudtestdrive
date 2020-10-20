

![](../../../common/images/customer.logo2.png)

# Microservices on Kubernetes and Autonomous Database

## Setting up a CI/CD environment for developing Microservices on an Autonomous Database, with Visual Builder Studio

## Introduction

This lab will walk you through the steps to set up a CI/CD environment for developing Microservices, based on the automation possible in Visual Builder Studio and deploying all components on Oracle's Managed Container platform and the ATP database.

***3-Apr-2020 : New Version using Cloud Shell !***  For Lab Instructors, please be aware this lab has been updated to use the **Oracle Cloud Shell** for all operations involving git, terraform and kubectl.  The full lab is now executed through the browser !



## Prerequisites

To run these labs you will need access to an Oracle Cloud Account.  

<u>We assume you are using your own Oracle Cloud Tenancy,</u> either via a **Free Tier**, using a **Pay-as-you-Go** account, or using the **Corporate account** of your organization.  

==> If you do not have an account yet, you can obtain  an Oracle Free Tier account by [clicking here.](https://signup.oraclecloud.com/?sourceType=:em:lw:ie:pt::RC_WWMK200730P00046:EMEAHOL20OCT)

Next, follow the steps described below.



## Components of this lab

This lab is composed of the steps outlined below.  Please walk through the various labs in a sequential order, as the different steps depend on each other:

- Preparing your Tenancy for the lab

- **Part 1:** Setting up your Visual Builder Studio project
- **Part 2:** Create and populate the Database objects in your ATP database with Visual Builder Studio
- **Part 3:** Spin up a Managed Kubernetes environment with Terraform
- **Part 4:** Build a Container image with the aone application running on ATP
- **Part 5:** Deploy your container on top of your Kubernetes Cluster

Use the menu on the right side of the screen to navigate to the various chapters of this lab.

---





## License

Copyright (c) 2014, 2020 Oracle and/or its affiliates
The Universal Permissive License (UPL), Version 1.0
