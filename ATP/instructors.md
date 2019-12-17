[Go to the Cloud Test Drive Overview](../readme.md)

![](../common/images/customer.logo2.png)

# Autonomous Transaction Processing for Developers #



## Preparation for Lab Instructors ##

**ATTENTION !!** 

Instructions on this page are for instructors setting up a class to execute the ATP for Developers lab.

**If you are a participant, hit the <u>back button of your browser</u> now**



### Preparing DevCS

Project creation in DevCS typically takes 2 minutes for a single project creation.  But if you have 20 participants, who all execute the project creation at the same moment, you might see an increase in the creation time, as the creation of projects in a single tenancy is a sequential process.

Therefore we changed the initial step of the lab, requiring Lab Instructors to set up the DevCS projects for their labs ahead of time.

- Navigate to the DevCS console, and hit the **+ Create** button.
  - Enter a name of the project, using a naming convention using the number of the participant, followed by the name or location of your event
    Example : *1_London*
  - Keep all other parametes as default (private repo, English language, empty project, markdown Wiki)
  - Hit the finish button
- As soon as you see the Provisioning screen of the project with the various elements being set up, hit the "Oracle Developer Cloud" icon in the top left of the screen to return to the starting page
- You can now immediately launch the next project creation (name : *2_London*)
- Please make sure not to have more that 3 project creations running in parrallel, or execution time will increase
- Repeat above steps until you have created the appropriate number of projects for your session.



### Preparing Linux Desktops

This current version of the lab requires minimal installations of software on the laptops of participants.  Only in case they want to execute the optional step to create a Kubernetes cluster you will need  more software components

#### Option 1 : No Kubernetes creation

- Participants need to install the **kubectl executable** to visualize the resulting deployments on the cluster.  As this is not an installation but just an executable to download, this will work even on "locked down" laptops.  
- As an instructor, you can choose to show the Kubernetes dashboard on your screen, projecting the status of created deployments to avoid even this installation

#### Option 2 : Participants install OKE

- **Git** is required to download a copy of the project repository, containing the terraform scripts
- **Terraform** is required to launch the OKE cluster
- **kubectl** is required to visualize the cluser

#### Option 3 : Running the lab at customer premises

When running the lab at a customer location, you will hit various firewall related issues.  Not only do you need to make sure you are able to execute all operations - most probably using a guest access on the customer's WIFI, but you also need to make sure the employees, using their regular corporate internet  connectivity, are able to access all the various locations on our cloud, and use the various ports needed for executing the lab.  

Using the Linux Desktop allows you to focus on enabling that single exit point : install a VNC viewer on the laptop, and allow access to the IP addresses of the VM's you spin up, on ports 5900-5901.  All consecutive access is done from the VM.

### Spinning up the VMs

A zipfile with a terraform script to spin up the required number of VMs can be downloaded [here](../AppDev/vm_terraform.zip).

- Edit the file **terraform.tfvars**
  - set the parameter **user_count** to *<u>one third</u>* of the number of participants you expect in your workshop.  The script will create *user_count* machines in each AD, so with a count of 4 you get 12 instances.
  - copy the public/private key from the access info folder (pem_compute) into the *keys* folder
  - Replace the various OCID's with the apropriate values as per the access document.
    - The subnet OCID and the gold_image OCID are the correct ones to use in the EMEA Cloud TestDrive environment
    - If you are running this lab on a different tenancy, please contact the EMEA BDM team as you will need to copy the golden image into your tenancy.