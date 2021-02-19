# WebLogic for OKE - stack creation

### Creating the stack and provisioning the WebLogic Infrastructure



## Objective

This Hands on Lab will go through the process of creating a WebLogic for OKE on Oracle CIoud Infrastructure - using Oracle Cloud Marketplace.



## Step 1. Create WebLogic for OKE Stack

Login to your Oracle Cloud Infrastructure environment and from the main menu go to *Solutions and platform* -> *Marketplace* -> *Applications*:

![](images/wlsforocionoke/image-010.png)



You can search for *WebLogic* in the Marketplace search bar or narrow down displayed solutions by applying these filters:

- **Type:** *Stack*
- **Publisher**: *Oracle*
- **Category:** *Application Development*

Choose for *Oracle WebLogic Server Enterprise Edition for OKE UCM* (*Price*: *Paid*); This brings you to the Marketplace solution Overview page.

**Note**: if you're running this lab on an Oracle owned and managed environment, choose *Price: BYOL*

![](images/wlsforocionoke/image-020.png)



Choose your compartment where all WebLogic resources will be created, leave default WebLogic Version and accept *Oracle Terms of Use* before launching the Stack:

![](images/wlsforocionoke/image-030.png)



Launching the Stack will redirect you to Oracle Resource Manager (Oracle's managed Terraform service) where you need to configure some variables before the WebLogic Infrastructure gets provisioned.

Fill in Stack Information:

- **Name**: *WLSOKE* (add an unique suffix if other colleagues will be running this lab in the same Compartment)
- **Description**: *Oracle WebLogic Server Enterprise Edition for OKE UCM*

Click **Next** to go to the next screen.

![](images/wlsforocionoke/image-040.png)



Fill in information for **WebLogic Server on Container Cluster (OKE)**:

- **Resource Name Prefix**: *wlsoke* (use **lower case letters** and add an unique suffix if other colleagues will be running this lab on the same cloud environment)

- **SSH Public Key**: copy-and-paste the content of the generated **weblogic_ssh_key.pub** file; it contains the public key in RSA format; make sure to include the whole content in a single line, including *ssh-rsa* part at the beginning.

  - Note: if you have used the Cloud Shell to generate the SSH Key, you can use the `cat` command to display its contents:

    ```
    $ cat weblogic_ssh_key.pub
    ```

    ![](images/wlsforocionoke/image-060.png)

    

  - On Windows, use `Ctrl+INSERT` to copy the highlighted area as in the above example

  - On Mac, you can simply use `command+c`

- **Managed Server Count**: *2* (two managed WebLogic servers will be up&running as Kubernetes pods; this can be changed later)
- **Administrator name**: *weblogic*
- **Secrets OCID for Administration Password**: Enter the OCID of the WebLogic Admin Secret that was set up in the prerequisites lab
  
  - A bit of context: the WebLogic Server Admin Password it's stored in an OCI Vault as an OCI Secret (encrypted with an OCI Encryption Key); during WebLogic Domain creation, the provisioning scripts will setup the admin password by getting it from the OCI Secret instead of having it as a Terraform variable in plain-text mode

![](images/wlsforocionoke/image-050.png)



Scroll down and expand **WebLogic Server Advance Configuration**. Configure a name for the WebLogic Domain and leave default port as 7001:

- **WebLogic Domain Name**: wlsoke
- **WebLogic Server Admin Console Port**: *7001*

![](images/wlsforocionoke/image-070.png)



Next, in the **Container Cluster (OKE) Configuration** Section:

- **Kubernetes Version**: leave default
- **WebLogic Node Pool Shape**: leave default
- **Nodes in the Node Pool For WebLogic Pods**: *2* (this will allow the Kubernetes cluster to span over multiple Availability Domains)
- **Non-WebLogic Node Pool Shape**: leave default
- **Nodes in the Node Pool for Non-WebLogic Pods**: *2*
- **Pods CIDR**: leave default
- **Services CIDR**: leave default
- **Kubernetes Secret Encryption**: leave default (unchecked)

![](images/wlsforocionoke/image-080.png) 



For the **Container Cluster (OKE) Administration Instances**:

- **Availability Domain for Compute Instances**: choose one of the Availability Domains (in Single AD Regions you'll see only one option)
- **Administration Instance Compute Shape**: leave default
- **Bastion Instance Shape**: leave default

![](images/wlsforocionoke/image-090.png)



On **Network** configuration:

- **Network Compartment**: keep the same compartment selected when launching the Stack configuration
- **Virtual Cloud Network Strategy**: *Create New VCN* (easy way for quick execution of the lab; if you'd like to reuse an existing network, check the documentation and make sure you have in place all prerequisites from networking perspective)
- **WebLogic Server CIDR**: keep default value
- **Administration Console Load Balancer Shape**: *100Mbtps*
- **WebLogic Cluster Load Balancer Shape**: *100Mbps*

![](images/wlsforocionoke/image-100.png)



Scroll down and leave **Provision with JRF** unchecked to skip database configuration. We'll provision a Non-JRF WebLogic Domain.

For the **File System** choose one of the Availability Domain. A File System and a Mount Target will be created in that particular AD. From Service Limits perspective, choose one that allows creation of new Shared File System resources.

![](images/wlsforocionoke/image-110.png)



Last part of the Stack configuration is addressing connectivity to OCI Registry for storing WebLogic Domain docker images. For the **Registry User Name** put the user name, in full format. For example, if using your current user, you can get full user name by checking how it appears if you click on the upper-right profile icon:

![](images/wlsforocionoke/image-120.png)



For the **Secrets OCID For Registry Authentication Token** use the OCID of the WLS Registry Secret created in the prerequisites lab:

![](images/wlsforocionoke/image-130.png)



Finally, leave **OCI Policies** option checked and the provisioning scripts will create required policies for reading Secrets from the Vault:

![](images/wlsforocionoke/image-135.png)



Click **Next** to review Stack Configuration and click **Create** to start executing the Stack:

![](images/wlsforocionoke/image-140.png)



An **Apply** Terraform Job Type has started running and all infrastructure is being provisioned:

![](images/wlsforocionoke/image-150.png)



After a while (~20mins) the Job status turns into **Succeeded**:

![](images/wlsforocionoke/image-160.png)



## Step 2. Check what resources have been provisioned

To better understand all components of a WebLogic for OKE on OCI solution keep as a reference this architecture diagram:

![](images/wlsforocionoke/image-200.png)



Before navigating away of the Job Information page, let's take note of some relevant details that we'll be using later. Switch from the *Logs* to the *Outputs* submenu item and check the **Outputs** table:

![](images/wlsforocionoke/image-210.png)



Some items need our attention:

- **admin_instance_private_ip**: this displays the private IP address of the *Admin Host* Compute Instance in the reference architecture; we need to know this IP address to connect from the *Bastion* instance to *Admin Host* Instance
- **bastion_instance_public_ip**: public IP address of the *Bastion* Compute Instance in the reference architecture; the Bastion VM acts as jump server and let us connect from Internet to the WebLogic Infrastructure
- **fss_path**: mount path of the shared file system between *Admin Host*, WebLogic managed servers and Jenkins Continuous Integration system; by connecting to the *Admin Host* you can change/add new scripts to be used in existing or new Jenkins Pipelines
- **jenkins_console_url**: remember that `/jenkins` is the Jenkins application context root
- **weblogic_console_url**: remember that `/console` is the WebLogic Administration Console context root
- **oke_cluster_name**: the name of the OKE Cluster running 



To easily get the two Load Balancers IPs, go back to the Job *Logs*, and scroll down to the end:

![](images/wlsforocionoke/image-220.png)



With yellow (at the top of the above image), we have the full URLs for:

- WebLogic Admin Console (**weblogic_console_url**)
- Jenkins Console (**jenkins_console_url**)
- WebLogic Applications deployed on WebLogic domain (**weblogic_cluster_lb_url**)

As we can see, the WebLogic Admin Console and the Jenkins Console have the same IP (hostname): this is the IP of the Private Load Balancer as in the Reference Architecture. This Load Balancer balances the traffic across Kubernetes Nodes and subsequently, on each node, an Ingress Controller forwards the traffic to right Pod running respective application (WebLogic Admin Server or Jenkins Master).

The IP address of the WebLogic Cluster LB URL represents the Public IP address of the Public Load Balancer from the Reference Architecture. This Load Balancer allows incoming Internet traffic to be send to deployed applications running on WebLogic Managed Server Pods.



We can have a quick look of all OCI resources that have been created.

If we navigate to *Core Infrastructure* -> *Compute* -> *Instances* we can see six new Compute Instance running: one for *Admin Host*, one for *Bastion* host and four belonging to the OKE cluster (two for each Node Pools, the *Non-WebLogic Node Pool* and the *WebLogic Node Pool*). Note that only the Bastion host has a Public IP address:

![](images/wlsforocionoke/image-230.png)



If we go *Core Infrastructure* -> *File Storage* -> *File Systems* we can see the File System that it's being shared among some of the created components:

![](images/wlsforocionoke/image-240.png)



And the associated Mount Target that actually exports the File System through the internal network:

![](images/wlsforocionoke/image-250.png)



In the  *Core Infrastructure* -> *Networking* -> *Virtual Cloud Networks*  we'll see the new VCN in which all components are running:

![](images/wlsforocionoke/image-260.png)



Switching to *Load Balancers* we see the two Load Balancers up & running and their respective IP Addresses:

![](images/wlsforocionoke/image-270.png)



Going to *Solutions and Platform* -> *Developer Services* -> *Kubernetes Clusters* we can see the WebLogic Kubernetes Cluster:

![](images/wlsforocionoke/image-280.png)



Let's click on it and check the information to **Access the Cluster**:

![](images/wlsforocionoke/image-290.png)



Launch the Cloud Shell, copy the command listed at step 2) and run it in the Cloud Shell Console:

![](images/wlsforocionoke/image-300.png)



Run:

```
$ kubectl get nodes
```



It will display Kubernetes nodes corresponding to both Node Pools (the four Compute Instances we have seen above):

![](images/wlsforocionoke/image-310.png)



Run now:

```
$ kubectl get pods --all-namespaces
```



It will display all running Pods across all namespaces:

![](images/wlsforocionoke/image-320.png)



At the end of the list we identity a Pod running WLS Admin Server, two Pods running Managed Servers and one Pod running WebLogic Operator.



Lastly, by going to *Solutions and Platform* -> *Developer Services* -> *Container Registry* we can check for the repositories created once the WebLogic for OKE has been provisioned:

![image-20201103180909347](images/wlsforocionoke/image-330.png)



We can see:

- infra/cisystem-jenkins-controller - Jenkins Controller Image
- infra/cisystem-jenkins-agent - Jenkins Agent Image
- infra/nginx-ingress-controller - Nginx Ingress Controller Image
- infra/oraclelinux - Oracle Base Linux Image
- infra/weblogic-kubernetes-operator - WebLogic Operator Image
- /wlsoke02/wls-domain-base/12214 - WebLogic domain Base Image
- /wlsoke02/wls-domain-base - WebLogic domain Image (this one will get versioned each time the WebLogic domain is updating, for example for deploying or undeploying applications)



## Step 3. Access WebLogic Admin and Jenkins Consoles

To access the WebLogic Admin Console and the Jenkins Console we need first  to connect to the Bastion Host and create a SSH tunnel at the same time. We cannot use the Cloud Shell for this part.



If you used Cloud Shell for creating the SSH private and public key pair, you'd need to copy it to local machine. In the Cloud Shell Console, go to `keys` folder and print the private key:

![](images/wlsforocionoke/image-400.png)



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

![](images/wlsforocionoke/image-410.png)



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

![](images/wlsforocionoke/image-420.png) 



Once done that, open a new browser tab and navigate to WebLogic Admin Console:

```
http://<private load balancer ip>/console
```



You find the full URL in the Terraform Apply Job Logs Output as showed above. Login with `weblogic` and the password setup for the WebLogic Admin Secret in the prerequisites lab:

![](images/wlsforocionoke/image-430.png)



Navigate to *Environments* > *Servers* to check for the running Managed Servers. As we have 2 Pods running Managed WebLogic Servers, only two of them are listed in `RUNNING` State.

![](images/wlsforocionoke/image-440.png)



In another browser tab, open the Jenkins console:

```
http://<private load balancer ip>/jenkins
```



You find the full URL in the Terraform Apply Job Logs Output as showed above. On the first access, you need to create a Jenkins Admin User. Fill in the form and setup an username and password (make sure not to forget the credentials):

![](images/wlsforocionoke/image-450.png)



Once done that, a Success message appears. Click on the *Go back to the top page* link:

![](images/wlsforocionoke/image-460.png)



This leads us to the Jenkins Dashboard page displaying several pre-configured Pipelines that will help us manage the WebLogic for OKE. 

Don't forget that with WebLogic running on top of Kubernetes, any change to the running WebLogic Domain (like domain configuration, deploying/un-deploying applications or managing Managed Servers) it's not recommended and it's not a best practice. Everything has to be done through the CI/CD flows that will update the WebLogic Domain model, push the WebLogic Image to OCI Registry and then re-create the Kubernetes Pods.

![](images/wlsforocionoke/image-470.png)



## Step 4. Access Admin host

There are cases when we would need to access the Admin host, for example to change the existing Jenkins Pipelines script files, add new ones to the shared file system or, as we'll see in the last lab of the workshop, to clean up some resources before tearing town the WebLogic for OKE Infrastructure.

Accessing the Admin host can be done:

- using Cloud Shell - easier if you have generated the WebLogic SSH keys on the Cloud Shell environment; if not, you'd need to copy the private key in advance
- using local ssh client

Either option, an easy way to connect directly to Admin host by jumping though the Bastion host is to use ssh `ProxyCommand` feature. The ssh command should look like this:

```
ssh -i <path_to_private_key> -o ProxyCommand="ssh -W %h:%p -i <path_to_private_key> opc@<bastion_public_ip>" opc@<admin_host_private_ip>
```



Example on Cloud Shell:

![image-20201103162837302](images/wlsforocionoke/image-500.png)



Example on Window PowerShell:

![image-20201103163051480](images/wlsforocionoke/image-510.png)

**Note:** on Windows, you'd need to provide the full `shh.exe` path in the `ProxyCommand` string.



Once logged in, you can inspect `/u01/shared` shared folder, for example checking the Jenkins Pipelines script files:

![image-20201103163708746](images/wlsforocionoke/image-520.png)



In the next Hands on Lab, we'll test some of the pre-build Jenkins Pipelines.