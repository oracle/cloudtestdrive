

These are the raw stack files that you have to upload to your Resource Manager in order to create the server to run the labs for the wls wdt/tooling session.

You should download them from this directory before to start the labs, to your local folder after that follow the below steps to create your test server to your compartment.

Get the test_wls_docker_image-stack.zip which contains the artifact to create your stack





Be sure that all policies described [here](https://docs.cloud.oracle.com/en-us/iaas/Content/Identity/Tasks/managingstacksandjobs.htm#Policies_for_Managing_Stacks_and_Jobs) are fulfilled before to import the stack



Log into your tenancy 

Scroll to Resource Manager / Stack entry

![](../WLS_deploy_scripts/images/2020-11-09_13-05-58.jpg)

Then choose your compartment:

![](../WLS_deploy_scripts/images/RM-2.jpg)

The Click on the Create Stack button:

![](../WLS_deploy_scripts/images/RM-3.jpg)



Then Choose folder, and Browse to your local directory :

![](../WLS_deploy_scripts/images/RM-4.jpg)



Choose the folder name as origin and click to upload button:

![](../WLS_deploy_scripts/images/RM-5.jpg)



Then accept the option of the uploading :

![](../WLS_deploy_scripts/images/RM-6.jpg)



Then check that the stack will be created in your compartment, you can change the name, and you see that a number of files will be used for the creation of your server infrastructure:

![](../WLS_deploy_scripts/images/RM-7.jpg)



Then copy your OWN PUBLIC KEY in the field SSH_PUBLIC_KEY, and , give also the REGION where your server will be created :

**IF YOU DONT HAVE A PUBLIC IP KEY THEN YOU CAN USE THE PUBLIC/PRIVATE KEYS THAT YOU WILL FIND INTO THE FOLDER OF THE STACK.**

**DONT USE THESE KEYS TO ANY OTHER COMPUTE NODE AS THEY ARE CREATED ONLY FOR THIS SESSION**

**THESE KEYS ARE STORED AS :**

![](../WLS_deploy_scripts/images/lab-keys.jpg)


![](../WLS_deploy_scripts/images/RM-8.jpg)

Click Next and review carefully the stack variables , you can still go back if you need to modify them, otherwise click on Create to start the stack creation:



![](../WLS_deploy_scripts/images/RM-9.jpg)



When the stack is created then you will see this screen :



![](../WLS_deploy_scripts/images/RM-10.jpg)





The stack will create a VCN, and a compute node using the below variables :



![](../WLS_deploy_scripts/images/RM-11.jpg)



Click on Terraform Apply to launch the stack creation:



![](../WLS_deploy_scripts/images/RM-12.jpg)





Click on the Apply button to start the process:



![](../WLS_deploy_scripts/images/RM-13.jpg)



After a couple of minutes you will see the progress of the stack creation:



![](../WLS_deploy_scripts/images/RM-14.jpg)



When the status is succeeded then copy the public ip of you server :



![](../WLS_deploy_scripts/images/RM-15.jpg)



Go to the compute/instances of your compartment and check that the server is up :



![](../WLS_deploy_scripts/images/RM-16.jpg)





Go to the NetWorking/Virtual CloudNetworks of your compartment



![](../WLS_deploy_scripts/images/RM-17.jpg)



Check that a VCN and the associated resources are created :



![](../WLS_deploy_scripts/images/RM-18.jpg)





Check the public ip of your server:



![](../WLS_deploy_scripts/images/RM-19.jpg)





then connect to your server as **oracle user** with your public key or the provided public IP  :



![](../WLS_deploy_scripts/images/RM-20.jpg)



In the terminal enter : docker version



![](../WLS_deploy_scripts/images/RM-21.jpg)



Then enter:

 java -version to check that the java runtime is installed

imagetool to check that the image tool is installed 

then  cd stage/installers to check that several files are installed 



![](../WLS_deploy_scripts/images/RM-22.jpg)



if you see all these artifacts then you server is ready for your labs



eugene.simos@oracle.com