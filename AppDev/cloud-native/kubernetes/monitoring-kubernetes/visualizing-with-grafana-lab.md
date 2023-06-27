![Title image](../../../../common/images/customer.logo2.png)

# Visualize metrics data with Grafana


<details><summary><b>Self guided student - video introduction</b></summary>


This video is an introduction to the Visualizing metrics with Grafana lab. Depending on your browser settings it may open in this tab / window or open a new one. Once you've watched it please return to this page to continue the labs.

[![Visualizing metrics with Grafana lab Introduction Video](https://img.youtube.com/vi/upAhbUQ0K7s/0.jpg)](https://youtu.be/upAhbUQ0K7s "Visualizing metrics with Grafana lab introduction video")

---

</details>

## Introduction

This is one of the optional sets of Kubernetes labs

**Estimated module duration** 30 mins.

### Objectives

This module shows how to install the data visualisation tool Grafana and configure it to use Prometheus as a data source. You will then create a simple dashboard using this data, and explore how complex dashboard can be using a pre-built example.

### Prerequisites

The **Prometheus for metrics capture** module must have been completed before you can do this module, and you must have left the Prometheus server running. If you stopped it then follow the instructions to install it again (the deployments will still have the correct annotations.)

## Task 1: Displaying data with Grafana

As we've seen while Prometheus can gather lots of data, it is not exactly the most powerful visualization mechanism.

Grafana on the other hand is a very powerful open source visualization engine and it can take data from many sources, including Prometheus.  The core engine of Grafana is Open source.  However some of the additional component features (for example specific dashboard configurations, plugins for graph types etc.) are not open source.

For this lab we will use a small subset of the open source features only.

## Task 2: Installing Grafana

Reminder - This lab requires that you have the Prometheus service installed and the `monitoring` namespace in place. This is covered in the **Prometheus for metrics capture** module. If at the end of that module you deleted the Promtheus stack and the `monitoring` namespace you will have to re-create them before proceeding with this module.

Like many other Kubernetes services Grafana can be installed using helm. By default the helm chart does not create a volume for the storage of the grafana configuration. This would be a problem in a production environment, so we're going to use the persistent storage option defined in the helm chart for Grafana to create a storage volume. 

  1. Add the Helm repository entry for Grafana 
  
  ```bash
  <copy>helm repo add grafana https://grafana.github.io/helm-charts</copy>
  ```

 ```
"grafana" has been added to your repositories
```

If you have already added the repository in another module of the lab you'll be told it's already there, that's fine.

  2. Update the repository cache
  
  ```bash
  <copy>helm repo update</copy>
  ```

  ```
Hang tight while we grab the latest from your chart repositories...
...Successfully got an update from the "kubernetes-dashboard" chart repository
...Successfully got an update from the "prometheus-community" chart repository
...Successfully got an update from the "grafana" chart repository
.
.
.
Update Complete. ⎈ Happy Helming!⎈ 
```

Depending on what modules you have done previously the updated repositories list may vary

If your cloud shell session is new or has been restarted then the shell variable `$EXTERNAL_IP` may be invalid, expand this section if you think this may be the case to check and reset it if needed.

<details><summary><b>How to check if $EXTERNAL_IP is set, and re-set it if it's not</b></summary>

**To check if `$EXTERNAL_IP` is set**

If you want to check if the variable is still set type `echo $EXTERNAL_IP` if it returns the IP address you're ready to go, if not then you'll need to re-set it, there are a couple of ways to do this, expand the appropriate section below.
  
<details><summary><b>If you used the automated scripts in the kubernetes-lab directory to setup the microservices in Kubernetes</b></summary>

  - Open the OCI cloud shell 

The automated scripts will create a script file `$HOME/clusterSettings.one` this can be executed using the shell built in `source` to set the EXTERNAL_IP variable for you.

  ```bash
  <copy>source $HOME/clusterSettings.one</copy>
  ```
  
```
EXTERNAL_IP set to 139.185.45.98
NAMESPACE set to tg
```

  Of course the actual IP address and namespace will almost certainly be different from the example here !
  
---

</details>

<details><summary><b>If you manually setup the Kubernetes ingress services using helm</b></summary>

In this case as you manually set this up you will need to get the information from Kubernetes itself


  - Open the OCI cloud shell 

  - You are going to get the value of the `EXTERNAL_IP` for your environment. This is used to identify the DNS name used by an incoming connection. In the OCI cloud shell type

  ```bash
  <copy>kubectl get services -n ingress-nginx</copy>
  ```

```
NAME                                 TYPE           CLUSTER-IP      EXTERNAL-IP      PORT(S)                      AGE
ingress-nginx-controller             LoadBalancer   10.96.182.204   130.162.40.241   80:31834/TCP,443:31118/TCP   2h
ingress-nginx-controller-admission   ClusterIP      10.96.216.33    <none>           443/TCP                      2h
```

  - Look for the `ingress-nginx-controller` line and note the IP address in the `EXTERNAL-IP` column, in this case that's `130.162.40.121` but it's almost certain that the IP address you have will differ. IMPORTANT, be sure to use the IP in the `EXTERNAL-IP` column, ignore anything that looks like an IP address in any other column as those are internal to the OKE cluster and not used externally. 

  - IN the OCI CLoud shell type the following, replacing `[external ip]` with the IP address you retrieved above.
  
  ```bash
  export EXTERNAL_IP=[external ip]
  ```
  
---

</details>

</details>

  3. Make sure you're in the `$HOME/helidon-kubernetes/monitoring-kubernetes` directory
  
  ```bash
  <copy>cd $HOME/helidon-kubernetes/monitoring-kubernetes</copy>
  ```

  4. Create a certificate to protect the connection, we'll use step which we installed in the cloud shell setup section of the lab.
  
  ```bash
  <copy>$HOME/keys/step certificate create grafana.monitoring.$EXTERNAL_IP.nip.io tls-grafana-$EXTERNAL_IP.crt tls-grafana-$EXTERNAL_IP.key --profile leaf  --not-after 8760h --no-password --insecure --kty=RSA --ca $HOME/keys/root.crt --ca-key $HOME/keys/root.key</copy>
  ```
  
  ```
  Your certificate has been saved in tls-grafana-123.456.789.123.crt.
  Your private key has been saved in tls-grafana-123.456.789.123.key.
```

(The above is example output, your files will be based on the IP you provided)

If your output says it's created key files like `tls-grafana-.crt` and does not include the IP address then the `EXTERNAL_IP` variable is not set, please follow the instructions in Task 1 and re-run the step certificate creation command

  5. Now let's create a TLS secret containing this configuration. 
  
  ```bash
  <copy>kubectl create secret tls tls-grafana --key tls-grafana-$EXTERNAL_IP.key --cert tls-grafana-$EXTERNAL_IP.crt -n monitoring</copy>
  ```
  
  ```
  secret/tls-grafana created
  ```

  6. Let's install Grafana itself. In the OCI Cloud Shell type following command, replace `<External IP>` with the IP address of the load balancer we've been using for all the other steps.
  
  ```bash
  <copy>helm install grafana grafana/grafana --version 6.56.2 --namespace  monitoring  --set persistence.enabled=true --set ingress.enabled=true --set ingress.hosts="{grafana.monitoring.$EXTERNAL_IP.nip.io}" --set ingress.tls[0].secretName=tls-grafana --set ingress.annotations."kubernetes\.io/ingress\.class"=nginx</copy>
  ```

  ```
NAME: grafana
LAST DEPLOYED: Wed Jun 30 18:18:59 2021
NAMESPACE: monitoring
STATUS: deployed
REVISION: 1
NOTES:
1. Get your 'admin' user password by running:

   kubectl get secret --namespace monitoring grafana -o jsonpath="{.data.admin-password}" | base64 --decode ; echo

2. The Grafana server can be accessed via port 80 on the following DNS name from within your cluster:

   grafana.monitoring.svc.cluster.local

   If you bind grafana to 80, please update values in values.yaml and reinstall:
   
   securityContext:
     runAsUser: 0
     runAsGroup: 0
     fsGroup: 0

   command:
   - "setcap"
   - "'cap_net_bind_service=+ep'"
   - "/usr/sbin/grafana-server &&"
   - "sh"
   - "/run.sh"
   
   Details refer to https://grafana.com/docs/installation/configuration/#http-port.
   Or grafana would always crash.

   From outside the cluster, the server URL(s) are:
     http://grafana.monitoring.123.456.789.999.nip.io


3. Login with the password from step 1 and the username: admin
```

Note that normally you would not expose Grafana directly like this but woudl use an official certificate. For the lab we're just using a self signed certificate.

Like many helm charts the output has some useful hints in it, specifically in this case how to get the admin password and setup port-forwarding using Kubectl.

  7. Now get the Grafana login password. In the OCI Cloud Shell 
  
  ```bash
  <copy>kubectl get secret --namespace monitoring grafana -o jsonpath="{.data.admin-password}" | base64 --decode ; echo</copy>
  ```
  
  ```
G5gBdejUfBxhzKn4ZrmwhZQTtlXlZ9qaLHpzispm
```

Of course **your** password will vary, this is just an example

  8. **Copy and paste** the password into a text editor so you can use it later.

We need some data to look at, so :

  9. Using the OCI Cloud Shell or your laptop, make a few requests using curl to generate some new data.
  
  ```bash
  <copy>curl -i -k -X GET -u jack:password https://store.$EXTERNAL_IP.nip.io/store/stocklevel</copy>
  ```

We need to open a web page to the Grafana service. This was displayed in the Helm output, in this example it's `http://grafana.monitoring.123.456.789.999.nip.io` ** but of of thats an example, your's will vary** (and that's not a valid address anyway)

  10. Open a web page (replace `<External IP>` with the one for the load balancer.
  
  ```
  https://grafana.monitoring.<External IP>.nip.io
  ```
  

If the browser prompts you about using a self signed certificate accept it. The process for doing this can vary by browser and version, as of August 2020 the following worked, but newer versions may have changed it.

  - In Safari you will be presented with a page saying "This Connection Is Not Private" Click the "Show details" button, then you will see a link titled `visit this website` click that, then click the `Visit Website` button on the confirmation pop-up. To update the security settings you may need to enter a password, use Touch ID or confirm using your Apple Watch.
  
  - In Firefox once the security risk page is displayed click on the "Advanced" button, then on the "Accept Risk and Continue" button
  
  - In Chrome once the "Your connection is not private" page is displayed click the advanced button, then you may see a link titled `Proceed to ....(unsafe)` click that. 
  
We have had reports that some versions of Chrome will not allow you to override the page like this, for Chrome 83 at least one solution is to click in the browser window and type the words `thisisunsafe` (copy and past doesn't seem to work, you need to actually type it). Alternatively use a different browser.


You'll be presented with the Grafana login window
  ![Grafana login](images/grafana-login.png)

  11. Enter **admin** as the user name and then use the Grafana password you copied a few moments ago. 

  12. Press enter to login and go to the Grafana initial config page

  ![Initial pre-configuration Grafana page](images/grafana-initial-setup.png)

Before we can do anything useful with Grafana we need to provide it with some data. 

  13. Click the **Add Your First Data Source** icon to start this process

  ![List of potential data sources for Grafana](images/grafana-possible-data-sources.png)

  14. Select **Prometheus**  from the list, then when the UI displays it click the **Select** button

  ![Completing the details for the Prometheus data source](images/grafana-configure-prometheus-data-source.png)

  15. In the **URL** field we need to enter the details we got then we installed Prometheus. Enter the URL 
  
  ```
  <copy>http://prometheus-server.monitoring.svc.cluster.local</copy>
  ```

Leave the other values unchanged

  16. Scroll down and click the **Save & Test** button at the bottom of the screen. 

  ![Saving and testing the data we entered for the Prometheus data soruce](images/grafana-configure-prometheus-data-source-save-and-test.png)

Assuming you entered the details correctly it will report that it's done the save and that the data source is working

  ![The saved Promethus data source configured in Grafana](images/grafana-configure-prometheus-data-source-saved.png)

  17. Click the **Grafana logo** ![grafana-logo](images/grafana-logo.png) at the top left to return to the Grafana home page

  ![The Grafana home page with a data source](images/grafana-home-datasource-done.png)
  
## Task 3: Creating our first dashboard

We now need to configure a dashboard that will display data for us.

### Task 3a: Create our initial visualisation

  ![Creating our first Grafana dashboard](images/grafana-home-create-first-dashboard.png)
  
  1. Click the **Create your first dashboard** button to start the process

  ![Add the first panel to the dashboard](images/grafana-new-dashboard-add-first-panel.png)

  2. In the new Panel click the **Add an empty panel** button to define the data we want to retrieve

  ![Definign the data query for our new panel](images/grafana-new-dashboard-first-panel-add-query.png)

  3. In the Metrics browser enter `application_listAllStockMeter_one_min_rate_per_second` then click in the Graph box (for example where it says `No Data In respomse` )

![Usinf the list stock data rate as the query](images/grafana-new-dashboard-first-panel-add-query-list-stock-meter-rate.png)

You may recall that this it the data set for the number of list stock requests made per second averaged over a minute.

Once you've entered this it then the display will update with the graph you've selected

  ![The new panel with the per pod data rate](images/grafana-new-dashboard-first-panel-add-query-list-stock-meter-rate-individual-pods.png)
  
If your cloud shell session is new or has been restarted then the shell variable `$EXTERNAL_IP` may be invalid, expand this section if you think this may be the case to check and reset it if needed.

<details><summary><b>How to check if $EXTERNAL_IP is set, and re-set it if it's not</b></summary>

**To check if `$EXTERNAL_IP` is set**

If you want to check if the variable is still set type `echo $EXTERNAL_IP` if it returns the IP address you're ready to go, if not then you'll need to re-set it.

**To get the external IP address if you no longer have it**

In the OCI Cloud shell type

  ```bash
  <copy>kubectl --namespace ingress-nginx get services -o wide ingress-nginx-controller</copy>
  ```
  
  ```
NAME                       TYPE           CLUSTER-IP    EXTERNAL-IP      PORT(S)                      AGE   SELECTOR
ingress-nginx-controller   LoadBalancer   10.96.61.56   132.145.235.17   80:31387/TCP,443:32404/TCP   45s   app.kubernetes.io/component=controller,app.kubernetes.io/instance=ingress-nginx,app.kubernetes.io/name=ingress-nginx
```

The External IP of the Load Balancer connected to the ingresss controller is shown in the EXTERNAL-IP column.

**To set the variable again** replacing `[External IP]` with the one you just retrieved for the load balancer

  ```bash
  export EXTERNAL_IP=[External IP]
  ```
  
---

</details>
  

  You should have some data in the graph, but if not then make a few requests 

  4. If needed use curl to generate some new data.
  
  ```bash
  <copy>curl -i -k -X GET -u jack:password https://store.$EXTERNAL_IP.nip.io/store/stocklevel</copy>
  ```
  
  ```
HTTP/2 200 
server: nginx/1.17.8
date: Fri, 27 Mar 2020 09:17:24 GMT
content-type: application/json
content-length: 220
strict-transport-security: max-age=15724800; includeSubDomains

[{"itemCount":4980,"itemName":"rivet"},{"itemCount":4,"itemName":"chair"},{"itemCount":981,"itemName":"door"},{"itemCount":25,"itemName":"window"},{"itemCount":20,"itemName":"handle"}]
```

You can refresh the graph using the refresh icon if you added some new data

  5. Click the time selector and chose a time period where you have data (In this case I'm going for the last hour)

  ![Selecting the time window for the panel](images/grafana-new-dashboard-first-panel-add-query-select-time-window.png)

Once you've clicked the time the graph will update

  ![After selecting the time window](images/grafana-new-dashboard-first-panel-add-query-selected-time-window.png)


You may see multiple pods listed in the legend (above one as a green line in the chart, the other as yellow). Do not worry if you can only see one, it depends on the exact flow and timing of the labs which will vary between participants.

Grafana allows us to combine the data using the Prometheus query language, by using the ***SUM*** function in the language to combine all of these.  If you only have one pod do the following anyway, just so see how to use functions)

  6. Click on the text in the **Metrics browser ** box and change it to 
  
  - `sum(application_listAllStockMeter_one_min_rate_per_second)` 
  
  - then click on the graph

  ![Combining the per second rate for all pods](images/grafana-new-dashboard-first-panel-add-query-list-stock-meter-rate-combined-pods.png)

Now any pod that provides the `application_listAllStockMeter_one_min_rate_per_second` data will be part of the total, giving us the total rate across all of the pods.

  ![Applying out new panel to the dashboard](images/grafana-new-dashboard-first-panel-apply-button.png.png)

  7. Click the **Apply** button on the upper right.

  ![The dashboard after adding the panel](images/grafana-new-dashboard-first-panel-added.png)

  8. Make a few requests using curl to generate some new data.
  
  ```bash
  <copy>curl -i -k -X GET -u jack:password https://store.$EXTERNAL_IP.nip.io/store/stocklevel</copy>
  ```

  ```
HTTP/2 200 
server: nginx/1.17.8
date: Fri, 27 Mar 2020 10:06:39 GMT
content-type: application/json
content-length: 220
strict-transport-security: max-age=15724800; includeSubDomains

[{"itemCount":4980,"itemName":"rivet"},{"itemCount":4,"itemName":"chair"},{"itemCount":981,"itemName":"door"},{"itemCount":25,"itemName":"window"},{"itemCount":20,"itemName":"handle"}]
```

After a bit of time for Helidon to update it's metrics (this is an average over 1 min) Prometheus to get round to scraping them and for Grafana to get round to retrieving them click the refresh icon on the upper right ![grafana-refresh-icon](images/grafana-refresh-icon.png) (We'll look at auto refresh in a bit).

  ![The combined stock rate list panel after waiting for data updates](images/grafana-new-dashboard-first-panel-add-query-list-stock-meter-rate-combined-pods-updated-graph.png)

If it hasn't updated after a bit you can force the screen to update, click the refresh icon on the upper right ![grafana-refresh-icon](images/grafana-refresh-icon.png) 

This is only a visuals update, if the scraping hasn't retrieved the updated data then you'll just have to wait for it to happen.

Once we've defined the query then we can look at the way it's displayed. 

Let's go back and edit the visuals

  9. Click the **Panel Title** then chose **Edit**

  ![Editing the firat panel](images/grafana-new-dashboard-edit-first-panel.png)

  10. On the right click on the graph type choice (Here this is set to **Time Series**)

  ![Chosing the visialisation options for the panel](images/grafana-new-dashboard-first-panel-visualization-options.png)

You can chose the visualization type you want

  11. As you can see there are a lot of options ![The set of Grafana visualization options](images/grafana-visualization-options.png). 

For now we're going to leave this as a **Time Series** graph, but if you want try clicking on some of the other options to see what they display, not all data makes sense in all visualization types though.

  ![Using the time series data graph](images/grafana-visualization-options-time-series.png)
  
For now (as there is only a single set of numeric data) we are going to leave this as a time series line graph, so just click on the **Time Series** option but we'll make it a little more interesting.

  12. On the right scroll down to the **Graph Styles**, if neede expand the selection with the arrow

  ![Opening the graph styles options](images/grafana-new-dashboard-first-panel-visualization-display-options.png)

  13. Set the **Line width** to `2` the **Fill Opacity** to `100` and the **Gradient mode** to `Opacity`

  ![Changing the graph visualisation details](images/grafana-new-dashboard-first-panel-visualization-options-updated.png)

  14. Notice that the graph displayed updates as you make changes.

  15. Scroll to the top of the right hand panel.

  16. In the **Panel Options** **Title** field enter a suitable title, for example  `Stock Listing Requests per second`

  ![Entering the title for the panel](images/grafana-new-dashboard-first-panel-general-options.png)
  
  17. Click back on the graph to apply the change
  
  ![Once the panel is titled](images/grafana-new-dashboard-first-panel-title-set.png)

  18. Click the **Apply** button at the top right to return to the New Dashboard
  
  ![Applying the updates to our panel](images/grafana-new-dashboard-first-panel-updated-apply-button.png)

Now we see our dashboard with a graph panel

   ![The updated panel](images/grafana-new-dashboard-first-panel-completed.png)
   
### Task 3b: Adding a second panel

Of course this looks pretty basic, It's good to see how many requests we're getting, but let's add an additional panel to give us a history of how many requests we've had . 

  1. Click on the  **Add Panel** icon on the upper right ![grafana-add-panel-icon](images/grafana-add-panel-icon.png) 

  ![Adding a second panel](images/grafana-dashboard-add-second-panel.png)

  2. Click the **Add a new panel** button

  2. In the metrics field, enter following (you can copy and paste if you wish) then click in the graph area

  - `avg(application_com_oracle_labs_helidon_storefront_resources_StorefrontResource_listAllStockTimer_mean_seconds)` 


  ![Using the average function on the request timer](images/grafana-dashboard-add-second-panel-timer-mean-seconds.png)

  4. In the Graph types section on the right hand menu (in the image shown this is titled **Time Series** but it changes based on the selected visualization). If it's not already selected chose **Time Series** as the type
  
  5. In the **Graph Styles** section on the right hand menu. Set the **Style** to **Bars** Note that the graph updates.

  ![Choesing the visual style for the secont panel](images/grafana-dashboard-add-second-panel-visualization.png)

  6. Move to the **Settings** section at the top of the right hand menu 

  ![Accessing the title field](images/grafana-dashboard-add-second-panel-general.png)

  7. In the **Panel Options** section set the title to `Response Times`
  
  8. Hit the **Apply** button on the upper right to return to the New Dashboard
  
  ![The dashboard after adding the second panel](images/grafana-dashboard-added-second-panel.png)
  
### Task 3c: Adding a different type of visualisation

We're going to add a 3rd panel with a different visualization type, using a dial graph that gives us a view of the most recent data.

  ![Adding the third panel](images/grafana-dashboard-add-third-panel.png)

  1. Click the **Add panel** icon then the **Add a New Panel** 

  ![Choosing the mean data for the timer](images/grafana-dashboard-add-third-panel-timer-seconds.png)

  2. In the **Metrics browser** set it to `application_com_oracle_labs_helidon_storefront_resources_StorefrontResource_listAllStockTimer_mean_seconds` then click in the graph area to get the data

We're going for a different visualization type. 

  ![Choding the graph type for the third panel](images/grafana-dashboard-add-third-panel-select-graph-type.png)
  
  3. In the graph selection on the right hand menu  (in this image this is set to **Time Series** )
  
  ![Selecting the gage visualisation type for the third panel](images/grafana-dashboard-add-third-panel-select-gauage-type.png)
  
  4. Chose the **Gauge** option, the display will update to show a gauge.  Note that the right hand menu has also changed a bit

  ![Accessing the options for the third panel gauge visual type](images/grafana-visualization-options-gauge.png)

  5. In the right hand section scroll down to the Gauge section, make sure that both **Show Threshold Labels** and **Show Threshold Markers** are enabled. 

  ![Threshold and markers selected for the gauge](images/grafana-visualization-options-gauge-display.png)
  
  6. We are going to override the max and min for the gauge, Sctoll down to the **Standard Options** section on the right panel, then set the **Min** to be `0` and the **Max** to be `1` Set the **Display Name** to be `Response Times`
  
  ![Selecting the min and max limits for the gauge](images/grafana-visualization-options-gauge-display-max-min.png)

  6. We now need to define different thresholds. Scroll further down the right section to find the **Thresholds** section, Click the **Add Threshold** button. You will see three entries.

  ![Selecting threshold colours for the guage](imnages/grafana-gauge-set-threshold-colours.png)
  
  7. The colours are a little wrong here, click on the colour next to the `90` threshold and in the resulting colour choser set it to Red, then got the `80` threshold set it to orange

  ![After updating the threshold colours](images/grafana-visualization-options-gauge-thresholds-added.png)

  9. In the text boxes representing the thresholds 
  
  - Set the Red threshold to be 0.5 
  
  - Set the yellow threshold to be 0.25
  
  ![Setting the threfhold values for our gauge bands](images/grafana-visualization-options-gauge-thresholds-adjusted.png)
  
Note that as you enter the values the order of the boxes may change.

  ![The final version of the gauge visual options](images/grafana-visualization-options-gauge-final.png)

  10. Scroll up to the top of the right hand panel, Remove any text in the panel title, Click the **Apply** to return to the New Dashboard

  ![Adding the third panel](images/grafana-three-panel-dashboard-colums.png)
  
### Task 3d: Organising the dashboard

We can see what data we're getting, but it's not that easy to look at.

Let's Re-arrange the panels a bit. 

  ![Panels as a vertical column](images/grafana-three-panel-dashboard-rearange-start.png)

  1. Click on the working of the middle panels title (Response Times) and drag it to the right of the gauge panel.

  ![Panels in a 2 column grid](images/grafana-three-panel-dashboard-grid.png)

We need to rename our panel, after all "New dashboard" is not especially descriptive. 

  ![Renaming the dashboard](images/grafana-three-panel-dashboard-grid-settings-icon.png)

  2. Click on the dashboard settings icon on the upper right of the window

  ![Settign the dashboard name](images/grafana-dashboard-settings.png)

  3. In the settings page give it a name, let's use `Stock Listing performance`, provide a description, *disable* the editing option, and set it to auto refresh when showing live data.

  ![Saving the dashbaord])images/grafana-dashboard-settings-save-button.png)
  
  4. Then click the **Save Dashboard** button
  
  ![Dashboard save dialogue box](images/grafana-dashboard-save-dialogue.png)

  5. In the popup checkthe dashboard is named `Stock Listing performance` then click the **Save** button

Confirm if prompted (Note you cannot save to the name of an existing dashboard)

Now we have our dashboard let's look at the time windows and set the auto refresh so as new data becomes available it will be displayed.

  ![Configuring the visuals auto refrech settings](images/grafana-dashboard-auto-refresh.png)

  6. Next to the **Refresh** icon click the menu to open up the auto-refresh options list. Chose 5 seconds from the list

Let's set it to display the most recent data

  ![Configuring the displayed data to be most recent](images/grafana-dashboard-display-range.png)
  
  7. Select the display range (set to `Last 1 hour` in this grab, and for the list chose `5 minutes`)
  
  ![After updating the dashboard time range](images/grafana-dashboard-display-update-updated.png)
  
  Note that the resulting dashboard doesn't have a lot to display as it's only showing recent data, and we haven't been doing a lot with the microservices themselves.

  8. In the cloud shell. Make a few requests using curl to generate some new data, remember if the cloud shell has timed out you will need to set the EXTERNAL_IP variable when you reconnect / create a new session.
  
  ```bash
  <copy>curl -i -k -X GET -u jack:password https://store.$EXTERNAL_IP.nip.io/store/stocklevel</copy>
  ```
  
```
HTTP/2 200 
server: nginx/1.17.8
date: Fri, 27 Mar 2020 13:35:04 GMT
content-type: application/json
content-length: 220
strict-transport-security: max-age=15724800; includeSubDomains

[{"itemCount":4980,"itemName":"rivet"},{"itemCount":4,"itemName":"chair"},{"itemCount":981,"itemName":"door"},{"itemCount":25,"itemName":"window"},{"itemCount":20,"itemName":"handle"}]
```
Within a min or two (remember Helidon, Prometheus and Grafana need to capture and process their data) the UI will update with the requests you've just made. Curiously in my case I had to actually click eht refresh button to get the latest data. I don;t know if this is an issue with this version of Grafana, the browser, or simply some cached data somewhere in my web proxies.

  ![After the data updates have made their way to the dashboard](images/grafana-dashboard-auto-refresh-happened.png)


## Task 4: More complex dashboards
This is a fairly simple dashboard, far more complex ones are easily achievable using a combination or Prometheus and Grafana. As an example we're going to look at a prebuilt dashboard.

  1. Click the **Grafana logo** ![grafana-logo](images/grafana-logo.png) on the upper left. 

  2. On the left side menu click the settings **cog**, and then **Datasources**.

  ![Accessing the datasourcesa list](images/grafana-config-menu.png)

  3. Click the entry for **Prometheus**

  ![The Prometheus data source](images/grafana-config-chose-prometheus.png)

  4. To get the list of dashboards click the **Dashboards** tab

  ![List of pre-build prometheus data soruce dashbaords](images/grafana-config-prometheus-dashboards.png)

  5. Click on the **import** button for each dashboard, 

The dashbaords will be imported (there will be a quick "I'm doing an import" message after each click) after which we can see they are all imported

  ![Imported the pre-build dashboard](images/grafana-prometheus-data-source-dashboards-import-done.png)

  6. Click the **Grafana** logo ![grafana-logo](images/grafana-logo.png) on the upper left. 
  
  7. Click the **Home** menu ![grafana-home-dashboards-menu](images/grafana-home-dashboards-menu.png) to get a list of available dashboards

  ![Updated list of dashboard in Grafana](images/grafana-home-available-dashboards.png)

  8. Click on the **Prometheus 2.0 Stats** option to see an example of a more comlex dashboard containing stats for Prometheus

  ![The Promethus statistics dashboard](images/grafana-prometheus-stats-dashboard.png)

---

## Task 5: Tidying up the environment

If you are in a trial tenancy there are limitations on how many Load Balancers and other resources you can have in use at any time, and you may need them for other modules. The simplest way to release the resources used in his module (including the load balancer) is to delete the entire namespace.

To delete the monitoring namespace do the following

  1. In the OCI Cloud shell type 
  
  ```bash
  <copy>kubectl delete namespace monitoring</copy>
  ```
  
  ```
namespace "monitoring" deleted
```

## End of the module, What's next ?

You can chose from the various Kubernetes optional module sets.

## Acknowledgements

* **Author** - Tim Graves, Cloud Native Solutions Architect, Oracle EMEA Cloud Native Application Development specialists Team
* **Contributor** - Jan Leemans, Director Business Development, EMEA Divisional Technology
* **Last Updated By** - Tim Graves, May 2023
