Now we have our build process producing artifacts it's time to look at how we deploy them to our Oracle Kubernetes Engine (OKE)

For the purposes of this lab you must have previously created the OKE environment and got the Storefront and Stockmanager services running in it, connected to an Oracle Database, you may have done this by following the steps in the related Kubernetes lab, or by using the quick setup scripts as described in the setup for this lab.

In this deployment section we will create a deployment pipeline which will deploy the Storefront service (in the artifacts we've just built) into the OKE environment, replacing the one that already exists in the OKE cluster.

Note - Why are re not using the deployment pipelines to deploy the entire services stack ?
There are a few reasons, firstly there are several elements to the already existing deployment (for example the database wallet secrets) which are unique to each user and are potentially shared across services. While we absolutely could setup vault secrets with each of files in the database wallet and then setup a config map that of course would result in the vault secrets being tied to the deployment (and having to maintain and update them as the database access credentials changed over time)
The next reason is that the configuration information may well need to be updated independently of deploying new versions of the code, for example configuring destinations for tracing.
Another reason specifically to do with the database is that with the Oracle Service Operator for Kubernetes you would dynamically retrieve the database configuration, and thus there would be no need to bring it in as part of each individual deployment, admittedly the service operator manifest used to identify the database could be part of a deployment.
However for this lab the main reason is that this lab is part of a larger set of interconnected labs, and in those we show how to install the database credentials as a Kubernetes secret, and I need to maintain consistency between the labs.

 Before we can create a deployment pipeline we need to create a target for the deployment, this is called an environment. The OCI DevOps service can currently deploy into instance groups (VM / Bare metal), Oracle Functions and Oracle Kubernetes Engine. In this lab we're going to use OKE.
 
 Navigate to your devops projects home page (Hamburger menu -> Developer Services -> Projects (Under DevOps) -> Chose your project from the list)
 
 In the **Resources** menu on the left of the page click **Environments** to go to the Environments page
 
 Click the **Create environment** to open the Create environment form
 
 Select **Oracle Kubernetes Enmgine**
 
 Name this `<YOUR INITIALS`_OKE in my case that's going to be `TG_OKE` but of course you probably have different initials than I do, so remember to use yours!
 
 If you like add a description of your choice
 
 Click **Next** at the bottom of the form to progress to the next page.
 
 On the **Environment details** page select the region your OKE cluster is in, this is probably the region you're already using and it may already have been selected as the default
 
 Check that the **Compartment** is the compartment you are using for the OKE cluster - this should be the same as the one you're using for this lab
 
 Click `Select a cluster` in the **Cluster**  field and chose your OKE cluster, remember that in some labs there may be multiuple people using the same environment, so be sure to double check it's your cluster, not someone elses
 
 Click **Create environment** at the bottom of the page, after a short while you will be taken to the page for this environment.
 
 Using the breadcrumbs at the top of the page return to your project by clicking on it's name
 
 In the left menu (Resources) click on **Deployment Pipelines**
 
 On the Deployment pipelines page click **Create pipeline**
 
In the popout window 

Name your pipeline `StorefrontDeploy`

Give it a description if you want

Ensure that the pipeline type is **Create a deployment** (currently there is only one option anyway, so this should be selected)


Click the **Create pipeline** button at the bottom to create the pipeline and take you to it's page.

We are going to create two deployment stages to deploy the storefront project.

The first stage will do the actual OKE deployment, and also create an OKE service object that matches to the deployment

The next stage will (once the deployment is completed) apply the Kubernetes manifest to create the ingress rule. As the ingress rule will route traffic using the service object we have to do this once the service is in place.

Once you are on the Deployment pipeline page click the **+** button (if you can't see this check you are on the **Pipeline** tab) Then in the popeup menu click **Add Stage** to open the Add stage form

In the **Deploy** Section click **Apply manifest to your Kubernetes Cluster** then click **Next** at the bottom of the add stage form.

Name this stage `StorefrontServiceAndDeployDeployment` (it's unwieldy I know, but like good variable names it's helpful to name things by their use)

Add a description if you wish

In the **Environment** field select the environment you created earlier (`<YOUR_INIAIALS>_OKE`) this is the environment the stage will deploy to

Click the **Select Artifact** button and in the resulting popout form select StorefrontDeploymentYAML and StorefrontServiceYAML - notice that both of these have their version specified as `${STOREFRONT_VERSION}` This will be substituted with the value of the variable which will come from the build pipeline phase when we have it trigger the deploy.

Click the **Save changes** button

Leave the **Override Kubernetes namespace** field blank (the YAML files will set this using a build pipeline parameter)

Set the **If validation fails, automatically rollback to the last successful version** option to be `Yes`

Click the **Add** button at the lower left of the page, this will add the stage and return to the pipeline designer.

Note - other types of stage are :
Deploy types Deploy to Oracle Functions and OCI Instance groups (this allows for deployment into virtual machines and bare metal services)
Control types : Pause the deployment for approvals  - allow for a manual approval stage (perhaps to confirm before deploying to a production environment) 
Traffic Shift - when used with a multiple deployment environments with a front end load balancer can gradually shift traffic from one backend to another enabling a controlled rollout
Wait - introduces a delay in the pipeline running, perhaps to enable long running activities in a previous stage to complete
Integrations types : Run a custom logic through a function allows you to trigger external code running using the Oracle Functions service, this could do pretty much anything, for example examining the results of a container image scan to ensure there are no critical vulnerabilityes discovered before processing, or simply triggering an async action to record details of the process


Our stage that applies the manifests for the deployment and service will wait for those actions to complete before completing

Let's add a stage that will deploy the ingress rule to the OKE cluster.

**Below** the stage we just added click the **+** symbol

In the **Deploy** Section click **Apply manifest to your Kubernetes Cluster** then click **Next** at the bottom of the add stage form.

Name this stage `StorefrontIngressDeployment` 

Add a description if you wish

In the **Environment** field select the environment you created earlier (`<YOUR_INIAIALS>_OKE`)

Click the **Select Artifact** button and in the resulting popout form select `StorefrontIngressRuleYAML` - this also uses `${STOREFRONT_VERSION}` to ensure we get the appropriate version for the deployment.

Click the **Save changes** button

Leave the **Override Kubernetes namespace** field blank (the YAML files will set this)

Set the **If validation fails, automatically rollback to the last successful version** option to be `Yes`

Click the **Add** button at the lower left of the page

Now we have our deployment pipeline ready to run, but there are a couple of parameters that we need, specifically `KUBERNETES_NAMESPACE` and `EXTERNAL_IP` Those are very specific to deployments into OKE~, and are not set in the build pipeline - We need to set them.

First we are going to gather the information we need, this will come from using the OCI Cloud shell to run some kubectl commands

Open the OCI Cloud shell if it's not already open, if it's been a while since you previously used it you may need to reconnect.

First we are going to get the value of the `EXTERNAL_IP` This is used to identify the DNS name used by an incoming connection.

In the OCI cloud shell type

`kubectl get services -n ingress-nginx`

```
NAME                                 TYPE           CLUSTER-IP      EXTERNAL-IP      PORT(S)                      AGE
ingress-nginx-controller             LoadBalancer   10.96.182.204   130.162.40.241   80:31834/TCP,443:31118/TCP   2h
ingress-nginx-controller-admission   ClusterIP      10.96.216.33    <none>           443/TCP                      2h
```

Look for the `ingress-nginx-controller` line and note the IP address in the `EXTERNAL-IP` column, in this case that's `130.162.40.121` but it's almost certain that the IP address you have will differ. IMPORTANT, be sure to use the IP in the `EXTERNAL-IP` column, ignore anything that looks like an IP address in any other column as those are internal to the OKE cluster and not used externally. Please save this IP address in a note pad or similar as we will be using this in several times in the remainder of the lab.


Note - why do we need the IP address ?
Normally a DNS name would not include an IP address, but setting up a DNS entry requires several steps, many of which take time, and then setting up a security certificate using it can take longer, especially if you need to prove that you have the authority from your organization do get certificates in their name. 
Because of this in the OKE labs we use a DNS service called nip.io This is basically a special DNS server that doesn't hold any IP to DNS mappings at all, what it does do is look for an IP address in the DNS name it's asked to resolve, and it then returns that as if it were a real DNS mapping. For example if asked to resolve a DNS name of `myservice.123.456.789.123.nip.io` you will have `123.456.789.123` returned for the IP address. 
Doing this does however mean that you do need to include the IP address in the DNS name. As an ingress rule uses DNS names to determine which security certificate to use for the incoming connection, and what hostnames to use when determining where to send an incoming request that of course means that we will need to update the artifact containing the ingress rule (`StorefrontIngressRuleYAML` in this case) with the IP address

Now we are going to get the namespace used by your current deployments, as we are going to be replacing an existing deployment it's critical that we get this correct.

When you did the original Kubernetes lab, or if you used a scripted setup you specified this. To remind you of the options and to confirm your memory we will look at all of the namespaces.

In the OCI Cloud Shell type

`kubectl get namespaces`

```
NAME              STATUS   AGE
default           Active   13d
ingress-nginx     Active   13d
kube-node-lease   Active   13d
kube-public       Active   13d
kube-system       Active   13d
tims              Active   13d
```

In this case the namespace I created is `tims`. If you are in doubt as to which namespace in the list relates to you please ignore any namespace starting with `kube`, `ingress`, and `default`. If you have done the Kubernetes lab and completed the other optional modules you may also have namespaces for `logging`, `monitoring` or starting with `linkerd` ignore those as well.

Now we have the values for our parameters we will go and set them in the Deployment pipeline. We're doing this really to show that the deploy pipeline supports parameters, we could have set them on the build pipeline.

Note What happens if the same parameter is defined in both pipelines ?

Is a parameter is defined in both the build and a deploy pipeline it triggers then the value from the build pipeline takes priority.

In the Deploy pipeline editor page click the `Parameters` tab to access the parameters form.

First we will define the `EXTERNAL_IP` parameter

In the **Name** field enter `EXTERNAL_IP`

In the **Default Value** field enter the IP address for the ingress-controller you retrieved above

In the **description** field enter `Ingress controler external IP` (For some reason in this case you have to specify a description)

Click the **+** button to save this paramter

In this screenshot the IP address I used is of course for my deployment, yours will almost certainly differ.

Now we will create a parameter for the Kubernetes namespace the manifests use to specify where the deployment will go.

In the **Name** field enter `KUBERNETES_NAMESPACE`

In the **Default value** field enter the namespace you identified above for your deployments

In the **Description** field enter `OKE Deployment namespace`

Click the **+** button.

In the nbext module we will look at how to have a sucesfull build trigger the deployment pipeline we have just created.