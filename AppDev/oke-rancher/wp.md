## Welcome to Part 3 - Installing Wordpress deployment on OKE using Rancher ##
 
Now that we have Rancher installed, and an OKE cluster created, 
we can simplify the deployments of different apps/storage/services and more.. 

In this part we are going to install Wordpress, and see how simple it is.
let's get started. 

First thing we are going to do is to access our created cluster. 

![image](https://github.com/deton57/oke-labs/blob/master/oke-rancher/screenshots/part3/Access-Cluster.PNG)

Now we see that we have different projects and namespaces on our system,
they are default as this is a new cluster and nothing is created. 

## Creating a project ##

Let's start by creating a new project. 
Click on the "Add Project" button. 

![image](https://github.com/deton57/oke-labs/blob/master/oke-rancher/screenshots/part3/Projects%20and%20namespaces.PNG)

Name it "wordpress", and click on the "Create" button.

![image](https://github.com/deton57/oke-labs/blob/master/oke-rancher/screenshots/part3/project-creation.PNG)

Now let's access the project from the top menu. 

![image](https://github.com/deton57/oke-labs/blob/master/oke-rancher/screenshots/part3/access-project.PNG)

## Creating your first app ##

Next, navigate to "Apps" from the top menu.

![image](https://github.com/deton57/oke-labs/blob/master/oke-rancher/screenshots/part3/apps.PNG)

and click on "Launch" on the left side of the screen.

Rancher has a rich app catalog, that can be easily deployed on your Kubernetes cluster.
let's search for "wordpress" using the search bar on the right corner. 

![image](https://github.com/deton57/oke-labs/blob/master/oke-rancher/screenshots/part3/app-catalog.PNG)

Once you've found it, let's click on it. 

![image](https://github.com/deton57/oke-labs/blob/master/oke-rancher/screenshots/part3/wordpress.PNG) 

In the following deployment you have 3 placeholders for password input,
let's input a password: **WPRancher321!** (you can use your own/auto-generated) 

![image](https://github.com/deton57/oke-labs/blob/master/oke-rancher/screenshots/part3/passwords.PNG)

Scroll down, and click on the "Launch" button. 
This will take a few moments..

Congratulations!
you have deployed your first app on Rancher (in this lab, of course)

![image](https://github.com/deton57/oke-labs/blob/master/oke-rancher/screenshots/part3/ready-deployment.PNG)

Let’s give it a try and see some features that Rancher offer us. 
First, let's click on the deployment on the word "wordpress". 

In the next screen you will see endpoints you can access,
this is a website you have deployed by a few clicks. 
you can click on one of the endpoints to access your website:

![image](https://github.com/deton57/oke-labs/blob/master/oke-rancher/screenshots/part3/endpoints.PNG)

And this is your Wordpress website:

![image](https://github.com/deton57/oke-labs/blob/master/oke-rancher/screenshots/part3/wordpress-website.PNG)

The IP address you see, is a provisioned Load Balancer,
Kubernetes can provision a Load Balancer per each service/ingress. 

The big advantage of Rancher is that it manages all the different Kubernetes resources,
in an easy way. Per the deployment, you can see all the Kubernetes resources such as:
Volumes, Secrets, Configmaps, Ingresses, Services and everything you need. 

## Check the deployment from OCI and OKE ##

Let's view the deployment on the OCI OKE side now. 

Open OCI Console 
Go to the left menu > Developer Services > Container Cluster OKE

![image](https://github.com/deton57/oke-labs/blob/master/oke-rancher/screenshots/part3/oke-oci.PNG)

Click on your OKE cluster

![image](https://github.com/deton57/oke-labs/blob/master/oke-rancher/screenshots/part3/click-on-oke.PNG)

On the top menu click on the Cloud Shell icon,
wait a few moments while it opens. meanwhile at the same time, click on the "Access Cluster" button.


![image](https://github.com/deton57/oke-labs/blob/master/oke-rancher/screenshots/part3/access-cluster-cloudshell.PNG)

The OCI Cloud Shell is a great tool, it gives you a cloud terminal window,
where it has all the tools you need to manage and deploy on your cloud.

The tools we need now is OCI CLI and Kubectl commands, in order to create the kubeconfig file
and access it. 

When the Cloud Shell comes up, copy and paste the command:

![image](https://github.com/deton57/oke-labs/blob/master/oke-rancher/screenshots/part3/copy-paste-cloud-shell.PNG) 

If you did it correctly, you should get the following response:
```Existing Kubeconfig file found at /home/account/.kube/config and new config merged into it```

Now, from your Cloud Shell, run the following command:

```kubectl get ns```

This will retrieve a list of all the created namespaces on your OKE cluster.

```
NAME              STATUS   AGE
cattle-system     Active   11h
default           Active   11h
kube-node-lease   Active   11h
kube-public       Active   11h
kube-system       Active   11h
wordpress         Active   20m
```

You can see that the wordpress namespace have been created. 
I did this part of the lab a bit later, so ignore the time differences. 

Now let's verify that we have all what we created from Rancher, by running the following command:

```kubectl get all -n wordpress```

the output should be like in the example:

```
NAME                             READY   STATUS    RESTARTS   AGE
pod/wordpress-6bcf994cbd-np5nj   1/1     Running   0          21m
pod/wordpress-mariadb-0          1/1     Running   0          21m


NAME                        TYPE           CLUSTER-IP      EXTERNAL-IP       PORT(S)                      AGE
service/wordpress           LoadBalancer   10.96.191.212   158.101.180.218   80:31638/TCP,443:30243/TCP   21m
service/wordpress-mariadb   ClusterIP      10.96.105.44    <none>            3306/TCP                     21m


NAME                        READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/wordpress   1/1     1            1           21m

NAME                                   DESIRED   CURRENT   READY   AGE
replicaset.apps/wordpress-6bcf994cbd   1         1         1       21m

NAME                                 READY   AGE
statefulset.apps/wordpress-mariadb   1/1     21m
```

Note as I mentioned before - you have a Loadbalancer created, with External-IP.
This is the power of running Kubernetes on the Cloud, cause it can provision different resources. 
Let's check our cloud account to see if it's actually created. 


Go to the left menu, click on Networking > Load Balancers

![image](https://github.com/deton57/oke-labs/blob/master/oke-rancher/screenshots/part3/load-balancers.PNG)

I can see that a Load Balancer have been created. 

![image](https://github.com/deton57/oke-labs/blob/master/oke-rancher/screenshots/part3/Load-Balancer-created.PNG)

Let's access it. 
Click on the Load Balancer name.

In the next screen click on the left bottom menu on Backend Sets

![image](https://github.com/deton57/oke-labs/blob/master/oke-rancher/screenshots/part3/lb-backend.PNG)

We can see that it has 2 backend sets, 
and they act as our Wordpress endpoints. 

Congratulations! 
We have done with part 3. 

It's time to continue to our final part for this intro lab. 

[Continue to part 4 Monitoring the cluster and the app](https://github.com/deton57/oke-labs/blob/master/oke-rancher/mon.md) 

If you want to return to the lab homepage, click here: [Back to the general lab section](https://github.com/deton57/oke-labs/blob/master/oke-rancher/readme.md)






