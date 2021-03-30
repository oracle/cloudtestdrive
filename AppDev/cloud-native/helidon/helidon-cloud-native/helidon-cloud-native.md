![](../../../../common/images/customer.logo2.png)

# Cloud Native - Supporting cloud native operations with Helidon

<details><summary><b>Self guided student - video introduction</b></summary>


This video is an introduction to the Helidon cloud native support lab. Depending on your browser settings it may open in this tab / window or open a new one. Once you've watched it please return to this page to continue the labs.

[![Helidon cloud native support lab Introduction Video](https://img.youtube.com/vi/vPSphbTg1MQ/0.jpg)](https://youtu.be/vPSphbTg1MQ "Helidon cloud native support lab introduction video")

---

</details>

## Introduction

**Estimated module duration** 10 mins.

### Objectives

Here we will see how Helidon can provide information to operational frameworks to determine not only if your microservice is able to respond to requests, but also if it's operational. This information can be used by coordinators like Kubernetes to restart services or stop directing requests to them.

### Prerequisites

You need to have completed the **Operations support with Helidon** module.

## Step 1: Is it running ?

Most cloud native platforms (and Kubernetes in particular) need to know if a microservices is running at all, if it's capable of responding to requests and if it has access to all the dependent services it needs to operate. In the event that these conditions are not fulfilled the cloud native platform will take steps like re-starting a microservice instance, or stopping sending it requests for a short while.

The exercises in this section show how you can use Helidon to directly support the cloud native capabilities that Kubernetes uses. It does not directly cover using them in Kubernetes however, but if later on you're doing the microservices in Kubernetes modules then this will make sense when you do it.

**Monitoring and metrics**
Kubernetes does not itself have built in monitoring tools, however many users of Kubernetes use Prometheus which can use the /metrics API Helidon provides and we saw in the operations section of these labs to extract data on the operation and performance of a microservice, then Grafana is used to visualise the metrics retrieved from Prometheus.

## Step 2: Health
Helidon has built in health info as standard. By default this is available on the same port as the service, but our runtime config (conf/storefront-network.yaml) separates these  onto different ports (8080 for the service, 9080 for the non service) 

  1. If the storefront and stockmanager are not running start them.

  2.Look at the details of the default health service
  
  -  `curl -i -X GET http://localhost:9080/health`

  ```
HTTP/1.1 200 OK
Content-Type: application/json
Date: Mon, 6 Jan 2020 18:28:28 GMT
connection: keep-alive
content-length: 460

{"outcome":"UP","status":"UP","checks":[{"name":"deadlock","state":"UP","status":"UP"},{"name":"diskSpace","state":"UP","status":"UP","data":{"free":"1.40 TB","freeBytes":1534390464512,"percentFree":"76.69%","total":"1.82 TB","totalBytes":2000796545024}},{"name":"heapMemory","state":"UP","status":"UP","data":{"free":"919.13 MB","freeBytes":963775960,"max":"16.00 GB","maxBytes":17179869184,"percentFree":"99.36%","total":"1.00 GB","totalBytes":1073741824}}]}
```

The default info contains information on the microservices use of resources (CPU, Memory , disk usage and so on) This information could be gathered and processed by a managment tool to see if there was a approaching problem due to memory leaks, lack of storage etc.

## Step 3: Liveness
Services like kubenetes will know if a microservice has crashed as the application will have exited, but detecting that the service is not properly responding to requests is harder. Eventually most programs will get into some kind of resource starvation request like a deadlock. Cloud native platforms like Kubernetes have `liveness` tests which check to see if the microservice is alive (e.g. not in deadlock) If the service is not responding then the cloud native platform can restart it.

Provding a Liveness capability is pretty simple. Somewhere in the class structure you just need a class that implements the HealthCheck interface (Helidon uses this interface to know what method to call to run the test) and is annotated with `@Liveness` 

  1. In the storefront project navigate to the package **com.oracle.labs.helidon.storefront.health**, and open the file **LivenessChecker.java**

  2. Add an annotation to the class definition:

  -  `@Liveness`
  
  The class declaration section should look like 

  ```java

@ApplicationScoped
@Liveness
@Slf4j
public class LivenessChecker implements HealthCheck {
```

<details><summary><b>Java Imports</b></summary>

You may need to add the following import to the class

```java
import org.eclipse.microprofile.health.Liveness;
```

---

</details>

Because this implements the HealthCheck interface it must provide a implementation of the call() method which returns a HealthCheckResponse, this is at the end of the method. Please ignore the section of code that looks for a `/frozen` file, that is there to support exploring Liveness in the Kubernetes labs (and would not be in a production deployment !)

```java
@Override
	public HealthCheckResponse call() {
	...
	return HealthCheckResponse.named("storefront-live").up()
					.withData("uptime", System.currentTimeMillis() - startTime).withData("storename", storeName)
					.withData("frozen", false).build();
	}
```

<details><summary><b>What should I do in a Liveliness check?</b></summary>


What you actually do in the liveness check requires careful consideration. It should not be to complex or use a lot of resources, because that in itself will reduce the resources available to process real requests. Yet the liveness check must also ensure that it actually tests something useful, there's no point in just returning "OK" if you don't actually test the operation of the microservice.

The Liveness check we have here is **not** one that you would use in production. While it does test the web service part of the Helidon stack it doesn't check the correct operation of the storefront. However the storefont is pretty simple so there's not really much that could be tested.

As another reason this particular Liveness checker is not production ready in that it's actually implemented so we can create a fake scenario where the system is not responding to a Liveness check if the file /frozen exists. This is provided so we can demonstrate how Kubernetes will behave in the event that a Liveness check does fail. Obviously in a production system you're not going to be doing that.

---

</details>


  3. Save the changes and **restart** the application. 

  4. Look at the results of the health endpoint
  
  -  `curl -i -X GET http://localhost:9080/health`

  ```
HTTP/1.1 200 OK
Content-Type: application/json
Date: Mon, 6 Jan 2020 18:45:58 GMT
connection: keep-alive
content-length: 574

{"outcome":"UP","status":"UP","checks":[{"name":"deadlock","state":"UP","status":"UP"},{"name":"diskSpace","state":"UP","status":"UP","data":{"free":"1.40 TB","freeBytes":1534352314368,"percentFree":"76.69%","total":"1.82 TB","totalBytes":2000796545024}},{"name":"heapMemory","state":"UP","status":"UP","data":{"free":"926.15 MB","freeBytes":971133984,"max":"16.00 GB","maxBytes":17179869184,"percentFree":"99.40%","total":"1.00 GB","totalBytes":1073741824}},{"name":"storefront-live","state":"UP","status":"UP","data":{"frozen":false,"storename":"My Shop","uptime":3011}}]}
```

The health endpoint now includes the data we return from the Liveness check, in this case 

```json
{"name":"storefront-live","state":"UP","status":"UP","data":{"frozen":false,"storename":"My Shop","uptime":3011}}
```

There is of course a lot of other data that Kubernetes could use, for example to detect if a microservice instance was consuming to much memory.

## Step 4: Readiness
<details><summary><b>Intro on Readiness</b></summary>


If an application crashes then clearly the solution is to restart it, and in basically most cases if it's in deadlock the only option is to restart, so cloud native platforms like Kubernetes do just that in those situations. 

There is however a different situation where a microservice itself can be behaving just fine, but it can't actually process requests because a service it depends on is for some reason not available. In many situations the downstream service will likely become available again - perhaps there has been a temporary network issue. 

In this situation restarting the higher level microservice wont actually solve the problem, if the downstream service is unavailable doing a restart of the upstream service wont solve that problem, and the restart will place unneeded load on the environment.

Readiness is a way to let the microservices runtime determine if a service has everything it needs to respond to requests. Helidon has a build in configuration to offer a readiness response to platforms like Kubernetes, but like Liveness you need to look at the actual implementation carefully, you don't want to be making expensive calls to the downstream service, but equally you want to make sure that it is responding. In particular if the downstream service does become ready again your readiness checker needs to update it's response, reflecting that it is now ready to process requests again.

---

</details>

  1. In the storefront project navigate to the package **com.oracle.labs.helidon.storefront.health** Open the file **ReadinessChecker.java**
  
  2. Add the following annotation to the class ReadinessChecker
  
  - `@Readiness`

The start of the class should now look like :

  ```java
@ApplicationScoped
@Readiness
@Slf4j
public class ReadinessChecker implements HealthCheck {
```

<details><summary><b>Java Imports</b></summary>

You may need to add the following import to the class

```java
import org.eclipse.microprofile.health.Readiness;
```

---

</details>

  3. Save your changes and **restart** the storefront

  4. Call the URL that goes direct to the storefront ready state:
  
  -  `curl -i -X GET http://localhost:9080/health/ready`

  ```
HTTP/1.1 200 OK
Content-Type: application/json
Date: Mon, 6 Jan 2020 18:57:54 GMT
connection: keep-alive
content-length: 127

{"outcome":"UP","status":"UP","checks":[{"name":"storefront-ready","state":"UP","status":"UP","data":{"storename":"My Shop"}}]}
```

The readiness check is informing us that the service is ready and can process requests.

Let's check that the service can indeed inform us of an issue - the backend storemanager not being available in this case :

  5. On the **Eclipse console tab**, switch to the **stockmanager** tab, then use the **Stop** button to stop the **stockmanager** process and stop it.

  6. Now let's make another readiness request to the storefront :

  -  `curl -i -X GET http://localhost:9080/health/ready`

  ```
HTTP/1.1 503 Service Unavailable
Content-Type: application/json
Date: Mon, 6 Jan 2020 19:00:05 GMT
transfer-encoding: chunked
connection: keep-alive

{"outcome":"DOWN","status":"DOWN","checks":[{"name":"storefront-ready","state":"DOWN","status":"DOWN","data":{"exeption":"java.net.ConnectException: Connection refused (Connection refused)","statusURL":"http://stockmanager:8081/status","storename":"My Shop"}}]}
```

The service is "DOWN" as it can't process requests properly, so a cloud native platform like Kubernetes would no longer send requests to this instance.

  7. Restart the stockmanager 
  
  8. Wait a short time (we need the stock manager to start and be available for the storefront readiness check) and then rerun the readiness check:
  
  -  `curl -i -X GET http://localhost:9080/health/ready`

  ```
HTTP/1.1 200 OK
Content-Type: application/json
Date: Mon, 6 Jan 2020 19:01:33 GMT
connection: keep-alive
content-length: 127

{"outcome":"UP","status":"UP","checks":[{"name":"storefront-ready","state":"UP","status":"UP","data":{"storename":"My Shop"}}]}
```

As the stockmanager is now up the storefront has it's dependencies satisfied and it can respond that it's status is UP and it's ready to process requests. The cloud native infrastructure will then send it requests as needed.

---

## End of the module, what's next ?

You have finished all the core labs in **Helidon**.  

If you wish you can now do the optional **Self documenting API support in Helidon** module

If you do not want to do the **Self documenting API support in Helidon** module and are doing the "mega" lab then the next module is the **Docker** module

If you are only doing the Helidon labs and do not want to do the **Self documenting API support in Helidon** module then thank you for your time and attention

## Acknowledgements

* **Author** - Tim Graves, Cloud Native Solutions Architect, EMEA OCI Centre of Excellence
* **Contributor** - Jan Leemans, Director Business Development, EMEA Divisional Technology
* **Last Updated By** - Tim Graves, November 2020

## Need Help ?

If you are doing this module as part of an instructor led lab then please just ask the instructor.

If you are working through this module self guided then please submit feedback or ask for help using our [LiveLabs Support Forum](https://community.oracle.com/tech/developers/categories/OCI%20Native%20Development). Please click the **Log In** button and login using your Oracle Account. Click the **Ask A Question** button to the left to start a *New Discussion* or *Ask a Question*.  Please include your workshop name and lab name.  You can also include screenshots and attach files.  Engage directly with the author of the workshop.

If you do not have an Oracle Account, click [here](https://profile.oracle.com/myprofile/account/create-account.jspx) to create one.
