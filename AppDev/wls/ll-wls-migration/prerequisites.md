**All the subsequent steps have to be run from the provided compute image**.

Follow the next steps to get the base compute image and install it your tenancy.
Once the import of this images is done, then you should create a new compute node from this image.
You will run all labs from this node

You have to provide a VCN, with a  public subnet, and an Internet Gateway and your public key in order to be able to log into the new compute image and run all the parts of this workshop.

These are the installation steps to import / configure / create your compute node :
Log into your OCI account

A pre-auth request to download the image from the original bucket should be given to you during the workshop.
For the demo we will use a temp pre-aauth request as  :

https://objectstorage.eu-frankfurt-1.oraclecloud.com/p/0cGx21GaR_ZHfxABGGKpHNdgB7918BrhVOCLZ0jrl6IjOanhoMAypKEp2EYjjN3M/n/oraseemeatechse/b/weblogic/o/wls_base_image 

Click on compute /custom images 

![](images/preaut_1.jpg)



Click on :

1. Import image
2. Give a name to the image
3. Import from object storage bucket URL
4. Copy the pre-auth request to the textbox
5. Choose OCI type
6. Then click import to launch the import of this image to your compartment 



![](images/preaut_2.jpg)



the import task will be launched , and you have to wait until the state of the work request is finished![](images/preaut_3.jpg)

At this stage the inspection of the imported image should be as below

![](images/preaut_4.jpg)



In your tenancy  before to deploy a new compute node from this image, check that you have:

1.  **a vnc, with a regional public subnet, associated with a security list**
2.  **the port 22 open (ssh)**
3. **an internet gateway**

Below you have some examples with the previous settings :

![](images/ex_vcn1.jpg)



![](images/sec_rulesVCN.jpg)



![](images/route_table.jpg)



Create you labs compute node as below:

click on Compute/Instances entry of you oci console 

![](images/compute1.jpg)

Create an image from Custom Images /wls_lab_base_image
![](images/compute3.jpg)

Call you compute node wls_compute_node, choose any AD, check that the node is based on the custom imported image


![](images/compute31.jpg)

Choose your VCN, with your public regioanl subnet, and assign a public IP

![](images/compute32.jpg)

Copy your public key from your private key

![](images/compute33.jpg)

Paste your public ke to the wizzard

![](images/compute34.jpg)

Push the create button to launch the creation of your compute node
![](images/compute35.jpg)

Select the public IP of your compute node and use to to connect to your server

![](images/compute_node_ready.jpg)

Use your client SSH sofotaware , below is the setting for MobXterm 

![](images/mobx_term.jpg)







execute the command to change the linux user to oracle :

```
sudo su - oracle
```

Then you have to  switch to the /home/oracle/stage/installers directory from where you should run the workshop



**Before to start this lab we will explain some settings for the Docker Daemon.**

We will activate the buildkit [extention](https://docs.docker.com/develop/develop-images/build_enhancements/) in our Docker builds by adding the flag in out docker build command  
***(check the provided scripts)***.

BuildKit handle docker tag in lower letters.

We will generate the "stubs", or Dockerfiles with the dryrun flag, we will convert the relevant tags in lower letters, and then we will built the docker images with the docker build commands.

```
DOCKER_BUILDKIT=1 docker build .
```

The buildkit can be also globally activated by creating the following json file, we have added the experimental feature as well
**you don't need to modify anything into your compute node !**

```
sudo su <<EOT
cat<<'EOF'>/etc/docker/daemon.json
{
  "features": { "buildkit": true },
  "experimental": true
}
EOF
EOT
```