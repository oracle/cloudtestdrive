[Go to Helidon for Cloud Native Page](../Helidon-labs.md)

![](../../../../common/images/customer.logo2.png)

# Migration of Monolith to Cloud Native

## A. Helidon for Cloud Native

## 3. Communicating between microservcies

<details><summary><b>Self guided student - video introduction</b></summary>
<p>

This video is an introduction to the Helidon communicating with other REST services lab. Once you've watched it please press the "Back" button on your browser to return to the labs.

[![Helidon communication to other REST services capabilities lab Introduction Video](https://img.youtube.com/vi/IZnlF6lhfNA/0.jpg)](https://youtu.be/IZnlF6lhfNA "Helidon communication to other REST services lab introduction video")

</p>
</details>

---

For one thing (person, program etc.) to talk to another it does of course need to talk the same language, in the case of microservices this is generally based on the ideas in REST, which is an **architectural style, not a standard** (Anyone who tries to say that REST is a standard should go read the [Wikipedia REST article](https://en.wikipedia.org/wiki/Representational_state_transfer))

REST is generally implemented using http(s) as the transport using XML or JSON text in the body of the request to represent data if needed, so though REST is **not** a standard usually we can get it to work using these mechanisms.


<details><summary><b>Implementing communications (historically)</b></summary>
<p>

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
We could of course build a class ourselves that has a delete method that does the REST work in the class, but that's just pushing it down a layer !

**RestClients**

Fortunately for us Eclipse Microprofile have created a solution for this in a manner that results in minimal code changes to your logic.

Best software development practice is to to follow the [loose coupling design patterns](https://en.wikipedia.org/wiki/Loose_coupling) so that the caller can't see the details of the implementation. In Java this is achieved using interfaces, so a developer created an interface for externally use that defines the functionality and then a separate class the implements it, this is especially true if your class is in a library class or a different package.

All a developer then need to do is to have your code create a proxy for the interface (or preferably have a factory create it) and interact with the actual implementation of the micro-service using the proxy which looks like the interface, The interface is of course by definition public and (if designed properly) will not expose any of the implementation details.

With Helidon and the Rest Client functionality all we need to do is to annotate the interface with details of paths and such like, add the @RegisterRestClient annotation and then inject it as a Rest client to the class that uses it. Then we can carry on in our code using the interface as if it was an interface for a local class, for example 

```java
	ItemDetails itemDetails = stockManager.getStockItem(itemRequest.getRequestedItem());
```

We don't need to change any of our code that uses the interface at all, and Helidon creates the RestClient proxy to do all of the network activities for us automatically!

</p></details>

---





Let's do this for real. 

- The **stockmanager** service should still be running, if not then please start it.
- In project **helidon-labs-storefront**, navigate to folder **src/main/java**, then **restclients** and open the file **StockManager.java**

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

Let's set this up as something that can be build into a REST client:

- add the following annotations:

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
<p>

You may need to add the following imports to the class

```java
import javax.enterprise.context.ApplicationScoped;
import org.eclipse.microprofile.rest.client.inject.RegisterRestClient;
```

---
</p></details>

<details><summary><b>Details on the annotations</b></summary><p>

The annotation tells Helidon that this is something that can be used as a REST client, the configKey parameter to the annotation tells Helidon that the configuration settings (URL to use and so on) will be in the configuration properties with property names starting with StockManager.  

If we didn't specify a configuration key the fully qualifies class name would be used for the start of the properties, in this case com.oracle.labs.helidob.storefront.resources.StorefronResource.

As the URL and so on is pretty standard they are defined in the microprofile-config.properties file in src/main/resources These are the relevant lines

```
StockManager/mp-rest/url=http://stockmanager:8081/stocklevel
StockManager/mp-rest/connectTimeout=5000
StockManager/mp-rest/responseTimeout=5000
```

The only thing we absolutely have to specify is the URL, though this can be specified as an option in the `RegisterRestClient` annotation if desired as well (the configuration files will override anything that's hard coded in the annotation.) The timeouts and so on are really for convenience, we could also (if it wasn't defined in the interface itself) specify the scope of the rest client. Note that configuration property settings will override those in the source code.

Also in the microprofile-config.properties file are details for another REST client

```
com.oracle.labs.helidon.storefront.restclients.StockManagerStatus/mp-rest/url=http://stockmanager:8081/status
```

As you can probably guess this is for the REST client com.oracle.labs.helidon.storefront.restclients.StockManagerStatus, but in this case I didn't specify a config key in the `@RegisterRestClient` annotation, so it defaulted to the fully qualified classname based property names.

---

</p></details>

<details><summary><b>Why is this interface in this project ? </b></summary><p>

Good question, best practice is that normally you would define code like the interface which is common to multiple projects in a separate project and both the StockManager and Storefront projects would import it. This also allows you to properly use the Java modules.

In fact for some code in this lab (e.g. the ItemDetails class) that is common we do exactly that. However that means you have to manage three separate projects (common, storefront and stockmanager) and remember to build and push the common project to the local Maven repository when changes are made. When we tested the lab we found this caused a lot of confusion, so for the purposes of the lab only we have included it in the storefront project. Normally of course you would not do this and would follow the best practice.

---

</p></details> 

### Creating the REST client.
It's possible to manually create a REST client using the interface, but it's far better to let Helidon use the @RestClient coupled with @Inject to do this for us. That way we don't have to worry about closing the client to reclaim resources and so on.

- Navigate to the **resources** folder and open the file **StorefrontResource.java**

- Locate the line where the **stockManager** is defined

- Add the following annotations:

```java
    @Inject
    @RestClient
```

- Remove the null initializer.

Result:

```java
	@Inject
	@RestClient
	private StockManager stockManager;
```

<details><summary><b>Java Imports</b></summary>
<p>

You may need to add the following import to the class

```java
import org.eclipse.microprofile.rest.client.inject.RestClient;
```

---
</p></details>

Now when the StorefrontResource class is initialized the Helidon runtime will dynamically create (if needed, or use an existing instance as appropriate depending on the scope) a proxy implementation that looks like the interface, but under the covers does all of the work to make the REST calls and process the response into the returned objects.

Basically this looks pretty simple in comparison to making all of the http requests by hand !

- **Save the changes** to the files
- **Run** the storefront main class.

Let's try accessing the storefront service using **curl**.  This may take a few seconds to respond to the first request as there is a lot of stuff which is initialized on demand here. 

-  `curl -i -X GET -u jill:password http://localhost:8080/store/stocklevel`

```
HTTP/1.1 200 OK
Content-Type: application/json
Date: Mon, 6 Jan 2020 14:33:57 GMT
connection: keep-alive
content-length: 148

[{"itemCount":5000,"itemName":"pin"},{"itemCount":150,"itemName":"Pencil"},{"itemCount":50,"itemName":"Eraser"},{"itemCount":100,"itemName":"Book"}]
```
<details><summary><b>Got an error ?</b></summary><p>
It's possible that the services may take longer to do their initial initialization that the timeouts. (The initialization is done on demand) If this happens you may get an error. Wait a short while and retry, hopefully the initialization will have been completed then.
</p></details>

We have now got the data back from the database itself. Our client is working, and with very little effort !

### Talking to non Helidon REST services
If you have a non Helidon micro-service and want to talk to it from a Helidon MP client just create an appropriate interface to represent the REST service and then follow the approach above to create the proxy implementations of the interface and use it.


## Non Helidon MP clients of a micro service, also known as My monolith is not decomposed yet
Of course here we've been assuming that this is a Helidon MP micro-service talking to another Helidon MP micro-service. But it's quite possible (even probable) that you are actually going to be making a gradual transition of your monolithic applications to micro-services and will be splitting of bits of the monolith at a time. In those cases you want to be able to connect your remaining monolith to the new micro-service while making as few changes to the monolith as possible. In that case you can still use the approach of defining an interface for your micro-service and then creating a proxy implementation. Your original code just continues to use the proxy which it thinks is the real local object, not a remote micro-service, the only code changed required in the origional monolith code is to crate the proxy rather than instantiate a local class.

We've put together a short document on how to [manually create a rest client](non-helidon-rest-clients.md) if you want more information. (Reading this is an optional activity in this lab)

---

<details><summary><b>Async requests</b></summary>
<p>
You may have noticed the delay in the request, if you try the request again it's much faster, this is because the second time all of the lazy initialization will have been done. But in some cases it may be that every call to a request takes a long time (perhaps it's getting data from a real physical device !) which may leave the client execution blocked until the request completes.

One solution to this is to make the request, then go and do something else while waiting for the response. We're not going go to into detail on this, but the REST client supports the use of async operations by having the returned object not be the actual object (which would require the entire call sequence to have completed) but a object of type `CompletionStage`. 

The CompletionStage objects are created by the framework on the client side, so the response is much faster, and by looking into the CompletionStage object it's possible to determine if the call has finished, and if so what the result was. If you want you can register code to be run independently when the CompletionStage finishes (or the process errors.)

</p></details>

---

<details><summary><b>How does the authentication transfer ?</b></summary>
<p>


You may be wondering about the authentication here. When we made the curl call we specified the usersername and password, but that was to the storefront service. None of our code event sees the user name / password, that's all done by the framework, so how can it be passed on to the stockmanager service (which if it didn't get the username and password would have thrown a 401 Unauthorized error.

The solution to this is another reason why using Helidon (or other microprofile based frameworks) is exceptionally useful. Helidon automatically extracts the authorization data for us when it received the storefront request. That information is held within the framework as part of the request and when the subsequent requests are made via the REST Client is till automatically add the authentication data for us. Thus the users information is propagated throughout the sequence of requests.

This is why we've used the same user credentials, and in a production environment you'd use the same security system across both services.

</p></details>

---


### End of the lab
You have finished this part of the lab, you can proceed to the next step of this lab:

[4. Supporting operations activities with Helidon](../Helidon-Operations/helidon-operations.md)



---


[Go to *Helidon for Cloud Native* overview Page](../Helidon-labs.md)