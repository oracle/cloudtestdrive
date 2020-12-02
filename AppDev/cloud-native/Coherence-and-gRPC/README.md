[Go to Overview Page](../README.md)

![](../../../common/images/customer.logo2.png)

# Migration of Cloud Native - Coherence and gRPC

STANDALONE SETUP

If doing standalone need to do the full setup (Import image, create compartment, ATP, + K8S cluster, setup VM, import eclipse etc. Don't need to import the Helidon projects though. Then need to import the coherence cn project and do the lombok setup. Maybe just cover that with doing the full import ? Maybe just do a small test project for setting up Lombok ?

Run script to updates hosts or add to hosts in image ?

AS PART OF CN LAB SETUP

Just import the git repo

Run script to updates hosts or add to hosts in image ?


[Using coherence with microservices](Coherence-and-microservices.md)

Optional section on using gRPC - need to have done the charge server part of the coherence and microservices section first

gRPC is a more efficient way of transfering requests than using REST, which can have quite a large overhead setting up the connection and sending / receiving the data. However the data format used by gRPC is ovten a binary format, which can make it hard to test and see what's going on.

[gRPC Enabling the microservice](gRPC-enabling-the-charge-server.md)