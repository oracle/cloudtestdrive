[Go to Helidon for Cloud Native Page](../Helidon-labs.md)

![](../../../common/images/customer.logo2.png)

# Your ATP Database Wallet file.

The database wallet file contains the access information, you need the this information for your database to access it.

You need an existing database with a user. See the [Creating an ATP database document](CreateATPDatabaseAndSetupUser.md) If you don't already have this. In some lab situations your instructor will have an existing database and will advise you if you can skip that step.

**IMPORTANT** Do the following steps *inside* the virtual machine. This will let you easily place the wallet into the right location.

# Getting the Wallet file

In some instructor led labs your instructor may provide the database Wallet file themselves, in that case they will advise how to access it, and you will just need to install it (See the Using the wallet section below.) 

Otherwise please follow the instructions below to get the Wallet and then follow the instructions to install it

The easiest way to get the database Wallet file into your virtual machine is to use the cloud console to download it.

- Open a web browser **inside** the virtual machine

- Login to the Oracle Cloud Console

- Open the `hamburger` menu (three bars on the top left)

- Scroll down (if needed) to the `Database` section. Click on the `Autonomous Transation Processing` menu option

- Click on your database name in the list (it's a link)

- On the database page click the `DB Connection` button
  - This will display a Database connection popup

- Leave the `Wallet type` as `Instance connection`

- Click the `Download Wallet` button

- A password pop-up will be displayed. Enter and confirm a password, this is used to encrypt some of the details. if you have a password manager let it generate a password for you if you like

- Once your password is accepted and confirmed click the `Download` button

- If you are asked what to do with the file make sure you chose the `Save file` option

- The wallet file will start to download and the password pop-up will disapear and you'll be returned to the `Database connection` pop-up

- Click `Close` on the `Database Connection` popup

# Using the Wallet file

The Wallet file will have been downloaded to $HOME/Downloads, we want to place it in the right location for the labs and with the right name. It is **very** important that you follow the instructions below to ensure you are in the right directory as otherwise you may delete the lab files !

- Delete any existing wallet information
  - `rm -rf $HOME/workspace/helidon-labs-stockmanager/Wallet_ATP`
  
- Create a new wallet directory
  - `mkdir -p $HOME/workspace/helidon-labs-stockmanager/Wallet_ATP`
  
- Navigate to the stock manager folder
  - `cd $HOME/workspace/helidon-labs-stockmanager/Wallet_ATP`
  
- Move the downloaded wallet file from the downloads to the folder
  - `mv $HOME/Downloads/Wallet_*.zip .`
  
- Unpack the wallet 
  - `unzip Wallet_*.zip`
  

We now need to locate the wallet connection details.
- Look at the contents of the tnsnames.ora file to get the database connection name
  - `cat tnsnames.ora`



```
tg_high = (description= (retry_count=20)(retry_delay=3)(address=(protocol=tcps)(port=1522)(host=adb.eu-frankfurt-1.oraclecloud.com))(connect_data=(service_name=cgipkrq1hwcdlkv_jleoow_high.atp.oraclecloud.com))(security=(ssl_ser
ver_cert_dn="CN=adwc.eucom-central-1.oraclecloud.com,OU=Oracle BMCS FRANKFURT,O=Oracle Corporation,L=Redwood City,ST=California,C=US")))

tg_low = (description= (retry_count=20)(retry_delay=3)(address=(protocol=tcps)(port=1522)(host=adb.eu-frankfurt-1.oraclecloud.com))(connect_data=(service_name=cgipkrq1hwcdlkv_jleoow_low.atp.oraclecloud.com))(security=(ssl_serve
r_cert_dn="CN=adwc.eucom-central-1.oraclecloud.com,OU=Oracle BMCS FRANKFURT,O=Oracle Corporation,L=Redwood City,ST=California,C=US")))

tg_medium = (description= (retry_count=20)(retry_delay=3)(address=(protocol=tcps)(port=1522)(host=adb.eu-frankfurt-1.oraclecloud.com))(connect_data=(service_name=cgipkrq1hwcdlkv_jleoow_medium.atp.oraclecloud.com))(security=(ssl
_server_cert_dn="CN=adwc.eucom-central-1.oraclecloud.com,OU=Oracle BMCS FRANKFURT,O=Oracle Corporation,L=Redwood City,ST=California,C=US")))

tg_tp = (description= (retry_count=20)(retry_delay=3)(address=(protocol=tcps)(port=1522)(host=adb.eu-frankfurt-1.oraclecloud.com))(connect_data=(service_name=cgipkrq1hwcdlkv_jleoow_tp.atp.oraclecloud.com))(security=(ssl_server_
cert_dn="CN=adwc.eucom-central-1.oraclecloud.com,OU=Oracle BMCS FRANKFURT,O=Oracle Corporation,L=Redwood City,ST=California,C=US")))

tg_tpurgent = (description= (retry_count=20)(retry_delay=3)(address=(protocol=tcps)(port=1522)(host=adb.eu-frankfurt-1.oraclecloud.com))(connect_data=(service_name=cgipkrq1hwcdlkv_jleoow_tpurgent.atp.oraclecloud.com))(security=
(ssl_server_cert_dn="CN=adwc.eucom-central-1.oraclecloud.com,OU=Oracle BMCS FRANKFURT,O=Oracle Corporation,L=Redwood City,ST=California,C=US")))
```




- Locate the "high" connection and take a note of the name, in the example above this is tg_high **Your file will contain different names**

- Be sure to write down the database connection name you have just found, you will need it later