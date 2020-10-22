[Go to Overview Page](../README.md)

![](../../../common/images/customer.logo2.png)

# Migration of Monolith to Cloud Native

## Setting up your Cloud Tenancy 

### Introduction

This page explains all the steps to set up your **Oracle Cloud Tenancy** so you are ready to run the labs.  Because participants can use different types of tenancies, not all steps need to be executed by everybody.  In case you are using a new **Oracle Free Tier** or **Trial tenancy** environment, you are probably starting from an "empty page" and will most likely have to execute all the steps below. If you are using an existing **paid tenancy** then you may need to get the tenancy administrator to create a compartment, create security roles with the appropriate policies and to assign your user to that role.

**If you are attending an instructor-led lab**, your instructor will detail steps you need to execute and which ones you can skip.

While we strongly recommend running the lab in the virtual machine we have built, running on the Oracle Cloud Infrastructure, if you do not want to use this and are willing and able to re-create the configuration of the virtual machine on your own computer (and adjust the labs content to reflect your differing environment as ypu go through it) there are some guidelines [here](./Using-your-own-computer.md)

<details><summary><b>Self guided student - section video introduction</b></summary>
<p>

This video is an introduction to this section of the lab. Once you've watched it please press the "Back" button on your browser to return to the labs.

[![Introduction to lab preparation Video](https://img.youtube.com/vi/fxrOnJjCLBc/0.jpg)](https://youtu.be/fxrOnJjCLBc "Lab preparation introduction video")

</p>
</details>

### 1. Create the CTDOKE compartment

- Click the `hamburger` menu (three bars on the upper left)

- Scroll down the list to the `Governance and Administration` section

- Under the `Identity` option chose `Compartments`

- You should see a screen that looks like this : 

  ![](images/compartments.png)

  

- **ATTENTION** : if the compartment **CTDOKE** already exists, please move to the next item on this page
- If the **CTDOKE** compartment is not yet there, **create it** : 
  - Click the `Create Compartment` button
  - Provide a name, description
  - Chose **root** as the parent compartment
  - Click the `Create Compartment` button.



### 2. Import the image for the Development VM

- Navigate to the **Compute** and **Custom Image** screen

![](images/custom-image.png)



- On the right, make sure the **CTDOKE** compartment is selected

  ![](images/images2.png)

- **ATTENTION** : if an image with a name composed like **H-K8S-Lab-A-Helidon-2020-03-13** already exists and the date at the end (it's in the form year-month-day) is the same as or newer than the date in the import URL your instructor has given you then **you are OK for this step**, please move to the next item on this page.
- If you do not have this image available, import it with following steps:
  - Click the `Import Image` button
  - Make sure the **CTDOKE** compartment is selected
  - Name the image, probably best to have it match the name in the storage URL which will be something like H-K8S-Lab-A-Helidon-2020-03-23 as that way you will know what version of the lab you are using.
  - Make sure the Operating System is set to **Linux**
  - Select the option `IMPORT FROM AN OBJECT STORAGE URL` 
  - Enter the **VM image URL** you received from your instructor
  - Set the image type to **OCI**
  - Click the `Import image` option - it can take 10 to 15 minutes to finish, you can continue with the next setup actions and check it's completed before you create an instance using the image.

![](images/import-custom-image-form.png)

### 3. Creating a Virtual Cloud Network (VCN)

You need to set up a Virtual Cloud Network to run the instances of this lab on.

- Click the `hamburger` menu
- In the `Core Infrastructure` section chose `Networking` and then `Virtual Cloud Networks`
- Make sure you are using the =`CTDOKE` compartment you created
- Click the `Start VCN Wizzard`` button
- Chose the `VCN with Internet Connectivity` option
- Click the `Start VCN Wizzard` button
- Enter a name for the VCN : **CTDVMVCN**
- Make sure that the compartment matches the compartment **CTDOKE** you just chose / created
- Leave the fields in the Configure VCN and Subnets with their default values.
- If you are using a non trial tenancy and your organization requires it add the appropriate tags (click the `Show Tagging Options` to see these)
- Click the `Next` button
- Double check the information you've provided
- Click the `Create` button
- Once the VCN has been created click the `View Virtual Cloud Network` button





### 4. Adding an OCI ingress rule for VNC

You need to be sure that the Virtual Cloud Network supports remote access using VNC.

- Go to the VCN you created earlier:  **CTDVMVCN**

- On the VNC page on the left hand side click the `Security Lists` option

- Click on the security list in the list, Chose the one with a name something like `Default Security List for CTDVMVCN` (don't select the private subnet one)

- In the list click the `Add Ingress Rules` button

- Leave the `Stateless` option unchecked (This will provide for the returning traffic)

- Leave the `SOURCE TYPE` as CIDR

- In the `SOURCE CIDR` enter `0.0.0.0/0` (basically the entire internet, in a production you might limit to your organizations address range)

- Leave the `protocol` as `TCP`

- Leave the `SOURCE PORT RANGE` blank

- Set the `DESTINATION PORT RANGE` as `5800-5910`

- Set the `DESCRIPTION` to be VNC

- Click the `Add Ingress Rules` button





### 5. Setup the database.

#### 5a. Create a database

- Use the Hamburger menu, and select the Database section, **Autonomous Transaction Processing**
- Click **Create DB**

- Make sure the **CTDOKE** compartment is selected
- Fill in the form, and make sure to give the DB a unique name for you in case multiple users are running the lab on this tenancy.

- Make the workload type `Transaction Processing` 
- Set the deployment type `Shared Infrastructure` 

- Chose the most recent option for the database version, allocate 1 OCPU and 1 GB of storage (this lab only requires a very small database)

- Turn off auto scaling

- Make sure that the `Allow secure access from everywhere` is enabled.

- Chose the `License included` option

Be sure to remember the **admin password**, save it in a notes document for later reference.

- Once the instance is running go to the database details page, on the center left of the general information column there will be the label OCID and the start of the OCID itself. Click the **Copy** just to the left and then save the ODIC together with the password.



#### 5b. Setup your database user

- On the details page for the database, click the **Service Console** button

- On the left side click the **Development** option

- Open up the **SQL Developer Web** console

- Login as admin, using the appropriate password

- Copy and paste the below SQL instructions:

```
CREATE USER HelidonLabs IDENTIFIED BY H3lid0n_Labs;
GRANT CONNECT TO HelidonLabs;
GRANT CREATE SESSION TO HelidonLabs;
GRANT DWROLE TO HelidonLabs ;
GRANT UNLIMITED TABLESPACE TO HelidonLabs;
```

- Run the script (The Page of paper with the green "run" button, identified in the image below.) if it works OK you will see a set of messages in the Script Output window saying the User has been created and grants made.

![](images/SQLDeveloper-button.png)


### 6. Create a Development VM using the image you imported

If you are running in your tenancy
- Return to the Custom Compute Images menu (Hamburger menu -> Core Infrastructure section -> Compute -> Custom Images) 

If you are in an **instructor led** lab, you instructor will provide you with the details to locate the Developer VM image to use

- Locate image to use which your instructor has provided or you have just imported : If you are in a shared environment and there is more than one image starting H-K8S-Lab-A-Helidon chose the one with the most recent date. (As we recommend naming the images using the date this will be the last part of the image name in the format `yyyy-mm-dd`and if you had to run the import

- Check that the image state is **Available** :

Note sometimes the import image page does not refresh once the image is imported, so if it's is still displaying `Importing` then try refreshing the page.

![](images/image-available.png)

- Click on the three dots menu on the **right** of the row for your chosen image
- Now click the `Create Instance` in the resulting menu

![](images/create-instance-from-custom-image.png)

- Name the instance based on the image version so you can track what version of the lab you are following. If multiple people are sharing the same tennacy you may want to put your initials in there as well e.g. `H-K8S-Lab-A-Helidon-2020-009-07-tg`
- Expand the **Show Shape, Network and Storage Options** selection if it's not visible
- Select an **Availability domain** (Which one doesn't matter)
- If `VM.Standard.E3.Flex` with 1 OCPU and 16GB memory is not the selected instance shape click the `Change shape` button, select the Instance type to `Virtual machine`, the Processor to `AMD Rome` and the OCPU count to `1` (This will set the memory for you) Then click `Select shape` to use this shape. (You can chose other shapes if you prefer, just at the time of writing this was the most cost effective)
- The *Virtual Cloud Network Compartment* should already be set to **CTDOKE**.

![](images/create-instance-first-part.png)

- Check the `Virtual Cloud Network Compartment` is set to `CTDOKE`
- In the **Virtual cloud Network** dropdown,  select the **CTDVMVCN** network. 
- Leave all the other settings in the network section as they are
  - Check the **Assign a public IP address** option is selected
- Leave the boot volume settings unchanged

![](images/create-instance-second-part.png)

- Scroll down to the **Add SSH Key** section
  - Make sure the **Generate SSH Key Pair** option is selected
  - If you wish you can download the ssh keys by clicking on the buttons (This is not required as we will be using VNC to access the instance)
  
![](images/create-instance-third-part.png)

You have finished the wizard!

- Click the **Create** button on the bottom of the wizard to initiate the creation.

- If you get a **No SSH Access** warning you can ignore it, just click `Yes, Create Instance Anyway`

Once the create button has been clicked you will see the VM details page.  Initially the state will be **Provisioning** but after a few minutes it will switch to **Running**, and you will see that a **public IP address** has been assigned.  Make a note of that IP address (The copy link next to it will copy the address into your computers copy-and-paste buffer.)

![](images/create-instance-public-ip-address.png)

- Give the VM a few minutes to start up it's internal services.





### 7. Accessing the Developer VM

You will be using VNC to access the developer VM. There are multiple possible clients, chose from the list below or use another if you already have it. Note that the following may require you to have some level of admin rights on your machine.

#### Installing a VNC viewer

- For **macOS** we recommend realVNC which can be obtained from 

  - https://www.realvnc.com/en/connect/download/viewer/macos/

- For **Windows**, suggested packages are TigerVNC viewer or TightVNC Viewer but if you already have a preferred VNC viewer you can use this. TigerVNC viewer has a simpler install process, as it is a standalone executable, but has fewer features.

  - TigerVNC: Download ‘vncviewer64-1.9.0.exe’ from

    - https://bintray.com/tigervnc/stable/tigervnc/1.9.0#files and save it to your desktop. It is a self-contained executable file, which requires no further installation.

  - TightVNC Viewer: Select the 'Installer for Windows (64-bit)' from

    - https://www.tightvnc.com/download.php

      - When prompted, select to save the file.  Next, run the executable to install the program. This requires you have the privileges to install software on your machine

#### Accessing Development VM using VNC

We are using VNC to provide you with a remote desktop, this let's us use a Integrated Development Environment for the Helidon labs.

You need to let your VM run for a couple of mins to fully boot and start the VNC server.

- Open your VNC Client

- Connect to the client VM. Depending on your client you may be asked to different information, but usually you'll be asked for a connect string. Thsi will typically look like `123.456.789.123:1` where the ``123.456.789.123` is the IP address and the `:1` is the display number which is a constant (this is an example, the IP address won't work, you need to use your own.)

- You VNC client may warn you that you're making an insecure connection, this is expected as we have not setup security certificates. For example for a real VNC client on a Mac this may look like 

![](images/01-vnc-security-warning.png)

- You will be asked to enter a password to access the virtual screen. Your instructor will have provided this or it will have been in the file with the image import URL. This is an example showing this with the Real VNC client running on a Mac

![](images/02-vnc-login.png)

Once you have logged in you will see the Linux desktop, it will look similar to this, though the background and specific icons may differ.

![](images/03-desktop.png)

### 8. Installing Eclipse in the developer VM

We have installed a developer configuration of Oracle Linux, and added tools like Maven, git and the Java development kit. To ensure that you have the latest integrated developer environments (IDE's) and starting point source code for the labs there are a couple of steps you need to take.

There are many IDE's available. We have chosen Eclipse as it's open source licensed. As Eclipse requires the acceptance of a license we can't automate the process for you.

We have installed the Eclipse installer and places a short cut to it on the desktop. It will look like 

 - Double click on the `eclipse-installer` icon on the desktop. This will open the installer. It may look like a text page and be named `eclipse-installer.desktop` rather than the icon shown below, if it does still click it. You may be warned it's and `Untrusted application launcher`, if this happens click the `Trust and launch` option. **Do not** click the Post Eclipse Installer icon.
 
![](images/04-eclipse-installer-icon.png)

The Eclipse installer will start.

 - Select the `Eclipse IDE for Enterprise Java Developers` option

![](images/05-eclipse-installer-selection.png)

The installer switched to the next page

 - Select the `/usr/lib/jvm/java-11-openjdk` in the Java JVM dropdown ** DO NOT PRESS INSTALL YET**
 
 - Set the install path to be `/home/opc`

![](images/06-eclipse-installer-selections.png)
 
 - Then click the `Install` button
 
 - Assuming you agree with it click `Accept Now` on the license page. (If you don't agree with the license you can install your own IDE but all of the instructions are on the basis of ucing Eclispe.)
 
![](images/07-eclipse-installer-license.png)
 
The installer progress will be displayed
 
![](images/08-eclipse-installer-progress.png)
 
 - You **may** be presented with warnings about unsigned content, if you are click the `Accept` button
 
![](images/09-eclipse-installer-unsigned-warning.png)
 
 - You **may** be presented with warnings about certificates. If you are click the `Select All` button, then the `Accept Selected` button (this is not enabled until certifcates have been selected)
  
![](images/10-eclipse-installer-accept-unsigned.png)
  
 - On completion close the installer window (X on the upper right.) **Do not** click the `Launch` button.
 
![](images/11-eclipse-installer-finished-install-path.png)

- Click `No` on the exit launcher page that's displayed

![](images/12-eclipse-installer-finished-exit-without-launching.png)

We're now going to run a script that tidies up the desktop and creates an eclipse desktop icon

- Double click on the `Post Eclipse Installer` icon on the desktop. This will run the script. It may looks like a text page and be called `posteclipseinstal.desktop` rather than the icon shown below, if it does still click it. You may be warned it's an `Untrusted application launcher`, if this happens click the `Trust and launch` option.

![](images/13-post-eclipse-installer-icon.png)

If the eclipse installation was in the right place then the two desktop icons will disappear and be replaced with an `Eclipse` icon. If the Eclipse installation was in the wrong place then it will exit immediately without making any changes. In that case re-run the installer and ensure you use `/home/opc` as the Eclipse installation path.

Note that sometimes the Eclipse installer will create it's own desktop icon to start Eclipse. This does not happen every time, but if it does create one you can also use that icon to start Eclipse as well.

- Double click on the `Eclipse` icon on the desktop. It may looks like a text page rather than the icon shown below, if it does still click it. You may be warned it's an `Untrusted application launcher`, if this happens click the `Trust and launch` option.

![](images/14-eclipse-icon.png)

As Eclipse starts you will be presented with a start up "splash" then workspace selection option. 

- Set the eclipse workspace to be `/home/opc/workspace` (If you chose a different location you will have to remember to use that new location in many later stages.)

![](images/20-eclipse-start-workspace-selection.png)

- Click the `use this as the default and do not ask again` option, then the `Launch` button

![](images/20a-eclipse-start-default-workspace-selection.png)

You will be presented with the Eclipse startup. This may include a welcome page. You can close it by clicking the `x` as per normal with sub windows.

![](images/21-eclipse-welcome-page.png)

- You can close the `Donate` , `Outline` and `Task list` tabs to get the most usage from the screen.

![](images/22-eclipse-donate-page.png)

This image shows you the empty Eclipse workspace with the non required tabs all closed

![](images/23-empty-eclipse-workspace.png)

We need to configure Eclipse to display the course files in a hierarchical manner (this is so it matches the images you will have in the lab instructions, if you prefer to use the Eclipse  "Flat" view then you can ignore this step"

- Click on the Three dots in the Project Explorer panel, then take the `Package Presentation` menu option and click the radio button for `Hierarchical`

![](images/24-eclipse-package-presentation-hierarchical.png)

#### How to re-open Eclipse if you close it

- Double click on the `Eclipse` icon on the desktop. It may looks like a text page rather than the icon shown below, if it does still click it. You may be warned it's an `Untrusted application launcher`, if this happens click the `Trust and launch` option.

![](images/14-eclipse-icon.png)

### 9. Downloading and importing the labs initial code

To enable us to update the code used by the labs without having to update the Developer VM image each time we hold the primary copy of the code in a git repository (where we can update it as the lab is enhanced) You need to download this into your development VM and import it into Eclipse

#### 9a. Downloading the initial setup code zip file.

- Open the Firefox web browser - Click `Applications` then `Internet` then `Firefox`

![](images/40-open-firefox-menu.png)

- Go to the URL `https://github.com/CloudTestDrive/cloud-native-setup` - Do this in the browser **in the virtual machine**

- Click the `Code` button

![](images/41-github-project-page.png)

- Click the `Download ZIP` option

![](images/42-github-download-code.png)

A save options menu may be displayed

- Click the `Save file` option, then `OK`

![](images/43-github-download-save-file.png)

When the download is complete the Firefox download icon will turn completely blue

![](images/44-github-download-complete.png)

#### 9a. Importing the downloaded zip file

- Switch back to Eclipse

- Click the `File` menu, then `Import`

![](images/50-eclipse-import-menu.png)

- Open the `General` node, then chose the `Existing projects into Workspace` option. Click `Next`

![](images/51-eclipse-import-types.png)

- Chose the `Select archive file` radio button, then click `Browse` on that row

![](images/52-eclipse-import-archive.png)

- On the left menu chose `Downloads` then in the resulting list chose the download you just made (probably called `cloud-native-setup-main.zip`)

- Click the `Open` button

![](images/53-eclipse-import-file-selection.png)

- Click `Select All` to make sure all the projects are imported, then click the `Finish` button

![](images/54-eclipse-import-final-stage.png)

Eclipse will import the projects and start importing the Maven dependencies. Expect to see errors listed on the Eclipse `Problems` tab, and projects marked as having errors (red indicators) in the Project Explorer. 

![](images/55-eclipse-import-finished.png)

This may take a few mins. **Do not worry if you see errors** these are to be expected as we haven't finished configuring the Eclipse environment yet

Wait until the building indicator (lower right) has gone away.

#### 9b. Configuring Lombok

These labs use Lombok to do many of the "standard" functions like automatically creating constructors, getters and so on. Lombok will be covered later in the labs, but for now we need to install it into the Eclipse installation.

- Expand the `cloud-native-setup` project (Click the little triangle to the left of the project name)

- Expand the `Maven Dependencies` node

- In the maven dependencies section locate the `lombok` jar file (it will have a version number after it, at the time of writing that was 1.18.10, but that may have changed as lombok updates often)

![](images/60-lombok-locate-jar-file.png)

- Click right on the lombok jar file, then chose the `Run As` manu option, then `Java Application`

![](images/61-run-lombok-application.png)

- If you get a warning about errors click the `Proceed` button (the point of what we're doing is to fix them !)

![](images/62-run-lombok-error-warning.png)

After a short while the lombok UI will be displayed.

If you get a warning that Lombok cannot locate any IDE's you will have to locate it manually

![](images/63-lombok-cant-locate-ide-warning.png)

- Click the `OK` button in the warning popup

If Lombok has located an IDE then skip the following two steps that locate the IDE

- Click the `Specify location` button

![](images/64-lombok-locate-ide-option.png)

- In the file selector popup navigate to the IDE location you noted when you installed Eclipse if you set the install path in the earlier stage this is going to be `/home/opc/eclipse`

- Select the `eclipse.ini` file

- Click the `Select` button on the file chooser

![](images/65-lombok-locate-eclipse.png)

- Make sure that the eclipse installation has it's checkbox selected, then click the `Install / Update` button

![](images/66-lombok-install-start.png)

Lombok will do the install (this is very quick) and confirm success 

- Click the `Quit Installer` button to close the Lombok installer

![](images/67-lombok-install-completed.png)

Once Lombok has been installed you need to exit and then start Eclipse to have it recognized (The restart option in Eclipse is not sufficient.)

- Click the `File` menu then `Exit` (**do not chose restart**, that does not trigger the reload of the entire Eclipse environment) 

- Re-start Eclipse using the method described above, make sure it's Eclipse you are starting, not the installer.)

We can check that Lombok has been installed

- Click the `Help` Menu then the `About Eclipse IDE` option

![](images/68-lombok-access-eclipse-about-menu.png)

- You may need to scroll down in the `About` popup, but towards the end you should see the Lombok installation confirmation (in this case 1.18.12)

![](images/69-lombok-installed-version.png)

- Click the `Close` button to get rid of the popup

#### 9c. Updating the project configuration.

Restarting eclipse so it recognises Lombok does not always trigger a rebuild or Maven update to remove the flagged problems, so we need to do that. 

- Select the `cloud-native-setup`  project in the project explorer. Click right on them then chose `Maven` from the menu then `Update project`

![](images/70-maven-update-project-menu.png)

- Click the `Select All` button, then click the `OK` button

![](images/71-maven-update-all.png)

Maven will go and do it's thing, that may take a while.

When Maven finishes there may be warnings about problems (These relate to incomplete code you will be updating in the lab) but there shouldn't be any remaining errors.



### 10. Handling the database Wallet file.

The database Wallet file contains the details needed to connect to your database instance, it needs to be downloaded to the development VM and placed in the right location.

The easiest way to get the database Wallet file into your virtual machine is to use the cloud console to download it.

- Open a web browser **inside the virtual machine**
- Login to the Oracle Cloud Console
- Open the `hamburger` menu (three bars on the top left)
- Scroll down (if needed) to the `Database` section. Click on the `Autonomous Transaction Processing` menu option
- If you need to select the **CTDOKE** compartment you created earlier in the Compartment selector on the left side of the page.
- Click on your database name in the list (it's a link)
- On the database page click the `DB Connection` button
  - This will display a Database connection popup
- Leave the `Wallet type` as `Instance connection`
- Click the `Download Wallet` button
- A password pop-up will be displayed. Enter and confirm a password, this is used to encrypt some of the details.
- Once your password is accepted and confirmed click the `Download` button
- If you are asked what to do with the file make sure you chose the `Save file` option
- The wallet file will start to download and the password pop-up will disappear and you'll be returned to the `Database connection` pop-up
- Click `Close` on the `Database Connection` popup



## End of the setup

Congratulations, you have successfully prepared your tenancy to do the labs, there will be lab specific setup instruction where appropriate in the labs. 

Hit the **Back** button of your browser to return to the top level and start the labs !



------

[Go to Overview Page](../README.md)
