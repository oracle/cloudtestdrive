[Go to the Cloud Test Drive Welcomer Page](../../README.md)

![](../../common/images/customer.logo2.png)

# Microservices on Kubernetes and Autonomous Database

## Setting up a CI/CD environment for developing Microservices on an ATP Database, with Developer Cloud

## Introduction

This lab will walk you through the steps to set up a CI/CD environment for developing Microservices, based on the automation possible in Developer Cloud and deploying all components on Oracle's Managed Container platform and the ATP database.

## Prerequisites

To run these labs you will need access to an Oracle Cloud Account.  We have prepared this lab for the following situations: 

- You are using your own Oracle Cloud Tenancy, either via a **Trial**, using a **Pay-as-you-Go** account, or using the **Corporate account** of your organization.  If you do not have an account yet, you can obtain  a [Free Trial account](https://myservices.us.oraclecloud.com/mycloud/signup?sourceType=:eng:lw:ie::RC_EMMK190301P00254:220519_MicroATP).

  In this case, you need to go through the **Part 0** of this tutorial, to prepare your environment for this lab.

  

- If you are participating in a **in-person Oracle event**, your instructor will provide you the required credentials to access an environment that has already been prepared with the minimum policies, account credentials etc.  
  **In this case you can <u>skip Part 0</u>**





## Components of this lab

This lab is composed of the steps outlined below.  Please walk through the various labs in a sequential order, as the different steps depend on each other:

- **Part 0**:  [Preparing your Tenancy for the lab](env-setup.md) .  **ATTENTION : Only for personal tenancies.**  Please skip this part if your instructor provided you an environment.



In case you already participated in the lab **Autonomous Database Hands-On Lab**, you just created a new ATP database and learned how to connect to this database instance.  In this case, you can skip Part 1 and Part 2, and go straight to Part 3, using the ATP database you created in the previous lab for all subsequent database activities.

- **Part 1:** [Provisioning an Autonomous Transaction Processing Database Instance](LabGuide100ProvisionAnATPDatabase.md)  using the OCI Console (manual).
- **Part 2:** [Connecting to your Database](LabGuide200SecureConnectivityAndDataAccess.md) using the secure wallet



Start here after successfully connecting to an ATP dabase instance:

- **Part 3:** [Setting up your Developer Cloud project](LabGuide250Devcs-proj.md)
- **Part 4:** [Create and populate the Database objects](LabGuide400DataLoadingIntoATP.md) in your ATP database with Developer Cloud
- **Part 5:** [Spin up a Managed Kubernetes environment with Terraform](LabGuide660OKE_Create.md)
- **Part 6:** [Build a Container image with the aone application running on ATP](LabGuide650BuildDocker.md)
- **Part 7:** [Deploy your container on top of your Kubernetes Cluster](LabGuide670DeployDocker.md)

---



[Go to the Cloud Test Drive Welcomer Page](../../README.md)



#### [License](../../LICENSE.md)

Copyright (c) 2014, 2016 Oracle and/or its affiliates
The Universal Permissive License (UPL), Version 1.0