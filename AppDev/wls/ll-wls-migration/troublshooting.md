Troubleshooting guide

# Docker images failed to compile :

In same rare cases , during the building of the image , the docker image process fails, with the message that the yum.oracle repository is unreachable.
In this case you should relaunch the docker daemon with the command :

```
systemctl restart docker

systemctl status docker
```



# Problems logging to your server as oracle user 

During the creation of the wls compute node the oracle Linux account is created and updated.
In same case, the server is marked a "ready" from the OCI console, but when you try to log in as oracle you will be refused with the error 

```text
Permission denied (publickey).
```

in this case wait , and try to reconnect to the server, or try to connect as opc user then execute sudo su - oracle to continue as oracle user

Missing File DiscoveredDemoDomain.zip-logfile

in case that this file is missing and the Docker build fails then run this command from the linux terminal

/home/oracle/stage/installers

wget  https://github.com/eugsim1/WLS_imagetool_scripts/raw/main/DiscoveredDemoDomain.zip