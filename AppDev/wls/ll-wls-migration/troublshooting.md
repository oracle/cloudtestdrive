Troubleshooting guide

Docker images failed to compile :

In same rare cases , during the building of the image , the docker image process fails, with the message that the yum.oracle repository is unreachable.
In this case you should relaunch the docker daemon with the command :

```
systemctl restart docker

systemctl status docker
```

