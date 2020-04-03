[Go to Helidon for Cloud Native Page](../Helidon-labs.md)

![](../../../common/images/customer.logo2.png)

# Loading the client VM into your tenancy

If you are running the Helidon part of the labs and want to use your own tenancy you will need to have a VM to run the Eclipse environment.

We use a VM because it enables us to provide you with a specific configuration that can be used in the labs, of course if you were developing for Helidon yourself you could use a very wide number of configurations, but for the purposes of this lab we have build a virtual machine with the Eclipse IDE, Java 11 and  Maven. The basic source code is in it's start configuration is also part of the VM. 

**IMPORTANT** These instructions currently only cover creating a VM configured for the Helidon labs, you will need to do other actions to configure the VM for the Docker and Kubernetes part of the labs. Additional documents will be created to cover those soon.

## What is not covered here
We do not do into great detail on how to do things like sign up for a trial account, create OCI compartments, configuring a Virtual Client Network and so on 

# What you will need

## Oracle Cloud Tenancy
You will need a Oracle Cloud Tenancy as the Virtual Machine is in OCI format. If you don't already have access to a tenancy you can create a free trial one by going to [cloud.oracle.com/trial](http://cloud.oracle.com/trial) 

## Compartment

You need to identify a compartment in your tenancy to use, if you don't already have a compartment you need to create one.

### Creating a compartment

If you need to create a compartment (and if you don't know if you need to create one you do) do the following as the tenancy admin (If you don't have tenancy admin rights you'll need to get your tenant admin to do this for you and give you rights to work in the compartment)

- Click the `hamburger` menu (three bars on the upper left)

- Scroll down the list to the `Governance and Administration` section

- Under the `Identity` option chose `Compartments`

- Click the `Create Compartment` button

- Provide a name, description

- Chose the parent compartment, if this is a new tenancy you'll only have a `root` compartment

- Add any tags your organization may require, if this is a trial tenancy you can ignore the tags.

- Click the `Create Compartment` button.

## Virtual Cloud Network

You need to identify a Virtual Cloud network to use, this must give you access to VNC clients (ports 5800 - 5910) If you have one ready to use you can reuse that, if not you can create one.

### Creating a Virtual Cloud Network (VCN)

If you need to create a VCN (and if you don't know if you need to create one you do) do the following as the tenancy network admin (If you are using a commercial tenancy or you don't have tenancy network admin rights you'll need to get your tenant network admin to do this for you, making sure it fits with your organizations policy)

Note, to create the VCN you should have creates or identified a compartment first.

- Click the `hamburger` menu

- In the `Core Infrastructure` section chose `Networking` and then `Virtual Cloud Networks`

- Click the `Networking Quickstart` button

- Chose the `VCN with Internet Connectivity` option

- Click the `Start Workflow` button

- Give it a name E.g. MyVCN

- Make sure that the compartment matches the compartment you chose / created

- Leave the fields in the COnfigure VCN and Subnets with their default values.

- If you are using a non trial tenancy and your organization rrequired it add the appropriate tags (click the `Show Tagging Options` to see these

- Click the `Next` button

- Double check the information you've provided

- Click the `Create` button

- Once the VCN has been created click the `View Virtual Cloud Network` button

### Adding an ingress rule for VNC
You need to be sure that the Virtual Cloud Network supports remote access using VNC.

- Go to the VCN you created earlier (this is on the cloud networks list, click on the VNC name)

- On the VNC page on the left hand side click the `Security Lists` option

- Click on the security list in the list, Chose the one with a name something like `Default Security List for MyVCN` (don't select the private subnet one)

- In the list click the `Add Ingress Rules` button

- Leave the `Stateless` option unchecked

- Leave the `SOURCE TYPE` as CIDR

- In the `SOURCE CIDR` enter `0.0.0.0/0` (basically the entire internet, in a production you might limit to your organizations address range)

- Leave the `protocol` as `TCP`

- Leave the `SOURCE PORT RANGE` blank

- Set the `DESTINATION PORT RANGE` as `5800-5910`

- Set the `DESCRIPTION` to be VNC

- Click the `Add Ingress Rules` button

## Get the VM 
We are updating the VM used on a frequent basis as we enhance the lab and switch to updated versions of Helidon and Java. Because of this you should contact your instructor for the URL to the most recent version of the image in the Oracle Storage Cloud.

### Import the image into your tenancy

- Click the `hamburger` menu

- In the `Core Infrastructure` section click `Compute` and then `Custom Images`

- Click the `Import Image` button

- Chose the compartment you created / identified earlier for the `create in compartment` field

- Name the image, probably best to have it match the name in the storage URL which will be something like H-Lab-A-Helidon-2020-03-23 as that way you will know what version of the lab you are using.

- Make sure the Operating System is set to Linux

- Select the `IMPORT FROM AN OBJECT STORAGE URL` is selected

- Enter (best to copy and paste) the image URL you got from your instructor

- Set the image type to OCI

- Leave the launch mode unchanged

- If you are using a commercial tenancy (For a trial tenancy this is not going to be an issue) and your organization has requirements aroudn tags click the show tag options and do what you are required to.

- Click the `Import image` option - it can take a while to do the import

### Create a VM using the image

You must have created a compartment, imported the VM image and have created a Virtual Cloud Network (see above)

- Click the `Hamburger menu`

- In the `Core Infrastructure` section click `Compute` and then `Instances`

- Click the `Create Instance` button

- Name the instance based on the image version so you can track what version of the lab you are following. e.g. `H-K8S-Lab-A-Helidon-2020-03-23`

- Click the **Change Image Source** button.
  - In the resulting page click the **Custom Images** tab
  - Select the image you just imported
    - If you are in a shared environment and there is more than one image starting H-K8S-Lab-A-Helidon chose the one with the most recent date. 
    - DO NOT chose any image containing the word Export.
  - Click the **Select Image** button to return to the initial screen.
  
- Use the **default values** provided for following elements: 
  - **Availability domain** (AD1), and **Instance shape** (VM.Standard.2.1)

- Set *Virtual Cloud Network Compartment* to be the compartment you just created / selected.

- In the **Virtual cloud Network** dropdown

- In the Virtual Cloud network select the VCN you just created / selected. 

- The Subnet compartment should be the name of your compartment

- The Subnet should be the name of the **public** subnet (created for you when you ran the VCN wizard)

- Leave all the other setings in the section as they are in the boot volume section
  - Check the **Assign a public IP address** option is selected
  
- Scroll down to the **Add SSH Key** section
  - If you have a pre-existing key you'd like to use please do so
  - If you do not have a pre-existing key you'd like to use
    - In a separate window, download the public key file provided by your instructor onto your laptop. 
    - Use the **Choose File** button to select the downloaded public key file.

 - Click the `Create` button
 
 - Once the instance is running there will be an IP address in the `Public IP Address` field. Take a note of this
 
 ## Accessing the client VM
 
 You will be using VNC to access the client VM. There are multiple possible clients, chose from the list below or use another if you already have it. Note that the following may require you to have some level of admin rights on your machine.
 
 ### Installing a VNC viewer

- For **macOS** we recommend realVNC which can be obtained from 

  - https://www.realvnc.com/en/connect/download/viewer/macos/

- For **Windows**, suggested packages are TigerVNC viewer or TightVNC Viewer but if you already have a preferred VNC viewer you can use this. TigerVNC viewer has a simpler install process, as it is a standalone executable, but has fewer features.

  - TigerVNC: Download ‘vncviewer64-1.9.0.exe’ from

    - https://bintray.com/tigervnc/stable/tigervnc/1.9.0#files and save it to your desktop. It is a self-contained executable file, which requires no further installation.

  - TightVNC Viewer: Select the 'Installer for Windows (64-bit)' from

    - https://www.tightvnc.com/download.php

      When prompted, select to save the file.  Next, run the executable to install the program. This requires you have the privileges to install software on your machine

## Accessing using VNC
 
You need to let your VM run for a couple of mins to fully boot and start the VNC server.

- Open your VNC Client

- Connect to the client VM. Depending on your client you may be asked to different information, but usually you'll be asked for a connect string. Thsi will typically look like 123.456.789.123:1 where the first part is the IP address and the :1 is the display number which is a constant (this is an example, the IP address won't work, you need to use your own.)

- You VNC client may warn you that you're making an insecure connection, this is expected as we have not setup security certificates.

- You will be asked to enter a password to access the virtual screen. Your instructor will have provided this.
 
 ---


[Go to *Helidon for Cloud Native* overview Page](../Helidon-labs.md)