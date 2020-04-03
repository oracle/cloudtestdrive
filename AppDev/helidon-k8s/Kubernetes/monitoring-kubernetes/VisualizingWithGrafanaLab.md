[Go to Overview Page](../Kubernetes-labs.md)

![](../../../../common/images/customer.logo2.png)

# Migration of Monolith to Cloud Native

## C. Deploying to Kubernetes
## 3. Visualizing using Grafana

### **Introduction**
As we've seen while Prometheus can gather lots of data, it is not exactly the most powerful visualization mechanism.

Grafana on the other hand is a very powerful open source visualization engine and it can take data from many sources, including Prometheus.  The core engine of Grafana is Open source.  However some of the additional component features (for example specific dashboard configurations, plugins for graph types etc.) are not open source and are chargable.

For this lab we will use a small subset of the open source features only.

### Installing Grafana
Like many other Kubernetes services Grafana can be installed using helm. By default the helm chart does not create a volume for the storage of the grafana configuration. This would be a problem in a production environment, so we're going to use the persistent storage option defined inthe helm chart for Grafana to create a storage volume. 

- In the Oracle Cloud Shell type following command:
  -  `helm install grafana --namespace monitoring stable/grafana --set persistence.enabled=true --set service.type=LoadBalancer`

Note that normally you would not expose Grafana directly, but would use a ingress or other front end. However to do that requires setting up a reverse proxy with DNS names and getting security certificates, which can take time. Of course you'd do that in production, but for this lab we want to focus on the core Kubernetes learnign stream, so we're taking the easier approach of just creating a load balancer.
 
```

NAME: grafana
LAST DEPLOYED: Tue Dec 31 11:59:27 2019
NAMESPACE: monitoring
STATUS: deployed
REVISION: 1
NOTES:
1. Get your 'admin' user password by running:

   kubectl get secret --namespace monitoring grafana -o jsonpath="{.data.admin-password}" | base64 --decode ; echo

2. The Grafana server can be accessed via port 80 on the following DNS name from within your cluster:

   grafana.monitoring.svc.cluster.local

   Get the Grafana URL to visit by running these commands in the same shell:

     export POD_NAME=$(kubectl get pods --namespace monitoring -l "app=grafana,release=grafana" -o jsonpath="{.items[0].metadata.name}")
     kubectl --namespace monitoring port-forward $POD_NAME 3000

3. Login with the password from step 1 and the username: admin
```

Like many helm charts the output has some useful hints in it, specifically in this case how to get the admin password and setup port-forwarding using Kubectl.

- Now get the login password. In a window type :
  -  `kubectl get secret --namespace monitoring grafana -o jsonpath="{.data.admin-password}" | base64 --decode ; echo`

```
wzuiF89rmm2g671fdAkeyZ7GxGrpK71rdCD6YxBd
```

- **Copy and paste** the password into a text editor so you can use it later.

We need to open a web page to the Grafana service. To do that we need to get the IP address of the load balancer.

- Run the following command (here we are limiting to just the grafana service)
  - `kubectl get service grafana -n monitoring`

```
NAME      TYPE           CLUSTER-IP      EXTERNAL-IP      PORT(S)        AGE
grafana   LoadBalancer   10.96.161.234   130.61.205.103   80:32261/TCP   4m57s
```
Note the External IP address (130.61.201.103 in this case)

If the external IP address says <pending> then Kubernetes hasn't finished starting the service. wait a short whiel and run the command again.

- Open a web page (replace <external IP> with the one you just got for the grafana service_
  - `http://<external ip>

You'll be presented with the Grafana login window
![grafana-login](images/grafana-login.png)

- Enter **admin** as the user name and then use the Grafana password you copied a few moments ago. 
- Press enter to login and go to the Grafana initial config page

![grafana-initial-setup](images/grafana-initial-setup.png)

Before we can do anything useful with Grafana we need to provide it with some data. 

- Click the **Add Data Source** icon to start this process

![grafana-possible-data-sources](images/grafana-possible-data-sources.png)

- Select **Prometheus**  from the list

![grafana-configure-prometheus-data-source](images/grafana-configure-prometheus-data-source.png)

In the URL field we need to enter the details we got then we installed prometheus. 

- Enter the URL :
  -  `http://prometheus-server.monitoring.svc.cluster.local`

- Leave the other values unchanged
- Click the **Save & Test** button at the bottom of the screen. 

Assuming you entered the details correctly it will report that it's done the save and that the data source is working

![grafana-configure-prometheus-data-source-saved](images/grafana-configure-prometheus-data-source-saved.png)

- Click the grafana logo ![grafana-logo](images/grafana-logo.png) at the top left to return to the Grafana home page

![grafana-home-datasource-done](images/grafana-home-datasource-done.png)

We now need to configure a dashboard that will display data for us.

- Click the **New Dashboard** button to start the process

![grafana-new-dashboard-add-first-panel](images/grafana-new-dashboard-add-first-panel.png)

- In the new Panel click the **Add Query** button to define the data we want to retrieve

![grafana-new-dashboard-first-panel-add-query](images/grafana-new-dashboard-first-panel-add-query.png)

- In the Meter dropdown select `application:list`, then `application:list_all_stock_meter_one_min_rate_per_second`. 

![grafana-new-dashboard-first-panel-add-query-list-stock-meter-rate](images/grafana-new-dashboard-first-panel-add-query-list-stock-meter-rate.png)

You may recall that this it the data set for the number of list stock requests made per second.

Once you've selected it then the display will update with the graph you've selected

![grafana-new-dashboard-first-panel-add-query-list-stock-meter-rate-individual-pods](images/grafana-new-dashboard-first-panel-add-query-list-stock-meter-rate-individual-pods.png)

You may see multiple pods listed in the legend (above one as a green line in the chart, the other as orange.) Do not worry of you can only see one, it depends on the exact flow and timing of the labs which will vary between participants.

Grafana allows us to combine the data using the Prometheus query language, by using the ***SUM*** function in the language to combine all of these.  If you only have one pod do the following anyway, just so see how to use functions)

- Click in the metics box and change it to :
  - `sum(application:list_all_stock_meter_one_min_rate_per_second)` 
  - then press return

![grafana-new-dashboard-first-panel-add-query-list-stock-meter-rate-combined-pods](images/grafana-new-dashboard-first-panel-add-query-list-stock-meter-rate-combined-pods.png)

Now any pod that provides the `application:list_all_stock_meter_one_min_rate_per_second` data will be part of the total, giving us the total rate across all of the pods.

- Make a few requests using curl to generate some new data (replace <ip address> with that of the ingress controller you were using earlier)
  -  `curl -i -k -X GET -u jack:password https://123.456.789.123/store/stocklevel`

```
HTTP/2 200 
server: nginx/1.17.8
date: Fri, 27 Mar 2020 10:06:39 GMT
content-type: application/json
content-length: 220
strict-transport-security: max-age=15724800; includeSubDomains

[{"itemCount":4980,"itemName":"rivet"},{"itemCount":4,"itemName":"chair"},{"itemCount":981,"itemName":"door"},{"itemCount":25,"itemName":"window"},{"itemCount":20,"itemName":"handle"}]
```

After a bit of time for Helidon to update it's metrics, Prometheus to get round to scraping them and for Grafana to get round to retrieving and displaying them we see the updated in the chart.

![grafana-new-dashboard-first-panel-add-query-list-stock-meter-rate-combined-pods-updated-graph](images/grafana-new-dashboard-first-panel-add-query-list-stock-meter-rate-combined-pods-updated-graph.png)

If it hasn't updated after a bit you can force the screen to update, click the refresh icon on the upper right ![grafana-refresh-icon](images/grafana-refresh-icon.png) 

This is only a visuals update, if the scraping hasn't retrieved the updated data then you'll just have to wait for it to happen.

Once we've defined the query then we can look at the way it's displayed. On the left click the Visualization image ![grafana-visualization-icon](images/grafana-visualization-icon.png)

![grafana-new-dashboard-first-panel-visualization-options](images/grafana-new-dashboard-first-panel-visualization-options.png)

You can chose the visualization type you want,  

- Click the Graph icon next to the "Visualization" label ![grafana-visualization-options](images/grafana-visualization-options.png) to see the selection appear in a grid. 

For now we're going to leave this as a Graph, but if you want try clicking on some of the other options to see what they display, not all data makes sense in all visualization types though.

For now (as there is only a single set of numeric data) we are going to leave this as a line graph, but we'll make it a little more interesting.

-  In the Draw options make sure that Bars and Points are turned off and Lines is turned on. 
- In Mode options set Fill to 3, Fill Gradient to 10 and Line Width to 2.

![grafana-new-dashboard-first-panel-visualization-options-updated](images/grafana-new-dashboard-first-panel-visualization-options-updated.png)

- Click on the General icon ![grafana-general-icon](images/grafana-general-icon.png) 
- In the Title field enter a suitable title, for example  `Stock Listing Requests per second`

![grafana-new-dashboard-first-panel-general-options](images/grafana-new-dashboard-first-panel-general-options.png)

- Click the Back arrow at the top left ![grafana-back-icon](images/grafana-back-icon.png) to return to the New Dashboard

Now we see our dashboard with a graph panel

![grafana-new-dashboard-first-panel-completed](images/grafana-new-dashboard-first-panel-completed.png)

Of course this looks pretty basic, It's good to see how many requests we're getting, but let's add an additional panel to give us a history of how fast the service is working. 

- Click on the Add Panel icon on the upper right ![grafana-add-panel-icon](images/grafana-add-panel-icon.png) 

![grafana-dashboard-add-second-panel](images/grafana-dashboard-add-second-panel.png)

- Chose the Add Query option

- In the metics field, enter following :

  - `avg(application:com_oracle_labs_helidon_storefront_resources_storefront_resource_list_all_stock_timer_mean_seconds)` 

    

![grafana-dashboard-add-second-panel-timer-mean-seconds](images/grafana-dashboard-add-second-panel-timer-mean-seconds.png)

- Move to the Visualization tab 
  - Leave **Graph**s the type, 
  - Set the Draw Modes to have both **Bars** and **Lines** enabled

![grafana-dashboard-add-second-panel-visualization](images/grafana-dashboard-add-second-panel-visualization.png)

- Move to the General settings tab 
- Title the panel **Response Times**

![grafana-dashboard-add-second-panel-general](images/grafana-dashboard-add-second-panel-general.png)

- Hit the Grafana back arrow ![grafana-back-icon](images/grafana-back-icon.png) to return to the New Dashboard

![grafana-dashboard-added-second-panel](images/grafana-dashboard-added-second-panel.png)

We're going to add a 3rd panel with a different visualization type, using a dial graph that gives us a view of the most recent data.

- Click the add panel icon  ![grafana-add-panel-icon](images/grafana-add-panel-icon.png)

- Chose **Add Query** as the type

- Enter for **metrics**:
  -  `application:com_oracle_labs_helidon_storefront_resources_storefront_resource_list_all_stock_timer_mean_seconds`

![grafana-dashboard-add-third-panel-timer-seconds](images/grafana-dashboard-add-third-panel-timer-seconds.png)

On the Visualizations page we're going for a different visualization type. 

- Click the Graph option ![grafana-visualization-options-icon](images/grafana-visualization-options-icon.png) to get the list of options

![grafana-visualization-options-choices](images/grafana-visualization-options-choices.png)

- Chose the **Gauge** option, the display will update to show a gauge.

![grafana-visualization-options-guage](images/grafana-visualization-options-gauge.png)

- In the Display section make sure that both Labels and Markers are enabled

![grafana-visualization-options-guage-display](images/grafana-visualization-options-gauge-display.png)

- In the field section set the  title to be `Current Response Time` the Unit to be seconds (under time in the dropdown) and set the Min to be 0 and Max to be 5

![grafana-visualization-options-gauge-field](images/grafana-visualization-options-gauge-field.png)



- In the Threshold screen, click the + button next to the Green bar to get an additional threshold band

![grafana-visualization-options-gauge-thresholds-added](images/grafana-visualization-options-gauge-thresholds-added.png)

- In the text boxes representing the thresholds 
  - Set the Red threshold to be 4 
  - Set the yellow threshold to be 1

![grafana-visualization-options-gauge-thresholds-adjusted](images/grafana-visualization-options-gauge-thresholds-adjusted.png)

The final overall display should look something like this

![grafana-visualization-options-gauge-final](images/grafana-visualization-options-gauge-final.png)

- On the General settings remove the Title text so the panel has no visible title (we're using the label in the gauge itself)

![grafana-dashboard-add-third-panel-general-settings](images/grafana-dashboard-add-third-panel-general-settings.png)

- Click the Grafana back arrow ![grafana-back-icon](images/grafana-back-icon.png) to return to the New Dashboard

![grafana-three-panel-dashboard-colums](images/grafana-three-panel-dashboard-colums.png)

- Re-arrange the panels a bit. 
  - Click on the working of the middle panels title (Response Times) and drag it to the right of the gauge panel.

![grafana-three-panel-dashboard-grid](images/grafana-three-panel-dashboard-grid.png)

Lastly we need to rename out panel, after all "New dashboard" is not especially descriptive. 

- Click on the dashboard settings icon ![grafana-dashboard-settings-icon](images/grafana-dashboard-settings-icon.png) on the upper right of the window

- In the settings page give it a name, let's use `Stock Listing performance` and *disable* the editing option

![grafana-dashboard-settings](images/grafana-dashboard-settings.png)

- Click the Save button then the Back arrow ![grafana-back-icon](images/grafana-back-icon.png) 

- Using the duration dropdown in the upper right ![grafana-duration-dropdown-6-hours](images/grafana-duration-dropdown-6-hours.png) change the duration to be the last 5 mins ![grafana-duration-dropdown-5-mins](images/grafana-duration-dropdown-5-mins.png)

- Now make a bunch of curl requests to get some new data (replacing the IP address with the one for your service of course)
  -  `curl -i -k -X GET -u jack:password https://987.123.456.789/store/stocklevel`

```
HTTP/2 200 
server: nginx/1.17.8
date: Fri, 27 Mar 2020 10:08:15 GMT
content-type: application/json
content-length: 220
strict-transport-security: max-age=15724800; includeSubDomains

[{"itemCount":4980,"itemName":"rivet"},{"itemCount":4,"itemName":"chair"},{"itemCount":981,"itemName":"door"},{"itemCount":25,"itemName":"window"},{"itemCount":20,"itemName":"handle"}]
```

and after it updates it'll look something like 
![grafana-stock-perfprmance-dashboard-with-data](images/grafana-stock-perfprmance-dashboard-with-data.png)

### More complex dashboards
This is a fairly simple dashboard, far more complex ones are easily achievable using a combination or Prometheus and Grafana. As an example we're going to look at a prebuild dashboard.

- Click the Grafana logo ![grafana-logo](images/grafana-logo.png) on the upper left. 
- On the left side menu click the settings "cog", and then Datasources.

![grafana-config-menu](images/grafana-config-menu.png)

To get the list of data sources

![grafana-data-source-list](images/grafana-data-source-list.png)

- Click on the word Prometheus in the data source list to access the prometheus data source config

![grafana-prometheus-data-source-settings](images/grafana-prometheus-data-source-settings.png)

- At the top next to the Settings Tab click on the Dashboards tab

![grafana-prometheus-data-source-dashboards-import-ready](images/grafana-prometheus-data-source-dashboards-import-ready.png)

- Click on the"import" button for each dashboard, 

The dashbaords will be imported (there will be a quick "I'm doing an import" message after each click) after which we can see they are all imported

![grafana-prometheus-data-source-dashboards-import-done](images/grafana-prometheus-data-source-dashboards-import-done.png)

- Click the Grafana logo ![grafana-logo](images/grafana-logo.png) on the upper left. 
- Click the Home menu ![grafana-home-dashboards-menu](images/grafana-home-dashboards-menu.png) to get a list of available dashboards

![grafana-home-available-dashboards](images/grafana-home-available-dashboards.png)



- Click on the Prometheus 2.0 Stats option to see an example dashboard of stats for Prometheus

![grafana-prometheus-stats-dashboard](images/grafana-prometheus-stats-dashboard.png)







---

You have reached the end of this lab !!

Use your **back** button to return to the **C. Deploying to Kubernetes** section