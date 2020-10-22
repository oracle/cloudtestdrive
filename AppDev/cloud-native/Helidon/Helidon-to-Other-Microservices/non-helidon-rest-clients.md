[Go to Helidon for Cloud Native Page](../Helidon-labs.md)

![](../../../../common/images/customer.logo2.png)

# Migration of Monolith to Cloud Native

##  Helidon for Cloud Native

## Non Helidon clients of a micro service

The RestClient model in Helidon makes it really simple to program access to another micro-service, but sometimes you will be using something that isn't itself a micro-service to talk to a REST endpoint. In that case you probably do not want to bring in the entire Helidon MP stack and change the client to being Helidon based !

There are of course many client side frameworks in place to allow you to make a call to a REST end point, for example you could use the basic [Java HTTP client service](https://docs.oracle.com/en/java/javase/11/docs/api/java.net.http/java/net/http/HttpClient.html) which allows you to build every stage of the client connection, defining proxies and so on. There are also clients built on the Reactive Framework. The following is an example using the Http client taken from the Java docs page

```java
   HttpClient client = HttpClient.newBuilder()
        .version(Version.HTTP_1_1)
        .followRedirects(Redirect.NORMAL)
        .connectTimeout(Duration.ofSeconds(20))
        .proxy(ProxySelector.of(new InetSocketAddress("proxy.example.com", 80)))
        .authenticator(Authenticator.getDefault())
        .build();
   HttpResponse<String> response = client.send(request, BodyHandlers.ofString());
   System.out.println(response.statusCode());
   System.out.println(response.body());  
```

Not to complex, but pretty verbose !

One problem with these is that they don't provide you with a framework that let's you program the rest service the same way as if it was a local Java object based on an interface in the way that the RestClient annotation does.

If you are refactoring your monolith code and only want to move a small part of the service out of the monolith at a time then the easiest way to do that is for the rest of your code to continue to operate unchanged using an interface that defines the functionality the code you are moving. That way your existing code can continue to operate unchanged.

Fortunately for us Helidon does provide a way of doing this without having to deploy the entire Helidon framework and using the Helidon SE RestClientBuilder. Of course other Microprofile implementations also provide a similar package.

### How to do it

#### Define the service interface

You need to define the interface for your micro-service, in the same way as you would for any other Helidon micro-service. Hopefully you have done this as part of process of building the micro-service and can just import the project containing the interface into your client project, though for some microservice purists this is regarded as being bad, as really the "contract" should not be in code shared code (which makes it difficult to independently update the client and server) but in the endpoints and data model. The code below is the interface definition for the StockManager micro-service we have already been using. The annotations are the same as building the interface for use with MP, the server side annotations like @ApplicationScoped will be ignored by the rest client builder, and as we are using the Helidon SE code so will the Helidon MP specific annotations like RegisterRestClient

```java
@RegisterRestClient(configKey = "StockManager")
@ApplicationScoped
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

#### Create the client

The Helidon SE rest client library let's us create a proxy based in the interface programmatically. Ultimately this is what the Helidon MP annotations do under the covers. For example

```java
		StockManager sm = RestClientBuilder.newBuilder().baseUri(URI.create("http://localhost:8080")).build(StockManager.class);
		System.out.println("All stock levels are " + sm.getAllStockLevels());
```

Note that you have to provide the URL for the service end point, there is no Helidon config system available for you if you just import the rest client so you can't use the annotations for this. It is highly likely however that your client will have a properties file or other configuration mechanisms that can provide you with a way to store and retrieve external config information for you.

The above is a very simple client, it doesn't for example handle setting authentication details. Fortunately for us there is a simple way to extend the behavior of the proxies created by the RestClientBuilder. This is done by registering additional code that the proxy will call as it goes through the request process.

To do this first we have to create a proxy that will modify the headers in the request to add the authentication you want. The following is a very simple class to do this using basic authentication, but you could of course implement an OAUTH2 client or something else to provide the authentication details if desired. 
 
 ```java
 public class AuthBuilder implements ClientRequestFilter {
	private String user, password;

	public AuthBuilder(String user, String password) {
		this.user = user;
		this.password = password;
	}

	@Override
	public void filter(ClientRequestContext requestContext) throws IOException {
		MultivaluedMap<String, Object> headers = requestContext.getHeaders();
		// remove any existing authorization
		headers.remove(HttpHeaders.AUTHORIZATION);
		// Build a new authorization header
		String auth = user + ":" + password;
		byte[] encodedAuth = Base64.getEncoder().encode(auth.getBytes(StandardCharsets.ISO_8859_1));
		String authHeader = "Basic " + new String(encodedAuth);
		// apply the new authorization header
		headers.add(HttpHeaders.AUTHORIZATION, authHeader);
	}
}
 ```
 
Looking at the code you'll see that the filter method is the key functionality, when called by the proxy it will remove any existing authentication from the request and create a new one.
 
 All we need to do now is to register it when the RestClientBuilder is creating the proxy for us
 
```java
		StockManager sm = RestClientBuilder.newBuilder().baseUri(URI.create("http://localhost:8080")).register(new AuthBuilder(DEFAULT_USER, DEFAULT_PASS)).build(StockManager.class);
		System.out.println("All stock levels are " + sm.getAllStockLevels());
```

Here I'm defining and creating an instance of the class, but you could of course use a Lambda to do this if you liked. Equally while here I'm using constants to get the details you would normally get them from a configuration file or some other mechanism.

#### Additional information
The full specification of the [RestClient for Microprofile implementations](https://download.eclipse.org/microprofile/microprofile-rest-client-1.3/microprofile-rest-client-1.3.html) defined all of the capabilities. Very useful capabilities to help minimize code changes in your existing client are exception mappers

##### Response Exception Mapping
The ResponseExceptionMappers take the response returned and if it's not what's expected convert it into the appropriate exception, for example if your client is trying to retrieve some data and expects a `ItemNotFoundException` to be thrown if the data is not found just define and register a ResponseExceptionMapper so if the micro-service returns a http 404 (not found) code the mapper identifies it and throws a `ItemNotFoundException`

### Required libraries
You will of course need to bring in the required libraries for the rest client builder. The Maven dependencies are as follows (the version numbers are correct as of Mid Feb 2020, but you may want to check for later versions.)

```xml
		<dependency>
			<groupId>io.helidon.microprofile.rest-client</groupId>
			<artifactId>helidon-microprofile-rest-client</artifactId>
			<version>${helidon.version}</version>
		</dependency>
		<!-- brings in the json binsings -->
		<dependency>
			<groupId>jakarta.xml.bind</groupId>
			<artifactId>jakarta.xml.bind-api</artifactId>
			<version>2.3.2</version>
		</dependency>
		<!-- runtime for the java bindings (no longer part of std java -->
		<dependency>
			<groupId>org.glassfish.jaxb</groupId>
			<artifactId>jaxb-runtime</artifactId>
			<version>2.3.2</version>
		</dependency>
		<!-- sets up the message readers for us -->
		<dependency>
			<groupId>org.glassfish.jersey.media</groupId>
			<artifactId>jersey-media-json-jackson</artifactId>
			<version>2.30</version>
		</dependency>
```
