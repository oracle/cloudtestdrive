[Go to Overview Page](../README.md)

![](../../../common/images/customer.logo2.png)

# Migration of Cloud Native - Coherence and gRPC

STANDALONE SETUP

If doing standalone need to do the full setup (Import image, create compartment, ATP, + K8S cluster, setup VM, import eclipse etc. Don't need to import the Helidon projects though. Then need to import the coherence cn project and do the lombok setup. Maybe just cover that with doing the full import ? Maybe just do a small test project for setting up Lombok ?

Run script to updates hosts or add to hosts in image ?

AS PART OF CN LAB SETUP

Just import the git repo

Run script to updates hosts or add to hosts in image ?


### Development

Setup the REST server code adding the REST annotations to helidon-labs-coherence-charge-common project, in the 

com.oracle.labs.helidon.coherence.charge.common.resources.CoherenceChargeRESTResource.java fiule
To the class 
@Path("/charge")
@Authenticated
@ApplicationScoped

to the updateCharge method add 
	@PUT
	@Produces(MediaType.APPLICATION_JSON)
	@Consumes(MediaType.APPLICATION_JSON)
	@Operation(summary = "Updates a users charges", description = "Updates the cost charges for a specific user")
	
to the updateCharges method billingCost arg add

@RequestBody(description = "The details of the billing entry", required = true, content = @Content(schema = @Schema(implementation = BillingCost.class, example = "{\"user\" : \"Fred\", \"charge\" : 0.5}")))

Interface now looks like
@Path("/charge")
@Authenticated
@ApplicationScoped
public interface CoherenceChargeRESTResource {
	@PUT
	@Produces(MediaType.APPLICATION_JSON)
	@Consumes(MediaType.APPLICATION_JSON)
	@Operation(summary = "Updates a users charges", description = "Updates the cost charges for a specific user")
	public BillingCost updateCharges(
			@RequestBody(description = "The details of the billing entry", required = true, content = @Content(schema = @Schema(implementation = BillingCost.class, example = "{\"user\" : \"Fred\", \"charge\" : 0.5}"))) BillingCost billingCost);
}

If you have done the main Helidon lab you will recongise these, but in summary they create a REST endpoint on /charge

These will be inherited by the implementation, but need to build and add this to the maven repo
click the project. The do Run As -> Maven install to create a jar file and add to the maven repo where it can be used later.

in the helicon-labs-coherence-charge-server project let's test the REST endpoint

run the com.oracle.labs.helidon.coherence.charge.server.Main class

Put some test data in there

curl -i -u jack:password -d "{\"user\" : \"Fred\", \"charge\" : 2.0}" -H "Content-Type: application/json" -X PUT http://localhost:8082/charge
HTTP/1.1 200 OK
Content-Type: application/json
Date: Tue, 20 Oct 2020 17:39:53 +0100
connection: keep-alive
content-length: 28

{"charge":2.0,"user":"Fred"}

The returned data is the current info (after processing the charge) for the user. 

curl -i -u jack:password -d "{\"user\" : \"Fred\", \"charge\" : 0.5}" -H "Content-Type: application/json" -X PUT http://localhost:8082/charge
HTTP/1.1 200 OK
Content-Type: application/json
Date: Tue, 20 Oct 2020 17:40:09 +0100
connection: keep-alive
content-length: 28

{"charge":2.5,"user":"Fred"}

We can see that it remembers the value we added and increments on the 2nd request, but this just uses a Java hashmap, so it's not persistent


Now need to tell our code to use a Coherence cache - this is easy.
In the pom.xml file we've already told Maven to bring in the coherence resources (coherence CDI, metrics and Eclipse MP config) 

com.oracle.labs.helidon.coherence.charge.server.resources.CoheranceChargeRESRResourceImpl.java class - this is what actually respond to the incoming REST requests

find line private Map<String, Double> billingInfo = new HashMap<>() ;


Add annotations @Inject and @Name as below, remove the initialiser `new HashMap<>() ;` 
@Inject
	@Name("Charges") // The name of the Map to setup.
	private Map<String, Double> billingInfo;
As usual with Helidon @Inject tells the framework to automatically create the requested object type, @Name tells Helidon to create a choerence maps called Charges, bu nakign the map we can easily find it in other microservcies.
	
Now coherence will automatically create the map for us.

Stop the service and run it again, can see it now does a bunch of coherence stuff

re-do the curls to confirm it adds them.

Leave the charge server running.

While we can add stuff to the cache we're not actually doing much with it in terms of reporting, let's look at another microservice that retrieves data from the cache for us.

Look at the helidon-labs-coherence-report-common project. Note that it has a interface class
com.oracle.labs.helidon.coherence.report.common.resources.CoherenceReportRESTResource

If you look at this you'll see it has a similar set of annotations to those in the charging server class, we've already looked at these once, so no need to add them again, the only thing to look at here is that it's on the path /report and there are two API endpoints under that /count and /data.

Again we need to do a maven install on this, so select the project, click right to Run As to Maven install

The reporting server is in the helidon-labs-copherence-report-server projects

Look at the com.oracle.labs.helidon.coherence.report.server.resources.CoherenceReportRESTResourceImpl.java class

Note that is also has the same annotations on the billingInfo map. These are the same as the charge server implementation.

Let's run the reporting service

Click right on the com.oracle.labs.helidon.coherence.report.common.Main and chose Run As, then Java Application.

once it's ready go to 

curl -i -u jack:password  http://localhost:8083/report/data
HTTP/1.1 200 OK
Content-Type: application/json
Date: Tue, 20 Oct 2020 20:36:08 +0100
connection: keep-alive
content-length: 12

{"Fred":2.5}

OK, so  the data in there is what we got from the last charge against Fred, but how did that get into a completely different microservice ?

Well that's because Coherence provides a **distributed** cache, the data is in this case replicated to both the charge and report servers. If we had multiple instances then the data would be spread between them, but always maintaining additional copies for redundancy, so if one of the microservices fails the data is not lost.

Problem with data being in the microservices - using standalone coherence nodes and disabling local storage

Now putting it in front of a database

Note we could have got the increment to be processed in the coherence cache rather than us implementing it in the microservcies, but this way it's a little clearer, and the goal of this lab is to introduce coherence, not to cover every possible thing it can do. Actually the entire set of functionality could be implemented by using the REST or gRPC interfaces built into Coherence CE itself, removing the need for the reporting micropservice entirely.