

## Welcome to OKE - GitOps Workshop ##

<a target="_blank" href="http://cloud.oracle.com">
<img src="pics/oracle-oke.PNG" width="256"/>
</a>
<a target="_blank" href="http://oqva.io">
<img src="pics/OQVA-Logo-new.png"width="256"/> 
</a>


You are welcome to a live workshop hosted by Oracle in collaboration with OQVA, that will shade light on how to use Oracle managed Kubernetes with the cutting edge GitOps approach.

GitOps is a new paradigm of implementing CD (continuous delivery) for cloud-native applications. This approach focuses on operating cloud infrastructure using tools that developers are already familiar with.



## Before you begin, here are some prerequisite: ##


1. GitHub account, if you already have a GitHub account you can skip this step,
if not please create one here: https://github.com/join

2. Make sure you have an Oracle OCI account.
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

## Workshop Agenda: ## 

[Part 1 – Provisioning OKE Cluster](part1.md)

[Part 2 - Provision Flux](part2.md)

[Part 3 – Provision hello-kubernetes Application from GitHub](part3.md)

[Part 4 – Release Upgrade with New Values](part4.md)

[Part 5 – Pause/Resume Features](part5.md)

[Part 6 – ConfigMap Approach](part6.md)

[Part 7 - Provision OKE-Day2 Components](part7.md)

[Part 8 - Breaking the Helm Release](part8.md)

[Part 9 - Sealed Secrets](part9.md)

[Cleaning All Resources](clean.md) 
