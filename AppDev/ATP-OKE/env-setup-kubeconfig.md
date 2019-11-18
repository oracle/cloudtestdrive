![](../../common/images/customer.logo2.png)

# Microservices on ATP

## Construct a kubeconfig file with a classic certificate

The Oracle Cloud Managed Kubernetes service is now delivering a V2 kubernetes configuration file, which requires the OCI CLI software to be available for any action using kubectl to interact with the cluster.

This can be an issue in environments where this software cannot be easily installed, or when an old version (prior to v2.6.4) of the OCI CLI is still present.

Also distributing the config file to larger audiences is much easier using a V1 config file with certificate, for example for running the Kubernetes UI Console.





**Warning :  FOR TESTING ONLY, DO NOT USE IN REAL-LIFE SITUATIONS**.  This procedure will open up admin access to your cluster for anybody who has a copy of the config file.





### Steps to execute ###

In order to execute these steps, you will need a recent version of the OCI CLI (2.6.4 or above) on at least one machine.  Installation of OCI CLI is detailed [here](https://docs.cloud.oracle.com/iaas/Content/API/SDKDocs/cliinstall.htm).

- Obtain the V2 Certificate of your cluster

  - If you are using terraform to create your cluster, make sure to specify your kubeconfig file as an output parameter in the script : 

    ```
    resource "local_file" "mykubeconfig" {
      content  = data.oci_containerengine_cluster_kube_config.test_cluster_kube_config.content
      filename = "./mykubeconfig"
    }
    ```

  - If you use the OCI Console, you can run the **oci ce cluster create-kubeconfig** command as specified in the **Access Kubeconfig** button on the console.

  

- Validate you now can access the cluster through **kubectl**, for example by issuing the command

  ```
  kubectl get nodes
  ```

  

- Create a Service Account and associated ClusterRole and ClusterRoleBindings

  - Create a file on your machine called "rbac.yml" with following content:

    ```
    apiVersion: v1
    kind: ServiceAccount
    metadata:
      name: svcs-acct-jle
    ---
    
    apiVersion: rbac.authorization.k8s.io/v1beta1
    kind: ClusterRole
    metadata:
      name: jle-configv2-clusterrole
    rules:
      - apiGroups:
          - "*"
        resources:
          - "*"
        verbs:
          - "*"
    ---
    
    apiVersion: rbac.authorization.k8s.io/v1beta1
    kind: ClusterRoleBinding
    metadata:
      name: jle-configv2-clusterrole-nisa-binding
    roleRef:
      apiGroup: rbac.authorization.k8s.io
      kind: ClusterRole
      name: jle-configv2-clusterrole
    subjects:
      - kind: ServiceAccount
        name: svcs-acct-jle
        namespace: default
    ```

  - Now apply this config to your cluster :

    ```
    kubectl create -f rbac.yml
    ```

  - Fetch the name of the secrets used by the service account, by running the following command:

    ```
    kubectl describe serviceAccounts svcs-acct-jle
    ```

  - Note down the name of the **Mountable secrets**

    ```
    Jans-MacBook-Pro-7:test jleemans$ kubectl describe serviceAccounts svcs-acct-jle
    Name:                svcs-acct-jle
    Namespace:           default
    Labels:              <none>
    Annotations:         <none>
    Image pull secrets:  <none>
    Mountable secrets:   svcs-acct-jle-token-xvnc2
    Tokens:              svcs-acct-jle-token-xvnc2
    Events:              <none>
    
    ```

    In the above example, the name is svcs-acct-jle-token-xvnc2

  - Now fetch the token from the secret (substitute your secret name):

    ```
    kubectl describe secrets svcs-acct-jle-token-xvnc2
    ```

    The output of this command will show you the **token** to be inserted into the new kubeconfig file

    ```
    
    Name:               svcs-acct-dply-token-h6pdj
    Namespace:      default
    Labels:         <none>
    Annotations:    kubernetes.io/service-account.name=svcs-acct-dply
            kubernetes.io/service-account.uid=c2117d8e-3c2d-11e8-9ccd-42010a8a012f
    
    Type:   kubernetes.io/service-account-token
    
    Data
    ====
    ca.crt:     1115 bytes
    namespace:  7 bytes
    token:      eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJrdWJlcm5ldGVzL3NlcnZpY2VhY2NvdW50Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9uYW1lc3BhY2UiOiJkZWZhdWx0Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb5SJwwov6PjaADT-FqSO9ZgJEg6uUVXuPa03jmqyRB20HmsTvuDabVoK7Ky7Uug7V8J9yK4oOOK5d0aRRdgHXzxZd2yO8C4ggqsr1KQsfdlU4xRWglaZGI4S31ohCApJ0MUHaVnP5WkbC4FiTZAQ5fO_LcCokapzCLQyIuD5Ksdnj5Ad2ymiLQQ71TUNccN7BMX5aM4RHmztpEHOVbElCWXwyhWr3NR1Z1ar9s5ec6iHBqfkp_s8TvxPBLyUdy9OjCWy3iLQ4Lt4qpxsjwE4NE7KioDPX2Snb6NWFK7lvldjYX4tdkpWdQHBNmqaD8CuVCRdEQ
    
    ```

  - Now make a copy of your original kubeconfig file, and replace the **user** part at the end as follows :

    - Initial kubeconfig file structure:

      ```
      apiVersion: v1
      clusters:
      - cluster:
          certificate-authority-data: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSURqRENDQW5TZ0F3SUJBZ0lVWElCNDhGOURBR0kwYW9tWHVOQUkrOHY0dGNNd0RRWUpLb1pJaHZjTkFRRUwKQlFBd1hqRUxNQWtHQTFVRUJoTUNWVk14RGpBTUJnTlZCQWdUQlZSbGVHRnpNUTh3RFFZRFZRUUhFd1pCZFhOMAphVzR4RHpBTkJnTlZCQW9UQms5eVlXTnNaVEVNTUFvR0ExVUVDeE1EVDBSWU1ROHdEUVlEVlFRREV3WkxPRk1nClEwRXdIaGNOTVRrd09ESXdNVEl3TmpBd1doY05N .....   Yyd3k0YnNEdmlqCkdBK1BuNXNHZ3ZLUHh4NklSSFJnbXFOb0taYW52Y2xnK1ZLQm1kdTkzeGowUDhGWUpSU05zMnJ1SVUyeVZVYzEKYmtzM3ZTSk1tVjd4N3BHUS9DZ2hJQXV3SHNEdGJYcFpzeUYvakR5OEdVVVpUUGVBSWJYejFKbk9DSzAwRHpQNwpCcEhYdmFoWnBZeTlRM0xhMjJtblZOenR5MCtRbDNOdnRlVnY0bGlLQUV3RytBaWVrSGZtQ083VGxGUnAxNGRaCjNiZ2hqLzRKWjF4b25Nb2RCWFBGSG9nSUUwcFYyc09GcDNRTHh3TlpTNzh5dnkxd1QyL2R0VjVJSHZ0Q3VCZmgKLS0tLS1FTkQgQ0VSVElGSUNBVEUtLS0tLQo=
          server: https://cqwinyw.eu-frankfurt-1.clusters.oci.oraclecloud.com:6443
        name: cluster-cqwinyw
      contexts:
      - context:
          cluster: cluster-cqwiyw
          user: user-cqwinyw
        name: context-cqwinyw
      current-context: context-cqwinyw
      kind: ""
      users:
      - name: user-cqwinyw
        user:
          exec:
            apiVersion: client.authentication.k8s.io/v1beta1
            args:
            - ce
            - cluster
            - generate-token
            - --cluster-id
            - ocid1.cluster.oc1.eu-frankfurt-1.aaaaaaaaae3dgyrtga4gcnjrgrsdezjxgcqwinbwg4yw
            - --region
            - eu-frankfurt-1
            command: oci
            env: []
      ```

      Note: addresses and names in the above example are ficticious, no real addresses or certificates are shown.

    - New Structure

      ```
      apiVersion: v1
      clusters:
      - cluster:
          certificate-authority-data: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSURqRENDQW5TZ0F3SUJBZ0lVWElCNDhGOURBR0kwYW9tWHVOQUkrOHY0dGNNd0RRWUpLb1pJaHZjTkFRRUwKQlFBd1hqRUxNQWtHQTFVRUJoTUNWVk14RGpBTUJnTlZCQWdUQlZSbGVHRnpNUTh3RFFZRFZRUUhFd1pCZFhOMAphVzR4RHpBTkJnTlZCQW9UQms5eVlXTnNaVEVNTUFvR0ExVUVDeE1EVDBSWU1ROHdEUVlEVlFRREV3WkxPRk1nClEwRXdIaGNOTVRrd09ESXdNVEl3Tm ... RHpQNwpCcEhYdmFoWnBZeTlRM0xhMjJtblZOenR5MCtRbDNOdnRlVnY0bGlLQUV3RytBaWVrSGZtQ083VGxGUnAxNGRaCjNiZ2hqLzRKWjF4b25Nb2RCWFBGSG9nSUUwcFYyc09GcDNRTHh3TlpTNzh5dnkxd1QyL2R0VjVJSHZ0Q3VCZmgKLS0tLS1FTkQgQ0VSVElGSUNBVEUtLS0tLQo=
          server: https://cqwinyw.eu-frankfurt-1.clusters.oci.oraclecloud.com:6443
        name: cluster-cqwinyw
      contexts:
      - context:
          cluster: cluster-cqwinyw
          user: user-cqwinyw
        name: context-cqwinyw
      current-context: context-cqwinyw
      kind: ""
      users:
      - name: user-cqwinyw
        user:
          token: eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJrdWJlcm5ldGVzL3NlcnZpY2VhY2NvdW50Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9uYW1lc3BhY2UiOiJkZWZhdWx0Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb5SJwwov6PjaADT-FqSO9ZgJEg6uUVXuPa03jmqyRB20HmsTvuDabVoK7Ky7Uug7V8J9yK4oOOK5d0aRRdgHXzxZd2yO8C4ggqsr1KQsfdlU4xRWglaZGI4S31ohCApJ0MUHaVnP5WkbC4FiTZAQ5fO_LcCokapzCLQyIuD5Ksdnj5Ad2ymiLQQ71TUNccN7BMX5aM4RHmztpEHOVbElCWXwyhWr3NR1Z1ar9s5ec6iHBqfkp_s8TvxPBLyUdy9OjCWy3iLQ4Lt4qpxsjwE4NE7KioDPX2Snb6NWFK7lvldjYX4tdkpWdQHBNmqaD8CuVCRdEQ
      
      ```

  - Now reset your **KUBECONFIG** environment variable to point to your new kubeconfig file and validate you are able to access the cluster.

  

  



---

Use the **Back Button** of your browser to go back to the overview page and select the next lab step to continue.
