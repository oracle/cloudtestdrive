![](../../../../common/images/customer.logo2.png)

# Cloud Native - Monitoring with Prometheus

<details><summary><b>Self guided student - video introduction</b></summary>


This video is an introduction to the Monitoring microservcies with Prometheus lab. Depending on your browser settings it may open in this tab / window or open a new one. Once you've watched it please return to this page to continue the labs.

[![Gathering metrics with Prometheus lab Introduction Video](https://img.youtube.com/vi/qnDzZ2eOy0E/0.jpg)](https://youtu.be/qnDzZ2eOy0E "Gathering metrics with Prometheus lab introduction video")

---

</details>

## Introduction

This is one of the optional sets of Kubernetes labs

**Estimated module duration** 20 mins.

### Objectives

This module shows how to install the data capture tool Prometheus and how to configure your microservices to be "scraped" by it. We do some simple retrieval and display of the captured data.

### Prerequisites

You need to complete the **Rolling update** module (last of the core Kubernetes labs modules). You can have done any of the other optional module sets.

## Task 1: Explaining Monitoring in Kubernetes

Monitoring a service in Kubernetes involves three components

**A. Generating the monitoring data**
This is mostly done by the service itself, the metrics capability we created when building the Helidon labs are an example of this.

Core Kubernetes services may also provide the ability to generate data, for example the Kubernetes DNS service can report on how many lookups it's performed.

**B. Capturing the data**
Just because the data is available doesn't mean we can analyse it, something needs to extract it from the services, and store it. 

**C. Processing and Visualizing the data**
Once you have the data you need to be able to process it to visualize it and also report any alerts of problems.


## Task 2: Preparing for installing Prometheus

For this lab we are going to do some very simple monitoring, using the metrics in our microservices and the standard capabilities in the Kubernetes core services to generate data.  Then we'll use the Prometheus to extract the data and Grafana to display it.

These tools are of course not the only ones, but they are very widely used, and are available as Open Source projects.

### Task 2a: Configuring Helm

We need to specify the Helm repository for Prometheus

  1. In the OCI Cloud shell 
  
  - `helm repo add prometheus-community https://prometheus-community.github.io/helm-charts`

  ```
"prometheus-community" has been added to your repositories
```
  
Now update the repository information

  2. In the OCI Cloud shell 
  
  - `helm repo update`

   ```
Hang tight while we grab the latest from your chart repositories...
...Successfully got an update from the "kubernetes-dashboard" chart repository
...Successfully got an update from the "prometheus-community" chart repository
Update Complete. ⎈Happy Helming!⎈
```
  
Depending on which other modules you have done you may see differences in the repositories in the update list

### Task 2b: Setting up the namespace and security information

If your cloud shell session is new or has been restarted then the shell variable `$EXTERNAL_IP` may be invalid, expand this section if you think this may be the case to check and reset it if needed.

<details><summary><b>How to check if $EXTERNAL_IP is set, and re-set it if it's not</b></summary>

**To check if `$EXTERNAL_IP` is set**

If you want to check if the variable is still set type `echo $EXTRNAL_IP` if it returns the IP address you're ready to go, if not then you'll need to re-set it.

**To get the external IP address if you no longer have it**

In the OCI Cloud shell type

  -  `kubectl --namespace ingress-nginx get services -o wide ingress-nginx-controller`
  
  ```
NAME                       TYPE           CLUSTER-IP    EXTERNAL-IP      PORT(S)                      AGE   SELECTOR
ingress-nginx-controller   LoadBalancer   10.96.61.56   132.145.235.17   80:31387/TCP,443:32404/TCP   45s   app.kubernetes.io/component=controller,app.kubernetes.io/instance=ingress-nginx,app.kubernetes.io/name=ingress-nginx
```

The External IP of the Load Balancer connected to the ingresss controller is shown in the EXTERNAL-IP column.

**To set the variable again**

  - `export EXTERNAL_IP=<External IP>`
  
---

</details>

To separate the monitoring services from the  other services we're going to put them into a new namespace. We will also secure access to prometheus using a password.

  1. Switch to the monitoring directory. In the OCI CLoud shell type
  
   - `cd $HOME/helidon-kubernetes/monitoring-kubernetes` 
  

  2. Type the following to create the namespace
  
  -  `kubectl create namespace monitoring`

  ```
      namespace/monitoring created
 ```
 
  3. Create a password file for the admin user. In the example below I'm using `ZaphodBeeblebrox` as the password, but please feel free to change this if you like. In the OCI Cloud Shell type
  
  - `htpasswd -c -b auth admin ZaphodBeeblebrox`

  ```
Adding password for user admin
```

  4. Now having created the password file we need to add it to Kuberntes as a secret so the ingress controller can use it. In the OCI Cloud Shell type
  
  - `kubectl create secret generic web-ingress-auth -n monitoring --from-file=auth`

  ```
secret/web-ingress-auth created
```

  5. To provide secure access for the ingress we will set this up with a TLS connection , that requires that we create a certificate for the ingress rule. In productin you woudl use a proper certificate, but for this lab we're going to use the self-signed root certificate we created in the cloud shell setup.
  
  - `$HOME/keys/step certificate create prometheus.monitoring.$EXTERNAL_IP.nip.io tls-prometheus-$EXTERNAL_IP.crt tls-prometheus-$EXTERNAL_IP.key --profile leaf  --not-after 8760h --no-password --insecure --ca $HOME/keys/root.crt --ca-key $HOME/keys/root.key`
  
  ```
  Your certificate has been saved in tls-prometheus-123.456.789.123.crt.
  Your private key has been saved in tls-prometheus-123.456.789.123.key.
```

(The above is example output, your files will be based on the IP you provided)

  6. Now we will create a tls secret in Kubernetes using this certificate, note that this is in the `monitoring` namespace as that's where Prometheus will be installed..
  
  - `kubectl create secret tls tls-prometheus --key tls-prometheus-$EXTERNAL_IP.key --cert tls-prometheus-$EXTERNAL_IP.crt -n monitoring`
  
  ```
  secret/tls-prometheus created
  ```
  

## Task 3: Installing Prometheus


<details><summary><b>Older versions of Kubernetes than 1.20.8</b></summary>

We assume you are using Kubernetes 1.20.8 (the most recent version supported by the Oracle Kubernetes Environment at the time of writing these instructions) in which case the 14.4.1 version of the prometheus helm charts were found to work. If you were using an older version of Kubernetes we found the following version combinations to work.
Kubernetes 1.19.7 Prometheus Helm chart 13.7.0

Kubernetes 1.18.7 Promteheus helm chart 11.12.1 worked for us

Kubernetes 1.17.9 Promteheus helm chart 11.12.1 worked for us

Kubernetes 1.16.9 Promteheus helm chart 11.6.8 worked for us

Kubernetes 1.15.7 Prometheus helm chart 9.7.4 worked for us

Kubernetes 1.14.8 Prometheus helm chart 9.7.1 worked for us

To specify a specific older version use the version keyword in your help command, e.g. `--version 9.1.0`

---

</details>
Note the name given to the Prometheus server within the cluster, in this case `prometheus-server.monitoring.svc.cluster.local`  and also the alert manager's assigned name, in this case `prometheus-alertmanager.monitoring.svc.cluster.local`

The Helm chart will automatically create a couple of small persistent volumes to hold the data it captures. If you want to see more on the volume in the dashboard (namespace monitoring) look at the Config and storage section / Persistent volume claims section, chose the prometheus-server link to get more details, then to locate the volume in the storage click on the Volume link in the details section) Alternatively in the Workloads / Pods section click on the prometheus server pod and scroll down to see the persistent volumes assigned to it. It will also use the tls-prometheus secret and the password auth we just setup



  31 Installing Prometheus is simple, we just use helm. In the OCI Cloud Shell type the following.
  
  - `helm install prometheus prometheus-community/prometheus --namespace monitoring --version 14.4.1 --set server.ingress.enabled=true --set server.ingress.hosts="{prometheus.monitoring.$EXTERNAL_IP.nip.io}" --set server.ingress.tls[0].secretName=tls-prometheus --set server.ingress.annotations."nginx\.ingress\.kubernetes\.io/auth-type"=basic --set server.ingress.annotations."nginx\.ingress\.kubernetes\.io/auth-secret"=web-ingress-auth --set server.ingress.annotations."nginx\.ingress\.kubernetes\.io/auth-realm"="Authentication Required"`
  
  ```
  NAME: prometheus
LAST DEPLOYED: Wed Jul 21 17:22:59 2021
NAMESPACE: monitoring
STATUS: deployed
REVISION: 1
TEST SUITE: None
NOTES:
The Prometheus server can be accessed via port 80 on the following DNS name from within your cluster:
prometheus-server.monitoring.svc.cluster.local

From outside the cluster, the server URL(s) are:
http://prometheus.monitoring.123.456.789.999.nip.io


The Prometheus alertmanager can be accessed via port 80 on the following DNS name from within your cluster:
prometheus-alertmanager.monitoring.svc.cluster.local


Get the Alertmanager URL by running these commands in the same shell:
  export POD_NAME=$(kubectl get pods --namespace monitoring -l "app=prometheus,component=alertmanager" -o jsonpath="{.items[0].metadata.name}")
  kubectl --namespace monitoring port-forward $POD_NAME 9093
#################################################################################
######   WARNING: Pod Security Policy has been moved to a global property.  #####
######            use .Values.podSecurityPolicy.enabled with pod-based      #####
######            annotations                                               #####
######            (e.g. .Values.nodeExporter.podSecurityPolicy.annotations) #####
#################################################################################


The Prometheus PushGateway can be accessed via port 9091 on the following DNS name from within your cluster:
prometheus-pushgateway.monitoring.svc.cluster.local


Get the PushGateway URL by running these commands in the same shell:
  export POD_NAME=$(kubectl get pods --namespace monitoring -l "app=prometheus,component=pushgateway" -o jsonpath="{.items[0].metadata.name}")
  kubectl --namespace monitoring port-forward $POD_NAME 9091

For more information on running Prometheus, visit:
https://prometheus.io/
```
Note that it will take a short while for the Prometheus service to start. Check the dashboard and wait for the `prometheus-service` pod to be Ready or if you prefer the CLI `kubectl get pods -n monitoring`.
  
## Task 4 accessing Prometheus
Let's go to the service web page

  1. In your web browser open up the following link (replace <External IP> with the IP for your Load balancer) - you may have to accept it as an unsafe page due to using a self-signed root certificate.
  
  - `https://prometheus.monitoring.<External IP>.nip.io`
  
  2. When prompted enter the username of `admin` and the password you chose when you setup the credentials (we suggested `ZaphodBeeblebrox` but if you chose your own you'll need to use that).
  
  ![Prometheus login password](images/prometheus-login-password.png)
 
You'll see the Initial prometheus graph page as below.

  ![Prometheus empty graphs page](images/prometheus-empty-graphs.png)

Let's check that Prometheus is scraping some data. 

  2. Click in the **Expression** box the press the space bar
  
You will see a *lot* of possible choices exploring the various services built into Kubernetes (Including apiserver, Core DNS, Container stats, the number of various Kubernetes objects like secrets, pods, configmaps and so on).

  3. In the dropdown find and select select `kubelet_http_requests_total`  (if you type in the box it will reduce the options to match with what you've already entered)
  
  4. Click the **Execute** button. 

Alternatively rather than selecting from the list you can just start to type `kubelet_http_requests_total` into the Expression box, as you type a drop down will appear showing the possible metrics that match your typing so far, once the list of choices is small enough to see it chose `kubelet_http_requests_total` from the list (or just finish typing the entire name and press return to select it) 

Depending on what Prometheus feels like (It seems to very between versions and your starting view) you will initially be presented with either a table of text data

  ![prometheus-http-requests-total-console](images/prometheus-kubelet-http-requests-total-console.png)

or a graph

  ![prometheus-http-requests-total-graph](images/prometheus-kubelet-http-requests-total-graph.png)

  5. Click the **Graph** or **Table** tab names to switch between them

The Kubelet is the code that runs in the worker nodes to perform management actions like starting pods and the like, we can therefore be reasonably confident it'll be available to select.

Note that the precise details shown will of course vary, especially if you've only recently started Prometheus.

  6. Click the + and - buttons next to the duration (default is 1 hour) to expand or shrink the time window of the data displayed
  
  7. Use the << and >> buttons to move the time window around within the overall data set (of course these may not be much use if you haven't got much data, but have a play if you like)

## Task 5: Specifying services to scrape
The problem we have is that (currently) Prometheus is not collecting any data from our services. Of course we may find info on the clusters behavior interesting, but our own services would be more interesting!

We can see what services Prometheus is currently scraping :

  1. Click on the **Status** menu (top of the screen) :

  ![Choosing service discovery](images/prometheus-chosing-service-discovery.png)

  2. Then select **Service Discovery**

  ![The initial service discovery screen](images/prometheus-service-discovery-initial.png)

  3. Click on the **Show More** button next to the Kubernetes-pods line (this is the 2nd reference to Kubernetes pods, the 1st is just a link that takes you to the 2nd one it it's not on the screen)

You will be presented with a list of all of the pods in the system and the information that Prometheus has gathered about them (it does this by making api calls to the api server in the same way kubectl does)

  ![prometheus-pods-lists-initial](images/prometheus-pods-lists-initial.png)

  4. Scroll down to find the entries for the storefront and stockmanager pods. 

If the pod is exposing multiple ports there may be multiple entries for the same pod as Prometheus is checking every port it can to see if there are metrics available.  The image below shows the entries for the storefront on ports 8080 and 9080:

  ![prometheus-pods-storefront-initial](images/prometheus-pods-storefront-initial.png)

We know that Prometheus can see our pods, the question is how do we get it to scrape data from them ?

The answer is actually very simple. In the same way that we used annotations on the Ingress rules to let the Ingress controller know to scan them we use annotations on the pod descriptions to let Prometheus know to to scrape them (and how to do so)

We can use kubectl to get the pod id, using a label selector to get pods with a label **app** and a value **storefront**, then we're using jsonpath to get the specific details from the JSON output.

Don't actually do this, this is just to show how you could modify a live pod with kubectl

This gets the pod name - Example only, do not run this:

```
$ kubectl get pods -l "app=storefront" -o jsonpath="{.items[0].metadata.name}"
storefront-588b4d69db-w244b
```

Now we could use kubectl to add a few annotations to the pod (this is applied immediately, and Prometheus will pick up on it in a few seconds)

These are annotations to apply the live pod - Example only, do not run this:

```
$ kubectl annotate pod storefront-588b4d69db-w244b prometheus.io/scrape=true --overwrite
pod/storefront-588b4d69db-w244b annotated
$ kubectl annotate pod storefront-588b4d69db-w244b prometheus.io/path=/metrics --overwrite
pod/storefront-588b4d69db-w244b annotated
$ kubectl annotate pod storefront-588b4d69db-w244b prometheus.io/port=9080 --overwrite
pod/storefront-588b4d69db-w244b annotated
```

We can see what annotations there would be on the pod with kubectl (this works even if you setup the annotations using the deployment yaml file).

This lists the pod annotations - Example only, do not run this:

```
$  kubectl get pod storefront-588b4d69db-w244b -o jsonpath="{.metadata..annotations}"
map[prometheus.io/path:/metrics prometheus.io/port:9080 prometheus.io/scrape:true]
```

***However***
In most cases we don't want these to be a temporary change, we want the Prometheus to monitor our pods if they restart (or we re-deploy)

  5. In the OCI Cloud Shell Navigate to the helidon-kubernetes folder
  
  - `cd $HOME/helidon-kubernetes` 
  
  6. Edit the file `storefront-deployment.yaml`
  
  7. Locate the pod annotations (part of the spec / template / metadata section) which are currently commented out :

  ```
   metadata:
      labels:
        app: storefront
#      annotations:
#        prometheus.io/path: /metrics
#        prometheus.io/port: "9080"
#        prometheus.io/scrape: "true"
    spec:
      containers:
      - name: storefront
```

  8. Remove the comment symbol (the #) in front of the annotations so the section now looks like
   
  ```
   metadata:
      labels:
        app: storefront
      annotations:
        prometheus.io/path: /metrics
        prometheus.io/port: "9080"
        prometheus.io/scrape: "true"
    spec:
      containers:
      - name: storefront
```
Be **very** careful to only remove the # character and **no other whitespace**.

  9. Save the changes in this file
  
  10. Edit the file `stockmanager-deployment.yaml` so it now has a pod annotations section that looks like 

  ```
 template:
    metadata:
      labels:
        app: stockmanager
      annotations:
        prometheus.io/path: /metrics
        prometheus.io/port: "9081"
        prometheus.io/scrape: "true"
    spec:
      containers:
      - name: stockmanager
```

  11. Now run the script **undeploy.sh** to remove the deployments
  
  -  `bash undeploy.sh`

  ``` 
Deleting storefront deployment
deployment.apps "storefront" deleted
Deleting stockmanager deployment
deployment.apps "stockmanager" deleted
Deleting zipkin deployment
deployment.apps "zipkin" deleted
Kubenetes config is
NAME                               READY   STATUS    RESTARTS   AGE
pod/stockmanager-bd44bbbb7-qk6g9   1/1     Running   0          8h
pod/storefront-564dd99db9-fzf8s    1/1     Running   0          8h
pod/zipkin-88c48d8b9-tjvcg         1/1     Running   0          8h

NAME                   TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)             AGE
service/stockmanager   ClusterIP   10.100.156.12    <none>        8081/TCP,9081/TCP   8h
service/storefront     ClusterIP   10.110.88.187    <none>        8080/TCP,9080/TCP   8h
service/zipkin         ClusterIP   10.101.129.223   <none>        9411/TCP            8h

NAME                                     DESIRED   CURRENT   READY   AGE
replicaset.apps/stockmanager-bd44bbbb7   1         1         1       8h
replicaset.apps/storefront-564dd99db9    1         1         1       8h
replicaset.apps/zipkin-88c48d8b9         1         1         1       8h
```
This script just does a kubectl delete -f on each of the deployments. 

  12. Now recreate the deployments
  
  -  `bash deploy.sh `

  ```
Creating zipkin deployment
deployment.apps/zipkin created
Creating stockmanager deployment
deployment.apps/stockmanager created
Creating storefront deployment
deployment.apps/storefront created
Kubenetes config is
NAME                               READY   STATUS              RESTARTS   AGE
pod/stockmanager-d6cc5c9b7-f9dnf   0/1     ContainerCreating   0          1s
pod/storefront-588b4d69db-vnxgg    0/1     ContainerCreating   0          1s
pod/zipkin-88c48d8b9-x8b6t         0/1     ContainerCreating   0          1s

NAME                   TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)             AGE
service/stockmanager   ClusterIP   10.100.156.12    <none>        8081/TCP,9081/TCP   8h
service/storefront     ClusterIP   10.110.88.187    <none>        8080/TCP,9080/TCP   8h
service/zipkin         ClusterIP   10.101.129.223   <none>        9411/TCP            8h

NAME                           READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/stockmanager   0/1     1            0           1s
deployment.apps/storefront     0/1     1            0           1s
deployment.apps/zipkin         0/1     1            0           1s

NAME                                     DESIRED   CURRENT   READY   AGE
replicaset.apps/stockmanager-d6cc5c9b7   1         1         0       1s
replicaset.apps/storefront-588b4d69db    1         1         0       1s
replicaset.apps/zipkin-88c48d8b9         1         1         0       1s
```

This script just does a kubectl apply -f on each of the deployments. 

If we use kubectl to get the status after a short while (the pods may have to wait for their readiness probes to be operational) we'll see everything is working as expected and the pods are Running

  13. View status: `kubectl get all`

  ```
NAME                               READY   STATUS    RESTARTS   AGE
pod/stockmanager-d6cc5c9b7-f9dnf   1/1     Running   0          79s
pod/storefront-588b4d69db-vnxgg    1/1     Running   0          79s
pod/zipkin-88c48d8b9-x8b6t         1/1     Running   0          79s

NAME                   TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)             AGE
service/stockmanager   ClusterIP   10.100.156.12    <none>        8081/TCP,9081/TCP   8h
service/storefront     ClusterIP   10.110.88.187    <none>        8080/TCP,9080/TCP   8h
service/zipkin         ClusterIP   10.101.129.223   <none>        9411/TCP            8h

NAME                           READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/stockmanager   1/1     1            1           79s
deployment.apps/storefront     1/1     1            1           79s
deployment.apps/zipkin         1/1     1            1           79s

NAME                                     DESIRED   CURRENT   READY   AGE
replicaset.apps/stockmanager-d6cc5c9b7   1         1         1       79s
replicaset.apps/storefront-588b4d69db    1         1         1       79s
replicaset.apps/zipkin-88c48d8b9         1         1         1       79s
```

Note we are doing an undeploy and deploy to ensure we have a known state. If we'd just re-done the deploy only, Kubernetes would have acted like it was an upgrade of the deployments and we'd have seen pods terminating, while new ones were being created and additional replica sets. We saw how this actually works in the rolling upgrade lab.

  14. Return to your browser and reload the Prometheus Status page

You will see that there are 2 pods showing as being discovered, previously it was 0

  ![prometheus-pods-list-updated](images/prometheus-pods-list-updated.png)

  15. Click on the **show more** button next to the kubernetes-pods label

You can see that the storefront pod (port 9080) and stockmanager (port 9081) pods are no longer being dropped and there is now data in the target labels column. The actual data services for storefont (port 8080) and stockmanager (port 8081) are however still dropped.

  ![prometheus-pods-storefront-updated](images/prometheus-pods-storefront-updated.png)

### Task 3c: Let's look at our captured data
Now we have configured Prometheus to scrape the data from our services we can look at the data it's been capturing.

  1. Return to the Graph page in the Prometheus web page
  
  2. Click on the **Graph** tab in the lower section.

  3. In the Expression box use the auto complete function by typing the start of `application_com_oracle_labs_helidon_storefront_resources_StorefrontResource_listAllStock_total` or select it from the list under the **Insert metric at cursor** button.

  4. Click the **Execute** button.

If you're on the graph screen you'll probabaly see a pretty boring graph

  ![prometheus-list-stock-empty](images/prometheus-list-stock-empty-graph.png)

  5.Look at the **console view** to see a bit more information:

  ![prometheus-list-stock-empty-console](images/prometheus-list-stock-empty-console.png)

If we look at the data we can see that the retrieved value is 0 (it may be another number, depends on how often you made the call to list the stock in previous labs) of course our graph looks boring, since we setup prometheus we haven't actually done anything)

Let's make a few calls to list the stock and see what we get

If your cloud shell session is new or has been restarted then the shell variable `$EXTERNAL_IP` may be invalid, expand this section if you think this may be the case to check and reset it if needed.

<details><summary><b>How to check if $EXTERNAL_IP is set, and re-set it if it's not</b></summary>

**To check if `$EXTERNAL_IP` is set**

If you want to check if the variable is still set type `echo $EXTRNAL_IP` if it returns the IP address you're ready to go, if not then you'll need to re-set it.

**To get the external IP address if you no longer have it**

In the OCI Cloud shell type

  -  `kubectl --namespace ingress-nginx get services -o wide ingress-nginx-controller`
  
  ```
NAME                       TYPE           CLUSTER-IP    EXTERNAL-IP      PORT(S)                      AGE   SELECTOR
ingress-nginx-controller   LoadBalancer   10.96.61.56   132.145.235.17   80:31387/TCP,443:32404/TCP   45s   app.kubernetes.io/component=controller,app.kubernetes.io/instance=ingress-nginx,app.kubernetes.io/name=ingress-nginx
```

The External IP of the Load Balancer connected to the ingresss controller is shown in the EXTERNAL-IP column.

**To set the variable again**

  - `export EXTERNAL_IP=<External IP>`
  
---

</details>



  6. Execute the following command a few times
  
  -  `curl -i -k -X GET -u jack:password https://store.$EXTERNAL_IP.nip.io/store/stocklevel`

  ```
HTTP/2 200 
server: nginx/1.17.8
date: Fri, 27 Mar 2020 10:05:52 GMT
content-type: application/json
content-length: 220
strict-transport-security: max-age=15724800; includeSubDomains

[{"itemCount":4980,"itemName":"rivet"},{"itemCount":4,"itemName":"chair"},{"itemCount":981,"itemName":"door"},{"itemCount":25,"itemName":"window"},{"itemCount":20,"itemName":"handle"}]
```

  7. Go back to the Prometheus browser window
  
  8. Reload the page and make sure you're on the **Console** tab

We see that our changes have been applied.  Note it may take up to 60 seconds for Prometheus to get round to scraping the metrics form the service, it doesn't do it continuously as that may put a significant load on the services it's monitoring.

In the console we can see the number of requests we have made

  ![prometheus-list-stock-requested-console](images/prometheus-list-stock-requested-console.png)

And in the Graph we can see the data history

  ![prometheus-list-stock-requested-graph](images/prometheus-list-stock-requested-graph.png)

In this case you can see a set of 9 requests, you may of course have done a different number, or had a break between requests, so what you see will vary.

When we did the Helidon labs we actually setup the metrics on the call to list stock to not just generate an absolute count of calls, but to also calculate how man calls were begin made over a time interval. 

  9. Make a few more curl requests to ensure we have some data groupings, take a short break and then make a few more.

  10. Change the metric to `application_listAllStockMeter_one_min_rate_per_second` Click the **Execute** button

We can see the number of calls to list all stock per second averaged over 1 min. This basically provides us with a view of the number of calls made to the system over time, and we can use it to identify peak loads.

  ![prometheus-list-stock-requested-graph-rat-per-sec-one-min](images/prometheus-list-stock-requested-graph-rat-per-sec-one-min.png)

Prometheus can also produce multi value graphs. For example in addition to the counting metrics we also setup a timer on the listAllStock method to see how long calls to it took. If we now generate a graph on the timer we see in the Console view that instead of just seeing a single entry representing the latest data, that there are actually 6 entries representing different breakdowns of the data (0.5 being the most common data, 0.999 being the least common) Of course the data you see may vary depending on your situation and how much you've already been using the services.

  11. Change the metric to `application_com_oracle_labs_helidon_storefront_resources_StorefrontResource_listAllStockTimer_seconds` Click the **Execute** button

  ![prometheus-list-stock-timer-quantile-console](images/prometheus-list-stock-timer-quantile-console.png)

We can see that 50% of the requests are within 0.12 seconds, and 99.9% are within 0.47 seconds.

  12. The graph is also a lot more interesting, especially if we enabled the stacked mode

  ![prometheus-list-stock-timer-quantile-graph](images/prometheus-list-stock-timer-quantile-graph.png)

It's not possible to show in a static screen grab but in your browser as you move your mouse over the legend the selected data is highlighted, and if you click on a line in the legend only that data is displayed.

Prometheus has a number of mathematical functions we can apply to the graphs it produces, these are perhaps not so much use if there's only a single pod servicing requests, but if there are multiple pods all generating the same statistics (perhaps because of a replica set providing multiple pods to a service for horizontal scaling) then when you gather information such as call rates (the  `application_listAllStockMeter_one_min_rate_per_second` metric) instead of just generating and displaying the data per pod you could also generate data such as `sum(application_listAllStockMeter_one_min_rate_per_second)` which would tell you the total number of requests across ***all*** the pods providing the service.

It's also possible to do things like separate out pods that are being used for testing (say they have a deployment type of test rather than production) or many other parameters. If you want more details there is a link to the Prometheus Query language description in the further-information document

**But it's not a very good visualization**

Prometheus was not designed to be a high end graphing tool, the graphs cannot for instance be saved so you can get back to them later. For that we need to move on to the next lab and have a look at the capabilities of Grafana

---

## Task 3: Tidying up the environment

If you are going to do the Visualizing with Gafana module please do **not** do the following, but return to the introduction of jump to the Visualizing With Grafana module

**ONLY** do the following if you no longer want the Prometheus environment. **DO NOT** do this if you are planning on running the Visualising with Grafana module.

If you are in a trial tenancy there are limitations on how many Load Balancers and other resources you can have in use at any time, and you may need them for other modules. The simplest way to release the resources used in his module (including the load balancer) is to delete the entire namespace.

To delete the monitoring namespace **Only do this if you want to delete the entire monitoring environment and will not be doing the Visualising with Grafana module** 

Do the following

  1. In the OCI Cloud shell type 
  
  - `kubectl delete namespace monitoring`
  
  ```
namespace "monitoring" deleted
```

## End of the module, what's next ?

You can move on to the `Visualizing with Grafana` module which builds on this module, or chose from the various Kubernetes optional module sets.

## Acknowledgements

* **Author** - Tim Graves, Cloud Native Solutions Architect, EMEA OCI Centre of Excellence
* **Contributor** - Jan Leemans, Director Business Development, EMEA Divisional Technology
* **Last Updated By** - Tim Graves, August 2021
