![Title image](../../../images/customer.logo2.png)

# Deploy a private helm repository with ChartMuseum and Let's Encrypt


## Provision an OKE Cluster

## Install ingress-nginx controller

In this section, we are going to install ingress-nginx controller.

1. Add the helm repo:

  ```bash
    helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
  ```

2. Generate the installation manifest:

   ```bash
    helm show values ingress-nginx/ingress-nginx > nginx.yaml
   ```

3. Edit `nginx.yaml ` to disable the use of security list and use NSGs by adding the following:

  ```yaml
  controller:
    service:
      annotations:
        service.beta.kubernetes.io/oci-load-balancer-security-list-management-mode: "None"
        oci.oraclecloud.com/oci-network-security-groups: "ocid1.networksecuritygroup....."
  ```
4. Install ingress-nginx

  ```bash
  helm install nginx --namespace nginx ingress-nginx/ingress-nginx -f nginx.yaml --create-namespace
  ```

5. Verify a public load balancer has been created with a public IP address assigned in the OCI Console.

6. Retrieve the Load Balancer's public IP address:

  ```bash
  export EXTERNAL_IP=$(kubectl --namespace nginx get svc nginx-ingress-nginx-controller --output jsonpath='{.status.loadBalancer.ingress[0].ip}')
  ```
  
7. This concludes Part 1 of this lab.