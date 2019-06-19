[Go back to the to Container Lab Page](sample.app.OKE2.md)

![](../../common/images/customer.logo2.png)

## Creating an Ingress Loadbalancer on your Cluster ##

These instructions are only required in case you created your own K8S cluster, and did not (yet) configure a loadbalancer to reach your K8S worker nodes.

**DO NOT execute this script if you are using a K8S instance provided to you by your instructor**
### Setting up your loadbalancer ###

First you need to create a cluster role binding using the api.user you used to create the cluster with: 

- execute the following command, replacing the ocid1.user.... with the OCID of your api user.

  ```
  kubectl create clusterrolebinding my-cluster-admin-binding --clusterrole=cluster-admin --user=ocid1.user.oc1..aaaaa
  ```



The detailed scripts for setting up the loadbalancer can be found a separate github page,
but you can simply execute the below script by running the following on your machine :

      #!/bin/sh
      export NAMESPACE=shared-ingress
      
      kubectl delete namespace $NAMESPACE --ignore-not-found=true --now=true
      
      # wait to delete resources
      sleep 60
      
      kubectl create namespace $NAMESPACE
      
      #wait to avoid issues with uncreated namespace
      sleep 10
      
      kubectl create sa oraclebmc-provisioner -n=$NAMESPACE
      
      kubectl create -f https://raw.githubusercontent.com/nagypeter/kubernetes/master/ingress/rbac.yaml -n=$NAMESPACE
      
      kubectl create -f https://raw.githubusercontent.com/nagypeter/kubernetes/master/ingress/nginx-default-backend-deployment.yaml -n=$NAMESPACE
      
      kubectl create -f https://raw.githubusercontent.com/nagypeter/kubernetes/master/ingress/nginx-default-backend-service.yaml -n=$NAMESPACE
      
      kubectl create -f https://raw.githubusercontent.com/nagypeter/kubernetes/master/ingress/nginx-config.yaml -n=$NAMESPACE
      
      kubectl create -f https://raw.githubusercontent.com/nagypeter/kubernetes/master/ingress/nginx-ingress-controller-deployment.yaml -n=$NAMESPACE
      
      kubectl create -f https://raw.githubusercontent.com/nagypeter/kubernetes/master/ingress/nginx-ingress-controller-service.yaml -n=$NAMESPACE

For more details, visit [this page](https://github.com/nagypeter/kubernetes/tree/master/ingress)

To validate the correct execution of this script, you need to access your kubernetes console, and validate both pods are running correctly.  

![](images/k8s_pod_up.png)



Next, in your OCI console, validate you now have a running loadbalancer in the network config.

![](images/k8s_lb_up.png)

---
[Go back to the to Container Lab Page](sample.app.OKE2.md)
