# WebLogic for OCI - non JRF



## Objective

This Hands on Lab will go through the process of creating a non JRF type of WebLogic for OCI Instance - using Oracle Cloud Marketplace - and through the steps of deploying a simple application.



## Step 1. Create WebLogic for OCI Stack

- After logging in, go to Hamburger Menu,  *Marketplace* -> *All Applications*:

<img src="images/wlscnonjrfwithenv/image040.1.png" style="zoom: 50%;" />



- You can choose to browser-search for *WebLogic Server*, or you can apply the filters:
  - **Type**: *Stack*
  - **Publisher**: *Oracle*
  - **Category**: *Application Development*

![](images/wlscnonjrfwithenv/image050.png)



- Choose *WebLogic Server Enterprise Edition UCM*; This brings you to the Stack Overview page:
  - Select the most recently dated version of the version **12.2.1.4**

![](images/wlscnonjrfwithenv/image060.png)



- Make sure *CTDOKE* compartment is selected and to accept *Oracle Terms of Use*:

![](images/wlscnonjrfwithenv/image070.png)



- Fill in Stack information:
  - **Name**: *WLSNN* - where **NN** is your unique suffix given by the instructor
  - **Description**: Any meaningful description, maybe type in your name/initials
- Click **Next**

![](images/wlscnonjrfwithenv/image090.png)



- Start to fill in details:

  - **Resource Name Prefix**: *WLSNN* - where **NN** your unique suffix
  
  - **WebLogic Server Shape**: *VM.Standard2.1*
  
  - **SSH Public Key**: copy and paste the content from the provided **weblogic_ssh_key.pub** file; it contains the public key in RSA format; be sure to include the whole content in one line, including *ssh-rsa* part at the beginning.
  
    - Note: if you have used the Cloud Shell to generate the weblogic ssh key, you can use the `cat` command to display its contents:
  
      ```
      cat weblogic_ssh_key.pub
      ```
  
      ![](images/wlscnonjrfwithenv/image105.png)
  
    - On Windows, use `Ctrl+INSERT` to copy the highlighted aria as in the above example.
  
    - On Mac, you can simply use `command+c`


![](images/wlscnonjrfwithenv/image100.png)





---


- Continue setting up:

  - **WebLogic Server Node count**: *2* (we will create a WebLogic cluster with two nodes / managed servers)
  
  - **Admin user name**: *weblogic*
  
  - **Secrets OCID for WebLogic Server Admin Password**: Enter the OCID of the Secret that was set up earlier for this.  If you if you are using the CTD (Cloud Test Drive) environment, this OCID might be in a document provided by your instructor.

      - A bit of context: the WebLogic Server Admin Password it's stored in an OCI Vault as an OCI Secret (encrypted with an OCI Encryption Key); during WebLogic Domain creation, the provisioning scripts will setup the admin password by getting it from the OCI Secret instead of having it as a Terraform variable; in a similar way - if talking about an JRF enabled domains - the database admin password will be referred from an OCI Secret
      
  - **JDK Version**: use the default: *jdk8*
  
      
  


![](images/wlscnonjrfwithenv/image110.png)



- Don't change WebLogic Server Advanced Configuration

- WebLogic Server Network parameters:

  - Choose *Create New VCN*

  - Choose the same *CTDOKE* Compartment

  - Give a name to the Virtual Cloud Network

    ![](images/wlsvcn1.png)

  - For the Subnet Strategy:

    - *Create New Subnet*
    - WebLogic Server Subnet CIDR: keep default
    - Bastion Host Subnet CIDR : keep default
  - Bastion Host Shape: keep default
  
  ![](images/wlsvcn2.1.png)
  
- Tick to **Provision Load Balancer**
  
  - Load Balancer Subnet : keep defaults
    - Minimum Bandwidth : keep default of 10
  - Maximum Bandwidth : set to *20*
    
  
  ![](images/wlsvcn3.1.png)





- Leave Identity Cloud Service Integration **unchecked** as default (no integration) 
- Leave **OCI Policies** checked, as a Dynamic Group containing the WebLogic Compute nodes will be created automatically alongside policies for letting them access the Secrets from Vault

![](images/wlscnonjrfwithenv/image153.png)


- Leave **Provision with JRF** unchecked, as we will not associate this WLS instance with a database
- Leave **Configure Application Datasource** also unchecked, as we will not use application datasources

![](images/wlscnonjrfwithenv/image155.png)


- Review the Stack configuration and click **Create**:

![](images/wlscnonjrfwithenv/image170.png)



- A Stack Job is being kicked off and our WebLogic Domain starts to be provisioned. Console context moves to Stack's details page (*Solutions and Platform* > *Resource Manager* > *Stacks*):

![](images/wlscnonjrfwithenv/image180.png)



- While all resources being created we can check the Job Logs; it helps fixing potentially configuration errors if the provisioning fails:

![](images/wlscnonjrfwithenv/image190.png)



The creation process will take approx. 15 minutes, during this time you can already set up your local machine to access the admin console through the bastion host: 


If you used Cloud Shell for creating the SSH private and public key pair, you'd need to copy it to local machine. In the Cloud Shell Console, go to `keys` folder and print the private key:

![](images/image-400.png)



Use `CTRL+Insert` to copy the entire output including the last line:

```
-----BEGIN RSA PRIVATE KEY-----
MIIJKAIBAAKCAgEA1/QqcR0Z6y/BKwloOSwIZKc3cneUtBdjmNz0AKmVDxN5cFHs
tibJXd32TDBo0DGhl1FsIlI9Zx2/EC0a4haYjef7Y3uHd3m5z4CEmNML53DSxq/A
2Y5gL0aGxl/b7nvRn5gKXuokBqSQ/uy562P/fZLdRMHPqPyIsNiKauESxtYegLVM
....

/rbekx4s3WF0C11lfCsYsQVfBrTLOSO890KqklC5f1ZQH99glF6sjiTbxdz+6ZJy
3hGzLs46srOx5NDA4EfIz4WfcddXMGBXwVwfJVmR7CGn+wVwAXVKr7/6V7HNFjDy
zcdaHbqFbR1gDVa5xZ1s+htPM2lW5UQDVvdpcALefZqmQgYAQV6jZNUDyeA=
-----END RSA PRIVATE KEY-----
```



Save the content on local machine, in a file with the same name, as in example **weblogic_ssh_key**.



Next, we need to change the private key file permissions.

On a linux / mac platform:

```
$ chmod 600 weblogic_ssh_key
```



On a Windows platform, open **Command Prompt** (cmd) and run below commands to make the file readable only by current user:

```
> icacls .\weblogic_ssh_key /inheritance:r
> icacls .\weblogic_ssh_key /grant:r "%username%":"(R)"
```



For both Windows commands you should get an output like:

```
processed file: .\weblogic_ssh_key
Successfully processed 1 files; Failed processing 0 files
```



For Windows we're taking this approach for using **Windows Power Shell** instead of Putty. If you enjoy more using Putty, you'd need to use PuttyGen to import the private key and save it in .ppk format.



Next, on your local computer, open an SSH tunnel to an unused port on the bastion compute instance as the `opc` user. For example, you can use port `1088` for SOCKS proxy. Specify the `-D` option to use dynamic port forwarding. 

The SSH command format is:

```
$ ssh -C -D <port_for_socks_proxy> -i <path_to_private_key> opc@<bastion_public_ip>
```



For example:

```
ssh -C -D 1088 -i weblogic_ssh_key opc@130.61.39.170
```



For Windows, use **Windows Power Shell** to run the SSH command.

![](images/image-410.png)



In another Bash Console (or Command Prompt for Windows) you can check that the tunnel port has been open on your computer:

```
$ netstat -tln | grep 1088
```



On Windows:

```
> netstat -a
```

(look for `TCP    127.0.0.1:1088` line)



Now all the local machine network traffic proxy-ed through 1088 port will be tunneled through the SSH connection to the bastion host.

Open **Firefox** browser, go to  *Options*, scroll down to *Network Settings* and configure a Proxy to access Internet. Setup a *Manual proxy configuration*, use *localhost* for **SOCKS Host** and *1088* port for **SOCKS Port**. Leave HTTP Proxy and FTP Proxy untouched:

![](images/image-420.png) 





- By now the Job should have completed with success:

![](images/wlscnonjrfwithenv/image200.png)



- We can check the *Outputs* section of Job Resources and see two important values:
  - **Sample Application URL** (we can can try it at this moment, but the out of the box sample application won't load as we need to finish the SSL configuration of the Load Balancer)
  - **WebLogic Server Administration Console**

![](images/wlscnonjrfwithenv/image210.1.png)



- Let's check the **WLS admin console** of the newly created WebLogic Server; as we have chosen a Public Subnet for the WLS network, both Compute instances that have been created have public IPs associated.  Use the Console URL provided in the **Outputs** section as shown above
- Login with **weblogic** username and the provided password:

![](images/wlscnonjrfwithenv/image220.png)



- We can see that our domain has one admin server and two managed servers:

![](images/wlscnonjrfwithenv/image230.png)



- We can check the Compute Instances to see what has been provisioned; From OCI menu choose *Core Infrastructure* -> *Compute* -> *Instances*:

![](images/wlscnonjrfwithenv/image240.png)



- We can see two instances having our prefix setup during Stack configuration; one of them runs the WebLogic Admin server and a Managed Server and the other runs the second Managed Server:

![](images/wlscnonjrfwithenv/image250.png)



- We can check now if the out of the box deployed application is loading; From the Stack Job **Outputs**, open the **Sample Application URL**; it's loading, but we have to bypass the browser warning as the Public Load Balancer is configured with a Self Signed Certificate;
- Click **Advanced** button and **Proceed to ...** to continue:



![](images/wlscnonjrfwithenv/image390.png)

- The out of the box deployed sample application is being served through a secured SSL Load Balancer Listener:

![](images/wlscnonjrfwithenv/image400.png)

- Congratulations! Your WLS domain is up&running! 



## Step 2. Deploy custom sample application

- Let's go back to the WebLogic Server admin console to deploy our sample web application:

![](images/wlscnonjrfwithenv/image410.png)



- Go to *Domain Structure* menu, *Deployments*; **Lock & Edit** to switch to edit mode; Click **Install**:

![](images/wlscnonjrfwithenv/image420.png)



- Follow **Upload your files** link and upload provided [SampleWebApp.war](resources/SampleWebApp.war) web archive file:

![](images/wlscnonjrfwithenv/image430.png)



- Click **Next**, **Next**, leave *Install de deployment as an application* default option; click **Next**:

![](images/wlscnonjrfwithenv/image440.png)



- Choose deploying the application on WebLogic Cluster; click **Next**:

![](images/wlscnonjrfwithenv/image450.png)



- Leave default settings and click **Next**:

![](images/wlscnonjrfwithenv/image460.png)



- Choose *No, I will review the configuration later* and click **Finish**

![](images/wlscnonjrfwithenv/image470.png)



- **Activate Changes**:

![](images/wlscnonjrfwithenv/image480.png)



- The application is now in *Prepared* state; switch to *Control* tab:

![](images/wlscnonjrfwithenv/image490.png)



- Select the *SampleWebApp* web application and click **Start** -> **Serving all requests**; Click **Next** in the following screen:

![](images/wlscnonjrfwithenv/image500.png)



- The *SampleWebApp* web application is in the *Active* State now:

![](images/wlscnonjrfwithenv/image510.png)



- Now, test this new application at *https://< public load balancer IP >/SampleWebApp/*

 ![](images/wlscnonjrfwithenv/image520.png)

- Click on the link to test this sample application:

![](images/wlscnonjrfwithenv/image530.png)



- This is just another sample application, but you can deploy any other application; Congratulations!



## Step 3. [Optional] Destroy resources

If you don't plan to use the WebLogic Domain anymore, to spare tenancy resources, the quickest way to delete the resources created during this lab is to run *Terraform Destroy*  on the Stack.

- Navigate to *Solutions and Platform* > *Resource Manager* > *Stacks*, identify and click on the Stack name you have created at the beginning of this lab.

- By running the *Destroy* Terraform Action, a Terraform job will kick off and delete all created resources.

![](images/wlscnonjrfwithenv/image600.png)



- When the job ends, you should see a similar log output:

![](images/wlscnonjrfwithenv/image610.png)



You can check that the Compute Instances and the Block Volumes have been terminated.

- At the end you can also delete the Stack:

![](images/wlscnonjrfwithenv/image620.png)
