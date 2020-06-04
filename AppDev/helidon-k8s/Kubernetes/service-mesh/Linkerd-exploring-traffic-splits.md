[Go to Overview Page](../Kubernetes-labs.md)

![](../../../../common/images/customer.logo2.png)

# Migration of Monolith to Cloud Native

## C. Deploying to Kubernetes

## Optional 3d. Exploring traffic splits with a Service mesh.

# IN DEVElOPMENT

# NEED INTRO VIDEO 

<details><summary><b>Self guided student - video introduction</b></summary>
<p>

This video is an introduction to the Service mesh traffic splits lab. Once you've watched it please press the "Back" button on your browser to return to the labs.

[![Kubernetes core features lab only setup Introduction Video](https://img.youtube.com/vi/kc1SvmTbvZ8/0.jpg)](https://youtu.be/kc1SvmTbvZ8 "Kubernetes core features lab introduction video")

</p>
</details>

---

## What is a a traffic split, and what can I do with it

A traffic split is just what it says, the traffic arriving at a service is split between the implementation instances. In core Kubernetes this is done using the selector in the service to locate pods with matching  labels. Then traffic sent to the service is split between the different pods, often using a round robin approach so each pod responds in turn.

In a service mesh a traffic split can do the traditional Kubernetes round robin approach, but it can do a lot more. For example there could be two different versions of the service, with the service mesh sending a percentage of the traffic to the different versions. This is useful if for example you want to try out one of the versions to see if it produced better business results (called A/B testing) or maybe you want to try out a new version of your micro-service before fully rolling it out. By diverting a small percentage of the traffic to it you can find out in the real deployed environment if it has any faults or returns errors. If it does then the new version is abandoned and the traffic all goes to instances of the old version, but if the new version turns out to be more reliable than the old one then you complete the rollout process and switch entirely to the new version.

Some service mesh implementations even have the ability to examine the headers in the request and make traffic split decisions based on those. An example of this in use would be to test out a new micro-service version in the real live environment, but limiting it's access to only requests with specific headers, thus a test team could deploy the new version, but the service mesh would only route the requests with that specific header to the new version. The rest of the environment would remain the same so the new version is being tested in the real production environment.

You can even use the traffic split to deliberately introduce faults to your environment to see how the system behaves, for example how well the upstream service handles bad result data, or even no response at all. This later function is part of a larger discipline called [Chaos Engineering](https://en.wikipedia.org/wiki/Chaos_engineering) but we will look at a very small part of it here.

Note that in a lot of these cases you use additional external automation tools to manage the service mesh traffic split (and to use it's monitoring) to adjust the traffic split.

This module was written using the information in the [Linkerd fault injection page.](https://linkerd.io/2/tasks/fault-injection/)

## Using a traffic split to test resilience

We're going to use a traffic split to send some messages to a fake zipkin endpoint which will generate errors, this will let us see how well our micro-services handle the situation where zipkin becomes unavailable.

### Setup the fault injection service

Switch to the service mesh directory

- In the OCI Cloud Shell type :
  - `cd $HOME/helidon-kubernetes/service-mesh`

Let's setup the fault injector, this is basically a simple nginx based web server that returns a HTTP 504 error status (Gateway timeout) each time it's accessed.

First setup the config map for nginx, it defines a config rule for nginx that will always return a 504 error

```
apiVersion: v1
kind: ConfigMap
metadata:
  name: fault-injector-configmap
data:
 nginx.conf: |-
    events {}
    http {
        server {
          listen 80;
            location / {
                return 504;
            }
        }
    }
```

- In the OCI Cloud shell type
  - `kubectl apply -f nginx-fault-injector-configmap.yaml`

```
configmap/fault-injector-configmap created
```

Next let's start a service for the nginx instance (feel free to  look at the contents of the yaml, it's a standard service definition, but it maps the incomming port 9411 to port 80 in the deployments)

- In the OCI Cloud shell type
  - `kubectl apply -f fault-injector-service.yaml`

```  
service/fault-injector created
```

Start the nginx fault injector deployment

- In the OCI Cloud shell type
  - `kubectl apply -f nginx-fault-injector-deployment.yaml`

```
deployment.apps/fault-injector created
```

For testing purposes we'll run an ingress, normally you wouldn't need to do this, but I want to show that the service does indeed return 504 errors

- In the OCI Cloud shell type
  - `kubectl apply -f fault-injector-ingress.yaml`

```
ingress.extensions/fault-injector created
```

Test the fault injection returns the right value

- In the OCI Cloud shell type (replace <external IP> with **your** ingress controller IP address)

  - `curl -i  http://<external IP>/fault`

```
Handling connection for 9411
HTTP/1.1 504 Gateway Time-out
Server: nginx/1.19.0
Date: Wed, 03 Jun 2020 13:22:02 GMT
Content-Type: text/html
Content-Length: 167
Connection: keep-alive

<html>
<head><title>504 Gateway Time-out</title></head>
<body>
<center><h1>504 Gateway Time-out</h1></center>
<hr><center>nginx/1.19.0</center>
</body>
</html>
```

<details><summary><b>If you need to remind yourself of the ingress controller external IP address</b></summary>
<p>

- In the OCI Cloud Shell type :
  - `kubectl get services -n ingress-nginx`

```
NAME                                          TYPE           CLUSTER-IP     EXTERNAL-IP      PORT(S)                      AGE
ingress-nginx-nginx-ingress-controller        LoadBalancer   10.96.196.6    130.61.195.102   80:31969/TCP,443:31302/TCP   3h
ingress-nginx-nginx-ingress-default-backend   ClusterIP      10.96.17.121   <none>           80/TCP                       3h
```

look at the `ingress-nginx-nginx-ingress-controller` row, IP address inthe `EXTERNAL-IP` column is the one you want, in this case that's `130.61.195.102` **but yours will vary**

---
</p></details>

OK, the 504 / Gateway Time-out response is generated as we expect.

### Deploy the traffic split

So far all we've done is to create a service that generates 504 errors, we need to look at the traffic split to redirect some of the traffic for the original service to this new one.

Let's look at the traffic split

```
apiVersion: split.smi-spec.io/v1alpha1
kind: TrafficSplit
metadata:
  name: fault-injector
spec:
  service: zipkin
  backends:
  - service: zipkin
    weight: 500m
  - service: fault-injector-zipkin
    weight: 500m
```

Looking at the spec the split is deployed on the service `zipkin` (This is known as the `Apex Service` as it's the actual top level service) The traffic split talks to two backend services (also known as `Leaf services`) the real `zipkin` service and also the `fault-injector-zipkin` service. The weight indicates how many thousandths of the service should go to each backend, so in this example we have a 50/50 split between fault and working, normally you would have a lower number of requests being sent to the fault-injector (after all, if it does break things you don;t want your end customers to be impacted, especially in a production environment if you wern't sure what would happen, but here we want to be confident we'll see some "failures"  generated.

OK, now we know what it is let's deploy it, note that the traffic split is what's known as a custom resource definition, basically is a mechanism to extend the core Kuberntes capabilities.

- In the OCI Cloud shell type 
  - `kubectl apply -f  fault-injector-traffic-split.yaml`

```
trafficsplit.split.smi-spec.io/fault-injector-split created
```

Let's look at the traffic split in the linkerd UI

- In your web browser go to `https://<external IP address>`

If needed accept that it's a self signed certificate and login as `admin` with password you set when installing linkerd


- On the upper left click the namespaces dropdown (It may display `DEFAULT` or another namespace name

![](images/Linkerd-namespaces-menu.png)

- Click **your namespace** in the list (tg-helidon in my case, but yours should be different)

- On the left menu in the configuration section click `Traffic Splits`

![](images/Linkerd-traffic-splits-menu-option.png)

You will be shown the traffic splits page

![](images/Linkerd-traffic-namespace-traffic-splits-list.png)

This Shows the traffic split details

Click on the name of the traffic-split `fault-injector`

![](images/Linkerd-traffic-splits-fault-injector-details-initial.png)

We can see the details of the traffic split, the `Apex Service` indicates the service the traffic split is operating on, the `Leaf service` shows where the traffic will be split to and the `Weight` indicates the probability of that split option, in this case it's 500/1000 in each case. Of course you could potentially have additional splits.

keep this page open

Let's generate some requests to see what happens

curl -i -k  -u jack:password https://<external ip>/store/stocklevel
^[[AHTTP/2 200 
server: nginx/1.17.8
date: Wed, 03 Jun 2020 18:38:20 GMT
content-type: application/json
content-length: 149
strict-transport-security: max-age=15724800; includeSubDomains

[{"itemCount":410,"itemName":"Pencil"},{"itemCount":50,"itemName":"Eraser"},{"itemCount":4490,"itemName":"Pins"},{"itemCount":100,"itemName":"Book"}]

Well the good news is that on this occasion we got a result, make a few more requests, then return to your web browser (hopefully you left it on the details page of the fault-injection traffic split)

Below is what **I** saw, and it seems that **in this case** the random number generator means that the few requests I made to the traffic split that was connected to the origional zipkin service had all been passed to fault-injector-zipkin which of course failed them all.

![](images/Linkerd-traffic-split-fault-injection-details-all-faults.png)

**Yours may be different** You may see a partial split where some succeeded and some failed (so some going to the `zipkin` and some going to `fault-injector-zipkin`), of you may see them all succeeding (I.e. all going to the `zipkin` service) as the traffic split works randomly it's impossible to predict exactly

In this case you can see that requests to the fault-injection traffic split had a 0% success rate, and were passed to the failt-injector-zipkin service which had a 0% success rate.

So I can show you what it looks like if there are only some failures I made a few more curl requests and came back to the page

![](images/Linkerd-traffic-split-fault-injection-details-some-faults.png)

**Again yours will almost certainly be different**

Here we see that 66.67% of the requests to the traffic split had failed (the bar at the top of the service also indicates the failure rate) and that 100% of the requests to zipkin had succeeded, while 100% of the requests to the fault-injector-zipkin service had failed. In this case given the fault-injector-zipkin service will always fail this is what we would expect, but as you'll see later when we look at canary deployments it's not a pure 100% success or failure in all cases.

Of course this is useful, but in this case all it's telling us is that the `zipkin` service always works and the `fault-injector-zipkin` service always fails. What does that mean for the requests to the zipkin service.

- Click on `Routes` on the left menu

- In the `Namespace` dropdown chose the name of **your** namespace (tg-helidon in the example below)

- In the `Resource` dropdown chose `deployment`

- in the `To Namespace` dropdown chose the name of **your** namespace (tg-helidon in the example below)

- In the `To resource` dropdown chose `deployment/zipkin`

![](images/Linkerd-traffic-split-route-spec.png)

This will generate reports from any deployment to the `zipkin` deployment (it is of course possible to look at specific deployments, but this shows us a good overview)

- Click the `Start` button

- Make multiple curl requests 
curl -i -k  -u jack:password https://<external ip>/store/stocklevel

![](images/Linkerd-traffic-split-route-results.png)

(you may have to scroll down a bit to see the deployment details)

We can see that **in this case** 50% of the requests from the storefront deployment to the zipkin deployment have failed, the same is true for the stockmanager. We know that our traffic split is doing what we expected and that we are failing the requests and potentially causing chaos ! (If you feel like it please feel free to do a Dr Evil or Bond villan manic laugh at this point)

This is great, but how is our service handling it ?

Unless something very unexpected from the point of view of the lab writer has happened all the time you have been getting a reply to the curl command of something like 

```
[{"itemCount":410,"itemName":"Pencil"},{"itemCount":50,"itemName":"Eraser"},{"itemCount":4490,"itemName":"Pins"},{"itemCount":100,"itemName":"Book"}]
```

And you have not had any HTTP errors, this is a pretty good indicator that our service is continuing to work, out little experiment in chaos engineering has given us useful information !

<details><summary><b>What's happening in the pod itself ?</b></summary>
<p>

Wile the service itself is still delivering results fine it's possible that there are useful bit's of information in the logs that might help improve reliability.

First we need the pod name

- In the OCI Cloud shell type 

 - `kubectl get pods`

```
NAME                             READY   STATUS    RESTARTS   AGE
fault-injector-b5bf94d48-f7wbq   2/2     Running   0          55m
stockmanager-7945b54576-9f7q7    2/2     Running   0          69m
storefront-7667fc5fdc-5zwbr      2/2     Running   0          69m
zipkin-7db7558998-c5b5j          2/2     Running   0          69m
```

Now we want to get the logs of the pod itself, in **my** case that's `stockmanager-7945b54576-9f7q7`, but of course yours will be different.

Let's use kubectl to get the logs. Note that as the pod now contains multiple containers due to linkerd injecting them automatically we need to specify the container we want the logs for, as it's names in the deployment. In this case that's the stockmanager container.


- In the OCI Cloud Shell type the following, replace the pod name with your stockmanager pod name :

  - `kubectl logs stockmanager-7945b54576-9f7q7 stockmanager`

```
... Loads of stuff ....
2020.06.03 18:10:01 INFO com.oracle.labs.helidon.stockmanager.resources.StockResource Thread[helidon-4,5,server]: Getting all stock items
Hibernate: 
    SELECT
        departmentName,
        itemName,
        itemCount 
    FROM
        StockLevel 
    WHERE
        departmentName='Tims Shop'
2020.06.03 18:10:02 INFO com.oracle.labs.helidon.stockmanager.resources.StockResource Thread[helidon-4,5,server]: Returning 4 stock items
2020.06.03 18:10:02 WARNING zipkin2.reporter.AsyncReporter$BoundedAsyncReporter Thread[AsyncReporter{URLConnectionSender{http://zipkin:9411/api/v2/spans}},5,main]: Spans were dropped due to exceptions. All subsequent errors will be logged at FINE level.
2020.06.03 18:10:02 WARNING zipkin2.reporter.AsyncReporter$BoundedAsyncReporter Thread[AsyncReporter{URLConnectionSender{http://zipkin:9411/api/v2/spans}},5,main]: Dropped 8 spans due to IOException(Server returned HTTP response code: 504 for URL: http://zipkin:9411/api/v2/spans)
java.io.IOException: Server returned HTTP response code: 504 for URL: http://zipkin:9411/api/v2/spans
        at java.base/sun.net.www.protocol.http.HttpURLConnection.getInputStream0(HttpURLConnection.java:1919)
        at java.base/sun.net.www.protocol.http.HttpURLConnection.getInputStream(HttpURLConnection.java:1515)
        at zipkin2.reporter.urlconnection.URLConnectionSender.skipAllContent(URLConnectionSender.java:232)
        at zipkin2.reporter.urlconnection.URLConnectionSender.send(URLConnectionSender.java:227)
        at zipkin2.reporter.urlconnection.URLConnectionSender$HttpPostCall.doExecute(URLConnectionSender.java:266)
        at zipkin2.reporter.urlconnection.URLConnectionSender$HttpPostCall.doExecute(URLConnectionSender.java:258)
        at zipkin2.Call$Base.execute(Call.java:380)
        at zipkin2.reporter.AsyncReporter$BoundedAsyncReporter.flush(AsyncReporter.java:285)
        at zipkin2.reporter.AsyncReporter$Flusher.run(AsyncReporter.java:354)
        at java.base/java.lang.Thread.run(Thread.java:834)

Hibernate: 
    SELECT
        departmentName,
        itemName,
        itemCount 
    FROM
        StockLevel 
    WHERE
        departmentName='Tims Shop'
... Loads of stuff ....

```

In this case we can find (within a lot of other stuff) the error log details when the stockmanager tried to talk to the zipkin service. We can see that zipkin is dropping the spans.

**If you cannot find this** do not worry, there is a **lot** of log data.

---

</p></details>


For now let's remove the Traffic split and the fault-injector components we created.

- In the OCI Cloud shell type
  - `bash stop-fault-injection.sh`

```
trafficsplit.split.smi-spec.io "fault-injector" deleted
ingress.extensions "fault-injector" deleted
service "fault-injector" deleted
deployment.apps "fault-injector" deleted
configmap "fault-injector-configmap" deleted
```

## Now let's look at how we can use the service mesh to do a canary deployment

### What is a canary deployment ?

A canary deployment is a method of doing a small trial deployment, operating within the overall production infrastructure, and if the trial works you can expand it, if the trial deployment fails then it can be removed.

<details><summary><b>Why the term canary ?</b></summary>
<p>

Historically canaries were used in mines as they were far more sensitive to dangerous atmospheric contaminants than humans, and mines frequently had pockets of carbon monoxide,  and other dangerous gases. The miners would carry a canary in a cage (or a [canary resucitator](https://blog.scienceandindustrymuseum.org.uk/canary-resuscitator/) )with them, sometimes at the end of a long pole, and the canary went first, and if it remained well then in went the humans. If however the canary became unwell then the humans knew it was not safe for them to proceed, and backed out (one hopes taking the canary with them!)

</p</details>

### What are we going to do ?

In this lab we are going to go through the process of **manually** performing a canary deployment, along with recovering it. We're doing this manually so you get the full details of what's happening, however normally you would use automated tools like [Flagger](https://flagger.app) to actually perform the steps for you (and at a much finer granularity)

We are going to deploy a our version of the stockmanager service that deliberately breaks sometimes, from this you can gather than we will not be completing the deployment, but rolling it back !

More importantly we are going to do this while keeping the stockmanager service online all the time.

The order here is important, this is because the basic stockmanager service is only looking for deployments which match the selector of `app: stockmanager`, so if we were to just roll out the new version then the service would match the old and new versions.

First we need to make a small change to our stock manager deployment, adding  the version number to the deployment, this will let us separate it from the newer version we are about to deploy.

- In the OCI Cloud shell type
  - `kubectl edit dsployment stockmanager`

- Scroll down until you find the matchLabels section in the selector (this is the spec.selector.matchLabels)

- Make sure you are changing the matchLabels for the selector, after the `app: stockmanager` line add a new line **at the same indent** of `version: 0.0.1`

- Scroll down until you find the labels section in the pod template (this is the spec.template.metadata.labels)

- Make sure you are changing the metadata for the template of the pods, after the `app: stockmanager` line add a new line **at the same indent** of `version: 0.0.1`

This shows part section of the file with the new lines added

```yaml
  selector:
    matchLabels:
      app: stockmanager
      version: 0.0.1
  strategy:
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 1
    type: RollingUpdate
  template:
    metadata:
      annotations:
        prometheus.io/path: /metrics
        prometheus.io/port: "9081"
        prometheus.io/scrape: "true"
      creationTimestamp: null
      labels:
        app: stockmanager
        version: 0.0.1
    spec:
      containers:
```

(Note that the prometheus annotations may not be present depending on which optional modules you have done)

Save the file and exit, the changes will be updated.

If we have a look at the pods we'll see that the stockmanager pod has been restarted

- In the OCI Cloud shell type
  - ` kubectl get pods`

```
NAME                             READY   STATUS    RESTARTS   AGE
fault-injector-b5bf94d48-llkwf   2/2     Running   0          135m
stockmanager-7cbf798cd9-tdk5h    2/2     Running   0          5m48s
storefront-7667fc5fdc-5zwbr      2/2     Running   0          22h
zipkin-7db7558998-c5b5j          2/2     Running   0          22h
```

Let's make sure our service is still running

- In the OCI CLoud shell type the following (as usual replacing <external IP> with the IP address of the ingress controller service)
  - `curl -i -k  -u jack:password https://<external IP>/store/stocklevel`

```
HTTP/2 200 
server: nginx/1.17.8
date: Thu, 04 Jun 2020 16:38:55 GMT
content-type: application/json
content-length: 149
strict-transport-security: max-age=15724800; includeSubDomains

[{"itemCount":410,"itemName":"Pencil"},{"itemCount":50,"itemName":"Eraser"},{"itemCount":4490,"itemName":"Pins"},{"itemCount":100,"itemName":"Book"}]
```

As the pod has restarted you may have a delay or have to retry the request as the database connection is established.

Now we have a mechanism to split the old and new versions of the service we're going to create two new service definitions, one having a selector that matches the  0.0.1 version of the stockmanager service and one for the 0.0.2 version.

We need to do this now to we can create the traffic split that interposes itself between the original service (stockmanager) and the separate deployments. Remember that the stockmanager service definition only has a selector for the label `app: stockmanager` so if we created the deployments before we put the service in place the original stockmanager service would match both the old and new deployments, and we wouldn't have any control. By putting in a traffic split to manage the requests to the original  (Apex) stockmanager service we can set it up so it sends all traffic to the leaf service for the 0.0.1 version

The versioned services are defined in a couple of yaml files. let's deploy them

- In the OCI CLoud shell type the following
  - `kubectl apply -f stockmanager-v0.0.1-service.yaml`

```
service/stockmanagerv0-0-1 created
```

Then deploy the next

- In the OCI CLoud shell type the following
  - `kubectl apply -f stockmanager-v0.0.2-service.yaml`

```
service/stockmanagerv0-0-2 created
```

**For demonstration purposes only** I have supplied a couple of ingress configurations that will let us see the difference between the two versions. In a normal canary deployment you would **not** do this, but in the lab it helps make clear what's happening.

- In the OCI CLoud shell type the following
  - `kubectl apply -f stockmanager-canary-ingress.yaml`

```
ingress.extensions/stockmanager-v0-0-1 created
ingress.extensions/stockmanager-v0-0-2 created
```

These ingresses connect to the versioned services, not the original stockmanager which does not have a version in it's selector

Let's check them out

- In the OCI CLoud shell type the following
  - `curl -i -k  -u jack:password https://<external IP>/stockmanagerv0-0-1/stocklevel`

```
HTTP/2 200 
server: nginx/1.17.8
date: Thu, 04 Jun 2020 17:06:41 GMT
content-type: application/json
content-length: 149
strict-transport-security: max-age=15724800; includeSubDomains

[{"itemCount":410,"itemName":"Pencil"},{"itemCount":50,"itemName":"Eraser"},{"itemCount":4490,"itemName":"Pins"},{"itemCount":100,"itemName":"Book"}]
```

Accessing the 0.0.1 version the ingress connects to the 0.0.1 service which has the 0.0.1 version of the pods in it's selector. As we earlier updated the existing deployment with this there is a active set of pods behind it and we get results as we'd expect

Now let's try the 0.0.2 version

- In the OCI CLoud shell type the following
  - `curl -i -k  -u jack:password https://<external IP>/stockmanagerv0-0-1/stocklevel`

```
HTTP/2 503 
server: nginx/1.17.8
date: Thu, 04 Jun 2020 17:06:47 GMT
content-type: text/html
content-length: 197
strict-transport-security: max-age=15724800; includeSubDomains

<html>
<head><title>503 Service Temporarily Unavailable</title></head>
<body>
<center><h1>503 Service Temporarily Unavailable</h1></center>
<hr><center>nginx/1.17.8</center>
</body>
</html>
```

For the 0.0.2 version we get a 502 - Service Unavailable response. The ingress controller can map to the 0.0.2 service, but the 0.0.2 service has a selector which is looking for pods with a label `version: 0.0.2` and so far we haven't created any of those.

Now we have to create the traffic split. We need to do this now because the original (un-verioned) stockmanager service has a selector that wil match on **any** pod with the label `app: stockmanager` **regardless` of what the version it is. The traffic split effectively intercepts those requests and distributes them according to it's breakdown. As we can see below, that breakdown sends all the traffic to the v0.0.1 version and none to the v0.0.2 version as we haven't setup any pods for that yet.

# show split
As the traffic split is now intercepting requests to the origional service (even it it's directign them all to the 0.0.1 version we can setup the 0.0.2 pods

# apply 0.0.2

We are using the "broken" version of the stockmanager service we saw earlier, let's confirm that it occationally gives us errors

# curl to /stockmanagerv0-0-2

Now let's adjust the balance of the trafficsplit

The split is 10/90 and the error rate is 50% so we expect to see a fail 5% of the time at the user, let's have a look at what's happening.

Start the load generator <need to fix this to make is varialble request speed, updat the other bits of this lab to reflect the need to put in a speed argumentt>

OK, the new version is broken, what to do.
For now just adjust the split, set the 002 version to 0 - let's us easily update the 002 deployment, but keeps thigns running otherwise

Could of course unwind the entire split, versioned services etc.

It it has worked then roll forwards, increase the spliut while keeping eye on things

Ultiately switch traffic to 0.0.2 remvoe the 0.0.1 service.

Coudl remove the split and 0.0.2 specicic servcie, or coudl leave them in place for future trials

## Other criteria for splitting the traffic

The [Service mesh specification for traffic splits](https://github.com/servicemeshinterface/smi-spec/blob/master/apis/traffic-split/v1alpha3/traffic-split.md) supports other mechanisms (be warned not all service mesh implementation support this specification, and now all support all the traffic split options.)

One interesting one is to have a split based on an `HTTPRouteGroup` This is interesting because it allows you to split traffic based on HTTP elements such as the presence (or not) of specific headers / header values. For example you could split traffic base on if the users browser was Firefox or not. More interestingly you could add a custom header to your request, for example declaring that the request should be treated in a particular way, thus you could have a header "DevelopmentUser", the request would progress through the connected microservices as usual until it got to the particular traffic split, then the traffic split would sent only traffic with that header to the service. This means you can test an update to your microservice in the fully operational production environment, with no risk that non developers would use the in-test version. This solves many of the problems of testing in that it is genuinely operating in the production environment, not a test environment that you believe is "close to" the production environment (but in reality unlikely to be so as the load and scale is usually much smaller for cost reasons)

Of course splitting by header is assuming that the headers are correctly passed on between micro-services.

The service mesh standard also defines capabilities that allow you to apply access controls within the mesh, so for example restricting access to the /metrics endpoint to prometheus, 



---

You have reached the end of this lab module !!

In the next module we will look at how you can use linkerd and grafana to see the traffic flows in your cluster.

Acknowledgements. I'd like to thank Charles Pretzer of Bouyant, Inc for reviewing and sanity checking parts of this document.

Use your **back** button to return to the lab sequence document to access further service mesh modules.