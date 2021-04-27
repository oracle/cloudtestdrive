# Further information
While writing these labs I came across many web pages. Ones that I think are especially useful are detailed in the sections below

## Helm
Helm has been used here to install a number of Kubernetes services. See [Helm website](https://helm.sh) for details and if you need to download it there are details in the [Helm web page](https://helm.sh/docs/intro/install/)

If you download Helm version 3 it does not come with a pre-configured chart repository. The master repo used to be at `kubernetes-charts.storage.googleapis.com` however in late 2020 it was deprecated when the help project stopped maintaining it's chart repo, so you may experience access problems, as well as it not containing current charts. Charts are now managed by the individual projects / companies (e.g. `https://kubernetes.github.io/dashboard/` for the dashboard). There are some companies that maintain a collection of helm charts from multiple other sources which may be suitable if you can't find the individual project charts (E.g. The Bitnami helm chart repo at `https://charts.bitnami.com/bitnami`) 

## Ingress
For more information on [Nginx Ingress](https://matthewpalmer.net/kubernetes-app-developer/articles/kubernetes-ingress-guide-nginx-example.html) (this also looks in more detail at the benefits / disadvantages of using an Ingress vs Load Balancer)

If you don't want to use the nginx there is a [list of other controllers.](https://kubernetes.io/docs/concepts/services-networking/ingress-controllers/) Note that different controllers may well use different annotations to the ones we've used in these labs, so for the Ingress rules your version of the yaml files will probably need to be modified.



## Kubernetes
We have been using Kubernetes a lot, here is a link to the [Kubernetes website](https://kubernetes.io)

For more info on the structure of the components in Kubernetes see the Kubernetes documentation ["What is Kubernetes"](https://kubernetes.io/docs/concepts/overview/what-is-kubernetes/) page

To leaven more about how to define liveness and readiness probes (and if you have Kubernetes 1.16 or later also start up probes) see the [probes documentation](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/)

Managing database and kubernetes rollouts can be complex, here is a link to an external web page that discusses the problem. [How to handle DB Scheme changes during Kubernetes rollouts](https://www.weave.works/blog/how-to-correctly-handle-db-schemas-during-kubernetes-rollouts)



## Kubectl
Kubectl is a very powerful tool, but it can be complex to use, fortunately there is a [cheet sheet](https://kubernetes.io/docs/reference/kubectl/cheatsheet)



## Prometheus
More details of Prometheus can be find at the [Prometheus web page.](https://prometheus.io)

If you want to look at using external storage for prometheus [here is an overview.](https://prometheus.io/docs/prometheus/latest/storage/)

The Prometheus query language is very powerful for fill details look at it's [Query Basics page.](https://prometheus.io/docs/prometheus/latest/querying/basics/)


## Metrics to gather
This article at [golden metrics](https://blog.appoptics.com/the-four-golden-signals-for-monitoring-distributed-systems/) has some intereting information on what you should think about monitoring.

## Service mesh
 
For more details on the service mesh concept the site [servicemesh.io](https://servicemesh.io) has lot's of interesting information, it is however run by one of the creators of linkerd so may be biased towards that. 

## End of the lab, What's next ?

You have reached the end of this section of the lab and of the Kubernetes sections.

## Acknowledgements

* **Author** - Tim Graves, Cloud Native Solutions Architect, EMEA OCI Centre of Excellence
* **Last Updated By** - Tim Graves, November 2020
