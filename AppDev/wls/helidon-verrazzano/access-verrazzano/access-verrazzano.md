# Explore Verrazzano and Consoles

## Introduction

You deployed the Helidon *quickstart-mp* application. In this lab, we will access the application and verify using multiple management tools provided by Verrazzano.

### Grafana

Grafana is an open source solution for running data analytics, pulling up metrics that make sense of the massive amount of data & to monitor our apps with the help of nice customizable dashboards. The tool helps to study, analyse & monitor data over a period of time, technically called time series analytics.
Useful to track the user behaviour, application behaviour, frequency of errors popping up in production or a pre-prod environment, type of errors popping up and the contextual scenarios by providing relative data.

[https://grafana.com/grafana/](https://grafana.com/grafana/)

### OpenSearch Dashboards

OpenSearch Dashboards is a visualization dashboard for the content indexed on an OpenSearch cluster. Verrazzano creates a OpenSearch Dashboards deployment to provide a user interface for querying and visualizing the log data collected in OpenSearch.

To access the OpenSearch Dashboards console, read [Access Verrazzano](https://verrazzano.io/latest/docs/access/).

To see the records of an OpenSearch index through OpenSearch Dashboards, create an index pattern to filter for records under the desired index.

In Task 3, we will explore the OpenSearch Dashboards.

[https://opensearch.org/docs/latest/dashboards/index/](https://opensearch.org/docs/latest/dashboards/index/)

### Prometheus

Prometheus is a monitoring and alerting toolkit. Prometheus collects and stores its metrics as time series data, i.e. metrics information is stored with the timestamp at which it was recorded, alongside optional key-value pairs called labels.

[https://prometheus.io/](https://prometheus.io/)

### Rancher

Rancher is a platform that enables Verrazzano to run containers on multiple Kubernetes clusters in production. It enables hybrid which means single pane of glass management of on-prem clusters and hosted on cloud services like.

[https://rancher.com/](https://rancher.com/)

### Objectives

In this lab, you will:

* Explore the Verrazzano console.
* Explore the Grafana console.
* Explore the OpenSearch Dashboards.
* Explore the Prometheus console.
* Explore the Rancher console.

### Prerequisites

* Kubernetes (OKE) cluster running on the Oracle Cloud Infrastructure.
* Verrazzano installed on a Kubernetes (OKE) cluster.
* Deployed Helidon *quickstart-mp* application.


## Task 1: Explore the Verrazzano Console

Verrazzano installs several consoles. The endpoints for an installation are stored in the `Status` field of the installed Verrazzano Custom Resource.

1. You can get the endpoints for these consoles by using the following command:

      ```bash
      <copy>kubectl get vz -o jsonpath="{.items[].status.instance}" | jq .</copy>
      ```

   The output should be similar to the following:
      ```bash
      $ kubectl get vz -o jsonpath="{.items[].status.instance}" | jq .
      {
      "consoleUrl": "https://verrazzano.default.XX.XX.XX.XX.nip.io",
      "elasticUrl": "https://elasticsearch.vmi.system.default.XX.XX.XX.XX.nip.io",
      "grafanaUrl": "https://grafana.vmi.system.default.XX.XX.XX.XX.nip.io",
      "keyCloakUrl": "https://keycloak.default.XX.XX.XX.XX.nip.io",
      "kialiUrl": "https://kiali.vmi.system.default.XX.XX.XX.XX.nip.io",
      "kibanaUrl": "https://kibana.vmi.system.default.XX.XX.XX.XX.nip.io",
      "prometheusUrl": "https://prometheus.vmi.system.default.1XX.XX.XX.XX.nip.io",
      "rancherUrl": "https://rancher.default.XX.XX.XX.XX.nip.io"
      }
      $
      ```


2. Use the `https://verrazzano.default.YOUR_UNIQUE_IP.nip.io` to open the Verrazzano console.

3. Verrazzano *dev* profile use self-signed certificates, so you need to click **Advanced** to accept risk and skip warning.

![Advanced](images/VerrazzanoAdvanced.png)

4. Click **Proceed to verrazzano default XX.XX.XX.XX.nip.io(unsafe)**. If you are the not getting this option for proceed, just type *thisisunsafe* without any space anywhere inside this chrome browser window. As you are typing in the chrome browser window, you can't see it, but as soon as you finish typing *thisisunsafe*, you can see next page immediately. You can find more details [here](https://verrazzano.io/latest/docs/faq/faq/#enable-google-chrome-to-accept-self-signed-verrazzano-certificates).

![Proceed](images/VerrazzanoProceed.png)

5. Because it redirects to the Keycloak console URL for authentication, click **Advanced**.

![Keycloak Authentication](images/KeycloakAdvanced.png)

6. Click **Proceed to Keycloak default XX.XX.XX.XX.nip.io(unsafe)**. If you are the not getting this option for proceed, just type *thisisunsafe* without any space anywhere inside this chrome browser window. As you are typing in the chrome browser window, you can't see it, but as soon as you finish typing *thisisunsafe*, you can see next page immediately. You can find more details [here](https://verrazzano.io/latest/docs/faq/faq/#enable-google-chrome-to-accept-self-signed-verrazzano-certificates).

![Proceed](images/KeycloakProceed.png)

7. Now we need the username and password for the Verrazzano console. *Username* is *verrazzano* and to find out the password, go back to the *Cloud Shell* and paste the following command to find out the password for the *Verrazzano Console*.

```bash
<copy>kubectl get secret --namespace verrazzano-system verrazzano -o jsonpath={.data.password} | base64 --decode; echo</copy>
```

8. Copy the password and go back to the browser, where the *Verrazzano Console* is open. Paste the password in the *Password* field and enter *verrazzano* as *Username* and then click **Sign In**.

![SignIn](images/VerrazzanoSignIn.png)

9. From the home page of the Verrazzano Console, you can see *System Telemetry*, and because we installed the *Development Profile* of Verrazzano, you can see it in the **General Information** section. You can see the Helidon *quickstart-mp* application under **OAM Applications**. Click **hello-helidon-appconf** to view components of this application.

![Home Page](images/VerrazzanoHomePage.png)

10. There is only one component for this application as you can see under **Components**. To explore the configuration click the **OAM Component Ref:** *hello-helidon-component* component as shown:

![hello-helidon](images/VerrazzanoComponents.png)

11. You can see *General Information* for this component. To learn about the *Workload Spec*, click **hello-helidon-component** as shown:

![Workload spec](images/WorkloadSpec.png)

12. Here you can see the configuration details for the *hello-helidon-component* component. Click **Close**.

![configuration](images/configuration.png)

## Task 2: Explore the Grafana Console

1. Click **Home** to go back to Verrazzano Console Home Page.

![Home](images/GrafanaLink.png)

2. On the home page, you'll see the link for opening the *Grafana console*. Click the link for the **Grafana Console** as shown:

![Grafana Home](images/GrafanaLink2.png)

3. Click **Advanced**.

![Advanced](images/GrafanaAdvanced.png)

4. Click **Proceed to grafana.vmi.system.default.XX.XX.XX.XX.nip.io(unsafe)**. If you are the not getting this option for proceed, just type *thisisunsafe* without any space anywhere inside this chrome browser window. As you are typing in the chrome browser window, you can't see it, but as soon as you finish typing *thisisunsafe*, you can see next page immediately. You can find more details [here](https://verrazzano.io/latest/docs/faq/faq/#enable-google-chrome-to-accept-self-signed-verrazzano-certificates).

![proceed](images/GrafanaProceed.png)

5. The Grafana home page opens. Click **Home** at the top left.

![Home](images/GrafanaHome.png)

6. Type `Helidon` and you will see *Helidon Monitoring Dashboard* under **General**. Click **Helidon Monitoring Dashboard**.

![Helidon dashboard](images/SearchHelidon.png)

7. Observe the JVM details of the Helidon *quickstart-mp* application such as Status, Heap Usage, Running Time, JVM Heap, Thread Count, HTTP Requests, etc. This is a prebuilt dashboard specifically for Helidon workloads. Of course you can customize this dashboard according to your needs and add custom diagnostics information.

![Dashboard](images/HelidonDashboard.png)

## Task 3: Explore the OpenSearch Dashboards

1. Go back to the Verrazzano home page and click **OpenSearch Dashboards** console.

![Kibana link](images/OpenSearchLink.png)

2. Click *Proceed to ... default XX.XX.XX.XX.nip.io(unsafe)* if necessary. First time *OpenSearch Dashboards* shows the welcome page. It offers built in sample data to try OpenSearch but you can select the **Explore on my own** option, because Verrazzano completed the necessary configuration and the application data is already available.

![Kibana welcome page](images/OpenSearchProceed.png)

3. On the OpenSearch homepage click the **Home** -> **Discover**.

![Kibana dashboard click](images/Discover1.png)

4. In order to find log entry in OpenSearch first you need to define index pattern. Click *Create index pattern*. Type `verrazzano-namespace-hello-helidon` in the **Index Pattern name**. Select the result from the list below and click **Next step** as shown.

![Index pattern](images/CreateIndex.png)
![Index pattern](images/IndexPattern.png)

5. On the next page select *@timestamp* as **Time Filter** field name and click **Create Index pattern**.

![Index pattern](images/TimeFilter.png)

6. When the index is ready you need to click *Home* -> *Discover*. 

![Index pattern](images/Discover2.png)

7. Type the custom log entry value you created in the Helidon application: `Help requested` into the filter textbox. Press **Enter** or click **Refresh**. You should get at least one result. <br>
>If you haven't hit the application endpoint, or that happened a long time ago, simply invoke again the following HTTP request in the Cloud Shell against your endpoint. You can execute request multiple times.
```bash
<copy>curl -k https://$(kubectl get gateway hello-helidon-hello-helidon-appconf-gw -n hello-helidon -o jsonpath={.spec.servers[0].hosts[0]})/help/allGreetings; echo</copy>
```

![Log result](images/LogResult.png)

## Task 4: Explore the Prometheus Console

1. Go back to the Verrazzano home page and click **Prometheus** console.

![Prometheus link](images/PrometheusLink.png)

2. Click **Proceed to ... default XX.XX.XX.XX.nip.io(unsafe)** if prompted.

3. On the Prometheus dashboard page type *help* into the search field and click your custom metric *application _me _user _mp _quickstart _GreetHelpResource _helpCalled _total*.

![Prometheus execute](images/PrometheusQuery.png)

4. Click **Execute** and check the result below. You should see your metric's current value which means how many requests were completed by your endpoint. You can also switch to *Graph* view instead of the *Console* mode.

![Prometheus value](images/ExecuteQuery.png)

>You can also add another metric to your dashboard. Discover the available, default metrics in the list.

## Task 5: Explore the Rancher Console

1. Go back to the Verrazzano home page and click **Rancher** console.

![Rancher link](images/RancherLink.png)

2. Click **Proceed to ... default XX.XX.XX.XX.nip.io(unsafe)** if prompted.

3. Rancher requires separate credentials. In the Verrazzano `dev` profile the username is *admin*. To get the password execute the following command in Cloud Shell which extracts from the proper secret configuration:
```bash
<copy>kubectl get secret --namespace cattle-system rancher-admin-secret -o jsonpath={.data.password} | base64 --decode; echo</copy>
```
4. Using the values above login to the Rancher console.

![Rancher login](images/RancherLogin.png)
 > You may notice checkbox for *Allow collection of anonymous statistics*, Check this box and click *Got It*.
 ![Rancher Welcome](images/RancherWelcome.png)

5. On the Cluster Manager page you can monitor and manage multiple cluster controlled by Verrazzano. In this lab you have only one (OKE) cluster. Click on the **Explorer** button to open the *Cluster Explorer*. The *Cluster Explorer* allows you to view and manipulate all of the custom resources and CRDs in a Kubernetes cluster from the Rancher UI.

![Cluster Manager](images/RancherExplorer.png)

6. The dashboard gives an overview about the cluster and the deployed applications. The number of resources belong to the *User Namespaces* which is practically almost all the resources including the system too. You can filter by namespace at top of the dashboard, but this is not necessary now. Click on the **Nodes** item in the left side menu to get an overview about the current load of the nodes.

![Cluster Explorer](images/ClusterDashboard.png)

7. The whole deployment doesn't have any impact on the OKE cluster. Now click on the **Deployment** item in the left side menu to check your Helidon quickstart-mp application.

![Nodes](images/Nodes.png)

8. You can see several deployments. Click on the *hello-helidon-deployment*.

![Deployments](images/Deployments.png)

9. On the *Deployment* page you can see your application deployment. A deployment provides declarative updates for pods and replicasets. The pod name contains an auto generated unique string to identify that particular replica. To see how many and what type of containers are running in this pod click on the name.

![Helidon deployment](images/HelidonDeployment.png)

10. You should see two containers in the pod. The *hello-helidon-container* runs the "real" application and the other is the sidecar container which is automatically injected and necessary to take the advantage of the Istio features. Here you can check the application's log in the container. Click on the dotted menu button at top right corner and select **View Logs**.

![Pod](images/ViewLogs.png)

11. Make sure that the Helidon quickstart-mp application's container is selected in the log window. Find the custom `Help requested!` log entry. If you can't see the application log then click the **Settings** (blue button with the gear icon) and change the time filter to show all the log entries from the container start.

![Pod](images/Logs.png)

Congratulations you have successfully completed the Helidon application deployment on Verrazzano lab.

## Acknowledgements

* **Author** -  Peter Nagy
* **Contributors** - Maciej Gruszka, Peter Nagy
* **Last Updated By/Date** - Ankit Pandey, April 2022
