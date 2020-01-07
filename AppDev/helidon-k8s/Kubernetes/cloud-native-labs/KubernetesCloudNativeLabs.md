[Go to Overview Page](../README.md)

![](../../../../common/images/customer.logo2.png)

# Migration of Monolith to Cloud Native

## D. Cloud Native with Kubernetes


### 1. Is it running, and what to do if it isn't
Kubernetes doesn't just provide a platform to run containers in, it also provides a base for many other things including a comprehensive service availability framework which handles monitoring containers and services to see if they are still running, are still alive and are capable of responding to requests.

Fo understand how this works see the [Health Readiness Liveness labs.](Health-readiness-liveness/Health-liveness-readiness.md)

### 2. Horizontal Scaling
Kubernetes also supports horizontal scaling of services, enabling multiple instances of a service to run with the load being shared amongst all of them.

[The Replica set labs](Horizontal-scaling/Horizontal-scaling.md) 

### 3. Rolling out deployment updates
Commonly when a service is deployed it will be updated, Kubernetes provides support for performing rolling upgrades, ensuring that the service continues running during the upgrade. Built into this are easy ways to reverse a deployment roll out to one of it's previous states.

[Rolling updates labs](Rolling-updates/Rolling-updates.md)


### 4. Sections still to be written in Kubernetes cloud native
The following sections have not yet been written, they will be added in time.

#### Horizontal Autoscaling
Sadly the automatic horizontal scaling capability which would automatically adjust the number of instances of a pod based on it's load seems to currently be unavailable as one of the services it depended on (Heapster) is no longer available in Kubernetes. Once a solution for that is available it will be documented here.

#### Automatic CI/CD and Kubenetes

To be completed.

#### Automatic A/B testing

To be completed.

#### Services Meshes.
The service mesh is one of the latest ideas to come out of the cloud native forum.
To be completed

## End of this tutorial

Congratulations, you have reached the end of the tutorial !  You are now ready to start refactoring your own applications with the techniques you learned during this session !



------

[Go to Overview Page](../../README.md)