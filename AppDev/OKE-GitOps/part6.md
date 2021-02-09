# Part 6 – ConfigMap Approach #


It is possible to define a list of ConfigMap and Secret resources from which to take values. 
The values are merged in the order given, with the later values overwriting earlier. 
These values always have a lower priority than the values inlined in the HelmRelease via the spec.values parameter.

Use cases:

1.	Your values can became after the actual installation

2.	You want manage the values separated, so you will have separated git history on your values configmap filename

3.	Your want to have many prioritized values for one parameter

Let's create a ConfigMap

1.	Open the CloudShell and execute the following command
```
echo "replicaCount: 2" > values.yaml
```
```
kubectl create configmap myconfig --from-file=values.yaml --namespace=flux-system --output=yaml --dry-run > myconfig.yaml
```
```
cat myconfig.yaml
```

output:
```
apiVersion: v1
data:
  values.yaml: |
    replicaCount: 2
kind: ConfigMap
metadata:
  creationTimestamp: null
  name: myconfig
  namespace: flux-system
```

2.	Commit the ConfigMap myconfig.yaml to your Git repository

i.	Go to your GitHub account in the browser, open oracle-gitops-workshop repository in your GitHub webpage

ii.	Go to **clusters/default/flux-system/** directory

iii.	Сlick on **Add file** -> **Create new file**

iv.	Fill filename **myconfig.yaml** to Name your file... field

v.	Copy & Paste myconfig.yaml content to text area and click on **Commit change** on the bottom of the page.


3.	Define a ConfigMap resource from which to take the values

i.	Open **oracle-gitops-workshop** repository in your GitHub webpage

ii.	Go to **clusters/default/flux-system/hello-kubernetes.yaml** file

iii.	Сlick on pencil to edit the file

iv.	After the values section and new valuesFrom section

```
apiVersion: helm.toolkit.fluxcd.io/v2beta1
kind: HelmRelease
metadata:
  name: hello-kubernetes
  namespace: flux-system
spec:
  interval: 1m
  timeout: 1m
  chart:
    spec:
      chart: ./charts/hello-kubernetes
      sourceRef:
        kind: GitRepository
        name: oracle-gitops-workshop
      interval: 1m
  targetNamespace: default
  values:
    message: This is new one
  valuesFrom:
  - kind: ConfigMap
    name: myconfig
```

•	Note you can just copy & paste this into the editor. 

After you commit the file, you can go back to your CloudShell to watch the changes. 

#### The number of pods should be different #### 

After you pass this from the ConfigMap. 

Nice! You just added changes through the ConfigMap. 


[Continue to Part 7 Provision OKE-Day2 Components](part7.md) 

If you want to return to the workshop homepage:

[Back to the general workshop section](README.md)
