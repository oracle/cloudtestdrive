Lab sequence is either helidon -> docker -> kubernetes OR Just helidon (optionally with docker) OR just kubernetes. This document is focused on the just Kubernetes section


This document lists the things we need to document so people can do this standalone rather than as a follow on from the helidon / docker labs. There are other instructiosn they will need to do as well (e.g. get the DB Wallet into the cloud shell), but those are common to all forms of the lab.



1/ [Create the database and setup the database user] (../../ManualSetup/CreateATPDatabaseAndSetupUser.md)
This is optional, if a database has already been setup then you'll be given the name by your instructor. you just need the OCID - [follow these instructions to get the OCID of an existing database](../../ManualSetup/GetTheATPDatabaseDetailsForYourTenancy.md)

Remember to save the database OCID !

2/ [get the docker details for your tenancy](../../ManualSetup/GetDockerDetailsForYourTenancy.md)

3/ Docker login in to the Oracle Container Image Registry (OCIR)

We need to tell docker your username and password for the registry. 

You will have gathered the information needed in the previous step. You just need to execute the following command, of course you need to substitute the fields

`docker login <registry> --username=<tenancy name>/oracleidentitycloudservice/<user name> --password='<auth token>'

For example a completed version may look like this (this is only an example, use your own values)

`docker login fra.odir.io --username=cdtemeabdnse/oracleidentitycloudservice/my.email@you.server.com --password='q)u70[]eUkM1u}zu;:[L'`

Enter the command with **your** details into the Oracle Cloud Shell to login to the OCIR.

4/ Get the sample docker images into your registry


===================
Should I write a script to do this ???
===================

Sequence on the docker images setup
1/ Get current user auth token
2/ docker login 
need to login to the tenancies OCIR as the current user using the auth token
3/ Download the pre-built docker images
docker pull fra.ocir.io/oractdemeabdmnative/h-k8s_repo/storefront:0.0.1
docker pull fra.ocir.io/oractdemeabdmnative/h-k8s_repo/storefront:0.0.2
docker pull fra.ocir.io/oractdemeabdmnative/h-k8s_repo/stockmanager:0.0.1
4/ Change the docker image tags
In the target section :
  change myregion  to be the one for your region, e.g. fra.ocir.io
  change mytenancy to be your tenancy
  change myrepo to be your repo name
  
docker tag fra.ocir.io/oractdemeabdmnative/h-k8s_repo/storefront:0.0.1 myregion/mytenancy/myrepoo/storefront:0.0.1
docker tag fra.ocir.io/oractdemeabdmnative/h-k8s_repo/storefront:0.0.2 myregion/mytenancy/myrepo/storefront:0.0.2
docker tag fra.ocir.io/oractdemeabdmnative/h-k8s_repo/stockmanager:0.0.1 myregion/mytenancy/myrepo/stockmanager:0.0.1

5/ Push the images up to your tenancy
  change myregion  to be the one for your region, e.g. fra.ocir.io
  change mytenancy to be your tenancy
  change myrepo to be your repo name

docker push myregion/mytenancy/myrepoo/storefront:0.0.1
docker push myregion/mytenancy/myrepo/storefront:0.0.2
docker push myregion/mytenancy/myrepo/stockmanager:0.0.1
  
  