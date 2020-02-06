# Createing the client VM in the OCI tenancy

Log into the OCI environment using your laptop. The instructor will provide you with the URL and login details. You may have to provide a password, if you do please read the password rules carefully, and make sure you chose a password that you can remember.

Once you've logged in to the cloud test drive tenancy if you re opn the OCI "Classic" page then click the word Infrastructure to take you to the OCI main page
create the instance.

Using the "hamburger" menu (top left, three bars) in the core infrastructure section -> Compute -> Instances.

On the left side Under list scope using the Compartment dropdown chose CDTOKE as the compartment.

Click on the "Create Instance" button (Upper left of the list of instances)

Chose a name for your instance, to recognize it it needs to be unique so we suggest you use something like LAB-<Your initials>-Helidon-Client

Where you replace <Your initials> with your initials, if you think that is likely to be common, or you don;t want to use them then please chose something that you think will be unique.

In the operating system or image source click the "Change Image Source" button.

In the resulting page click the "Custom Images" tab 

Look for an image called H-K8S-Initial-State-<YYYY-MM-DD> where the YYYY-MM-DD is a date, chose it by clicking the checkbix to the left of the image name. If there are more than one image chose the one with the most recent date. DO NOT chose any image containing the work Export.

Once you've selected the image you want at the bottom of the list click the "Select Image" button

DO NOT change anything the availability domain, instance type and instance shape settings.

In the configure networking section, in the Virtual Cloud Network use the dropdown to select the CTDVMVCN network. Leave all the other setings in the section as they are.

DO NOT change anything the boot volume section (make sure that the Assign a public IP address option is selected)

In the Add SSH Key section click the chose files. Your instructor will have provided yopu with a web location where you can download a .pub file from. Download it and the select the downloaded file using the normal web browser file choser that is displayed when you click "Chose files"

Check that you have followed the instructions aboce, then click the "Create button. This will be at the bottom of the page.

Once the create button has been clicked you will see the Vm details page, initially the state will be provisioning but after a few mins it will switch to Running, and you will see that a public IP address has been assigned (This is in the Primary VNIC section) Make a note of that IP address.

Give the VM a few mins to start up it's internal services.

Use your VNC client to connect to the VM desktop display 1. The precise format of the VNC connect string will vary depending on your VNC client, but it will be something like <Your VM Public IP address>:1  (Note the :1 at the end) Be sure to use the public IP address, not the private one!

When you connect you will get warnings about an insecure connection, as this lab does nto process any confidential data and is only running for a short time that's OK

You will need to enter a password for the VNC session. The instructor will provide you with this.