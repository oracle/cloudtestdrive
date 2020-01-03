#The Helidon core
Where we look at our initial java classes and REST enable them.

Before anything happens you need to open the Eclipse IDE. There is an Eclipse icon on the desktop, double click it, and wait for Eclipse to start.

For all of the steps in this section of the lab we will be using the helidon-labs-storefront project in Eclipse.

The main class we will be using is the com.oracle.labs.helidon.storefront.resources.StorefrontResource.java Locate it in the Eclipse project explorer (Hierarchical browser on the left of the Eclipse window) and open it.

#Make the list stock REST Service available
The first thing a REST service must do is provide a REST end point that can be called. Helidon makes this process very easy.

Find the listAllStock method in the StorefrontResource.java file

```
	public Collection<ItemDetails> listAllStock() {
		// log the request
		log.info("Requesting listing of all stock");
		// get the list from the stock management service
		try {
			Collection<ItemDetails> items = stockManager.getAllStockLevels();
			// log the response
			log.info("Found " + items.size() + " items");
			// return the items
			return items;
		} catch (Exception e) {
			e.printStackTrace();
			throw e;
		}
	}
```

It's pretty simple, when called it does some logging, then gets a Collection of ItemDetails and returns it, doing a bit of Exception handling as it does so. Hopefully this type of thing will be very familiar to you.

But how to we REST enable it ?

Firstly we need to tell Helidon that the StorefrontResource class responds to REST messages. At the start of the class definition place the annotations
 
```
@Path("/store")
@RequestScoped
```

The `@Path("/store")` annotation means that each time the Helidon framework brings the StorefromtResource in as a REST service that all of the capabilities will be registered under the /store url (the application can provide a higher level URL if it wants, but we're not going to do that here.)

The `@RequestScoped` annotation means that the Helidon framework will create a new instance of the class automatically each time a rest request is made, and that the instance will be used for the duration of that request. This would allow us to modify the internal state of the class as the request is being processed and we can be sure that those modifications woudln't interfere with other subsequent or concurrent requests (well as long as we limit out changes to the StorefrontResource class of course)

Wile we're here you may also have noticed a couple of other annotations already on place on the class. These are being processed by [Lombok](https://projectlombok.org/) Lombok is a set of Java based tools tha use annotations to perform common tasks for us. In this case the `@Log` annotation tells Lombok to automatically generate a Java system logger using the class name as the loggers name. The `@NoArgsConstructor` does what the name suggests and creates a constructor for us without any arguments. 

Lombok provides a wide variety of other usefull annotations to speed up development, for example rather than manually creating getters and setters, hash codes and equals we can just use the @Lombok `@Data` annotation to create them for us automatically. As Lombok is executed when a class if compiled as we change the class any new fields would have getters / setters automatically created for us and any fields that had been removed would no longer have getters / setters created.

It's not required that people use Lombok for java development of course, but I'm using it here to as to not clutter up the code, and also I'm lazy when it comes to coding and Lombok is a great tool for lazy coders :-)

Enough on Lombok. Let's get back to the Helidon work !

Our class definition now starts something like

```
@Path("/store")
@RequestScoped
@Log
@NoArgsConstructor
public class StorefrontResource {
   .....
```

Helidon will now REST enable the class, but it needs to know what specific methods will be REST endpoints.

Place the following annotations of the listAllStock method

```
	@GET
	@Path("/stocklevel")
	@Produces(MediaType.APPLICATION_JSON)
```
These annotations mean :

`@GET` the method will be called in response to http GET requests

`@Path("/stocklevel")` that it will respond to the relative (to the class) path /stocklevel As the class as a whole is under /stock the actual effective path combined the two so it's /stock/stocklevel 
 
`@Produces(MediaType.APPLICATION_JSON)` means that the framework will convert the resulting object into JSON format (there are other formats available, for example APPLICATION_XML, but JSON is nice for humans to read and parse, and it also relatively compact compared to XML)

This Produces annotation is very important to understand. It means that the framework handles all of the work in getting the right data type from the result for us. We don't have to modify our code to generate the JSON (this is often a non trivial bit of work. We could if we wanted support multiple data formats as the return and the framework will chose the right format based on the type the headers in the incoming request asked for. This single annotation is doing a *lot* of work for us behind the scenes.

##But how does the framework know what to make available?
We've updated a single class, but in a traditional Java program something else would be calling that class and starting the rest of the program. We need to have a class that does that for us and tells Helidon that this is a class we want enabled as a REST service.

The com.oracle.labs.helidon.storefront.Main class starts the process. We're going to look into sections of this in more detail soon. but the main thing is to see that the main method of the main class creates a Helidon server instance

```
	public static void main(final String[] args) throws IOException {
		setupLogging();

		log.info("Starting server");
		Server server = Server.builder().config(buildConfig()).build().start();

		log.info("Running on http://localhost:" + server.port() + "/store");
	}
```

How does Helidon know what classes it needs to create REST endpoints for ? Well the annotations system does that.

Look at the class com.oracle.labs.helidon.storefront.StorefrontApplication

```
@ApplicationScoped
@ApplicationPath("/")
public class StorefrontApplication extends Application {

	@Override
	public Set<Class<?>> getClasses() {
		// here we have two classes to operate on, the store front, and the
		// configuration manager
		return CollectionsHelper.setOf(StorefrontResource.class);
	}
}
```

There are several important elements here

`@ApplicationScoped` Means that the Helidon framework will automatically create a *single* instance of the class for the entire application, whenever the framework is asked for an instance of StorefrontApplication that single instance will be returned.

`@ApplicationPath("/")` Means that all the classes that provide REST services for the application will have a URL path starting with / So our listAllStock method will be /store/stocklevel If however the StorefrontAplication has been annotated `@ApplicationPath("/postroom")` then out listAllStock method woudl be on the path /postroom/store/stocklevel (the /postroom coming from the @ApplicationPath annotation on StorefrontApplication, /store from the @Path annotation on the StorefrontResource class and /stocklevel from the @Path annotation on the listAllStock method.

the `extends Application` means that there is a getClasses method which returns a set of classes that form part of the application and actually do the work in responsind to requests.

When the Helidon server starts up it looks for classes with the @ApplicationPath path and that extent the Application interface and then calls the getClasses method on those to get a set of classes that it will then examine in more detail for other annotations.

Save your changes to the StorefrontResource file. then let's run the program.

##Running the storefront program.
In the package explorer locate the class com.oracle.labs.helidon.storefront.Main class. click right on it and chose `Run As` then `Java Application`

![Eclipse Run Storefront Application Main Class](images/eclipse-run-storefront-main.png)

Eclipse may automatically switch to the console for you, but if not in the lower portion of the screen below the Java code window click the "Console" tab

![Eclipse console tab](images/eclipse-run-console-tab.png)

In the console you'll see a bunch of output representing the loging information generated as the storefront starts up

```
2020.01.03 19:39:40 INFO com.oracle.labs.helidon.storefront.Main Thread[main,5,main]: Starting server
2020.01.03 19:39:41 INFO org.jboss.weld.Version Thread[main,5,main]: WELD-000900: 3.1.1 (Final)
2020.01.03 19:39:41 INFO org.jboss.weld.Bootstrap Thread[main,5,main]: WELD-ENV-000020: Using jandex for bean discovery
2020.01.03 19:39:41 INFO org.jboss.weld.Event Thread[main,5,main]: WELD-000411: Observer method [BackedAnnotatedMethod] private io.helidon.microprofile.openapi.IndexBuilder.processAnnotatedType(@Observes ProcessAnnotatedType<X>) receives events for all annotated types. Consider restricting events using @WithAnnotations or a generic type with bounds.
2020.01.03 19:39:41 INFO org.jboss.weld.Event Thread[main,5,main]: WELD-000411: Observer method [BackedAnnotatedMethod] public org.glassfish.jersey.ext.cdi1x.internal.ProcessAllAnnotatedTypes.processAnnotatedType(@Observes ProcessAnnotatedType<?>, BeanManager) receives events for all annotated types. Consider restricting events using @WithAnnotations or a generic type with bounds.
2020.01.03 19:39:42 INFO org.jboss.weld.Bootstrap Thread[main,5,main]: WELD-ENV-002003: Weld SE container c9a54300-79f1-4568-b61e-d9aa8322d693 initialized
2020.01.03 19:39:42 INFO io.smallrye.openapi.api.OpenApiDocument Thread[main,5,main]: OpenAPI document initialized: io.smallrye.openapi.api.models.OpenAPIImpl@28279a49
2020.01.03 19:39:42 INFO io.helidon.webserver.NettyWebServer Thread[main,5,main]: Version: 1.3.1
2020.01.03 19:39:42 INFO io.helidon.webserver.NettyWebServer Thread[nioEventLoopGroup-2-2,10,main]: Channel '@default' started: [id: 0xe4f91c20, L:/0:0:0:0:0:0:0:0:8080]
2020.01.03 19:39:42 INFO io.helidon.microprofile.server.ServerImpl Thread[nioEventLoopGroup-2-2,10,main]: Server started on http://localhost:8080 (and all other host addresses) in 71 milliseconds.
2020.01.03 19:39:42 INFO com.oracle.labs.helidon.storefront.Main Thread[main,5,main]: Running on http://localhost:8080
```

We can see the URL that our server is running on http://localhost:8080 (8080 is the port we've chosen in the Heldion config, we'll look at this later)

Now in a terminal on the desktop let's try opening it (to open a terminal click right on the Linux desktop in tthe client VM and take the Terminal option)

Using curl let's test the http://localhost:8080/store/stocklevel REST endpoint 

```
$ curl -i -X GET http://localhost:8080/store/stocklevel
HTTP/1.1 200 OK
Content-Type: application/json
Date: Fri, 3 Jan 2020 19:45:16 GMT
connection: keep-alive
content-length: 107

[{"itemCount":2,"itemName":"Pen"},{"itemCount":12,"itemName":"Pencil"},{"itemCount":27,"itemName":"Brush"}]
```

We've got data ! Admittedly this is using fake data for now for testing purposes, but it's always a good idea to do that so you have predictable data to run your test cases against (the test data is for now generated using the com.oracle.labs.helidon.storefront.dummy.StockManagerDummy)

Congratulations on creating your first REST API of the lab !

Make the reserveStock REST service available
=============================================
In the StorefrontRecourse class
Note that for now we're working against a dummy data set, so making a change is not permanent
Enable the reserveStockLevels @Post @Path @Produces @Consumes annotations
Note that the body of the request is automatically converted from the JSON into the itemRequest param
call and see that the pencil cound has changed compared to the previous list
{"requestedItem":"Pencil", "requestedCount":7}

Authentication
==============
Problem is anyone can access our service, let's add some security
Add @Authenticated to the StorefrontResource class, this is applied to every REST call in the class (could also add to individual 
ones) now have to have a user for every access
Try accessing the list endpoint, without setting the user details, will get an 401 unauthorized error
Set the username and password (list below) access now works
For this lab using hard coded (in the confsecure/storefront-security.yaml so that needs to be in the config setup), but in reality 
this file would configure things to use an external identity service !
users are jack, jill, joe password for all is password

Adding extra endpoints to the application (and scope implications)
==================================================================
A big application may have multiple sets of services, grouped into resources, we're looking at the Storefront resource that handles the stock interactions
But what if we want to modify the minimum change remotely, can create a new rest endpoint to handle this
Add the ConfigurationResource to the classes in StoreFrontApplication
ConfiguationResource is @ApplicationScoped
Now the endpoint http://localhost:8080/minimumChange is added, can access this, it's not @Authenticated (at class or method) so anyone can call it
Note that the POST is @Authenticated but also @RolesAllowed, requires that the user be in the admin role to access this
If you POST to it with an integer in the body (no need to wrap it in JSON, but do need the jack/password user details as that one has the admin role) you'll find 
that the next get shows the changes value, this is the CongirutationRecourse is across the application, and it has a minimum  change request
However ... making a modification to the minimum change just modifies the version tied to the ConfigurarionResource, the StorefrontResource has it's own version. So 
this doesn;t actually do what we want !
Test this by setting the mnnimum change to 1, then trying to get a single item
Add the StatusResource as well, it's just does a hello world curl -i http://localhost:8080/status returning a bit of config info (more on this later)

Injecting classes and resources
===============================
Say we want to avoid creating class instances and have the system do it for us
Minimum change controls the minimum change for a reservation, we want this to apply across all of the requests.
In the ConfigurationResource class @Inject the minimum change in the Storefront rather than building it by hand
In the StorefrontResourece class @Inject the miniumum change
Look at the MinimumChange class, note @ApplicationScoped - means only one across the entire setup
This is because we don't want a different minimum change value each time
The Injection system knows we only need one and will re-use one the first is created
@RequestScoped means there is once instance across a request
There are other types of scope - see https://stackoverflow.com/questions/7031885/how-to-choose-the-right-bean-scope

Java classes vs Response
========================
Helidon can let us specifically craft an HTTP Response if we want, The ConfigurationResrouce shows how this is don
though in most cases you don't need to do this, it's sometimes sensible. The Failure handling below shows how we can handle converting 
exceptions into respinse codes


Injecting properties from configuration
=======================================
Property inheritance order (top is java system properties, unix env, then config options in order specified, META-INF/microprofile.config is added by default if nothing is specified)
In Main add the conf/storefront-config.yaml source in, note it is optional, if the file is not there no error, for non optional 
the config source must be there - good to hit the error in advance, not sometime downstream !
In minimum change uncomment the second constructor
Note it also has @Inject - the system will look to inject a value into the constructor and use this for creating injectable objects
@ConfigProperty tries to locate the property in the properties stack and apply it, now to change the 
default we just change the config.
Look at the conf1/storefront-config.yaml file, it has two settings,change the minimumDecrement to a value of your choice, but make it 
realistic so below 10 would be a good idea.
edit storecftont-config.yam l, ato the app section 
  minimumdecrement: 3

Now the minimum is set to three compared to the coding default of 2
Also note that there are multiple configuration sources, these are read in order thay are declared, and the first value that matches 
is returned. Why have multiple sources ? It allows the data to be independently set, in many runtime environments you may have different 
people responsible for different areas and thus different configurations.
Having class path as well as local files resources also allows you to have a file containiner default values shipped with your microservice 
and thus always available, you can then use a local file based version to override the speciffic values you want to without having to 
mess aroudn and change the distribution (which is likely to cause problems in a automated deployment situation)

Monitoring the configuration for changes
========================================
By default config read at startup, but it's also possible to define a config source that periodically checks for changes.
In the Storefront.Main class buildConfig method update the configiuration for the storefront-congig line to be :
ConfigSources.file("conf/storefront-config.yaml").pollingStrategy(PollingStrategies::watch).optional()

We'll see later in the Kuberneties labs why we're using conf1 and conf directories, but it also demonstrates that you don;t need to have both in the same place

This means that the configuration source will check periodically if the file has changes and if so will re-load it updating the config data to reflect any changes. Then when the information is retrived from the config it will reflect the latest version.
When allowing for changing the configuration consideration needs to be given to when the data is actually extracted from the configuration. If you look at the StatusResource class you'l see that it's RequestScoped. This means that a new instance is created per request, and the propeties that are @Injected reflect the value of those propertieds at the time the instance was created (it it had been application scoped this woudl have been true as well, but as application scoped means there is only one per application we would have got the value when it was created,, and no updates when the configuration changed.

Run the program and access the status resource. 
curl -i http://localhost:8080/status
HTTP/1.1 200 OK
Content-Type: application/json
Date: Sun, 29 Dec 2019 14:50:07 GMT
connection: keep-alive
content-length: 46

{"name":"My Shop","alive":true,"frozen":false}

Note that it returns a name of "My Shop", (the default value in META-INF/microprofile-config.properties is "Name Not Set", but the conf/storefront-config.yaml overrides that)

LEAVE THE PROGRAM RUNNING !

Edit the conf/storefront-config.yaml file and change it to something unique to you (Say your name) then save the file

Access the status resource again
curl -i http://localhost:8080/status
HTTP/1.1 200 OK
Content-Type: application/json
Date: Sun, 29 Dec 2019 14:51:24 GMT
connection: keep-alive
content-length: 48

{"name":"Tims Shop","alive":true,"frozen":false}

Note that the name is now what you changed it to ("Tims Shop" in this case)

(It may take a short while for the modified file to be recognized and loaded, Helidon checks for config modifications in the background, it seems in my testing to recognize changes within 30 seconds, but usually it's faster)

Of course this is a very simple change in configuration, but the principle applies to any configuration file change. So if you do have configuration information you expect to change whilst the program is running this is a very simple way to handle that without yourself having to remember to check for an process updates.


Separating functionality by port
================================
Helidon can deliver service using multiple ports, for example separating out the administration functions (e.g. metrics, health etc.) from
the operational functions.
Look at the config file in conf/storefront-network.yamp and you will see that it defines two network ports, the primary one on port 8080
and an additional one on port 9080, then it specifies which port the metrics and health services will bund to (the 0.0.0.0 means listen 
on all interfaces, not a speficic IP address)
If you modify the Main class and include the conf/storefront-network.yaml fle, then restart the service you will see in the diagnostic 
output that two channels are now in use, the default on 8080 and admin on 9080.

2019.11.27 16:35:11 INFO io.helidon.webserver.NettyWebServer Thread[nioEventLoopGroup-2-2,10,main]: Channel '@default' started: [id: 0xd964f1e7, L:/0:0:0:0:0:0:0:0:8080]
2019.11.27 16:35:11 INFO io.helidon.webserver.NettyWebServer Thread[nioEventLoopGroup-2-1,10,main]: Channel 'admin' started: [id: 0x65a8faa0, L:/0:0:0:0:0:0:0:0:9080]

We will look more in the the services like health that are available on the admin port in a later exercise.


Handling failures
=================
Remove the StockManagerDummy instance in the StorefrontResource class (It will be null now when the methods are called
Save and run with a request. Hardly surprisingly the request fails. Note the null pointer in the logs for both /store/reserveStock and /store/stockLevel methods
Enable the @Fallback on the reserveStock method, now get an error description back, but it's not possible using 
this approach of calling a FallBack method to get the exception details and such like


Handling code exceptions
========================
Enable the @Fallback annotation on the StorefrontResource reserveStorkItems method
This calls a method on the handler class (look at the class if you like) which generates data, lots more info on what the
error cause was.
The class is in resource.fallbacn
Can define failure conditions, e.g. add @Timeout(value = 15, unit = ChronoUnit.SECONDS) to the StorefrontResource class, now
every REST call that does not finish in 15 will generate a timed out http response automatically
There are other options here, for example circuit breakers