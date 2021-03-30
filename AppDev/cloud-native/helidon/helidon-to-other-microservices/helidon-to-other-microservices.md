![](../../../../common/images/customer.logo2.png)

# Cloud Native - Communicating between microservcies

<details><summary><b>Self guided student - video introduction</b></summary>


This video is an introduction to the Helidon communicating with other REST services lab. Depending on your browser settings it may open in this tab / window or open a new one. Once you've watched it please return to this page to continue the labs.

[![Helidon communication to other REST services capabilities lab Introduction Video](https://img.youtube.com/vi/IZnlF6lhfNA/0.jpg)](https://youtu.be/IZnlF6lhfNA "Helidon communication to other REST services lab introduction video")

---

</details>

## Introduction

**Estimated module duration** 20 mins.

### Objectives

Here we will see how you can use a Helidon RESTClient in your Helidon code to access a different microservice, enabling the condtruction of a cooperating mesh of microservices.

### Prerequisites

You need to have completed the **Databases with Helidon** module.

## Step 1: Service to service communications

For one thing (person, program etc.) to talk to another it does of course need to talk the same language, in the case of microservices this is generally based on the ideas in REST, which is an **architectural style, not a standard** (Anyone who tries to say that REST is a standard should go read the [Wikipedia REST article](https://en.wikipedia.org/wiki/Representational_state_transfer))

REST is generally implemented using http(s) as the transport using XML or JSON text in the body of the request to represent data if needed, so though REST is **not** a standard usually we can get it to work using these mechanisms.


<details><summary><b>Implementing communications (historically)</b></summary>


Historically much of the work on creating REST based microservice frameworks in Java has concentrated on the server side. Creating the client side connection has required the developer to create the connection themselves. For example the following.

```java
private ItemDetails setItemCount(ItemDetails newDetails) {
    // business logic happens here
    // let's sent the data
	try {
		URL url = new URL("http://my.service.com/store/stocklevel) ;
		HttpURLConnection con = (HttpURLConnection) url.openConnection();
         con.setRequestMethod("POST"); 
         con.setRequestProperty("Content-Type", "application/json");  
         con.setDoOutput(true); 

         OutputStream os = con.getOutputStream(); 
         jaxbContext.createMarshaller().marshal(neDetails, os); 
         os.flush(); 

         ItemDetails resultingItemDetails ;
         if (con.getResponseCode() == 200) {
            // now get the result
            BufferedReader respIn = new BufferedReader(new InputStreamReader(con.getInputStream())) ;
            String respLine ;
            String response ;
            while ((respLine = respIn.readline()) != null) {
               response+= respLine ;
            }
            respIn.close() ;
            ObjectMapper detailsMapper = new ObjectMapper() ;
            resultingItemDetails = detailsMapper.readVale(response, itemDetails.class) ;
         } else {
            throw Exception("Didn't get OK from service") ;
         }
         return resultingItemDetails ;
         con.disconnect(); 
    } catch(Exception e) { 
         throw new RuntimeException(e); 
    } 
}
```

Over time this got a bit easier with wrapper classes 

```java
private void deleteItem(String itemName) {
   RestTeplateBuilder rtb = new RestTemplateBuilder() ;
   RestTemplate = rtb.build() ;
   rt.delete("http://my.service.com/store/stocklevel"), itemName);
}
```

But it's still not as simple as calling the method we want directly

```java
private void deleteItem(String itemName) {
   StockManager manager = new StockManager() ;
   stockmanager.delete(itemName) ;
```
We could of course build a class ourselves that has a delete method that does the REST work in the class, but that's just pushing it down a layer!


---

</details>

**RestClients**

Fortunately for us Eclipse Microprofile have created a solution for communicating between microservices (and non microservices for that matter) in a manner that results in minimal code changes to your code.

Best software development practice is to to follow the [loose coupling design patterns](https://en.wikipedia.org/wiki/Loose_coupling) so that the caller can't see the details of the implementation. In Java this is achieved using interfaces, so a developer created an interface for externally use that defines the functionality and then a separate class the implements it, this is especially true if your class is in a library class or a different package.

Of course your code may not have an interface, not least of which is the remove microservice may not be written in Java, so in that case you've create an interface to represent the remote endpoint.

All a developer then need to do is to have your code create a proxy for the interface (or preferably have a factory create it) and interact with the actual implementation of the micro-service using the proxy which looks like the interface, The interface is of course by definition public and (if designed properly) will not expose any of the implementation details.

With Helidon and the Rest Client functionality all we need to do is to annotate the interface with details of paths and such like, add the @RegisterRestClient annotation and then inject it as a Rest client to the class that uses it. Then we can carry on in our code using the interface as if it was an interface for a local class, for example 

```java
	ItemDetails itemDetails = stockManager.getStockItem(itemRequest.getRequestedItem());
```

We don't need to change any of our code that uses the interface at all, and Helidon creates the RestClient proxy to do all of the network activities for us automatically!


Let's do this for real. 

  1. The **stockmanager** service should still be running, if not then please start it.

  2. In project **helidon-labs-storefront**, navigate to folder **src/main/java**, then the package  **com.oracle.labs.helidon.storefront** then the package **restclients** and open the file **StockManager.java**

First let's look at the StockManager interface.

  ```java
public interface StockManager {
	@GET
	@Produces(MediaType.APPLICATION_JSON)
	public Collection<ItemDetails> getAllStockLevels();

	@GET
	@Path("/{itemName}")
	@Produces(MediaType.APPLICATION_JSON)
	public ItemDetails getStockItem(@PathParam("itemName") String itemName);

	@POST
	@Path("/{itemName}/{itemCount}")
	@Produces(MediaType.APPLICATION_JSON)
	public ItemDetails setStockItemLevel(@PathParam("itemName") String itemName,
			@PathParam("itemCount") Integer itemCount);
}
```

Apart from being an interface (so only method names, not implementations) this looks very like the getAllStockLevels, getStockItem and setStockItemLevel methods in the StockResource class in the stock manager project. We have the same request types, paths, params etc.

  3. Let's set this up as something that can be build into a REST client. Add the following annotations:

  ```java
    @RegisterRestClient(configKey = "StockManager")
    @ApplicationScoped
```

The result should look like :

  ```java
@ApplicationScoped
@RegisterRestClient(configKey = "StockManager")
public interface StockManager {
```

---

<details><summary><b>Java Imports</b></summary>

You may need to add the following imports to the class

```java
import javax.enterprise.context.ApplicationScoped;
import org.eclipse.microprofile.rest.client.inject.RegisterRestClient;
```

---

</details>

We have just told the Helidon framework that when injected into a class that behind the scenes it should create a new class, based on this interface that does all or the communications work for us. Helidon will locate information on how the proxy behaves in the config setup (using the config key) Look at the `Details on annotations` for more information.

<details><summary><b>Details on the annotations</b></summary>

The annotation tells Helidon that this is something that can be used as a REST client, the configKey parameter to the annotation tells Helidon that the configuration settings (URL to use and so on) will be in the configuration properties with property names starting with StockManager.  

If we didn't specify a configuration key the fully qualifies class name would be used for the start of the properties, in this case com.oracle.labs.helidon.storefront.restclients.StockManager.

As the URL and so on is pretty standard they are defined in the microprofile-config.properties file in src/main/resources These are the relevant lines

  ```
StockManager/mp-rest/url=http://stockmanager:8081/stocklevel
StockManager/mp-rest/connectTimeout=5000
StockManager/mp-rest/responseTimeout=5000
```

The only thing we absolutely have to specify is the URL, though this can be specified as an option in the `RegisterRestClient` annotation if desired as well (the configuration files will override anything that's hard coded in the annotation). The timeouts and so on are really for convenience, we could also (if it wasn't defined in the interface itself) specify the scope of the rest client. Note that configuration property settings will override those in the source code.

Also in the microprofile-config.properties file are details for another REST client

  ```
com.oracle.labs.helidon.storefront.restclients.StockManagerStatus/mp-rest/url=http://stockmanager:8081/status
```

As you can probably guess this is for the REST client com.oracle.labs.helidon.storefront.restclients.StockManagerStatus, but in this case I didn't specify a config key in the `@RegisterRestClient` annotation, so it defaulted to the fully qualified classname based property names.

---

</details>

<details><summary><b>Why is this interface in this project ?</b></summary>

Good question, best Java practice is that normally you would define code like the interface which is common to multiple projects in a separate project and both the StockManager and Storefront projects would import it. This also allows you to properly use the Java modules.

In fact for some code in this lab (e.g. the ItemDetails class) that is common we do exactly that, and that's a structure that may well have been used in existing Java code that's being refactored into microservices. However that means you have to manage three separate projects (common, storefront and stockmanager) and remember to build and push the common project to the local Maven repository when changes are made. When we tested the lab we found this caused a lot of confusion, so for the purposes of the lab only we have included it in the storefront project. Normally of course you would not do this and would follow the Java best practice.

There is however also a good argument that we should not share any classes between microservices as the REST API and over the wire data (I.e. JSON / XML) is the key element that defines communications, and that by having common code we are breaking the independence of the microservices. This is one of those things where you have to carefully consider the benefits and disadvantages. Personally if I was creating a new set of microservices I would follow the micrservices approach of keeping things separate, but if I was decomposing existing code which uses a common interface between the calling and called classes (especially which may already be in Java modules) then I would continue to share the code, at least in the short term.

---

</details> 

## Step 2: Creating the REST client instance.

It's possible to manually create a REST client from a code perspective using a RestClientBuilder and the interface (this is how you would add add it to existing code as shown in the optional module `Communicating from non Helidon clients`, but it's far better to let Helidon use the @RestClient coupled with @Inject to do this for us. That way we don't have to worry about closing the client to reclaim resources and so on.

  1. Navigate to the **resources** folder and open the file **StorefrontResource.java**

  2. Locate the line where the **stockManager** is defined

  3. Add the following annotations:

  ```java
    @Inject
    @RestClient
```

  4. Remove the null initializer.

Result:

  ```java
	@Inject
	@RestClient
	private StockManager stockManager;
```

<details><summary><b>Java Imports</b></summary>

You may need to add the following import to the class

```java
import org.eclipse.microprofile.rest.client.inject.RestClient;
```

---

</details>

Now when the StorefrontResource class is initialized the Helidon runtime will dynamically create (if needed, or use an existing instance as appropriate depending on the scope) a proxy implementation that looks like the interface, but under the covers does all of the work to make the REST calls and process the response into the returned objects.

Basically this looks pretty simple in comparison to making all of the http requests by hand, and that is especially true if you had already created an interface to abstract the client code!

  5. **Save the changes** to the files

  6. **Run** the storefront main class.
  
  7. If it's not still running run the stockmanager main class.

  8. Let's try accessing the storefront service using curl. Expect an error

  -  `curl -i -X GET -u jill:password http://localhost:8080/store/stocklevel`

The curl response will give you a 424 error (Failed Dependency) because it can't communicate with the stockmanager servcie, but why is that ? We need to look at the storefront logs to find out.

Looking at the log output of the **storefront** main class you will find a long stack trace, at the top of which will be the request to list stock, followed by a line that there was a `Unknown error, status code 401`

  ```
...
2020.11.04 18:51:09.628 INFO com.oracle.labs.helidon.storefront.resources.StorefrontResource !thread!: Requesting listing of all stock
javax.ws.rs.WebApplicationException: Unknown error, status code 401
<Lots of stack trace>
```

Those of you familiar with HTTP status codes will know that 401 us an authentication error, and from the messages we can see that it's coming from when we make the call to the stockmanager service.

Helidon does not automatically propagate the authentication by default (since Helidon 2.1.0) This is on the principle that you restrict security related information to the smallest set of locations you can, because otherwise you may accidentally propagate security information to locations where it shouldn't go.

Clearly we could remove authentication requirements on the stockmanager service, but this may result in it being accessed by unauthorized persons. We need a better solution.

Fortunately for us Helidon has that solution built in, we just need to tell the security provider to pass on the security credentials to the downstream services.

  9. In the storefront project expand the `confsecure` folder and open the file `storefront-security.yaml`

This contains the security setting used by the storefront service. The `http-basic-auth` is the section we need

  10. Add an outbound section to the `http-basic-auth` **exactly** as shown below

  ```
   - http-basic-auth:
        realm: "helidon"
        users:
          - login: "jack"
            password: "password"
            roles: ["admin"]    
          - login: "jill"
            password: "password"
            roles: ["user"]
          - login: "joe"
            password: "password"
        outbound:
          - name: "propogate-to-everyone"
            hosts: ["*"]
```

It is **absolutely critical** that you maintain the indentation shown (this is achieved with spaces, not tabs allowed). The `outbound` should line up with the `users` section, the hypen in `- name` should be under the `t` in `outbound` and `hosts` should line up with `name`

This setting tells the `http-basic-auth` provider to transfer the inbound credentials to the outbound requests regardless of the host the request is going to.

<details><summary><b>What other settings are possible ?</b></summary>

The `http-basic-auth` provider supports multiple names outbound configurations. Each configuration can specify a host, specific API endpoints the configuration is limited to, if the credentials from the inbound request are to be reused (the default) and any particular credentials to use. 

The precise settings options depend on the security provider, you can see details in the [Helidon security provider documentation.](https://helidon.io/docs/v2/#/mp/security/02_providers) Click on the provider that you're using.

</details>

  11. Save the changes to the storefront-security.conf` file

  12. Stop and restart the storefront service.

  13. Try the curl again

  -  `curl -i -X GET -u jill:password http://localhost:8080/store/stocklevel`

  ```
HTTP/1.1 200 OK
Content-Type: application/json
Date: Mon, 6 Jan 2020 14:33:57 GMT
connection: keep-alive
content-length: 148

[{"itemCount":5000,"itemName":"pin"},{"itemCount":150,"itemName":"Pencil"},{"itemCount":50,"itemName":"Eraser"},{"itemCount":100,"itemName":"Book"}]
```

It may take a few seconds to respond to this first request as there is a lot of stuff which is initialized on demand here. 


<details><summary><b>Got an error ?</b></summary>

It's possible that the services may take longer to do their initial initialization that the timeout allows, especially as multiple services and the database connection are all involved here. (The initialization is done on demand) If this happens you may get an error. Wait a short while and retry, hopefully the initialization will have been completed then.

---

</details>

We have now got the data back from the database itself. Our client is working, and with very little effort!

<details><summary><b>Async requests</b></summary>

You may have noticed the delay in the request, if you try the request again it's much faster, this is because the second time all of the lazy initialization will have been done. But in some cases it may be that every call to a request takes a long time (perhaps it's getting data from a real physical device!) which may leave the client execution blocked until the request completes.

One solution to this is to make the request, then go and do something else while waiting for the response. We're not going go to into detail on this, but the REST client supports the use of async operations by having the returned object not be the actual object (which would require the entire call sequence to have completed) but a object of type `CompletionStage`. 

The CompletionStage objects are created by the framework on the client side, so the response is much faster, and by looking into the CompletionStage object it's possible to determine if the call has finished, and if so what the result was. If you want you can register code to be run independently when the CompletionStage finishes (or the process errors). See the [CompletionStage JavaDoc](https://docs.oracle.com/en/java/javase/11/docs/api/java.base/java/util/concurrent/CompletionStage.html) for more details.

---

</details>

<details><summary><b>Can I transfer other headers ? </b></summary>

You may have other headers that are embedded in your incoming request that you need to transfer. Helidon supports a generic framework for handling headers (and other aspects of a REST request)

On the RESTClient interface you need to register a class to process them using the `@RegisterClientHeaders` annotation. This takes a single parameter which is the name of the class that will do the processing for us. This class must implement the `ClientHeadersFactory` interface

E.g.

```java
@RegisterRestClient
@RegisterClientHeaders(TransferClientHeaders.class)
public interface StockManager
...
```

When Helidon creates the RESTClient for us it will automatically create an instance of that class for us, and add it to the processing pipeline when the RESTClient code calls out to the downstream service.

The class implementing `ClientHeadersFactory` in this case `TransferClientHeaders` will process the actual transfer of the data for us, Here is an example that just adds transfers most of the incoming headers to the outgoing ones, we are removing the `Host` header as forwarding that is regarded as a security issue by the Http processing stack. Also we remove the `Authorization` as we want Helidon to process that for us (if the `Authorization` is present it will just use what's already been provided) It could of course do some more sophisticated processing for us if we wanted.

```java
@Slf4j
public class TransferClientHeaders implements ClientHeadersFactory {

    @Override
	public MultivaluedMap<String, String> update(MultivaluedMap<String, String> incomingHeaders,
			MultivaluedMap<String, String> outgoingHeaders) {
		log.debug("Incoming headers - " + incomingHeaders);
		log.debug("Provided outgoing headers - " + outgoingHeaders);
		// we need to remove some headers as by default they are restricted
		MultivaluedMap<String, String> sanitisedIncomingHeaders = new MultivaluedHashMap<>(incomingHeaders);
		sanitisedIncomingHeaders.remove("Host");
		// Helidon may have handled the Authorization for us.
		sanitisedIncomingHeaders.remove("Authorization");
		// Need a multi valued map as a header can be repeated multiple times.
		MultivaluedMap<String, String> transferredHeaders = new MultivaluedHashMap<>();
		// add all of the headers that have already been setup for us
		transferredHeaders.putAll(sanitisedIncomingHeaders);
		// now add all of the incoming ones
		transferredHeaders.putAll(outgoingHeaders);
		log.debug("Combined headers - " + transferredHeaders);
		// return the new map
		return transferredHeaders;
	}
}

```

---

</details>


### Talking to non Helidon REST services

If you have a non Helidon micro-service and want to talk to it from a Helidon MP client just create an appropriate interface to represent the REST service and then follow the @Inject and @RestClient approach we just followed to create the proxy implementations of the interface and use it.


## Step 3: Non Helidon MP clients of a micro service, also known as My monolith is not decomposed yet

Of course here we've been assuming that this is a Helidon MP micro-service talking to another Helidon MP micro-service. But it's quite possible (even probable) that you are actually going to be making a gradual transition of your monolithic applications to micro-services and will be splitting of bits of the monolith at a time. In those cases you want to be able to connect your remaining monolith to the new microservice while making as few changes to the monolith as possible. In that case you can still use the approach of defining an interface for your microservice and then creating a proxy implementation. Your original code just continues to use the proxy which it thinks is the real local object, not a remote microservice, the only code changed required in the original monolith code is to create the proxy rather than instantiate a local class.

For more details there is a optional lab (See the main labs listing) that explores how to do this.

---


## End of the module, what's next ?

You have finished the lab of **Communicating between microservices with Helidon**. 

You can now do the optional lab **Communicating from non Helidon clients** lab

OR

The next lab in the Helidon core labs is **Operations support with Helidon**

## Acknowledgements

* **Author** - Tim Graves, Cloud Native Solutions Architect, EMEA OCI Centre of Excellence
* **Contributor** - Jan Leemans, Director Business Development, EMEA Divisional Technology
* **Last Updated By** - Tim Graves, November 2020

## Need Help ?

If you are doing this module as part of an instructor led lab then please just ask the instructor.

If you are working through this module self guided then please submit feedback or ask for help using our [LiveLabs Support Forum](https://community.oracle.com/tech/developers/categories/OCI%20Native%20Development). Please click the **Log In** button and login using your Oracle Account. Click the **Ask A Question** button to the left to start a *New Discussion* or *Ask a Question*.  Please include your workshop name and lab name.  You can also include screenshots and attach files.  Engage directly with the author of the workshop.

If you do not have an Oracle Account, click [here](https://profile.oracle.com/myprofile/account/create-account.jspx) to create one.
