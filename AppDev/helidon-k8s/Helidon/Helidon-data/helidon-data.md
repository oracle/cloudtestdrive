[Go to Helidon for Cloud Native Page](../Helidon-labs.md)

![](../../../../common/images/customer.logo2.png)

# Migration of Monolith to Cloud Native

## A. Helidon for Cloud Native

## 2. Helidon and Databases

Unlike SPRING with the SPRINGData projects microprofile (and thus Helidon) to not currently have a built in mechanism for accessing databases. This is however something that is being looked at and hopefully at some point there will be a Microprofile standard for accessing data which Helidon can implement. At that point these labs will be updated to reflect the changes.

However, just because Microprofile and thus Helidon do not have a set of data access annotations and abstractions themselves does not mean you can't access databases (and other persistence solutions) from with Helidon microservcies. You simply use the existing technologies such as the Java Persistence API (JPA) and the JTA (Java Transaction API)

In this set of lab modules we will look at how we can combine those with Helidon techniques such as the configuration mechanisms to implement database accesses.

For the labs we will be using the Oracle Autonomous Transaction Processing database running in the Oracle Cloud, and have already installed in the client VM maven repository the required OJDBC jar files to support this. We have also down loaded into the environment the "Wallet" file for the database which defines the database configuration, access information and such like.

We are using the Hibernate implementation of the JPA standard to actually do the work of accessing the database. 

If you wanted to change the database instance or the JPA implementation in a deployment it's simply the case of getting the right driver classes and updating the configuration to use them.

As mentioned in the helidon core labs we are only looking at the programming aspects here. We do not cover the Maven pom.xml file. If you want to use this code as a starting point for your own projects then we strongly recommend looking at the pom.xml file so you can see what dependencies are made available to the projects.

**What's in the lab**
We will be looking at the helidon-labs-stockmanager project. This set of classes operate on the database and provides Create Read, Update, Delete (CRUD) functionality for the database front end, specifically modifying the database tables. It will be called by the storefront.

**What's not in this lab**
This lab does not attempt to go into all of the detail or JPA and JTA, the goal is to see how they can be handled in a Helidon based microservice. Because of that the lab does not go into great about how those Java API's operate. 

If you want to understand JPA and JTA in a lot of detail there are courses available, and of course lots of books on the subject

### Configuring the project to be personal to you
For this project all attendees will be operating on a shared database, updating the same table. To ensure that your work doesn't interfere with other peoples work you need to provide a unique identity for yourself

In the helidon-labs-stockmanager project conf/stockmanager-config.xml file add a property department with be **your** your name, initials or something that's going to be unique. I changed mine to be `timg` but **YOURS MUST BE DIFFERENT FROM MINE AND EVEYONE ELSES.** We suggest you write your chosen name on a board so other folks will know what's already been taken !

Example of the conf/stockmanager-config.xml updated with **my** name as the department, remember to use **your** chosen name **not mine !**

```
app:
  persistenceUnit: "HelidonATPJTA"
  department: "timg"
```

The way this operates is that the StockResource will automatically and transparently add the department to the primary key in all requests, this is not something you're likely to do in production, but here as we're focusing on the coding rather than starting up multiple databases it makes the lab go faster.

### What's the difference from the storefront labs ?
This set of labs sections concentrates on the data accesses. You are assumed to be familiar with things like @POST, @ApplicationScope, loading configurations and such like.

There is less coding than the helidon core lab and more reading here.

This lab also uses exactly the same security configuration so users jack, jill and joe are provided, with password password, and user jack is an admin as before.

I'm also assuming that you'll remember how to stop and start the Main class (though of course for **this** lab you'll be using the com.oracle.labs.helidon.stockmanager.MAIN class, not the storefront version) so you won't be reminded on that.

---

**Before you start**
Please makes sure that for now you have **stopped** the storefront application.

---




### Quick overview of the database functionality
The com.oracle.labs.helidon.stockmanager.resources.StockmanagerResource class is the primary class we'll be working with in this lab. If you're not familar with JPA however there are some other classes you should look at.

The classes in the com.oracle.labs.helidon.stockmanager.database package represent the actual structure of the database. In the database configuration we tell the JPA, JTA layers these are the classes we want the database to represent. You'll see that they have some annotations on them, some of which will be familiar. Let's look at the StockLevel class first:

```
@Data
// setup the constructors for us
@NoArgsConstructor
@AllArgsConstructor
// Tell JPA This is something that we want to save, hibernate will do a bunch of stuff for 
// us on this basis, including creating the required tables (assuming we've setup it's 
// properties file correctly
@Entity
@Table(name = "StockLevel")
public class StockLevel {
	@EmbeddedId
	private StockId stockId;

	@Column(name = "itemCount")
	private int itemCount;
}
```

`@Data`, `@NoArgsConstructor` and `@AllArgsConstructor` are Lombok annotations that tell Lombok to automatically create the constructors,getters and setters, toString, equals and hashcode. We could of course do this manually or use tooling in the IDE to generate them, but using Lombok means that the source code is less cluttered and also that if we change the class (say by adding new fields) all of the related methods and constructors update automatically.

The other annotations are used by Java persistence to identify what the classes are :

At the class level
`@Entity` means that this is something that JPA can save into the database as a database row (rather than something that's embedded in a row)

`@Table` specifies the table name to use, a default will be generated based on the class name, but it's nicer to know exactly what we're getting

On our fields in the class

`@EmbeddedId` means that the primary key is this object, because it's embedded the actual primary key can have multiple columns

`@Column` defines the details of the column name, again it can be generated automatically, but this will force a specific name.

Looking at the StockId class

```
@Embeddable
@Data
@AllArgsConstructor
@NoArgsConstructor
public class StockId implements Serializable {
	private static final long serialVersionUID = 4014326887605314630L;
	@Column(name = "departmentName")
	private String departmentName;
	@Column(name = "itemName")
	private String itemName;
}
```
The Lombok annotations are the same

The class level `@Embeddable` means that JPA treats thsi class as part of an Entity (so a DB row in this case) which means JPA will construct the primary key using the fields in this class

As with the StockLevel we're choosing our own column names using `@Column` rather than letting the system chose them for us.

The Java Persistence system at runtime looks for these annotations and will automatically setup the database mappings based on them. The actual JPA implementation that's being used here is hibernate, it's an open source project, and it will not only handle the database interactions for us, but could if if we wanted it to create the database tables on our behalf (this is controlled by the hibernate.hbm2ddl.auto setting in the persistence.xml file, at the moment it will jst check that the database schema matches what our entities require.)

The entity manager represents the connection to the JPA system, it can be used to locate existing object and create new ones (see the StockResource.createStockLevel method) It can merge updates to existing data (see the StockResource.adjustStockLevel method) and delete objects in the database (see the StockResource.deleteStockItem method.)

For this lab we've got a little bit of logic around those entity manager functions to act as s starting point to let us provide REST CRUD APIs.

It is important to note that each item retrieved from or saved to the database using the entity manager is almost certainly a different instance of the object. Even if you save an object then look at the returned object that has "just been saved" ! So retrieving the same object twice is two separate objects, which contain the same data, not two references to the same object. This means that you need to think carefully if you're going to implement comparisons or equality (hence the benefits of Lombok generating this type of code automatically for us)

**Configuring the database**
Initially the database is setup to use the JPA / JTA (transaction system) to load in the configuration. The database settings are defined in the confsecure/stockmanager-database.yaml file and in the src/main/resources/META-INF/persistence.xml file. The latter is automatically read by the JPA and the config is processed using the Helidon configuration system and handed to the Java Persistence layers.

The split between the files is more one of the stockmanager-database.yaml file contains things that are specific to a database instance, e.g. usernames, passwords, JDBC Urls. Wheras the persietence.xml file defines stuff that's not instance specific but is project specific, for example which classes are persisted.

### Using path parameters for methods
In the Storefront object we were processing Java objects directly as out method arguments (the helidon framework was converting them to / from JSON for us) 

For the StockmanagerResource (really I did this just to show it's possible) we are using @PathParams. a path param is basically part of the URL that can contain data, for example a GET method with a `@Path("/stocklevel/{item}")` when called with /stockLevel/Pencil would extract the Pencil and make it available as the PathParam "item"

Let's look at the StockResource.createStockLevel method to see how this works (I've removed a bunch of other text here for clarity)

```
@Path("/{itemName}/{itemCount}")
	@PUT
	@Produces(MediaType.APPLICATION_JSON)
	public ItemDetails createStockLevel(@PathParam("itemName") String itemName,
			@PathParam("itemCount") Integer itemCount) throws ItemAlreadyExistsException {
```

The `@Path("/{itemName}/{itemCount}")` makes two params called itemName and itemCount available. Then in the method signature the `@PathParam("itemName")` binds whatever was in the itemName path param to the itemName parameter, and the same for the itemCount.

Helidon does sanity checks here, it the itemCount wasn't a String verion of an integer then the caller would get an error message back before the method was called.

Here (to make it clear whatn's happening) I've used the same name for the path and method param, but that's not required.

Other possible sources for the params are @QueryParam and @FormsParam. Which one you chose will depend on what the URL you are expecting (or want) to get.

### Getting an entity manager
JPA requires an entity manager to do the work of interacting with the database for us. Historically however that would require code like the following which is in the Stockmanager constructor.

```
	public StockResource(@ConfigProperty(name = "app.persistenceUnit") String persistenceUnitProvided,
			DepartmentProvider departmentProviderProvided) {
		persistenceUnit = persistenceUnitProvided;
		EntityManagerFactory emfactory = Persistence.createEntityManagerFactory(persistenceUnit);
		this.entityManager = emfactory.createEntityManager();
		departmentProvider = departmentProviderProvided;
	}
```

There are a several problems here. Firstly, we do this each time we create a new instance of the StockResource, and that happens every time we get a request. That's a potentially expensive set of method calls.

Secondly we have to close the entity manager down when it's no longer needed, that can result in some complex code paths to follow, especially if there are exceptions being handled as well.

Also why write code when we don't have to ? With Helidon we have the context and dependency injections capabilities, so we don't however need to setup the entity manager itself, we can have Helidon do that for us

In the StockManager constructor remove the lines that setup the entity manager, it should now look like

```
	public StockResource(@ConfigProperty(name = "app.persistenceUnit") String persistenceUnitProvided,
			DepartmentProvider departmentProviderProvided) {
		persistenceUnit = persistenceUnitProvided;
		departmentProvider = departmentProviderProvided;
	}
```
(we're just saving the params away for later use)

Locate where the EntityManager is defined and add a `@PersistenceContext(unitName = "HelidonATPJTA")`

```
	@PersistenceContext(unitName = "HelidonATPJTA")
	private EntityManager entityManager; 
```

Note that the name of the persistence context is defined as a hard coded String, and there is no mechanism for it to be injected via a config property. However, this is not as restrictive as it seems as the name just refers to entries in the persistence.xml file, so if we do want to change the database details we can achieve that by modifying the config, and that can be done without source code modifications.

Using Helidon to create our PersistenceContext will also ensure that the entity manager is correctly shutdown when the program exits so we won't have any resources hanging around in the database.


Run the com.oracle.labs.helidon.stockmanager.Main class. 

If it fails to run like this

```
2020.01.05 18:26:18 INFO org.jboss.weld.Version Thread[main,5,main]: WELD-000900: 3.1.1 (Final)
2020.01.05 18:26:19 INFO org.jboss.weld.Bootstrap Thread[main,5,main]: WELD-ENV-000020: Using jandex for bean discovery
2020.01.05 18:26:19 INFO org.jboss.weld.Event Thread[main,5,main]: WELD-000411: Observer method [BackedAnnotatedMethod] public org.glassfish.jersey.ext.cdi1x.internal.ProcessAllAnnotatedTypes.processAnnotatedType(@Observes ProcessAnnotatedType<?>, BeanManager) receives events for all annotated types. Consider restricting events using @WithAnnotations or a generic type with bounds.
2020.01.05 18:26:19 INFO org.jboss.weld.Event Thread[main,5,main]: WELD-000411: Observer method [BackedAnnotatedMethod] private io.helidon.microprofile.openapi.IndexBuilder.processAnnotatedType(@Observes ProcessAnnotatedType<X>) receives events for all annotated types. Consider restricting events using @WithAnnotations or a generic type with bounds.
Exception in thread "main" org.jboss.weld.exceptions.DeploymentException: Requested value for configuration key 'app.department' is not present in the configuration.
	at org.jboss.weld.bootstrap.events.AbstractDeploymentContainerEvent.fire(AbstractDeploymentContainerEvent.java:38)
	at org.jboss.weld.bootstrap.events.AfterDeploymentValidationImpl.fire(AfterDeploymentValidationImpl.java:28)
	at org.jboss.weld.bootstrap.WeldStartup.validateBeans(WeldStartup.java:505)
```

You haven't setup the stockmanager-config.yaml file with the department value. Go do that, restart the program and try again.

Assuming you've got that bit right and you get the server started messages and urls like the following

```
2020.01.05 18:30:33 INFO io.helidon.microprofile.server.ServerImpl Thread[nioEventLoopGroup-2-1,10,main]: Server started on http://localhost:8081 (and all other host addresses) in 69 milliseconds.
2020.01.05 18:30:33 INFO com.oracle.labs.helidon.stockmanager.Main Thread[main,5,main]: http://localhost:8081

```

Use curl to see what's there

```
$ curl -i -X GET -u jack:password http://localhost:8081/stocklevel
HTTP/1.1 200 OK
Content-Type: application/json
Date: Sun, 5 Jan 2020 18:54:06 GMT
connection: keep-alive
content-length: 2

[]
```

There should be **nothing** returned, if there is it means that you didn't chose a unique department value ! Chose something that is unique, update the stockmanager-config.yaml file department attribute and restart the program.

Let's create some stock items, these need to be done as a user with admin rights so do the following command. Note there is a few seconds delay when you try this as the code does the database connection on demand.

```
$ curl -i -X PUT -u jack:password http://localhost:8081/stocklevel/pins/5000
HTTP/1.1 500 Internal Server Error
Content-Length: 0
Date: Sun, 5 Jan 2020 18:54:43 GMT
connection: keep-alive
```

Opps, server error and no updated data back, should have got the item we just created

Look at the console tab and you will that the code generates an error

```

2020.01.05 18:54:43 INFO com.oracle.labs.helidon.stockmanager.resources.StockResource Thread[helidon-1,5,server]: Creating StockId(departmentName=timg, itemName=pins), with count 5000
2020.01.05 18:54:44 INFO org.hibernate.jpa.internal.util.LogHelper Thread[helidon-1,5,server]: HHH000204: Processing PersistenceUnitInfo [name: HelidonATPJTA]
2020.01.05 18:54:44 INFO org.hibernate.Version Thread[helidon-1,5,server]: HHH000412: Hibernate Core {5.4.9.Final}
2020.01.05 18:54:44 INFO org.hibernate.annotations.common.Version Thread[helidon-1,5,server]: HCANN000001: Hibernate Commons Annotations {5.1.0.Final}
2020.01.05 18:54:44 INFO com.zaxxer.hikari.HikariDataSource Thread[helidon-1,5,server]: HikariPool-1 - Starting...
2020.01.05 18:54:45 INFO com.zaxxer.hikari.HikariDataSource Thread[helidon-1,5,server]: HikariPool-1 - Start completed.
2020.01.05 18:54:45 INFO org.hibernate.dialect.Dialect Thread[helidon-1,5,server]: HHH000400: Using dialect: org.hibernate.dialect.Oracle10gDialect
2020.01.05 18:54:46 INFO org.hibernate.engine.transaction.jta.platform.internal.JtaPlatformInitiator Thread[helidon-1,5,server]: HHH000490: Using JtaPlatform implementation: [org.hibernate.engine.transaction.jta.platform.internal.JBossStandAloneJtaPlatform]
Hibernate: 
    select
        stocklevel0_.departmentName as departmentName1_0_0_,
        stocklevel0_.itemName as itemName2_0_0_,
        stocklevel0_.itemCount as itemCount3_0_0_ 
    from
        StockLevel stocklevel0_ 
    where
        stocklevel0_.departmentName=? 
        and stocklevel0_.itemName=?
2020.01.05 18:54:47 INFO com.oracle.labs.helidon.stockmanager.resources.StockResource Thread[helidon-1,5,server]: Creating StockLevel(stockId=StockId(departmentName=timg, itemName=pins), itemCount=5000)
javax.persistence.TransactionRequiredException
	at io.helidon.integrations.cdi.jpa.NonTransactionalEntityManager.persist(NonTransactionalEntityManager.java:92)
	at java.base/jdk.internal.reflect.NativeMethodAccessorImpl.invoke0(Native Method)
	at java.base/jdk.internal.reflect.NativeMethodAccessorImpl.invoke(NativeMethodAccessorImpl.java:62)
	at java.base/jdk.internal.reflect.DelegatingMethodAccessorImpl.invoke(DelegatingMethodAccessorImpl.java:43)
```

`TransactionRequiredException` sounds pretty serious, and it is, it's because we're trying to modify the database, and Helidon created entity management knows that 
this should be done in a transaction. Whenever you modify a database it's a pretty good rule of thumb that you need a transaction to keep things safa and consistent, even when the modification is a single row in a single database.

### Automatic Transactions
We could manually ask the entity manager to start and and transactions, but that's a load of extra code, and the possible paths if there are problems to do the rollback or commit are significant. Let's use the Java Transaction API (JTA) to do it for us.

Fortunately for us all we need is an @Transactional annotation and Heliton will trigger the JTA to do the right things.

Add the @Transactional annotation to the StockResource class.


```
@Path("/stocklevel")
@RequestScoped
@Log
@Transactional
public class StockResource {
```
This means that every operation in the class will be wrapped in a transaction automatically, If the method returns normally (so no exceptions thrown) then the transaction will be automatically committed, but if the transaction returned abnormally (e.g. an exception was thrown) then the transaction will be rolled back.

This will apply if there were multiple entity managers or database modification actions operating within the method. So if the method modifies data in several databases then they woudl all suceed of fail. This your database ACID (Atomic, Consistent, Isolated and Durable) semantics are maintained 



---

**Note on @Transaction and @Fallback**
In the current version of Helidon there is a conflict between the processing of @Transactional and @Fallback, if a class (or method) has the @Fallback annotation then the transaction will not be created, which causes all sorts of problems  Sadly at the moment there is no workaround, though the development team are working on a fix to, but it's expected (but not guaranteed) that the Helidon Data functionality (which is planned to make persistence a lot easier) will fix that problem.

---



### Creating some data and testing the stockmanager works
Use curl to create some stock items, these need to be done as a user with admin rights so do the following commands against a running 
stockmanager service 

curl -i -X PUT -u jack:password http://localhost:8081/stocklevel/pin/5000
curl -i -X PUT -u jack:password http://localhost:8081/stocklevel/pins/5000
curl -i -X PUT -u jack:password http://localhost:8081/stocklevel/Pencil/200
curl -i -X PUT -u jack:password http://localhost:8081/stocklevel/Eraser/50
curl -i -X PUT -u jack:password http://localhost:8081/stocklevel/Book/100
curl -i -X PUT -u jack:password http://localhost:8081/stocklevel/Book/50

```
$ curl -i -X PUT -u jack:password http://localhost:8081/stocklevel/pin/5000
HTTP/1.1 200 OK
Content-Type: application/json
Date: Sun, 5 Jan 2020 18:58:43 GMT
connection: keep-alive
content-length: 35

{"itemCount":5000,"itemName":"pin"}

$ curl -i -X PUT -u jack:password http://localhost:8081/stocklevel/pins/5000
HTTP/1.1 200 OK
Content-Type: application/json
Date: Sun, 5 Jan 2020 18:59:19 GMT
connection: keep-alive
content-length: 36

{"itemCount":5000,"itemName":"pins"}

$ curl -i -X PUT -u jack:password http://localhost:8081/stocklevel/Pencil/200
HTTP/1.1 200 OK
Content-Type: application/json
Date: Sun, 5 Jan 2020 18:59:23 GMT
connection: keep-alive
content-length: 37

{"itemCount":200,"itemName":"Pencil"}

$ curl -i -X PUT -u jack:password http://localhost:8081/stocklevel/Eraser/50
HTTP/1.1 200 OK
Content-Type: application/json
Date: Sun, 5 Jan 2020 18:59:29 GMT
connection: keep-alive
content-length: 36

{"itemCount":50,"itemName":"Eraser"}

$ curl -i -X PUT -u jack:password http://localhost:8081/stocklevel/Book/100
HTTP/1.1 200 OK
Content-Type: application/json
Date: Sun, 5 Jan 2020 18:59:35 GMT
connection: keep-alive
content-length: 35

{"itemCount":100,"itemName":"Book"}

$ curl -i -X PUT -u jack:password http://localhost:8081/stocklevel/Book/50
HTTP/1.1 500 Internal Server Error
Content-Length: 0
Date: Sun, 5 Jan 2020 18:59:39 GMT
connection: keep-alive
```

On success the return is the newly created object

Once the first operation has returned and the database connection is all setup the subsequent calls are much faster.

Note that on the 2nd attempt to add the window we don't get anything back representing the newly create object - it's already there, and the logs give us error messages
get an error, there are already items with that name present.

Use curl to get the current stock list

```
$ curl -i -X GET -u jack:password http://localhost:8081/stocklevel
HTTP/1.1 200 OK
Content-Type: application/json
Date: Sun, 5 Jan 2020 19:01:01 GMT
connection: keep-alive
content-length: 185

[{"itemCount":100,"itemName":"Book"},{"itemCount":50,"itemName":"Eraser"},{"itemCount":200,"itemName":"Pencil"},{"itemCount":5000,"itemName":"pin"},{"itemCount":5000,"itemName":"pins"}]
```

Note that we have "accidentally created two versions of the pin (pin and pins), let's remove one

Use curl to remove it

```
$ curl -i -X DELETE -u jack:password http://localhost:8081/stocklevel/pins
HTTP/1.1 200 OK
Content-Type: application/json
Date: Sun, 5 Jan 2020 19:01:38 GMT
connection: keep-alive
content-length: 36

{"itemCount":5000,"itemName":"pins"}
```
(The details of the deleted item are returned)

Now we will see it removed from the list.

```
$ curl -i -X GET -u jack:password http://localhost:8081/stocklevel
HTTP/1.1 200 OK
Content-Type: application/json
Date: Sun, 5 Jan 2020 19:02:07 GMT
connection: keep-alive
content-length: 148

[{"itemCount":100,"itemName":"Book"},{"itemCount":50,"itemName":"Eraser"},{"itemCount":200,"itemName":"Pencil"},{"itemCount":5000,"itemName":"pin"}]
```

Finally let's test changing the level of some stock, we had 200 Pencils, let's reduce that to 1500

```
$ curl -X POST  -u jack:password http://localhost:8081/stocklevel/Pencil/150
{"itemCount":150,"itemName":"Pencil"}
```

Finally get the stock list again

```
$ curl -i -X GET -u jack:password http://localhost:8081/stocklevel
HTTP/1.1 200 OK
Content-Type: application/json
Date: Sun, 5 Jan 2020 19:03:11 GMT
connection: keep-alive
content-length: 148

[{"itemCount":100,"itemName":"Book"},{"itemCount":50,"itemName":"Eraser"},{"itemCount":150,"itemName":"Pencil"},{"itemCount":5000,"itemName":"pin"}]
```

**Please leave the stockmanager running, we're going to use it in the next few labs**



### Summary
We haven't looked at JPA / JTA in much detail, but we've seen how the Helidon configuration system can be used to supply configuration data to the JPA and JTA as they are being setup.

We've seen how we can use the Helidon dependency injection system with the `@PersistenceContext` annotation to create and manage entity managers for us.

We've used the `@Transactional` annotation to make our entire class use JTA transactions

We've also seen how we can bring use @PathParam to provide us with a different way of gathering data from a REST request and passing it to our methods.



The next lab in the *Helidon for Cloud Native* section is 

**3. Communicating services with Helidon** : This lab shows the support in Helidon for switching from a direct method call to using a REST call without modifying the calling method.

[The cross service communication lab](../Helidon-to-Other-Microservices/helidon-to-other-microservices.md)







---



[Go to *Helidon for Cloud Native* overview Page](../Helidon-labs.md)
