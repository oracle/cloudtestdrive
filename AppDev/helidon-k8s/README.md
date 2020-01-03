# Migration of Monolith to Cloud Native labs - Master document flow

This is the project for the Migration of a Monolith (well actually quite a simple "Monolith" web app that provides a REST API and a basic database service) into a web service comprised of two microservices using the Helidon framework. The microservcies are then extended to provide monitoring capabilities such as metrics and tracing, then to prepare them for cloud native capabilities such as health checks, automatic service restart etc.

The next part of the lab goes through the process of packaging those services up into Docker and externalizing configuration such as the database connection details and pushing to a docker repository.

Then we look at how to run the docker containers in Kubernetes, examining how to setup a Kubernetes cluster with basic capabilities, then creating a basic deployment of the services behind an Ingress controller. The labs then examine how to make use of cloud native capabilities in Kuberneties suck as horizontal scaling and using the support in Helidon for things like service liveness, readiness and how those combine to enable continuous service delivery using rolling upgrades. 

Finally (for now) we look at monitoring and graphing to extract data on how the system operates.

In the future the labs will include sections on auto-scaling and the use of a Service Mesh, and other Kuberneties based cloud native capabilities such as A/B testing of new releases etc.

# Helidon labs
The Helidon part of the labs show how to Split the Monolith into microservices using Helidon REST, to access data and to extend the microservices to suppport cloud native capabilities

To do these labs you must be familiar with Java at a basic lavel (able to understand classes, constructors, methods etc.) and a bit familiar with the Eclipse IDE

# Using Docker
The Docker part of the labs covers how we use JIB to create a docker image, run it, then to move the configuration and secrets externally to the docker image, finally we look at how to push the docker image to a repository

[The Labs](Docker/DockerLabs.md)

# Deploying in Kubernetes
These labs cover how to deploy our docker continers in Kubernetes and how to make use of the cloud native capabilities of Kuberneties.

[The Labs](Kubernetes/Kubernetes-labs.md)

# Cloud Native functionality
Finally we look at how to make use of the cloud capabilities within Kuberneties, this includes capabilities such as Health checks on pods and services, performing rolling upgrades and monitoring and graphing using Prometheus and Grafana, 


[The Labs](Kubernetes/KubernetiesCloudNativeLabs.md)