# How to create an ATP database in your tenancy for your lab

## Create the database

Login to the cloud tenancy

Hamburger menu, go to the left side, then Database section -> Autonomous Transaction Processing 
Click create DB

Fill in the form (give the DB a unique name for you) remember the admin password

## Get the OCID

Once the instance is running go to the database details page, on the center left of the general information column there will be the label OCID and the start of the OCID iteelf. Click the "Copy" just to the left and then in a text editor or similar save the ODIC.

## Setup your user

On the details page for the database, click the "Service Console" button (probabaly will open a separate tab)

On the left side click the "Development" option

Open up the SQLWebDeveloper console

Login if required as admin, using the admin password you set when you setup the database

Copy and paste the below, Note that the username (HelidonLabs) and password (H3lid0n_Labs) below can be changed if you like, **BUT** if you do change them you will also need to change the helidon-labs-stockmanaer/confsecure/stockmanager-database.conf file  or you will be unable to connect to the database

CREATE USER HelidonLabs IDENTIFIED BY H3lid0n_Labs;
GRANT CONNECT TO HelidonLabs;
GRANT CREATE SESSION TO HelidonLabs;
GRANT DWROLE TO HelidonLabs ;
GRANT UNLIMITED TABLESPACE TO HelidonLabs;

Run the script (The Page of paper with the green "run" button.) if it works OK you will see a set of messages in the Script Output window saying the User has been created and grants made.

## **VERY IMPORTANT**
Make sure you take a copy of the DB OCID