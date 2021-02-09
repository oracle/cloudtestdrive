# Part 2 - Provision Flux # 

In this part we are going to install and provision Flux. 

Flux is a tool that automatically ensures that the state of a cluster matches the config in git. It uses an operator in the cluster to trigger deployments inside Kubernetes, which means you don't need a separate CD tool. It monitors all relevant image repositories, detects new images, triggers deployments and updates the desired running configuration based on that (and a configurable policy).

Source: https://github.com/fluxcd/flux

We are going to implement this operation using CloudShell in the cloud console, 
but alternatively if you have a developer machine that has access to OCI, you can do it from there. 

1.	Install Flux cli run the following command: 
```
curl -s https://toolkit.fluxcd.io/install.sh | bash -s $PWD
```

output:
```
[INFO]  Downloading metadata https://api.github.com/repos/fluxcd/flux2/releases/latest
[INFO]  Using 0.7.5 as release
[INFO]  Downloading hash https://github.com/fluxcd/flux2/releases/download/v0.7.5/flux_0.7.5_checksums.txt
[INFO]  Downloading binary https://github.com/fluxcd/flux2/releases/download/v0.7.5/flux_0.7.5_linux_amd64.tar.gz
[INFO]  Verifying binary download
which: no shasum in (/usr/lib/jvm/java-1.8.0-openjdk-1.8.0.275.b01-0.el7_9.x86_64/bin/:/opt/oracle/sqlcl/bin:/usr/lib/oracle/19.5/client64/bin:/home/oci/.pyenv/plugins/pyenv-virtualenv/shims:/home/oci/.pyenv/shims:/home/oci/.pyenv/bin:/opt/rh/rh-ruby25/root/usr/local/bin:/opt/rh/rh-ruby25/root/usr/bin:/opt/rh/rh-maven35/root/usr/bin:/opt/rh/rh-dotnet31/root/usr/bin:/opt/rh/rh-dotnet31/root/usr/sbin:/home/oci/bin:/opt/oracle/sqlcl/bin:/opt/gradle/gradle-6.0/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/home/daniel_kag/.composer/vendor/bin:/home/daniel_kag/.dotnet/tools)
```

2.	Install Flux controllers on your OKE cluster
```
./flux install 
```

output: 
```
✚ generating manifests
✔ manifests build completed
► installing components in flux-system namespace
✔ install completed
◎ verifying installation
✔ source-controller ready
✔ kustomize-controller ready
✔ helm-controller ready
✔ notification-controller ready
✔ install finished
```

3.	Verify that Flux is installed in your Cluster, let's verify that the pods are in ready state. 
```
kubectl get pod -n flux-system
``` 

output:
```
NAME                                      READY   STATUS    RESTARTS   AGE
helm-controller-c65c64b89-lvlmr           1/1     Running   0          2m59s
kustomize-controller-77789fd79f-bvrz6     1/1     Running   0          2m59s
notification-controller-7c8779c44-9k6kr   1/1     Running   0          2m59s
source-controller-6bb5dc558c-nj2vz        1/1     Running   0          2m59s
```
4.	Now Observe flux custom resources
```
kubectl get crds -A
```

output:
```
NAME                                         CREATED AT
alerts.notification.toolkit.fluxcd.io        2021-02-02T09:15:37Z
buckets.source.toolkit.fluxcd.io             2021-02-02T09:15:37Z
gitrepositories.source.toolkit.fluxcd.io     2021-02-02T09:15:37Z
helmcharts.source.toolkit.fluxcd.io          2021-02-02T09:15:37Z
helmreleases.helm.toolkit.fluxcd.io          2021-02-02T09:15:37Z
helmrepositories.source.toolkit.fluxcd.io    2021-02-02T09:15:38Z
kustomizations.kustomize.toolkit.fluxcd.io   2021-02-02T09:15:38Z
providers.notification.toolkit.fluxcd.io     2021-02-02T09:15:38Z
receivers.notification.toolkit.fluxcd.io     2021-02-02T09:15:38Z
```

Well done, Flux is provisioned.

[Continue to Part 3 – Provision hello-kubernetes Application from GitHub](part3.md) 

If you want to return to the workshop homepage:

[Back to the general workshop section](README.md)
