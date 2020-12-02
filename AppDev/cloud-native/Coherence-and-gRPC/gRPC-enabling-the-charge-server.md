[Go to Overview Page](../README.md)

![](../../../common/images/customer.logo2.png)

# Migration of Cloud Native - Coherence and gRPC

You need to have setup the charge server in the coherence module.

Unlike REST services the gRPC server does not inherit attributes from the interface (though the gRPC does generate clients for you using the interface.)

Usually with gRPC you have to implement protocol buffers to act as a representation of the server (in the client) and to transfer and receive the data and responses. Unlike REST gRPC makes it easier to send a stream of requests or responses (or both)

Both have their place, and both can support multiple languages.

