#Monitoring services in Kubernetes

Monitoring a service in Kuberneties involves three components

####Generating the monitoring data.
This is mostly done by the service itself, the metrics capability we created when building the Helidon labs are an example of this.

Core Kubernetes services may also provide the ability to generate data, for example the Kubernetes DNS service can report on how many lookups it's performed.

####Capturing the data
Just because the data is available something needs to extract it from the services, and store it. 

####Processing and Visualizing the data
Once you have the data you need to be able to process it to visualize it and also report any alerts of problems.

#Monitoring and visualization software
We are going to use a very simple monitoring, we will use the metrics in our microservcies and the standard capabilities in the Kubernetes core services to generate data, then use the Prometheus to extract the data and Grafana to display it.

These tools are of course not the only ones, but they are very widely used, and are available as Open Source projects.

#Namespace for the monitoring and visualization software
So separate the monitoring services from the  other services we're going to put them into a new namespace. Type the following to create it.

```$ kubectl create namespace monitoring
namespace/monitoring created
```

#Installing and using Prometheus
This is described in the [Monitoring With Prometheus lab document.](MonitoringWithPrometheusLab.md)

#Installing and using Grafana
As you've seen Prometheus is great at capturing the data, but it's not the worlds best tool for displaying the data.

Fortunately for us there is an open source tool called Grafana which is ***way*** better than Prometheus at this.

The process for installing and using Grafana is detailed in the [Visualusing with Grafana lab document.](VisualizingWithGrafanaLab.md)