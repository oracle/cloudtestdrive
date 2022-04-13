# Deploy the Helidon Application on Verrazzano

## Introduction

### Verrazzano and Application Deployment

Verrazzano supports application definition using [Open Application Model (OAM)](https://oam.dev/). Verrrazzano applications are composed of components and application configurations.

When you deploy applications with Verrazzano, the platform sets up connections, network policies, and ingresses in the service mesh, and wires up a monitoring stack to capture the metrics, logs, and traces. Verrazzano employs OAM components to define the functional units of a system that are then assembled and configured by defining associated application configurations.

### Verrazzano components

A Verrazzano OAM component is a [Kubernetes Custom Resource](https://kubernetes.io/docs/concepts/extend-kubernetes/api-extension/custom-resources/) describing an application’s general composition and environment requirements.

The following code shows a simple Helidon application component for Helidon *quickstart-mp* application used in this lab. This resource describes a component which is implemented by a single Docker image containing a Helidon application exposing a single endpoint.

```yaml
apiVersion: core.oam.dev/v1alpha2
kind: Component
metadata:
  name: hello-helidon-component
  namespace: hello-helidon
spec:
  workload:
    apiVersion: oam.verrazzano.io/v1alpha1
    kind: VerrazzanoHelidonWorkload
    metadata:
      name: hello-helidon-workload
      labels:
        app: hello-helidon
    spec:
      deploymentTemplate:
        metadata:
          name: hello-helidon-deployment
        podSpec:
          containers:
            - name: hello-helidon-container
              image: "END_POINT_OF_YOUR_REGION/NAMESPACE_OF_YOUR_TENANCY/quickstart-mp:1.0"
              ports:
                - containerPort: 8080
                  name: http
```

A brief description of each field of the component:

* **apiVersion** - Version of the component custom resource definition
* **kind** - Standard name of the component custom resource definition
* **metadata.name** - The name used to create the component’s custom resource
* **metadata.namespace** - The namespace used to create this component’s custom resource
* **spec.workload.kind** - VerrazzanoHelidonWorkload defines a stateless workload of Kubernetes
* **spec.workload.spec.deploymentTemplate.podSpec.metadata.name** - The name used to create the stateless workload of Kubernetes
* **spec.workload.spec.deploymentTemplate.podSpec.containers** - The implementation containers
* **spec.workload.spec.deploymentTemplate.podSpec.containers.ports** - Ports exposed by the container

### Verrazzano Application Configurations

A Verrazzano application configuration is a Kubernetes Custom Resource which provides environment-specific customizations. The following code shows the application configuration for the Helidon *quickstart-mp* example used in this lab. This resource specifies the deployment of the application to the hello-helidon namespace.

Additional runtime features are specified using traits, or runtime overlays that augment the workload. For example, the ingress trait specifies the ingress host and path, while the metrics trait provides the Prometheus scraper used to obtain the application related metrics.

```yaml
apiVersion: core.oam.dev/v1alpha2
kind: ApplicationConfiguration
metadata:
  name: hello-helidon-appconf
  namespace: hello-helidon
  annotations:
    version: v1.0.0
    description: "Hello Helidon application"
spec:
  components:
    - componentName: hello-helidon-component
      traits:
        - trait:
            apiVersion: oam.verrazzano.io/v1alpha1
            kind: MetricsTrait
            spec:
                port: 8080
                scraper: verrazzano-system/vmi-system-prometheus-0
        - trait:
            apiVersion: oam.verrazzano.io/v1alpha1
            kind: IngressTrait
            metadata:
              name: hello-helidon-ingress
            spec:
              rules:
                - paths:
                    - path: "/help/allGreetings"
                      pathType: Prefix
```

A brief description of each field in the application configuration:

* **apiVersion** - Version of the ApplicationConfiguration custom resource definition
* **kind** - Standard name of the application configuration custom resource definition
* **metadata.name** - The name used to create this application configuration resource
* **metadata.namespace** - The namespace used for this application configuration custom resource
* **spec.components** - Reference to the application’s components leveraged to specify runtime configuration
* **spec.components[].traits** - The traits specified for the application’s components

To explore traits, we can examine the fields of an ingress trait:

* **apiVersion** - Version of the OAM trait custom resource definition
* **kind** - IngressTrait is the name of the OAM application ingress trait custom resource definition
* **spec.rules.paths** - The context paths for accessing the application

This lab walks you through the process of deploying the Helidon quickstart-mp application.

### Objectives

In this lab, you will:

* Verify the successful installation of the Verrazzano environment.
* Deploy the Helidon *quickstart-mp* application.
* Verify the deployment of the Helidon *quickstart-mp* application.

### Prerequisites

To run this lab, you must have:

* Kubernetes (OKE) cluster running on the Oracle Cloud Infrastructure.
* Verrazzano installation started on a Kubernetes (OKE) cluster.
* Container packaged Helidon *quickstart-mp* application available in container registry.

## Task 1: Verify the Verrazzano Installation is Complete

1. In Lab 3, we ran the below copy the command in the Cloud Shell. This command checks that the *InstallComplete* condition has been met and notifies you. In this example, *example-verrazzano* is the name of the *Verrazzano Custom Resource*.

```bash
<copy>kubectl wait --timeout=20m --for=condition=InstallComplete verrazzano/example-verrazzano</copy>
```
When the process is complete you should see the `verrazzano.install.verrazzano.io/example-verrazzano condition met` response.

Or, another option is to check that the pods associated with Verrazzano have a *Running* status. You will have 16 pods in the *Running* state.

```bash
<copy>kubectl get pods -n verrazzano-system</copy>
```

The output should be similar to the following:

```bash
kubectl get pods -n verrazzano-system
NAME                                           READY STATUS    RESTARTS   AGE
coherence-operator-dcfb446df-5dckp             1/1   Running   1          8m57s
fluentd-cgrg5                                  2/2   Running   1          6m22s
fluentd-jztnn                                  2/2   Running   1          6m22s
fluentd-n4s95                                  2/2   Running   1          6m22s
oam-kubernetes-runtime-549db9798b-grxj4        1/1   Running   0          8m50s
verrazzano-application-operator-54668f668-bng5 1/1   Running   0          8m9s
verrazzano-authproxy-86fb64c9f-4mffq           2/2   Running   0          6m22s
verrazzano-console-6c8d4875cf-r6bsv            2/2   Running   0          6m22s
verrazzano-monitoring-operator-787bfc7f86-p6qb 1/1   Running   0          6m22s
verrazzano-operator-6cc79dfdcc-6l9lt           1/1   Running   0          6m22s
vmi-system-es-master-0                         2/2   Running   0          4m37s
vmi-system-grafana-666f6854b4-xrmwf            2/2   Running   0          4m37s
vmi-system-kiali-5949966fb8-gczd5              2/2   Running   0          6m17s
vmi-system-kibana-95d8c5d96-9qr9j              2/2   Running   0          4m37s
vmi-system-prometheus-0-74478c9d44-gk85g       3/3   Running   0          3m6s
weblogic-operator-5df5f94bd7-tkg74             2/2   Running   0          8m17s
$
```

## Task 2: Deploy the Helidon quickstart-mp application

1. Download the Verrazzano OAM component yaml file and Verrazzano Application Configuration files in the Cloud Shell environment:

```bash
<copy>
curl -LSs https://raw.githubusercontent.com/oracle/learning-library/master/developer-library/multicloud/helidon-verrazzano/hello-helidon-app.yaml >~/hello-helidon-app.yaml
curl -LSs https://raw.githubusercontent.com/oracle/learning-library/master/developer-library/multicloud/helidon-verrazzano/hello-helidon-comp.yaml >~/hello-helidon-comp.yaml
cd ~
</copy>
```
2. Modify the image name in *hello-helidon-comp.yaml*. You can use the `vi` editor:
```bash
<copy>vi ~/hello-helidon-comp.yaml</copy>
```

3. Use `i` to change insert mode and modify the image name to reflect your repository path at line 23:
```yaml
image: "END_POINT_OF_YOUR_REGION/NAMESPACE_OF_YOUR_TENANCY/quickstart-mp-your_first_name:1.0"
```
For example:
```yaml
image: "ocir.io/tenancynamespace/quickstart-mp-your_first_name:1.0"
```
4. Use `Esc` the quit insert mode and type `:wq` to save changes and close the editor.


5. Create a `hello-helidon` namespace for the Helidon quickstart-mp application. We will keep all Kubernetes artifacts in the separate namespace.

  ```bash
  <copy>
  kubectl create namespace hello-helidon
  </copy>
  ```

  >Namespaces are a way to organize clusters into virtual sub-clusters. We can have any number of namespaces within a cluster, each logically separated from others but with the ability to communicate with each other.

6. We need to make Verrazzano aware that we store in that namespace Verrazzano artifacts. So we need to add a label identifying the `hello-helidon` namespace as managed by Verrazzano. Labels are intended to be used to specify identifying attributes of objects that are meaningful and relevant to users.

  Here, for the `hello-helidon` namespace, we are attaching a label to it, which marks this namespace as managed by Verrazzano. The *istio-injection=enabled*, enables an Istio "sidecar", and as such, helps establish an Istio proxy. With an Istio proxy, we can access other Istio services like an Istio gateway. To add the label to the `hello-helidon` namespace with the previously mentioned attributes, copy the following command and run it in the Cloud Shell:

  ```bash
  <copy>
  kubectl label namespace hello-helidon verrazzano-managed=true istio-injection=enabled
  </copy>
  ```


7. Now, we want to deploy Helidon *quickstart-mp* containerized application on *cluster1*. For this, we need a Kubernetes deployment configuration. This deployment instructs the Kubernetes to create and update instances for the Helidon *quickstart-mp* application. Here, we have the `hello-helidon-comp.yaml` file, which instructs Kubernetes.

To deploy the Helidon *quickstart-mp* application, copy and paste the following two commands as shown. The `hello-helidon-comp.yaml` file contains definitions of various OAM components, where, an OAM component is a Kubernetes Custom Resource describing an application’s general composition and environment requirements.

```bash
<copy>kubectl apply -f ~/hello-helidon-comp.yaml</copy>
```

The `hello-helidon-app.yaml` file is a Verrazzano application configuration file, which provides environment-specific customizations.

```bash
<copy>kubectl apply -f ~/hello-helidon-app.yaml</copy>
```

8. Wait for the pods to be in *Running* status. Use this *kubectl* command to wait for all the pods to be in the *Running* state within the hello-helidon namespace. It takes around 1-2 minutes.

```bash
<copy>kubectl wait --for=condition=Ready pods --all -n hello-helidon --timeout=600s</copy>
```

When the pods are ready you can see similar response:

```bash
$ kubectl wait --for=condition=Ready pods --all -n hello-helidon --timeout=600s
pod/hello-helidon-deployment-58fdd5cd4-94wjf condition met
```
You can also list the pods directly to check their status:

```bash
$ kubectl  get po -n hello-helidon
NAME                                       READY   STATUS    RESTARTS   AGE
hello-helidon-deployment-58fdd5cd4-94wjf   2/2     Running   0          34m
```



## Task 3: Verify the Successful Deployment of the Helidon quickstart-mp Application

1. Verify the `help/allGreetings` endpoint. To determine the URL that was constructed from the external/load balancer IP and application configuration, execute the following command:

```bash
<copy>echo https://$(kubectl get gateway hello-helidon-hello-helidon-appconf-gw -n hello-helidon -o jsonpath={.spec.servers[0].hosts[0]})/help/allGreetings</copy>
```

This will print the proper URL to your REST endpoint, for example:

```bash
https://hello-helidon-appconf.hello-helidon.xx.xx.xx.xx.nip.io/help/allGreetings
```

2. Use this link to test from your browser. Due to self-signed certificates, however, you need to accept risk and allow the browser to continue the request processing.

You may find it easier to use `curl` because the response is only a string:

```bash
<copy>curl -k https://$(kubectl get gateway hello-helidon-hello-helidon-appconf-gw -n hello-helidon -o jsonpath={.spec.servers[0].hosts[0]})/help/allGreetings; echo</copy>
```

You should see the same result you received during the development:


```yaml
[Hello, Привет, Hola, Hallo, Ciao, Nǐ hǎo, Marhaba, Olá]
```

3. Leave the *Cloud Shell* open; we will use it for the next lab.

## Acknowledgements

* **Author** -  Peter Nagy
* **Contributors** - Maciej Gruszka, Peter Nagy
* **Last Updated By/Date** - Ankit Pandey, April 2022
