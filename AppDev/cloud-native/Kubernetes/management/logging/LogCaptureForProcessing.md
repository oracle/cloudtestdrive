[Go to Overview Page](../Kubernetes-labs.md)

![](../../../../../common/images/customer.logo2.png)

# Migration of Monolith to Cloud Native

## C. Deploying to Kubernetes
## Optional 2a. Log Capture for processing

<details><summary><b>Self guided student - video introduction</b></summary>
<p>

This video is an introduction to the Log Capture for processing labs Once you've watched it please press the "Back" button on your browser to return to the labs.

[![Kubernetes Log capture for processing video](https://img.youtube.com/vi/QjvhjL0hxLE/0.jpg)](https://youtu.be/QjvhjL0hxLE "Kubernetes log capture for procesing video")

</p>
</details>

---

### Introduction

<details><summary><b>The problem with log data in a distributed cloud native environment</b></summary>
<p>

Many applications generate log data, in the case of Java programs this is usually achieved by a logging library, in the case of the Helidon parts of the labs we have used the Simple Logging Facade (The @slf4j Lombok annotation in the code) which allows us to easily switch the actuall logging engine being used. Other languages also have their own logging frameworks, for example in Ruby there is the Logger class, and in there are open source libraries like log4c.

Most Unix (and Linux) systems provide support for syslogd which enables system operations as well as code to generate log messages.

The problem is that the output of the log messages is not always consistent, for example syslogd writes it's data to a system directory and most code logging frameworks have many different output mechanisms including files, the system console, and also standard output.

To make things even more complicated there are many different output formats, plain ASCII is common, but json, xml are often used. Even something as simple as the date / time is often specified by the authors of the code itself and is in their local format (it's rare to see a log event using seconds / milliseconds as per Unix / Java time)

All of these options make logging complicated, where to capture the data and what it looks like make it very difficult to have consistent logging, and given that micro-service based architectures are often deployed using micro-services from many locations and in many programming languages this is a problem.

Fortunately the 12 factors has a [simple recommendation on logging](https://12factor.net/logs) that addresses at least some of these problems. The recommendation is that logs should be treated as a stream of data being sent to the applications standard out, and that the rest of the process is a problem for the execution environment.

As part of its design Kubernetes does save all the information sent by a pod to its standard out, and we have seen this when we look at the logs for a pod, we did this earlier on when we used the dashboard to have a log at the logs, and also the command `kubectl logs <pod> -n <namespace>` let's us see the logs (use `-f` to "follow" the log as new information is added)

This is good, but with in a distributed architecture a single request may (almost certainly will) be processed by multiple individual micro-services. We've seen how zipkin can be used to generate trace data as a request traverses multiple micro-services, but how can integrate the log data ?

---

</p></details>

To process log data in a consistent manner we need to get all of the data into one place. We're going to use [fluentd](https://www.fluentd.org/) to capture the data and send it to  an Elastic search instance deployed in our Kubernetes cluster in the initial example below, but there are many other options.

### Installing elastic search

As with elsewhere in the labs we'll do this module in it's own namespace, so first we have to create one.

- In the cloud console type :
  - `kubectl create namespace logging`
  
```
namespace/logging created
```

Now let's use helm to install the elastic search engine into the logging namespace

- First if you haven't already done it add the bitnami help repository

- `helm repo add bitnami https://charts.bitnami.com/bitnami`
```
"bitnami" has been added to your repositories
```

- Update the repository cache
  - `helm repo update`

```
Hang tight while we grab the latest from your chart repositories...
...Successfully got an update from the "kubernetes-dashboard" chart repository
...Successfully got an update from the "bitnami" chart repository
...Successfully got an update from the "stable" chart repository
Update Complete. ⎈ Happy Helming!⎈ 
```

- In the cloud console type :
  - `helm install elasticsearch bitnami/elasticsearch --namespace logging --version 12.7.3`

```
NAME: elasticsearch
LAST DEPLOYED: Wed Apr 22 15:05:25 2020
NAMESPACE: logging
STATUS: deployed
REVISION: 1
NOTES:
The elasticsearch cluster has been installed.

Elasticsearch can be accessed:

  * Within your cluster, at the following DNS name at port 9200:

    elasticsearch-client.logging.svc

  * From outside the cluster, run these commands in the same shell:

    export POD_NAME=$(kubectl get pods --namespace logging -l "app=elasticsearch,component=client,release=elasticsearch" -o jsonpath="{.items[0].metadata.name}")
    echo "Visit http://127.0.0.1:9200 to use Elasticsearch"
    kubectl port-forward --namespace logging $POD_NAME 9200:9200
```

Note the DNS name, in this case it's `elasticsearch-client.logging.svc`

Let's check on the installation, note that is can take a few mins for the elastic search to be loaded and installed.

- In the cloud console type :
  - `kubectl get all -n logging`

```
NAME                                        READY   STATUS     RESTARTS   AGE
pod/elasticsearch-client-5597688787-mq8qx   0/1     Running    0          55s
pod/elasticsearch-client-5597688787-vzgk6   0/1     Running    0          56s
pod/elasticsearch-data-0                    0/1     Init:0/2   0          56s
pod/elasticsearch-master-0                  0/1     Init:0/2   0          55s

NAME                              TYPE        CLUSTER-IP    EXTERNAL-IP   PORT(S)    AGE
service/elasticsearch-client      ClusterIP   10.96.5.107   <none>        9200/TCP   56s
service/elasticsearch-discovery   ClusterIP   None          <none>        9300/TCP   56s

NAME                                   READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/elasticsearch-client   0/2     2            0           56s

NAME                                              DESIRED   CURRENT   READY   AGE
replicaset.apps/elasticsearch-client-5597688787   2         2         0       56s

NAME                                    READY   AGE
statefulset.apps/elasticsearch-data     0/2     56s
statefulset.apps/elasticsearch-master   0/3     56s
```

### Create an ingress to allow external access to the elastic search

Normally you wouldn't do this as the elastic search is an internal service that's accessed using other services that do analysis, but as we're going to be connecting to it externally to see how it's been working we're going to create an ingress that will let us access it.

- Switch to the `$HOME/helidon-kubernetes/management/logging` directory

- Apply the ingress file by typing :
  - `kubectl apply -f ingressElasticSearch.yaml`

```
ingress.networking.k8s.io/elasticsearch created
```

<details><summary><b>If you need to remind yourself of the ingress controller IP address</b></summary>
<p>

- In the OCI Cloud Shell type :
  - `kubectl get services -n ingress-nginx`

```
NAME                                          TYPE           CLUSTER-IP     EXTERNAL-IP      PORT(S)                      AGE
ingress-nginx-nginx-ingress-controller        LoadBalancer   10.96.196.6    130.61.195.102   80:31969/TCP,443:31302/TCP   6d1h
ingress-nginx-nginx-ingress-default-backend   ClusterIP      10.96.17.121   <none>           80/TCP                       6d1h
```

look at the `ingress-nginx-nginx-ingress-controller` row, IP address inthe `EXTERNAL-IP` column is the one you want, in this case that's `130.61.195.102` **but yours will vary**

</p></details>

- In a web browser go to the web page `https://<External IP>/elastic/_cat`  (remember the one below is **my** ip address **you need to use yours**)

- If needed in the browser, accept a self signed certificate.
  - In Safari you will be presented with a page saying "This Connection Is Not Private" Click the "Show details" button, then you will see a link titled `visit this website` click that, then click the `Visit Website` button on the confirmation pop-up. To update the security settings you may need to enter a password, use Touch ID or confirm using your Apple Watch.
  - In Firefox once the security risk page is displayed click on the "Advanced" button, then on the "Accept Risk and Continue" button
  - In Chrome once the "Your connection is not private" page is displayed click the advanced button, then you may see a link titled `Proceed to ....(unsafe)` click that. 
  
We have had reports that some versions of Chrome will not allow you to override the page like this, for Chrome 83 at least one solution is to click in the browser window and type the words `thisisunsafe` (copy and past doesn't seem to work, you need to actually type it.) Alternatively use a different browser.


![](images/ES-catalogue-endpoints.png)

We can see that the elastic search service is up and running, let's see what data it holds

- In a web browser (remember to substitute **your** IP address) look at the indices in the service

![](images/ES-no-indices.png)

Well, it's empty ! Of course that shouldn't be a surprise, we've not put any log data in it yet !

### Capturing the log data from the micro-services

Kubernetes writes the log data it captures to files on the host that's running the node. To get the data we therefore need to run a program on every node that accesses the log files and sends them to the storage (elastic search in this case)

So far we've just asked Kubernetes to create deployments / replica sets / pods and it's determined the node they will run based on the best balance of availability and resources, how do we ensure that we can run a service in each node ? 

Well the daemonset in Kubernetes allows the definition of a pod that will run on every node in the cluster, we just have to define the daemonset and the template of the pod that's going to do the work and Kubernetes will deal with the rest, ensuring that even if nodes are added or removed that a pod matching the daemonset definition is running on the node.

<details><summary><b>Other benefits of using daemon sets</b></summary>
<p>
The daemon set is a separate pod, running with it's own set of resources, thus while it does consume resources at the node and cluster level it doesn't impact the performance of the pods it's extracting log data for.

Additionally the daemon set can look at the log data for all of the pods in the node, if we did the logging within a pod (say by replacing the log processor or your micro-service) then you'd have to modify every pod, but by logging it to standard out and using a deamonset you can capture the data of all of the logs at the same time, and only need to make changes in a single place.

---

</p></details>

Why run the data gathering in a pod ? Well why not ? While we could run the data capture process by hand manually on each node then we'd have to worry about stopping and starting the service, restarting if it fails, managing and updating configuration files and so on. If we just run it in a Kubernetes pod we can let Kuberneties do all of it's magic for us and we can focus on defining the capture process, and leave running it to Kubernetes ! 

How will our capture pod get the log data though ? We've seen previously how we can use volumes to bring in a config map or secret to a pod and make it look like it's part of the local file system, well there are several other types of source for a volume (in the Prometheus section we briefly saw how helm setup an external storage object as a volume for storing the data.) One of the volume types provides the ability to bring in a local file system, in this case in the node as part of the pods file structure.

Fluentd is an open source solution to processing the log data, it's basically an engine, reading data from input sources and sending them to output sources (that's more complicated than you'd think when dealing with potentially large numbers of high volume sources.) it supports multiple input sources, including reading log files saved from the containers by Kubernetes (imported from the node into the pods via a volume) It also supports many output types. 

We will be using the output that writes to elastic search, this does all the work of creating indices for us and storing the data for each day.

There are a number of yaml daemonset configuration files at the [fluentd daemonset github](https://github.com/fluent/fluentd-kubernetes-daemonset) We will be using a modified version of the `fluentd-daemonset-elasticsearch-rbac.yaml` configuration.

What are the modifications ? 

We are telling fluentd the DNS name of the elastic search service. In this case that's `elasticsearch-client.logging.svc` As we've seen previously the Kubernetes service makes this available on it's internal DNS service and distributes requests across all of the pods that are ready in the service.

We need to tell fluentd to ignore the systemd that's running in it's own pod, the base images used by fluentd no longer supports systemd, and if we didn't disable it we'd just get a bunch of log messages complaining that it can't access the service.

We have added a volume mount entry and associated volume to bring in the log files. In the case of the OKE installation of Kubernetes those are located in /var/log/containers, but that's actually a link to their real location in /u01/data/docker/containers

Finally we have changes the namespace from kube-system to logging, this is really just for convenience as this is an optional lab module, and we didn't want to complicate following modules with text along the lines of "If you've done the logging module you'll see xxxx in kube-system, but if you haven't you'll see yyyy" Also it's generally good practice to separate things by their function.

Let's create the daemonset
- Make sure you are in the `$HOME/helidon-kubernetes/management/logging` directory
- In the OCI Cloud Shell terminal type :
  - `kubectl apply -f fluentd-daemonset-elasticsearch-rbac.yaml`

```
serviceaccount/fluentd created
clusterrole.rbac.authorization.k8s.io/fluentd created
clusterrolebinding.rbac.authorization.k8s.io/fluentd created
daemonset.apps/fluentd created
```
Let's make sure that everything has started
- In the OCI Cloud Shell type :
  - `kubectl get daemonsets -n logging`

```
NAME      DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR   AGE
fluentd   3         3         3       3            3           <none>          3m4s
```

We can see that there are 3 pods, why 3 ? That's the number of nodes in this cluster, it may vary if your cluster has a different number of nodes.

Let's look at the distribution of the fluent instances, we could do this using kubectl commands, for example  

```
$ kubectl get nodes
NAME        STATUS   ROLES   AGE   VERSION
10.0.10.2   Ready    node    8d    v1.15.7
10.0.10.3   Ready    node    8d    v1.15.7
10.0.10.4   Ready    node    8d    v1.15.7
```

But it's easier to see what's happening using the Kubernetes dashboard in this case.

<details><summary><b>If you've forgotten your Kubernetes dashboard details</b></summary>
<p>

You can get the IP address being used for the dashboard by looking at the services list for the kube-system namespace

- In the OCI Cloud Shell type :
  - `kubectl get services -n kube-system`
  
```
NAME                   TYPE           CLUSTER-IP     EXTERNAL-IP      PORT(S)                  AGE
kube-dns               ClusterIP      10.96.5.5      <none>           53/UDP,53/TCP,9153/TCP   8d
kubernetes-dashboard   LoadBalancer   10.96.161.29   132.145.231.23   443:30738/TCP            6d22h
```

The address is in the EXTERNAL-IP column, in this case it's 132.145.231.23 **but yours will be different**

</p></details>

Open the Kubernetes dashboard

- In a web browser go to the dashboard (remember this is my IP address, yours will be different) `https://132.145.231.23`

- If prompted in the browser, accept the self signed certificate.
  - In Safari you will be presented with a page saying "This Connection Is Not Private" Click the "Show details" button, then you will see a link titled `visit this website` click that, then click the `Visit Website` button on the confirmation pop-up. To update the security settings you may need to enter a password, use Touch ID or confirm using your Apple Watch.
  - In Firefox once the security risk page is displayed click on the "Advanced" button, then on the "Accept Risk and Continue" button
  - In Chrome once the "Your connection is not private" page is displayed click the advanced button, then you may see a link titled `Proceed to ....(unsafe)` click that. 
  
We have had reports that some versions of Chrome will not allow you to override the page like this, for Chrome 83 at least one solution is to click in the browser window and type the words `thisisunsafe` (copy and past doesn't seem to work, you need to actually type it.) Alternatively use a different browser.


If you are presented with the login page use the Token option and the dashboard user token you got previously

<details><summary><b>If you've forgotten your dashboard user token</b></summary>
<p>
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
- Save it in a plain text editor on your laptop for easy use later
</p></details>

- Click on the `nodes` option in the `cluster` section of the UI menu on the left

![dashboard-nodes-menu](images/dashboard-nodes-menu.png)

Once you have logged in go to the nodes list (Click nodes on the upper left)

![](images/dashboard-nodes-list.png)

My cluster has 3 nodes, so there are three entries, but yours may have a different number of nodes, and thus entries.

In the Oracle Kubertnetes Environment the nodes are names based on their IP address, so 10.0.10.2, 10.0.10.3, and 10.0.10.4 in the case of this cluster.

- Click on one of the node names, in this case I chose the 10.0.10.2 node
![](images/dashboard-node-details.png)

The dashboard is showing the overview of the node, if we scroll down further we'll see the list of the pods running on it.

![](images/dashboard-node-pods.png)

The fluentd pod is running, along with a number of others, for example the elaxtic search pods, others are system pods, and our application.

If you look at all of the other nodes you'll find that there is a fluentd pod on all of them, even though the other services like storefrond or stock manager aren't running on them all (well unless you've told Kubernetes to run multiple instances of the pod)

### Looking the the data

If we go back and look at the Elastic search list of indices now we can see that some data has been added (the `?v=true` means that column headings are included the the returned data

- In a web browser go to the web page `https://<External IP>/elastic/_cat/indices?v=true`  (remember the one below is **my** ip address **you need to use yours**)


![](images/ES-some-indicies.png)

There is an index for each days data. In this case I had started the services yesterday, so data for two days was added, however you may well see only a single entry.

We can have a look at the data from a specific day

I've used the index for the data gathered most recently, as can be seen in the index listing that's `logstash-2020.04.23` **but yours will be different**

For example the URL `https://<External IP>/elastic/logstash-2020.04.23/_search`  (remember the one below is **my** ip address **you need to use yours**)

![](images/ES-quick-log-query.png)

There's a lot of data here (and depending on which browser yu use it may be nicely formated, or a pure text dump) but this has been running most of the day as I wrote this module, most interesting is that in the hits.total section we can see that there were 66177 entries, and we can see that (in this case) entry 0 is a warning from fluentd about the log data generated by the coredns container.

Of course we can focus in on specific entries if we want, in this case we're going to look for entries which have the container_name of storefront

For example the URL `https://<External IP>/elastic/logstash-2020.04.23/_search?q=kubernetes.container_name:storefront`  (remember the one below is **my** ip address **you need to use yours**)

![](images/ES-search-empty-storefront.png)

It may be empry, or you may get log messages (will really depend on if you'de used it on the chosen day)

If you haven't generated any log messages from the storefront container since we setup up the log capture just do some requests to the stock manager service which will generate log data

- In the OCI Cloud Shell terminal type (remember to replace the <external IP> with the IP address for the ingress controller for your service):
  - `curl -i -k -X GET -u jack:password https://<external IP>/store/stocklevel`
  
```
HTTP/1.1 200 OK
Server: nginx/1.17.8
Date: Thu, 23 Apr 2020 18:38:50 GMT
Content-Type: application/json
Content-Length: 149
Connection: keep-alive
Strict-Transport-Security: max-age=15724800; includeSubDomains

[{"itemCount":100,"itemName":"Book"},{"itemCount":50,"itemName":"Eraser"},{"itemCount":500,"itemName":"Pencil"},{"itemCount":5000,"itemName":"Pins"}]
```

Do this several times, then look at the log URL again

![](images/ES-search-storefront-data.png)

Now you will can see that there is data in the system, there were 12 hits.

You may have seen that the data arrived into the elastic search index pretty fast, fluentd is monitoring the log files all the time, in my testing it's usually less than a second between the log data being generated and the data being in the logs cache, though of course that can very.

### Other log capture options

Fluentd itself supports many other output plugins for writing the data, including to the OCI Object Storage service, or other services which provide a S3 compatible. We will see in the next section how to use those.

### How do I handle my Monoliths logging ?

It's quite possible (even probable) that you have elements of your overall service that are not running in micro-services in Kubernetes. To capture the log data from those applications you can run fluentd on the operating systems of the environments running them. In the case of some logging frameworks there may even be the ability to send log data direct to a central fluentd server.

Of course fluentd is not the only logging solution out there, and elastic search is not the only data storage option, after all you could also write data to an Oracle data warehouse and analyze it using Oracle Analytics !

### Log processing

Once the data has been captured there needs to be analysis of it, as we saw before it's possible to extract specific records from the storage (and far more complex queries can be constructed than those shown) but for proper data analysis we need additional tools. The usage of these tools is outside the scope of this lab, (and as you've only been gathering data for a short time period there just isn't enough log data to perform an analasys on.)

The process of data ingest and analysis is specific to the particular tool, though many can retrieve data from elasticsearch or a storage bucket, but here are some tools you may like to consider.

One such tool that is often used in conjunction with elastic search is Kibana, which is developed by the company that owns Elasticsearch. It's important to note that though parts of Kibana are open source not all the functionality is covered by the open source license, even though it may be in the Kibana container image. You must be careful to follow the licensing restrictions and of course only use the features you have access to either under the open source license or via a [license or subscription.](https://www.elastic.co/subscriptions)

The Oracle Log Analytics cloud service can be used when processing logs from many sources including on-premise and in the cloud. It's capable of [taking data direct from fluentd](https://docs.oracle.com/en/cloud/paas/management-cloud/logcs/use-fluentd-log-collection.html) or via the Oracle Object Storage Service.

The Kubernetes documentation has a [section covering logging](https://kubernetes.io/docs/concepts/cluster-administration/logging/)


## Tidying up the environment

If you are in a trial tenancy there are limitations on how many Load Balancers and other resources you can have in use at any time, and you may need them for other modules. The simplest way to release the resources used in his module (including the load balancer) is to delete the entire namespace.

- In the OCI Cloud shell type 
  - `kubectl delete namespace logging`
  
```
namespace "logging" deleted
```
  
### Summary

You've seen that the capture of Log data for Kubernetes hosted microservices is pretty easy, but so far we haven't done a lot of processing of the log data, and though we've seen we can extract the data this approach is not very useful unless you want to look at the specifics of a single log message. 

Although we haven't looked at the analysis of log data there are many tools available to help with that.