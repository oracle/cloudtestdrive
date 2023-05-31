![Title image](../../../../common/images/customer.logo2.png)

# Install monitoring with Prometheus

<details><summary><b>Self guided student - video introduction</b></summary>


This video is an introduction to the Monitoring microservices with Prometheus lab. Depending on your browser settings it may open in this tab / window or open a new one. Once you've watched it please return to this page to continue the labs.

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
  
  ```bash
  <copy>helm repo add prometheus-community https://prometheus-community.github.io/helm-charts</copy>
  ```

  ```
"prometheus-community" has been added to your repositories
```
  
Now update the repository information

  2. In the OCI Cloud shell 
  
  ```bash
  <copy>helm repo update</copy>
  ```

   ```
Hang tight while we grab the latest from your chart repositories...
...Successfully got an update from the "kubernetes-dashboard" chart repository
...Successfully got an update from the "prometheus-community" chart repository
Update Complete. ⎈Happy Helming!⎈
```
  
Depending on which other modules you have done you may see differences in the repositories in the update list

### Task 2b: Setting up the namespace and security information

To separate the monitoring services from the  other services we're going to put them into a new namespace. We will also secure access to Prometheus using a password.

Check if the `$EXTERNAL_IP` variable is set (depending on the order of modules you took to get here it may not be set)

  - Open the OCI cloud shell if it's not already open, type
  
  ```bash
  <copy>echo $EXTERNAL_IP</copy>
  ``` 
  
  ```
  123.456.789.123
  ```
  
  If it returns the IP address like the example above you're ready to go
  
**If it's not set then you'll need to re-set it.** There are a couple of ways to do this depending on if you use the scripts to install the microservices in Kubernetes (expand the first section immediately below) or if you installed your Kubernetes services manually (expand the second section below).
  
<details><summary><b>If you used the automated scripts to setup the microservices in Kubernetes (you have gone directly to the "optional" labs)</b></summary>

  - Open the OCI cloud shell 

The automated scripts will create a script file `$HOME/clusterSettings.one` this can be executed using the shell built in `source` to set the EXTERNAL_IP variable for you.

  ```bash
  <copy>source $HOME/clusterSettings.one</copy>
  ```
  
```
EXTERNAL_IP set to 123.456.789.123
NAMESPACE set to tg
```

  Of course the actual IP address and namespace will be different from the example here !
  
---

</details>

<details><summary><b>If you manually setup the Kubernetes microservices (you have been doing the "full" lab) </b></summary>

In this case as you manually installed the ingress controller there isn't a script created file with the information and set this up you will need to get the information from Kubernetes itself


  - Open the OCI cloud shell 

  - You are going to get the value of the `EXTERNAL_IP` for your environment. This is used to identify the DNS name used by an incoming connection. In the OCI cloud shell type

  ```bash
  <copy>kubectl get services -n ingress-nginx</copy>
  ```

```
NAME                                 TYPE           CLUSTER-IP      EXTERNAL-IP      PORT(S)                      AGE
ingress-nginx-controller             LoadBalancer   10.96.182.204   130.162.40.241   80:31834/TCP,443:31118/TCP   2h
ingress-nginx-controller-admission   ClusterIP      10.96.216.33    <none>           443/TCP                      2h
```

  - Look for the `ingress-nginx-controller` line and note the IP address in the `EXTERNAL-IP` column, in this case that's `130.162.40.121` but it's almost certain that the IP address you have will differ. IMPORTANT, be sure to use the IP in the `EXTERNAL-IP` column, ignore anything that looks like an IP address in any other column as those are internal to the OKE cluster and not used externally. 

  - IN the OCI CLoud shell type the following, replacing `[external ip]` with the IP address you retrieved above.
  
  ```bash
  export EXTERNAL_IP=[external ip]
  ```
  
---


</details>

Now you have got a value in the variable you can copy and paste from the instructions below.


  1. Switch to the monitoring directory. In the OCI Cloud shell type
  
  ```bash
  <copy>cd $HOME/helidon-kubernetes/monitoring-kubernetes</copy>
  ```
  

  2. Type the following to create the namespace
  
  ```bash
  <copy>kubectl create namespace monitoring</copy>
  ```

  ```
      namespace/monitoring created
 ```
 
  3. Create a password file for the admin user. In the example below I'm using `ZaphodBeeblebrox` as the password, but please feel free to change this if you like. In the OCI Cloud Shell type
  
  ```bash
  <copy>htpasswd -c -b auth admin ZaphodBeeblebrox</copy>
  ```

  ```
Adding password for user admin
```

  4. Now having created the password file we need to add it to Kuberntes as a secret so the ingress controller can use it. In the OCI Cloud Shell type
  
  ```bash
  <copy>kubectl create secret generic web-ingress-auth -n monitoring --from-file=auth</copy>
  ```

  ```
secret/web-ingress-auth created
```

  5. To provide secure access for the ingress we will set this up with a TLS connection , that requires that we create a certificate for the ingress rule. In production you would of course use a proper certificate, but for this lab we're going to use the self-signed root certificate we created in the cloud shell setup.
  
  ```bash
  <copy>$HOME/keys/step certificate create prometheus.monitoring.$EXTERNAL_IP.nip.io tls-prometheus-$EXTERNAL_IP.crt tls-prometheus-$EXTERNAL_IP.key --profile leaf  --not-after 8760h --no-password --insecure --kty=RSA --ca $HOME/keys/root.crt --ca-key $HOME/keys/root.key</copy>
  ```
  
  ```
  Your certificate has been saved in tls-prometheus-123.456.789.123.crt.
  Your private key has been saved in tls-prometheus-123.456.789.123.key.
```

(The above is example output, your files will be based on the IP you provided)

If your output says it's created key files like `tls-prometheus-.crt` and does not include the IP address then the `EXTERNAL_IP` variable is not set, please follow the instructions in Task 1 and re-run the step certificate creation command

  6. Now we will create a tls secret in Kubernetes using this certificate, note that this is in the `monitoring` namespace as that's where Prometheus will be installed..
  
  ```bash
  <copy>`kubectl create secret tls tls-prometheus --key tls-prometheus-$EXTERNAL_IP.key --cert tls-prometheus-$EXTERNAL_IP.crt -n monitoring</copy>
  ```
  
  ```
  secret/tls-prometheus created
  ```
  

## Task 3: Installing Prometheus



Note the name given to the Prometheus server within the cluster, in this case `prometheus-server.monitoring.svc.cluster.local`  and also the alert manager's assigned name, in this case `prometheus-alertmanager.monitoring.svc.cluster.local`

The Helm chart will automatically create a couple of small persistent volumes to hold the data it captures. If you want to see more on the volume in the dashboard (namespace monitoring) look at the Config and storage section / Persistent volume claims section, chose the prometheus-server link to get more details, then to locate the volume in the storage click on the Volume link in the details section) Alternatively in the Workloads / Pods section click on the prometheus server pod and scroll down to see the persistent volumes assigned to it. It will also use the tls-prometheus secret and the password auth we just setup



  1. Installing Prometheus is simple, we just use helm, though there are quite a lot of options here most of them relate to setting up security on the ingress rules. In the OCI Cloud Shell type the following.
  
  ```bash
  <copy>helm install prometheus prometheus-community/prometheus --namespace monitoring --version 22.4.1 --set server.ingress.enabled=true --set server.ingress.hosts="{prometheus.monitoring.$EXTERNAL_IP.nip.io}" --set server.ingress.tls[0].secretName=tls-prometheus --set server.ingress.annotations."kubernetes\.io/ingress\.class"=nginx --set server.ingress.annotations."nginx\.ingress\.kubernetes\.io/auth-type"=basic --set server.ingress.annotations."nginx\.ingress\.kubernetes\.io/auth-secret"=web-ingress-auth --set server.ingress.annotations."nginx\.ingress\.kubernetes\.io/auth-realm"="Authentication Required" --set alertmanager.persistentVolume.enabled=false --set server.persistentVolume.enabled=false --set pushgateway.persistentVolume.enabled=false</copy>
  ```
  
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

Note that it will take a short while for the Prometheus service to start, but to speed this up we have disabled the use of persistent storage - of course in a production environment you would **not** do this ! Check the dashboard and wait for the `prometheus-service` pod to be Ready or if you prefer the CLI `kubectl get pods -n monitoring`.
  
## Task 4 Accessing Prometheus
Let's go to the service web page

  1. In your web browser open up the following link (replace <External IP> with the IP for your Load balancer) - you may have to accept it as an unsafe page due to using a self-signed root certificate.
  
  ```
  https://prometheus.monitoring.<External IP>.nip.io
  ```
  
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

  ![Prometheus reported metrics of total kubelet http requests - table](images/prometheus-kubelet-http-requests-total-console.png)

or a graph

  ![Prometheus reported metrics of total kubelet http requests - graoh](images/prometheus-kubelet-http-requests-total-graph.png)

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

  ![List of pods prometheus knows about](images/prometheus-pods-lists-initial.png)

  4. Scroll down to find the entries for the storefront and stockmanager pods. 

If the pod is exposing multiple ports there may be multiple entries for the same pod as Prometheus is checking every port it can to see if there are metrics available.  The image below shows the entries for the storefront on ports 8080 and 9080:

  ![Details of the storefront pods as seen by Prometheus](images/prometheus-pods-storefront-initial.png)

We know that Prometheus can see our pods, the question is how do we get it to scrape data from them ?

The answer is actually very simple. In the same way that we used annotations on the Ingress rules to let the Ingress controller know to scan them we use annotations on the pod descriptions to let Prometheus know to to scrape them (and how to do so)

We can use kubectl to get the pod id, using a label selector to get pods with a label **app** and a value **storefront**, then we're using jsonpath to get the specific details from the JSON output.

Don't actually do this, this is just to show how you could modify a live pod with kubectl

This gets the pod name - Example only, do not run this:

```bash
$ kubectl get pods -l "app=storefront" -o jsonpath="{.items[0].metadata.name}"
storefront-588b4d69db-w244b
```

Now we could use kubectl to add a few annotations to the pod (this is applied immediately, and Prometheus will pick up on it in a few seconds)

These are annotations to apply the live pod - Example only, do not run this:

```bash
$ kubectl annotate pod storefront-588b4d69db-w244b prometheus.io/scrape=true --overwrite
pod/storefront-588b4d69db-w244b annotated
$ kubectl annotate pod storefront-588b4d69db-w244b prometheus.io/path=/metrics --overwrite
pod/storefront-588b4d69db-w244b annotated
$ kubectl annotate pod storefront-588b4d69db-w244b prometheus.io/port=9080 --overwrite
pod/storefront-588b4d69db-w244b annotated
```

We can see what annotations there would be on the pod with kubectl (this works even if you setup the annotations using the deployment yaml file).

This lists the pod annotations - Example only, do not run this:

```bash
$  kubectl get pod storefront-588b4d69db-w244b -o jsonpath="{.metadata..annotations}"
map[prometheus.io/path:/metrics prometheus.io/port:9080 prometheus.io/scrape:true]
```

***However***
In most cases we don't want these to be a temporary change, we want the Prometheus to monitor our pods if they restart (or we re-deploy)

 The deployment files in the `$HOME/helidon-kubernetes` directory have the annotations commented out when they were cloned from git. Rather than edit the YAML (which can lead to format errors if the indentation doesn't line up) we're going to run a script that will remove the comments and redeploy the services with the updated annotations for us, if you wanted you could of course do this by hand !

  5. Switch to the monitoring directory. In the OCI CLoud shell type
  
   ```bash
  <copy>cd $HOME/helidon-kubernetes/monitoring-kubernetes</copy>
  ```
  
  6. Run the script
  
  ```bash
  <copy>bash configure-pods-for-prometheus.sh</copy>
  ```
  
  ```
deployment.apps/stockmanager configured
deployment.apps/storefront configured
```
  
  7. The deployment files now contains annotations like the following
   
  ```yaml
      annotations:
        prometheus.io/path: /metrics
        prometheus.io/port: "9080"
        prometheus.io/scrape: "true"
    spec:
      containers:
```

  The first path and port annotations define the path and port the metrics service is running on.
  
  The scrape annotation is detected by Prometheus and as in this case it's set to true will trigger Prometheus to start looking for metrics data. This is why we didn't have to configure Prometheus itself, and only needed to 

If we use kubectl to get the status after a short while (the pods may have to wait for their readiness probes to be operational) we'll see everything is working as expected and the pods are Running

  8. View status: 
  
  ```bash
  <copy>kubectl get all</copy>
  ```

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
deployment.apps/stockmanager   1/1     1            1           1h
deployment.apps/storefront     1/1     1            1           1h
deployment.apps/zipkin         1/1     1            1           1h

NAME                                     DESIRED   CURRENT   READY   AGE
replicaset.apps/stockmanager-d6cc5c9b7   1         1         1       79s
replicaset.apps/storefront-588b4d69db    1         1         1       79s
replicaset.apps/stockmanager-2fae51269   1         1         1       1h
replicaset.apps/storefront-a458e8bc51    1         1         1       1h
replicaset.apps/zipkin-88c48d8b9         1         1         1       1h
```

  We actually redeployed the pods (so applied an updated configuration) this is why we see multiple replica sets. Kubernetes has acted in the same way as if it was an upgrade of the deployment images of other configuration information and if we'd run the kubectl command quickly enough the new replica sets and pods being created before the old pods were terminated. We saw how this actually works in the rolling upgrade lab.

  9. Return to your browser and reload the Prometheus Status page

You will see that there are 2 pods showing as being discovered, previously it was 0

  ![Updated list of pods Prometheus is scraping](images/prometheus-pods-list-updated.png)

  10. Click on the **show more** button next to the kubernetes-pods label

You can see that the storefront pod (port 9080) and stockmanager (port 9081) pods are no longer being dropped and there is now data in the target labels column. The actual data services for storefont (port 8080) and stockmanager (port 8081) are however still dropped.

  ![Details of the storefront metrics from Prometheus](images/prometheus-pods-storefront-updated.png)

## Task 6: Let's look at our captured data
Now we have configured Prometheus to scrape the data from our services we can look at the data it's been capturing.

  1. Return to the Graph page in the Prometheus web page
  
  2. Click on the **Graph** tab in the lower section.

  3. In the Expression box use the auto complete function by typing the start of `application_com_oracle_labs_helidon_storefront_resources_StorefrontResource_listAllStock_total` or select it from the list under the **Insert metric at cursor** button.

  4. Click the **Execute** button.

If you're on the graph screen you'll probably see a pretty boring graph

  ![Metrics of calls for the storefront listAllStock method as a graph](images/prometheus-list-stock-empty-graph.png)

  5.Look at the **console view** to see a bit more information:

  ![Metrics of calls for the storefront listAllStock method as a table](images/prometheus-list-stock-empty-console.png)

If we look at the data we can see that the retrieved value (in the **Value** column on the right) in this case is 0  (it may be another number, depends on how often you made the call to list the stock in previous labs) of course our graph looks boring, since we've just setup Prometheus we haven't actually done anything)

Let's make a few calls to list the stock and see what we get

If your cloud shell session is new or has been restarted then the shell variable `$EXTERNAL_IP` may be invalid, expand this section if you think this may be the case to check and reset it if needed.

<details><summary><b>How to check if $EXTERNAL_IP is set, and re-set it if it's not</b></summary>

**To check if `$EXTERNAL_IP` is set**

If you want to check if the variable is still set type `echo $EXTERNAL_IP` if it returns the IP address you're ready to go, if not then you'll need to re-set it.

**To get the external IP address if you no longer have it**

In the OCI Cloud shell type

  ```bash
  <copy>kubectl --namespace ingress-nginx get services -o wide ingress-nginx-controller</copy>
  ```
  
  ```
NAME                       TYPE           CLUSTER-IP    EXTERNAL-IP      PORT(S)                      AGE   SELECTOR
ingress-nginx-controller   LoadBalancer   10.96.61.56   132.145.235.17   80:31387/TCP,443:32404/TCP   45s   app.kubernetes.io/component=controller,app.kubernetes.io/instance=ingress-nginx,app.kubernetes.io/name=ingress-nginx
```

The External IP of the Load Balancer connected to the ingresss controller is shown in the EXTERNAL-IP column.

**To set the variable again** replace `[External IP]` with the IP address you got above

  ```bash
  export EXTERNAL_IP=[External IP]
  ```
  
---

</details>



  6. Execute the following command a few times to generate some call metrics
  
 ```bash
  <copy>curl -i -k -X GET -u jack:password https://store.$EXTERNAL_IP.nip.io/store/stocklevel</copy>
  ```

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
  
  8. Click the **Execute** button to update the query the page and make sure you're on the **Table** tab

We see that our changes have been applied, herwe we see that there were 9 calls (the **Value** column on the right), but of course the number may vary depending on how many requests you made.  Note it may take up to 60 seconds for Prometheus to get round to scraping the metrics from the service, it doesn't do it continuously as that may put a significant load on the services it's monitoring.

In the console we can see the number of requests we have made

  ![Updated metrics form Prometheus on the list stock requests as a table](images/prometheus-list-stock-requested-console.png)

And in the Graph we can see the data history

  ![Updated metrics form Prometheus on the list stock requests as a graph](images/prometheus-list-stock-requested-graph.png)

In this case you can see a set of 9 requests, you may of course have done a different number, or had a break between requests, so what you see will vary.

When we did the Helidon labs we actually setup the metrics on the call to list stock to not just generate an absolute count of calls, but to also calculate how man calls were begin made over a time interval. 

  9. Make a few more curl requests to ensure we have some data groupings, take a short break and then make a few more.

  10. Change the metric to `application_listAllStockMeter_one_min_rate_per_second` Click the **Execute** button

We can see the number of calls to list all stock per second averaged over 1 min. This basically provides us with a view of the number of calls made to the system over time, and we can use it to identify peak loads.

  ![Graph of stock requests per second](images/prometheus-list-stock-requested-graph-rat-per-sec-one-min.png)

Prometheus can also produce multi value graphs. For example in addition to the counting metrics we also setup a timer on the listAllStock method to see how long calls to it took. If we now generate a graph on the timer we see in the Console view that instead of just seeing a single entry representing the latest data, that there are actually 6 entries representing different breakdowns of the data (0.5 being the most common data, 0.999 being the least common) Of course the data you see may vary depending on your situation and how much you've already been using the services.

  11. Change the metric to `application_com_oracle_labs_helidon_storefront_resources_StorefrontResource_listAllStockTimer_seconds` Click the **Execute** button

  ![Distribution graph of requests per second](images/prometheus-list-stock-timer-quantile-console.png)

We can see that 50% of the requests are within 0.12 seconds, and 99.9% are within 0.47 seconds.

  12. The graph is also a lot more interesting, especially if we enabled the stacked mode

  ![Stacked distribution graph of requests per second](images/prometheus-list-stock-timer-quantile-graph.png)

It's not possible to show in a static screen grab but in your browser as you move your mouse over the legend the selected data is highlighted, and if you click on a line in the legend only that data is displayed.

Prometheus has a number of mathematical functions we can apply to the graphs it produces, these are perhaps not so much use if there's only a single pod servicing requests (that's unusual in any production environment where you'd always want to have at least two instances running in case one fails), but if there are multiple pods all generating the same statistics (perhaps because of a replica set providing multiple pods to a service for horizontal scaling) then when you gather information such as call rates (the  `application_listAllStockMeter_one_min_rate_per_second` metric) instead of just generating and displaying the data per pod you could also generate data such as `sum(application_listAllStockMeter_one_min_rate_per_second)` which would tell you the total number of requests across ***all*** the pods providing the service (trhis f course assumes that you do have multiple pods).

It's also possible to do things like separate out pods that are being used for testing (say they have a deployment type of test rather than production) or many other parameters. If you want more details there is a link to the Prometheus Query language description in the further-information document

**But it's not a very good visualization**

Prometheus was not designed to be a high end graphing tool, the graphs cannot for instance be saved so you can get back to them later. For that we need to move on to the next lab and have a look at the capabilities of Grafana

---

## Task 7: Tidying up the environment

If you are going to do the Visualizing with Gafana module please do **not** do the following, but return to the introduction or jump to the Visualizing With Grafana module

**ONLY** do the following if you no longer want the Prometheus environment. **DO NOT** do this if you are planning on running the Visualising with Grafana module.

If you are in a trial tenancy there are limitations on how many resources you can have in use at any time, and you may need them for other modules. The simplest way to release the resources used in his module (including the load balancer) is to delete the entire namespace.

To delete the monitoring namespace **Only do this if you want to delete the entire monitoring environment and will not be doing the Visualising with Grafana module** 

Do the following

  1. In the OCI Cloud shell type 
  
  ```bash
  <copy>kubectl delete namespace monitoring</copy>
  ```
  
  ```
namespace "monitoring" deleted
```

## End of the module, what's next ?

You can move on to the `Visualizing with Grafana` module which builds on this module, or chose from the various Kubernetes optional module sets.

## Acknowledgements

* **Author** - Tim Graves, Cloud Native Solutions Architect, Oracle EMEA Cloud Native Application Development specialists Team
* **Contributor** - Jan Leemans, Director Business Development, EMEA Divisional Technology
* **Last Updated By** - Tim Graves, May 2023
