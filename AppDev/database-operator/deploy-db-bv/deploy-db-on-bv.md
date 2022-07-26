# Deploy a database using a block volume

## Introduction

#### Dynamic Persistence

In this lab we'll be using **Dynamic Persistence Provisioning**, a persistent volume that is automatically provisioned by mentioning a storage class. As we are running on Oracle OCI, we'll use the **oci-bv** storage class. This storage class facilitates dynamic provisioning of the OCI block volumes. The supported access mode for this class is `ReadWriteOnce`. For other cloud providers, you can similarly use their dynamic provisioning storage classes.

We'll also be specifying the  `Reclaim Policy` of the dynamically provisioned volumes as `Delete`. In this case the volume is deleted when the corresponding database deployment is deleted.



Estimated Lab Time: 20 minutes



## Task 1: Store passwords in Kubernetes Secrets
When creating a database we will need a few passwords:

- Your Oracle Account password to pull the DB docker container from the Oracle Container Repository 
- The Admin password of the database we'll be creating

In kubernetes we store these passwords in secrets.

1. In the Cloud Shell, log into the oracle repository with the below command :

   ```
   docker login container-registry.oracle.com
   ```

   You'll be prompted for your username and password, please enter your Oracle website username and password (**not** your OCI Cloud username !)
   If all goes well you'll get a `Login Succeeded`message.

2. Now use the local config file to create the secret we'll pass to the operator:

   ```
   kubectl create secret generic oracle-container-registry-secret --from-file=.dockerconfigjson=.docker/config.json --type=kubernetes.io/dockerconfigjson
   ```

   Please note we're assuming you are in the home directory of your cloud shell, if not please make sure to correct the path to the .docker directory accordingly.

3. Let's now create a secret containing the admin password we'll want to specify for the new database: 

   ```
   kubectl create secret generic admin-secret --from-literal=oracle_pwd=Oracle123456
   ```

   





passworkTo access the pre-configured docker image containing the Oracle 21c Enterprise Edition database from the Oracle Container Registry, you need to sign in and accept the required developer License Agreement.

1. Navigate to the [Oracle Container Registry](https://container-registry.oracle.com/) and log in with your Oracle account. 
   *!! Attention, !!* this is **not** your Cloud account but the account you used to register to the Oracle website, sign up for events or download software.
   ![](images/container-reg.png)

2. Sign in with your Oracle account

3. Navigate to the Database section

4. Click on the `Continue` button besides the **Enterprise** edition, scroll down to the bottom of the page and `Accept` theT&C's.

   You should now see a green checkmark besides the Enterprise edition version
   ![](images/enterprise-tc.png)

5. Now click on the blue **enterprise** label to see the download instructions, especially the exact path for the pull command
   ![](images/image-details.png)







## Task 2: Install the operator using the Cloud Shell

The operator uses webhooks for validating user input before persisting it in Etcd. Webhooks require TLS certificates that are generated and managed by a certificate manager.

1. Install the certificate manager with the following command:

```
kubectl apply -f https://github.com/jetstack/cert-manager/releases/latest/download/cert-manager.yaml
```

The resulting output should have no error messages and end like below:

```
clusterrolebinding.rbac.authorization.k8s.io/cert-manager-webhook:subjectaccessreviews created
role.rbac.authorization.k8s.io/cert-manager-cainjector:leaderelection created
role.rbac.authorization.k8s.io/cert-manager:leaderelection created
role.rbac.authorization.k8s.io/cert-manager-webhook:dynamic-serving created
rolebinding.rbac.authorization.k8s.io/cert-manager-cainjector:leaderelection created
rolebinding.rbac.authorization.k8s.io/cert-manager:leaderelection created
rolebinding.rbac.authorization.k8s.io/cert-manager-webhook:dynamic-serving created
service/cert-manager created
service/cert-manager-webhook created
deployment.apps/cert-manager-cainjector created
deployment.apps/cert-manager created
deployment.apps/cert-manager-webhook created
mutatingwebhookconfiguration.admissionregistration.k8s.io/cert-manager-webhook created
validatingwebhookconfiguration.admissionregistration.k8s.io/cert-manager-webhook created
```



2. Next we'll install the operator itself using the default [oracle-database-operator.yaml](https://github.com/oracle/oracle-database-operator/blob/main/oracle-database-operator.yaml) file straight from the git repo.  Of course you can also download and edit this file manually, as there are various options that can be controlled in this fashion.

```
kubectl apply -f https://raw.githubusercontent.com/oracle/oracle-database-operator/main/oracle-database-operator.yaml
```

Again you should see an output ending like below, without errors :

```
clusterrolebinding.rbac.authorization.k8s.io/oracle-database-operator-oracle-database-operator-proxy-rolebinding created
service/oracle-database-operator-controller-manager-metrics-service created
service/oracle-database-operator-webhook-service created
certificate.cert-manager.io/oracle-database-operator-serving-cert created
issuer.cert-manager.io/oracle-database-operator-selfsigned-issuer created
mutatingwebhookconfiguration.admissionregistration.k8s.io/oracle-database-operator-mutating-webhook-configuration created
validatingwebhookconfiguration.admissionregistration.k8s.io/oracle-database-operator-validating-webhook-configuration created
deployment.apps/oracle-database-operator-controller-manager created
```



3. Now validate that the operator is indeed running on the three nodes of the kubernetes cluster with the below command : 

   ```
   kubectl get pod -n oracle-database-operator-system -o wide
   ```

   The output should be something like the below, where you can see each pod runs on a different node of the cluster:

   ```
   NAME                                                           READY   STATUS    RESTARTS   AGE     IP             NODE          NOMINATED NODE   READINESS GATES
   oracle-database-operator-controller-manager-5fbbffb45c-9v7k8   1/1     Running   0          6m25s   10.244.0.5     10.0.10.52    <none>           <none>
   oracle-database-operator-controller-manager-5fbbffb45c-mdxvj   1/1     Running   0          6m25s   10.244.1.132   10.0.10.193   <none>           <none>
   oracle-database-operator-controller-manager-5fbbffb45c-slj5l   1/1     Running   0          6m25s   10.244.0.132   10.0.10.149   <none>           <none>
   ```

   

The Database Kubernetes Operator has been installed. You may now **proceed to the next lab**.



## Acknowledgements
* **Author** - Jan Leemans, July 2022
* **Last Updated By/Date**
