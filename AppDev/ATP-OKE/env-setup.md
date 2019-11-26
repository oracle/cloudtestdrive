[Go to Overview Page](README.md)

![](../../common/images/customer.logo2.png)
# Microservices on ATP #
## Preparing your Oracle Cloud Tenancy for the lab ##

## Introduction ##

In case you are using a personal instance, either obtained via a free trial or using an existing paying account, you need to ensure the basic services for this lab are up and running, and ensure your user has the right entitlements to execute this lab successfully.

This page will guide you through the following activities :

- Part A : Set up your Cloud Infrastructure
  - Step 1: Create a compartment called CTDOKE which we will use in this lab
  - Step 2: Add a Policy statement for OKE
  - Step 3: Create an API user with a certificate
- Part B : Install some software on your local machine:
  - Step 4: Install git
  - Step 5: Install kubectl
  - Step 6 : Install terraform
- Part C : Set up Developer Cloud Service
  - Step 7 : Create an Instance
  - Step 8 : Configure the new DevCS instance



**ATTENTION** : if you are running this lab in a **Instructor-provided environment**, your Developer Cloud instance has already been created, **you can skip the steps on this page**.  A link to the instance will be provided by your instructor.



## Part A : Set up your Cloud Infrastructure



### **STEP 1: Create a Compartment**

- In the Cloud Infrastructure Console, click on the hamburger menu on the top left of the screen. From the pull-out menu, under Identity, click Compartments.

![](images/100/Compartments.jpeg)



- You will see the list of compartments currently available in your instance, which will include at least the root compartment of your tenancy (with has the tenancy name). 
  - ![](images/100/ListCompartmentsCTDOKE.png)
- Click on **Create Compartment** button to start the compartment creation process

![](images/100/CreateCompartment4.png)

Enter the following in create Compartment window

- **Name**: Enter **CTDOKE**
- **Description**: Enter a description for the compartment
- **Parent Compartment**:  select the root compartment.
- Click on the **Create Compartment** link 
- You can verify the compartment created on Compartments page



After you successfully created the compartment, note down the **Compartment OCID**, you will need it later in the lab :

![](images/100/comp_ocid.png)




### **STEP 2**: Add a Policy Statement for OKE

- If you are using an Instructor provided instance, this policy will already be defined.

- Before the Oracle managed Kubernetes service can create compute instances in your OCI tenancy, we must explicitly give it permission to do so using a policy statement. From the OCI Console navigation menu, choose **Identity->Policies**.

  ![img](images/devcs/LabGuide200-13c980fa.png)

- In the Compartment drop down menu on the left side, choose the **root compartment**. It will have the same name as your OCI tenancy (Cloud Account Name).

  ![img](images/devcs/LabGuide200-a321171a.png)

- Click **PSM-root-policy**

  ![img](images/devcs/LabGuide200-e67b7705.png)

- Click the **Add Policy Statement** button

  ![img](images/devcs/LabGuide200-3d4a7471.png)

- In the Statement box, enter: `allow service OKE to manage all-resources in tenancy` and click **Add Statement**

  ![img](images/devcs/LabGuide200-bd5bcbd1.png)



### STEP 3: Create an API user with a certificate

**ATTENTION** : if you are using an Instructor-provided instance, a user called **api.user** will already have been set up for you, and the keys, fingerprints and tokens of this user will be provided to you.

- Add an API (non-SSO) user with an API key:

  - Navigate to the "Identity" , "Users" screen and add a user called "api.user"

  - Add an API key: you need a private/public key pair, and you need to paste the public one into the key field. 

    - You can use the following [OpenSSL](http://www.openssl.org/) commands to generate the key pair in the required PEM format. If you're using Windows, you'll need to install [Git Bash for Windows](https://git-scm.com/download/win) and run the commands with that tool.

    - Open a console window and execute following commands
  
      - ```
        mkdir ./mykey
        openssl genrsa -out ./mykey/api_key.pem 2048
        openssl rsa -pubout -in ./mykey/api_key.pem -out ./mykey/api_key_public.pem
        ```

    - For more details on this key creation, see the [documentation](https://docs.cloud.oracle.com/iaas/Content/API/Concepts/apisigningkey.htm).

  - Copy the fingerprint of your API key in a temporary file

  - Copy the OCID of this new user in a temporary file
  
  ![alt text](images/devcs/OCI_user_details_new.png)


- Create an Auth Token for the user api.user

  - Take care to copy the Token string in a file on your PC : you will need it later, and you cannot retrieve it back from the console.

    ![img](images/660/Auth_token.png)

- Add the **api.user** to the administrator group


  - Navigate to the **Identity** and **Groups** menu

    ![img](images/660/Groups.png)


  - Open the group **Administrators**

  - Click the **Add User to Group** button, and select the **api.user**

    ![img](images/660/AddUser.png)

  - Click the **add** button to finalize the operation



## Part B: Install required software on your Laptop ##



### STEP 4: Installing git

In order to easily update and upload files into your Developer repository, we will clone the newly created DevCS repository onto your machine.  For this you need to install **git** on your laptop.   

- Download the software for your OS on [this location](https://git-scm.com/downloads) 
- In this tutorial we will use the command line to execute the required git operations, but if you have a git GUI installed (like GitHub Desktop or GitKraken) you can execute the equivalent operations through these tools.

### Step 5 : Installing kubectl

This page covers how to install the Kubernetes command line interface and connect to your Kubernetes cluster

Choose the section that corresponds to your machine:

##### MacOS

Download the latest release with the following `curl` command:

```
$ curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/darwin/amd64/kubectl
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100 49.9M  100 49.9M    0     0  4289k      0  0:00:11  0:00:11 --:--:-- 4150k
```

Make the kubectl binary executable.

```
$ chmod +x ./kubectl
```

Move the binary in to your PATH.

```
$ mv ./kubectl /usr/local/bin/kubectl
```

Verify the installation using the version command.

```
$ kubectl version
Client Version: version.Info{Major:"1", Minor:"8", GitVersion:"v1.8.4", GitCommit:"9befc2b8928a9426501d3bf62f72849d5cbcd5a3", GitTreeState:"clean", BuildDate:"2017-11-20T05:28:34Z", GoVersion:"go1.8.3", Compiler:"gc", Platform:"linux/amd64"}
The connection to the server localhost:8080 was refused - did you specify the right host or port?
```

At this step the server connection failure is normal. For easier usage it is recommended to setup the autocomplete for bash.

```
$ source <(kubectl completion bash)
```



##### Linux machines

For Linux, use the same sequence as described above for Linux, only replace the CURL command with the following:

```
$ curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100 49.9M  100 49.9M    0     0  4289k      0  0:00:11  0:00:11 --:--:-- 4150k
```

​	Note the difference: you are using /bin/linux/... instead of /bin/darwin/...
​

##### Windows

To find out the latest stable version take a look at [https://storage.googleapis.com/kubernetes-release/release/stable.txt](https://storage.googleapis.com/kubernetes-release/release/stable.txt)

For example if latest stable version is: **v1.8.4** then construct the download link in the following way: *https://storage.googleapis.com/kubernetes-release/release/VERSION_NUMBER/bin/windows/amd64/kubectl.exe*. Thus in case of **v1.8.4** the link looks like this:

[https://storage.googleapis.com/kubernetes-release/release/v1.8.4/bin/windows/amd64/kubectl.exe](https://storage.googleapis.com/kubernetes-release/release/v1.8.4/bin/windows/amd64/kubectl.exe)

Once you have the executable binary add to your PATH variable.

```
set PATH=%PATH%;c:\download_folder\kubectl.exe
```

Verify the installation using the version command.

```
C:\Users\pnagy>kubectl version
Client Version: version.Info{Major:"1", Minor:"7", GitVersion:"v1.7.0", GitCommit:"d3ada0119e776222f11ec7945e6d860061339aad", GitTreeState:"clean", BuildDate:"2
017-06-29T23:15:59Z", GoVersion:"go1.8.3", Compiler:"gc", Platform:"windows/amd64"}
Unable to connect to the server: dial tcp 192.168.99.100:8443: connectex: A connection attempt failed because the connected party did not properly respond after a period of time, or established connection failed because connected host has failed to respond.
```



### Step 6 : Installing terraform

Terraform is an open-source infrastructure as code software tool created by HashiCorp. It enables users to define and provision a datacenter infrastructure using a high-level configuration language known as Hashicorp Configuration Language

- Go to the [Hashicorp Terraform website](https://www.terraform.io/downloads.html) to download the software for your OS
- unzip the executable file in the directory of your choice
- Add the terraform command to your path
  - On Mac: export PATH=$PATH:`pwd`
  - On Windows: go to System Steetings, Advanced, Environment Variables, and add the path to your Terraform directory 






## Part C : Set up your Cloud Infrastructure



### Step 7 : Setting up Developer Cloud Service ###

This step will guide you through the setup of a new Developer Cloud instance :

- Go to DevCS on your Dashboard
- Creating a Developer Cloud instance
- Configuring the Storage and Build parameters for your DevCS instance



#### Go to DevCS on your dashboard ####

- Login to your cloud account and find DevCS service:

![alt text](images/devcs/dashboard_new.png)

- Open DevCS service



#### Create an instance ####

-  You should have no existing instances.  If you have, you can skip the following steps and just validate you have a build engine witht the correct libraries included.

![alt text](images/devcs/DevCS_create_instance_new.png)



- Use the "Create Instance" button to create a new Developer Cloud instance

![alt text](images/devcs/create_new.png)

Note: You should match the region selected with your home region.

![alt text](images/devcs/region_match_new.png)



- Hit the "Next" button and then "Create"

![alt text](images/devcs/confirm_new.png)



- Now the instance is being created.  This will take a few minutes, you can hit the small arrow to requery the status.

![alt text](images/devcs/creating_new.png)



#### Access your DevCS Environment ####

To access your Developer Cloud Instance, refresh the page and use the hamburger menu on the right to access the menu item **Access Service Instance**. 






### Step 8 : Configure DevCS Compute & Storage using OCI credentials

To configure DevCS to use the OCI Compute resources for its build engines, we need to manually provide the OCI credentials in the DevCSD setup menu.

**Attention !!** 

In the following section you will need to switch repeatedly between the DevCS console (on the left in the below screenshot, the "OCI Credentials" screen) and the OCI Cloud Interface where you need to collect a number of parameters of your instance (on the right in the below screenshot)

**Take a minute to set up 2 browser windows that allow easy switching between these 2 screens** to cut and paste parameters between them ! 

![alt text](images/devcs/dualscreen.png)





- In DevCS, on the left-side menu, select the top level **Organization** menu, then click on **OCI Account** in the top menu.  Next you can hit the **Connect** button.

![alt text](images/devcs/Connect_OCIaccount_new.png)

![alt text](images/devcs/Configure_OCIaccount_new.png)

- The OCI credentials can be found in your main cloud dasboard / Administration / Tenancy details

![alt text](images/devcs/OCI_Tenancy_details_new.png)

![alt text](images/devcs/OCI_tenancy_details_new_2.png)

- The user details can be found in your main cloud dasboard / Identity/ Users / click on api.user

![alt text](images/devcs/OCI_user_details_new.png)

- You should have noted the OCID of the **CTDOKE** Compartment earlier in this section just after the creation.



#### Create a Virtual Machine

- On the left-side menu, select the top level **Organization** menu, then click on **Virtual Machines Templates** in the top menu.  Next you can hit the **Create Template** button.

![alt text](images/devcs/NewTemplate2.png)


- In the dialog box, specify a name, for example **OKE2**  and use the default **Oracle Linux 7** image.  Then hit the **Create** button.

  ![alt text](images/devcs/im04-1.png)


- Now select the template you just created (OKE2), and add the required software packages by clicking on the **Configure Software** button.

![alt text](images/devcs/im05-3.png)

- Select the following packages:
  - Docker 17.2
  - Kubectl
  - OCIcli ==> this will prompt you to also install Python3
  - SQLcl 18

![alt text](images/devcs/im06-2.png)



- Finally, navigate to the **Build Virtual Machines** menu on the top menu, and hit the **+ Create VM** button.

  ![alt text](images/devcs/im07-2.png)

  
  
  In the dialog that pops up, enter following values:
  
  - Choose **Quantity = 1**
  
  - Select the **VM Template** you just created: **OKE2**
  
  - Set the **Region** to **eu-Frankfurt-1**
  
  - Select the compute **Shape** : **VM.Standard2.1**
  
    ![alt text](images/devcs/im08-2.png)

You finished all the steps of the Developer Cloud setup.  



---

[Go to Overview Page](README.md)

