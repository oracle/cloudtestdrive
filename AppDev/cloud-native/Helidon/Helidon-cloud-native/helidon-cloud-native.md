[Go to Helidon for Cloud Native Page](../Helidon-labs.md)

![](../../../../common/images/customer.logo2.png)

# Migration of Monolith to Cloud Native

## A. Helidon for Cloud Native

## 5. Supporting cloud native operations with Helidon

<details><summary><b>Self guided student - video introduction</b></summary>
<p>

This video is an introduction to the Helidon cloud native support lab. Once you've watched it please press the "Back" button on your browser to return to the labs.

[![Helidon cloud native support lab Introduction Video](https://img.youtube.com/vi/vPSphbTg1MQ/0.jpg)](https://youtu.be/vPSphbTg1MQ "Helidon cloud native support lab introduction video")

</p>
</details>

---

Most cloud native platforms (and Kubernetes in particular) need to know if a microservices is running at all, if it's capable of responding to requests and if it has access to all the dependent services it needs to operate. In the event that these conditions are not fulfilled the cloud native platform will take steps like re-starting a microservice instance, or stopping sending it requests for a short while.

The exercises in this section show how you can use Helidon to directly support the cloud native capabilities that Kubernetes uses. It does not directly cover using them in Kubernetes however, but if you're doing the microservices in kubernetes sections of the workshop then this will make sense when you do it.

**Monitoring and metrics**
Kubernetes does not itself have built in monitoring tools, however many users of Kubernetes use Prometheus which can use the /metrics API Helidon provides and we saw in the operations section of these labs to extract data on the operation and performance of a microservice, then Grafana is used to visualise the metrics retrieved from Prometheus.

### Health
Helidon has built in health info as standard. By default this is available on the same port as the service, but our runtime config (conf/storefront-network.yaml) separates these  onto different ports (8080 for the service, 9080 for the non service) 

- Look at the details of the default health service:
  -  `curl -i -X GET http://localhost:9080/health`

```
HTTP/1.1 200 OK
Content-Type: application/json
Date: Mon, 6 Jan 2020 18:28:28 GMT
connection: keep-alive
content-length: 460

{"outcome":"UP","status":"UP","checks":[{"name":"deadlock","state":"UP","status":"UP"},{"name":"diskSpace","state":"UP","status":"UP","data":{"free":"1.40 TB","freeBytes":1534390464512,"percentFree":"76.69%","total":"1.82 TB","totalBytes":2000796545024}},{"name":"heapMemory","state":"UP","status":"UP","data":{"free":"919.13 MB","freeBytes":963775960,"max":"16.00 GB","maxBytes":17179869184,"percentFree":"99.36%","total":"1.00 GB","totalBytes":1073741824}}]}
```

The default info contains information on the microservcies use of resources (CPU, Memory , disk usage and so on)

### Liveness
Services like kubenetes will know if a microservice has crashed as the application will have exited, but detecting that the service is not properly responding to requests is harder. Eventually most programs will get into some kind of resource starvation request like a deadlock. Cloud native platforms like Kubernetes have `liveness` tests which check to see if the microservice is alive (e.g. not in deadlock) If the service is not responding then the cloud native platform can restart it.

Provding a Liveness capability is pretty simple. Somewhere in the class structure you just need a class that implements the HealthCheck interface (Helidon uses this interface to know what method to call to run the test) and is annotated with `@Liveness` 

- In the storefront project navigate to the package **com.oracle.labs.helidon.storefront.health**, and open the file **LivenessChecker.java**
- Add an annotation to the class definition:
  -  `@Liveness`

```java

@ApplicationScoped
@Liveness
@Slf4j
public class LivenessChecker implements HealthCheck {
```

<details><summary><b>Java Imports</b></summary>
<p>

You may need to add the following import to the class

```java
import org.eclipse.microprofile.health.Liveness;
```

---
</p></details>

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

<details><summary><b>What is a Liveliness check?</b></summary>
<p>

What you actually do in the liveness check requires careful consideration. It should not be to complex or use a lot of resources, because that in itself will reduce the resources available to process real requests. Yet the liveness check must also ensure that it actually tests something useful, there's no point in just returning "OK" if you don't actually test the operation of the microservice.

THe Liveness check we have here is **not** one that you would use in production. While it does test the web service part of the Helidon stack it doesn't check the correct operation of the storefront. However the storefont is pretty simple so there's not really much that could be tested.

As another reason this particular Liveness checker is not production ready in that it's actually implemented so we can create a fake scenario where the system is not responding to a Liveness check if the file /frozen exists. This is provided so we can demonstrate how Kubernetes will behave in the event that a Liveness check does fail. Obviously in a production system you're not going to be doing that.

</p></details>

---



- Save the changes and **restart** the application. 

- Look at the results of the health endpoint:
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

### Readiness
<details><summary><b>Intro on Readiness</b></summary>
<p>

If an application crashes then clearly the solution is to restart it, and in basically most cases if it's in deadlock the only option is to restart, so cloud native platforms like Kubernetes do just that in those situations. 

There is however a different situation where a microservice itself can be behaving just fine, but it can't actually process requests because a service it depends on is for some reason not available. In many situations the downstream service will likely become available again - perhaps there has been a temporary network issue. 

In this situation restarting the higher level microservice won-t solve the problem, if the downstream service is unavailable doing a restart of the upstream service won't solve that problem, and the restart will place unneeded load on the environment.

Readiness is a way to let the microservices runtime determine if a service has everything it needs to respond to requests. Helidon has a build in configuration to offer a readiness response to platforms like Kubernetes, but like Liveness you need to look at the actual implementation carefully, you don't want to be making expensive calls to the downstream service, but equally you want to make sure that it is responding. In particular if the downstream service does become ready again your readiness checker needs to return to reflecting that in the readiness response it generates.

</p></details>

---



- In the storefront project navigate to the package **com.oracle.labs.helidon.storefront.health** Open the file **ReadinessChecker.java**
- Add the following annotation to the class ReadinessChecker
  -  `@Readiness`

```java
@ApplicationScoped
@Readiness
@Slf4j
public class ReadinessChecker implements HealthCheck {
```

<details><summary><b>Java Imports</b></summary>
<p>

You may need to add the following import to the class

```java
import org.eclipse.microprofile.health.Readiness;
```

---
</p></details>

- Save your changes and **restart** the storefront

- Call the URL that goes direct to the storefront ready state:
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

- On the **Eclipse console tab**, switch to the **stockmanager** tab, then use the **Stop** button to stop the **stockmanager** process and stop it.

Now let's make another readiness request to the storefront :

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

- Restart the stockmanager 
- Rerun the readiness check:
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




### End of the lab
You have finished all the labs in this initial section **A. Helidon**.  

If you wich you can now do the [optional labs in the Helidon section](../Helidon-labs.md)
 
If you don;t want to do those labs then if you are doing the full set of labs you can now start working on Section [B. Using Docker](../../Docker/DockerLabs.md)





---


[Go to *Helidon for Cloud Native* overview Page](../Helidon-labs.md)