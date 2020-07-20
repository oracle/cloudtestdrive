![](../../common/images/customer.logo2.png)
# Microservices on ATP - Part 5

## Deploy your container on top of your Kubernetes Cluster

#### **Introduction**

In this section we will create a second build job to run the container we created on the Kubernetes Cluster we set up.

Let’s get started! 

## Step 1: Set up your Deploy Build Job

- Navigate to the **Build** tab and hit the **New Job** button.

  - Enter a name, for example OKEDeploy
  - Select your build template, we named it DockerOCIOKE in the previous steps

  ![](images/670/im47-1.png)

  - Now hit  **Create Job**, and the Job Configuration dialog will pop up. 

- In the Git tab, select your git repository.

  ![](images/670/im48-1.png)

  - Do **not** select the "Automatically perform Build" option for this job, we will link it with the previous job using a pipeline.

- In the Builders tab, add the following Builder steps:

  - **Docker Login** : use the predefined Repository definition **MyOCIR** as you did in the previous job

    ![](images/670/im53.png)

  

  - **OCIcli** step: 
    - Enter the required parameters to set up the OCI Command line environment:
      - User OCID : the OCID of the user you attached the certificate to.  This string starts with : ocid1.user.oc1..aaaaaaaavgjs6jhi...
      - Fingerprint : the fingerprint of your API Key.  Forma looks like: 60:25:4a:81:01:55:85:c3:1c:c7:18 ...
      - Tenancy: this is the OCID of the tenancy.  This OCID starts with: ocid1.tenancy.oc1..aaaaaaaa46ywh ...
      - Private Key: visualize the private key you generated in the **Cloud Shell** with the command:
        - `cat api_key.pem`
        - Paste the full text of the result in the Private Key field.  Below an abbreviated exaple:
        - -----BEGIN RSA PRIVATE KEY-----
          MIIEpQIBAAKCAQEAvErG6O47tjqDUzJGtIpks6CO0ydja/nGEkr3k3VQrCggY9RX
          SX34OuAgN9YFB1y1UqC6bH2NkT7DyKhuYMPFzzOgpqOLxWwmiXWYvhy28O191pkQ
          ...
          x5aB2O+hkY2k2QwiA8D4ZKsd+tiJyxj5fomzCt4pNWUGOyUuweE4BroH1XRizKmK
          rDNFBWkCgYEAtRL5vd4UOXxGP6bAjPs1ZzI3JkLxeznBMHHnl03f6nMHJEgcCY3K
          08oVHiNKOPxhsJ8zgWHXB40QUZ3+WGEL9QCBd3Hv1lsOC83KfY+FIiBCY/++mPfj
          l8qwvaYS9fp8jwDiQ+H1rfD5YCD5HV1Mh4dcTNY0A147xHQBsEIdqts=
          -----END RSA PRIVATE KEY-----
      - Region: name of the region your tenancy is running in.  For example : eu-frankfurt-1

  

  - **Unix Shell** step:

    - launch the script "kubescript.sh" that is in your repository.  We will edit this script after completing the Build definition to adapt it to your needs.

      ``bash -ex kubescript.sh``

  ![](images/670/im50-1.png)

- You have finished setting up the Build job !

  ==> Don't forget to **Save** the job !

  

## Step 2: Configure the environment to point to your cloud instance

- Upload the kubeconfig file into the repository.  During the creation of the cluster, a **kubeconfig** file was generated.  This file is required to connect to your cluster from within the build job.  In case you are using a common Kubernetes cluster, your instructor will provide you with the appropriate **kubeconfig** file.

  - In Visual Builder Studio, navigate to the top level of your git repository, and hit the **+ File** button:

    ![](images/670/im51.png)

  - Enter the name of the file : **mykubeconfig**
  
    - Open your local **mykubeconfig** file **with a plain text editor** and copy the content into the editor window of your browser:
  
  ![](images/670/im52.png)
  
  **Attention** : make sure NOT to accidentally insert any line feeds in the long line 4 that contains a certificate.  See picture above how the file should look after the paste command.
  
  - Commit the new file

  

- Now open the file **atp2.yaml**.  This is the deployment profile of your container on the Cluster.  You need to make following changes:

  - Line 17: set the correct image location as you configured it in the BuildContainer job

  - Example for datacenter in Frankfurt (**fra**), tenancy object storage namespace **mytenancy_namespace**, repo path **oowhol** and image name joduatp2:latest container name: 

    `fra.ocir.io/mytenancy_namespace/oowhol/joduatp2:latest`

    ![](images/670/edit_yaml-1.png)

  - Notice the **imagePullSecret name** parameter on line 22.  In case you created you own secret, you need to enter the correct name on this line.  For the shared Kuberentes instance, this name is **jleoow_oicsecret** and should already be set correctly.

  - Use the **Commit** button to save your changes.
  
  

## Step 3: Execute and validate your new job

- In the **Builds** menu, select the job you just created and hit the **Build Now** button.

- Wait for the job to finish, then check the build log:

  ![](images/670/image067-1.png) 

- Inspect the build job log file to validate correct execution

  ![](images/670/log_deploy.png)






## Step 4: Visualize the Service to obtain the URL of your application

In order to see the application you just deployed, we need to construct the URL where the container is listening.  You can do this via the command line and kubectl.

- command : `kubectl get nodes -o wide`

```
NAME        STATUS   ROLES   AGE   VERSION   INTERNAL-IP   EXTERNAL-IP     OS-IMAGE                  KERNEL-VERSION                   CONTAINER-RUNTIME
10.0.10.2   Ready    node    16h   v1.12.6   10.0.10.2     130.61.56.185   Oracle Linux Server 7.5   4.14.35-1818.3.3.el7uek.x86_64   docker://18.9.1
10.0.11.2   Ready    node    16h   v1.12.6   10.0.11.2     130.61.34.50    Oracle Linux Server 7.5   4.14.35-1818.3.3.el7uek.x86_64   docker://18.9.1
10.0.12.2   Ready    node    16h   v1.12.6   10.0.12.2     130.61.109.52   Oracle Linux Server 7.5   4.14.35-1818.3.3.el7uek.x86_64   docker://18.9.1
```

And next: 

- Command : `kubectl get service`

```
NAME         TYPE        CLUSTER-IP    EXTERNAL-IP   PORT(S)          AGE
atp2jle      NodePort    10.96.6.240   <none>        3050:31056/TCP   15h
kubernetes   ClusterIP   10.96.0.1     <none>        443/TCP          16h
```

 

- Now select any of the **external IP** addresses of the nodes, and combine it with the **external port** of your service - this is the second port number on the line of the atp2 service.  
  In the above example : 130.61.56.185:31056



When you enter this URL in your browser, you should see the below result:

![alt text](images/670/result.png)





Congratulations, you have finished this lab !!!!

- You created an Autonomous database and populated it with some tables and data
- You created a Kubernetes cluster and deployed a container with a Node application
- You accessed this application via your browser

Because you did all this via a CI/CD chain, making a small change in the source code of your application will trigger the re-deployment and make your change immediately visible.


