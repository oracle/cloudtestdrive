## Welcome to OKE - Rancher lab ##

<img src="https://github.com/deton57/oke-labs/blob/master/oke-rancher/oracle-k8s-rancher-linnovate.png" width="1024"/>


Our goal is to get familiar with the following: 
1. Oracle IaaS - OCI (Oracle Cloud Infrastructure)
2. Oracle Cloud Native Solutions - OKE (Oracle Kubernetes Engine) 
3. Managing the Kubernetes Engine Cluster using Rancher
4. Simplifying Deployments and monitoring them using Rancher 

<details><summary><b>If you are not familiar with the mentioned solutions yet, you can find some documentation here:</b></summary>
<p>
  
Oracle IaaS - OCI: https://docs.cloud.oracle.com/en-us/iaas/Content/home.htm

Oracle OKE - https://docs.cloud.oracle.com/en-us/iaas/Content/ContEng/Concepts/contengoverview.htm

Rancher - https://rancher.com/docs/

</p></details>

## Before you begin, here are some prerequisite: ##


1. First, make sure you have an Oracle OCI account.
Sign in page: https://www.oracle.com/cloud/sign-in.html

**If you don't have a cloud account yet,**
**you can create a free account trial here:** 
**https://bit.ly/ocicredits**

**If you have signed for a zoominar,
you can enjoy a $500 promotion and no credit card required** 

```diff 
- **Existing Accounts only!** 
- These steps apply only if you are using your current OCI Account, and you are not under root compartment
- please make sure you have permissions for:

- 1a. Creating Virtual Cloud Network and Subnets.
- 1b. Creating Compute Instance + Shapes + Images permission.
- 1c. Creating OKE Cluster with all the permissions.
- 1d. Make sure your OKE has permissions to create Networks and Storage.
```
<details><summary><b>Links for policy documentation:</b></summary>
<p>
  
  [Link for Common policies](https://docs.cloud.oracle.com/en-us/iaas/Content/Identity/Concepts/commonpolicies.htm)
  
  [Link for OKE Policies](https://docs.cloud.oracle.com/en-us/iaas/Content/ContEng/Concepts/contengpolicyconfig.htm)
</p></details>

```diff
- Please update them before we begin the lab.
```

2. Mobaxterm installed 
    [Mobaxterm Download link](https://mobaxterm.mobatek.net/download.html)
3. Putty + Puttygen installed 
    [Putty Download Link](https://www.chiark.greenend.org.uk/~sgtatham/putty/latest.html)




## Lab Agenda: ## 

First, we shall create a virtual machine with Oracle Developer image,
connect it to Oracle cloud, and launch a Rancher Docker:

1. [Create a virtual machine with Rancher installed on Docker](vm.md) 

Once Rancher is installed, 
we shall create an OKE cluster on Oracle cloud:

2. [Create an OKE cluster using Rancher](cluster.md)

We have a cluster up and running with nodes, 
now it is time to install apps on the cluster:

3. [Install Wordpress app from Rancher catalog and manage it](wp.md)

Our apps are up and running, 
let's monitor the Kubernetes cluster, and see the workloads:

4. [Monitoring the cluster and the app](mon.md)
