![](../../../common/images/customer.logo2.png)

# Migration of Monolith to Cloud Native

## Using your own computer

These labs have been designed and the instructions written assuming you are using the virtual machine image we have provided, running in the Oracle Cloud Infrastructure. For the Kubernetes modules

If for what ever reason you do not want to use this prepared virtual machine image it is possible to run the labs using your own computer, but you will of course need to set it up, and of course you will need to adapt the instructions given to meet your own environment.

### What you will need installed and configured

#### For the Helidon labs

Java JDK 11 or higher

Maven 3.6.3 or higher

Eclipse Summer 2020 or a later compatible version

curl command (Standard with Linux and MacOS)

bash shell (Standard with Linux and MacOS)

docker engine

git

helm 3

You must also add these entries to your hosts file as aliases for localhost `zipkin storefront stockmanager`

#### Databases

The JPA config is setup for using an Oracle Autonomous database running in the Oracle Cloud. You can change this, for example to use a local MySQL instance, but you will need to update the persistence.xml file and the pom.xml to reflect the appropriate database drivers. When setting up the database connection parameters you will need to replace the ones we suggest with ones appropriate to your database.

Oracle Autonomous Database uses a wallet file which contains the credentials to access the database, you will need to setup and configure whatever the equivalent is for the database you are using.

#### Docker labs

You will need to replace the docker logins with logins for the docker repository you are using, or if you are going to run Kubernetes locally you can just use your local docker images store

#### Kubernetes modules

The Kubernetes lab modules will **currently** (as of Sept 2020) run on a Kubernetes 1.17.9 cluster, however you will have to set that up, and configure kubectl. Be aware that as Kubernetes evolves and introduces additional features that we are adding more lab modules to demonstrate them, so you are **strongly** recommended to look at the version of Kubernetes specified in the [create kubernetes cluster](./create-kubernetes-cluster.md) module and ensure you are running that version or later.

Be warned that sometimes Kubernetes and helm chart versions become incompatible. The versions of the helm charts we specify in the instructions should work with the version of Kubernetes in the lab, but if you are using a later version of Kubernetes you may have to switch to a later helm chart version, as sometimes there are incompatible changes in the helm charts or Kubernetes.