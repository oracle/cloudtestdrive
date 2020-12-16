Before to run these steps you need to log into the [Docker hub](https://hub.docker.com/_/oracle-weblogic-server-12c) 

![](images/docker-hub.jpg)



and download the following weblogic images:

**store/oracle/weblogic:12.2.1.3**

**store/oracle/weblogic:12.2.1.4**

If you don't have a Docker account follow the instructions on Docker site to create your account then use the below scripts to download the images to you test server:

```
###
### get the following images from the docker hub
##  
###
echo "You_Docker_Password" > ~/my_password.txt
cat ~/my_password.txt | docker login --username Your_Docker_Id --password-stdin
docker pull store/oracle/weblogic:12.2.1.3 
docker pull store/oracle/weblogic:12.2.1.4
```
