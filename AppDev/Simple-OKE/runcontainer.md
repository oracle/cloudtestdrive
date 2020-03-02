# Pull an Image from Oracle Cloud Infrastructure Registry when Deploying a Load-Balanced Application to a Cluster

## Before You Begin

This 15-minute tutorial shows you how to:

- create a named secret containing Oracle Cloud Infrastructure credentials
- add the named secret to a manifest .yml file, along with the name and location of an image to pull from Oracle Cloud Infrastructure Registry
- use the manifest .yml file to deploy the helloworld application to a Kubernetes cluster and create an Oracle Cloud Infrastructure load balancer
- verify that the helloworld application is working as expected, and that the load balancer is distributing requests between the nodes in a cluster



### Background

Oracle Cloud Infrastructure Registry is an Oracle-managed registry that enables you to simplify your development to production workflow. Oracle Cloud Infrastructure Registry makes it easy for you as a developer to store, share, and manage development artifacts like Docker images. And the highly available and scalable architecture of Oracle Cloud Infrastructure ensures you can reliably deploy your applications. So you don't have to worry about operational issues, or scaling the underlying infrastructure.

Oracle Cloud Infrastructure Container Engine for Kubernetes is a fully-managed, scalable, and highly available service that you can use to deploy your containerized applications to the cloud. Use Container Engine for Kubernetes when your development team wants to reliably build, deploy, and manage cloud-native applications. You specify the compute resources that your applications require, and Container Engine for Kubernetes provisions them on Oracle Cloud Infrastructure in an existing OCI tenancy.

This tutorial assumes you have already completed:

- the [Pushing an Image to Oracle Cloud Infrastructure Registry](http://www.oracle.com/webfolder/technetwork/tutorials/obe/oci/registry/index.html) tutorial
- the [Creating a Cluster with Oracle Cloud Infrastructure Container Engine for Kubernetes](http://www.oracle.com/webfolder/technetwork/tutorials/obe/oci/oke-full/index.html) tutorial

### What Do You Need?

- You must have met the prerequisites for the [Pushing an Image to Oracle Cloud Infrastructure Registry](http://www.oracle.com/webfolder/technetwork/tutorials/obe/oci/registry/index.html) tutorial, and successfully completed the tutorial. 
- You must have met the prerequisites for the [Creating a Cluster with Oracle Cloud Infrastructure Container Engine for Kubernetes](http://www.oracle.com/webfolder/technetwork/tutorials/obe/oci/oke-full/index.html) tutorial, and successfully completed the tutorial. 

------

## ![section 1](https://www.oracle.com/webfolder/technetwork/tutorials/obe/oci/oke-and-registry/img/32_1.png)Getting Ready for the Tutorial

1. Verify that you can use kubectl to connect to the cluster you created in the [Creating a Cluster with Oracle Cloud Infrastructure Container Engine for Kubernetes](http://www.oracle.com/webfolder/technetwork/tutorials/obe/oci/oke-full/index.html) tutorial by entering the following command in a terminal window:

   ```
   $ kubectl get nodes
   ```

   You see details of the nodes running in the cluster. For example:

   ```
   NAME               STATUS   ROLES   AGE   VERSION
   10.0.10.2          Ready    node    1d    v1.13.5
   10.0.11.2          Ready    node    1d    v1.13.5
   10.0.12.2          Ready    node    1d    v1.13.5
   ```

   You've confirmed that the cluster is up and running as expected. You can now deploy an application to the cluster.

------

## ![section 2](https://www.oracle.com/webfolder/technetwork/tutorials/obe/oci/oke-and-registry/img/32_2.png)Create a Secret for the Tutorial

To enable Kubernetes to pull an image from Oracle Cloud Infrastructure Registry when deploying an application, you need to create a Kubernetes secret. The secret includes all the login details you would provide if you were manually logging in to Oracle Cloud Infrastructure Registry using the `docker login` command, including your auth token.

1. In a terminal window, enter the following command:

   ```
   $ kubectl create secret docker-registry ocirsecret
   --docker-server=fra.ocir.io --docker-username='<tenancy-namespace>/<oci-username>' --docker-password='<oci-auth-token>' --docker-email='<email-address>'
   ```

   where:

   - `ocirsecret` is the name of the secret you're creating, and that you'll use in the manifest file to refer to the secret. For the purposes of this tutorial, you must name the secret `ocirsecret`. When you've completed the tutorial and are creating your own secrets for your own use, you can choose what to call your secrets. ``
   - `<username>` is the username to use when pulling the image. The username must have access to the tenancy specified by `tenancy-namespace`. For example, `jdoe@acme.com`. 
   - `<oci-auth-token>` is the auth token of the user specified by `oci-username`. For example, `k]j64r{1sJSSF-;)K8`
   - `<email-address>` is an email address. An email address is required, but it doesn't matter what you specify. For example, `jdoe@acme.com`

   Note the use of single quotes around strings containing special characters.

   For example, combining the previous examples, you might enter:

   ```
   $ kubectl create secret docker-registry ocirsecret --docker-server=fra.ocir.io --docker-username='oractdemeabdmnative/user.api' --docker-password='k]j64r{1sJSSF-;)K8'
   --docker-email='jdoe@acme.com'
   ```

2. Verify that the secret has been created by entering:

   ```
   $ kubectl get secrets
   ```

   Details about the ocirsecret secret you just created are shown.

3. Having created the secret, you can now refer to it in the application's manifest file.

------

## ![section 3](https://www.oracle.com/webfolder/technetwork/tutorials/obe/oci/oke-and-registry/img/32_3.png)Add the Secret and the Image Path to the Manifest File

Having created the secret, you now include the name of the secret in the manifest file that Kubernetes uses when deploying the helloworld application to a cluster. You also include in the manifest file the path to the helloworld image in Oracle Cloud Infrastructure Registry.

1. Open a new file in a text editor.

2. Copy and paste the following text into the new file:

3. ```
   apiVersion: apps/v1
   kind: Deployment
   metadata:
     name: helloworld-deployment
   spec:
     selector:
       matchLabels:
         app: helloworld
     replicas: 1
     template:
       metadata:
         labels:
           app: helloworld
       spec:
         containers:
         - name: helloworld
       # enter the path to your image, be sure to include the correct region prefix    
           image: fra.ocir.io/oractdemeabdmnative/<repo-name>/<image-name>:<tag>
           ports:
           - containerPort: 80
         imagePullSecrets:
       # enter the name of the secret you created  
         - name: <secret-name>
   ---
   apiVersion: v1
   kind: Service
   metadata:
     name: helloworld-service
   spec:
     type: LoadBalancer
     ports:
     - port: 80
       protocol: TCP
       targetPort: 80
     selector:
       app: helloworld
   ```

4. Change the following line in the file to include the path you specified when you pushed the helloworld image to Oracle Cloud Infrastructure Registry:

   ```
   image: fra.ocir.io/oractdemeabdmnative/<repo-name>/<image-name>:<tag>
   ```

   For example,  change the line to read:

   ```
   image: fra.ocir.io/oractdemeabdmnative/myrepo/helloworld:latest
   ```

5. Change the following line in the file to include the name of the secret you created earlier:

   ```
   name: <secret-name>
   ```

   As you gave the secret the name ocirsecret, change the line to read:

   ```
   name: ocirsecret
   ```

6. Save the file with the name helloworld-lb.yml in a local directory accessible to kubectl, and close the file.

------

## ![section 4](https://www.oracle.com/webfolder/technetwork/tutorials/obe/oci/oke-and-registry/img/32_4.png)Deploy the helloworld Application

Having updated the helloworld application's manifest file, you can now deploy the application.

1. In a terminal window, deploy the sample helloworld application to the cluster by entering:

   ```
   $ kubectl create -f <local-path>/helloworld-lb.yml
   ```

   Messages confirm that the deployment helloworld-deployment and the service helloworld-service load balancer have both been created.

   The helloworld-service load balancer is implemented as an Oracle Cloud Infrastructure load balancer with a backend set to route incoming traffic to nodes in the cluster. You can see the new load balancer on the Load Balancers page in the Oracle Cloud Infrastructure Console.

------

## ![section 5](https://www.oracle.com/webfolder/technetwork/tutorials/obe/oci/oke-and-registry/img/32_5.png)Verify the Load-balanced helloworld Application Is Working Correctly

1. In a terminal window, enter the following command:

   ```
   $ kubectl get services
   ```

   You see details of the services running on the nodes in the cluster. For the helloworld-service load balancer that you just deployed, you see:

   - the external IP address of the load balancer (for example, 129.146.147.91)
   - the port number

2. Open a new browser window and enter the url to access the helloworld application in the browser's **URL** field. For example, http://129.146.147.91


3. When the load balancer receives the request to access the helloworld application, the load balancer routes the request to one of the available nodes in the cluster. The results of the request are returned to the browser, which displays a page with a message like:

   **`Hello`**

   `Is it me you're looking for?`

   ![Browser window](https://www.oracle.com/webfolder/technetwork/tutorials/obe/oci/oke-and-registry/img/oci-hello-world-visit1.png)

   At the bottom of the page, a page view counter shows the number of times the page has been visited, and initially displays '1'.

4. Reload the page in the browser window (for example, by clicking **Refresh** or **Reload**).

    ![Browser window](https://www.oracle.com/webfolder/technetwork/tutorials/obe/oci/oke-and-registry/img/oci-hello-world-visit2.png)

    

    The counter at the bottom of the page now displays '2'.

    Congratulations! You've successfully deployed the helloworld application. Kubernetes used the secret you created to pull the helloworld image from Oracle Cloud Infrastructure Registry. It then deployed the image and created an Oracle Cloud Infrastructure load balancer to distribute requests between the nodes in the cluster. Finally, you've verified that the application is working as expected.





