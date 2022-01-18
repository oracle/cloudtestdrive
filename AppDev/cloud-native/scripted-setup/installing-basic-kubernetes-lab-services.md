![](../../../common/images/customer.logo2.png)

# Installing the core kubernetes lab services

You can of course if you wish setup the core services in the Kubernetes lab by hand, and if you have done the core Kubernetes lab you will probably have done so - in which case you can re-use that environment if it's still available to you.

If however you are doing a more focused lab where you don't want to be setting up the core Kubernetes services, but are for example planning on examining just the features like the service mesh or DevOps then I have provided a script that will basically automatically perform all of the steps that you would previously have done manually in the basic Kubernetes labs.

### Objectives

To use the scripts to setup the core Kubernrtes services

### Prerequisites

You must have setup the compartment, database (including setting up the labs user and downloading the Wallet.zip file) and Kubernetes cluster (including downloading the kubectl config file, and naming the clusters context as "one"). You can have done this by hand or by using the scripts as detailed in the **Setting up the OCI environment using scripts** module.

### When not to use these scripts 

If you have got a Kubernetes cluster running and have setup all of the services as described in the base kubernetes lab (so Ingress controller, Kubernetes Dashboard, Services / Ingress rules / configuration (config  map / secrets) / Deployments for the Storefront / Stockmanager / Zipkin microservices. Using this script if those already exist may result in an inconsistent state.

## Task 1: Downloading the latest scripts

**If you have recently downloaded the git repo (within a day or two) then you do not need to do this task, please proceed to Task 2**

There are a number of scripts that we have created for this lab to make life easier, if you have previously downloaded those then you should ensure you have the latest version, if you haven't downloaded them then you will need to do so.

If you are not sure if you have downloaded the lates version then you can check

  - In the OCI Cloud shell type 
  
  - `ls $HOME/helidon-kubernetes`

If you get output like this then you need to download the scripts, follow the process in **Task 1a**

```
ls: cannot access /home/tim_graves/helidon-kubernetes: No such file or directory
```

If you get output similar to this (the file names and count may vary slightly as the lab evolves) then you have downloaded the scripts previously, but you should get the latest versions, please follow the steps in **Task 1b**

```
base-kubernetes          configurations       deploy.sh   monitoring-kubernetes  README.md     servicesClusterIP.yaml  stockmanager-deployment.yaml  undeploy.sh
cloud-native-kubernetes  create-test-data.sh  management  README                 service-mesh  setup                   storefront-deployment.yaml    zipkin-deployment.yaml
```

### Task 1a: Downloading the scripts

We will use git to download the scripts

  1. Open the OCI Cloud Shell

  2. Make sure you are in the top level directory
  
  - `cd $HOME`
  
  3. Clone the repository with all scripts from github into your OCI Cloud Shell environment
  
  - `git clone https://github.com/CloudTestDrive/helidon-kubernetes.git`
  
  ```
  Cloning into 'helidon-kubernetes'...
remote: Enumerating objects: 723, done.
remote: Counting objects: 100% (723/723), done.
remote: Compressing objects: 100% (452/452), done.
remote: Total 723 (delta 423), reused 537 (delta 249), pack-reused 0
Receiving objects: 100% (723/723), 110.23 KiB | 0 bytes/s, done.
Resolving deltas: 100% (423/423), done.
```

Note that the precise details will vary as the lab is updated over time.

Please go to **Task 2**

### Task 1b: Updating the scripts

We will use git to update the scripts

  1. Open the OCI Cloud shell type
  
  2. Make sure you are in the home directory
  
  - `cd $HOME/helidon-kubernetes`
  
  3. Use git to get the latest updates
  
  - `git pull`

```
remote: Enumerating objects: 21, done.
remote: Counting objects: 100% (21/21), done.
remote: Compressing objects: 100% (8/8), done.
remote: Total 14 (delta 6), reused 14 (delta 6), pack-reused 0
Unpacking objects: 100% (14/14), done.
From https://github.com/CloudTestDrive/helidon-kubernetes
   51c1ba8..f3845ad  master     -> origin/master
Updating 51c1ba8..f3845ad
Fast-forward
 setup/common/compartment-destroy.sh                 | 50 ++++++++++++++++++++++++++++++++++++++++++++++++++
 setup/common/compartment-setup.sh                   | 14 ++++++++++++++
 setup/common/database-destroy.sh                    | 38 ++++++++++++++++++++++++++++++++++++++
 setup/common/database-setup.sh                      | 15 ++++++++++++++-
 setup/common/delete-from-saved-settings.sh          | 12 ++++++++++++
 setup/common/initials-destroy.sh                    |  3 +++
 setup/common/{get-initials.sh => initials-setup.sh} |  2 +-
 setup/common/kubernetes-destroy.sh                  | 57 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 setup/common/kubernetes-setup.sh                    | 24 ++++++++++++++++++------
 setup/common/oke-terraform.tfvars                   |  2 ++
 10 files changed, 209 insertions(+), 8 deletions(-)
 create mode 100644 setup/common/compartment-destroy.sh
 create mode 100644 setup/common/database-destroy.sh
 create mode 100644 setup/common/delete-from-saved-settings.sh
 create mode 100644 setup/common/initials-destroy.sh
 rename setup/common/{get-initials.sh => initials-setup.sh} (89%)
 create mode 100644 setup/common/kubernetes-destroy.sh
```

Note that the output will vary depending on exactly what changes have been made since you first download the scripts or last updated them.

Please continue with **Task 2**

## Task 2: Running the Kubernetes setup scripts

This script will configure the database settings using information in the Wallet.zip file, will setup various database related variables, will then setup the Helm repo, install the Ingress controller and Kubernetes dashboard, then create a namespace for your work, configure and install the Services, Ingress rules, configuration information and deployments. Lastly it will check if all this correctly deployed.

  1. If you have not already done so open the OCI Cloud shell and go to the scripts directory 
  
  - `cd $HOME/helidon-kubernetes/setup/kubernetes-labs`
  
  2/ Run the installation script, you will need to replace `<your initials>` with your personal initials, or first name in **lower case** (singluar or plural). For example my name is Tim Graves, so my initials will be tg, or I might use `tim` or `tims`. Of course unless your name is also Tim Graves yoiu will be using a different value. If you are running a version of the lab where multiple people are using the same tenancy (your instructor will notify you of this, most people will be using their own free trial) please ensure that you do not duplicate this value.
  
  - `bash ./configureGitAndFullyInstallCluster.sh <your initials>`
  
  ```
  setting up config in downloaded git repo using tims as the department name one as the kubernetes context and /home/tim_graves/Wallet.zip as the DB wallet file.
Proceed ? 
```

  - Assuming you are happy with this press `y` to continue... There will be a lot of output as the script will basically go through all of the steps you would have performed manually in the base kubernetes lab. This process will take upto 5 minutes (but it's a lot faster and less prone to errors than performing all the commands by hand !)
  
<details><summary><b>example output if you want to see it</b></summary>  

  ```
Context one found
Configuring base location variables
Configuring helm
Creating helm repo entries
"kubernetes-dashboard" already exists with the same configuration, skipping
"ingress-nginx" already exists with the same configuration, skipping
"prometheus-community" already exists with the same configuration, skipping
"grafana" already exists with the same configuration, skipping
"elastic" already exists with the same configuration, skipping
"bitnami" already exists with the same configuration, skipping
Updating helm repos
Hang tight while we grab the latest from your chart repositories...
...Successfully got an update from the "kubernetes-dashboard" chart repository
...Successfully got an update from the "ingress-nginx" chart repository
...Successfully got an update from the "elastic" chart repository
...Successfully got an update from the "fluxcd" chart repository
...Successfully got an update from the "grafana" chart repository
...Successfully got an update from the "prometheus-community" chart repository
...Successfully got an update from the "bitnami" chart repository
Update Complete. ⎈Happy Helming!⎈
Saving current context of one and switching to one
Skipping confirmation, switching the kubernetes context to one - this will apply across all calls unless you overrite using --context=<name> or switch to a new default context
Switched to context "one".
Switched, new default context is is
one
Skipping configure-repo confirmation using tims as the deparment name and /home/tim_graves/Wallet.zip as the DB wallet file
Skipping stockmanager department setup confirmation using tims as the department name
Updating the stockmanager config in /home/tim_graves/helidon-kubernetes/configurations/stockmanagerconf/conf/stockmanager-config.yaml to set tims as the department name
Skipping db wallet install confirmation
Initiing wallet Directory
Installing DB wallet in /home/tim_graves/Wallet.zip into config
Archive:  /home/tim_graves/Wallet.zip
  inflating: README                  
  inflating: cwallet.sso             
  inflating: tnsnames.ora            
  inflating: truststore.jks          
  inflating: ojdbc.properties        
  inflating: sqlnet.ora              
  inflating: ewallet.p12             
  inflating: keystore.jks            
Skipping database connection secret confirmation
Updating the database connection secret config in /home/tim_graves/helidon-kubernetes/configurations/stockmanagerconf/databaseConnectionSecret.yaml to set tgdemo_high as the database connection
Skipping fully install cluster confirmation, will setup using  tims as the department name one is the kubernetes current context name and /home/tim_graves/Wallet.zip as the DB wallet file
Skipping fully install cluster confirmation one is the kubernetes cluster name
reseting cluster info file
reset cluster settings file
Getting helm chart versions
Create ingress namespace
namespace/ingress-nginx created
install Ingress using helm
NAME: ingress-nginx
LAST DEPLOYED: Tue Nov 23 20:39:46 2021
NAMESPACE: ingress-nginx
STATUS: deployed
REVISION: 1
TEST SUITE: None
NOTES:
The ingress-nginx controller has been installed.
It may take a few minutes for the LoadBalancer IP to be available.
You can watch the status by running 'kubectl --namespace ingress-nginx get services -o wide -w ingress-nginx-controller'

An example Ingress that makes use of the controller:

  apiVersion: networking.k8s.io/v1beta1
  kind: Ingress
  metadata:
    annotations:
      kubernetes.io/ingress.class: nginx
    name: example
    namespace: foo
  spec:
    rules:
      - host: www.example.com
        http:
          paths:
            - backend:
                serviceName: exampleService
                servicePort: 80
              path: /
    # This section is only required if TLS is to be enabled for the Ingress
    tls:
        - hosts:
            - www.example.com
          secretName: example-tls

If TLS is enabled for the Ingress, a Secret containing the certificate and key must also be provided:

  apiVersion: v1
  kind: Secret
  metadata:
    name: example-tls
    namespace: foo
  data:
    tls.crt: <base64 encoded cert>
    tls.key: <base64 encoded key>
  type: kubernetes.io/tls
Helm for ingress completed - It may take a while to get the external IP address of the ingress load ballancer
Waiting for ingress external IP
Waiting for ingress external IP
Waiting for ingress external IP
Waiting for ingress external IP
Waiting for ingress external IP
Ingress controller external IP is  123.456.789.123
installing dashboard using helm
NAME: kubernetes-dashboard
LAST DEPLOYED: Tue Nov 23 20:40:39 2021
NAMESPACE: kube-system
STATUS: deployed
REVISION: 1
TEST SUITE: None
NOTES:
*********************************************************************************
*** PLEASE BE PATIENT: kubernetes-dashboard may take a few minutes to install ***
*********************************************************************************
From outside the cluster, the server URL(s) are:
     https://dashboard.kube-system.123.456.789.123.nip.io
Helm for dashboard completed - it may take a while for the dashboard to be running
Installing dashboard user
serviceaccount/dashboard-user created
clusterrole.rbac.authorization.k8s.io/kubernetes-dashboard-role created
clusterrolebinding.rbac.authorization.k8s.io/dashboard-user created
getting dashboard token
Dashboard token is eyJhbGciOiJSUzI1NiIsImtpZCI6IkkxN3dTdEZFV2JsdXFieHVwYlJCcUhpZmVGQlZTM3NPV3lRUVdBVmthMUEifQ.eyJpc3MiOiJrdWJlcm5ldGVzL3NlcnZpY2VhY2NvdW50Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9uYW1lc3BhY2UiOiJrdWJlLXN5c3RlbSIsImt1YmVybmV0ZXMuaW8vc2VydmljZWFjY291bnQvc2VjcmV0Lm5hbWUiOiJkYXNoYm9hcmQtdXNlci10b2tlbi13NTRxNyIsImt1YmVybmV0ZXMuaW8vc2VydmljZWFjY291bnQvc2VydmljZS1hY2NvdW50Lm5hbWUiOiJkYXNoYm9hcmQtdXNlciIsImt1YmVybmV0ZXMuaW8vc2VydmljZWFjY291bnQvc2VydmljZS1hY2NvdW50LnVpZCI6Ijc4MDM5YTQ5LWYzZDMtNDg1My1iYzJkLTliNTAzYTBmOTZlYSIsInN1YiI6InN5c3RlbTpzZXJ2aWNlYWNjb3VudDprdWJlLXN5c3RlbTpkYXNoYm9hcmQtdXNlciJ9.on_Xsa_MZpxnw8MghXr853C064VRtPB6wLbi7-oIY-TSodOT6ym3G7_eKlXGEx-GUxa3YZJ0EYWVSmieub7i_bYOU7jzGS2FYovnvlNsSOCwK9J3s8BReGVle44YTuQEbhmztrS8i6LgxarPoUlbYQ4_4Vn6nxVhv4tt0oimg9Hvv5rBIidlMNGmpsAFb8CaI18WQGNqCKdC9EumaYj1ZGlmqxYX_nOC617u_1lDWVO3nKEXR4KPAE963jl46zbVkwWnxKaDX1LEqEiM9HI5q5wg8G8qMVYwhcCS0xIOpIBbvB0FGAzO6zEdnwtOTmMvauJTx1diPex4hua_i9tAmw
saving External IP for later use
updating base ingress rules
Skipping ingress rule setup confirmation
Updating ingress rules - setting 123.456.789.123 as the external IP address
Skipping ingress rule setup confirmation
Templating ingress rules - updating the template ingress rules yaml in /home/tim_graves/helidon-kubernetes/base-kubernetes setting 123.456.789.123 as the external IP address
Templating /home/tim_graves/helidon-kubernetes/base-kubernetes/ingressStockmanagerRules.yaml to /home/tim_graves/helidon-kubernetes/base-kubernetes/ingressStockmanagerRules-one.yaml
Templating /home/tim_graves/helidon-kubernetes/base-kubernetes/ingressStockmanagerRules.yaml replacing ${EXTERNAL_IP}.nip.io with 123.456.789.123.nip.io to destination /home/tim_graves/helidon-kubernetes/base-kubernetes/ingressStockmanagerRules-one.yaml
Templating /home/tim_graves/helidon-kubernetes/base-kubernetes/ingressStorefrontRules.yaml to /home/tim_graves/helidon-kubernetes/base-kubernetes/ingressStorefrontRules-one.yaml
Templating /home/tim_graves/helidon-kubernetes/base-kubernetes/ingressStorefrontRules.yaml replacing ${EXTERNAL_IP}.nip.io with 123.456.789.123.nip.io to destination /home/tim_graves/helidon-kubernetes/base-kubernetes/ingressStorefrontRules-one.yaml
Templating /home/tim_graves/helidon-kubernetes/base-kubernetes/ingressZipkinRules.yaml to /home/tim_graves/helidon-kubernetes/base-kubernetes/ingressZipkinRules-one.yaml
Templating /home/tim_graves/helidon-kubernetes/base-kubernetes/ingressZipkinRules.yaml replacing ${EXTERNAL_IP}.nip.io with 123.456.789.123.nip.io to destination /home/tim_graves/helidon-kubernetes/base-kubernetes/ingressZipkinRules-one.yaml
updating service mesh ingress rules
Skipping ingress rule setup confirmation
Updating service mesh ingress rules - setting 123.456.789.123 as the external IP address
Skipping ingress rule setup confirmation
Templating ingress rules - updating the template ingress rules yaml in /home/tim_graves/helidon-kubernetes/service-mesh setting 123.456.789.123 as the external IP address
Templating /home/tim_graves/helidon-kubernetes/service-mesh/ingressFaultInjectorRules.yaml to /home/tim_graves/helidon-kubernetes/service-mesh/ingressFaultInjectorRules-one.yaml
Templating /home/tim_graves/helidon-kubernetes/service-mesh/ingressFaultInjectorRules.yaml replacing ${EXTERNAL_IP}.nip.io with 123.456.789.123.nip.io to destination /home/tim_graves/helidon-kubernetes/service-mesh/ingressFaultInjectorRules-one.yaml
Templating /home/tim_graves/helidon-kubernetes/service-mesh/ingressLinkerdRules.yaml to /home/tim_graves/helidon-kubernetes/service-mesh/ingressLinkerdRules-one.yaml
Templating /home/tim_graves/helidon-kubernetes/service-mesh/ingressLinkerdRules.yaml replacing ${EXTERNAL_IP}.nip.io with 123.456.789.123.nip.io to destination /home/tim_graves/helidon-kubernetes/service-mesh/ingressLinkerdRules-one.yaml
Templating /home/tim_graves/helidon-kubernetes/service-mesh/ingressStockmanagerCanaryRules.yaml to /home/tim_graves/helidon-kubernetes/service-mesh/ingressStockmanagerCanaryRules-one.yaml
Templating /home/tim_graves/helidon-kubernetes/service-mesh/ingressStockmanagerCanaryRules.yaml replacing ${EXTERNAL_IP}.nip.io with 123.456.789.123.nip.io to destination /home/tim_graves/helidon-kubernetes/service-mesh/ingressStockmanagerCanaryRules-one.yaml
Skipping entire stack confirmation, setting up config in downloaded git repo using tims as the department name 123.456.789.123 as the ingress controller IP address one is the current kubernetes context name
Setup namespace
Deleting old tims namespace
Creating new tims namespace
namespace/tims created
Setting default kubectl namespace
Context "one" modified.
Creating tls store secret
removing existing certs
creating tls secret using step with common name of store.123.456.789.123.nip.io
Your certificate has been saved in tls-store-123.456.789.123.crt.
Your private key has been saved in tls-store-123.456.789.123.key.
removing any existing tls-store secret
creating new tls-store secret
secret/tls-store created
Created secret
Deleting existing services
Storefront
Stockmanager
Zipkin
Deleted services
Services remaining in namespace are
No resources found in tims namespace.
Creating services
Zipkin
service/zipkin created
Stockmanager
service/stockmanager created
Storefront
service/storefront created
Current services in namespace are
NAME           TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)             AGE
stockmanager   ClusterIP   10.96.106.152   <none>        8081/TCP,9081/TCP   3s
storefront     ClusterIP   10.96.16.17     <none>        8080/TCP,9080/TCP   2s
zipkin         ClusterIP   10.96.174.94    <none>        9411/TCP            5s
Applying /home/tim_graves/helidon-kubernetes/base-kubernetes/ingressStockmanagerRules-one.yaml
ingress.networking.k8s.io/stockmanager-direct-ingress created
ingress.networking.k8s.io/stockmanager-rewrite-ingress created
Applying /home/tim_graves/helidon-kubernetes/base-kubernetes/ingressStorefrontRules-one.yaml
ingress.networking.k8s.io/storefront-direct-ingress created
ingress.networking.k8s.io/storefront-rewrite-ingress created
Applying /home/tim_graves/helidon-kubernetes/base-kubernetes/ingressZipkinRules-one.yaml
ingress.networking.k8s.io/zipkin-direct-ingress created
Deleting existing store front secrets
sf-conf
Deleting existing stock manager secrets
sm-conf
sm-wallet-atp
stockmanagerdb
Deleted secrets
Secrets remaining in namespace are
NAME                  TYPE                                  DATA   AGE
default-token-cfh48   kubernetes.io/service-account-token   3      29s
tls-store             kubernetes.io/tls                     2      26s
Creating stock manager secrets
stockmanagerdb
secret/stockmanagerdb created
sm-wallet-atp
secret/sm-wallet-atp created
Creating stockmanager secrets
secret/sm-conf-secure created
Creating store front secrets
secret/sf-conf-secure created
Existing in namespace are
NAME                  TYPE                                  DATA   AGE
default-token-cfh48   kubernetes.io/service-account-token   3      36s
sf-conf-secure        Opaque                                1      1s
sm-conf-secure        Opaque                                1      3s
sm-wallet-atp         Opaque                                9      4s
stockmanagerdb        Opaque                                6      6s
tls-store             kubernetes.io/tls                     2      33s
Deleting existing config maps
sf-config-map
sm-config-map
Config Maps remaining in namespace are
NAME               DATA   AGE
kube-root-ca.crt   1      40s
Creating config maps
sf-config-map
configmap/sf-config-map created
sm-config-map
configmap/sm-config-map created
Existing in namespace are
NAME               DATA   AGE
kube-root-ca.crt   1      44s
sf-config-map      2      3s
sm-config-map      2      2s
Creating zipkin deployment
deployment.apps/zipkin created
Creating stockmanager deployment
deployment.apps/stockmanager created
Creating storefront deployment
deployment.apps/storefront created
Kubenetes config is
NAME                                READY   STATUS              RESTARTS   AGE
pod/stockmanager-6b759ddcd7-49t2g   1/1     Running             0          3s
pod/storefront-74d6d55dcc-gpxtn     0/1     ContainerCreating   0          1s
pod/zipkin-55c5b96f9d-7rpr5         1/1     Running             0          4s

NAME                   TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)             AGE
service/stockmanager   ClusterIP   10.96.106.152   <none>        8081/TCP,9081/TCP   37s
service/storefront     ClusterIP   10.96.16.17     <none>        8080/TCP,9080/TCP   36s
service/zipkin         ClusterIP   10.96.174.94    <none>        9411/TCP            39s

NAME                           READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/stockmanager   1/1     1            1           4s
deployment.apps/storefront     0/1     1            0           2s
deployment.apps/zipkin         1/1     1            1           5s

NAME                                      DESIRED   CURRENT   READY   AGE
replicaset.apps/stockmanager-6b759ddcd7   1         1         1       4s
replicaset.apps/storefront-74d6d55dcc     1         1         0       2s
replicaset.apps/zipkin-55c5b96f9d         1         1         1       5s
checking https://store.123.456.789.123.nip.io/store/stocklevel for a 200 response
Waiting for services to start
Creating test data
Service IP address is 123.456.789.123
HTTP/1.1 500 Internal Server Error
Date: Tue, 23 Nov 2021 20:42:57 GMT
Content-Length: 0
Connection: keep-alive
Strict-Transport-Security: max-age=15724800; includeSubDomains

HTTP/1.1 500 Internal Server Error
Date: Tue, 23 Nov 2021 20:42:57 GMT
Content-Length: 0
Connection: keep-alive
Strict-Transport-Security: max-age=15724800; includeSubDomains

HTTP/1.1 500 Internal Server Error
Date: Tue, 23 Nov 2021 20:42:57 GMT
Content-Length: 0
Connection: keep-alive
Strict-Transport-Security: max-age=15724800; includeSubDomains

HTTP/1.1 500 Internal Server Error
Date: Tue, 23 Nov 2021 20:42:57 GMT
Content-Length: 0
Connection: keep-alive
Strict-Transport-Security: max-age=15724800; includeSubDomains

returning to previous context of one
Skipping confirmation, switching the kubernetes context to one - this will apply across all calls unless you overrite using --context=<name> or switch to a new default context
Switched to context "one".
Switched, new default context is is
one

```
---

</details>

If the database already contains data then you may see the `HTTP/1.1 500 Internal Server Error` messages when the script tries to create the test data.

## Task 3: Viewing the results

The script saves information that is useful for the lab into a config file.

  - To look at the contents in the OCI Cloud shell type
  
  - `cat $HOME/clusterInfo.one`

```
External IP
123.456.789.123

export EXTERNAL_IP=123.456.789.123

Dashboard URL
https://dashboard.kube-system.123.456.789.123.nip.io

Dashboard Token
eyJhbGciOiJSUzI1NiIsImtpZCI6IkkxN3dTdEZFV2JsdXFieHVwYlJCcUhpZmVGQlZTM3NPV3lRUVdBVmthMUEifQ.eyJpc3MiOiJrdWJlcn5ldGVzL3NlcnZpY2VhY2NvdW50Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9uYW1lc3BhY2UiOiJrdWJlLXN5c3RlbSIsImt1YmVybmV0ZXMuaW8vc2VydmljZWFjY291bnQvc2VjcmV0Lm5hbWUiOiJkYXNoYm9hcmQtdXNlci10b2tlbi13NTRxNyIsImt1YmVybmV0ZXMuaW8vc2VydmljZWFjY291bnQvc2VydmljZS1hY2NvdW50Lm5hbWUiOiJkYXNoYm9hcmQtdXNlciIsImH1YmVybmV0ZXMuaW8vc2VydmljZWFjY291bnQvc2VydmljZS1hY2NvdW50LnVpZCI6Ijc4MDM5YTQ5LWYzZDMtNDg1My1iYzJkLTliNTAzYTBmOTZlYSIsInN1YiI6InN5c3RlbTpzZXJ2aWNlYWNjb3VudDprdWJlLXN5c3RlbTpkYXNoYm9hcmQtdXNlciJ9.on_Xsa_MZpxnw8MghXr823C064VRtPB6wLbi7-oIY-TSodOT6ym3G7_eKlXGEx-GUxa3YZJ0EYWVSmieub7i_bYOU7jzGS2FYovnvlNsSOCwK9J3s8BReGVle44YTuQEbhmztrS8i6LgxarPoUlbYQ4_4Vn6nxVhv4tt0oimg9Hvv5rBIidlMNGmpsAFb8CaI18WQGNqCKdC9EumaYj1ZGlmqxYX_nOC617u_1lDWVO3nKEXR4KPAE963jl46zbVkwWnxKaDX1LEqEiM9HI5q5wg8G8qMVYwhcCS0xIOpIBbvB0FGAzO6zEdnwtOTmMvauJTx1diPex4hua_i9tAmw

curl cmd
curl -i -X GET -u jack:password -k https://store.123.456.789.123.nip.io/store/stocklevel

status command
curl -i -X GET -k https://store.123.456.789.123.nip.io/sf/status
```

You can confirm that everything is working using the curl command in the output, of course your IP address may be different so you will need to replace `123.456.789.123` with the IP address you see

  - Check the service is available, in the OCI CLoud shell copy and past the curl command ending in `/sf/status` from the clusterSettings.one file
  
  - `curl -i -X GET -u jack:password -k https://store.123.456.789.123.nip.io/sf/status`

```
HTTP/1.1 200 OK
Date: Tue, 23 Nov 2021 20:57:49 GMT
Content-Type: application/json
Content-Length: 87
Connection: keep-alive
Strict-Transport-Security: max-age=15724800; includeSubDomains

{"name":"My Shop","alive":true,"version":"0.0.1","timestamp":"2021-11-23 20:57:49.151"}

```

The output above shows that the shop is "alive" and is version "0.0.1"
 
  - In the OCI cloud shell copy and paste the curl command ending oin /store/stocklevel from the clusterSettings.one file
  
  - `curl -i -X GET -u jack:password -k https://store.123.456.789.123.nip.io/store/stocklevel`
  
```
HTTP/1.1 200 OK
Date: Tue, 23 Nov 2021 20:55:51 GMT
Content-Type: application/json
Content-Length: 149
Connection: keep-alive
Strict-Transport-Security: max-age=15724800; includeSubDomains

[{"itemCount":100,"itemName":"Book"},{"itemCount":50,"itemName":"Eraser"},{"itemCount":200,"itemName":"Pencil"},{"itemCount":5000,"itemName":"Pins"}]
```

The output above shows that the storefront can communicate with the stock manager which can communicate with the database.

## Acknowledgements

* **Author** - Tim Graves, Cloud Native Solutions Architect, EMEA OCI Centre of Excellence
* **Last Updated By** - Tim Graves, November 2021