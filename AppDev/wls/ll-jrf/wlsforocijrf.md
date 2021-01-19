# WebLogic for OCI (JRF)



## Objective

This Hands on Lab will go through the process of creating a JRF type of WebLogic for OCI Instance - using Oracle Cloud Marketplace - and through the steps of deploying some sample ADF applications.



## Step 1. Create WebLogic for OCI Stack

- After logging in, go to Hamburger Menu, *Solutions and Platform* -> *Marketplace*:

![](images/wlscnonjrfwithenv/image040.png)



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
    - *Use Public Subnet*
    - *Regional Subnet*

    ![](images/wlsvcn2.png)

  - Tick to **Enable Access to Administration Console**:
  
    ![image-20210119080943656](images/wlsvcn4.png)
  
  - Tick to **Provision Load Balancer**
  
    - **Load Balancer Shape**: *100Mbps*
  
    ![](images/wlsvcn3.png)



- Leave Identity Cloud Service Integration **unchecked** as default (no integration) 
- Leave **OCI Policies** checked, as a Dynamic Group containing the WebLogic Compute nodes will be created automatically alongside policies for letting them read Secrets from OCI Vault

![](images/wlscnonjrfwithenv/image153.png)


- Check **Provision with JRF**. In the *Database* section choose:

  - **Database Strategy**: *Autonomous Transaction Processing Database*
  - **Autonomous DB System Compartment**: *CTDOKE* (or the compartment name where the ATP database was provisioned)
  - **Autonomous Database** name: *WLSATPBDB*
  - **Secrets OCID for Autonomous Database Admin Password**: Enter the OCID of the <u>DB Admin Secret</u> that was set up earlier for this.  If you if you are using the CTD (Cloud Test Drive) environment, this OCID might be in a document provided by your instructor
  - **Autonomous Database Service level**: *low* (default option)

![image-20210117160118326](images/wlscnonjrfwithenv/image160.png)




- Check **Configure Application Datasource**. We have a quick option to pre-configure the WebLogic Domain with a ready to use Application Datasource.

![image-20210117161400912](images/wlscnonjrfwithenv/image162.png)



- Set:
  - **Application Database Strategy**: *Autonomous Transaction Processing Database*
  - **Compartment**: *CTDOKE* (or the compartment name where the ATP database was provisioned)
  - **Autonomous Database** name: *WLSATPBDB*
  - **Secrets OCID for Autonomous Application Database User Password**: Enter the OCID of the <u>Sample Application Schema Secret</u> that was set up earlier for this.  If you if you are using the CTD (Cloud Test Drive) environment, this OCID might be in a document provided by your instructor
  - **Autonomous Database Service level**: *tp*

![image-20210117161450978](images/wlscnonjrfwithenv/image164.png)




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

![](images/wlscnonjrfwithenv/image210.png)



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

![](images/wlscnonjrfwithenv/image395.png)

- Congratulations! Your WLS domain is up&running! 



## Step 2. Change Load Balancer Cookie persistence type

Before deploying the sample ADF Application, we need to change the way Session Persistence is handled by the Public Load Balancer. By default, the Public Load Balancer comes pre-configured to use *Load Balancer cooking persistence*. But in our case - or in any ADF application case actually - as the sample ADF application generates its own cookie (**JSESSIONID**), we need to instruct the Load Balancer to use *Application cookie persistence*.



- In the OCI Console navigate to *Core Infrastructure* -> *Networking* -> *Load Balancers*:

![image-20210117204440511](images/wlscnonjrfwithenv/image800.png)



- Identify the Load Balancer created by the WebLogic Stack and click on it (contains the Stack resource name prefix setup during WebLogic Stack configuration):

![image-20210117205102040](images/wlscnonjrfwithenv/image810.png) 



- In the *Resources* section, click on **Backend Sets**; click on the backend set:

![image-20210117205154277](images/wlscnonjrfwithenv/image820.png)



- Click on **Edit**:

![image-20210117205504439](images/wlscnonjrfwithenv/image830.png)



- We see that, by default, the Backend Set has Session Persistence enabled using load balancer cookie persistence:

![image-20210117183948693](images/wlscnonjrfwithenv/image840.png)



- Change to *Enable application cookie persistence*; Set **Cookie Name** to *JSESSIONID*; Click on **Update Backend Set**:

![image-20210117184034878](images/wlscnonjrfwithenv/image850.png)



- A Work Request has been created and shortly the Backend Set configuration shall be updated:

![image-20210117184105827](images/wlscnonjrfwithenv/image860.png)



## Step 3. Deploy sample ADF application

- Let's go back to the WebLogic Server admin console:

![image-20210117211129722](images/wlscnonjrfwithenv/image400.png)



- Before we deploy the ADF application, let's have a look at the Application Data Source that has been created with WebLogic Server; From *Domain Structure* go to *Services* -> *Data Sources*:

![image-20210117211532183](images/wlscnonjrfwithenv/image401.png)



- The Data Source it's named **APPDBDataSource**. We need to change the *JNDI Name* as our sample ADF application requires **jdbc/adfappds** to lookup for data source and get database connections. Click on the data source:

![image-20210117212224972](images/wlscnonjrfwithenv/image402.png)



- To change the *JNDI Name* we need to *Lock* the WebLogic Console Session. Click on **Lock & Edit** in the upper left corner:

![image-20210117212436274](images/wlscnonjrfwithenv/image403.png)



- Change *JNDI Name* to  **jdbc/adfappds** and click **Save**:

![image-20210117212733419](images/wlscnonjrfwithenv/image404.png)



- Click on **Activate Changes** to save and close the WebLogic Console Editing Session:

![image-20210117212844552](images/wlscnonjrfwithenv/image405.png)



- The change has been recorded, but we need also to restart the Datasource. Click on *View changes and restarts* (upper left corner):

![image-20210117213058670](images/wlscnonjrfwithenv/image406.png)



- Switch to *Restart Checklist*:

![image-20210117213448644](images/wlscnonjrfwithenv/image407.png)



- Select the **AppDBDataSource** and click on **Restart**:

![image-20210117213605274](images/wlscnonjrfwithenv/image408.png)



- Click **Yes**:

![image-20210117213733501](images/wlscnonjrfwithenv/image409.png)



- The Datasource will be restarted shortly:

![image-20210117213906680](images/wlscnonjrfwithenv/image410.png)



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



## Step 4. [Optional] Deploy ADF Faces Rich Client Components Demo Application

If you want to explore the ADF Faces components at runtime, the ADF Faces development team at Oracle created a component demo that showcases the various components and framework capabilities and allows you to try different property settings on the selected component. The components demo is provided with full source code and is a great way to learn how to work with the components in general. 

![img](images/wlscnonjrfwithenv/image700.png)



- First, download the [faces-12.2.1.4.0.war](https://objectstorage.eu-frankfurt-1.oraclecloud.com/n/oractdemeabdmnative/b/ll-wls-bucket/o/faces-12.2.1.4.0.war) application web archive. Then, in a similar way as at step **Deploy sample ADP application**, install the faces-12.2.1.4.0.war application. 

- Then, from *Deployments* -> *Control* tab start the application:

![image-20210117182752892](images/wlscnonjrfwithenv/image710.png)



- Once *Active*, another browser tab navigate to *https://< public load balancer IP >/faces-12.2.2.1.0/*:

![image-20210117184328628](images/wlscnonjrfwithenv/image720.png)



The **Tag Guide** is the entry link to the component demo and shows a list of ADF Faces components that you can select to further explore. Each component demo is launched in a browser that has a split screen layout. The split screen's right content area has a property inspector functionality that you can use to set properties for the individual component. Note that the right content area might be closed so that you have to drag it open before using it. Also of interest is that in addition to the rich client components, the data visualization components which allow you to graphically represent your data are also present in this listing.

The **Feature Demos** include a variety of demonstrations for the frameworks capabilities including a rich set of demos for the data visualization components, active data services, drag and drop and other client behaviors.

A demo of interest should be the **Styles** demo. Users frequently get confused by which part of a component is styled by the **inlineStyle** attribute and which part is styled by the **contentStyle** attribute. The demo also contains a skinning demonstration that allows developers to play with various skin definitions per component.



## Step 5. [Optional] Destroy resources

If you don't plan to use the WebLogic Domain anymore, to spare tenancy resources, the quickest way to delete the resources created during this lab is to run *Terraform Destroy*  on the Stack.

- Navigate to *Solutions and Platform* > *Resource Manager* > *Stacks*, identify and click on the Stack name you have created at the beginning of this lab.

- By running the *Destroy* Terraform Action, a Terraform job will kick off and delete all created resources.

![](images/wlscnonjrfwithenv/image600.png)



- When the job ends, you should see a similar log output:

![](images/wlscnonjrfwithenv/image610.png)



You can check that the Compute Instances and the Block Volumes have been terminated.

- At the end you can also delete the Stack:

![](images/wlscnonjrfwithenv/image620.png)