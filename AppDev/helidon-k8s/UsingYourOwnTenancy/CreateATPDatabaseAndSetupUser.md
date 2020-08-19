[Go to Helidon for Cloud Native Page](../Helidon-labs.md)

![](../../../common/images/customer.logo2.png)

# How to create an ATP database in your tenancy for your lab

If you already have a database just get the OCID and create the user as below.

## Create the database

Login to the cloud tenancy

Hamburger menu, go to the left side, then Database section -> Autonomous Transaction Processing 
Click create DB

It is not required, but if you are creating a database just for these labs you may want to include it in the same compartment as the client VM and other resources.

Fill in the form (give the DB a unique name for you) 

Make the workload type `Transaction Processing` and the deployment type `Shared Infrastructure` 

Chose the most recent option for the database version, allocate 1 OCPU and 1 GB of storage (this lab only requires a very small database)

Turn off auto scaling

Make sure that the `Allow secure access from everywhere` is enabled.

If you do not have your own Oracle licenses (this is probably the case for a trial)  make sure that you chose the `License included` option. If you have unused licenses owned by your organization you can chose the `Bring your own license` option - but please confirm that your existing licenses can be used by reading the details on the `Learn more` link

Be sure to remember the admin password !

## Get the OCID

Once the instance is running go to the database details page, on the center left of the general information column there will be the label OCID and the start of the OCID itself. Click the "Copy" just to the left and then in a text editor or similar save the ODIC.

## Setup your user

On the details page for the database, click the "Service Console" button (probably will open a separate tab)

On the left side click the "Development" option

Open up the SQLWebDeveloper console

Login if required as admin, using the admin password you set when you setup the database. If you are using a already existing database (not one created for this lab) then you can either create the user (as described below) or you can use an existing user and adjust the Helidon database configuration file.

Copy and paste the below, Note that the username (HelidonLabs) and password (H3lid0n_Labs) below can be changed if you like, **BUT** if you do change them you will also need to change the database connection configurations you use (more on these later) with the any changes to the username or password or you will be unable to connect to the database

CREATE USER HelidonLabs IDENTIFIED BY H3lid0n_Labs;
GRANT CONNECT TO HelidonLabs;
GRANT CREATE SESSION TO HelidonLabs;
GRANT DWROLE TO HelidonLabs ;
GRANT UNLIMITED TABLESPACE TO HelidonLabs;

Run the script (The Page of paper with the green "run" button.) if it works OK you will see a set of messages in the Script Output window saying the User has been created and grants made.

## Creating database tables
Fortunately for us we don't need to create the database tables ourselves. The labs use a database engine called Hibernate, and that has been configured to create the tables if it needs to.

# **VERY IMPORTANT**
Make sure you take a copy of the DB OCID (see above) You will need this if you do the Kubernetes labs.