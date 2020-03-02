![](../commonimages/workshop_logo.png)

# Provision the Data Science service (Project and Notebook)

<!--
## Step 1: Request an Oracle Cloud Free Tier account
Your lab instructor will assist you to obtaining the account during the event.

To sign up for the Free Tier: [http://bit.ly/registeroraclecloud](http://bit.ly/registeroraclecloud). 


![](./images/create_cloud_trial.png)

### Account Details
- On the next page you will be asked for the Cloud Account Name. This is what will uniquely identify your cloud environment. You will see it as part of the URL when you access it later.
- You will also be asked for the "Home Region". This is the location of the physical data center. Choose you nearest location.

![](./images/create_cloud_trial2.png)

-
- At the end of this process, you should receive an email titled "Get Started Now With Oracle Cloud".
- To login to your cloud account, use the same email address that you used for registration.
- If you have to choose your identify domain, this is the same as the value that you chose for "Cloud Account Name" during registration.
  
![](./images/create_cloud_trial3.png)
-->

## Check/Set Privileges for Data Science service

The following privileges must be granted before you will be able to provision Data Science notebooks.
- The group of the user must have access to manage data-science-family
- The group of the user must have access to use virtual-network-family
- The service datascience must have access to use virtual-network-family
If you need help with setting this up, please refer to https://docs.cloud.oracle.com/en-us/iaas/data-science/ds-using/configure-tenancy.htm#service-access. 
Note there's a bug in the documentation: "datascience-family" must be "data-science-family", as below:

  ```
  allow group acme-datascientists to manage datascience-family in compartment acme-datascience-compartment
  ```
(the group and compartment names are arbitrary, and depend on your own configuration)

## Provisioning

- Go to the main menu.

![](./images/provisionds01.png)

- Go to Data Science -> Projects.

![](./images/provisionds02.png)

- Choose "Create Project".

![](./images/provisionds03.png)

- Choose a name and create the project.

![](./images/provisionds04.png)

- Next, within the Project, choose "Create Notebook Session".

![](./images/provisionds05.png)

- Choose a name. 
  For this exercise the default shape of VM.Standard.E2.2 is sufficient.
  For this exercise the default shape of VM.Standard.E2.2 is sufficient.
  Choose an existing VCN and subnet. If you don't have these yet, go back and create them using defaults.
  Then choose "Create".

![](./images/provisionds06.png)

