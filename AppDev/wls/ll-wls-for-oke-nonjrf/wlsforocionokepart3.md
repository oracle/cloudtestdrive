# WebLogic for OKE - WLS Domain Creation

### Creating the WebLogic domain through the Jenkins console



## Objective

This chapter will go through the process of creating a WebLogic domain using the Jenkins pipelines that were provisioned with the Kubernetes infrastructure



## Step 1. Setup access to the environment

To access the Jenkins Console and the Admin server we need first  to connect to the Bastion Host and create a SSH tunnel at the same time. 

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



## Step 1b. Apply a patch for Trial Environments

**This step only applies when running in a Free Trial account**

When running on a normal, Free trial Cloud environment, you will only have a single loadbalancer of the type *Flexible Shape* at your discposal.  But the creation wizard of the WebLogic Domain will assume you have a second one available ... so we need to apply a small patch to switch your public domain loadbalancer to the type *Fixed Shape 100 MB*,of which you have 3 available in your trial.

To do this, we will be accessing the Admin host.  This can be done :

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



Lets now **apply the patch**:

- download the patch script by executing the below command :

  ```
  wget https://objectstorage.us-ashburn-1.oraclecloud.com/n/ocloud200/b/tutorial/o/apply_fixed_lb_100mb_no_limits_check.sh
  ```

- Make the script executable : 

  ```
  chmod +x apply_fixed_lb_100mb_no_limits_check.sh
  ```

- Execute the script :

  ```
  ./apply_fixed_lb_100mb_no_limits_check.sh
  ```

Do you want to understand what the patch has done ?

- We canceled a pre-check that validated the availability of the Flexible Loadbalancers in the pipeline script `/u01/shared/scripts/pipeline/create_domain/scripts/precheck_utils.py`
  The function `check_lb_quota` now always returns 0, indicating a successful check
- We changed the template of the loadbalancer to use a different type of loadbalancer : in the file `/u01/shared/scripts/pipeline/create_domain/ingress-controller/templates/_nginx-load-balancer.tpl` we replaced the definition of the loadbalancer type from `flexible` to `100Mbps` 





## Step 2. Connecting to the Jenkins console 



Open **Firefox** browser, go to  *Options*, scroll down to *Network Settings* and configure a Proxy to access Internet. Setup a *Manual proxy configuration*, use *localhost* for **SOCKS Host** and *1088* port for **SOCKS Port**. Leave HTTP Proxy and FTP Proxy untouched:

![](images/wlsforocionoke/image-420.png) 



Once done that, open a new browser tab and navigate to the Jenkins console:

```
http://<private load balancer ip>/jenkins
```



You find the full URL in the Terraform Apply Job Logs Output as showed above. On the first access, you need to create a Jenkins Admin User. Fill in the form and setup an username and password (make sure not to forget the credentials):

![](images/wlsforocionoke/image-450.png)



Once done that, a Success message appears. Click on the *Go back to the top page* link:

![](images/wlsforocionoke/image-460.png)



This leads us to the Jenkins Dashboard page displaying several pre-configured Pipelines that will help us manage the WebLogic for OKE. 

Don't forget that with WebLogic running on top of Kubernetes, any change to the running WebLogic Domain (like domain configuration, deploying/un-deploying applications or managing Managed Servers) it's not recommended and it's not a best practice. Everything has to be done through the CI/CD flows that will update the WebLogic Domain model, push the WebLogic Image to OCI Registry and then re-create the Kubernetes Pods.

![](images/wlsforocionoke/image-470-2.png)



To start a WLS Domain we'll be using the **Create_domain** pipeline.  Start the pipeline by clicking the small arrow on the right of the pipeline name to see th drop-down menu, and select **Build with Parameters**

 ![](images/wlsforocionoke/image-471-2.png)

You now see the various parameters you can enter for the domain creation : 

Fill in information for **WebLogic Server on Container Cluster** section:

- **Domain_Name**: *wlsoke* (use **lower case letters** and add an unique suffix if other colleagues will be running this lab on the same cloud environment)

- **Base_Image**: select the single default image in the dropdown

- **Administrator name**: *weblogic*

- **Managed_Server_Count**: *2* (two managed WebLogic servers will be up&running as Kubernetes pods; this can be changed later)

- **SSH Public Key**: copy-and-paste the content of the generated **weblogic_ssh_key.pub** file; it contains the public key in RSA format; make sure to include the whole content in a single line, including *ssh-rsa* part at the beginning.

  - Note: if you have used the Cloud Shell to generate the SSH Key, you can use the `cat` command to display its contents:

    ```
    $ cat weblogic_ssh_key.pub
    ```

    ![](images/wlsforocionoke/image-060.png)

    

  - On Windows, use `Ctrl+INSERT` to copy the highlighted area as in the above example

  - On Mac, you can simply use `command+c`

- Keep the **Patch_Automatically** parameter unchecked.

![](images/wlsforocionoke/image-472.png)

For the **Registry (OCIR)** section:

- **Registry_Username** : leave this field blank, the script will use the value you already provided during stack creation
- **Registry_Authentication_Token** : leave this field blank, the script will use the value you already provided during stack creation

![](images/wlsforocionoke/image-491.png)



Fill in information for **Container Cluster (OKE) Configuration** section:

- **WebLogic_Node_Pool_Type** : select the **Create_Node_Pool** option
- **Node_Count** : fill in **2**
- **WebLogic_Node_Pool_Shape** : leave the default
- **SSH_Public_Key** : leave blank, the same key provided in the stack creation will be used
- **NodePool_Subnet_ID** : leave blank
- **Existing_Node_Pool** : leave blank

![](images/wlsforocionoke/image-492.png)



Fill in information for **Load balancer Configuration** section:

- **External_Lb_Shape_Min** : leave the default - **10**
- **External_Lb_Shape_Max** : fill in **20**
- **Private_Load_Balancer** : leave the default - unchecked
- **Reserved_Public_IP** : leave blank

![](images/wlsforocionoke/image-493.png)



Leave the sections **Provision with JRF** and **Identity Cloud Service (IDCS) Integration** unchanged, in this lab we will not use these options.



You are now ready to hit the **Build**button at the bottom.  The pipline will start executing and after some time you will see the progression through the various steps.  When the run is finished (successfully), the result should look like this : 

![](images/wlsforocionoke/image-494.png)

While the provisioning is proceeding, you can continue to the next step, and see the various resources you are in the process of creating.



## Step 3. Check what resources have been provisioned

To better understand all components of a WebLogic for OKE on OCI solution keep as a reference this architecture diagram:

![](images/wlsforocionoke/image-200.png)



We can have a quick look of all OCI resources that have been created.

If we navigate to *Compute* -> *Instances* we can see six new Compute Instance running: one for *Admin Host*, one for *Bastion* host and four belonging to the OKE cluster (two for each Node Pools, the *Non-WebLogic Node Pool* and the *WebLogic Node Pool*). Note that only the Bastion host has a Public IP address:

![](images/wlsforocionoke/image-230.png)



If we go *Storage* -> *File Storage* -> *File Systems* we can see the File System that it's being shared among some of the created components:

![](images/wlsforocionoke/image-240.png)



And the associated Mount Target that actually exports the File System through the internal network:

![](images/wlsforocionoke/image-250.png)



In the  *Networking* -> *Virtual Cloud Networks*  we'll see the new VCN in which all components are running:

![](images/wlsforocionoke/image-260.png)



Switching to *Load Balancers* we see the two Load Balancers up & running and their respective IP Addresses:

![](images/wlsforocionoke/image-270.png)



Going to *Developer Services* -> *Container* -> *Kubernetes Clusters* we can see the WebLogic Kubernetes Cluster:

![](images/wlsforocionoke/image-280.png)



Lastly, by going to *Developer Services* -> *Containers* -> *Container Registry* we can check for the repositories created once the WebLogic for OKE has been provisioned:

![image-20201103180909347](images/wlsforocionoke/image-330.png)



We can see:

- infra/cisystem-jenkins-controller - Jenkins Controller Image
- infra/cisystem-jenkins-agent - Jenkins Agent Image
- infra/nginx-ingress-controller - Nginx Ingress Controller Image
- infra/oraclelinux - Oracle Base Linux Image
- infra/weblogic-kubernetes-operator - WebLogic Operator Image
- /wlsoke02/wls-domain-base/12214 - WebLogic domain Base Image
- /wlsoke02/wls-domain-base - WebLogic domain Image (this one will get versioned each time the WebLogic domain is updating, for example for deploying or undeploying applications)



## Step 4. Access WebLogic Admin Console

To access the WebLogic Admin Console we also need to use the tunnel we set up previously.  

- Use the Firefox browser used for accessing the Jenkins console and open a 2nd tab
- Browse to the WebLogic Console URL : the URL format is: `http://<jenkins_lb_IP>/<domainname>/console`

1. For example: `http://10.0.2.3/wlsoke/console`

2. The WebLogic Server Administration Console login page is displayed.

![](images/wlsforocionoke/image-430.png)



Navigate to *Environments* > *Servers* to check for the running Managed Servers. As we have 2 Pods running Managed WebLogic Servers, only two of them are listed in `RUNNING` State.

![](images/wlsforocionoke/image-440.png)





You can now navigate to the next chapter of this lab called **Deploying a Sample application**

