#Horizontal Scaling labs
In most cases (especially if the services were developed using the principles defined in [The 12 factors](https://12factor.net/)) a microservice is horizontally scalable.

Kubernetes has built in support for easily managing the horizontal scaling of services.

#Manual scaling
In many of the labs when you've looked at the contents of the namespace wou'll have seen things called replica sets, and may have wondered what they are. We can get this info using kubectl. In a terminal window

```
$ $ kubectl get all
NAME                                READY   STATUS    RESTARTS   AGE
pod/stockmanager-6456cfd8b6-4mpl2   1/1     Running   0          118m
pod/storefront-74cd999d8-dzl2n      1/1     Running   0          152m
pod/zipkin-88c48d8b9-vdn47          1/1     Running   0          152m

NAME                   TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)             AGE
service/stockmanager   ClusterIP   10.100.65.58    <none>        8081/TCP,9081/TCP   7h14m
service/storefront     ClusterIP   10.96.237.252   <none>        8080/TCP,9080/TCP   7h14m
service/zipkin         ClusterIP   10.104.81.126   <none>        9411/TCP            7h14m

NAME                           READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/stockmanager   1/1     1            1           118m
deployment.apps/storefront     1/1     1            1           152m
deployment.apps/zipkin         1/1     1            1           152m

NAME                                      DESIRED   CURRENT   READY   AGE
replicaset.apps/stockmanager-6456cfd8b6   1         1         1       118m
replicaset.apps/storefront-74cd999d8      1         1         1       152m
replicaset.apps/zipkin-88c48d8b9          1         1         1       152m
```

You can see that there is a replica set for each deployment. They are actually implicitly defined in the deployment yaml files (replica sets are the definition, but the deployments are the management point, I don't understand why) though they don't have an explicit section the `replicas : 1` line tells the Kubernetes deployment to automatically create a replica set for us with one of the pods (as the pod is described later in the file.) If we hadn't specified the `replicas : 1` line it defaults to a single pod. Kubernetes will create a replica set automatically for us with a single pod for each deployment, and as we've seen in the health, liveness and readiness labs if there is a problem it will automatically restart the services so that there is one service available.

We can if we want modify the number of replicas in the deployment by modifying the YAML and then re-applying it, or of course we could use the kubectl scale command to do it as well, but for this lab we're going to use the dashbaord.

Open the dashboard and switch to your namespace (tg-helidon in my case) In the left menu under the workloads section chose Deployments

![scaling-deployments-list](images/scaling-deployments-list.png)

You can see our three deployments (Zipkin, storefront and stock manager) and in the Pods column we can see that each has 1 or 1 pods. Click on the storefront deployment for more details.

![scaling-deployments-storefront-pre-scale](images/scaling-deployments-storefront-pre-scale.png)

We can see the replica sets that match the deployment, and if we click on the replica set name we can see the details of it

![scaling-replicaset-storefront-pre-scale](images/scaling-replicaset-storefront-pre-scale.png)

Go back to the storefront deployment.

Scaling the deployment is simple, on the deployment page just click on the Scale Icon ![scaling-scale-icon](images/scaling-scale-icon.png) and in the new pop up enter the desired number of pods you want. In this case I've chosen 4

![scaling-deployment-chose-scaling](images/scaling-deployment-chose-scaling.png)

Then click the Ok button on the pop up.

Kuberneties immediately gets to work creating new pods for us

The deployment updates
![scaling-deployment-started-scaling](images/scaling-deployment-started-scaling.png)

And if we drill down into the replica set we can see the pods themselves being created
![scaling-replicaset-started-scaling](images/scaling-replicaset-started-scaling.png)

Remember that the storefront uses a readiness probe, so it may be a while before those pods are reporting ready, (and you may have to reload the page to get the updates) but once they are ready they will show up in the replica set as ready

![scaling-replicaset-post-scaling](images/scaling-replicaset-post-scaling.png)

And if we go back to the deployments list we'll see the pods is now 4 of 4 ready

![scaling-deployments-list-post-scaling](images/scaling-deployments-list-post-scaling.png)

Then looking at the storefront deployment itself we'll see
![scaling-deployment-post-scale](images/scaling-deployment-post-scale.png)

If on the deployments page we scroll down we'll see the list of events for that deployment, our scaling event is there !
![scaling-deployment-events-post-scale](images/scaling-deployment-events-post-scale.png)

If you are on a Kubernetes cluster with multiple physical nodes the scaling operation will try and place the pods on different nodes, protecting the service so if one node fails for any reason the other nodes can still be used to provide the service.

#Horizontal Pod Autoscaling
Strictly speaking this should be called Horizontal Deployment Autoscaling 
This currently relies on a Kubernetes feature called heapster that's been deprecated. but here's the page
[K8S Docs HPA](https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/)
This lab content will be updated later once we've worked this out.