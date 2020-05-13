[Go to the Cloud Test Drive Overview](../readme.md)

![](../common/images/customer.logo2.png)

# Autonomous Transaction Processing for Developers #



## Lab Introduction ##

In this hands-on lab you will get first-hand experience with Oracle’s new Autonomous Transaction Processing (ATP) service. Oracle ATP delivers a self-driving, self-securing, self-repairing database service that can instantly scale to meet demands of mission critical transaction processing and mixed workload applications. 

***3-Apr-2020 : New Version using Cloud Shell !***  For Lab Instructors, please be aware this lab has been updated to use the **Oracle Cloud Shell** for all operations involving git, terraform and kubectl.  The full lab is now executed through the browser !



## Prerequisites ##

- To run these labs you will need access to an Oracle Cloud Account.  Your instructor will provide you a URL that allows to perform **Self Registration**, where you will be asked to provide a username and a password of your choosing.  **Please note down this username and password, you will need this info later in the labs!**
       

- **USING A PERSONAL TRIAL ACCOUNT ?** 

  In case you are using a personal Cloud Trial Account, you will need to prepare your Cloud Environment to be able to execute these labs.  See [instructions on this page](../AppDev/ATP-OKE/README.md) for all details.

  
  
- **Want to connect to the Autonomous Database first?**

  Most people attending this lab will already have experienced connecting to an ATP database and discovering it's features in the base Autonomous Database lab.  If this would not be the case for you, your instructor will advise you to execute these [initial ATP steps](initial_atp_steps.md).

  
  
- If you are a Lab Instructor, you need to perform some preparation the day before your workshop.  More info on [this page](instructors.md).

  

## Lab Instructions ##


This section will take you through the steps to set up a CI/CD environment for developing Microservices, based on the automation possible in Developer Cloud and deploying all components on Oracle's Managed Container platform.

- **Part 1:** [Setting up your Developer Cloud project](../AppDev/ATP-OKE/LabGuide250Devcs-proj.md)
- **Part 2:** [Create and populate the Database objects](../AppDev/ATP-OKE/LabGuide400DataLoadingIntoATP.md) in your ATP database with Developer Cloud

- **OPTIONAL**:   [Spin up a Managed Kubernetes environment with Terraform](../AppDev/ATP-OKE/LabGuide660OKE_Create.md) 

- **Part 3:** [Build a Container image with the aone application running on ATP](../AppDev/ATP-OKE/LabGuide650BuildDocker.md)
- **Part 4:** [Deploy your container on top of your Kubernetes Cluster](../AppDev/ATP-OKE/LabGuide670DeployDocker.md)

---

[Go to the Cloud Test Drive Overview](../readme.md)

