## Welcome to part 1 - Creating the Rancher ## 
The first step in our lab is creating the Rancher.
Our mission is to create a Virtual machine and set it up everything we need to create a Kubernetes cluster.

In this section we will focus on the following 3 steps:
1.	Create Virtual Cloud Network and Subnet for the virtual machine
2.	Add HTTPS/443 rule to the security list, in order to connect to Rancher
3.	Create Virtual machine with Oracle Cloud Developer image, in order to create a Docker


Step 1: 

## Create Virtual Cloud Network and Subnet ## 

Once connected to your cloud account,
you will see the dashboard screen.


Open the side menu and go to Networking:


![image](https://github.com/deton57/oke-labs/blob/master/oke-rancher/screenshots/menu-networking.PNG)
    

Click on Virtual Cloud Networks.

![image](https://github.com/deton57/oke-labs/blob/master/oke-rancher/screenshots/create-vcn.PNG)
  
Click on Create VCN button,
and enter the following values:

1.	Name: "oke-rancher-lab"
2.	Compartment name: select your compartment name
3.	CIDR BLOCK: you can select any private subnet you use. For example: "10.0.0.0/16"
•	Comment: Make sure it's not overlapping with other subnets you have
4.	Click on Create VCN button on the bottom


![image](https://github.com/deton57/oke-labs/blob/master/oke-rancher/screenshots/create-vcn2.PNG)  

Done. your VCN is created.


Now click on the Create Subnet button.

![image](https://github.com/deton57/oke-labs/blob/master/oke-rancher/screenshots/create-subnet2.PNG)  


Enter the following values:

1.	Name: "dev-subnet"
2.	Leave Regional option selected
3.	From the CIDR BLOCK select a sub-network, which is the same as the subnet previously selected. For example: "10.0.0.0/24"
4.	Subnet access - must remain public (do not worry, this is just a “sandbox”)
5.	Scroll down and click on Create Subnet button


Congratulations! You have now created a Virtual Network plus Subnet.
Let us continue to the second step.
 
Step 2: 

## Add rules to Security list and add an Internet Gateway ## 

Open the side menu and go to Networking:

![image](https://github.com/deton57/oke-labs/blob/master/oke-rancher/screenshots/menu-networking.PNG)
  
Go to Virtual Cloud Networks. 

Select the Virtual Cloud Network created in the previous step.

And now navigate to Security Lists.

![image](https://github.com/deton57/oke-labs/blob/master/oke-rancher/screenshots/security-list.PNG)

Click on the default security list. 

Click on Add Ingress Rule. 

Now we are going to add HTTPS access to our network, 
so, we can access the web page of Rancher. 

First we must add HTTPS access to our network, to let us access the Rancher web page:

1.	Source CIDR input: "0.0.0.0/0" (comment: I know it is not secured, and I would never recommend you do that,  but just for lab we can do that)
2.	DESTINATION PORT RANGE: "443"

Now click on Add Ingress Rule button



![image](https://github.com/deton57/oke-labs/blob/master/oke-rancher/screenshots/security-list2.PNG)

![image](https://github.com/deton57/oke-labs/blob/master/oke-rancher/screenshots/security-list-result.PNG)  


Once the Ingress Rule is created, 
we shall create an Internet Gateway, to enable routing traffic through the Internet.

1.	On your network side menu go to Internet Gateway:

![image](https://github.com/deton57/oke-labs/blob/master/oke-rancher/screenshots/internet-gateway.PNG)

2. Click on Create Internet Gateway button:

![image](https://github.com/deton57/oke-labs/blob/master/oke-rancher/screenshots/internet-gateway2.PNG)

3. Go to Route Tables, to set the traffic route to the Internet Gateway:

![image](https://github.com/deton57/oke-labs/blob/master/oke-rancher/screenshots/internet-gateway3.PNG)

4. Click on the Default Route Table for oke-rancher-lab:

![image](https://github.com/deton57/oke-labs/blob/master/oke-rancher/screenshots/internet-gateway4.PNG)

5. Add the following route to the Internet Gateway:

![image](https://github.com/deton57/oke-labs/blob/master/oke-rancher/screenshots/internet-gateway5.PNG)

Now the traffic is routed to the Internet, 
and we have access to port 443. 
We completed step 2!


Step 3: 

## Create a virtual machine and install Rancher ##

Open the side menu and go to Compute:

![image](https://github.com/deton57/oke-labs/blob/master/oke-rancher/screenshots/menu-compute.PNG)  
  
Click on Create Instance button:

![image](https://github.com/deton57/oke-labs/blob/master/oke-rancher/screenshots/create-instance1.PNG)

Enter the following values:
1.	Name: "dev-oke-rancher"
2.	Select your compartment name
3.	Click on Change Image, then Oracle images, look for "Oracle Cloud Developer Image", scroll down and check the checkbox:
I have reviewed and accept the Oracle Standard Terms and Restrictions.
4.	Click on Select Image.


4.**Note: you are going to create a shape with 1 OCPU (Intel) + 15Gb RAM..**

![image](https://github.com/deton57/oke-labs/blob/master/oke-rancher/screenshots/create-instance1.PNG)


5.	Select the Virtual Cloud Network you created before
6.	Select the subnet you created before
7.	Make sure that ASSIGN A PUBLIC IP ADDRESS is checked


![image](https://github.com/deton57/oke-labs/blob/master/oke-rancher/screenshots/create-instance2.PNG)


8.	Scroll down to Add SSH Keys

Here it is a bit tricky, 
but we will do it together.

**If you are a Mac user, use this link: https://ocikb.com/ssh-keys-for-linux-cloud-instances ** 
For windows users, you can continue with the following steps: 

1. Open putty keygen
![image](https://github.com/deton57/oke-labs/blob/master/oke-rancher/screenshots/putty-keygen1.PNG)

2. click on Generate button and hoover your mouse a few times over the screen so a key is generated.

![image](https://github.com/deton57/oke-labs/blob/master/oke-rancher/screenshots/putty-keygen2.PNG)

3. **Important: ** Save the private key on your PC (click Save private key)

![image](https://github.com/deton57/oke-labs/blob/master/oke-rancher/screenshots/putty-keygen3.PNG)

4. Save your public key content on your PC 
(copy the public key content from the screen and save it to Notepad)

![image](https://github.com/deton57/oke-labs/blob/master/oke-rancher/screenshots/putty-keygen4.PNG)

Now, once it is copied, we can paste the public key into the SSH-KEY in OCI: 
 
![image](https://github.com/deton57/oke-labs/blob/master/oke-rancher/screenshots/create-instance3.PNG)
 
9.	Click on Create
10.	Let us wait 1to 2 minutes until the Instance is provisioned.
Now copy the public IP address and put it on a Notepad page.


![image](https://github.com/deton57/oke-labs/blob/master/oke-rancher/screenshots/public-ip.PNG)  
  
As soon as this step is complete, 
it is time to connect and install Rancher. 
Since you have selected the Oracle Developer Cloud Image, 
there is no need to install Docker or any other tools, for now.

Open your Mobaxterm or any other terminal. 
For your convenience, please find below the steps for Mobaxterm 
(in Putty you can use other steps):

1. Click Session
2. SSH
3. In the remote host, copy the instance **Public IP** you saved before. 
4. specify username: opc 
5. Click on Advanced SSH Settings 
6. Check the Use private key and load it from your directory

![image](https://github.com/deton57/oke-labs/blob/master/oke-rancher/screenshots/session-moba.PNG)
  
If you have successfully completed the previous steps, 
you can now connect to the machine from the left side panel, 
by double-clicking on the machine name.

Once you are connected you should see the following output:

[opc@dev-machine ~]$

In order to create the Rancher on Docker, 
run the following command:


``sudo 
   docker run -d --restart=unless-stopped \
  -p 80:80 -p 443:443 \
  rancher/rancher:latest``
  
**if the command is not running well** go here:
https://rancher.com/docs/rancher/v2.x/en/installation/other-installation-methods/single-node-docker/#option-a-default-rancher-generated-self-signed-certificate

Let us wait 1 to 2 minutes until the Docker images 
are downloaded and the Docker is up and running.

run the following command: 

``sudo docker ps``

You should see something like the following:

90c3ff917b57        rancher/rancher:latest   "entrypoint.sh"     2 hours ago         Up 2 hours          0.0.0.0:80->80/tcp, 0.0.0.0:443->443/tcp   focused_beaver

If you got this output, you rock! 
We just finished creating our Rancher. 
Let's continue to our next step.

Click here to go to part 2: 

[Create an OKE cluster using Rancher](cluster.md) 


If you want to return to the lab homepage, click here:
[Back to the general lab section](readme.md)




  
 
