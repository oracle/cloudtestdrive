[Go to ATP Overview Page](../../ATP/readme.md)

![](../../common/images/customer.logo2.png)
# Microservices on ATP

## Build a Container image with the aone application runing on ATP

#### **Extra Steps**

Because you are working in your own Cloud Tenancy, you need to perform a few extra steps to set all parameters up correctly:

## Steps

- In the **Cloud Shell**, navigate to the directory where you cloned your **Git** repository

- Navigate into your database wallet folder, and edit the file **sqlnet.ora** 

  - In this file, replace the default line below:

  - ```
    WALLET_LOCATION = (SOURCE = (METHOD = file) (METHOD_DATA = (DIRECTORY="?/network/admin")))
    ```

    

  - by this line:

  - ```
    WALLET_LOCATION = (SOURCE = (METHOD = file) (METHOD_DATA = (DIRECTORY=$TNS_ADMIN)))
    ```

  - This will allow us to simply set the environment variable $TNS_ADMIN to the correct path.




- Create a secret for making the database wallet available as a mounted volume inside your pods

  - Run the following command :

    ```
    #First move up one level
    cd ..
  
    # Now create a second secret
  kubectl create secret generic db-wallet --from-file=<wallet_directory>
    ```

    - <wallet_directory> is the location of your wallet folder.  This can be a relative or a full path, finishing with a "/"
  
  - Example command:

    ```
    kubectl create secret generic jle-wallet --from-file=./Wallet_JLEOOW/
    ```
  
    





**Use the "Back" button of your browser to return to the flow of your lab.**