# Create a Cluster with Oracle Cloud Infrastructure Container Engine for Kubernetes

## Before You Begin

This 10-minute tutorial shows you how to:

- create a new cluster with default settings and new network resources
- create a node pool
- download the kubeconfig file for the cluster
- verify you can access the cluster using kubectl and the Kubernetes Dashboard



### Background

Oracle Cloud Infrastructure Container Engine for Kubernetes is a fully-managed, scalable, and highly available service that you can use to deploy your containerized applications to the cloud. Use Container Engine for Kubernetes when your development team wants to reliably build, deploy, and manage cloud-native applications. You specify the compute resources that your applications require, and Container Engine for Kubernetes provisions them on Oracle Cloud Infrastructure in an existing OCI tenancy.

In this tutorial, you use default settings to define a new cluster. When you create the new cluster, new network resources for the cluster are created automatically, along with a node pool and three private worker nodes. You'll then download the Kubernetes configuration file for the cluster (the cluster's 'kubeconfig' file). The kubeconfig file enables you to access the cluster using kubectl and the Kubernetes Dashboard.

### What Do You Need?

- An Oracle Cloud Infrastructure username and password.

  

------

## ![section 1](https://www.oracle.com/webfolder/technetwork/tutorials/obe/oci/oke-full/img/32_1.png)Starting OCI

1. In a browser, go to the url you've been given to log in to Oracle Cloud Infrastructure.

   ![Sign In page](https://www.oracle.com/webfolder/technetwork/tutorials/obe/oci/oke-full/img/oci-login-page.png)

    

3. Enter your username and password.

------

## ![section 2](https://www.oracle.com/webfolder/technetwork/tutorials/obe/oci/oke-full/img/32_2.png)Define Cluster Details

1. In the Console, open the navigation menu. Under **Solutions and Platform**, go to **Developer Services** and click **Container Clusters**.

2. Choose a **Compartment** that you have permission to work in, and in which you want to create both the new cluster and the associated network resources.

   ![Clusters page](https://www.oracle.com/webfolder/technetwork/tutorials/obe/oci/oke-full/img/oci-console-create-cluster.png)

4. On the **Clusters** page, click **Create Cluster**.

4. In the **Create Cluster Solution** dialog, click **Quick Create** and click **Launch Workflow**.

   ![Create Cluster Solution dialog](https://www.oracle.com/webfolder/technetwork/tutorials/obe/oci/oke-full/img/oci-create-cluster-solution-v2.png)

5. On the **Create Cluster** page, change the placeholder value in the **Name** field and enter `Tutorial Cluster<your-initials>` instead, replacing <your-initials by your initials.

   ![Cluster Creation - Create Cluster page](https://www.oracle.com/webfolder/technetwork/tutorials/obe/oci/oke-full/img/oci-create-cluster-complete-top-v2.png)

6. Click **Next** to review the details you entered for the new cluster.

   ![Cluster Creation - Review page](https://www.oracle.com/webfolder/technetwork/tutorials/obe/oci/oke-full/img/oci-create-cluster-review-top-v2.png)

     

11. On the **Review** page, click **Submit** to create the new network resources and the new cluster.

8. You see the different network resources being created for you.

   ![Cluster Creation Status dialog](https://www.oracle.com/webfolder/technetwork/tutorials/obe/oci/oke-full/img/oci-create-cluster-creation-status-top-v1.png)

     

9. Click **Close** to return to the Console.

   ![Cluster Creation Status dialog](https://www.oracle.com/webfolder/technetwork/tutorials/obe/oci/oke-full/img/oci-create-cluster-creation-status-bottom-v2.png)

     

10. The new cluster is shown on the Cluster Details page. When it has been created, the new cluster has a status of Active.

    ![Cluster Details page](https://www.oracle.com/webfolder/technetwork/tutorials/obe/oci/oke-full/img/oci-clusters-page-active.png)

11. Scroll down to see details of the new node pool that has been created, along with details of the new worker nodes (compute instances).

    ![Cluster Details page](https://www.oracle.com/webfolder/technetwork/tutorials/obe/oci/oke-full/img/oci-clusters-page-nodepool.png)


------

## ![section 3](https://www.oracle.com/webfolder/technetwork/tutorials/obe/oci/oke-full/img/32_3.png)Download the kubeconfig File for the Cluster

1. With the Cluster Details page showing the Tutorial Cluster, click **Access Kubeconfig**

   to display the **How to Access Kubeconfig** dialog box.

   ![How to Access Kubeconfig dialog](https://www.oracle.com/webfolder/technetwork/tutorials/obe/oci/oke-full/img/oci-how-to-access-kubeconfig.png)

2. In a terminal window, create a directory to contain the kubeconfig file, giving the directory the expected default name and location of `$HOME/.kube`. For example, on Linux, enter the following command (or copy and paste it from the **How to Access Kubeconfig** dialog box): 

3. ```
   $ mkdir -p $HOME/.kube
   ```

4. Run the Oracle Cloud Infrastructure CLI command to download the kubeconfig file and save it with the expected default name and location of `$HOME/.kube/config`.  This name and location ensures the kubeconfig file is accessible to kubectl and the Kubernetes Dashboard whenever you run them from a terminal window. For example, on Linux, enter the following command (or copy and paste it from the **How to Access Kubeconfig** dialog box):

   ```
   $ oci ce cluster create-kubeconfig --cluster-id ocid1.cluster.oc1.phx.aaaaaaaaae... --file $HOME/.kube/config --region us-phoenix-1 --token-version 2.0.0
   ```

   where ocid1.cluster.oc1.phx.aaaaaaaaae... is the OCID of the current cluster. 

5. Click **Close** to close the **How to Access Kubeconfig** dialog.

------

## ![section 4](https://www.oracle.com/webfolder/technetwork/tutorials/obe/oci/oke-full/img/32_4.png)Verify kubectl and Kubernetes Dashboard Access to the Cluster

1. Confirm that you've already installed kubectl. If you haven't done so already, see the [kubectl documentation](https://kubernetes.io/docs/tasks/tools/install-kubectl/).

2. Verify that you can use kubectl to connect to the new cluster you have created. In a terminal window, enter the following command:

   `kubectl get nodes`

   You see details of the nodes running in the cluster. For example:

   ```
   NAME              STATUS  ROLES  AGE  VERSION
   10.0.10.2         Ready   node   1d   v1.13.5
   10.0.11.2         Ready   node   1d   v1.13.5
   10.0.12.2         Ready   node   1d   v1.13.5
   ```

3. Verify that you can use the Kubernetes Dashboard to connect to the cluster:

   1. In a text editor, create a file called oke-admin-service-account.yaml with the following content:

      ```
      apiVersion: v1
      kind: ServiceAccount
      metadata:
        name: oke-admin
        namespace: kube-system
      ---
      apiVersion: rbac.authorization.k8s.io/v1beta1
      kind: ClusterRoleBinding
      metadata:
        name: oke-admin
      roleRef:
        apiGroup: rbac.authorization.k8s.io
        kind: ClusterRole
        name: cluster-admin
      subjects:
        - kind: ServiceAccount
          name: oke-admin
          namespace: kube-system
      ```

      The file defines an administrator service account and a clusterrolebinding, both called oke-admin.

   2. Create the service account and the clusterrolebinding in the cluster by entering:

      ```
      $ kubectl apply -f oke-admin-service-account.yaml
      ```

      The output from the above command confirms the creation of the service account and the clusterrolebinding:

      ```
      serviceaccount "oke-admin" created
      clusterrolebinding.rbac.authorization.k8s.io "oke-admin" created
      ```

      You can now use the oke-admin service account to view and control the cluster, and to connect to the Kubernetes dashboard.

   3. Obtain an authentication token for the oke-admin service account by entering:

      ```
      $ kubectl -n kube-system describe secret $(kubectl -n kube-system get secret | grep oke-admin | awk '{print $1}')
      ```
      

The output from the above command includes an authentication token (a long alphanumeric string) as the value of the **token** element, as shown below:
      
```
      Name: oke-admin-token-gwbp2
Namespace: kube-system
      Labels: <none>
      Annotations: kubernetes.io/service-account.name: oke-admin
      kubernetes.io/service-account.uid: 3a7fcd8e-e123-11e9-81ca-0a580aed8570
Type: kubernetes.io/service-account-token
      Data
===
      ca.crt: 1289 bytes
namespace: 11 bytes
      token: eyJh______px1Q
```

    In the example above, **eyJh______px1Q** is the authentication token.


   4. Copy the value of the `token:` element from the output. You will use this token to
      connect to the dashboard.

   5. In a terminal window, enter the following command:

      ```
      $ kubectl proxy
      ```
   
   6. Open a new browser window and go to http://localhost:8001/api/v1/namespaces/kube-system/services/https:kubernetes-dashboard:/proxy/#!/login to display the Kubernetes Dashboard.

      ![Kubernetes Dashboard Sign In page](https://www.oracle.com/webfolder/technetwork/tutorials/obe/oci/oke-full/img/oci-k8s-dashboard-sign-in.png)

   7. Select the **Token** option, and paste the value of the `token:` element you copied earlier into the **Token** field.

   8. Click **Sign In**.
   
9. Click **Overview** to see that Kubernetes is the only service running in the cluster.
  
  ![Kubernetes Dashboard Overview page](https://www.oracle.com/webfolder/technetwork/tutorials/obe/oci/oke-full/img/oci-k8s-dashboard-overview.png)
  
   10. Congratulations! You've successfully created a new cluster, and confirmed that the new cluster is up and running as expected.

