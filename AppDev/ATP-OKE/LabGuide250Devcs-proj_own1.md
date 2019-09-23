[Go to ATP Overview Page](../../ATP/readme.md)

![](../../common/images/customer.logo2.png)
# Microservices on ATP #

## Setting up your Developer Cloud Project ##

### Extra step when using a personal Trial environment ###

If you are using a personal trial Cloud Tenancy, you need to upload some larger files to the Developr Cloud git Repository.  The easiest way to do this consists of making a local branch of the repository on your machine.

### Cloning your repository locally

In order to easily update and upload files into your Developer repository, we will clone the newly created DevCS repository onto your (VM) machine.

- Open a Terminal window on your laptop
- In the home directory, create a directory where you will clone the repository, and move into this directory:

```
mkdir dev

cd dev
```



- Copy the URL of your newly created repository in Developer cloud, by navigating to the "Project Home" page on the left, then selecting the **Clone** button of your repository on the right.  Select **Clone with HTTPS** and the URL will be copied.

![](/Users/jleemans/dev/github/old/cloudtestdrive/AppDev/ATP-OKE/images/150/image013.png)

Now you can enter a command similar to the one below to clone your repository

- Type in the command **git clone** followed by a space
- paste the URL you just copied into the terminal

The result should look like:

`git clone https://<user_name>@ctddevcs-<instance_name>.developer.ocp.oraclecloud.com/ctddevcs-<instance_name>/s/ctddevcs-<instance_name>_atpdocker_1741/scm/ATPDocker.git`

This will result in following output:

![](/Users/jleemans/dev/github/old/cloudtestdrive/AppDev/ATP-OKE/images/150/image014.png)



---
[Go to ATP Overview Page](../../ATP/readme.md)

