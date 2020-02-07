# Creating your own Kubernetes cluster in the OCI tenancy

You will need to have created (or been allocated) a client VM instance. If you have not got one then contact your instructor.

**IMPORTANT** The following steps will need to be performed •within* your client VM instance.

In the client VM open the web browser (double click the Firefox icon on the desktop)

Go the the cloud.oracle.com page (making choices about cookies as you see fit)

Click the "View Accounts" button on the upper right of the page

In the resulting list click the "Sign in to cloud" option

enter the cloud account name (your instructor will provide this)

enter your user name and password (you will have been assigned one or these are the details you provided when you use the self-registration tool and did the initial login)

Once you have signed in you may find yourself on the Clout Infrastructure Classic page. If you do click the "Infrastructure" link just to the right of the heading on the page (you may be asked to provide the cloud details and re-authenticate again, if you are please ensure you chose the Single Sign On / SSO option when you've provide the tenancy information)

Once you have signed in the the OCI infrastructure click on the hamburger menu (three bars on the upper left) Go dowen the menu until you get th the Solutions and Platform section, then click on the Developer services -> Container Clusters (OKE) option

In the List Scope section use the dropdown to select CTDOKE as the compartment (you may have to expand the tree nodes to locate this) Click the "Create Cluster" button at the top of the clusters list

Take the option for the "Quick Create" (this provides automatic versions of most of the key elements for you) then click the "Launch workflow" button

In the next form name the cluster something like LAB-<your initials>-Helidon-Cluster (you can of course use anything you like instead of <your initials> as long as it's unique)

Make sure the compartment is CTKOKE

Make sure the Kubernetes version is the highest on the list (currently 1.14.8)

Leave the visibility type as private

Leave the shape as VM.Standard1.1

Set the number of nodes to be 1

**TURN OFF** the Add Ons, make sure that the sliders for both Kubernetes Dashboard Enabled and Tiller (Helm) Enabled are grey ("switch" to the left")

Click the Next button to go to the review page.

On the review page check the details you have provided are there, then click the Create Cluster button.

You'll be presented with a progress option, if you want read what's happening, but scroll to the bottom of it and click the Close button which will take you to the instance page for your cluster.

The state will be "Creating" for a few mins (usually 3-4 mins)

Once the cluster has been created the "Accesss Kubeconfig" button will be enabled. Click it to get the configuration for **your** cluster. Remember you need to be doing this in your client VM (it has sll of the other items needed), no point in downloading the kube config anywhere else !

You will be presented with a page with detial of downloading the Kubeconfig file. The main thing is to look for the line like this. Copy the line (your's not the one) by selecting the test starting with the OCI and ending in the token version. Then click right and chose copy. In a terminal run the command it says to get the config

```
oci ce cluster create-kubeconfig --cluster-id ocid1.cluster.oc1.eu-frankfurt-1.aaaa<lots of stuff>aaa --file $HOME/.kube/config --region eu-frankfurt-1 --token-version 2.0.0
New config written to the Kubeconfig file /home/oracle/.kube/config
```

Make sure you can access the cluster using the `kubectl get all` command

```
kubectl get all
NAME                 TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)   AGE
service/kubernetes   ClusterIP   10.96.0.1    <none>        443/TCP   13m
```