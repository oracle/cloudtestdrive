# Introduction

## About this Workshop

This lab shows you how to deploy and run an Oracle Database inside a Kubernetes cluster, using the Oracle Database Kubernetes Operator (the "operator").  

See the [Oracle Database Operator for Kubernetes](https://github.com/oracle/oracle-database-operator) documentation for more details on the other deployment options the Operator offers (for example running an Autonomous database, or running an on-premise PDB on a CDB)

In this lab we'll be using 2 types of persistant storage : 

- a dynamic Block Volume, that will be deleted automatically once the database is deleted, 
- a static NFS filesystem, which allows to have automatic failover between nodes of the kubernetes cluster.



### Objectives

* Set up an Oracle Kubernetes Engine instance on the Oracle Cloud Infrastructure
* Install the Database Kubernetes Operator
* Configure and launch a Database instance on Kubernetes, using a a Dynamic Block Volume
* Connect to the database and delete the instance
* Create an NFS shared filesystem
* Configure and launch a database with multiple Pods using the filesystem
* Validate node failover by stopping the node on which the DB is initially running
* Destroy the environments



### Prerequisites

Access to an Oracle Cloud account



## Learn More

* [WebLogic Kubernetes Operator Documentation](https://github.com/oracle/oracle-database-operator)

## Acknowledgements
* **Author** - Jan Leemans, July 2022
* **Last Updated By/Date** - n.a.
