![](../../../../common/images/customer.logo2.png)

# Combining build and deploy pipelines, and automated triggering

## Introduction

We now have a build pipeline that builds the code and uploads the resulting artifacts, and the deployment pipeline is ready to go, though admittedly we haven't run it yet.

### Objectives

In this module we will combine the build and deployment pipelines to have a successfully build pipeline automatically trigger a deploy pipeline for us, thus showing how the DevOps service can deliver a continuous integration and continuous deployment process.

### Prerequisites

You must have created and run the build pipeline and have created the deploy pipeline.

## Triggering a deploy from a build pipeline


We could if we wanted have run the deploy pipeline we just created in a previous module, though we would have has to define a few more params (e.g. `STOREFRONT_VERSION`,`OCIR_HOST` etc.) but as this is a lab showing how the use of continuous integration and continuous deployment let's show how to connect the two and run a full CI/CD process.

We will need to update the build pipeline to have it trigger a deploy pipeline on successful completion.

### Task 1: Adding a deployment trigger to the build pipeline

We need to add a stage to the build pipeline that will trigger the deployment

Go to the home page of your DevOps project (click on it's name in the "breadcrumb" trail at the top of the page)

Scroll down the page a little to see the **Latest build pipelines** section, and click on your build pipeline in the list

This will open the pipeline designer page. Click the **+** at the bottom of the `UploadStorefrontArtifacts` stage, and in the resulting menu chose **Add stage**, This will open the new stage form.

In the **Optional** section click the **Trigger Deployment** stage type, then click the **Next** button on the lower left of the form to go to the next page.

Enter `StartStorefrontDeployment` in the stage name, enter a description if you want to

Click the **Select deployment pipeline** button, this will open a popup listing the deployment pipelines, chose the one you created (We suggested you call it `StorefrontDeploy`) from the list, then click the **Save** button on the popup. Once saved the UI will update with further information.

Make sure that the ** Send build pipelines Parameters** check box is selected - if you don't then your deployment won't know about the parameters you set or created in the build pipeline, and the deployment needs those to work out the artifact versions and container image location.

You don't need to do anything with the details in the **Deployment Pipeline Parameters** section, they are there for your reference.

Click the **Add** button on the lower left of the page

We have now updated the build pipeline to trigger our deployment process. 

let's check the version that's currently running - remember that though we have done builds we haven't yet done a depoloyment, so the service will be whatever was there before you started this lab.


Let's check the current version number

First Let's check that the EXTERNAL_IP variable is still set

  - In the OCI Cloud shell type 
  
  - `echo $EXTERNAL_IP`
  
  ```
  123.123.123.123
```

If you get an ip address as the output (the above is of course an example) then proceed to the next step

If you didn't get a value for the EXTERNAL_IP then set it like this *using the IP address for the load ballancer you got earlier*

If you didn't save the load ballancers external IP address

  - In the OCI cloud shell type

  - `kubectl get services -n ingress-nginx`

```
NAME                                 TYPE           CLUSTER-IP      EXTERNAL-IP      PORT(S)                      AGE
ingress-nginx-controller             LoadBalancer   10.96.182.204   130.162.40.241   80:31834/TCP,443:31118/TCP   2h
ingress-nginx-controller-admission   ClusterIP      10.96.216.33    <none>           443/TCP                      2h
```

Look for the `ingress-nginx-controller` line and note the IP address in the `EXTERNAL-IP` column, in this case that's `130.162.40.121` but it's almost certain that the IP address you have will differ. IMPORTANT, be sure to use the IP in the `EXTERNAL-IP` column, ignore anything that looks like an IP address in any other column as those are internal to the OKE cluster and not used externally. Please save this IP address in a note pad or similar as we will be using this in several times in the remainder of the lab.

  - In the OCI Cloud shell type the following *replace `123.123.123.123` with the external IP address of your load ballancer* 
  
  - `export EXTERNAL_IP=123.123.123.123`

Let's confirm that we can still talk to the status service

  - In the OCI Cloud shell type
  
  - `curl -i -k -X GET https://store.$EXTERNAL_IP.nip.io/sf/status`
  
  ```
  HTTP/1.1 200 OK
Date: Thu, 11 Nov 2021 18:12:55 GMT
Content-Type: application/json
Content-Length: 87
Connection: keep-alive
Strict-Transport-Security: max-age=15724800; includeSubDomains

{"name":"My Shop","alive":true,"version":"1.0.0","timestamp":"2021-11-11 18:12:55.354"}
```

Depending on what other labs you may have run against the cluster the version may be `0.0.1` or `0.0.2`

But when we setup the vault variables we also changed the Version so it would be version `1.0.0`, let's run the build to push that version out

Let's give it a go. Click the **Start manual run** on the upper left of the **Build pipeline** tab

We know that the value of the `YOUR_INITIALS` is correct from the previous runs, so just click the **Start manual run** button on the lower left of the page

This time in the stages list note that in addition to the previous two stages we also have a stage called `StartStorefrontDeployment`

**Important** The `StartStorefrontDeployment` stage just triggers the deployment process, it's considered to have successfully run if the deployment starts, *a green checkmark in the build pipeline for the deployment only means that the deployment was started, not that the deployment has succeeded* To see the state of the deployment click the "three dot's" menu for the deployment stage then select the **View deployment** option. This will show you the deployment pipeline and it's progress.

After a while the build pipeline and the deployment should complete with the green checkmarks on all stages for both of them.

## Congratulations, you've deployed to Kubernetes

You can confirm that this is indeed a new deployment by looking at the running pods

  - In the OCI Cloud shell type
  
  - `kubectl get pods`
  
  ```
  NAME                            READY   STATUS    RESTARTS   AGE
stockmanager-6b759ddcd7-rz2jm   1/1     Running   0          177m
storefront-74d6d55dcc-bt4cv     1/1     Running   0          3m
zipkin-7f4676fdcc-rkfsd         1/1     Running   0          177m
```

Notice that the storefront pod is very young compared to the other pods, this is because when making a Kubernetes deployment the pod itself is recreated.

The service is however running, you can check that it's there using the OCI cloud shell.

First Let's check that the EXTERNAL_IP variable is still set

  - In the OCI Cloud shell type 
  
  - `echo $EXTERNAL_IP`
  
  ```
  123.123.123.123
```

If you get an ip address as the output (the above is of course an example) then proceed to the next step

If you didn't get a value for the EXTERNAL_IP then set it like this *using the IP address for the load ballancer you got earlier*

If you didn't save the load ballancers external IP address

  - In the OCI cloud shell type

  - `kubectl get services -n ingress-nginx`

```
NAME                                 TYPE           CLUSTER-IP      EXTERNAL-IP      PORT(S)                      AGE
ingress-nginx-controller             LoadBalancer   10.96.182.204   130.162.40.241   80:31834/TCP,443:31118/TCP   2h
ingress-nginx-controller-admission   ClusterIP      10.96.216.33    <none>           443/TCP                      2h
```

Look for the `ingress-nginx-controller` line and note the IP address in the `EXTERNAL-IP` column, in this case that's `130.162.40.121` but it's almost certain that the IP address you have will differ. IMPORTANT, be sure to use the IP in the `EXTERNAL-IP` column, ignore anything that looks like an IP address in any other column as those are internal to the OKE cluster and not used externally. Please save this IP address in a note pad or similar as we will be using this in several times in the remainder of the lab.

  - In the OCI Cloud shell type the following *replace `123.123.123.123` with the external IP address of your load ballancer* 
  
  - `export EXTERNAL_IP=123.123.123.123`

Let's talk to the status service to see if the version number has updated

  - In the OCI Cloud shell type
  
  - `curl -i -k -X GET https://store.$EXTERNAL_IP.nip.io/sf/status`
  
  ```
  HTTP/1.1 200 OK
Date: Thu, 11 Nov 2021 18:34:12 GMT
Content-Type: application/json
Content-Length: 87
Connection: keep-alive
Strict-Transport-Security: max-age=15724800; includeSubDomains

{"name":"My Shop","alive":true,"version":"1.0.0","timestamp":"2021-11-11 18:34:12.523"}
```

Notice that we now have out version as `1.0.0` which is the version we set earlier in the lab. The name and timestamp will be different for you of course.

  
We are still manually starting the build process, this is what's wanted in some situations, but in may cases you will want the process to happen automatically when code is committed into the git repository, let's see how we can arrange for that to happen.

  - Make sure you are on the main page of your devops project
  
  - Click the **Triggers** menu option on the left side in the **Resources** menu
  
  - Click the **Create Trigger** button
  
  - Name the trigger `StorefrontTrigger`
  
  - Provide a desceription if you wish
  
  - Click in the **Source connection** field and chose **OCI Code Repository**
  
  - The UI will have updated with some new fields 
  
  - Click the **Select** option in the **Select code repository** box
  
  - This will open a popup
  
  - Click the checkbox for your OCI Code Repository in the list
  
  - Click the **Save** button
  
  - In the **Actions** box click the **Add Action** button
  
  - This will open a popup
  
  - In the **Select Build pipeline** box click the **Select** button
  
  - This will open a popup over the first
  
  - Use the checkbox to mark your build pipeline from the list, click the **Save** button to return to the previous popup
  
  - In the **Event** section Click the **Push** checkbox
  
  - In the source branch enter `my-lab-branch` This will cause the trigger to only work on this branch. Note that this mechanism allows you to have different build pipelines for different situations, for example a push to the `main` branch may trigger pipelines that goes through a full and rigorous testing process, whereas a push to a dev related branch may just allow it to progress relying on any unit testing you have defined in your build tools.
  
  - CLick the **Save** button to close this popup
  
  - Click the **Create** button to create the trigger.
  
Now we are going to make a change to our code, to show the process working.

  - In the OCI Cloud shell edit the file $HOME/cloudnative-helidon-storefront/helidon-storefront-full/src/main/java/com/oracle/labs/helidon/storefront/resources/StatusResource.java`
  
  - Locate the line `public final static String VERSION = "1.0.0";` and change the version string to `"1.0.1"` Be careful not to remove any quotes or make any other changes that would mean it won't compile.
  
  Let's commit these changes to your local git repo (the one in the cloud shell you are using) 
In the OCI Cloud shell
git commit -a -m 'Updated version number'

Now push the repo branch to the OCI Code repo you created earlier
In the OCI Cloud shell
git push devops my-lab-branch

This will automatically start the build process, let's go and see that in action

  - Go to the project main page

  - On the left in the Resource section select **Build History**
  
  - In the build history list you'll see a build with a status of `Accepted` (will have a grey dot) or maybe `In Progress` (will have a green dot) that has a name starting `StorefrontTrigger` or similar. This was started by the trigger (the other entries will start `BuildStorefront` which is the name of the pipeline, both names will include a timestamp, but personally I find the **Timestamp** column easier easier to understand).
  
  - Click on the name of your trigger started build, to watch it go through it's steps
  
Once the build and deploy pipelines have finished (remember that the deploy stage in the build pipeline onluy means that the build has started, in the build progress section you need to click right on the three dots menu for the deploy stage, then **View Details** to go to the associated deploy pipeline proigress)  we can check that our update version has in fact been deployed, we'll use the status endpoint to check

  - In the OCI Cloud shell type
  
  - `curl -i -k -X GET https://store.$EXTERNAL_IP.nip.io/sf/status`
  
  ```
  HTTP/1.1 200 OK
Date: Thu, 11 Nov 2021 19:12:25 GMT
Content-Type: application/json
Content-Length: 87
Connection: keep-alive
Strict-Transport-Security: max-age=15724800; includeSubDomains

{"name":"My Shop","alive":true,"version":"1.0.1","timestamp":"2021-11-11 19:12:25.231"}
```

The version number has updated to `1.0.1` so the pipelines we automatically triggered with the git commit have done this work.
  
But what if there's problems with my code, I don't want to just deploy something that is broken.

There are several approaches here :

Firstly you should ensure that your build tools run tests (Maven does this automatically for you as it builds your code) and that you write tests to be run (in Java many people use the JUnit testing framework, though others are available. Other languages will have their own testing frameworks. Generally most testing frameworks will exist with an error if the unit tests do not all complete successfully, this of course will result in the build pipeline stopping as well.

Whatever approach you take we would suggest that you consider putting in a manual confirmation step in the deployment pipeline before deploying to the production environment, you could combine this by having the deployment pipeline initially deploy to a test system where you can run more detailed (and potentially intensive tests) allowing you to extent the unit testing and additionally look for non fatal errors such as performance regressions.

If you are deploying into Kubernetes you may chose to miss the final production deployment step, and instead use a tool like Spinaker or ArgoCD to do the deployment, these can work with a service mesh like Linkerd to do a gradual rollout or a canary deployment, enabling a small portion of your traffic to test the new version first before expanding it to all customers. Currently this would be done using a Function to trigger that process.

Though this lab has focused on deploying into Kubernetes other mechanisms are available