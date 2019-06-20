[Go to the Cloud Test Drive Welcomer Page](../../README.md)

![](../../common/images/customer.logo2.png)

# Microservices on Kubernetes and Autonomous Database

## Setting up a CI/CD environment for developing Microservices on an ATP Database, with Developer Cloud

## Introduction

This lab will walk you through the steps to set up a CI/CD environment for developing Microservices, based on the automation possible in Developer Cloud and deploying all components on Oracle's Managed Container platform and the ATP database.

## Prerequisites

- To run these labs you will need access to an Oracle Cloud Account.  Your instructor will provide you a URL that allows to perform **Self Registration**, where you will be asked to provide a username and a password of your choosing.  **Please note down this username and password, you will need this info later in the labs!**

- This lab requires you to install a VNC viewer on your Laptop so that you can complete this hands-on lab.   There are many VNC viewer packages both commercial and open source. 

  - For macOS we advise realVNC which can be obtained from 

    - https://www.realvnc.com/en/connect/download/viewer/macos/

  - For Windows, suggested packages are TigerVNC viewer or TightVNC Viewer but if you already have a preferred VNC viewer you can use this. TigerVNC viewer has a simpler install process, as it is a standalone executable, but has fewer features.

    - TigerVNC: Download ‘vncviewer64-1.9.0.exe’ from

      - https://bintray.com/tigervnc/stable/tigervnc/1.9.0#files and save it to your desktop. It is a self-contained executable file, which requires no further installation.

    - TightVNC Viewer: Select the 'Installer for Windows (64-bit)' from

      - https://www.tightvnc.com/download.php

        When prompted, select to save the file.  Next, run the executable to install the program. This requires you have the privileges to install software on your machine.

## Connecting to your Lab Virtual Machine

To reduce the amount of software that needs to be installed on your local machine we have prepared a Linux virtual machine to act as your desktop.

Start TigerVNC viewer (or your choice of VNC viewer) by double clicking on the icon on your local desktop.
Enter connection information (IP address and password)  provided by your lab leader and select Connect.



## Components of this lab

This lab is composed of the steps outlined below.  Please walk through the various labs in a sequential order, as the different steps depend on each other:

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



#### [License](../../LICENSE)

Copyright (c) 2014, 2016 Oracle and/or its affiliates
The Universal Permissive License (UPL), Version 1.0