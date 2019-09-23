[Go to ATP Overview Page](../../ATP/readme.md)

![](../../common/images/customer.logo2.png)
# Microservices on ATP

## Build a Container image with the aone application runing on ATP

#### **Extra Steps**

Because you are working in your own Cloud Tenancy, you need to perform a few extra stepps to set all parameters up correctly:

## Steps

- Navigate to the **Git** page of your Developer project

- Open the file **Dockerfile**, and hit the Edit button (pencil icon upper right) to change the file

- On line 17, change the **COPY** comman to reflect the name of your wallet directory:

  - For example, if your wallet folder is named **APT1**, replace the original line with the blow text:

    ```dockerfile
    COPY ./wallet_ATP1 ./wallet_NODEAPPDB2
    ```

- Hit the **Commit** button (upper right) to save your changes.

- Now navigate into your wallet folder by clicking on it, then select the file **sqlnet.ora** and hit the "Edit" pencil icon.

  - In this file, replace the default line below:

  - ```
    WALLET_LOCATION = (SOURCE = (METHOD = file) (METHOD_DATA = (DIRECTORY="?/network/admin")))
    ```

    

  - by this line:

  - ```
    WALLET_LOCATION = (SOURCE = (METHOD = file) (METHOD_DATA = (DIRECTORY=$TNS_ADMIN)))
    ```

  - This will allow us to simply set the environment variable $TNS_ADMIN to the correct path.





**Use the "Back" button of your browser to return to the flow of your lab.**