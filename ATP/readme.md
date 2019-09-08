[Go to the Cloud Test Drive Overview](../README.md)

![](../common/images/customer.logo2.png)

# Autonomous Transaction Processing for Developers #



## Lab Introduction ##

In this hands-on lab you will get first-hand experience with Oracle’s new Autonomous Transaction Processing (ATP) service. Oracle ATP delivers a self-driving, self-securing, self-repairing database service that can instantly scale to meet demands of mission critical transaction processing and mixed workload applications. 

The lab is structured in two sections 

- **Section 1** – Introduction to ATP 
- **Section 2** – Focus on Developer features - *For Developers*




## Prerequisites ##

- To run these labs you will need access to an Oracle Cloud Account.  Your instructor will provide you a URL that allows to perform **Self Registration**, where you will be asked to provide a username and a password of your choosing.  **Please note down this username and password, you will need this info later in the labs!**

- This lab requires you to install a VNC viewer on your Laptop so that you can complete this hands-on lab.   There are many VNC viewer packages both commercial and open source. 

  - For **macOS** we advise realVNC which can be obtained from 

    - https://www.realvnc.com/en/connect/download/viewer/macos/

  - For **Windows**, suggested packages are TigerVNC viewer or TightVNC Viewer but if you already have a preferred VNC viewer you can use this. TigerVNC viewer has a simpler install process, as it is a standalone executable, but has fewer features.

    - TigerVNC: Download ‘vncviewer64-1.9.0.exe’ from

      - https://bintray.com/tigervnc/stable/tigervnc/1.9.0#files and save it to your desktop. It is a self-contained executable file, which requires no further installation.

    - TightVNC Viewer: Select the 'Installer for Windows (64-bit)' from

      - https://www.tightvnc.com/download.php

        When prompted, select to save the file.  Next, run the executable to install the program. This requires you have the privileges to install software on your machine

- **USING A PERSONAL TRIAL ACCOUNT ?** 

  In case you are using a personal Cloud Trial Account, you will need to prepare your Cloud Environment to be able to execute these labs.  See [instructions on this page](../AppDev/ATP-OKE/README.md) for all details.

  



## Lab Instructions ##

**Section 1** - Introduction to ATP 

This section will take you through connecting to your Lab VM, locating your ATP instance and connecting to it using SQL Developer.

- **Part 1:** [Connecting to the Oracle Cloud](./LabGuideOSC100Login.md)

- **Part 2:**  [Securely Connecting to Autonomous Transaction Processing](LabGuideOSC200Connect.md)

  


**Section 2** - Focus on Developers

This section will take you through the steps to set up a CI/CD environment for developing Microservices, based on the automation possible in Developer Cloud and deploying all components on Oracle's Managed Container platform.

- **Part 1:** [Setting up your Developer Cloud project](../AppDev/ATP-OKE/LabGuide250Devcs-proj.md)
- **Part 2:** [Create and populate the Database objects](../AppDev/ATP-OKE/LabGuide400DataLoadingIntoATP.md) in your ATP database with Developer Cloud
- **OPTIONAL Part 3:** [Spin up a Managed Kubernetes environment with Terraform](../AppDev/ATP-OKE/LabGuide660OKE_Create.md)
- **Part 4:** [Build a Container image with the aone application running on ATP](../AppDev/ATP-OKE/LabGuide650BuildDocker.md)
- **Part 5:** [Deploy your container on top of your Kubernetes Cluster](../AppDev/ATP-OKE/LabGuide670DeployDocker.md)



---


[Go to the Cloud Test Drive Overview](../README.md)

