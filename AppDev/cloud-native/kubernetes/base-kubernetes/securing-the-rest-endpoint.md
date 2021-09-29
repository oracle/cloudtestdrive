![](../../../../common/images/customer.logo2.png)

# Cloud Native - Securing the REST endpoint

## Introduction

This is an optional reading only module, there are no exercises to do.

**Estimated module duration** 5 mins.

### Objectives

This module looks at some of the 

### Prerequisites
You should have completed the **Setting up the cluster and getting your services running in Kubernetes** module.


## Should I secure my REST API ?

Stupid question! 

The answer is that of course you should. Even if the information you have is public and you are not charging for access to your service you should still protect it against malicious actors who want to use it as a way to break into your systems, or vandals who just to deny access to others.

## Securing the REST API

This module looks at **some** of the ways you can secure your REST API's. Just to be clear, this is not a complete list and there are other approaches not covered here, but I have attempted to cover the major approaches.

### What security approach to use ?

There is no right or wrong way to secure your REST API's the best solution is to do a team assessment of the risks you have. You need to to a team assessment because as individuals it's very easy to get wrapped up in your own specific security experiences and viewpoints and not look at other areas, for example my background is such that when writing this document I was focusing on TLS and authentication / authorization and had to be reminded about SQL injection attacks, even though they are quite common attack.

Below are some thoughts, but these need to be considered with professional advice and in the context of your specific situation.

### In your service itself

You can of course have your micro-service itself implement the end point termination and other security features. If you did the Helidon lab you will have seen how Helidon can implement authentication to limit who can access certain features of the micro-service.

You could of course implement a TLS end point in your application as well, but then you have to implement your own certificate management. By taking the encryption all the way to the micro-service you'd also be limiting what you can do in terms of a Layer 7 firewall where you use an external service to inspect your data, for example to rate limit for specific endpoints, or dynamically add capabilities such as SQL Injection protection.

Taking the encryption all the way to the micro-service does however reduce the chance that you will be subject to a attack by compromised network infrastructure (with modern clouds this is unlikely as the vendor can almost certainly do a better job at managing their infrastructure and detecting attacks than most end user organizations who will have a different focus).

Taking encryption to the service also means that you are responsible for ensuring that your service meets the latest patches and updates. It may be great to have the fine grained control, but with that comes the responsibility of monitoring the encryption libraries you've used for vulnerabilities and patching them to keep up to the latest versions. On that subject you should **never** write your own encryption unless you are an genuine expert, professionals are guaranteed to do a better job at that than you, and it's incredibly easily to make a mistake with encryption. 

### Using the Ingress controller

This is the approach we have taken in the labs, we use the ingress controller to perform the encryption of the https connections from outside the Kubernetes cluster, and then internal to the cluster pass the information on to the micro-service unencrypted (except in the ServiceMesh lab where the mesh provides point to point encryption between meshed services). The benefit of this is your service no longer needs to manage the encryption. If your application doesn't provide authentication capabilities you can even have the ingress controller implement a password capability for you - we show this later on in the optional lab modules where we use the ingress controller to implement a password layer on top of the otherwise unsecured Prometheus UI. 

### In the load Balancer

Load Balancers are generally in two types. 

The ones that operate on a TCP/IP connection don't look inside the contents of the packet, they just send the packet on to the specified destination and port. They block all other communication except that on the in-bound port they are configured to work on, so they are also an in-bound firewall restricting the traffic into your network. If you are terminating encryption in your ingress controller or load balancer you'll need to use this type, but there are some drawbacks to this, for example you won't the original client UP address header added to http requests if you do this.

The other type operates at the http / https level. These can perform operations such as terminating the SSL connection, potentially adding extra headers to the http request (for example with proxy information) and usually they can also then re-encrypt the http(s) traffic as it makes the onward connection to the micro-service if you want internal encryption. This type of load balancer may have dedicated hardware to perform functions such as encryption / decryption of data, and is likely to have better certificate management than you would implement in your own micro-service code.

The second type can provide an https connection externally but internally route the requests to your micro-service (usually via an ingress controller) so you don't need to implement the encryption in the ingress controller or micro-service.

Load balancers however are often not part of your Kubernetes environment, and often are offered as a distinct service from the micro-service environment and used by other services from your cloud provider. This means that they may well have their own certificate management approaches and not integrate into the Kubernetes based certificate systems.

For the Oracle load balancer there are some annotations you can apply when creating the service, these cover a number of possibilities that avoid manually configuring the load balancer, for example you can specify a Kubernetes secret to be used for the TLS certificate. [See the Load balancers section in the Oracle Kubernetes documentation](https://docs.cloud.oracle.com/en-us/iaas/Content/ContEng/Tasks/contengcreatingloadbalancer.htm#creatinglbhttps) for more details.

### With an API Gateway

Technologies such as an API gateway are applied (usually with their own load balancer) to examine the REST API Requests and to externally apply policy to those requests, this is done on the edge of your environment and prevents out of policy REST API calls even reaching your micro-service. For example an API Gateway would typically be configured with policies that ensure that the correct authentication details are applied to the connection, often also validating the supplied details are correct. Other typical functions are ensuring that the data is in the correct format, potentially applying checks against SQL Injection, and performing functions such as rate lmiting and API key management (for example limiting access only to applications form organizations that have been issued with an access key.

## Internal to the cluster data encryption

Most Kubernetes implementations can run a service mesh like Linkerd (other service mesh implementations are of course available). These can provide many capabilities, but they usually offer mechanisms whereby you can encrypt internal communications within the cluster.

If you are operating a distributed Kubernetes cluster where the microservices are spread around with physical separation  between the nodes, then this may be a good approach to ensuring that a wide area communications provider (or someone that's hacked into them) cannot access the data (though usually wide area links would have their own encryption applied to protect the actual connection).

## Certificate management

Managing certificates can be a pain, especially if you have short lived certificates. To make this easier you can use a tool that will automatically source, renew and manage certificates.

 **For certificates held in Kubernetes** there is a service called [CertManager](https://cert-manager.io/docs/) This service will source and maintain certificates for you, a typical use case may be to specify in the Ingress rule that a certificate is needed, along with information of the type of certificate, issuing authority etc. The certmanager will then get a certificate and place it in the appropriate Kubernetes secret. The certificate will then be used as if it was manually installed.
 
## Where to get security assistance.

This section has only covered at a simple level a few of the security options. Clearly in a sensitive commercial situation you will want to conduct a thorough security assessment of your risks, ensure you have not made any common security mistakes etc. Oracle (and I'm sure other vendors and consultants) has a security assessment service that can help with this. Oracle also has automated tools that can help you monitor your OCI environment for security problems.

## End of the module, what's next ?

The next module is the **Cloud native availability with Kubernetes** module

## Acknowledgements

* **Author** - Tim Graves, Cloud Native Solutions Architect, EMEA OCI Centre of Excellence
* **Contributor** - Jan Leemans, Director Business Development, EMEA Divisional Technology
* **Last Updated By** - Tim Graves, August 2021
