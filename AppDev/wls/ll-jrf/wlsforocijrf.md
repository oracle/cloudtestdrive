# WebLogic for OCI (JRF)



## Objective

This Hands on Lab will go through the process of creating a JRF type of WebLogic for OCI Instance - using Oracle Cloud Marketplace - and through the steps of deploying some sample ADF applications.



## 1. Create WebLogic for OCI Stack

- After logging in, go to Hamburger Menu, *Solutions and Platform -> Marketplace -> All Application*:

<img src="images/wlscnonjrfwithenv/image040.png" style="zoom:33%;" />



- You can choose to browser-search for *WebLogic Server*, or you can apply the filters:
  - **Type**: *Stack*
  - **Publisher**: *Oracle*
  - **Category**: *Application Development*

![](images/wlscnonjrfwithenv/image050.png)



- Choose *WebLogic Server Enterprise Edition UCM*; This brings you to the Stack Overview page:

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

  - **Secrets OCID for WebLogic Server Admin Password**: Enter the OCID of the <u>WebLogic Admin Secret</u> that was set up earlier for this.  If you if you are using the CTD (Cloud Test Drive) environment, this OCID might be in a document provided by your instructor.

    - A bit of context: the WebLogic Server Admin Password it's stored in an OCI Vault as an OCI Secret (encrypted with an OCI Encryption Key); during WebLogic Domain creation, the provisioning scripts will setup the admin password by getting it from the OCI Secret instead of having it as a Terraform variable; in a similar way - for JRF enabled domains - the database admin password will be referred from an OCI Secret

    



![](images/wlscnonjrfwithenv/image110.png)



- Don't change WebLogic Server Advanced Configuration

- WebLogic Server Network parameters:

  - Choose *Create New VCN*

  - Choose the same *CTDOKE* Compartment

  - Give a name to the Virtual Cloud Network

    ![](images/wlsvcn1.png)

  - For the Subnet Strategy:

    - *Create New Subnet*
    - Leave other parameters as default
  
  ![](images/wlsvcn2.png)
  
  
  
  - Tick to **Provision Load Balancer**
  
    - **Load Balancer Minimum and Maximum Bandwidth**: 
    - Set the **Maximum Bandwith = 20**
    
    ![](images/wlsvcn3-1.png)



- Leave Identity Cloud Service Integration **unchecked** as default (no integration) 

  ![](images/wlsvcn5.png)

  

- For the **OCI Policies** checkbox you need to choose the correct option, depending on the type of tenancy you are using and the rights you have been given:

  - If you are using a *Free Tier* tenancy you will be the administrator, and have all required rights.  In this case *leave this option CHECKED*, a Dynamic Group containing the WebLogic Compute nodes will be created automatically alongside policies for letting them read Secrets from OCI Vault.

    ![](images/wlsvcn6.png)

  - If you are using your *corporate tenancy* and your administrator has set up the required privileges in a specific compartment, *UNCHECK this option* because you don't have the rights to make these types of groups and policies yourself.

    ![](images/wlsvcn7.png)




- Check **Provision with JRF**. In the *Database* section choose:

  - **Database Strategy**: *Autonomous Transaction Processing Database*
  - **Autonomous DB System Compartment**: *CTDOKE* (or the compartment name where the ATP database was provisioned)
  - **Autonomous Database** name: *WLSATPBDB*
  - **Secrets OCID for Autonomous Database Admin Password**: Enter the OCID of the <u>DB Admin Secret</u> that was set up earlier for this.  If you if you are using the CTD (Cloud Test Drive) environment, this OCID might be in a document provided by your instructor
  - **Autonomous Database Service level**: *low* (default option)

![](images/wlscnonjrfwithenv/image160.png)




- Check **Configure Application Datasource**. We have a quick option to pre-configure the WebLogic Domain with a ready to use Application Datasource.

![](images/wlscnonjrfwithenv/image162.png)



- Set:
  - **Application Database Strategy**: *Autonomous Transaction Processing Database*
  - **Compartment**: *CTDOKE* (or the compartment name where the ATP database was provisioned)
  - **Autonomous Database** name: *WLSATPBDB*
  - **Autonomous Application Database User Name**: *ADFAPP*
  - **Secrets OCID for Autonomous Application Database User Password**: Enter the OCID of the <u>Sample Application Schema Secret</u> that was set up earlier for this.  If you if you are using the CTD (Cloud Test Drive) environment, this OCID might be in a document provided by your instructor
  - **Autonomous Database Service level**: *tp*

![8](images/wlscnonjrfwithenv/image164.png)




- Review the Stack configuration and click **Create**:

![](images/wlscnonjrfwithenv/image170.png)



- A Stack Job is being kicked off and our WebLogic Domain starts to be provisioned. Console context moves to Stack's details page (*Solutions and Platform* > *Resource Manager* > *Stacks*):

![](images/wlscnonjrfwithenv/image180.png)



- While all resources being created we can check the Job Logs; it helps fixing potentially configuration errors if the provisioning fails:

![](images/wlscnonjrfwithenv/image190.png)



- After approx. 15 minutes, the Job should complete with success:

![](images/wlscnonjrfwithenv/image200.png)



- We can check the *Outputs* section of Job Resources and see two important values:
  - **Sample Application URL** (we can can try it at this moment, but the out of the box sample application won't load as we need to finish the SSL configuration of the Load Balancer)
  - **WebLogic Server Administration Console**

![](images/image210.png)



### Access the WebLogic Admin Console

To access the WebLogic Admin Console we need first to connect to the Bastion Host and create a SSH tunnel from your PC to the Bastion.

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



Once done that, open a new browser tab and navigate to WebLogic Admin Console:

```
http://<private load balancer ip>/console
```



You find the full URL in the Terraform Apply Job Logs Output as showed above. Login with `weblogic` and the password setup for the WebLogic Admin Secret in the prerequisites lab:



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

![](images/wlscnonjrfwithenv/image395.png)

- Congratulations! Your WLS domain is up&running! 



## 2. Change Load Balancer Cookie persistence type

Before deploying the sample ADF Application, we need to change the way Session Persistence is handled by the Public Load Balancer. By default, the Public Load Balancer comes pre-configured to use *Load Balancer cooking persistence*. But in our case - or in any ADF application case actually - as the sample ADF application generates its own cookie (**JSESSIONID**), we need to instruct the Load Balancer to use *Application cookie persistence*.



- In the OCI Console navigate to *Core Infrastructure* -> *Networking* -> *Load Balancers*:

![](images/wlscnonjrfwithenv/image800.png)



- Identify the Load Balancer created by the WebLogic Stack and click on it (contains the Stack resource name prefix setup during WebLogic Stack configuration):

![](images/wlscnonjrfwithenv/image810.png) 



- In the *Resources* section, click on **Backend Sets**; click on the backend set:

![](images/wlscnonjrfwithenv/image820.png)



- Click on **Edit**:

![](images/wlscnonjrfwithenv/image830.png)



- We see that, by default, the Backend Set has Session Persistence enabled using load balancer cookie persistence:

![](images/wlscnonjrfwithenv/image840.png)



- Change to *Enable application cookie persistence*; Set **Cookie Name** to *JSESSIONID*; Click on **Update Backend Set**:

![](images/wlscnonjrfwithenv/image850.png)



- A Work Request has been created and shortly the Backend Set configuration shall be updated:

![](images/wlscnonjrfwithenv/image860.png)



## 3. Deploy sample ADF application

- Let's go back to the WebLogic Server admin console:

![](images/wlscnonjrfwithenv/image400.png)



- Before we deploy the ADF application, let's have a look at the Application Data Source that has been created with WebLogic Server; From *Domain Structure* go to *Services* -> *Data Sources*:

![](images/wlscnonjrfwithenv/image401.png)



- The Data Source it's named **APPDBDataSource**. We need to change the *JNDI Name* as our sample ADF application requires **jdbc/adfappds** to lookup for data source and get database connections. Click on the data source:

![](images/wlscnonjrfwithenv/image402.png)



- To change the *JNDI Name* we need to *Lock* the WebLogic Console Session. Click on **Lock & Edit** in the upper left corner:

![](images/wlscnonjrfwithenv/image403.png)



- Change *JNDI Name* to  **jdbc/adfappds** and click **Save**:

![](images/wlscnonjrfwithenv/image404.png)



- Click on **Activate Changes** to save and close the WebLogic Console Editing Session:

![](images/wlscnonjrfwithenv/image405.png)



- The change has been recorded, but we need also to restart the Datasource. Click on *View changes and restarts* (upper left corner):

![](images/wlscnonjrfwithenv/image406.png)



- Switch to *Restart Checklist*:

![](images/wlscnonjrfwithenv/image407.png)



- Select the **AppDBDataSource** and click on **Restart**:

![](images/wlscnonjrfwithenv/image408.png)



- Click **Yes**:

![](images/wlscnonjrfwithenv/image409.png)



- The Datasource will be restarted shortly:

![](images/wlscnonjrfwithenv/image410.png)



- Now, to deploy the ADF application, go to *Domain Structure* menu, *Deployments*; **Lock & Edit** to switch to edit mode; Click **Install**:

![](images/wlscnonjrfwithenv/image420.png)



- Follow **Upload your files** link and upload provided [SampleADFApplication.ear](https://objectstorage.eu-frankfurt-1.oraclecloud.com/n/oractdemeabdmnative/b/ll-wls-bucket/o/SampleADFApplication.ear) enterprise archive file:

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



- Select the *SampleADFApplication* enterprise application and click **Start** -> **Serving all requests**; Click **Yes** in the following screen:

![](images/wlscnonjrfwithenv/image500.png)



- The *SampleADFApplication* application is in the *Active* State now:

![](images/wlscnonjrfwithenv/image510.png)



- Now, test this application at *https://< public load balancer IP >/sampleADFApplication/*

![](images/wlscnonjrfwithenv/image520.png)



- As we can see, calendar entries are coming from the ATP database. Play with the ADF Calendar Component, for example switch to *List view*:

![](images/wlscnonjrfwithenv/image530.png)



- This is just a sample ADF application, but you can deploy any other applications; Congratulations!


