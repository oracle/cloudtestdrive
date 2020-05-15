[Go to Overview Page](../Kubernetes-labs.md)

![](../../../../common/images/customer.logo2.png)

# Migration of Monolith to Cloud Native

## C. Deploying to Kubernetes

## 7a. Service mesh basics


# NEED INTRO VIDEO 

<details><summary><b>Self guided student - video introduction</b></summary>
<p>

This video is an introduction to the Service mesh basics lab. Once you've watched it please press the "Back" button on your browser to return to the labs.

[![Kubernetes core features lab only setup Introduction Video](https://img.youtube.com/vi/kc1SvmTbvZ8/0.jpg)](https://youtu.be/kc1SvmTbvZ8 "Kubernetes core features lab introduction video")

</p>
</details>

---

## What is a service mesh

The concept behind a service mesh is pretty simple. It's basically a set of network proxies that are interposed between the containers running on a pod and the external network of the pod. This is achieved by the service mesh management capability (the control plane) which automatically adds proxies (the data plane) to the pods when the pods are started (if the pod is in a namespace that requests this via annotations)

The data plane consists of proxies which intercept the network operations of the pods and can apply rules to the data, for example encrypting data between proxies so cross microservcie connections are transparently encrypted, splitting or mirroring traffic to help with update processes, and also gathering metrics on the number of calls, how often a cross microservice call failed and such like. Of course in a non kubernetes environment you may have had your network switches or host operating systems do this, but in kubernetes the boundary between the physical and logical compute resources is blured, so using a servcie mesh allows you to have a simple implementation approach that applies regardless of if pods are running on the same node, different nodes in the same environment, or potentially even between data centres in opposite sides of the world.

The control plans does what it says on the box, it provides control functions to the data plane, for example getting and updating certificates, providing a management point so you can set the properties you want the data plane to implement (and passing those to the data plane)

The mechanisms to do this are relatively simple to the user, though the internal implementation details of a service mash can be very complex !

### What service meshes are there ?

There are multiple service mesh implementations available, a non exclusive list (there are others) includes Linkerd, Istio, Consul, Kuma, Maesh and Grey Matter. 

Most Service mesh implementations are open source to some level, but currently only [Linkerd](https://linkerd.io/) from [Buoyant Inc.](https://buoyant.io/) is listed as being a Cloud Native Computing Foundation (the governance body for open source Kubernetes related things) project though there have been press discussions that Istio may be donated by Google to an open source founcation. 

For more details on the service mesh the site [servicemesh.io](https://servicemesh.io) has lot's of interestign information, it is however run by one of the creators of linkerd so may be biased towards that. 

Currently there is no agreed standard on how to manage a service mesh, or even exactly what it does, though the [CNCF Service Mesh Interface project](https://smi-spec.io/)  is starting to define one. 

## What does that mean as an admin ?

Well the short version is that you need to be careful in choosing the right service mesh to meet your needs!

The longer version is that at least some of your concerns about managing networking within Kubernetes deployments have gone away. 

### Which service mesh to use ?

There is no simple answer to this, as none of them are built into Kubernetes and there is no official standard. 

Factors to consider are functionality, if it's fully or partially open source, what support is available (most service mesh implementations have a company behind them that provides commercial support on the open source product) and also if you want to follow the CNCF projects list or not (some Kubernetes users are only willing to consider official CNCS projects for compatibility and other reasons)

## How to install a a service mesh ?

For the purposes of this lab we've chosen to use Linkerd as it's a long standing service mesh implementation and is a CNCF supported project. It also has a reputation for being simple to install and use.

Linkerd is in two parts, the linkerd command which runs local to your environment (similar to the kubectl command) and the linkerd control pane which runs in your Kubernetes cluster (similar to the kubernetes cluster management elements) and manages the data plane.

These instructions are based on the [Getting started](https://linkerd.io/2/getting-started/) page at Linkerd.io

### Installing the linkerd client command

As linkerd is not a core Kubernetes component it's not included in the Oracle OCI Shell, so we need to do that first.

- In the OCI Cloud Shell type the follwing
  - `curl -sL https://run.linkerd.io/install | sh`
  
```
Downloading linkerd2-cli-stable-2.7.1-linux...
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100   644  100   644    0     0   1531      0 --:--:-- --:--:-- --:--:--  1529
100 34.3M  100 34.3M    0     0  30384      0  0:19:46  0:19:46 --:--:-- 34918
Download complete!

Validating checksum...
Checksum valid.

Linkerd stable-2.7.1 was successfully installed 🎉


Add the linkerd CLI to your path with:

  export PATH=$PATH:/home/tim_graves/.linkerd2/bin

Now run:

  linkerd check --pre                     # validate that Linkerd can be installed
  linkerd install | kubectl apply -f -    # install the control plane into the 'linkerd' namespace
  linkerd check                           # validate everything worked!
  linkerd dashboard                       # launch the dashboard

Looking for more? Visit https://linkerd.io/2/next-steps
```
  
Warning, this may take a while to run, in my case about 20 mins because the OCI Cloud shell system does not provide huge throughput as it's designed for management activities, not running applications !
  
Now we need to add it to our path

- In the OCI Cloud Shell type :
  - `export PATH=$PATH:$HOME/.linkerd2/bin`
  
This is only a temporary change, that applies to the current OCI Cloud shell session. To make it permanent we need to edit the $HOME/.bashrc file

- Use your preferred editor (vi, vim, nano etc.) edit $HOME/.bashrc

- At the end of the file add and new line containing `export PATH=$PATH:$HOME/.linkerd2/bin`

Lastly let's check the status of the linkerd installation

- In the OCI Cloud Shell type
  - `linkerd version`

```
Client version: stable-2.7.1
Server version: unavailable
```

The server is unavailable because we haven't installed it yet. The version numbers will of course change over time, but these are the ones when this lab module was written.



### Installing linkerd into your Kubernetes cluster

Though we have the linkerd client application we still need to install the linkerd control plan in our clouster (The control plan will handle deploying the data plane)

Firstly let's make sure that the cluster meets the requirements to deploy linkerd

- In the OCI Cloud shell type :
  - `linkerd check --pre`
  
```
kubernetes-api
--------------
√ can initialize the client
√ can query the Kubernetes API

kubernetes-version
------------------
√ is running the minimum Kubernetes API version
√ is running the minimum kubectl version

pre-kubernetes-setup
--------------------
√ control plane namespace does not already exist
√ can create non-namespaced resources
√ can create ServiceAccounts
√ can create Services
√ can create Deployments
√ can create CronJobs
√ can create ConfigMaps
√ can create Secrets
√ can read Secrets
√ no clock skew detected

pre-kubernetes-capability
-------------------------
√ has NET_ADMIN capability
√ has NET_RAW capability

linkerd-version
---------------
√ can determine the latest version
√ cli is up-to-date

Status check results are √
```

The pre-install check that the Kubernetes cluster (and the configuration of kubectl) is able to install linkerd. All the checks have passed (the tick by each line) so we're good to install the linkerd control plane.

The linkerd control plan process used the linkerd command to generate the configuration yaml, which is then processed by kubectl. 

- In the OCI Cloud Shell type
  - `linkerd install | kubectl apply -f -`
  
```
linkerd install | kubectl apply -f -
namespace/linkerd created
clusterrole.rbac.authorization.k8s.io/linkerd-linkerd-identity created
clusterrolebinding.rbac.authorization.k8s.io/linkerd-linkerd-identity created
serviceaccount/linkerd-identity created
clusterrole.rbac.authorization.k8s.io/linkerd-linkerd-controller created
clusterrolebinding.rbac.authorization.k8s.io/linkerd-linkerd-controller created
serviceaccount/linkerd-controller created
... lots more created messages...
service/linkerd-tap created
deployment.apps/linkerd-tap created
```
  
<details><summary><b>If you want to see exactly what is being done</b></summary>
<p>

To find out exactly what linkerd is going to install we can execute it without sending the output to kubectl. There is a lot of output, so we're going to redirect it to a file

- In the OCI Cloud Shell type
  - `linkerd install > /tmp/linkerd-install-output`

To see the YAML

- In the OCI Cloud Shell type
  - `more /tmp/linkerd-install-output`
  
```
---
###
### Linkerd Namespace
###
---
kind: Namespace
apiVersion: v1
metadata:
  name: linkerd
  annotations:
    linkerd.io/inject: disabled
  labels:
    linkerd.io/is-control-plane: "true"
    config.linkerd.io/admission-webhooks: disabled
---
###
### Identity Controller Service RBAC
###
---
kind: ClusterRole
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: linkerd-linkerd-identity
  labels:
    linkerd.io/control-plane-component: identity
    linkerd.io/control-plane-ns: linkerd

... lots more yaml output...
```

There is a lot of output here, we've only seen the beginning of it above

---

</p></details>

Linkerd creates it's own namespace so we can chesk what's in there using kubectl 

- In the OCI Cloud shell type 
  - `kubectl get namespaces`

```
NAME              STATUS   AGE
default           Active   29d
ingress-nginx     Active   28d
kube-node-lease   Active   29d
kube-public       Active   29d
kube-system       Active   29d
linkerd           Active   63s
logging           Active   7d22h
monitoring        Active   27d
tg-helidon        Active   27d
```

And we can see what's in the linkerd namespace

- In the OCI Cloud shell type
  - `kubectl get all -n linkerd`

```
NAME                                          READY   STATUS    RESTARTS   AGE
pod/linkerd-controller-5747df4f94-qxx9s       2/2     Running   0          2m18s
pod/linkerd-destination-554b6cc765-wmwkt      2/2     Running   0          2m18s
pod/linkerd-grafana-cdffd746f-f4jgb           2/2     Running   0          2m18s
pod/linkerd-identity-7b8c5df854-cf6b2         2/2     Running   0          2m18s
pod/linkerd-prometheus-699c66d6b6-2scsz       2/2     Running   0          2m18s
pod/linkerd-proxy-injector-64658cb549-jshdz   2/2     Running   0          2m18s
pod/linkerd-sp-validator-67b765dc6d-n9wzg     2/2     Running   0          2m17s
pod/linkerd-tap-7479dc4777-z7nxs              2/2     Running   0          2m17s
pod/linkerd-web-86d9856cff-ph7ct              2/2     Running   0          2m18s


NAME                             TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)             AGE
service/linkerd-controller-api   ClusterIP   10.96.119.245   <none>        8085/TCP            2m18s
service/linkerd-dst              ClusterIP   10.96.14.26     <none>        8086/TCP            2m18s
service/linkerd-grafana          ClusterIP   10.96.183.225   <none>        3000/TCP            2m18s
service/linkerd-identity         ClusterIP   10.96.130.48    <none>        8080/TCP            2m18s
service/linkerd-prometheus       ClusterIP   10.96.133.113   <none>        9090/TCP            2m18s
service/linkerd-proxy-injector   ClusterIP   10.96.190.92    <none>        443/TCP             2m18s
service/linkerd-sp-validator     ClusterIP   10.96.0.227     <none>        443/TCP             2m17s
service/linkerd-tap              ClusterIP   10.96.196.4     <none>        8088/TCP,443/TCP    2m17s
service/linkerd-web              ClusterIP   10.96.182.13    <none>        8084/TCP,9994/TCP   2m18s


NAME                                     READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/linkerd-controller       1/1     1            1           2m18s
deployment.apps/linkerd-destination      1/1     1            1           2m18s
deployment.apps/linkerd-grafana          1/1     1            1           2m18s
deployment.apps/linkerd-identity         1/1     1            1           2m18s
deployment.apps/linkerd-prometheus       1/1     1            1           2m18s
deployment.apps/linkerd-proxy-injector   1/1     1            1           2m18s
deployment.apps/linkerd-sp-validator     1/1     1            1           2m17s
deployment.apps/linkerd-tap              1/1     1            1           2m17s
deployment.apps/linkerd-web              1/1     1            1           2m18s

NAME                                                DESIRED   CURRENT   READY   AGE
replicaset.apps/linkerd-controller-5747df4f94       1         1         1       2m18s
replicaset.apps/linkerd-destination-554b6cc765      1         1         1       2m18s
replicaset.apps/linkerd-grafana-cdffd746f           1         1         1       2m18s
replicaset.apps/linkerd-identity-7b8c5df854         1         1         1       2m18s
replicaset.apps/linkerd-prometheus-699c66d6b6       1         1         1       2m18s
replicaset.apps/linkerd-proxy-injector-64658cb549   1         1         1       2m18s
replicaset.apps/linkerd-sp-validator-67b765dc6d     1         1         1       2m17s
replicaset.apps/linkerd-tap-7479dc4777              1         1         1       2m17s
replicaset.apps/linkerd-web-86d9856cff              1         1         1       2m18s




NAME                              SCHEDULE       SUSPEND   ACTIVE   LAST SCHEDULE   AGE
cronjob.batch/linkerd-heartbeat   14 14 * * *    False     0        <none>          2m18s
```

Linkerd has created a number of items, but note that all of the pods have 2 instances (for high availability) and that among other services linkerd has created it's own Prometheus and Grafana instalations.

Let's get linkerd to check that it's been installed correctly and everything is running.

- In the OCI Cloud Shell type
  - `linkerd check`
  
```
kubernetes-api
--------------
√ can initialize the client
√ can query the Kubernetes API

kubernetes-version
------------------
√ is running the minimum Kubernetes API version
√ is running the minimum kubectl version

linkerd-existence
-----------------
√ 'linkerd-config' config map exists
√ heartbeat ServiceAccount exist
√ control plane replica sets are ready
√ no unschedulable pods
√ controller pod is running
√ can initialize the client
√ can query the control plane API

linkerd-config
--------------
√ control plane Namespace exists
√ control plane ClusterRoles exist
√ control plane ClusterRoleBindings exist
√ control plane ServiceAccounts exist
√ control plane CustomResourceDefinitions exist
√ control plane MutatingWebhookConfigurations exist
√ control plane ValidatingWebhookConfigurations exist
√ control plane PodSecurityPolicies exist

linkerd-identity
----------------
√ certificate config is valid
√ trust roots are using supported crypto algorithm
√ trust roots are within their validity period
√ trust roots are valid for at least 60 days
√ issuer cert is using supported crypto algorithm
√ issuer cert is within its validity period
√ issuer cert is valid for at least 60 days
√ issuer cert is issued by the trust root

linkerd-api
-----------
√ control plane pods are ready
√ control plane self-check
√ [kubernetes] control plane can talk to Kubernetes
√ [prometheus] control plane can talk to Prometheus
√ tap api service is running

linkerd-version
---------------
√ can determine the latest version
√ cli is up-to-date

control-plane-version
---------------------
√ control plane is up-to-date
√ control plane and cli versions match

Status check results are √
```

If the linkerd environment is not yet running the check will block until the services are starting.

You can see that everything is running fine, there is a lot more output as the check confirms that linkerd itself has all the elements it needs to operate, and it is working fine.

## Configuring access to the linkerd UI

Linkerd is managed via the linkerd command OR via it's browser based dashboard. In general you want to use the dashboard as it give you access to the Grafana instance provided by Linkerd and thus you get the visualizations.

There are several ways to access the linkerd dashboard. In a production deployment you would use an ingress with very strict security rules, and configure linkerd to only accept external connections via that ingress, but to implement that requires the use of a certificate and DNS configuration.

For ease of setting up the lab we are going to use an ingress but relax the security constraints around accessing the linkerd web front end a bit **YOU SHOULD NEVER DO THIS IN A PRODUCTION ENVIRONMENT** A service mesh like linkerd controls the entire communications network in your cluster, unauthorized access to it would enable hackers to have complete control of your cluster.


### Removing the linkerd-web hosts restriction

The first thing we need to do is to remove the restriction in the linkerd web front end on which hosts are allowed to access the web front end. Of course you would not do this in a production system !

edit the linkerd web deployment yaml normally would not do

- In the OCI Cloud shell type
  - `kubectl edit deployment linkerd-web -n linkerd`
  
- In the spec.template.spec.containers.args locate the line that is like `- -enforced-host=^(localhost|127\\.0\\.0\\.1|linkerd-web\\.linkerd\\.svc\\.cluster\\.local|linkerd-web\\.linkerd\\.svc|\\[::1\\])(:\\d+)?$`

- Remove all of the value section of the line after the `=` the new line will look like

``` 
        - -enforced-host=
```

- Save the changes

kubectl will pick them up and apply them, kubernetes will restart the linkerd-web deployment withthe new arguments and linkerd-web will no longer enforce the check on the hostnames.


### Create a TLS secret

Curiously the linkerd-web ingress does not use a TLS certificate to ensure that the connection to it is encrtyped, as we will be sending passwords we want to ensure it is encrypted, to do which we need to create a TLS secret in kubernetes that the ingress controller can use.

Change to the directory for the service mesh scripts

- In the OCI Cloud shell type
  - `cd $HOME/helidon-kubernetes/management/servicemesh`

Create a TLS Secret in the linkerd namespace to use to secure the connection (do anyway)

- In the OCI CLoud shell type
  - `openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout tls-linkerd.key -out tls-linkerd.crt -subj "/CN=nginxsvc/O=nginxsvc"`

```
Generating a 2048 bit RSA private key
.....................................+++
...+++
writing new private key to 'tls-linkerd.key'
-----
```

Now create a kubernetes TLS secret from the key and certificate

- In the OCI CLoud shell type
  - `kubectl create secret tls tls-linkerd-secret --key tls-linkerd.key --cert tls-linkerd.crt -n linkerd`

```
secret/tls-linkerd-secret created
```

### Create a login password to secure the connection

The default configuration for the linkerd-web service includes a password of admin/admin. Obviously this is for demo purposed, we want to use something more secure (and of course you **must** to this in a production environment !)

First let's create a password file for the admin user. In the example below I'm using `ZaphodBeeblebrox` as the password, but please feel free to change this if you like

- In the OCI Cloud Shell type
  - `htpasswd -c -b auth admin ZaphodBeeblebrox`

```
Adding password for user admin
```

Now having create the password file we need to add it to kuberntes as a secret so the ingress controller can use it.

- In the OCI Cloud Shell type
  - `kubectl create secret generic web-ingress-auth -n linkerd --from-file=auth`

```
secret/web-ingress-auth created
```

### Creating the ingress rule itself

We are now going to create the ingress rule. This is based on the example on the linkerd website, but with the following changes: 

It does not define the web authentication secret (we did that above)

It does not specify the hostname the server is running on (that would require the creation of the DNS entries which takes time)

If specified the TLS secret we defined above so the connection is secure

Though these are not perfect they do ensure that users need to be authenticated and that their authentication details are protected by using an encrypted connection.

- In the OCI Cloud Shell type
  - `kubectl apply -f linkerd-ingress.yaml`
  
```
ingress.extensions/web-ingress created
```

Now you can go to the ingress ip address 

- In your laptop web browser go to `https://<external IP>`

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

---
</p></details>

You will probably be challenged as you have a self signed certificate. Follow the normal procedures in your browser to accept the connection and proceed.

Next you will be presented with the login challenge.

![](images/linkerd-web-login.png)

Login with `admin` as the username, for the password use the one you used when creating the login password above. Some browsers offer the change to remember the password details for later use. Feel free to do so if you like, or if you prefer you can re-enter the username and password when prompted by the browser.

You'll be presented with the linkerd-web main page

![](images/linkerd-web-main-page.png)

Let's also check you can access the grafana dashboard that's been installed by linkerd

- In your web browser go to `https://<externalIP>/grafana` Note if you dod not save the username / password details you may be prompted to re-enter tham

![](images/linkerd-grafana-initial-topline.png)

<details><summary><b>Other options for linkerd access</b></summary>
<p>

Exposing linkerd via an ingress allows anyone who has access to the external point of the ingress to access it. This may be required due to the way your organization operates, but you can also restrict access to the linkerd UI by using the linkerd command to setup a secure tunnel for you.

On your local laptop (which must already be configured with the appropriate kuberntes configuration and other credentials your provider may require)

- Open a terminal window and type
  - `linkerd dashboard`

```
Linkerd dashboard available at:
http://localhost:50750
Grafana dashboard available at:
http://localhost:50750/grafana
Opening Linkerd dashboard in the default browser
Failed to open Linkerd dashboard automatically
```

This will setup the tunnel for you. You can then access linkerd and the grafana environment using the url's above. Normally this command will open a web connection for you, but in this case I was using a remote terminal with no graphical desktop available, so running a web browser was not possible.

---
</p></details>

---

You have reached the end of this lab modules !!

Use your **back** button to return to the lab sequence document and to access the modules on how to apply the service mesh to your deployments and how to use it for tasks like intelligent upgrades.