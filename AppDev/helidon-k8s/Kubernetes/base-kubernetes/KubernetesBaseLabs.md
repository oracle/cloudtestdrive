[Go to Overview Page](../Kubernetes-labs.md)

![](../../../../common/images/customer.logo2.png)

# Migration of Monolith to Cloud Native

## C. Deploying to Kubernetes

## 1. Basic Kubernetes

## Lab Setup

You will be using the **Oracle Cloud shell** to run the kubernetes parts of the labs. 

The **Cloud Shell** is accessible throuhg the Oracle Cloud GUI, and has a number of elements set up out of the box, like the Oracle Cloud Command Line Interface, and it also has quite some usefull command-line tools pre-installed, like git, docker, kubectl, helm and more.

To access the shell, you can use the native browser on your laptop (no need for using the Linux desktop anymore).

- Login to your Oracle Cloud Console

- Click the icon on the top right of your screen:  **>_**

  ![](images/home-screen.png)

- This will result in the cloud shell to be displayed at the bottom of your window.

  - To maximise the size of the shell window, click the "Arrows" button on the right of the console as indicated below:

    ![](images/cloud-console.png)



### Downloading the scripts

Firstly we need to download all of the scripts and other configuration data to run the labs, these are stored in a Oracle Cloud storage bucket. Your tutor will have provided you with instructions which include the URL to use below.

**Need better instructions for this bit, can we switch to using git ? How does that work in eclipse ?**

- Open a cloud Shell
- Make a directory to hold this, for compatibility with the Helidon part of the labs we'll call this workspace
  - `mkdir workspace`
  - `cd workspace`
- Clone the repository with all scripts from github into your cloud shell environment:
  - `git clone xxxxxxxxx`
### Downloading the database wallet file

Usually you do not hard code the database details in to the images, they are held externally. This is for security reasons, and also convenience, you may decide to switch to a different database, or just change the user password of the database, and it's a lot easier doing that through configuration than having to rebuild the image.

To keep the secrets outside the image means that you need to get the database connection details so you can add them to your kubernetes configuration.

We will use the oci shell to download the database wallet file. 


- Create the wallet directory and navigate to it:
  
  - `mkdir -p $HOME/workspace/helidon-labs-stockmanager/Wallet_ATP`
  
  - `cd $HOME/workspace/helidon-labs-stockmanager/Wallet_ATP`
  
- Get the wallet file of your database
  
  
  - Attention: replace the example ODIC below with the OCID of your database
    
  - `oci db autonomous-database generate-wallet --file Wallet.zip --password 'Pa$$w0rd' --autonomous-database-id ocid1.autonomousdatabase.oc1.eu-frankfurt-1.aa8d698erlewaiehqrfklhfoeqwfaalkdhfuieiq`
  
    ```
    Downloading file  [####################################]  100%
    ```
  
- Unzip the wallet file
  
  - `unzip Wallet.zip`
  
- Look at the contents of the tnsnames.ora file to get the database connection names
  - `cat tnsnames.ora`
  
  You will see a list of the various connection types to your database.

- Locate the "high" connection type to your database and take a note of the full name, for example **jleoow_high**

### Point your Application to the database


- Edit the database configuration file to specify the database name. This file is `$HOME/workspace/helidon-labs-stockmanager/confsecure/stockmanager-database.yaml`
  - Locate the javax.sql.DataSource.stockLevelDataSourceOraATPJTA.datasource.url line. This will look something like 
    ```
    url: jdbc:oracle:thin:@jleoow_high?TNS_ADMIN=./Wallet_ATP
    ```
  - update the name of the connection (here it's shown as `jleoow_high`) and replace it with the name from the tnsnames.ora file, for example `tg_high`.  In this particular case the resulting line will look like  
    ```
    url: jdbc:oracle:thin:@tghigh?TNS_ADMIN=./Wallet_ATP
    ```
  
- Save the changes



## Introduction to the lab

### Kubernetes
Docker is great, but it only runs on a local machine, and doesn't have all of the nice cloud native features of kubernetes.

You will need access to a running Kubernetes cluster:

- Your instructor might have provided you with an environment.  In that case, just follow the instructions on this page
- You might need to spin up a Kubernetes cluster yourself.  Follow [these instructions](../../ManualSetup/CreateKubernetesCluster.md), then return to this page to start this part of the lab.



Access to the cluster is managed via a config file that by default is located in the $HOME/.kube folder, and is called `config`.  To check the setup, make sure to have copied your personal kubeconfig file at this location : 

- Locate the kubernetes **config file** of your cluster
  - Either provided by your instructor
  - Or download the file using the instructions in the Kubernetes 
- Copy the file into the **$HOME/.kube** folder and rename it to **config**
  -  `mv Downloads/kubeconfig .kube/config`
- Now validate you can visualize elements of the cluster with the **kubectl** command
  - `$ kubectl get nodes`

```
NAME        STATUS   ROLES   AGE     VERSION
10.0.10.2   Ready    node    9m16s   v1.15.7
10.0.10.3   Ready    node    9m2s    v1.15.7
```

 (The details and number of nodes will vary depending on the settings you chose when you created the cluster)


### Basic cluster infrastructure services install

Usually a Kubernetes cluster comes with only the core kubernetes services installed that are needed to actually run the cluster (e.g. the API, DNS services.) Some providers also give you the option of installing other elements (e.g. Oracle Kubernetes Envrionment provides the option of installing the Helm 2 tiller pod and / or the Kubernetes dashboard) but here we're going to assume you have a minimal cluster with only the core services and will need to setup the other services before you run the rest of the system

For most standard services in Kubernetes Helm is used to install and configure not just the pods, but also the configuration around them. Helm has templates (called charts) that define how to install potentially multiple services and to set them up.

**Using Helm 3**
Helm 3 is a client side only program that is used to configure the kubernetes cluster with the services you chose. If you're familiar with Helm 2 you will know about the cluster side component "tiller". This is no longer used in Helm 3


Once you have Helm then we will use it to install kubernetes-dashboard (if it wasn't installed for you when you setup the cluster) In this case we didn't do that as we want to show you how to use Helm.

Setting up the kubernetes dashboard (or any) service using helm is pretty easy. it's basically a simple command. 

**Lab version differences, you must do one of these options**
<details><summary><b>If you are using a client virtual machine for **this** section of the lab (either in an oracle provided or your own tenancy)</b></summary>
<p>

Helm is installed in the virtual machine for you, and already configured to use the master chart repository

For these labs we are using a common client virtual machine and we use both helm 2 and 3 for different labs. For *these* labs we're using helm 3, and to differentiate it we've renamed the command to be helm3, if you installed helm in your own laptop the helm command (version 2 or version 3) will just be called helm, not helm3

- Run the following command : 
  -  `helm3 install kubernetes-dashboard  stable/kubernetes-dashboard   --namespace kube-system`

```
NAME: kubernetes-dashboard
LAST DEPLOYED: Tue Dec 24 13:51:24 2019
NAMESPACE: kube-system
STATUS: deployed
REVISION: 1
TEST SUITE: None
NOTES:
*********************************************************************************
*** PLEASE BE PATIENT: kubernetes-dashboard may take a few minutes to install ***
*********************************************************************************
Get the Kubernetes Dashboard URL by running:
  export POD_NAME=$(kubectl get pods -n kube-system -l "app=kubernetes-dashboard,release=kubernetes-dashboard" -o jsonpath="{.items[0].metadata.name}")
  echo https://127.0.0.1:8443/
  kubectl -n kube-system port-forward $POD_NAME 8443:8443
```

Note that Helm does all the work needed here, it creates the service, deployment, replica set and pods for us and starts things running. 

-  Check the staus of the Helm deployment
  -  `helm3 list --namespace kube-system`

```
NAME                	NAMESPACE  	REVISION	UPDATED                             	STATUS  	CHART                      	APP VERSION
kubernetes-dashboard	kube-system	1       	2019-12-24 16:16:48.112474 +0000 UTC	deployed	kubernetes-dashboard-1.10.1	1.10.1 
```
</p></details>
<details><summary><b>If you are using the OCI Cloud shell for **this** section of the lab (either in an oracle provided or your own tenancy)</b></summary>

The cloud shell has helm already installed for you, however it does not know what repositories to use for the helm charts. We need to tell help what repositories to use.

- Run the following command :
  - `helm repo add stable https://kubernetes-charts.storage.googleapis.com/`
    ```
    "stable" has been added to your repositories
    ```
You can get the current list of repositories    
- Run the following command :
  - `helm repo list`
    ```
    NAME    URL                                              
    stable  https://kubernetes-charts.storage.googleapis.com/
    ```

- Run the following command : 
  
  -  `helm install kubernetes-dashboard  stable/kubernetes-dashboard   --namespace kube-system --set service.type=LoadBalancer`

```
NAME: kubernetes-dashboard
LAST DEPLOYED: Tue Dec 24 13:51:24 2019
NAMESPACE: kube-system
STATUS: deployed
REVISION: 1
TEST SUITE: None
NOTES:
*********************************************************************************
*** PLEASE BE PATIENT: kubernetes-dashboard may take a few minutes to install ***
*********************************************************************************
Get the Kubernetes Dashboard URL by running:
  export POD_NAME=$(kubectl get pods -n kube-system -l "app=kubernetes-dashboard,release=kubernetes-dashboard" -o jsonpath="{.items[0].metadata.name}")
  echo https://127.0.0.1:8443/
  kubectl -n kube-system port-forward $POD_NAME 8443:8443
```

Note that Helm does all the work needed here, it creates the service, deployment, replica set and pods for us and starts things running. 

-  Check the staus of the Helm deployment
  -  `helm list --namespace kube-system`

```
NAME                	NAMESPACE  	REVISION	UPDATED                             	STATUS  	CHART                      	APP VERSION
kubernetes-dashboard	kube-system	1       	2019-12-24 16:16:48.112474 +0000 UTC	deployed	kubernetes-dashboard-1.10.1	1.10.1 
```
<p>
</p></details>

We've seen it's been deployed by Helm, this doesn't however mean that the pods are actually running yet (they may still be downloading)

- Check the  status of the objects created:
  -  `kubectl get all --namespace kube-system`

```
NAME                                         READY   STATUS    RESTARTS   AGE
pod/coredns-6dcc67dcbc-hpqx8                 1/1     Running   0          49m
pod/coredns-6dcc67dcbc-xnbr8                 1/1     Running   0          49m
pod/etcd-docker-desktop                      1/1     Running   0          48m
pod/kube-apiserver-docker-desktop            1/1     Running   0          48m
pod/kube-controller-manager-docker-desktop   1/1     Running   0          48m
pod/kube-proxy-5mt6m                         1/1     Running   0          49m
pod/kube-scheduler-docker-desktop            1/1     Running   0          48m
pod/kubernetes-dashboard-58d96f69b8-tlhgx    1/1     Running   0          8m5s

NAME                           TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)                  AGE
service/kube-dns               ClusterIP   10.96.0.10       <none>        53/UDP,53/TCP,9153/TCP   49m
service/kubernetes-dashboard   ClusterIP   10.110.174.155   <none>        443/TCP                  8m5s

NAME                        DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR   AGE
daemonset.apps/kube-proxy   1         1         1       1            1           <none>          49m

NAME                                   READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/coredns                2/2     2            2           49m
deployment.apps/kubernetes-dashboard   1/1     1            1           8m5s

NAME                                              DESIRED   CURRENT   READY   AGE
replicaset.apps/coredns-6dcc67dcbc                2         2         2       49m
replicaset.apps/kubernetes-dashboard-58d96f69b8   1         1         1       8m5s
```
We see all the elements of the dashboard: a pod, a replica set, a deployment and a service.(

If you want more detailed information then you can extract it, for example to get the details on the pods do the following

-  Execute below command, replacing the ID with the ID of your pod:
  -  `kubectl get pod kubernetes-dashboard-58d96f69b8-tlhgx  -n kube-system -o yaml`

```
apiVersion: v1
kind: Pod
metadata:
  creationTimestamp: "2019-12-24T16:16:48Z"
  generateName: kubernetes-dashboard-58d96f69b8-
  labels:
    app: kubernetes-dashboard
    pod-template-hash: 58d96f69b8
    release: kubernetes-dashboard
  name: kubernetes-dashboard-58d96f69b8-tlhgx
  namespace: kube-system
  ownerReferences:
  - apiVersion: apps/v1
    blockOwnerDeletion: true
    controller: true
    kind: ReplicaSet
    name: kubernetes-dashboard-58d96f69b8
    uid: c93ec88c-2668-11ea-a75b-025000000001
  resourceVersion: "3519"
  selfLink: /api/v1/namespaces/kube-system/pods/kubernetes-dashboard-58d96f69b8-tlhgx
  uid: c93fbdbd-2668-11ea-a75b-025000000001
spec:
  containers:
  - args:
    - --auto-generate-certificates
    image: k8s.gcr.io/kubernetes-dashboard-amd64:v1.10.1
 (lots more lines of output)
```
If you want the output in json then replace the -o yaml with -o json.

If you're using JSON and want to focuse in on just one section of the data structure you can use the JSONPath printer in kubectl to do this, in this case we're going to look at the image that's used for the pod

- Get a specific element from a configuration:
  -  `kubectl get pod kubernetes-dashboard-58d96f69b8-tlhgx  -n kube-system -o=jsonpath='{.spec.containers[0].image}'`

```
k8s.gcr.io/kubernetes-dashboard-amd64:v1.10.1
```
This used the "path" in json of .spec.containers[0].image where the first . means the "root" of the JSON structure (subesquent . are delimiters in the way that / is a delimiter in Unix paths) the spec means the spec object (the specification) containers[0] means the first object in the containers list in the spec object and image means the attribute image in the located container.

We can use this coupled with kubectl to identify the specific pods associated with a service, for example 

- Command : 
  -  `kubectl get service kubernetes-dashboard -n kube-system -o=jsonpath='{.spec.selector}'`

```
map[app:kubernetes-dashboard release:kubernetes-dashboard]
```
Tells us that any thing with label app matching kubernetes-dashboard and label release matching kubernetes-dashboard will be part of the service

- Get the list of pods providing the service:
  -  `kubectl get pod -n kube-system --selector=app=kubernetes-dashboard`

```
NAME                                    READY   STATUS    RESTARTS   AGE
kubernetes-dashboard-58d96f69b8-tlhgx   1/1     Running   0          43m
```

### Accessing the kubernetes dashboard

First we're going to need create a user to access the dashboard. This involves creating the user, then giving it the kubernetes-dashbaord role that helm created for us when it installed the dashbaord chart.

- Go to the helidon-kubernetes project folder, then the base-kubernetes directory
  -  `cd  helidon-kubernetes/base-kubernetes`
- Create the user and role
  -  `kubectl apply -f dashboard-user.yaml`

```
serviceaccount/dashboard-user created
clusterrolebinding.rbac.authorization.k8s.io/dashboard-user created
```

---

<details><summary><b>Explaining the dashboard-file.yaml</b></summary>
<p>

Open up the dashboard-file.yaml and let's have a look at a few of the configuration items

```
apiVersion: v1
kind: ServiceAccount
metadata:
  name: dashboard-user
  namespace: kube-system
```
This first line tells us that kubectl will be using the core Kubernetes API to do the work, then the remainder of the section tells kubernetes to create an object of kind ServiceAccount called dashboard-user in the kube-system namespace. 

There is then a "divider" of `---` between the next section, this tells kubectl / kubetnetes to start the next section as if it was a separate command, the benefit here is that it allows us to basically issue one command that does two actions.

```
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: ClusterRole
metadata:
  name: kubernetes-dashboard-role
rules:
  - apiGroups:
      - "*"
    resources:
      - "*"
    verbs:
      - "*"
```

This section is potentially dangerous, it's defining a cluster role that has all permissions to everything. In a production environment you'd want to restrict to specific capabilities, but for this lab it's easier to do the lot rather than immediately jump into the kubernetes security configuration.

```
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: dashboard-user-role-binding
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: kubernetes-dashboard-role
subjects:
- kind: ServiceAccount
  name: dashboard-user
  namespace: kube-system
```
The last section tells kubernetes to use the rbac.authorization.k8s.io service (This naming scheme uses DNS type naming and basically means the role based access controls capability of the authorization service in kubernetes.io) create a binding that connects the user dashboard-user in namespace kub-system to the kubernetes-dashboard role, basically anyone logged in as dashboard-user has cluster the ability to run the commands specified in the cluster kubernetes-dashboard role. 

In practice this means that when the kubernetes-dashboard asks the RBAC service it the user identified as dashboard-user is allowed to use the dashboard it will return yes, and this the dashboard service will allow the dashbaord user to log in and process requests. So basically standard type of Role Based Access Control ideas. 



**A Note on YAML**

kubectl can also take JSON input as well as YAML. Personally I think that using any data format (including YAML) where whitespace is sensitive and defines the structure is just asking for trouble (get an extra space to many or too few and you'de completely changed what you're trying to do) so my preference would be to use JSON. However (to be fair) JSON is a lot more verbose compared to YAML and the syntax can also lead to problems (though I think that a reasonable JSON editor will be a lot better than a YAML editor at finding problems and helping you fix them)

Sadly (for me at least) YAML has been pretty widely adopted for use with kubernetes, so for the configuration files we're using here I've used YAML, if you'd like to convert them to JSON however please feel free :-)

</p></details>

---



Before we can login to the dashboard we need to get the access token for the dashboard-user. We do this using kubectl

- Visualize the token of the newly created user:
  - ```
    kubectl -n kube-system describe secret `kubectl -n kube-system get secret | grep dashboard-user | awk '{print $1}'`
    ```

```
Name:         dashboard-user-token-mhtf9
Namespace:    kube-system
Labels:       <none>
Annotations:  kubernetes.io/service-account.name: dashboard-user
              kubernetes.io/service-account.uid: a09cd40c-2663-11ea-a75b-025000000001

Type:  kubernetes.io/service-account-token
Data
====
namespace:  11 bytes
token:      
eyJhbGciOiJSUzI1NiIsImtpZCI6IiJ9.eyJpc3MiOiJrdWJlcm5ldGVzL3NlcnZpY2VhY2NvdW50Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9uYW1lc3BhY2UiOiJrdWJlLXN5c3RlbSIsImt1YmVybmV0ZXMuaW8vc2VydmljZWFjY291bnQvc2VjcmV0Lm5hbWUiOiJhZG1pbi11c2VyLXRva2VuLW1odGY5Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9zZXJ2aWNlLWFjY291bnQubmFtZSI6ImFkbWluLXVzZXIiLCJrdWJlcm5ldGVzLmlvL3NlcnZpY2VhY2NvdW50L3NlcnZpY2UtYWNjb3VudC51aWQiOiJhMDljZDQwYy0yNjYzLTExZWEtYTc1Yi0wMjUwMDAwMDAwMDEiLCJzdWIiOiJzeXN0ZW06c2VydmljZWFjY291bnQ6a3ViZS1zeXN0ZW06YWRtaW4tdXNlciJ9.HUg_9-3HBAG0IJKqCNZvXOS8xdt_n2qO4yNc0Lrh4T4AXnUdMHBR1H8uO6J_GoKSKKeuTJpaIB4Ns4QGaWAvcatFxJWmOywwT6CtbxOeLIyP61PCQju_yfqQO5dTUjNW4O1ciPqAWs6GXL-MRTZdvSiaKvUkD_yOrnmacFxVVZUIKR8Ki4dK0VbxF9VvN_MjZS2YgMz8CghsM6AB3lusqoWOK2SdM5VkIGoAOZzsGMjV2eCYJP3k6qIy2lfOD6KrvERhGZLk8GwEQ7h84dbTa4VHqZurS63fle-esKjtNS5A5Oarez6BReByO6nYwEVQBty3VLt9uKPJ7ZRr1FW5iA

ca.crt:     1025 bytes
```
- Copy the contents of the token (in this case the `eyJh........W5iA` text, but it *will* vary in your environment.) 
- Save it in a plain text editor on your laptop for easy use later in the lab

We now need to connect to the kubernetes-dashboard service, this gives us a problem as it's running on a network that it internal to the cluster. Fortunately for us kubernetes provides several mechanisms to expose a service outside the cluster network.


**Lab version differences, you must do one of these options**
<details><summary><b>If you are running in a virtual machine (in your own or an Oracle provided tenancy)</b></summary>
<p>
For now we're going to use port-forwarding to only make it available on our local machine (other mechanisms exist to make a service available to any external system that can access the public IP address)

- Run the following commands **in a *new* terminal window**
  -  `export POD_NAME=$(kubectl get pods -n kube-system -l "app=kubernetes-dashboard,release=kubernetes-dashboard" -o jsonpath="{.items[0].metadata.name}")`
  -  `echo $POD_NAME`

This will set the environment variable POD_NAME to be the value of the pod running the kubernetes-dashboard

- Setup the port forwarding
  -  `kubectl -n kube-system port-forward $POD_NAME 8443:8443`

```
Forwarding from 127.0.0.1:8443 -> 8443
Forwarding from [::1]:8443 -> 8443
```
This will create a port forwarding on the local host, connecting port 8443 locally to the 8443 port on the specified pod running in the kube-system namespace.

***Warning***
For security and resource management reasons the port forwarding will not run forever. After a period of time of not being used (depending on the Kubernetes providers configuration, this can be anything from a small number of seconds e.g. 30 to many hours, and may be based on total time, or time since last operation) the port forwarding will time out. In this case the kubectl command will exit and return to the prompt.

If you find that are unable to access the dashboard, or it does not reflect changes you've made check to see that the port forwarding is still running, and if it has exited just restart it.
</p></details>

<details><summary><b>If you are running in the cloud shell (in your own or an Oracle provided tenancy)</b></summary>
<p>
As the cloud shell runs in a web browser and is not itself a web browser we need to setup access so that the kubernetes-dashboard is available to your web browser running on your machine. 

Kubernetes supports many mechanisms for doing this (for example the use of ingress controllers which will be covered below) but for now we're just going to use a load balancer which will redirect the requests for us direct to the dashboard service.

Fortunately for us helm is a very powerful mechanism for configuring services, and when we used the helm command to install the dashboard we told it that the service.type was LoadBalancer, this will automatically setup a load balancer for us, we just need the IP address to use.

To get the IP address of the dashboard load balancer

- Run the following command
  - `kubectl get service kubernetes-dashboard -n kube-system`
    ```
    NAME                   TYPE           CLUSTER-IP     EXTERNAL-IP      PORT(S)         AGE
    kubernetes-dashboard   LoadBalancer   10.96.21.252   130.61.134.234   443:32302/TCP   4m48s
    ```

The IP address of the load balancer is in the EXTERNAL-IP column. Note that this can take a few minutes to be assigned, so it it's listed as <pending> just re-run the command after a short while
</p></details>
### Looking around the dashboard.
In several of the labs we're going to be using the dashboard, so let's look around it a bit to get familiar with it's operation.

- Open a web browser and if you are using a virtual machine go to page `https://localhost:8443/` If you are using the cloud shell user the IP address you got above and go to `https://<load balancer ip address>`

- In the browser, accept a self signed certificate. 
  - In Safari you will be presented with a page saying "This Connection Is Not Private" Click the "Show details" button, then you will see a link titled `visit this website` click that, then click the `Visit Website` button on the confirmation pop-up. To update the security settings you may need to enter a password, use Touch ID or confirm using your Apple Watch.
  - In Firefox once the security risk page is displayed click on the "Advanced" button, then on the "Accept Risk and Continue" button
  - In Chrome once the "Your connection is not private" page is displayed click the advanced button, then you will see a link titled `Proceed to ....(unsafe)` click that

You'll now be presented with the login screen for the dashboard.

- Click the radio button for the **Token**
- Enter the token for the admin-user you retrieved earlier
- Accept to save the password if given the option, it'll make things easier on the next login
- Press **Sign In**

![dashboard-login-completed](images/dashboard-login-completed.png)



You now should see the **Overview** dashboard :

![dashboard-overview](images/dashboard-overview.png)



---

<details><summary><b>Exploring the details of the dashboard</b></summary>
<p>

The kubernetes dashboard gives you a visual interface to many the features that kubectl provides. 

If you do not have the menu on the left click the three bars to open the menu up.

The first thing to remember with the dashboard is that (like kubectl) you need to select a namespace to operate in, or you can chose to extract data from all namespaces. The namespace selection is on the left side, initially it may well be set to "default" in the Namespace section on the left menu click the dropdown to select the kube-system namespace

![dashboard-overview-kube-system](images/dashboard-overview-kube-system.png)

You can use the kubernetes dashboard to navigate the relationships between the resources. If you scroll down the page to services you'll see the kubentes-dashboard service listed, 

![dashboard-overview-kube-system-services](images/dashboard-overview-kube-system-services.png)

click on it to get the details of the service, including the pods it's running on.

![dashboard-service-dashboard](images/dashboard-service-dashboard.png)

If you click the deployments in the left menu you'll see the deployments list (the dashboard and coredns services) 

![dashboard-deployments-list](images/dashboard-deployments-list.png)

click on the kubernetes-dashnboard deployment to look into the detail of the deployment and you'll see the deployment details, including the list of replica sets that are in use. We'll look into the old / new distinction when we look at rolling upgrades) 

![dashboard-deployment-dashboard](images/dashboard-deployment-dashboard.png)

Click on the replica set (something like kubernetes-dashboard-58d96f69b8) to see the pods in the replica set. 

![dashboard-replicaset-dashboard](images/dashboard-replicaset-dashboard.png)

In this case there's only one pod (kubernetes-dashboard-58d96f69b8-tlhgx in this case, yours will vary) so click on that to see the details of the pod. 

![dashboard-pod-dashboard](images/dashboard-pod-dashboard.png)

Using kubernetes-dashboard to look at a pod provides several useful features, we can look at any log data it's generated (output the pod has written to stderr or stdout) by clicking the Logs button on the upper right.
![dashboard-logs-dashboard](images/dashboard-logs-dashboard.png)

This opens a new tab / window with the log data which can be very useful when debugging.  Of course it's also possible to use kubectl to download logs info if you wanted to rather than just displaying it in the browser.

There is also the ability to use the dashboard to connect to a running container in a pod. This could be useful for debugging, and later on we'll use this to trigger a simulated pod failure when we explore service availability.

</p></details>

---


### Ingress for accepting external data

<details><summary><b>Ingress Intro</b></summary>
<p>

There is one other core service we need to install before we can start running our microservices, the Ingress controller. An Ingress controller provides the actual ingress capability, but it also needs to be configured (we will look at that later.)

An Ingress in Kubernetes is one mechanism for external / public internet clients to access http / https connections (and thus REST API's) It is basically a web proxy which can process specific URL's forwarding data received to a particular microservice / URL on that microservice.

Ingresses themselves are a Kubernetes service, they do however rely on the Kubernetes environment to support a load balancer to provide the external access. As a service they can have multiple instances with load balancing across them etc. as per any other Kubernetes service. 

The advantage of using an ingress compared to a load balancer is that as the ingress understands the payload a single ingress service can support connections to multiple microservices (we'll see more on this later) whereas a load balancer just forwards data on a single port to a specific destination. As commercially offered Kubernetes environments usually charge per load balancer this can be a significant cost saving. However, because it is a layer 7 (http/https) proxy it can't handle raw TCP/UCP connections (for those you need a load balancer)

Though an Ingress itself is a Kubernetes concept Kubernetes does not itself provide a specific Ingress service, it provides a framework in which different Ingress services can be deployed, with the user chosing the service to use. Though it uses the Kubernetes configuration mechanism the actual configuration specifics of an Ingress controller unfortunately very between the different controllers. 

</p></details>

<details><summary><b>Why not use an Ingress for the dashboard</b></summary>
<p>
Normally in a production environment you would use an ingress for the dashbaord rather than setting up (and paying for) a separate load balancer. For this lab however we are using a load balancer because the dashboard uses certificates, and while it is possible to create and install the certificates that takes time (especially if using real, not self-signed certificates)
</p></details>
---


For this lab we're going to use an nginx based Ingress controller. We're doing a quick start here to get you access to you Kubernetes dashboard, but don't worry, we'll explain how all this works in more detail later.

Note that using an ingress for access to the dashboard is not the only way to do this, you might even have seen above that you can use a proxy to get access to the dashbaord. The reason we're using an ingress controller is that it's closer to the way things should work in a production environment. (Though I'm sure in some production environments people take short cuts and use proxies !)

Firstly we need to create a namespace for the ingress controller.

- Run the following command :
  - `kubectl create namespace ingress-nginx`
    ```
    namespace/ingress-nginx created
    ```

**Lab version differences, you must do one of these options**
<details><summary><b>If you are using a client virtual machine for **this** section of the lab (either in an oracle provided or your own tenancy)</b></summary>
<p>
- Run the following command : 

- Install **ingress-nginx** using Helm 3:
  -  `helm3 install ingress-nginx stable/nginx-ingress  -n ingress-nginx --set rbac.create=true`
</p></details>

<details><summary><b>If you are using the OCI Cloud shell for **this** section of the lab (either in an oracle provided or your own tenancy)</b></summary>

- Run the following command : 

- Install **ingress-nginx** using Helm 3:
  -  `helm install ingress-nginx stable/nginx-ingress  -n ingress-nginx --set rbac.create=true`
</p></details>

Whichever option you chose the output will be similar to this :

```
NAME: ingress-nginx
LAST DEPLOYED: Fri Mar 20 14:33:47 2020
NAMESPACE: ingress-nginx
STATUS: deployed
REVISION: 1
TEST SUITE: None
NOTES:
The nginx-ingress controller has been installed.
It may take a few minutes for the LoadBalancer IP to be available.
You can watch the status by running 'kubectl --namespace ingress-nginx get services -o wide -w ingress-nginx-nginx-ingress-controller'
<Additional output>
```
This will install the ingress controller in the default namespace.

Because the Ingress controller is a service,  to make it externally available it still needs a load balancer with an external port.  This is not provided by Kubernetes, instead Kubernetes requests that the external framework delivered by the environment provider create a load balancer. Creating such a load balancer *may* take some time for the external framework to provide. 

- To see the progress in creating the Ingress service type :
  -  `kubectl --namespace ingress-nginx get services -o wide ingress-nginx-nginx-ingress-controller`

```
NAME                                     TYPE           CLUSTER-IP     EXTERNAL-IP   PORT(S)                      AGE   SELECTOR
ingress-nginx-nginx-ingress-controller   LoadBalancer   10.111.0.168   136.23.44.21 80:31934/TCP,443:31827/TCP   61s   app=nginx-ingress,component=controller,release=ingress-nginx
```
In this case we can see that the load balancer has been created and the external-IP address is available.


### Running your containers in Kubernetes

You now have the basic environment to deploy services, and we've looked at how to use the Kubernetes dashboard and the kubectl command line.

- Create a namespace and set the environment, to make it easier we have created a script called create-namespce.sh that does this for you. You must use **your initials** as a parameter (here the example uses tg as initials)
  -  `cd helidon-kubernetes/base-kubernetes`
  -  `bash create-namespace.sh tg-helidon`

```
Deleting old tg-helidon namespace
Creating new tg-helidon namespace
namespace/tg-helidon created
Setting default kubectl namespace
Context "docker-desktop" modified.
```
The script tries to delete any existing namespace with that name, creates a new one, and sets it as a default.

We can check the namespace has been created by listing all namespaces:

-  `kubectl get namespace`

```
NAME              STATUS   AGE
default           Active   2d23h
docker            Active   2d23h
kube-node-lease   Active   2d23h
kube-public       Active   2d23h
kube-system       Active   2d23h
tg-helidon        Active   97s
```
If we look into the namespace we've just created we'll see it contains nothing yet:

-  `kubectl get all`

```
No resources found in tg-helidon namespace.
```

---


<details><summary><b>Details on the script used</b></summary>
<p>
Firstly if you are running on a shared cluster you need to create a namespace, this is basically a "virtual" cluster that let's us separate out services from others that may be running in the cluster. If you have your own cluster it's still a good idea to have your own namespace so you can separate the lab from other activities in the cluster, letting you easily see what's happening in the lab and also no interfering with other cluster activities, and also easily delete it if needs be (deleting a namespace deletes everything in it)

The following command will create a namespace (don't actually do this)

```
$ kubectl create namespace <my namespace name>
```

We list available namespaces using kubectl

```
$ kubectl get namespace
NAME              STATUS   AGE
default           Active   2d23h
docker            Active   2d23h
kube-node-lease   Active   2d23h
kube-public       Active   2d23h
kube-system       Active   2d23h
```


Once you have a namespace you can use it by adding --namespace <my namespace name> to all of your kubectl commands (otherwise the default namespace is used which is called "default".) That's a bit of a pain, but fortunately for us there is a way to tell kubectl to use a different namespace for the default

```
$ kubectl config set-context --current --namespace=<my namespace name>
```

Of course the kubernetes dashboard also understands namespaces. If you go to the dashboard page (http://localhost:8443 assuming you've got the port forwarding running) you can chose the namespace to use (initially the dashboard used the "default" namespace, so if you can't see what you're expecting there remember to change it to the namespace you've chosen. 

</p></details>

---






### Creating Services

The next step is to create services:  a description of a set of microservice instances and the port(s) they listen on. 

<details><summary><b>Explaining the service concept in Kubernetes</b></summary>
<p>

A service effectively defines a logical endpoint that has a internal dns name inside the cluster and a virtual IP address bound to that name to enable communication to a service. It's also internal load balancer in that if there are multiple pods for a service it will switch between the pods, and also will remove pods from it's load balancer if they are not operating properly (We'll look at this side of a service later on.)

Services determine what pods they will talk to using selectors. Each pod had meta data comprised of multiple name / value pairs that can be searched on (e.g. type=dev, type=test, type=production, app=stockmanager etc.) The service has a set of labels it will match on (within the namespace) and gets the list of pods that match from kubernetes and uses that information to setup the DNS and the virtual IP address that's behind the DNS name. The Kubernetes system uses a round robin load balancing algorithm to distribute requests if there are multiple pods with matching labels that are able to accept requests (more on that later) 

Services can be exposed externally via load balancer on a specific port (the type field is LoadBalancer) or can be mapped on to an external to the cluster port (basically it's randomly assigned when the type is NodePort) but by default are only visible inside the cluster (or if the type is ClusterIP.) In this case we're going to be using ingress to provide the access to the services from the outside world so we'll not use a load balancer.

The helidon-kubernetes/base-kubernetes/servicesClusterIP.yaml file defined the services for us. Below is the definition of the storefront service (the file also defines the stock manager and zipkin servcies as well)

```
apiVersion: v1
kind: Service
metadata:
  name: storefront
spec:
  type: ClusterIP
  selector:
    app: storefront
  ports:
    - name: storefront
      protocol: TCP
      port: 8080
    - name: storefront-mgt
      protocol: TCP
      port: 9080
```

We are using the core api to create an object of type Service. The meta data tells us we're naming it storefront. The spec section defines what we want the service to look like, in this case it's a ClusterIP, so it's not externally visible. The selector tells us that any pods with a label app and a value storefront will be considered to be part of the service (in the namespace we're using of course.) Lastly the network ports offered by the service are defin, each has a name and also a protocol and port. By default the port applies to the port the pods actually provide the service on as well as the port the service itself will be provided on. It's possible to have these on differing values if desired (specify the targetPort label for the port definition) 

These could of course be manually specified using a kubectl command line.

***Important***
You need to define the services before defining anything else (e.g. deployments, pods, ingress rules etc.) that may use the services, this is especially true of pods which may use the DNS name created by the service as otherwise those dependent pods may fail to start up.



</p></details>

---


The servicesClusterIP.yaml file in the defines the cluster services for us. We can apply it to make the changes

- `kubectl apply -f servicesClusterIP.yaml`

```
service/storefront created
service/stockmanager created
service/zipkin created
```

Note that the service defines the endpoint, it's not actually running any code for your service yet.

To see the services we can use kubectl :

- `kubectl get services`

```
NAME           TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)             AGE
stockmanager   ClusterIP   10.110.57.74    <none>        8081/TCP,9081/TCP   2m15s
storefront     ClusterIP   10.96.208.163   <none>        8080/TCP,9080/TCP   2m16s
zipkin         ClusterIP   10.106.227.57   <none>        9411/TCP            2m15s
```

The clusterIP is the virtual IP address assigned in the cluster for the service, note there is no external IP as we haven't put a load balancer in front of these services. The ports section specified the ports that the service will use (and in this case the target ports in the pods)

We can of course also use the kuberntes dashboard. Open the dashboard and make sure that the namespace it correctly selected, then click the services in the Discovery and Load Balancing section on the left menu. Basically the same information is displayed.

If however you click on the service name in the services list in the dashboard you'll see that there are no endpoints, or pods associated with the service. This is because we haven't (yet) started any pods with labels that match those specified in the selector of the services.

### Accessing your services using an ingress
<details><summary><b>Introduction</b></summary>
<p>

Services can configure externally visible  load balancers for you, however this is not recommended for several reasons if using REST type access. 

Firstly the load balancers that are created are not part of kubernetes, the service needs to communicate with the external cloud infrastructure to create them, this means that the cloud needs to provide load balancers and drivers for kubernetes to configure them, not all clouds may provide this in a consistent manner, so you may get unexpected behavior.

Secondly the load balancers are at the port level, this is fine if you are dealing with a TCP connection (say a JDBC driver) however it means that you can't inspect the data contents and take actions based on it (for example requiring authentication)

Thirdly most cloud services charge on a per load balancer basis, this means that if you need to expose 10 different REST endpoints you are paying for 10 separate load balancers

Fourthly from a security perspective it means that you can't do things like enforcing SSL on your connections, as that's done at a level above TCP/IP

Fortunately for REST activities there is another option, the ingress controller. This can service multiple REST API endpoints as it operates at the http level and is aware of the context of the request (e.g. URL, headers etc.) The downside of an ingress controller is that it does not operate on non http / https requests

***Update***
Saying that an ingress cannot handle TCP / UDP level requests is actually a slight lie, in more recent versions of the nginx ingress controller it's possible to define a configuration that can process TCP / UDP connections and forward those untouched to a service / port. This is however not a standard capability and needs to be configured separately with specific IP addresses for the external port defined in the ingress configuration. However, different ingress controllers will have different capabilities, so you can't rely on this being the case with all ingress controllers.

</p></details>

---



We have already installed the Ingress controller which actually operates the ingress service. You can see this by looking at the services.  The ingress service is in this case cluster-wide so it's in the default namespace, so we have to specify that :

-  `kubectl get services -n ingress-nginx`

```
NAME                                          TYPE           CLUSTER-IP      EXTERNAL-IP   PORT(S)                      AGE
ingress-nginx-nginx-ingress-controller        LoadBalancer   10.111.0.168    132.18.12.23  80:31934/TCP,443:31827/TCP   4h9m
ingress-nginx-nginx-ingress-default-backend   ClusterIP      10.108.194.91   <none>        80/TCP                       4h9m
```



- Note the **External IP address** 
- You will need to use this address to access **your** services in the rest of this lab

For the moment there are no actual ingress rules defined yet, we can see this using kubectl:

-  `kubectl get ingress`

```
No resources found in tg-helidon namespace.
```



<details><summary><b>More on Ingress rules</b></summary>
<p>

We need to define the ingress rules that will apply. The critical thing to remember here is that different Ingress Controllers may have different syntax for applying the rules. We're looking at the nginx-ingress controller here which is commonly used, but remember there may be others.

The rules define URL's and service endpoints to pass those URLs to, the URL's can also be re-written if desired.

An ingress rule defines a URL path that is looked for, when it's discovered the action part of the rule is triggered and that 

There are ***many*** possible types of rules that we could define, but here we're just going to look at two types: Rules that are plain in that the recognize part of a path, and just pass the whole URL along to the actual service, and rules that re-write the URL before passing it on. Let's look at the simpler case first, that of the forwarding.

```
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: zipkin
  annotations:
    # use the shared ingress-nginx
    kubernetes.io/ingress.class: "nginx"
spec:
  rules:
  - http:
      paths:
      - path: /zipkin
        backend:
          serviceName: zipkin
          servicePort: 9411
```

Firstly note that the api here is the extensions/v1beta1 API. In more recent versions of Kubernetes this has been changed to networking.k8s.io/v1beta1 to indicate that Ingress configuration is part of the kubernetes networking features.

The metadata specifies the name of the ingress (in this case zipkin) and also the annotations. Annotations are a way of specifying name / value pairs that can be monitored for my other services. In this case we are specifying that this ingress Ingress rule has a label of kubernetes.io/ingress.class and a value of nginx. The nginx ingress controller will have setup a request inthe Kubernetes infrastructure so it will detect any ingress rules with that annotation as being targeted to be processed by it. This allows us to define rules as standalonw items, without having to setup and define a configuration for each rule in the ingress controller configuration itself. This annotation based approach is a simple way for services written to be cloud native to identify other kubernetes objects and determine how to hendle them, as we will see when we look at monitoring in kubenteres.

The spec section basically defined the rules to do the processing, basically if there's an http connection coming in with a url that starts with /zipkin then the connection will be proxied to the zikin service on port 9411. The entire URL will be forwarded including the /zipkin.

In some cases we don't want the entire URL to be forwarded however, what if we were using the initial part of the URL to identify a different service, perhaps for the health or metrics capabilities of the microservices which are on a different port (http://storefront:9081/health for example) In this case we want to re-write the incomming URL as it's passed to the target

```
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: stockmanager-management
  annotations:
    # use a re-writer
    nginx.ingress.kubernetes.io/rewrite-target: /$2
spec:
  rules:
  - http:
      paths:
        #any path starting with smmtg will have the /smmgt removed before being passed to the service on the specified url
      - path: /smmgt(/|$)(.*)
        backend:
          serviceName: stockmanager
          servicePort: 9081
```

In this case the annotations section is slightly different, it still triggers nginx when the path matches, but it uses a variable so that the URL will be `/` followed by whatever matches the `$2` in the regular expression. The rule itself looks for anything that starts with /smmgt followed by the regexp which matches `/` followed by a sequence of zero or more characters OR the end of the pattern. The regexp will be extracted and substituted for `$2`. The regexp matched two fields, the first match ​`$1` is `(/|$)` which matches either / or no further characters. The 2nd part of the regexp `$2` is `(.*)` which matches zero or more characters (the . being any character and * being a repeat of zero or more).

Thus **/smmgt** will result in a call to `/`, because `$1` matches no characters after /smmgt.  

On the other hand,  **/smmgt/health/ready** will be mapped to **/health/ready** :  the `$1` is `/` and `$2` is `health/ready`, but the rewrite rule puts a / in front of `$2` thus becoming `/health/ready`) 

Note that it is possible to match multiple paths in the same ingress, and they can forward to different ports, however the re-write target (the updated URL) will be the same structure in both cases.

</p></details>

---



- Apply the Ingress Config file : 
  -  `kubectl apply -f ingressConfig.yaml`

```
ingress.extensions/zipkin created
ingress.extensions/storefront created
ingress.extensions/stockmanager created
ingress.extensions/storefront-status created
ingress.extensions/stockmanager-status created
ingress.extensions/stockmanager-management created
ingress.extensions/storefront-management created
```

We can see the resulting ingresses using kubectl

-  `kubectl get ingress`

```
NAME                      HOSTS   ADDRESS   PORTS   AGE
stockmanager              *                 80      47s
stockmanager-management   *                 80      47s
stockmanager-status       *                 80      47s
storefront                *                 80      47s
storefront-management     *                 80      47s
storefront-status         *                 80      47s
zipkin                    *                 80      47s
```
One thing that you may have noticed is that the ingress controller is running in the default namespae, but when we create the rules we are using the namespace we specified (in this case tg_helidon) This is because the rule needs to be in the same namespace as the service it's defining the connection two, but the ingress controller service exists once for the cluster (we could have more pods if we wanted, but for this lab it's perfectly capable of running all we need) We could put the ingress controller into any namespace we chose, kube-system might be a good choice in a production environment. If we wanted different ingress controllers then for nginx at any rate the --watch-namespace option restricts the controller to only look for ingress rules in specific namespaces.

If you look at the rules in the ingressConfig.yaml file you'll see they setup the following mappings

Direct mappings

`/zipkin -> zipkin:9411/zipkin`

`/store -> storefront:8080/store`

`/stocklevel -> stockmanager:8081/stocklevel`

`/sf/<stuff> -> storefront:8080/<stuff> e.g. /sf/status -> storefront:8080/status`

`/sm/<stuff> -> stockmanager:8081/<stuff> e.g. /sm/status -> stockmanager:8081/status`

`/sfmgt/<stuff> -> storefront:9080/<stuff> e.g. /sfmgt/health -> storefront:9080/health`

`/smmgt/<stuff> -> stockmanager:9081/<stuff> e.g. /smmgt/metrics -> stockmanager:8081/metrics`

Notice the different ports in use on the target.

Find the external IP address the ingress controller is running on :

-  `kubectl get service -n ingress-nginx`

```
NAME                                          TYPE           CLUSTER-IP      EXTERNAL-IP   PORT(S)                      AGE
ingress-nginx-nginx-ingress-controller        LoadBalancer   10.111.0.168    132.18.12.23     80:31934/TCP,443:31827/TCP   5h50m
ingress-nginx-nginx-ingress-default-backend   ClusterIP      10.108.194.91   <none>        80/TCP                       5h50m
kubernetes                                    ClusterIP      10.96.0.1       <none>        443/TCP                      3d3h
```

The external-ip will be the public ip address of the load balancer setup for the ingress controller.

Or look up the ingress service in the namespace *'default'* in the dashboard, that will provide links to the ingress (though not the url's).
 The image below was captured from the services page of the Discovery and Load Balancing section of the dashboard. Note that it's on the default dashboard (that being the one the Ingress ***controller*** is running in)

![Ingress controller service endpoints](images/ingress-controller-service-endpoints.png)

We now have a working endpoint, let's try accessing it using curl - expect an error !

-  `curl -i -X GET http://<ip address>/sf`

```
HTTP/1.1 503 Service Temporarily Unavailable
Server: openresty/1.15.8.2
Date: Fri, 27 Dec 2019 18:59:48 GMT
Content-Type: text/html
Content-Length: 203
Connection: keep-alive

<html>
<head><title>503 Service Temporarily Unavailable</title></head>
<body>
<center><h1>503 Service Temporarily Unavailable</h1></center>
<hr><center>openresty/1.15.8.2</center>
</body>
</html>
```

We got a **service unavailable** error. This is because that web page is recognized as an ingress rule, but there are no pods able to deliver the service. This isn't a surprise as we haven't started them yet !

If we tried to go to a URL that's not defined we will as expected get a **404 error**:

-  `curl -i -X GET http://<ip address>/unknowningress`

```
HTTP/1.1 404 Not Found
Server: openresty/1.15.8.2
Date: Fri, 27 Dec 2019 19:03:52 GMT
Content-Type: text/plain; charset=utf-8
Content-Length: 21
Connection: keep-alive

default backend - 404
```

This is being served by the default backeng service that was installed at the same time as the ingress controller. It's possible to [customize the behavior of the default backend](https://kubernetes.github.io/ingress-nginx/user-guide/default-backend/), for example replacing the error page and so on.

For more information on the nginx ingress controller and the different rules types see the [nginx ingress default backend docs page.](https://github.com/kubernetes/ingress-nginx/tree/master/docs)

For see the doc more information on how the regular expressions with with see the [nginx ingress path matching page.](https://kubernetes.github.io/ingress-nginx/user-guide/ingress-path-matching/) 

### Secrets and external configuration

<details><summary><b>Introduction on secrets for Kubernetes</b></summary>
<p>

As when running the docker images we need to specify the external configuration for kubernetes. This is different from when running with docker though, in docker we just reference the local file system, however in kubernetes we don't even know what node a pod will be running on, so we need something different.

Kubernetes has a concept of volumes similar to that of docker in that a volume is something ouside a container that can be made visible inside the container. This might be for persistent storage (for example the tablespace files of a production database should continue existing, even after the pod holding the database has been shutdown) and kubernetes supports many types of sources for the volumes (e.g. nfs, iSCSI and most cloud providers offer storage services particular to their cloud such as the oracle storage service)

There are also configmaps (we'll look at these in a bit) which are basically a JSON or YAML configuration, a map can be created like any other kubernetes object (and it can also be dynamically modified) then made available. For a lot of configuration data held in YAML or json this is a very effective approach as it allows for easy modification and updates (though that can itself of course trigger change management issues)

Some data however probably should not be stored in a visible storage mechanism, or at the very least should not be easy to see (e.g. usernames / password for access controls, database login details etc.) To support this type of configuration data kubernetes supports a special volume type called secrets.  This information is never written to inside kubernetes and is maintained on the kubernetes management nodes as in-memory data. So if your entire management cluster fails for some reason then the secrets will have to be re-created. 

A secret can be mounted into the pod like any other type of volume. They represent a file, ***or*** a directory of files. This means you could have a single secret holding configuration information (for example the configuration file we're using for testing holding the usernames, passwords and roles, or the OJDBC wallet folder which contains a number of files.

Creating a secret is pretty simple, for example (**don't type this**)

```
$ kubectl create secret generic sm-wallet-atp --from-file=confdir/Wallet_ATP
secret/sm-wallet-atp created
```

The stock manager and storefront both require configuration data and the stock manager also requires the database wallet directory. As the configuration data also includes the authentication data I've decided to store some of this into secrets, though in a real situation the configuration information (except for the authentication server details) would probably be stored in a config map rather than a secret. We'll look at config maps later

There are also more specific secrets used for TLS certificates and pulling docker images from private registries, these have additional arguments to the create command. For  example in the labs we are pulling the docker images from a private registry running in the Oracle Cloud, we define a secret called my-docker-reg. This is a special type of secret in that it specifically has attributes for docker images

The following (don't enter it as the details will have changed) sets up the image pull secret my-docker-reg that we use when we define the pods later

-  `kubectl create secret docker-registry my-docker-reg --docker-server=fra.ocir.io --docker-username="oractdemeabdmnative/api.user" --docker-password="abcdefrghijklmnopqrstuvwxyz" --docker-email="user@oracle.com"`

</p></details>

\---

**Lab Setup**

<details><summary><b>If you've done the docker section of the labs</b></summary>
<p>
If you did the docker section of the labs (regardless of if you did it in your own or an oracle provided tenancy) then you will have done a docker login to the OCI Docker Registry, you will have used a token provided to you in the documentation (for oracle provided tenancies) or that you generated yourself (for your own tenancy.)

We will create a Kubernetes secret using the docker details you used, this will let Kubernetes pull the images from the docker registry.

<details><summary><b>If you can't remember your docker login details/b></summary>
<p>
If you are using an oracle provided tenancy then the details required will be in a document provided to you by your instructor

If you are using your own tenancy then you will have followed [these instructions](../../common/GetDockerDetailsForYourTenancy.md) Hopefully you will have saved the data you gathered in a text file, if you didn;t save the user token then you'll have to generate a new one and then re-do the docker login in the helidon environment.
</p>
</details>

- Edit the create-secrets.sh script in the **helidon-kubernetes/base-kubernetes** directory

- Locate the line that looks like the following (the specifics may be different)
  - `kubectl create secret docker-registry my-docker-reg --docker-server=fra.ocir.io --docker-username="tenancy-name/user" --docker-password="abcdefrghijklmnopqrstuvwxyz" --docker-email="you@email.com"`

- Replace the `tenancy-name` with the name of the tenancy, this is either your tenancy name or is specified in the document provided to you by your instructor this will be the same as you used when doing the docker login.

- Replace the `user` with the username, this is either your username (if using your own tenancy) or the one specified in the document provided to you by your instructor (if using an oracle provided tenancy) this will be the same as you used when doing the docker login

- Replace the password (abcdefrghijklmnopqrstuvwxyz above) with the token you have been given in the document provided by your instructor (for an oracle provided tenancy) or the one you generated in the docker section of the labs if using your own tenancy
</p>
</details>

To help you we have created a script called create-secrets.sh which deletes any existing secrets and sets up the secrets (in your chosen namespace.) This is just a convenience script, you could of course create them by hand (look in the script to see what we've done if you like.)

- Make sure you are in the **helidon-kubernetes/base-kubernetes** directory
- Run the following command to create the secrets:
  -  `bash create-secrets.sh`


```
Deleting existing generic secrets
my-docker-reg
Deleting existing store front secrets
sf-conf
Deleting existing stock manager secrets
sm-conf
sm-wallet-atp
Deleted secrets
Secrets remaining in namespace are
NAME                  TYPE                                  DATA   AGE
default-token-7tk9z   kubernetes.io/service-account-token   3      22s
Creating general secrets
my-docker-reg
secret/my-docker-reg created
Creating stock manager secrets
sm-wallet-atp
secret/sm-wallet-atp created
Createing stockmanager secrets
secret/sm-conf-secure created
Creating store front secrets
secret/sf-conf-secure created
Existing in namespace are
NAME                  TYPE                                  DATA   AGE
default-token-7tk9z   kubernetes.io/service-account-token   3      23s
my-docker-reg         kubernetes.io/dockerconfigjson        1      1s
sf-conf-secure        Opaque                                1      0s
sm-conf-secure        Opaque                                2      1s
sm-wallet-atp         Opaque                                7      1s

```

Note that the secrets are now held in kubernetes, if you want to modify them you'll need to update the configuration and then re-create the secrets. When a secrets is modified (and if you've set it up in helidon) then changes to the secret will be reflected as changes in the configuration. Depending on how your code accesses those, the change may be picked up by your existing code, or you may need to restart the pod(s) using the secrets.

Listing the secrets is simple:

-  `kubectl get secrets`

```
NAME                  TYPE                                  DATA   AGE
default-token-7tk9z   kubernetes.io/service-account-token   3      5m31s
my-docker-reg         kubernetes.io/dockerconfigjson        1      5m9s
sf-conf-secure        Opaque                                1      5m8s
sm-conf-secure        Opaque                                2      5m9s
sm-wallet-atp         Opaque                                7      5m9s
```



To see the content of a secret :

-  `kubectl get secret sm-conf-secure -o yaml`

```
apiVersion: v1
data:
  stockmanager-database.yaml: amF2YXg6CiAgICBzcWw6CiAgICAgICAgRGF0YVNvdXJjZToKICAgICAgICAgICAgc3RvY2tMZXZlbERhdGFTb3VyY...
ogSGVsaWRvbkxhYnMKICAgICAgICAgICAgICAgICAgICBwYXNzd29yZDogSDNsaWQwbl9MYWJzCgo=
  stockmanager-security.yaml: c2VjdXJpdHk6CiAgcHJvdmlkZXJzOgogICAgIyBlbmFibGUgdGhlICJBQkFDIiBzZWN1cml0eSBwcm92aWRlciAoY
...  
XIiXQogICAgICAgICAgLSBsb2dpbjogImpvZSIKICAgICAgICAgICAgcGFzc3dvcmQ6ICJwYXNzd29yZCI=
kind: Secret
metadata:
  creationTimestamp: "2019-12-31T20:02:38Z"
  name: sm-conf-secure
  namespace: tg-helidon
  resourceVersion: "481765"
  selfLink: /api/v1/namespaces/tg-helidon/secrets/sm-conf-secure
  uid: 7ef4aaf6-2c08-11ea-bd2b-025000000001
type: Opaque

```

The contents of the secret is base64 encoded, to see the actual content we need to use a base64 decoder : 

-  `echo <your secret payload> | base64 -d -i -`

```
security:
  providers:
    # enable the "ABAC" security provider (also handles RBAC)
    - abac:
    # enabled the HTTP Basic authentication provider
    - http-basic-auth:
        realm: "helidon"
        users:
          - login: "jack"
            password: "password"
            roles: ["admin"]    
          - login: "jill"
            password: "password"
            roles: ["user"]
          - login: "joe"
            password: "password"
```
The dashboard is actually a lot easier in this case. 

- In the dashboard click on the secrets page in the Config and Store section of the left hand menu.
- Select the sf-conf entry to see the list of files in the secret
- Click on the eye icon next to the storefront-security.yaml to see the contents of the secret.



### Config Maps

<details><summary><b>Intro on Config Maps</b></summary>
<p>

Secrets are great for holding information that you don't want written visibly in your cluster, and you need to keep secret. But the problem with them is that if all the cluster management goes down then the secrets are lost and will need to be recreated. Note that some kubernetes implementations (the docker / kubernetes single node cluster on my laptop for example) do actually persist the secrets somewhere.

For a lot of configuration information we want it to be persistent in the cluster configuration itself. This information would be for example values defining what our store name is, or other information that is not confidential.

There are many ways of doing this, (after all it's just a volume when presented to the pod) but one of the nicer ones is to store a config map into kubernetes, and then make that map available as a volume into the pod.

Creating a config map can be done in many ways, you can specify a set of key / value pairs as a string via the command line, but if you already have the config info in a suitable format the easiest way is to just import the config file as a sequence of characters.

For example (**don't type this**) `$ kubectl create configmap sf-config-map --from-file=projectdir/conf`  would create a secret using the specified directory as a source. A "sub" entry in the config map is created for each file

</p></details>

\---


We need to configure the stockmanager-config.yaml file. You need to do this even if you have done the Helidon labs as the set of configuration data downloaded into the Cloud shell is generic and does not include the customizations you made in the Helidon labs 

- Navigate into the folder helidon-labs-stockmanager/**conf**
- Open the file **stockmanager-config.yaml**
- In the `app:` section, add a property **department** with **your** your name, initials or something that's going to be **unique**:
  -  `department: "your_name"`

Example :

```
app:
  persistenceUnit: "HelidonATPJTA"
  department: "just_a_name"
```


\---

In the helidon-kubernetes/base-kubernetes folder there is a script create-configmaps.sh. We have created this to help you setup the configuration maps (though you can of course do this by hand instead of creating a script.) If you run this script it will delete existing config maps and create an up to date config for us :

-  `bash create-configmaps.sh `

```
Deleting existing config maps
sf-config-map
configmap "sf-config-map" deleted
sm-config-map
configmap "sm-config-map" deleted
Config Maps remaining in namespace are
No resources found in tg-helidon namespace.
Creating config maps
sf-config-map
configmap/sf-config-map created
sm-config-map
configmap/sm-config-map created
Existing in namespace are
NAME            DATA   AGE
sf-config-map   2      0s
sm-config-map   2      0s

```

To get the list of config maps we need to ask kubectl or look at the config maps in the dashbaord:

-  `kubectl get configmaps`

```
NAME            DATA   AGE
sf-config-map   2      37s
sm-config-map   2      37s
```

We can get more details by getting the data in JSON or YAML, in this case I'm extracting it using YAML as that's the origional data format:

-  `kubectl get configmap sf-config-map -o=yaml`

```
apiVersion: v1
data:
  storefront-config.yaml: |-
    app:
      storename: "My Shop"
      minimumdecrement: 3

    #tracing:
    #  service: "storefront"
    #  host: "zipkin"
  storefront-network.yaml: "server:\n  port: 8080\n  host: \"0.0.0.0\"\n  sockets:\n
    \   admin:\n      port: 9080\n      bind-address: \"0.0.0.0\"\n\nmetrics:\n  routing:
    \"admin\"\n\nhealth:\n  routing: \"admin\"\n  \n"
kind: ConfigMap
metadata:
  creationTimestamp: "2019-12-31T20:09:58Z"
  name: sf-config-map
  namespace: tg-helidon
  resourceVersion: "482505"
  selfLink: /api/v1/namespaces/tg-helidon/configmaps/sf-config-map
  uid: 84cdf8f5-2c09-11ea-bd2b-025000000001
```

As we'll see later we can also update the text by modifying the file and re-creating the config map, or using the dashboard to edit the YAML representing the config map.



### Deploying the actual microservices

It's been quite a few steps (many of which are one off and don't have to be repeated for each application we want to run in Kuberntes) but we're finally ready to create the deployments and actually run our Helidon microservices inside of Kubernetes!

<details><summary><b>About the deploymets</b></summary>
<p>

A deployment is the microservice itself, this is a replica set containing one or more pods. The deployment itself handles things like rolling upgrades by manipulating the replica sets. A replica set is a group of pods, it will ensure that if a pod fails (the program stops working) that another will be started. It's possible to add and remove replicas form a pod, but the key thing to note is that all pods within a replica set are the same. Finally we have the pods. In most cases a pod will contain a single user container (based on the image you supply) and if the container exits then a new one will be started. Pods may also contain kubernetes internal containers (for example to handle network redirections) and also pods can contain more than one user container, for example in the case of a web app a pod may have one container to operate the web app and another for a web server delivering the static content.

Pods are monitored by services so that a service will direct traffic to pod(s_ that have labels (names / values) which match those specified in the services selector. If there are multiple pods matching then the Kubernetes netowrking layer switched between them, usually with a round robin approach (at least until we look at health and readiness !)

The stockmanager-deployment.yaml, storefront-deployment.yaml and zipkin-deployment.yaml files contain the deployments. These files are in the helidon-kubernetes folder (***not*** the base-kubernetes folder) The following is the core contents of storefront-deployment.yaml file (actually the file has substantial amounts of additional content that is commented out, but we'll get to that when we look at other parts of the lab later on, If you do look at the file itself for now ignore everything that's commented out with #)

```
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: storefront
```
As with most kubenetes config files there is a first section that defines what we are creating (in this case a deployment names storefront) The deployment actually contains elements defining the replica sets the deployment contains, and what the pods will look like. These can all be defined in separate config files if desired, but as they are very closely bound together it's easiest to define them all in a single file.

```
spec:
  replicas: 1 
  selector:
    matchLabels:
      app: storefront
```
The `spec:` section defines what we want created. Replicas means how many pods we want creating in the replica set, in this case 1 (we will look at scaling later) the selector match labels specifies that and pods with label app:storefront will be part of the deployment.

```
  template:
    metadata:
      labels:
        app: storefront
```
The template section defines what the pods will look like, it starts by specifying that they will all "app:storefront" as a label


```
    spec:
      containers:
      - name: storefront
        image: fra.ocir.io/oractdemeabdmnative/tg_repo/storefront:0.0.1
        imagePullPolicy: IfNotPresent
        ports:
        - name: service-port
          containerPort: 8080
        - name: health-port
          containerPort: 9080
```
The spec section in the template is the specification of the pods, it starts out by specifying the details of the pods and the details of the containers that comprise them, in this case the pod names, the location of the image and how to retrieve it. It also defines the ports that will be used giving them names (naming is not required, but it helps to make it clear what's what.)

*** IMPORTANT ***
These files refer to the location in the docker repo that *I* used when setting up the labs. You are probably pushing to a different docker repo, so you'll need to edit the deployment files to reflect this diffrent image location !

```       
        resources:
          limits:
            # Set this to me a quarter CPU for now
            cpu: "250m"
```
The resources provides a limit for how much CPU each instance of a pod can utilize, in this case 250 mili CPU's or 1/4 whole CPU (the exact definition of what comprises a CPU will vary between kubernetes deployments and by provider.)

```         
        volumeMounts:
        - name: sf-conf-secure-vol
          mountPath: /confsecure
          readOnly: true
        - name: sf-config-map-vol
          mountPath: /conf
          readOnly: true
```
We now specify what volumes will be imported into the pods. Note that this defines what volume is connected the pod, the volume definitions themselves are later, in this case the contents of the sf-config-map-vol volume will be mounded on /conf and sf-config-secure-vol on /confsecure

Both are mounted read only as there's no need for the programs to modify them, so it's good practice to make sure that can't happen accidensally (or deliberately if someone hacks into your application and tries to use that as a way to change the config.)



```
      volumes:
      - name: sf-conf-secure-vol
        secret:
          secretName: sf-conf-secure
      - name: sf-config-map-vol
        configMap:
          name: sf-config-map
```
We define what each volume is based on, in this case we're saying that the volume sf-config-secure-vol (referenced earlier as being mounted on to /confsecure) has a source based on the secret called sf-conf-secure. the volume sf-config-map-vol (which is mounted onto /conf) will containe the contents of the config map sf-config-map There are many other different types of volume sources, including NFS, iSCSI, local storage to the kubernetes provider etc.

```
      imagePullSecrets:
      - name: my-docker-reg
```

We need to tell Kubernetes what secret to use when retrieving the docker images from the repository, the imagePullSecrets key allows us to pass this information on. 


To deploy the config file we would just use kubectl to apply it with a command that looks like  `$ kubectl apply -f mydeployment.yaml` ' (**example, don't type it**)



</p></details>

\---


The script deploy.sh will apply all three deployment configuration files (storefront, stockmanager, zipkin) for us. 

*** IMPORTANT ***
The config files of the storefront and stockmanager refer to the location in the docker repo and any security keys that you used when setting up the labs.   So you'll need to edit the deployment files to reflect this.

**Lab setup**
<details><summary><b>If you have done the docker section of the labs (using your own tenancy or an oracle provided one)<b></summary>
<p>

- Make sure you are in the folder **workspace/helidon-kubernetes**

  - You need to move up one level : `cd ..`

- Open the file **stockmanager-deployment.yaml** 

  - Edit the line specifying the image to reflect *your* docker image location.  The example below shows the config if you chose *tg_repo* as the name, but of course you will have chosen something different !

    ```
    spec:
          containers:
          - name: stockmanager
            image: fra.ocir.io/oractdemeabdmnative/tg_repo/stockmanager:0.0.1
    ```

- Repeat this operation for the file **storefront-deployment.yaml**
  
  - Edit the line specifying the image to reflect *your* docker image location.

</p></details>


<details><summary><b>If did not do the docker section of the labs<b></summary>
<p>
- Make sure you are in the folder **workspace/helidon-kubernetes**

  - You need to move up one level : `cd ..`

- Open the file **stockmanager-deployment.yaml** 

  - Edit the line specifying the image to reflect the following docker image location.

    ```
    spec:
          containers:
          - name: stockmanager
            image: fra.ocir.io/oractdemeabdmnative/h-k8s_repo/stockmanager:0.0.1
    ```

  - Locate **and remove** the `imagePullSecrets` lines. They will look like the following and are at the end of the file

    ```imagePullSecrets:
      - name: my-docker-reg
    ```
We don't need an image pull secret as the files are in a public location

- Repeat this both steps for the file **storefront-deployment.yaml**
  
  - Edit the line specifying the image to reflect fra.ocir.io/oractdemeabdmnative/h-k8s_repo as the docker image location.
  
  - Remove the `imagePullSecrets` lines
  

</p></details>

- Now run the deploy.sh script
  -  `./deploy.sh`

```
Creating zipkin deployment
deployment.extensions/zipkin created
Creating stockmanager deployment
deployment.extensions/stockmanager created
Creating storefront deployment
deployment.extensions/storefront created
Kubenetes config is
NAME                               READY   STATUS              RESTARTS   AGE
pod/stockmanager-d6cc5c9b7-bbjdp   0/1     ContainerCreating   0          0s
pod/storefront-68bbb5dbd8-vp578    0/1     ContainerCreating   0          0s
pod/zipkin-88c48d8b9-sxhcx         0/1     ContainerCreating   0          0s

NAME                   TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)             AGE
service/stockmanager   ClusterIP   10.110.57.74    <none>        8081/TCP,9081/TCP   2d
service/storefront     ClusterIP   10.96.208.163   <none>        8080/TCP,9080/TCP   2d
service/zipkin         ClusterIP   10.106.227.57   <none>        9411/TCP            2d

NAME                           READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/stockmanager   0/1     1            0           0s
deployment.apps/storefront     0/1     1            0           0s
deployment.apps/zipkin         0/1     1            0           0s

NAME                                     DESIRED   CURRENT   READY   AGE
replicaset.apps/stockmanager-d6cc5c9b7   1         1         0       0s
replicaset.apps/storefront-68bbb5dbd8    1         1         0       0s
replicaset.apps/zipkin-88c48d8b9         1         1         0       0s

```

The output includes the results of running the kubectl get all command. As it's been run immediately after we applied the files what we are seeing is the intermediate state of the environment.

---

<details><summary><b>Analyzing the output</b></summary>
<p>

Let's look at the specific sections of the output, starting with the pods 

```
NAME                                READY   STATUS              RESTARTS   AGE
pod/stockmanager-d6cc5c9b7-bbjdp   0/1     ContainerCreating   0          0s
pod/storefront-68bbb5dbd8-vp578    0/1     ContainerCreating   0          0s
pod/zipkin-88c48d8b9-sxhcx         0/1     ContainerCreating   0          0s
```
Shows the pods themselves are in the ContainerCreating state. This is where kubernetes downloads the images from the repo and created the containers. 

Now let's look at the replicasets

```
NAME                                      DESIRED   CURRENT   READY   AGE
replicaset.apps/stockmanager-5b844757df   1         1         0       0s
replicaset.apps/storefront-7cb7c6659d     1         1         0       0s
replicaset.apps/zipkin-88c48d8b9          1         1         0       0s
```
Lists the replica sets that were created for us as part of the deployment. You can see that kubernetes knows we want 1 pod in each replicaset and has done that, though the pods themselves are currently not in a READY state (the containers are being created)

Finally let's look at the deployments

```
NAME                           READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/stockmanager   0/1     1            0           0s
deployment.apps/storefront     0/1     1            0           0s
deployment.apps/zipkin         0/1     1            0           0s
```

This shows us that for the deployments we have 0 pods ready of the target of 1 and that therer are no pods currently available.

```
$ kubectl get all
NAME                               READY   STATUS    RESTARTS   AGE
pod/stockmanager-d6cc5c9b7-bbjdp   1/1     Running   0          3m9s
pod/storefront-68bbb5dbd8-vp578    1/1     Running   0          3m9s
pod/zipkin-88c48d8b9-sxhcx         1/1     Running   0          3m9s

NAME                   TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)             AGE
service/stockmanager   ClusterIP   10.110.57.74    <none>        8081/TCP,9081/TCP   2d
service/storefront     ClusterIP   10.96.208.163   <none>        8080/TCP,9080/TCP   2d
service/zipkin         ClusterIP   10.106.227.57   <none>        9411/TCP            2d

NAME                           READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/stockmanager   1/1     1            1           3m9s
deployment.apps/storefront     1/1     1            1           3m9s
deployment.apps/zipkin         1/1     1            1           3m9s

NAME                                     DESIRED   CURRENT   READY   AGE
replicaset.apps/stockmanager-d6cc5c9b7   1         1         1       3m9s
replicaset.apps/storefront-68bbb5dbd8    1         1         1       3m9s
replicaset.apps/zipkin-88c48d8b9         1         1         1       3m9s
```

If we wait a short time we will find that the images download and the pods are ready.

Is we look at the kubernetes dashboard we will see similar information. There is a bit more information available on the various stages of the deployment, if you chose pods (remember to select the right namespace!) then the pod running the storefront you will see the various steps taken to start the pod including assigning it to the scheduler, downloading the image and creating the container using it.

![The events relating to starting the storefront pod seen in the dashboard](images/storefront-pod-events-history.png)

</p></details>

---



- Now lets look at the logs of the pods you have launched (replace the ID by the exact ID of your pod)
  -  `kubectl logs  --follow storefront-68bbb5dbd8-vp578`

```
2019.12.29 17:40:04 INFO com.oracle.labs.helidon.storefront.Main Thread[main,5,main]: Starting server
2019.12.29 17:40:06 INFO org.jboss.weld.Version Thread[main,5,main]: WELD-000900: 3.1.1 (Final)
2019.12.29 17:40:06 INFO org.jboss.weld.Bootstrap Thread[main,5,main]: WELD-ENV-000020: Using jandex for bean discovery

...

2019.12.29 17:40:13 INFO com.oracle.labs.helidon.storefront.Main Thread[main,5,main]: Running on http://localhost:8080/store
```

- Type **Ctrl-C** to stop kubectl and return to the command prompt.



In the dashboard you can click the logs button on the upper right to open a log viewer page

![The logs from the storefront pod seen in the dashboard](images/storefront-logs-page-startup.png)

We can interact with the deployment using the public side of the ingress (it's load ballancer),  use kubectl to see the public IP address of the ingress controlers load ballancer, or the services section of the dashboard.

- Show the services :
  -  `kubectl get services -n ingress-nginx`

```
NAME                                          TYPE           CLUSTER-IP      EXTERNAL-IP    PORT(S)                      AGE
ingress-nginx-nginx-ingress-controller        LoadBalancer   10.111.0.168    132.145.232.69 80:31934/TCP,443:31827/TCP   2d4h
ingress-nginx-nginx-ingress-default-backend   ClusterIP      10.108.194.91   <none>         80/TCP                       2d4h
```

The External_IP column displays the external address. 

- Let's try to get some data - **you might get an error**
  -  `curl -i -X GET -u jack:password http://132.145.232.69:80/store/stocklevel`

```
HTTP/1.1 200 OK
Server: openresty/1.15.8.2
Date: Sun, 29 Dec 2019 18:05:24 GMT
Content-Type: application/json
Content-Length: 184
Connection: keep-alive

[{"itemCount":100,"itemName":"Book"},{"itemCount":50,"itemName":"Eraser"},{"itemCount":200,"itemName":"Pencil"},{"itemCount":5000,"itemName":"Pin"},{"itemCount":5000,"itemName":"Pins"}]
```

- If you get **424 failed dependency** or timeouts it's because the services are doing their lazy initialization, 
  - Wait a minute or so and retry the request
  
<details><summary><b>If you have not done the Helidon labs (or only get `[]` not a list of items)</b></summary>
<p>
Your database does not have the information that was uploaded in the Helidon part of the labs, or if you did the Helidon labs then you probabaly are using a different department name.

All is not lost, you can create the information easily

- Run the following command, using the ecternal IP address you would have used above
  - `bash create-test-data.sh external_ip_address`
    ```
    Service IP address is 130.61.11.184
    HTTP/1.1 200 OK
    Server: nginx/1.17.8
    Date: Fri, 20 Mar 2020 16:58:24 GMT
    Content-Type: application/json
    Content-Length: 36
    Connection: keep-alive

    {"itemCount":5000,"itemName":"Pins"}HTTP/1.1 200 OK
    
    <Additional lines of output>
    ```

This will populate the database for you so you have some test data.

</p>
</details>

And to see what's happening when we made the request we can look into the pods logs. Here we use --tail=5 to limit the logs output to the last 5 lines of the storefront pod

- Looking at the logs now:
  - kubectl logs storefront-68bbb5dbd8-vp578 --tail=5

```
2019.12.29 18:05:14 INFO com.netflix.config.sources.URLConfigurationSource Thread[helidon-2,5,server]: To enable URLs as dynamic configuration sources, define System property archaius.configurationSource.additionalUrls or make config.properties available on classpath.
2019.12.29 18:05:14 INFO com.netflix.config.DynamicPropertyFactory Thread[helidon-2,5,server]: DynamicPropertyFactory is initialized with configuration sources: com.netflix.config.ConcurrentCompositeConfiguration@51e9668e
2019.12.29 18:05:14 INFO io.helidon.microprofile.faulttolerance.CommandRetrier Thread[helidon-2,5,server]: About to execute command with key listAllStock162356533 on thread helidon-2
2019.12.29 18:05:14 INFO com.oracle.labs.helidon.storefront.resources.StorefrontResource Thread[hystrix-io.helidon.microprofile.faulttolerance-1,5,server]: Requesting listing of all stock
2019.12.29 18:05:24 INFO com.oracle.labs.helidon.storefront.resources.StorefrontResource Thread[hystrix-io.helidon.microprofile.faulttolerance-1,5,server]: Found 5 items
```

- And also on the stockmanager pod
  -  `kubectl logs stockmanager-d6cc5c9b7-bbjdp  --tail=20`

```
$ kubectl logs stockmanager-d6cc5c9b7-bbjdp  --tail=20
http://localhost:8081/stocklevel
2019.12.29 18:05:15 INFO com.arjuna.ats.arjuna Thread[helidon-1,5,server]: ARJUNA012170: TransactionStatusManager started on port 36319 and host 127.0.0.1 with service com.arjuna.ats.arjuna.recovery.ActionStatusService
2019.12.29 18:05:15 INFO com.oracle.labs.helidon.stockmanager.resources.StockResource Thread[helidon-1,5,server]: Getting all stock items
2019.12.29 18:05:15 INFO org.hibernate.jpa.internal.util.LogHelper Thread[helidon-1,5,server]: HHH000204: Processing PersistenceUnitInfo [name: HelidonATPJTA]
2019.12.29 18:05:16 INFO org.hibernate.Version Thread[helidon-1,5,server]: HHH000412: Hibernate Core {5.4.9.Final}
2019.12.29 18:05:16 INFO org.hibernate.annotations.common.Version Thread[helidon-1,5,server]: HCANN000001: Hibernate Commons Annotations {5.1.0.Final}
2019.12.29 18:05:16 INFO com.zaxxer.hikari.HikariDataSource Thread[helidon-1,5,server]: HikariPool-1 - Starting...
2019.12.29 18:05:19 INFO com.zaxxer.hikari.HikariDataSource Thread[helidon-1,5,server]: HikariPool-1 - Start completed.
2019.12.29 18:05:19 INFO org.hibernate.dialect.Dialect Thread[helidon-1,5,server]: HHH000400: Using dialect: org.hibernate.dialect.Oracle10gDialect
2019.12.29 18:05:22 INFO org.hibernate.engine.transaction.jta.platform.internal.JtaPlatformInitiator Thread[helidon-1,5,server]: HHH000490: Using JtaPlatform implementation: [org.hibernate.engine.transaction.jta.platform.internal.JBossStandAloneJtaPlatform]
Hibernate: 
    SELECT
        departmentName,
        itemName,
        itemCount 
    FROM
        StockLevel 
    WHERE
        departmentName='TestOrg'
2019.12.29 18:05:23 INFO com.oracle.labs.helidon.stockmanager.resources.StockResource Thread[helidon-1,5,server]: Returning 5 stock items

```

Here we retrieve the last 20 lines, and can see the connection to the database initializing and then retrieveing the data (Helidon does "lazy" instantiation of the DB connection by default)

Using the logs function on the dashboard we'd see the same output, but you'd probabaly want to set the logs output there to refresh automatically.



As we are runnig zipkin and have an ingress setup to let us access the zipkin pod let's look at just to show it working. 

- Open your browser
- Go to the ingress end point for your cluster, for example http://132.145.232.69/zipkin (replace with *your* Load balancer IP address)

![List of traces in Zipkin](images/zipkin-traces-list.png)

- Select the most recent trace and retrieve the data from that

![Stock listing trace in Zipkin](images/zipkin-trace.png)

Of course the other services are also available, for example we can get the minimum change using the re-writer rules

- Consult minimum change
  -  `curl -i -X GET http://132.145.232.69:80/sf/minimumChange`

```
HTTP/1.1 200 OK
Server: openresty/1.15.8.2
Date: Sun, 29 Dec 2019 18:33:15 GMT
Content-Type: text/plain
Content-Length: 1
Connection: keep-alive

3
```

And in this case we are going to look at data on the admin port for the stock management service and get it's readiness data

- Readiness call: `curl -i -X GET http://132.145.232.69:80/smmgt/health/ready`

```
HTTP/1.1 200 OK
Server: openresty/1.15.8.2
Date: Sun, 29 Dec 2019 18:34:40 GMT
Content-Type: application/json
Content-Length: 164
Connection: keep-alive

{"outcome":"UP","status":"UP","checks":[{"name":"stockmanager-ready","state":"UP","status":"UP","data":{"department":"TestOrg","persistanceUnit":"HelidonATPJTA"}}]}
```

### Changing the configuration
We saw in the helidon labs that it's possible to have the helidon framework monitor the configuration files and triger a refresh of the configuration data if something changed. Let's see how that works in Kubernetes.

- Get the status resource data :
  -  `curl -i -X GET http://132.145.232.69:80/sf/status`

```
HTTP/1.1 200 OK
Server: openresty/1.15.8.2
Date: Sun, 29 Dec 2019 18:32:50 GMT
Content-Type: application/json
Content-Length: 49
Connection: keep-alive

{"name":"My Shop","alive":true,"frozen":false}
```
(assuming your storefront-config.yamp file says the storename is My Shop this is what you should get back, if you changed it it will be slightly different)

We've mounted the sf-config-map (which contains the contents of storefront-config.yaml file) onto /conf1. Let's use a command to connect to the running pod (remember your storefront pod will have a different id so use kubectl get pods to retrieve that) and see how it looks in there, then exit the connection

- Execute these commands :
  -  `kubectl exec -it storefront-588b4d69db-w244b -- /bin/bash`
  - You are now inside the container.  Type the following commands here:
    -  `ls /conf`
    -  `cat /conf/storefront-config.yaml`

    ```
    app:
      storename: "My Shop"
      minimumdecrement: 3

    #tracing:
    #  service: "storefront"
    #  host: "zipkin"
    ```
    
    -  Exit the pod :  `exit`
    
    

As expected we see the contents of our config file. Let's use the dashboard to modify that data

- Open the dashboard
- Select your namespace
- Click on Config Maps in the Config and Storage section of the left menu

![Config Maps list in namespace](images/config-maps-list.png)

- Then click on our config map (sf-config-map) to see the details and contents

![Config Maps details](images/config-map-orig-details.png)

As we'd expect it has our contents (You may have text that doesn't say "My Shop" by instead shows what you edited it to in the helidon labs, if so don't worry)

- Click the **Edit button** (upper right) to get an on-screen editor where we can change the yaml that represents the map. 

![Config Maps in editor](images/config-map-editor-initial.png)

- Locate the **storename** attribute at the bottom of the file. 

- Now edit the text and **change** the *'My Shop'* to something else. Be sure to only change the text, not the quote characters or other things (don't want to create corrupt YAML which will be rejected).



![Config Maps changed in editor](images/config-map-editor-updated.png)

- Click on the update button to save your changes

You'll see the changes reflected in the window. If you made any changes which caused syntax errors then you'll get an error message and the changes will be discarded.

![Config Maps updated details](images/config-map-updated-details.png)

Now let's return to the pod and see what's happened

- Re-connect to the pod: `kubectl exec -it storefront-588b4d69db-w244b -- /bin/bash`
  - In the pod, run : `cat /conf/storefront-config.yaml`

    ```
    app:
      storename: "Tims Shop"
      minimumdecrement: 3
    
    #tracing:
    #  service: "storefront"
    #  host: "zipkin"
    ```

  - Exit the pod :   `exit`

The storefront-config.yaml file has now changed to reflect the modifications you made to the config map. Note that it usually takes between 30 - 60  seconds for the change to propogate into the pod.

If we now get the status resource data again it's also updated

- Query the status: `curl -i -X GET http://132.145.232.69:80/sf/status`

```bash
HTTP/1.1 200 OK
Server: openresty/1.15.8.2
Date: Sun, 29 Dec 2019 21:24:26 GMT
Content-Type: application/json
Content-Length: 48
Connection: keep-alive

{"name":"Tims Shop","alive":true,"frozen":false}
```
Of course there is time delay from the change being visible in the pod to the Helidon framework doing it's scan to detect the change and reloading the config, so yu may have to issue the curl command a few times to see when the change has fully propogated.
We've shown how to change the config in helidon using config maps, but the same principle woudl apply if you were using secrets and modified those (though there isn't really a usable secret editor in the dashboard)









---

You have reached the end of this lab !!

Use your **back** button to return to the **C. Deploying to Kubernetes** section

