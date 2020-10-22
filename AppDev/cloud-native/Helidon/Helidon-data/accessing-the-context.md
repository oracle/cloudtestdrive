[Go to Helidon for Cloud Native Page](../Helidon-labs.md)

![](../../../../common/images/customer.logo2.png)

# Accessing the context of the request

Sometimes you need to understand what's going on  within a request, for example to generate an audit record you may want to get the users identity (validated of course) so you can record who did what.

In the case of our simple little micro service we're not "billing" back to departments, but lets see how we can get the users information from the request. We'll also discover what over information is available.

## Accessing the context

Strictly speaking this is not part of Helidon, but part of the larger Java EE spec, but it's a useful thing to do and works with Helidon.

We will be working in the helidon-stockmanager project and modifying the com.oracle.labs.helidon.stockmanager.resources.StockResource class, adding annotations to the createStockLevel, adjustStockLevel and deleteStockItem methods and extracting the user identity.

## Available contexts

There are several different types of context that can be injected. Here we will be looking at the SecurityContext (easy access to the requests security information) but there are others, the most useful of which allows you access to the requests Http Headers. For a full list of the contexts that can be injected see the [J2EE Java Doc for @Context](https://docs.oracle.com/javaee/7/api/javax/ws/rs/core/Context.html)

## Injecting the context

As you might expect we use dependency injection to automatically add the context to method call. Let's add it to the createStockLevel method

- Open the com.oracle.labs.helidon.stockmanager.resources.StockResource class in the helidon-stockmanager project.

- add ` @Context SecurityContext securityContext` to the end of the createStockLevel method parameters.

The full method signature now looks like

```java
	public ItemDetails createStockLevel(@PathParam("itemName") String itemName,
			@PathParam("itemCount") Integer itemCount, @Context SecurityContext securityContext)
			throws ItemAlreadyExistsException {
```

<details><summary><b>Java Imports</b></summary>
<p>

You may need to add the following imports to the class

```java
import javax.ws.rs.core.Context;
import javax.ws.rs.core.SecurityContext;
```

---
</p></details>

When the method is called the a security context object for the current request is automatically added to the call.

There are multiple things we can do with the security context, but one of the most useful is to get the identity of the person making the REST API call. Of course if the authorization information is not available (say the REST API call did not provide the headers) then the returned value won't have any meaning (it will be null) but in this case we're requiring that the request be authenticated because we've placed an @Authenticated annotation on the class. 

In this case we're going to get the user name in the request. For this lab we're using the Basic Authentication scheme where the user name and password are in a header in the request itself, but this will work equally well for more advanced authentication schemes like OAUTH2 where a token is issued after an initial login process.

- In the createStockLevel method update the setting of the user String so it's now set to `securityContext.getUserPrincipal().getName()`

The full line is :

```java
	String user = securityContext.getUserPrincipal().getName();
```

This value is used later in the method to generate audit record information (you'll see a call to the `writeCreateCall` method that uses `user`) though that's pretty standard Java code so we're not going to explain it, but do feel free to look at it if you like.

If you save the file, then stop and restart the StockManager, then try adding a new item

  - `curl -i -X PUT -u jack:password http://localhost:8081/stocklevel/Pie/3142`
  
There is a REST endpoint that let's us get the most recent audit records

- Run the following command 
  - `curl -i -X GET -u jack:password http://localhost:8081/stocklevel/audit`
  
```json
HTTP/1.1 200 OK
Content-Type: application/json
Date: Wed, 1 Apr 2020 15:55:38 +0100
connection: keep-alive
content-length: 1832

[{"departmentName":"My Shop","itemCount":3142,"itemName":"Pie","operationId":9,"operationTs":"2020-04-01T14:55:28.844Z[UTC]","operationType":"CREATE","operationUser":"jack","succeded":true},
{"departmentName":"My Shop","itemCount":150,"itemName":"Pencil","operationId":8,"operationTs":"2020-04-01T14:54:02.071Z[UTC]","operationType":"UPDATE","operationUser":"Unknown","succeded":true},
{"departmentName":"My Shop","itemName":"pins","operationId":7,"operationTs":"2020-04-01T14:53:53.054Z[UTC]","operationType":"DELETE","operationUser":"Unknown","succeded":true},
{"departmentName":"My Shop","errorMessage":"Item StockId(departmentName=My Shop, itemName=Book) already exists, can't create it again",
		"itemCount":50,"itemName":"Book","operationId":6,"operationTs":"2020-04-01T14:53:32.652Z[UTC]","operationType":"CREATE","operationUser":"Unknown","succeded":false},
{"departmentName":"My Shop","itemCount":100,"itemName":"Book","operationId":4,"operationTs":"2020-04-01T14:53:25.007Z[UTC]","operationType":"CREATE","operationUser":"Unknown","succeded":true},
{"departmentName":"My Shop","itemCount":50,"itemName":"Eraser","operationId":4,"operationTs":"2020-04-01T14:53:18.365Z[UTC]","operationType":"CREATE","operationUser":"Unknown","succeded":true},
{"departmentName":"My Shop","itemCount":200,"itemName":"Pencil","operationId":3,"operationTs":"2020-04-01T14:53:10.733Z[UTC]","operationType":"CREATE","operationUser":"Unknown","succeded":true},
{"departmentName":"My Shop","itemCount":5000,"itemName":"pins","operationId":2,"operationTs":"2020-04-01T14:52:48.024Z[UTC]","operationType":"CREATE","operationUser":"Unknown","succeded":true},
{"departmentName":"My Shop","itemCount":5000,"itemName":"pin","operationId":1,"operationTs":"2020-04-01T14:52:39.336Z[UTC]","operationType":"CREATE","operationUser":"Unknown","succeded":true}]
```

The example output above will of course vary from the output you get (and I've formated it a bit), but it shows that for the last operation we have extracted the users name for the audit record.

To be complete update the adjustStockLevel and deleteStockItem methods in the same way, their updated method signatures and initial lines of code are below

```java
	public ItemDetails adjustStockLevel(@PathParam("itemName") String itemName,
			@PathParam("itemCount") Integer itemCount, @Context SecurityContext securityContext)
			throws UnknownItemException {
		String user = securityContext.getUserPrincipal().getName();
```


```java
	public ItemDetails deleteStockItem(@PathParam("itemName") String itemName, @Context SecurityContext securityContext)
			throws UnknownItemException {
		String user = securityContext.getUserPrincipal().getName();

```

- Save the StockResource 

- Stop and restart the stock manager
  
## Other information available
The security context can be used to find out if a user is in a role, and what form of authentication is in place. You can also use it to find out if the request came over a secure (https) connection, but a little note of warning there. In many micro-servcies deployments you may do the https termination elsewhere in the framework (for example in a Kubernetes Ingress controller) which may result in being told the connection is not secure, when in fact the connection to the framework itself is secure.


## Supporting methods

There are already methods in the StockResource class which deal with retrieving (getAuditRecords) and writing the audit records (writeAuditRecord and the helper methods writeCreateRecord, writeUpdateRecord and writeDeleteRecord) These methods work in basically the same way as the other stock item methods so we're don't need to  review them.

## Transactional implications

The entire StockResource class is covered by the @Transational annotation. This means that as we update the database with the stock changes in the transaction the same transaction will also cover the creating of the audit records. Thus both the stock level and the associated audit record will succeed or fail together. Admittedly here we are using the same database, but this would also apply if the audit records were being written to a completely different database.
