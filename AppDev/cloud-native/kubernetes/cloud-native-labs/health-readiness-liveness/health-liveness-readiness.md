![](../../../../../common/images/customer.logo2.png)

# Cloud Native - Health, Readines and liveness

<details><summary><b>Self guided student - video introduction</b></summary>


This video is an introduction to the Kubernetes health, readiness and liveness lab. Depending on your browser settings it may open in this tab / window or open a new one. Once you've watched it please return to this page to continue the labs.

[![Kubernetes health, readiness and liveness lab Introduction Video](https://img.youtube.com/vi/z1dKR94TQOE/0.jpg)](https://youtu.be/z1dKR94TQOE "Kubernetes health, readiness and liveness lab introduction video")

---

</details>

## Introduction

This is one of the core Kubernetes labs

**Estimated module duration** 15 mins.

### Objectives

This module takes you through the Kubernetes functionality for detecting failed pods, stuck pods and pods that cannot process requests.

### Prerequisites

You need to complete the **Setting up the cluster and getting your services running in Kubernetes** module.

## Task 1: Kubernetes and pod health

Kubernetes provides a service that monitors the pods to see if they meet the requirements in terms of running, being responsive, and being able to process requests. 

A core feature of Kubernetes is the assumption that eventually for some reason or another something will happen that means a service cannot be provided, and the designers of Kubernetes made this a core understanding of how it operates. Kubernetes doesn't just set things up they way you request, but it also continuously monitors the state of the entire deployments so that if the system does not meet what was specified Kubernetes steps in and automatically tries to adjust things so it does!

These labs look at how that is achieved.

## Task 2: Is the container running ?

As we've seen a service in Kubernetes is delivered by programs running in containers. The way a container operates is that it runs a single program, once that program exists then the container exits, and the pod is no longer providing the service. 

If your cloud shell session is new or has been restarted then the shell variable `$EXTERNAL_IP` may be invalid, expand this section if you think this may be the case to check and reset it if needed.

<details><summary><b>How to check if $EXTERNAL_IP is set, and re-set it if it's not</b></summary>

**To check if `$EXTERNAL_IP` is set**

If you want to check if the variable is still set type `echo $EXTRNAL_IP` if it returns the IP address you're ready to go, if not then you'll need to re-set it.

**To get the external IP address if you no longer have it**

In the OCI Cloud shell type

  -  `kubectl --namespace ingress-nginx get services -o wide ingress-nginx-controller`
  
  ```
NAME                       TYPE           CLUSTER-IP    EXTERNAL-IP      PORT(S)                      AGE   SELECTOR
ingress-nginx-controller   LoadBalancer   10.96.61.56   132.145.235.17   80:31387/TCP,443:32404/TCP   45s   app.kubernetes.io/component=controller,app.kubernetes.io/instance=ingress-nginx,app.kubernetes.io/name=ingress-nginx
```

The External IP of the Load Balancer connected to the ingresss controller is shown in the EXTERNAL-IP column.

**To set the variable again**

  - `export EXTERNAL_IP=<External IP>`
  
---

</details>

First let's make sure that the service is running

  1. In the OCI Cloud Shell
  
  - `curl -i -k -X GET -u jack:password https://store.$EXTERNAL_IP.nip.io/store/stocklevel`

  ```
HTTP/1.1 200 OK
Server: openresty/1.15.8.2
Date: Thu, 02 Jan 2020 14:01:18 GMT
Content-Type: application/json
Content-Length: 184
Connection: keep-alive

[{"itemCount":4980,"itemName":"rivet"},{"itemCount":4,"itemName":"chair"},{"itemCount":981,"itemName":"door"},{"itemCount":25,"itemName":"window"},{"itemCount":20,"itemName":"handle"}]
```

  2. Lets look at the pods to check all is running fine:

  -  `kubectl get pods` 

  ```
NAME                            READY   STATUS    RESTARTS   AGE
stockmanager-6456cfd8b6-rl8wg   1/1     Running   0          92m
storefront-65bd698bb4-cq26l     1/1     Running   0          92m
zipkin-88c48d8b9-jkcvq          1/1     Running   0          92m
```

We can see the state of our pods, look at the RESTARTS column, all of the values are 0 (if there was a problem, for example Kubernetes could not download the container images you would see a message in the Status column, and possibly additional re-starts, but here everything is A-OK).

We're going to simulate a crash in our program, this will cause the container to exit, and Kubernetes will identify this and start a replacement container in the pod for us.

  3. Using the name of the storefront pod above let's connect to the container in the pod using kubectl:

  -  `kubectl exec storefront-65bd698bb4-cq26l -ti -- /bin/bash` 

  4. Inside the pod simulate a major fault that causes a service failure by killing the process running our service :

  - `kill -1 1`

  ```
root@storefront-65bd698bb4-cq26l:/# command terminated with exit code 137
```

<details><summary><b>How do you know it's process 1 ?</b></summary>

To be honest this is a bit of inside knowledge, docker images run the command they are given as process 1. The GraalVM image is pretty restricted in the commands it contains and unfortunately does not include the `ps` command, so sadly we can't check this.

---

</details>

Within a second or two of the process being killed the connection to the container in the pod is terminated as the container exits.

If we now try getting the data again it still responds. If you get a 502 or 503 error that just means that the pod is still restarting, wait a few seconds and try again. If you get a `Cannot resolve host` or similar then follow the instructions in the expansion above to check and if needed reset the `$EXTERNAL_IP` variable.

  5. Try getting the data

  - `curl -i -k -X GET -u jack:password https://store.$EXTERNAL_IP.nip.io/store/stocklevel`

  ```
HTTP/2 200 
server: nginx/1.17.8
date: Fri, 27 Mar 2020 10:08:15 GMT
content-type: application/json
content-length: 220
strict-transport-security: max-age=15724800; includeSubDomains

[{"itemCount":4980,"itemName":"rivet"},{"itemCount":4,"itemName":"chair"},{"itemCount":981,"itemName":"door"},{"itemCount":25,"itemName":"window"},{"itemCount":20,"itemName":"handle"}]
```

The reason it took a bit longer than usual when accessing the service is that because it was restarted the code had to do the on-demand setup of the web services. This of course is only done once when the services are first accessed after the container in the pod starts up.

  6. Let's look at the pod details again:
  
  -  `kubectl get pods`

  ```
NAME                            READY   STATUS    RESTARTS   AGE
stockmanager-6456cfd8b6-rl8wg   1/1     Running   0          107m
storefront-65bd698bb4-cq26l     1/1     Running   1          107m
zipkin-88c48d8b9-jkcvq          1/1     Running   0          107m
```

Now we can see that the pod names are still the same, but the storefront pod has had a restart.

Kubernetes has identified that the container exited and within the pod restarted a new container. Another indication of this is if we look at the logs we can see that previous activity is no longer displaying:

  7. Let's look at the logs (use your storefront pod id of course)

  -  `kubectl logs storefront-65bd698bb4-cq26l `

  ```
2020.01.02 14:06:30 INFO com.oracle.labs.helidon.storefront.Main Thread[main,5,main]: Starting server
2020.01.02 14:06:32 INFO org.jboss.weld.Version Thread[main,5,main]: WELD-000900: 3.1.1 (Final)
...
2020.01.02 14:10:02 INFO com.oracle.labs.helidon.storefront.resources.StorefrontResource Thread[hystrix-io.helidon.microprofile.faulttolerance-1,5,server]: Requesting listing of all stock
2020.01.02 14:10:04 INFO com.oracle.labs.helidon.storefront.resources.StorefrontResource Thread[hystrix-io.helidon.microprofile.faulttolerance-1,5,server]: Found 5 items
```


## Task 3: Liveness
We now have mechanisms in place to restart a container if it fails, but it may be that the container does not actually fail, just that the program running in it ceases to behave properly, for example there is some kind of non fatal resource starvation such as a deadlock. In this case the pod cannot recognize the problem as the container is still running.

Fortunately Kubernetes provides a mechanism to handle this as well. This mechanism is called **Liveness probes**, if a pod fails a liveness probe then it will be automatically restarted.

You may recall in the Helidon labs (if you did them) we created a liveness probe, this is an example of Helidon is designed to work in cloud native environments.

  1. Navigate to the **$HOME/helidon-kubernetes** folder

  - `cd $HOME/helidon-kubernetes`
  
  2. Stop the existing deployments

  - `bash undeploy.sh`
  
```
Deleting storefront deployment
deployment.apps "storefront" deleted
Deleting stockmanager deployment
deployment.apps "stockmanager" deleted
Deleting zipkin deployment
deployment.apps "zipkin" deleted
Kubenetes config is
NAME                                READY   STATUS    RESTARTS   AGE
pod/stockmanager-6456cfd8b6-j6vf9   1/1     Running   0          66m
pod/storefront-dcc76cccb-6ztsf      1/1     Running   1          66m
pod/zipkin-88c48d8b9-7rx6q          1/1     Running   0          66m

NAME                   TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)             AGE
service/stockmanager   ClusterIP   10.100.65.58    <none>        8081/TCP,9081/TCP   3h52m
service/storefront     ClusterIP   10.96.237.252   <none>        8080/TCP,9080/TCP   3h52m
service/zipkin         ClusterIP   10.104.81.126   <none>        9411/TCP            3h52m

NAME                                      DESIRED   CURRENT   READY   AGE
replicaset.apps/stockmanager-6456cfd8b6   1         1         1       66m
replicaset.apps/storefront-dcc76cccb      1         1         1       66m
replicaset.apps/zipkin-88c48d8b9          1         1         1       66m

```

  3. Edit the file **storefront-deployment.yaml** using your prefered editor
  
  4. Search for the Liveness probes section. This is under the spec.template.spec.containers section

  ```
        resources:
          limits:
            # Set this to me a whole CPU for now
            cpu: "1000m"
#        # Use this to check if the pod is alive
#        livenessProbe:
#          #Simple check to see if the liveness call works
#          # If must return a 200 - 399 http status code
#          httpGet:
#             path: /health/live
#             port: health-port
#          # Give it a few seconds to make sure it's had a chance to start up
#          initialDelaySeconds: 120
#          # Let it have a 5 second timeout to wait for a response
#          timeoutSeconds: 5
#          # Check every 5 seconds (default is 1)
#          periodSeconds: 5
#          # Need to have 3 failures before we decide the pod is dead, not just slow
#          failureThreshold: 3
        # This checks if the pod is ready to process requests
#        readinessProbe:
```

As you can see this section has been commented out. 

  5. On each line remove the # (only the first one, and only the # character, be sure not to remove any whitespace). 

  6. Save the file

The resulting section should look like this:

  ```
        resources:
          limits:
            # Set this to me a whole CPU for now
            cpu: "1000m"
        # Use this to check if the pod is alive
        livenessProbe:
          #Simple check to see if the liveness call works
          # If must return a 200 - 399 http status code
          httpGet:
             path: /health/live
             port: health-port
          # Give it a few seconds to make sure it's had a chance to start up
          initialDelaySeconds: 120
          # Let it have a 5 second timeout to wait for a response
          timeoutSeconds: 5
          # Check every 5 seconds (default is 1)
          periodSeconds: 5
          # Need to have 3 failures before we decide the pod is dead, not just slow
          failureThreshold: 3
        # This checks if the pod is ready to process requests
#        readinessProbe:
```

This is a pretty simple test to see if there is a running service, in this case we use the service to make an http get request (this is made by the framework and is done from outside the pod) on the 9080:/health/live url (we know it's on port 9080 as the port definition names it health-port). There are other types of liveness probe than just get requests, you can run a command in the container itself, or just see if it's possible to open a tcp/ip connection to a port in the container. Of course this is a simple definition, it doesn't look at the many options that are available.

The first thing to say is that whatever steps your actual liveness test does it needs to be sufficient to detect service problems like deadlocks, but also to use as few resources as possible so the check itself doesn't become a major load factor.

Let's look at some of these values.

As it may take a while to start up the container, we specify and initialDelaySeconds of 120, Kubernetes won't start checking if the pod is live until that period is elapsed. If we made that to short then we may never start the container as Kubernetes would always determine it was not alive before the container had a chance to start up properly. 

The parameter **timeoutSeconds** specifies that for the http request to be considered failed it would not have responded in 5 seconds. As many http service implementations are initialized on first access we need to chose a value that is long enough for the framework to do it's lazy initialization.

The parameter **periodSeconds** defines how often Kubernetes will check the container to see if it's alive and responding. This is a balance, especially if the liveness check involved significant resources (e.g. making a RDBMS call) You need to check often enough that a non responding container will be detected quickly, but not check so often that the checking process itself uses to many resources.

Finally **failureThreshold** specifies how many consecutive failures are needed before it's deemed to have failed, in this case we need 3 failures to respond

Whatever your actual implementation you need to carefully consider the values above. Get them wrong and your service may never be allowed to start, or problems may not be detected.

Let's apply the changes we made in the deployment :

  7. Deploy the updated version
  
  -  `bash deploy.sh`

  ```
Creating zipkin deployment
deployment.apps/zipkin created
Creating stockmanager deployment
deployment.apps/stockmanager created
Creating storefront deployment
deployment.apps/storefront created
Kubenetes config is
NAME                                READY   STATUS              RESTARTS   AGE
pod/stockmanager-6456cfd8b6-29lmk   0/1     ContainerCreating   0          0s
pod/storefront-b44457b4d-29jr7      0/1     Pending             0          0s
pod/zipkin-88c48d8b9-bftvx          0/1     ContainerCreating   0          0s

NAME                   TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)             AGE
service/stockmanager   ClusterIP   10.100.65.58    <none>        8081/TCP,9081/TCP   3h55m
service/storefront     ClusterIP   10.96.237.252   <none>        8080/TCP,9080/TCP   3h55m
service/zipkin         ClusterIP   10.104.81.126   <none>        9411/TCP            3h55m

NAME                           READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/stockmanager   0/1     1            0           0s
deployment.apps/storefront     0/1     1            0           0s
deployment.apps/zipkin         0/1     1            0           0s

NAME                                      DESIRED   CURRENT   READY   AGE
replicaset.apps/stockmanager-6456cfd8b6   1         1         0       0s
replicaset.apps/storefront-b44457b4d      1         1         0       0s
replicaset.apps/zipkin-88c48d8b9          1         1         0       0s

```

  8. Let's see how our pod is doing.
  
  -  `kubectl get pods`

  ```
NAME                            READY   STATUS    RESTARTS   AGE
stockmanager-6456cfd8b6-29lmk   1/1     Running   0          24s
storefront-b44457b4d-29jr7      1/1     Running   0          24s
zipkin-88c48d8b9-bftvx          1/1     Running   0          24s
```

Note that as we have undeployed and then deployed again these are new pods and so the RESTART count is back to zero.

If we look at the logs for the storefront **before** the liveness probe has started (so before the 120 seconds from container creation) we see that it starts as we expect it to. 

  9. Let's look at the logs 
  
  -  `kubectl logs storefront-b44457b4d-29jr7`

  ```
2020.01.02 16:18:58 INFO com.oracle.labs.helidon.storefront.Main Thread[main,5,main]: Starting server
...
2020.01.02 16:19:07 INFO com.oracle.labs.helidon.storefront.Main Thread[main,5,main]: Running on http://localhost:8080/store
```

If however the 120 seconds has passed and the liveness call has started we will see calls being made to the status resource,

  10. Run the kubectl command again
  
  - `kubectl logs storefront-b44457b4d-29jr7 `

You will see multiple entries like the one below:

  ```
2020.01.02 16:21:11 INFO com.oracle.labs.helidon.storefront.health.LivenessChecker Thread[nioEventLoopGroup-3-1,10,main]: Not frozen, Returning alive status true, storename My Shop
```

  11. Look at the pods detailed info to check the state is fine :
  
  -  `kubectl describe pod storefront-b44457b4d-29jr7 `

  ```
...
Events:
  Type    Reason     Age    From                     Message
  ----    ------     ----   ----                     -------
  Normal  Scheduled  4m30s  default-scheduler        Successfully assigned tg-helidon/storefront-b44457b4d-29jr7 to docker-desktop
  Normal  Pulling    4m29s  kubelet, docker-desktop  Pulling image "fra.ocir.io/oractdemeabdmnative/tg_repo/storefront:0.0.1"
  Normal  Pulled     4m28s  kubelet, docker-desktop  Successfully pulled image "fra.ocir.io/oractdemeabdmnative/tg_repo/storefront:0.0.1"
  Normal  Created    4m28s  kubelet, docker-desktop  Created container storefront
  Normal  Started    4m28s  kubelet, docker-desktop  Started container storefront
```

It's started and no unexpected events!

Now is the time to explain that `Not frozen ...` text in the status. To enable us to actually simulate the service having a deadlock or resource starvation problem there's a bit of a cheat in the storefront LivenessChecker code :

```
	@Override
	public HealthCheckResponse call() {
		// don't test anything here, we're just reporting that we are running, not that
		// any of the underlying connections to thinks like the database are active

		// if there is a file /frozen then just lock up for 60 seconds
		// this let's us emulate a lockup which will trigger a pod restart
		// if we have enabled liveliness testing against this API
		if (new File("/frozen").exists()) {
			log.info("/frozen exists, locking for " + FROZEN_TIME + " seconds");
			try {
				Thread.sleep(FROZEN_TIME * 1000);
			} catch (InterruptedException e) {
				// ignore for now
			}
			return HealthCheckResponse.named("storefront-live").up()
					.withData("uptime", System.currentTimeMillis() - startTime).withData("storename", storeName)
					.withData("frozen", true).build();
		} else {
			log.info("Not frozen, Returning alive status true, storename " + storeName);
			return HealthCheckResponse.named("storefront-live").up()
					.withData("uptime", System.currentTimeMillis() - startTime).withData("storename", storeName)
					.withData("frozen", false).build();
		}
```

Every time it's called it checks to see it a file names /frozen exists in the root directory of the container. If it does then it will do a delay (about 60 seconds) before returning the response. Basically this means that by connecting to the container and creating the /frozen file we can simulate the container having a problem. The `Not Frozen...` is just text in the log data so we can see what's happening. Of course you wouldn't do this in a production system!

Let's see what happens in this case.

  12. First let's start following the logs of your pod. Run the following command (replace the pod Id with yours)
  
  -  `kubectl logs -f --tail=10 storefront-b44457b4d-29jr7 `

  ```
...
2020.01.02 16:24:36 INFO com.oracle.labs.helidon.storefront.health.LivenessChecker Thread[nioEventLoopGroup-3-1,10,main]: Not frozen, Returning alive status true, storename My Shop
2020.01.02 16:24:41 INFO com.oracle.labs.helidon.storefront.health.LivenessChecker Thread[nioEventLoopGroup-3-1,10,main]: Not frozen, Returning alive status true, storename My Shop
```

  13. Open new browser window or tab
  
  14. Go to your cloud account
  
  15. Once in the cloud account open an OCI Cloud Shell in the new window

  16. Log in to the your container and create the `/frozen` file  (replace the pod Id with yours)
  
  -  `kubectl exec -ti storefront-b44457b4d-29jr7 -- /bin/bash`
  
  -  `touch /frozen`
  
  17. Go back to the window running the logs

Kubernetes detected that the liveness probes were not responding in time, and after 3 failures it restarted the pod.

In the logs we see the following 

```
2020.01.02 16:25:41 INFO com.oracle.labs.helidon.storefront.health.LivenessChecker Thread[nioEventLoopGroup-3-1,10,main]: Not frozen, Returning alive status true, storename My Shop
2020.01.02 16:25:46 INFO com.oracle.labs.helidon.storefront.health.LivenessChecker Thread[nioEventLoopGroup-3-1,10,main]: Not frozen, Returning alive status true, storename My Shop
2020.01.02 16:25:51 INFO com.oracle.labs.helidon.storefront.health.LivenessChecker Thread[nioEventLoopGroup-3-1,10,main]: Not frozen, Returning alive status true, storename My Shop
2020.01.02 16:25:56 INFO com.oracle.labs.helidon.storefront.health.LivenessChecker Thread[nioEventLoopGroup-3-1,10,main]: /frozen exists, locking for 60 seconds
Weld SE container 53fe34a2-0291-4b72-a00e-966bab7ab2ad shut down by shutdown hook
```

Kubectl tells us there's been a problem and a pod has done a restart for us (the kubectl connection to the pod will have terminated when the pod restarted)

  18. Check the pod status
  
  - `kubectl get pods`

  ```
NAME                            READY   STATUS    RESTARTS   AGE
stockmanager-6456cfd8b6-29lmk   1/1     Running   0          7m50s
storefront-b44457b4d-29jr7      1/1     Running   1          7m50s
zipkin-88c48d8b9-bftvx          1/1     Running   0          7m50s
```

  19. Look at the deployment events for the pod
  
  -  `kubectl describe pod storefront-b44457b4d-29jr7`

  ```
...
Events:
  Type     Reason     Age                  From                     Message
  ----     ------     ----                 ----                     -------
  Normal   Scheduled  8m13s                default-scheduler        Successfully assigned tg-helidon/storefront-b44457b4d-29jr7 to docker-desktop
  Warning  Unhealthy  57s (x3 over 67s)    kubelet, docker-desktop  Liveness probe failed: Get http://10.1.0.170:9080/health/live: net/http: request canceled (Client.Timeout exceeded while awaiting headers)
  Normal   Killing    57s                  kubelet, docker-desktop  Container storefront failed liveness probe, will be restarted
  Normal   Pulling    56s (x2 over 8m12s)  kubelet, docker-desktop  Pulling image "fra.ocir.io/oractdemeabdmnative/tg_repo/storefront:0.0.1"
  Normal   Pulled     56s (x2 over 8m11s)  kubelet, docker-desktop  Successfully pulled image "fra.ocir.io/oractdemeabdmnative/tg_repo/storefront:0.0.1"
  Normal   Created    56s (x2 over 8m11s)  kubelet, docker-desktop  Created container storefront
  Normal   Started    55s (x2 over 8m11s)  kubelet, docker-desktop  Started container storefront
```

The pod became unhealthy, then the container was killed and a fresh new container restarted.

 (Leave the extra window open as you'll be using it again later)
 
## Task 4: Readiness
The first two probes determine if a pod is alive and running, but it doesn't actually report if it's able to process events. That can be a problem if for example a pod has a problem connecting to a backend service, perhaps there is a network configuration issue and the pods path to a back end service like a database is not available.

In this situation restarting the pod / container won't do anything useful, it's not a problem with the container itself, but something outside the container, and hopefully once that problem is resolved the front end service will recover (it's it's been properly coded and doesn't crash, but in that case one of the other health mechanisms will kick in and restart it) **BUT** there is also no point in sending requests to that container as it can't process them.

Kubernetes supports a readiness probe that we can call to see is the container is ready. If the container is not ready then it's removed from the set of available containers that can provide the service, and any requests are routed to other containers that can provide the service. 

Unlike a liveness probe, if a container fails it's not killed off, and calls to the readiness probe continue to be made, if the probe starts reporting the service in the container is ready then it's added back to the list of containers that can deliver the servcie and requests will be routed to it once more.

  1. Make sure you are in the folder **$HOME/helidon-kubernetes**

  2. Edit the file **storefront-deployment.yaml**

  3. Look for the section (just after the Liveness probe) where we define the **readiness probe**. 

  ```
#        readinessProbe:
#          exec:
#            command:
#            - /bin/bash
#            - -c
#            - 'curl -s http://localhost:9080/health/ready | grep "\"outcome\":\"UP\""'
#          # No point in checking until it's been running for a while 
#          initialDelaySeconds: 15
#          # Allow a short delay for the response
#          timeoutSeconds: 5
#          # Check every 10 seconds
#          periodSeconds: 10
#          # Need at least only one fail for this to be a problem
#          failureThreshold: 1
```
  4.Remove the # (and only the #, not spaces or anything else) for the **readiness section only** and save the file. 

The ReadinessProbe section should now look like this :

  ```
       # This checks if the pod is ready to process requests
        readinessProbe:
          exec:
            command:
            - /bin/bash
            - -c
            - 'curl -s http://localhost:9080/health/ready | grep "\"outcome\":\"UP\""'
          # No point in checking until it's been running for a while 
          initialDelaySeconds: 15
          # Allow a short delay for the response
          timeoutSeconds: 5
          # Check every 10 seconds
          periodSeconds: 10
          # Need at least only one fail for this to be a problem
          failureThreshold: 1
```

The various options for readiness are similar to those for Liveliness, except you see here we've got an exec instead of httpGet.

The exec means that we are going to run code **inside** the pod to determine if the pod is ready to serve requests. The command section defines the command that will be run and the arguments. In this case we run the /bin/bash shell, -c means to use the arguments as a command (so it won't try and be interactive) and  **'curl -s http://localhost:9080/health/ready | grep "\"outcome\":\"UP\""'** is the command.

Some points about **'curl -s http://localhost:9080/health/ready | grep "\"outcome\":\"UP\""'**

Firstly this is a command string that actually runs several commands connecting the output of one to the input of the other. If you exec to the pod you can actually run these by hand if you like

The first (the curl) gets the readiness data from the service (you may remember this in the Helidon labs) In this case as the code is running within the pod itself, so it's a localhost connection and as it'd direct to the micro-service it's http

```
root@storefront-b44457b4d-29jr7:/# curl -s http://localhost:9080/health/ready 
{"outcome":"UP","status":"UP","checks":[{"name":"storefront-ready","state":"UP","status":"UP","data":{"storename":"My Shop"}}]}
```

We can just use the final command the grep to look for a line containing `"outcome":"UP"` We do however have to be careful because " is actually part of what we want to look for (and if you ran the text thoguht a json formatter you may have space characters) So to define these as a constant we need to ensure it's a single string, we do this by enclosing the entire thing in quotes `"` and to prevent the `"` within the string being interpreted as end of string (and thus new argument) characters we need to escape them, hence we end up with `"\"outcome\":\"UP\""`

Now try it out:

  5. Connect to the pod 
  
  - `kubectl exec -ti storefront-b44457b4d-29jr7  -- /bin/bash`
  
  6. Run the command in the pod:
  
  -  `curl -s http://localhost:9080/health/ready | grep "\"outcome\":\"UP\""`

  ```
{"outcome":"UP","status":"UP","checks":[{"name":"storefront-ready","state":"UP","status":"UP","data":{"storename":"My Shop"}}]}
```

In this case the pod is ready, so the grep command returns what it's found. We are not actually concerned with what the pod returns in terms of string output, we are looking for the exit code, interactively we can find that by looking in the $? variable:

  7. Inside the pod look at the output of the previous command
  
  -  `echo $?`

  ```
0
```

And can see that the variable value (which is what's returned back to the Kubernetes readiness infrastructure) is 0. In Unix / Linux terms this means success.

If you want to see what it would do if the outcome was not UP try running the command changing the UP to DOWN like this (or actually anything other than UP). **Important** While you can run this command in the pods shell **DO NOT** modify the actual yaml files.

```
root@storefront-b44457b4d-29jr7:/# curl -s http://localhost:9080/health/ready | grep "\"outcome\":\"DOWN\""
root@storefront-b44457b4d-29jr7:/# echo $?
1
```

In this case the return value in $? is 1, not 0, and in Unix / Linux terms that means something's gone wrong.

The whole thing is held in single quotes `'curl -s http://localhost:9080/health/ready | grep "\"outcome\":\"UP\""'` to that it's treated as a single string by the yaml file parser and when being handed to the bash shell.

Remember, in this case the command is executed inside the container, so you have to make sure that the commands you want to run will be available. This is especially important if you change the base image, you might find you are relying on a command that's no longer there, or works in a different way from your expectations.

That's all we're going to do with bash shell programming for now!

Having made the changes let's undeploy the existing configuration and then deploy the new one

In the OCI Cloud Shell

  8. Navigate to the **$HOME/helidon-kubernetes** folder
  
  9. Let's stop the services running, run the undeploy.sh script
  
  -  `bash undeploy.sh `

 ```
Deleting storefront deployment
deployment.apps "storefront" deleted
Deleting stockmanager deployment
deployment.apps "stockmanager" deleted
Deleting zipkin deployment
deployment.apps "zipkin" deleted
Kubenetes config is
NAME                                READY   STATUS    RESTARTS   AGE
pod/stockmanager-6456cfd8b6-29lmk   1/1     Running   0          46m
pod/storefront-b44457b4d-29jr7      1/1     Running   1          46m
pod/zipkin-88c48d8b9-bftvx          1/1     Running   0          46m

NAME                   TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)             AGE
service/stockmanager   ClusterIP   10.100.65.58    <none>        8081/TCP,9081/TCP   4h41m
service/storefront     ClusterIP   10.96.237.252   <none>        8080/TCP,9080/TCP   4h41m
service/zipkin         ClusterIP   10.104.81.126   <none>        9411/TCP            4h41m

NAME                                      DESIRED   CURRENT   READY   AGE
replicaset.apps/stockmanager-6456cfd8b6   1         1         1       46m
replicaset.apps/storefront-b44457b4d      1         1         1       46m
replicaset.apps/zipkin-88c48d8b9          1         1         1       46m
```

As usual it takes a few seconds for the deployments to stop, this was about 30 seonds later

  10. Check only the services remain running : 
  
  -  `kubectl get all`

  ```
NAME                   TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)             AGE
service/stockmanager   ClusterIP   10.100.65.58    <none>        8081/TCP,9081/TCP   4h42m
service/storefront     ClusterIP   10.96.237.252   <none>        8080/TCP,9080/TCP   4h42m
service/zipkin         ClusterIP   10.104.81.126   <none>        9411/TCP            4h42m
```

Now let's deploy them again, run the deploy.sh script, be prepared to run kubectl get all within a few seconds of the deploy finishing.

  11. Run the deploy script 
  
  -  `bash deploy.sh`

  ```
Creating zipkin deployment
deployment.apps/zipkin created
Creating stockmanager deployment
deployment.apps/stockmanager created
Creating storefront deployment
deployment.apps/storefront created
Kubenetes config is
NAME                                READY   STATUS              RESTARTS   AGE
pod/stockmanager-6456cfd8b6-vqq7c   0/1     ContainerCreating   0          0s
pod/storefront-74cd999d8-dzl2n      0/1     Pending             0          0s
pod/zipkin-88c48d8b9-vdn47          0/1     ContainerCreating   0          0s

NAME                   TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)             AGE
service/stockmanager   ClusterIP   10.100.65.58    <none>        8081/TCP,9081/TCP   4h42m
service/storefront     ClusterIP   10.96.237.252   <none>        8080/TCP,9080/TCP   4h42m
service/zipkin         ClusterIP   10.104.81.126   <none>        9411/TCP            4h42m

NAME                           READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/stockmanager   0/1     1            0           0s
deployment.apps/storefront     0/1     1            0           0s
deployment.apps/zipkin         0/1     1            0           0s

NAME                                      DESIRED   CURRENT   READY   AGE
replicaset.apps/stockmanager-6456cfd8b6   1         1         0       0s
replicaset.apps/storefront-74cd999d8      1         1         0       0s
replicaset.apps/zipkin-88c48d8b9          1         1         0       0s
```

  12. **Immediately** run the command in the OCI cloud shell
  
  - `kubectl get all`

  ```
NAME                                READY   STATUS    RESTARTS   AGE
pod/stockmanager-6456cfd8b6-vqq7c   1/1     Running   0          12s
pod/storefront-74cd999d8-dzl2n      0/1     Running   0          12s
pod/zipkin-88c48d8b9-vdn47          1/1     Running   0          12s

NAME                   TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)             AGE
service/stockmanager   ClusterIP   10.100.65.58    <none>        8081/TCP,9081/TCP   4h43m
service/storefront     ClusterIP   10.96.237.252   <none>        8080/TCP,9080/TCP   4h43m
service/zipkin         ClusterIP   10.104.81.126   <none>        9411/TCP            4h43m

NAME                           READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/stockmanager   1/1     1            1           12s
deployment.apps/storefront     0/1     1            0           12s
deployment.apps/zipkin         1/1     1            1           12s

NAME                                      DESIRED   CURRENT   READY   AGE
replicaset.apps/stockmanager-6456cfd8b6   1         1         1       12s
replicaset.apps/storefront-74cd999d8      1         1         0       12s
replicaset.apps/zipkin-88c48d8b9          1         1         1       12s
```

We see something different, usually within a few seconds of starting a pod it's in the Running state (as are these) **BUT** if we look at the pods we see that though it's running the storefront is not actually ready, the replica set doesn't have any storefront ready (even though we've asked for pod 1) and neither does the deployment. 

If after a minute or so we re-do the kubectl command it's as we expected.

```
$ kubectl get all
NAME                                READY   STATUS    RESTARTS   AGE
pod/stockmanager-6456cfd8b6-vqq7c   1/1     Running   0          95s
pod/storefront-74cd999d8-dzl2n      1/1     Running   0          95s
pod/zipkin-88c48d8b9-vdn47          1/1     Running   0          95s

NAME                   TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)             AGE
service/stockmanager   ClusterIP   10.100.65.58    <none>        8081/TCP,9081/TCP   4h44m
service/storefront     ClusterIP   10.96.237.252   <none>        8080/TCP,9080/TCP   4h44m
service/zipkin         ClusterIP   10.104.81.126   <none>        9411/TCP            4h44m

NAME                           READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/stockmanager   1/1     1            1           95s
deployment.apps/storefront     1/1     1            1           95s
deployment.apps/zipkin         1/1     1            1           95s

NAME                                      DESIRED   CURRENT   READY   AGE
replicaset.apps/stockmanager-6456cfd8b6   1         1         1       95s
replicaset.apps/storefront-74cd999d8      1         1         1       95s
replicaset.apps/zipkin-88c48d8b9          1         1         1       95s
```

Now everything is ready, but why the delay ? What's caused it ? And why didn't it happen before ?

Well the answer is simple. If there is a readiness probe enabled a pod is not considered ready *until* the readiness probe reports success. Prior to that the pod is not in the set of pods that can deliver a service.

As to why it didn't happen before, if a pod does not have a readiness probe specified then it is automatically assumed to be in a ready state as soon as it's running

What happens if a request is made to the service while before the pod is ready ? Well if there are other pods in the service (the selector for the service matches the labels and the pods are ready to respond) then the service requests are sent to those pods. If there are **no** pods ab.e to service the requests than a 503 "Service Temporarily Unavailable" is generated back to the caller

To see what happens if the readiness probe does not work we can simply undeploy the stock manager service.

  13. First let's check it's running fine - be prepared for a short delay as we'd just restarted everything
  
  - `curl -i -k -X GET -u jack:password https://store.$EXTERNAL_IP.nip.io/store/stocklevel`

  ```
HTTP/1.1 200 OK
Server: openresty/1.15.8.2
Date: Thu, 02 Jan 2020 17:30:32 GMT
Content-Type: application/json
Content-Length: 184
Connection: keep-alive

[{"itemCount":4980,"itemName":"rivet"},{"itemCount":4,"itemName":"chair"},{"itemCount":981,"itemName":"door"},{"itemCount":25,"itemName":"window"},{"itemCount":20,"itemName":"handle"}]
```

  14. Now let's use kubectl to undeploy just the stockmanager service
  
  -  `kubectl delete -f stockmanager-deployment.yaml`

  ```
deployment.apps "stockmanager" deleted
```
  15. Let's check the pods status
  
  -  `kubectl get pods`

  ```
NAME                            READY   STATUS        RESTARTS   AGE
stockmanager-6456cfd8b6-vqq7c   0/1     Terminating   0          26m
storefront-74cd999d8-dzl2n      1/1     Running       0          26m
zipkin-88c48d8b9-vdn47          1/1     Running       0          26m
```
The stock manager service is being stopped (this is quite a fast process, so it may have completed before you ran the command). After 60 seconds or so if we run kubectl to get everything we see it's gone (note this is `all`, not `pods` here)

  16. Make sure that the stockmanager **pod** and **deployment** are terminated
  
  -  `kubectl get all`

  ```
NAME                             READY   STATUS    RESTARTS   AGE
pod/storefront-74cd999d8-dzl2n   0/1     Running   0          28m
pod/zipkin-88c48d8b9-vdn47       1/1     Running   0          28m

NAME                   TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)             AGE
service/stockmanager   ClusterIP   10.100.65.58    <none>        8081/TCP,9081/TCP   5h11m
service/storefront     ClusterIP   10.96.237.252   <none>        8080/TCP,9080/TCP   5h11m
service/zipkin         ClusterIP   10.104.81.126   <none>        9411/TCP            5h11m

NAME                         READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/storefront   0/1     1            0           28m
deployment.apps/zipkin       1/1     1            1           28m

NAME                                   DESIRED   CURRENT   READY   AGE
replicaset.apps/storefront-74cd999d8   1         1         0       28m
replicaset.apps/zipkin-88c48d8b9       1         1         1       28m

```

Something else has also happened though, the storefront service has no pods in the ready state, neither does the storefront deployment and replica set. The readiness probe has run against the storefront pod and when the probe checked the results it found that the storefront pod was not in a position to operate, because the service it depended on (the stock manager) was no longer available. 

  17. Let's try accessing the service
  
  -  `curl -i -k -X GET -u jack:password https://store.$EXTERNAL_IP.nip.io/store/stocklevel`

  ```
HTTP/1.1 503 Service Temporarily Unavailable
Server: openresty/1.15.8.2
Date: Thu, 02 Jan 2020 17:37:29 GMT
Content-Type: text/html
Content-Length: 203
Connection: keep-alive

<html>
<head><title>503 Service Temporarily Unavailable</title></head>
<body>
<center><h1>503 Service Temporarily Unavailable</h1></center>
<hr><center>openresty/1.15.8.2</center>
</body>
</html>
```
The service is giving us a 503 Service Temporarily Unavailable message. Well to be precise this is coming from the Kubernetes as it can't find a storefront service that is in the ready state.

  18. Let's start the stockmager service using kubectl again
  
  -  `kubectl apply -f stockmanager-deployment.yaml`

  ```
deployment.apps/stockmanager created
```

Now let's see what's happening with our deployments 

  19. **Immediately** let's look at the situation
  
  -  `kubectl get all`

  ```
NAME                                READY   STATUS    RESTARTS   AGE
pod/stockmanager-6456cfd8b6-4mpl2   1/1     Running   0          7s
pod/storefront-74cd999d8-dzl2n      0/1     Running   0          33m
pod/zipkin-88c48d8b9-vdn47          1/1     Running   0          33m

NAME                   TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)             AGE
service/stockmanager   ClusterIP   10.100.65.58    <none>        8081/TCP,9081/TCP   5h16m
service/storefront     ClusterIP   10.96.237.252   <none>        8080/TCP,9080/TCP   5h16m
service/zipkin         ClusterIP   10.104.81.126   <none>        9411/TCP            5h16m

NAME                           READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/stockmanager   1/1     1            1           7s
deployment.apps/storefront     0/1     1            0           33m
deployment.apps/zipkin         1/1     1            1           33m

NAME                                      DESIRED   CURRENT   READY   AGE
replicaset.apps/stockmanager-6456cfd8b6   1         1         1       7s
replicaset.apps/storefront-74cd999d8      1         1         0       33m
replicaset.apps/zipkin-88c48d8b9          1         1         1       33m
```

The stockmanager is running, but the storefront is still not ready, and it won't be until the readiness check is called again and determines that it's ready to work.

  20. Looking at the kubectl output about 120 seconds later:
  
  -  `kubectl get all`

```
NAME                                READY   STATUS    RESTARTS   AGE
pod/stockmanager-6456cfd8b6-4mpl2   1/1     Running   0          96s
pod/storefront-74cd999d8-dzl2n      1/1     Running   0          35m
pod/zipkin-88c48d8b9-vdn47          1/1     Running   0          35m

NAME                   TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)             AGE
service/stockmanager   ClusterIP   10.100.65.58    <none>        8081/TCP,9081/TCP   5h18m
service/storefront     ClusterIP   10.96.237.252   <none>        8080/TCP,9080/TCP   5h18m
service/zipkin         ClusterIP   10.104.81.126   <none>        9411/TCP            5h18m

NAME                           READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/stockmanager   1/1     1            1           96s
deployment.apps/storefront     1/1     1            1           35m
deployment.apps/zipkin         1/1     1            1           35m

NAME                                      DESIRED   CURRENT   READY   AGE
replicaset.apps/stockmanager-6456cfd8b6   1         1         1       96s
replicaset.apps/storefront-74cd999d8      1         1         1       35m
replicaset.apps/zipkin-88c48d8b9          1         1         1       35m
```

The storefront readiness probe has kicked in and the services are all back in the ready state once again  (replace <external IP> with the one for your service)

  21. Check the service is responding properly now
  
  - `curl -i -k -X GET -u jack:password https://store.$EXTERNAL_IP.nip.io/store/stocklevel`

  ```
HTTP/1.1 200 OK
Server: openresty/1.15.8.2
Date: Thu, 02 Jan 2020 17:42:40 GMT
Content-Type: application/json
Content-Length: 184
Connection: keep-alive

[{"itemCount":4980,"itemName":"rivet"},{"itemCount":4,"itemName":"chair"},{"itemCount":981,"itemName":"door"},{"itemCount":25,"itemName":"window"},{"itemCount":20,"itemName":"handle"}]
```

## Task 5: Startup probes

You may have noticed above that we had to wait for the liveness probe to complete it's initial delay it started checking. As the liveness probe checks for the service running this means we can't start checking until liveness probe has started. But equally we don't want to set the initial delay of the liveness probe to be to low as it might start checking before the service is running, and then kill the service off before it's finished it's setup. In the case of the storefront this is not to much of a problem as the service starts up fast, but for a more complex service, especially a legacy service that may have a startup time that varies a lot depending on other factors, this could be a problem.

To solve this in Kubernetes 1.18 the concept of startup probes will be introduced as a beta feature. A startup probe is a very simple probe that tests to see if the service has started running, usually at a basic level, and then starts up the liveness probes. Effectively the startupProbe means there is no longer any need for the initialDelaySeconds on the liveness probe.

Let's enable this.

  1. Edit the `storefront-deployment.yaml` file
  
  2. Locate the `startupProbe:` section
  
  3. Remove the `#` at the beginning of each line, only remove that character, be careful not to remove anything else
  
The result should look like this

  ```
        # Use this to check if the pod is started this has to pass before the liveness kicks in
        # note that this was released as beta in k8s V 1.18
        startupProbe:
          #Simple check to see if the status call works
          # If must return a 200 - 399 http status code
           httpGet:
              path: /status
              port: service-port
          # No initial delay - it starts checking immediately
          # Let it have a 5 second timeout
           timeoutSeconds: 5
          # allow for up to 48 failures
           failureThreshold: 48
          # Check every 5 seconds
           periodSeconds: 5
          # If after failureThreshold * periodSeconds it's not up and running then it's determined to have failed (4 mins in this case)
```
  
  4. Locate the  `initialDelaySeconds:` in the `livenessprobe` section
  
  5. Place a `#` just before the content
  
The result should look like this 

  ```
        livenessProbe:
          #Simple check to see if the liveness call works
          # If must return a 200 - 399 http status code
          httpGet:
             path: /health/live
             port: health-port
          # Give it a few seconds to make sure it's had a chance to start up
          #initialDelaySeconds: 120
          # Let it have a 5 second timeout to wait for a response
          timeoutSeconds: 5
          # Check every 5 seconds (default is 1)
          periodSeconds: 5
          # Need to have 3 failures before we decide the pod is dead, not just slow
          failureThreshold: 3
```

  6. Restart the storefront
  
  - `kubectl apply -f storefront-deployment.yaml`
  ```
deployment.apps/storefront configured
```

There isn't anything obvious happening here from a user perspective, but now if there is a problem with the deployment the liveness probe will pick it up a lot faster.

## End of the module, what's next ?

You have reached the end of this section of the lab. The next module is `Horizontal scaling`

## Acknowledgements

* **Author** - Tim Graves, Cloud Native Solutions Architect, EMEA OCI Centre of Excellence
* **Contributor** - Jan Leemans, Director Business Development, EMEA Divisional Technology
* **Last Updated By** - Tim Graves, July 2021
