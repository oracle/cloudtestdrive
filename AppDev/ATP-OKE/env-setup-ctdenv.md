![](../../common/images/customer.logo2.png)
# Microservices on ATP #
## Preparing your Oracle Cloud Tenancy for the lab ##

## Introduction ##

This tutorial assumes you are using an Oracle provided Cloud Tenancy, where most of the prerequisites for running this lab have already been set up for you.

In case you are using a personal instance, either obtained via the Oracle Cloud Free Tier or using an existing paying account, you need to [follow this tutorial]() for setting up all required services.

This page will guide you through the following activities :

- Step 1: Add a certificate and a token to your user



### Log in to your cloud account

In this lab you will be using the PaaS services that are linked with the **Identity Management Service** called IDCS.  In order to be able to manage these services you need to login using the option shown below:

<img src="images/100/login.png" alt="image-20200422220552977" style="zoom:33%;" /> 



## STEP 1: Create a user certificate and token

In order to interact with the various Cloud Services in a secure way, we will be using a **password token** and a **API Key**.

### Locate your User Details

First you need to locate your user using the Search functionality of the console:

- Click on the **Search Bar** on the top of your console, and enter your username.  For example, if your name was **ppan** : 

  ![](../wls/images/ppan2.png)

- Select the user **that looks like :  oracleidentitycloudservice/(your_name)**

### Create a Token

<img src="../wls/images/token1.png" style="zoom: 50%;" />

- Select **Token** in the right-hand menu, then click the button **Create Token**.

  - Enter a name for the token

  - Use the **Copy** button to copy the token in your buffer, and **immediately paste it** in a notebook of your choice, you will need this later.

    ![](../wls/images/token2.png)


### Create an API Key

- Add an API key:

  - In the left-hand menu, click on the **API Keys** menu

  - Add an API key: you need a private/public key pair, and you need to paste the public one into the key field. 
  
    - An **Example** is proveded below: both private and public keys are made available, so obviously this is **not good security practice**.
  
      - [Public key](keys/api_key_public.pem)
      - [Private key](keys/api_key.pem)
  
    - **Good practice** is to generate your own keys: You can use the following [OpenSSL](http://www.openssl.org/) commands to generate the key pair in the required PEM format. You can use the Oracle Cloud Shell to issue these commands: use the "**>_**" icon in the top right of your console.
  
      - Open a Cloud Shell and execute following commands
  
        - ```
          mkdir ./mykey
          openssl genrsa -out ./mykey/api_key.pem 2048
          openssl rsa -pubout -in ./mykey/api_key.pem -out ./mykey/api_key_public.pem
          ```
        
      - For more details on this key creation, see the [documentation](https://docs.cloud.oracle.com/iaas/Content/API/Concepts/apisigningkey.htm).
  
  - Once you have the key pair available, return to the detailed screen of your user
  
    - Click on the **Add Public Key** button
    - Either select the local file containing the public key, or paste the content of the file into the "Public Key" field.
    - Click **Add** to create the key
  
  - Copy the fingerprint of your API key in a temporary file
  
  - Copy the OCID of this user in a temporary file
  
  <img src="images/devcs/OCI_user_details_new.png" alt="alt text" style="zoom: 33%;" />



---





You finished all the steps of the setup.   Use the menu to navigate to the next chapter.

