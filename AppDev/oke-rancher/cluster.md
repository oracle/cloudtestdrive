## Welcome to part 2 - Installing OKE Cluster through Rancher ##

In this part of our lab, 
we are going to create the OKE cluster through the Rancher we created.

The cluster will be created on nodes, each of which represents a virtual machine. 
If your account is subscribed to a region with 3 AD's, you will have 3 virtual machines created.

If you completed the previous part successfully, 
you should be able to open the Rancher from your web browser, entering:

https://{{public-ip}}:433
  
The public IP should be saved in a Notepad.
**If you do not remember, follow these steps**
1. Login to OCI Console
2. Go to Compute > Instances
3. Select the dev machine and copy the public address. 

![image](https://github.com/deton57/oke-labs/blob/master/oke-rancher/screenshots/public-ip.PNG)


In your browser, go to: 
https://{{public-ip}}:433
  

If you enter via Google Chrome browser, 
click on Advanced, and then click on the Proceed link as shown below:

![image](https://github.com/deton57/oke-labs/blob/master/oke-rancher/screenshots/rancher-home-sec.PNG)

In the next screen, you can set a password. 
I would use: OKERancher123! but you may set any value as your own password. 
Once the password is set, check the checkbox 
"I agree to the Terms and Conditions for using Rancher" 
and click Continue. 

![image](https://github.com/deton57/oke-labs/blob/master/oke-rancher/screenshots/rancher-login.PNG)

On the next screen click on the button "Save URL", 
and you are in. You can now see the Rancher dashboard.

## Activate the OKE Driver ##

The OKE Driver allows Rancher to work with OCI-OKE API 
and to create and manage the cluster on Oracle.

1. Click on Tools menu and select Drivers:

![image](https://github.com/deton57/oke-labs/blob/master/oke-rancher/screenshots/Rancher-Drivers.PNG)

2. Activate the OKE Driver

![image](https://github.com/deton57/oke-labs/blob/master/oke-rancher/screenshots/rancher-OKE-driver.PNG)

Wait a few seconds, until it is Active. 
We are almost there!

## Creating the cluster ## 

Now we are one step away from creating the cluster. 
It will be a bit challenging, because we will need to prepare Rancher to work with our OCI Account.

There is one more step before we start. 
We must create an API key in our OCI Account.

I suggest to open 3 screens, out of which 2 are Web Browser’s and 1 is Mobaxterm’s.

* OCI Console Account
* On the second one Rancher
* Mobaxterm terminal 


Now, let's start.

1. On your Rancher click on "Add Cluster"

![image](https://github.com/deton57/oke-labs/blob/master/oke-rancher/screenshots/part2/rancher-add-cluster.PNG)

2.	Select OKE Driver

![image](https://github.com/deton57/oke-labs/blob/master/oke-rancher/screenshots/part2/Choose-OKE.PNG)  
  
3. Name the cluster "rancher-oke"

![image](https://github.com/deton57/oke-labs/blob/master/oke-rancher/screenshots/part2/rancher-oke-cluster.PNG) 

4. 4.	Under Region, select your cloud region. 
If you look on OCI Console should be on the upper part. 
Select the same in the Rancher cluster configuration screen.


![image](https://github.com/deton57/oke-labs/blob/master/oke-rancher/screenshots/part2/region.PNG)  

**If you are a Mac user, use this link: https://ocikb.com/create-keys-in-pem-format ** 
For windows users, you can continue with the following steps: 

5. Now we move to Mobaxterm terminal. 
We should create a Public/Private key for the API. 
This is a different requirement from the one we did before.

You can open it and connect to your dev machine.
Command line/saved session ssh 
ssh opc@{{public-ip}} -i private.key 

Once you are in, run the following commands:

opc@dev-machine-87165 ~]$ 
```ssh-keygen -t rsa -b 4096 -m PEM -f $HOME/id_rsa```
## promt enter twice ## 

Generating public/private rsa key pair.
Enter passphrase (empty for no passphrase):
Enter same passphrase again:
Your identification has been saved in /home/opc/id_rsa.
Your public key has been saved in /home/opc/id_rsa.pub.
The key fingerprint is:
SHA256:aXgNRwwd/t0BGFE0hgHcT1jrW4m4YDgYM/gt8a581b4 opc@dev-machine-87165
The key's randomart image is:
+---[RSA 4096]----+
|        o===@B   |
|    .    +o=..+  |
|   . =  . o o. . |
|    . O..= .oo..o|
|     +.=Soo..o.o.|
|      ooo.... o  |
|       .. .. .   |
|    . ..   .     |
|     o.    E.    |
+----[SHA256]-----+

Now RSA Key is generated. 
Next step is to create the public key in PEM format.

Run the following command:

```openssl rsa -in id_rsa -pubout -out id_rsa_pub.pem```

Next command will be used to copy the content:

```cat id_rsa_pub.pem```

Should be something like the following:

``` 
-----BEGIN PUBLIC KEY-----
MIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEAyQmFA7Kdx/DeN6qbg7ho
/7Yb2X+wAhzcyB4x3+IrU4r49mUoKtFrNoKHRSYsAt7Ofch74BdQ+UTRXhm+64ux
aJRQsvupEWcUC4CEQn+l6bNicskxl3LfpjxFaYVFWIWNo2Uk1O9STQ96gdFdh0xV
8HNPiWI7WNceVdlBhEw1FRFC3cZNec3jqV7YQvG8tL9pxSFTR/5hl0YWRfW2j5PK
tLstw1DWLcfjCpG7PHJ1Bm0q2JwYom5/L8G3EcCiEdqUJoJBSGqRV4O+fwv1fG6Z
YD8dZQ9FKhXlV0tLIBJ/3BPaqfrmteFojrGN4i3JAAtxP1O4Ok1qKKPcPt8z5GKS
nWHwzVorDUb0i5sQRCG13E3LRon4Qf0s4DTWUxVZ5N1AR1wtdcbxKAjwMBD/Hj5O
VfuPamh8Zjfxoz4RXNQCUklSYX1PU7413tyfKX2wP2V7g6CsonX5l0VWc/PdMgKc
ViBhD7bjQD6ujcSocNRNYAwUmPEqQHx4eDmRgNremNZhVg811FuQrbIsYpMAGEow
VmBuSxEsY76AWjFEfowmvkRaBad3F9LRFqVAkQ1d4NEZXTqRMNXsMrzSfFPj39IC
smPokzabZ0RQp+spak0p+IFYDW9kdhWqxBC2pI2ZPni5tP/h4yoRyeE0X1J4ewAr
00dRVxBiYfty4xpKjWMBgkUCAwEAAQ==
-----END PUBLIC KEY----- 
``` 

Copy the whole key and minimize the Mobaxterm window (we will need it later).

5.	Open OCI Console Click on the top right corner of the profile,
and then click on your account name.

![image](https://github.com/deton57/oke-labs/blob/master/oke-rancher/screenshots/part2/user-account.PNG)

On the left corner, click on API Keys.

Click on Create API Key


![image](https://github.com/deton57/oke-labs/blob/master/oke-rancher/screenshots/part2/api-keys.PNG)
 
paste the content from your machine generated key.

![image](https://github.com/deton57/oke-labs/blob/master/oke-rancher/screenshots/part2/add-pub-key.PNG)

You will notice that a fingerprint is created. 
Copy the full fingerprint. 

![image](https://github.com/deton57/oke-labs/blob/master/oke-rancher/screenshots/part2/fingerprint.PNG)

6.	Go to the Rancher screen 
and paste the fingerprint under "user fingerprint"

7. Go back to OCI console screen, 
at the same page you have the OCID.
Copy your user OCID and paste in the Rancher screen under "User OCID"

8. 8.	Open once again your Mobaxterm 
and run the following command:

```cat id_rsa```

This will show your private key content; 
copy it fully, without spaces, 
and paste it in the Rancher window under "User Private Key".

![image](https://github.com/deton57/oke-labs/blob/master/oke-rancher/screenshots/part2/keys-cluster.PNG)


9.	Go to OCI Console, 
click on the user profile icon,
and select your tenancy

![image](https://github.com/deton57/oke-labs/blob/master/oke-rancher/screenshots/part2/Tenancy.PNG)

copy the Tenancy OCID 
and paste it into the Rancher cluster configuration screen. "Tenancy OCID"

![image](https://github.com/deton57/oke-labs/blob/master/oke-rancher/screenshots/part2/copy-tenancy.PNG)

10.	Last parameters step: go again to OCI Console, 
scroll down the left menu, and click on identity.

![image](https://github.com/deton57/oke-labs/blob/master/oke-rancher/screenshots/part2/compartments.PNG)

Then, on compartments, choose your compartment. 
Copy the OCID of your compartment to Rancher cluster configuration screen, 
under "Compartment OCID".

11.	Once all parameters are configured, 
click on "Next Authenticate..." button

12.	Leave the parameters as is, with 1 node per AD. 
This will tell Rancher to create the OKE cluster with 1 node per AD, 
which will eventually result in total of 3 nodes, 
in case you are running on a region with 3 ADs.

13.	Click "Next Virtual Cloud Network" and select "Quick Create"

14.	Click "Next Configure Node Instances", and select the following shape: VM Standard2.1 Operating system: Oracle Linux 7.6

•	Optionally, if you wish to connect to one of the nodes, you may paste the public key created earlier for the machine.

Final result:

![image](https://github.com/deton57/oke-labs/blob/master/oke-rancher/screenshots/part2/all-params.PNG)

Now, you can click on "Create"

![image](https://github.com/deton57/oke-labs/blob/master/oke-rancher/screenshots/part2/create-cluster-final.PNG)

If you followed all the steps correctly and accurately, 
the cluster should be created. Congratulations!

We can see that the cluster is Active:

![image](https://github.com/deton57/oke-labs/blob/master/oke-rancher/screenshots/part2/Cluster-Active.PNG)

From OCI: 
go to the left menu > Developer Services > OKE > select the cluster you created, 
and check the following details: 

![image](https://github.com/deton57/oke-labs/blob/master/oke-rancher/screenshots/part2/cluster-Active-OCI.PNG)

We completed part 2, 
good job!


Continue to part 3 [Install Wordpress app from Rancher catalog and manage it](https://github.com/deton57/oke-labs/blob/master/oke-rancher/wp.md) 

If you want to return to the lab homepage, click [Back to the general lab section](https://github.com/deton57/oke-labs/blob/master/oke-rancher/readme.md)

