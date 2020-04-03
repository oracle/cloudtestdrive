[Go to Overview Page](../README.md)

![](../../../common/images/customer.logo2.png)

# Migration of Monolith to Cloud Native

## B. Running as a docker images locally

Like the Helidon lab you perform these steps **inside** the client virtual machine

### Prerequisites
To run this part of the lab you need the working storefront and stockmanager microservices (as per the Helidon labs) connected to the database.

- Make sure the zipkin container is running. You may have done this in the previous lab chapter and left it running. 
  - To check if it is already running type :

  ```
  docker ps
  ```
  - Check if there is an entry named **zipkin**:
  
  ```
  e3a7df18cd77        openzipkin/zipkin   "/busybox/sh run.sh"   3 seconds ago       Up 2 seconds        9410/tcp, 0.0.0.0:9411->9411/tcp   zipkin
  ```
  - If the entry is **missing**, relaunch it:  `docker run -d -p 9411:9411 --name zipkin --rm openzipkin/zipkin`


#### Docker image build tool

We will be using **jib** to build the docker images. The Maven pom.xml file contains the details of the jib tooling and it's settings. 

- Open the **storefront** project, and on the top level, open the **pom.xml** file
- Locate the **jib-maven-plugin** dependency near line 162

This defines what's required for jib, including the base image to use.  We will be using the Java 11 Oracle GraalVM Community Edition Docker image as a base image for our containers. We've chosen to use Graal rather than OpenJDK as it provides better Just In Time compilation performance and also the garbage collection. When running in a server environment both of those are important as they reduce startup overheads and make for more predictable responses to the callers. The Graal JVM also allows support for other languages, though we're not making use of that capability in these labs. As it's Java 11 it also means that it's a Long Term Support version of Java. There are of course other options if you want instead of the Graal JVM.

<details><summary><b>More details on Graal</b></summary>
<p>
Though not covered in this lab if you want more details on the free to use community edition of the Graal JVM or the fully supported enterprise version which includes the Ahead-of-Time compilation capabilities for Java applications that compiles the Java bytecode into native programs (and thus makes for a much faster startup and more efficient operations) or info on it's support for polyglot applications (which are becoming increasingly important.) there are other labs available.

The [Graal web site](https://www.graalvm.org/) provides more details om Graal.
</p></details>

#### Size of the base image
Our base image includes a full command line environment, using a base image with command lines and so on makes the docker image larger than it strictly speaking needs to be. If you wanted to of course you could of course use a different Java base image. There are lots of possible docker base images we could use (some of these are listed in the JIB section of the pom.xml file) but the command line tools in this image allows us to connect to the image and see what's going on internally as well as performing commands.

Later in the Kubernetes labs we will use the capability to run commands to simulate the failure of our microservice and see how Kubernetes handles that.

In a production environment a cut down version of a Java 11 base image would be used, as there wouldn't be the need to work inside the container. Also we'd suggest using the Graal enterprise versions which has native compilation capabilities to produce a single executable with a smaller footprint.


### Self contained images
Initially you might think that the easiest thing to do when creating a docker image is to simply package up all of the configuration into the docker image so it's entirely self contained. The problem with this is that quite often configuration information changes after the image has been built, for example between test and deployment, and creating different images for each configuration is challenging (you may have lots of different configuration options, and may not even be able to define them all) and worse can result in embedding things like database access or other security configuration information into the docker images. This latter is especially critical if you are storing your image on an external or public repository where it can be accessed by anyone !

To get around this docker provides a mechanism called volumes to have configuration files stored externally and injected into the container at run time.

### Externalising the configuration
The following is an example of the approach taken when separating the executable from the configuration. 

Firstly you'll need to create a docker image that contains the required executable elements. We've actually set up tooling to support this using jib (Java Image Builder), which is a Maven plugin - you've been using Maven already to manage dependencies, though you may not have realized this.

Use the Maven package target (mvn package) to trigger jib to create the docker container in your local registry. 

- Open a terminal window
- Navigate to the **storefront** project directory
  
  -  `cd workspace/helidon-labs-storefront/`
- Run maven : `mvn package`

```
[MVNVM] Using maven: 3.5.2
[INFO] Scanning for projects...
[INFO] 
[INFO] ------------------------------------------------------------------------
[INFO] Building storefront 0.0.1
[INFO] ------------------------------------------------------------------------
[INFO] 
[INFO] --- maven-resources-plugin:3.0.2:resources (default-resources) @ storefront ---
[INFO] Using 'UTF-8' encoding to copy filtered resources.
[INFO] Copying 3 resources
[INFO] 
...
...
[INFO] ------------------------------------------------------------------------
[INFO] BUILD SUCCESS
[INFO] ------------------------------------------------------------------------
[INFO] Total time: 41.430 s
[INFO] Finished at: 2019-12-29T15:30:06Z
[INFO] Final Memory: 39M/176M
[INFO] ------------------------------------------------------------------------
```

Now repeat this step for the stockmanager:

- Go to the other project directory
  -  `cd ../helidon-labs-stockmanager/`
- Run maven : `mvn package`

This operation will create two docker images, stored locally. The mvn package triggers jib to run which will build the docker image based on the properties in the jib section of the pom.xml file.

The jib tool has many advantages over creating a docker image by hand, because it uses the pom.xml file to know what dependencies to copy over, so any changes to the dependencies will automatically be handled when jib is run.

Note that jib does not copy every file into the right locations as needed by Helidon so there is a second stage to be done to get a functioning docker image for helidon. This runs a docker build against the image created by jib, the Dockerfile copies files in the container image from the resource to the classes directories and then removed the originals, resulting in a docker container that has everything in the places expected.

Once you've created the basic images by using mvn package you can manually create the new ones with the files in the right place using the docker command in the helidon-labs-stockmanager directory:

- In the terminal window, you should still be in the top directory of the **Stockmanager** project
- Run a docker build :  `docker build --tag stockmanager --file Dockerfile .`

```
Sending build context to Docker daemon  229.4kB
Step 1/3 : FROM jib-stockmanager:latest
 ---> 21ff68d7abaf
Step 2/3 : RUN cp -r /app/resources/* /app/classes
 ---> Running in 530a1de6f032
Removing intermediate container 530a1de6f032
 ---> 507b37292b2f
Step 3/3 : RUN rm -rf /app/resources
 ---> Running in 0f5275ae4108
Removing intermediate container 0f5275ae4108
 ---> 47d8ca5574a1
Successfully built 47d8ca5574a1
Successfully tagged stockmanager:latest
```

The --tag flag means that the resulting docker image is to be tagged (named) stockmanager, subsequently we can refer to is using the name, not it's image id which is like a hashcode (e.g. 2655bfee0d99) and much harder to remember than the name !

The --file flag specified the name of the file containing the commands to execute to build the image, strictly this isn't needed in this case as Dockerfile is the default for the docker build command

- Switch to the **Storefront** project: `cd ../helidon-labs-storefront/`
- Run the docker build: `docker build --tag storefront --file Dockerfile .`

```
Sending build context to Docker daemon  110.6kB
Step 1/3 : FROM jib-storefront:latest
 ---> d04bbcb28160
Step 2/3 : RUN cp -r /app/resources/* /app/classes
 ---> Running in 5849e8889fc4
Removing intermediate container 5849e8889fc4
 ---> 23e336c810e5
Step 3/3 : RUN rm -rf /app/resources
 ---> Running in 8c8a4b0fc6ad
Removing intermediate container 8c8a4b0fc6ad
 ---> 90bd16d9e6bc
Successfully built 90bd16d9e6bc
Successfully tagged storefront:latest
```

For your convenience in the future there is a script in each directory called buildLocalExternalConfig.sh that will run a mvn build and the appropriate docker commands. You will need to run the script in *each* directory (so once in the helidon-labs-storefront directory and once in the helidon-labs-stockmanager, it needs to be run from within the directory as that's where docker looks for the content) Initially it may take a few mins to run if it needs to download the appropriate base layers, but once they are downloaded it should speed up. It's best to let one build finish before starting the next one.

If you look at the scripts you will see that they run the maven package process to create the docker image using jib. They then create a new docker image which has the changes needed to run helidon. These are the commands you'd have run by hand.

You can explore the containers by running them to give you shell access (This is why we used a larger docker base image that includes a shell and other Unix utilities, in production you'd use a minimal image.) 

- Run the container:
  -  `docker run --tty --interactive --rm --entrypoint=/bin/bash stockmanager`

This command creates a docker container running the shell which is connected to your terminal. Once you're running in the container you can look around

- Take a look inside the container
  -  `ls`
  - `ls Wallet_ATP`
  - `ls conf`
- Now exit the container
  -  `exit`

```
root@1e640494f039:/# ls
Wallet_ATP  app  app.yml  bin  boot  conf  confsecure dev	  etc  home  lib	lib64  media  mnt  opt	proc  root  run  sbin  srv  sys  tmp  usr  var
root@1e640494f039:/# ls Wallet_ATP/
root@1e640494f039:/# ls conf
root@1e640494f039:/# ls confsecure
root@1e640494f039:/# exit
```

As you can see there is nothing in the /conf /confsecure or /Wallet_ATP directories .jib was told as part of it's config that these would be used for mounting external configuration, so it created the folders for us automatically.

When you exited the container it shutdown as nothing was running in it any more. 

<details><summary><b>Docker Flags</b></summary>
<p>

The docker flags are handled as following, 

--tty means to allocate a terminal connection and connect the standard output / error to the docker run command, 

--interactive means that you can type and your input will be connected to the containers standard input, 

--rm means that the container will be removed when it exits (this means you can reuse the container name and don't have lots of expired containers hanging around)

--entrypoint is the command to use when running the docker container, in this case the shell. jib actually set's up a java command to run your program as the default command if you don't override with --entrypoint.

</p></details>

Let's use docker volumes (the docker --volume flag) to inject the configuration for us, each volume argument is the host file system name (this needs to be an absolute pathname) and the location inside the container to mount it. Again in the helidon-labs-stockmanager directory

- Run the container with a volumes attached:

  - ```
    docker run --tty --interactive --volume `pwd`/Wallet_ATP:/Wallet_ATP --volume `pwd`/conf:/conf --volume `pwd`/confsecure:/confsecure  --rm --entrypoint=/bin/bash stockmanager
    ```

As before we find ourselves in the container and the root directory looks the same

- Look around
  - `ls`
  - ` ls conf`
  - `ls Wallet_ATP`

```
root@bc7d4ae0666b:/# ls
Wallet_ATP  app  app.yml  bin  boot  conf  confsecure dev	etc  home  lib	lib64  media  mnt  opt	proc  root  run  sbin  srv  sys  tmp  usr  var
```
```
root@bc7d4ae0666b:/# ls /conf
stockmanager-config.yaml  stockmanager-network.yaml  
root@bc7d4ae0666b:/# 
root@bc7d4ae0666b:/# ls Wallet_ATP
cwallet.sso  ewallet.p12  keystore.jks	ojdbc.properties  sqlnet.ora  tnsnames.ora  truststore.jks
```
- Exit the container: `exit`

To save having to copy and paste (or type !) each time in both the helidon-labs-storefront and helidon-labs-stockmanager directories there is a script called runLocalExternalConfig.sh to manage this.

This script uses a docker command to locates the IP addresses of the containers running dependencies (for stockmanager this is zipkin, and for the storefront this is zipkin and stockmanager) and injects the IP addresses and suitable hostnames into the containers as it starts them using the --add-host option to the docker run command.

The script also used the --publish flag to the docker run command this sets up a port connection from the specified port on the host OS to the specified port within the container. This is how we make a network service available to outside the docker container.

**If you have not stopped the stockmanager and storefront applications you were running in the helidon labs then they will have ownership of the ports** 

- Check now that the **stockmanager and storefront applicationsthey are not running** inside of your Eclipse environment

If when running the docker containers you get bind errors like this

```
docker: Error response from daemon: driver failed programming external connectivity on endpoint stockmanager (6e43692b6b949efc6f48d2dc18a7d5b9954bb0e16ad8b5cdba341fcabb673c89): Error starting userland proxy: listen tcp 0.0.0.0:9081: bind: address already in use.
```

It means you've not stopped the storefront and / or stock manager programs running in Eclipse

As the storefront depends on the stockmanager (and both depend on zipkin) it's important to ensure that the proper order is followed

- Run the **Stockmanager** container via script:
  -  `bash runLocalExternalConfig.sh`
  - Keep the terminal window open to see logging info
  
- Open a **new** terminal window
  - Go to the Storefront project: `cd workspace/helidon-labs-storefront`
  - Run the **Storefront** container via script: `bash runLocalExternalConfig.sh`

- Open **another** new terminal window
- Call the stocklevel method of the application:
  -  `curl -i -X GET -u jack:password http://localhost:8080/store/stocklevel`

```
HTTP/1.1 200 OK
Content-Type: application/json
Date: Mon, 23 Dec 2019 16:37:30 GMT
connection: keep-alive
content-length: 184
[{"itemCount":4980,"itemName":"rivet"},{"itemCount":4,"itemName":"chair"},{"itemCount":981,"itemName":"door"},{"itemCount":25,"itemName":"window"},{"itemCount":20,"itemName":"handle"}]
```
This call should return the entries you added earlier. 

- You probably will get a *424 Failed dependency* message:  it's because the lazy initialization has taken a while as the back end request has times out (remember the @Timeout annotation!) 
  - Just re-run the request a few times till you get the expected response


The outputs for the storefront and stockmanager containers will display the log data generated as the operation was performed.

Storefront example output

```
2020.01.07 17:29:34 INFO io.helidon.microprofile.faulttolerance.CommandRetrier Thread[helidon-2,5,server]: About to execute command with key listAllStock1387953623 on thread helidon-2
2020.01.07 17:29:34 INFO com.oracle.labs.helidon.storefront.resources.StorefrontResource Thread[hystrix-io.helidon.microprofile.faulttolerance-2,5,server]: Requesting listing of all stock
2020.01.07 17:29:34 INFO com.oracle.labs.helidon.storefront.resources.StorefrontResource Thread[hystrix-io.helidon.microprofile.faulttolerance-2,5,server]: Found 4 items
```

Stockmanager example output

```
^[c2020.01.07 17:29:11 INFO com.arjuna.ats.arjuna Thread[helidon-1,5,server]: ARJUNA012170: TransactionStatusManager started on port 35375 and host 127.0.0.1 with service com.arjuna.ats.arjuna.recovery.ActionStatusService
2020.01.07 17:29:11 INFO com.oracle.labs.helidon.stockmanager.resources.StockResource Thread[helidon-1,5,server]: Getting all stock items
2020.01.07 17:29:12 INFO org.hibernate.jpa.internal.util.LogHelper Thread[helidon-1,5,server]: HHH000204: Processing PersistenceUnitInfo [name: HelidonATPJTA]
2020.01.07 17:29:12 INFO org.hibernate.Version Thread[helidon-1,5,server]: HHH000412: Hibernate Core {5.4.9.Final}
2020.01.07 17:29:12 INFO org.hibernate.annotations.common.Version Thread[helidon-1,5,server]: HCANN000001: Hibernate Commons Annotations {5.1.0.Final}
2020.01.07 17:29:13 INFO com.zaxxer.hikari.HikariDataSource Thread[helidon-1,5,server]: HikariPool-1 - Starting...
2020.01.07 17:29:18 INFO com.zaxxer.hikari.HikariDataSource Thread[helidon-1,5,server]: HikariPool-1 - Start completed.
2020.01.07 17:29:18 INFO org.hibernate.dialect.Dialect Thread[helidon-1,5,server]: HHH000400: Using dialect: org.hibernate.dialect.Oracle10gDialect
2020.01.07 17:29:23 INFO org.hibernate.engine.transaction.jta.platform.internal.JtaPlatformInitiator Thread[helidon-1,5,server]: HHH000490: Using JtaPlatform implementation: [org.hibernate.engine.transaction.jta.platform.internal.JBossStandAloneJtaPlatform]
Hibernate: 
    SELECT
        departmentName,
        itemName,
        itemCount 
    FROM
        StockLevel 
    WHERE
        departmentName='timg'
2020.01.07 17:29:24 INFO com.oracle.labs.helidon.stockmanager.resources.StockResource Thread[helidon-1,5,server]: Returning 4 stock items
```

If you want to see the traces in zipkin use the URL http://localhost:9411/zipkin as before

To stop the containers do Ctrl-C in each of the windows, or in a separate terminal use docker to stop them

- Stop the containers:
  -  `docker stop storefront stockmanager`

<details><summary><b>Why use volumes ?</b></summary>
<p>

You may be asking in the storefront why do we need to inject configuration using the docker volumes, and not just copy it in to the image, after all it has no database connection details ? The reason is that though we could certainly build the configuration into the container that we should not do this with the authentication data, for a test environment you'd want to inject some hard coded authentication data, but in production you'd want to inject an external authentication service. You certainly would want the microservice to not have default authentication info that would be used if you forgot to do this, having a default that opens up security is a bad thing !

Of course in a production environment you'd probably have a separate folder containing the relevant configuration information (it's highly likely that multiple services would use the same database setup for example) to the host configuration would be in there, not in the development folder.

</p></details>

### Pushing your images to a container repository
The docker container images are currently only held locally, that's not good if you want to distribute them or run them in other locations. We can save the images in an external repository, This could be public - e.g. dockerhub.com, private to your organization or in a cloud registry like the Oracle OCIR. Note that if you wanted to there are docker image save and docker image load commands that will save and load image files from a tar ball, but that's unlikely to be as easy to use as a repository, especially when trying to manage distribution across a large enterprise environment.

#### Getting your docker credentials and other information

There are a few details (registry id, authentication tokens and the like) you will need to get before you push your images. 

- Please follow the instructions in this document for [getting your docker details](../ManualSetup/GetDockerDetailsForYourTenancy.md)

As there are may be many attendees doing the lab going through the same tenancy we need to separate the different images out, so we're also going to use your initials / name / something unique 

Your full repo will be a combination of the repository host name (e.g. fra.ocir.io for an Oracle Cloud Infrastructure Registry) the tenancy storage name (for example oractdemeabdmnative) and the  details you've chosen

#### Docker login in to the Oracle Container Image Registry (OCIR)

We need to tell docker your username and password for the registry. 

You will have gathered the information needed in the previous step. You just need to execute the following command, of course you need to substitute the fields

`docker login <region-code>.ocir.io --username=<mytenancystoragenamespace>/oracleidentitycloudservice/<myusername> --password='<auth token>'`

where :

- `<region-code>` : 3-letter code of the region you are using
- `<mytenancystoragenamespace>` : name of your tenancy's Object Storage namespace
- `<myusername>` : user name you used to register for your cloud account, usually an email address
- `<auth token>`: Auth token you associated with your username

All of this is information you gathered when you were [getting your docker details](../ManualSetup/GetDockerDetailsForYourTenancy.md)

For example a completed version may look like this (this is only an example, use your own values) ** Important** The auth token being used for the password may well contain characters with special meaning to the shell, so it's important to include it in single quotes as in the example below ( ' )

`docker login fra.ocir.io --username=cdtemeabdnse/oracleidentitycloudservice/my.email@you.server.com --password='q)u70[]eUkM1u}zu;:[L'`

Enter the command with **your** details into a terminal in the virtual machine to login to the OCIR.

#### Pushing the images

You need to update the repoConfig.sh scripts in **both** the helidon-labs-stockmanager and helidon-labs-storefront directories to reflect your chosen details

- Navigate to the Storefront project

- Open file **repoConfig.sh** and edit the repo name to contain your initials

  - Example for region `Frankfurt`, in the `oractdemeabdmnative` tenancy with initials `tg` you might have : 

    ```bash
    #!/bin/bash
    REPO=fra.ocir.io/oractdemeabdmnative/tg_repo
    echo Using repository $REPO
    ```

- Navigate to the Stockmanager project

- Open file **repoConfig.sh** and edit the repo name again as above

---

<details><summary><b>About the script and the docker tags</b></summary>
<p>

The build script is pretty similar to what we had before. It uses mvn package to create the initial image using jib, but the docker build command in the file is different (don't actually run this, just look at it)

```
$ docker build  --tag $REPO/storefront:latest --tag $REPO/storefront:0.0.1 -f Dockerfile .
```

Note that we have two --tag commands so the resulting image will be pointed to by two names, not just one. Both of the names include the repository information (we use this later on when pushing the images) but they also have a :\<something\> after the container name we're used to seeing. This is used as the version number, this is not processed in any meaningful way that I've discovered (for example I've yet to find a tool that allows you to do something like Version 1.2.4 or later) but by convention people tag the most recent version with :latest and all images should also be tagged with a version number in the form of :\<major\>.\<minor\>.\<micro\> e.g. 1.2.4

<details><summary><b>On the dangers of using :latest</b></summary>
<p>
On the surface using :latest may seem like a really good idea, you want to run the latest version all the time right ?

Well actually using :latest may not be what you want. In a production environment you probably want to know what your exact configuration is, you may well have accreditation requirements (especially in the finance sector) and in most situations you want the production environment to match your development, and test environment. Certainly if you have problems and want to fix them you would wnat to know the configuration the problem is occuring in.

To make matters worse :latest is just a tag , it has no actual meaning. you could have a v0.0.1 version which is also tagged latest, even though there are many versions after it (0.0.2, 0.1.4, 1.0.2 etc.) docker doesn't ensure that :latest is actually the most recent version of an image.
</p></details>

Now the images are tagged with a name that included version and repo information we can push them to a repository, you will need to have logged in to that docker repository (you did this earlier with the `docker login` command)

To push an image to the repository just push it, for example (don't actually run this, just look at it)

```
$ docker push my.repo.io/some-id/storefront:latest
The push refers to repository [my.repo.io/some-id/storefront]
fd17f594205f: Pushed 
f2d4659d7ea1: Pushed 
81c949a6999e: Layer already exists 
6d4327d22e70: Pushed 
84fad9f97da3: Layer already exists 
25efa461ccff: Layer already exists 
4272c5799ff4: Layer already exists 
9a11244a7e74: Layer already exists 
5f3a5adb8e97: Layer already exists 
73bfa217d66f: Layer already exists 
91ecdd7165d3: Layer already exists 
e4b20fcc48f4: Layer already exists 
latest: digest: sha256:7f5638210c48dd39d458ba946e13e82b56922c3b99096d3372301c1f234772af size: 2839
```

(While a layer is being pushed you'll see a progress bar, the above shows the final output.)


Note that the first time you run this most if not all of the layers will be pushed, however subsequent runs only the layers that have changes will need to be pushed, which speeds things up a lot, so if the 0.0.1 tagged version is pushed (this is the same actual image, just a different name, again don't actually run this, just look at it)

```
$ docker push my.repo.io/some-id/storefront:0.0.1
The push refers to repository [my.repo.io/some-id/storefront]
fd17f594205f: Layer already exists  
f2d4659d7ea1: Layer already exists  
81c949a6999e: Layer already exists 
6d4327d22e70: Layer already exists  
84fad9f97da3: Layer already exists 
25efa461ccff: Layer already exists 
4272c5799ff4: Layer already exists 
9a11244a7e74: Layer already exists 
5f3a5adb8e97: Layer already exists 
73bfa217d66f: Layer already exists 
91ecdd7165d3: Layer already exists 
e4b20fcc48f4: Layer already exists 
latest: digest: sha256:7f5638210c48dd39d458ba946e13e82b56922c3b99096d3372301c1f234772af size: 2839
```
Notice that the layers all already exist, so nothing needs to be uploaded at all (except of course to establish the name to image hash mapping)

</p></details>

- Rebuild the images

Run the buildPushToRepo.sh script in one of the project directories, then once it's finished in the other. 

- In the Storefront directory:
  - Run `bash buildPushToRepo.sh`
- In the Sockmanager directory:
  - Run `bash buildPushToRepo.sh`

```$ bash buildPushToRepo.sh 
Using repository fra.ocir.io/oractdemeabdmnative/tg_repo
[MVNVM] Using maven: 3.5.2
[INFO] Scanning for projects...
[INFO] 
[INFO] ------------------------------------------------------------------------
[INFO] Building storefront 0.0.1
[INFO] ------------------------------------------------------------------------
[INFO] 

<Bunch of mvn output and stuff deleted>

 ---> 63d65abfcf0c
Successfully built 63d65abfcf0c
Successfully tagged fra.ocir.io/oractdemeabdmnative/tg_repo/storefront:latest
Successfully tagged fra.ocir.io/oractdemeabdmnative/tg_repo/storefront:0.0.1
The push refers to repository [fra.ocir.io/oractdemeabdmnative/tg_repo/storefront]
61a16a955381: Pushed 
0cae22e386b2: Pushed 

<Bunch of deleted docker push output>

1f59a4b2e206: Layer already exists 
0ca7f54856c0: Layer already exists 
ebb9ae013834: Layer already exists 
0.0.1: digest: sha256:c993e660e73e681b7b5a8200b0a2e8baed0af1a52c334ef03284f13c27d4ed7c size: 2839
build and pushed with tags 0.0.1
```

The script will do the build then push the container images. The first time you push to the repository it may take a while because you've pushing all of the layers in the runtime, the next time however only changes layers will need to be pushed.

You can now re-run the images that have been pushed the cloud.



### Cleaning up

This is the end of this section of the lab, let's stop the running images

- Open a new terminal window
- Stop the Storefront and Stockmanager apps:
  -  ` docker stop storefront stockmanager`
- Stop the zipkin instance running
  -  `docker stop zipkin`



# Preparing for the Kubernetes labs

When you do the Kubernetes labs you will test out performing a rolling upgrade. To do that you need to be able to show that the upgrade has applied, so you're going to do a bit of advance work now make a small change now so you can see the differences in versions in the later labs.

- In Eclipse, navigate to the **helidon-labs-storefront** project
  - Then navigate to **src/main/java**, then **com.oracle.labs.helidon.storefront**, then **resources**
  - Open the file **StatusResource.java** 
  - Change the version in the returned to **0.0.2** (updated version shown below)

  ```
	  public JsonObject isAlive() throws InterruptedException {
		  return JSON.createObjectBuilder().add("name", storename).add("alive", true).add("version", "0.0.2").build();
	  }
  ```

  - Save the changes

- In a terminal window, let's build the new version of the container:

  -  Change to folder **helidon-labs-storefront**
  - Run the v2 script:
    -  `bash buildV0.0.2PushToRepo.sh `

```
Using repository fra.ocir.io/oractdemeabdmnative/tg_repo
[MVNVM] Using maven: 3.5.2
[INFO] Scanning for projects...

<Lots of Maven output removed>

[INFO] Total time: 23.872 s
[INFO] Finished at: 2020-01-03T12:13:40Z
[INFO] Final Memory: 39M/188M
[INFO] ------------------------------------------------------------------------
Sending build context to Docker daemon  112.1kB
Step 1/3 : FROM jib-storefront:latest
 ---> d31de67d9272
Step 2/3 : RUN cp -r /app/resources/* /app/classes
 ---> Running in 818de3f3faec
Removing intermediate container 818de3f3faec
 ---> 121bb2f37bb7
Step 3/3 : RUN rm -rf /app/resources
 ---> Running in 9d650231ec09
Removing intermediate container 9d650231ec09
 ---> df30253a82ec
Successfully built df30253a82ec
Successfully tagged fra.ocir.io/oractdemeabdmnative/tg_repo/storefront:latest
Successfully tagged fra.ocir.io/oractdemeabdmnative/tg_repo/storefront:0.0.2
The push refers to repository [fra.ocir.io/oractdemeabdmnative/tg_repo/storefront]
7f699cf87b87: Pushed 
76ad72d8097b: Pushed 
b158b5f94634: Pushed 
341c644e75cf: Pushed 
84fad9f97da3: Layer already exists 
2f6d5006f5d1: Layer already exists 
1608029e89ad: Layer already exists 
03ff63c55220: Layer already exists 
bee1e39d7c3a: Layer already exists 
1f59a4b2e206: Layer already exists 
0ca7f54856c0: Layer already exists 
ebb9ae013834: Layer already exists 
latest: digest: sha256:65db7b35e2f2bd73f0010771f66794034eecddb6b10b69a3f34b9a8ffd16d8f5 size: 2839
The push refers to repository [fra.ocir.io/oractdemeabdmnative/tg_repo/storefront]
7f699cf87b87: Layer already exists 
76ad72d8097b: Layer already exists 
b158b5f94634: Layer already exists 
341c644e75cf: Layer already exists 
84fad9f97da3: Layer already exists 
2f6d5006f5d1: Layer already exists 
1608029e89ad: Layer already exists 
03ff63c55220: Layer already exists 
bee1e39d7c3a: Layer already exists 
1f59a4b2e206: Layer already exists 
0ca7f54856c0: Layer already exists 
ebb9ae013834: Layer already exists 
0.0.2: digest: sha256:65db7b35e2f2bd73f0010771f66794034eecddb6b10b69a3f34b9a8ffd16d8f5 size: 2839
built and pushed v0.0.2

```

There is a lot of output, most of which has been removed in the example output above. You can see that the 0.0.2 version has been pushed to the repo.

(Note the Maven output may refer to v0.0.1, don't worry this is because we haven't changed the version details in the maven pom.xml file. The later stages of the process override this.)

## Summary
Congratulations, you are now able to run your microservices on Docker!  Next step is to use these images to deploy them on a Kubernetes cluster.  For this, navigate to the next chapter, [C. Deploying in Kubernetes](../Kubernetes/Kubernetes-labs.md)

------

[Go to Overview Page](../README.md)