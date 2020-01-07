[Go to Overview Page](../README.md)

![](../../../common/images/customer.logo2.png)

# Migration of Monolith to Cloud Native

## B. Running as a docker images locally

### **Introduction**
*To Do : Add a short introduction on docker and how we will use it in this lab*

### Prerequisites
Important, to run this you will need the working storefront and stockmanager microservices (as per the Helidon labs) connected to the database.

You will need docker running locally on your machine to build the images (This has been done for you if you're using the VM image we provide.)

We will be using jib (a google tool) to build the docker images. The pom.xml file contains the details of the jib tooling and it's settings. Open the pom.xml file for a project and look for the jib-maven-plugin dependency. This defined what's required for jib, including the base image to use. Here we're using the Java 11 openjdk (As this is build using JDK11 Long Term Support.) Of course there are lots of possible docker base images we could use, but I shode this as it allows us to connect to the image and see what's going on internally (I.e. it has a full shell environment) This makes the docker image larger than it needs to be, but it helps with debugging if it's needed. In a production environment a cut down version of a Java 11 base image would be used.

Make sure the zipkin container is running. You may have done this in a previous lab and left it running. To check if there is already one running type :

```
docker ps
```
See if there is an entry named zipkin, if there is it will look something like

```
e3a7df18cd77        openzipkin/zipkin   "/busybox/sh run.sh"   3 seconds ago       Up 2 seconds        9410/tcp, 0.0.0.0:9411->9411/tcp   zipkin
```
If there is an entry you're fine, if there isn't start it with the command (doesn't matter which directory you're in to do this)

```
docker run -d -p 9411:9411 --name zipkin --rm openzipkin/zipkin 
```
(this will download the zipkin image from an external repository if needed)

Once you have build the local docker containers then you can run them, be sure you have started zipkin (see previously)

### Self contained images
Initially you might think that the easiest thing to do when creating a docker image is to simply package up all of the configuration into the docker image so it's entirely self contained. The problem with this is that quite often configuration information changes after the image has been built, for example between test and deployment, and creating different images for each configuration is challenging (you may have lots of different configuration options, and may not even be able to define them all) and worse can result in embedding things like database access or other security configuration information into the docker images. This latter is especially critical if you are storing your image on an external or public repository where it can be accessed by anyone !

To get around this docker provides a mechanism called volumes to have configuration files stored externally and injected into the container at run time.

### Externalising the configuration
The following is an example of the approach taken when separating the executable from the configuration. 

Firstly you'll need to create a docker image that contains the required executable elements. We've actually set up tooling to support this using jib (Java Image Builder) which is a Maven plugin - you've been using Maven already to manage dependencies, though you may not have realized this.

The Maven package target (mvn package) to create the docker container in your local registry. Simply open a terminal, navigate to the two project directories in a terminal and type 

```
mvn package
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
[INFO] Built image to Docker daemon as jib-storefront, jib-storefront:0.0.1, jib-storefront
[INFO] Executing tasks:
[INFO] [==============================] 100.0% complete
[INFO] 
[INFO] ------------------------------------------------------------------------
[INFO] BUILD SUCCESS
[INFO] ------------------------------------------------------------------------
[INFO] Total time: 41.430 s
[INFO] Finished at: 2019-12-29T15:30:06Z
[INFO] Final Memory: 39M/176M
[INFO] ------------------------------------------------------------------------
```

Do this for both the storefront and stockmanager packages (helidon-labs-stockmanager and helidon-labs-storefront) This will create two  docker images. mvn package triggers jib to run which will build the docker image based on the properties in the jib section of the pom.xml file (docker is already installed and running in the VM.) jib has many advantages over creating a docker image by hand, because jib uses the pom.xml file it knows what dependencies to copy over, so any changes to the dependencies will automatically handled when jib is run.

Note that jib does not copy every file into the right locations as needed by Helidon so there is a second stage to be done to get a functioning docker image for helidon. This runs a docker build against the image created by jib, the Dockerfile copies files form resource to the classes structure and then removed the origionals, resulting in a docker container that has everything in the places expected

once you've created the basic images by using mvn package you can manually create the new ones with the files in the right place using the docker command in the helidon-labs-stockmanager directory
>
```
docker build --tag stockmanager --file Dockerfile .
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

In the helidon-labs-storefront directory


```
docker build --tag storefront --file Dockerfile .
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

For your convenience there is a script in each directory called buildLocalExternalConfig.sh that will run a mvn build and the appropriate docker commands. You will need to run the script in *both* the directories (so once in the helidon-labs-storefront directory and once in the helidon-labs-stockmanager, it needs to be run from within the directory as that's where docker looks for the content) Initially it may take a few mins to run if it needs to download the appropriate base layers, but once they are downloaded it should speed up. It's best to let one build finish before starting the next one.

If you look at the scripts you will see that they run the maven package process to create the docker image using jib. They they create a new docker image which has the changes needed to run helidon. These are the commands you'd have run by hand.

You can explore the containers by running them to give you shell access (This is why we used a larger docker base image that includes a shell and other Unix utilities.) In the helidon-labs-stockmanager directory run the following command

```
docker run --tty --interactive --rm --entrypoint=/bin/bash stockmanager
```
This command creates a docker container running the shell which is connected to your terminal. Once you're running in the container you can look around

```
root@1e640494f039:/# ls
Wallet_ATP  app  app.yml  bin  boot  conf  confsecure dev	  etc  home  lib	lib64  media  mnt  opt	proc  root  run  sbin  srv  sys  tmp  usr  var
root@1e640494f039:/# ls Wallet_ATP/
root@1e640494f039:/# ls conf
root@1e640494f039:/# ls confsecure
root@1e640494f039:/# exit
```

As you can see there is nothing in the /conf /confsecure or /Wallet_ATP directories .jib was told as part of it's config that these would be used for mounting external configuration, so it created the folders for us automatically.

When you exited the container it shutdown as nothing was in there any more. 

If you're interested the docker flags are handled as following, --tty means to allocate a terminal connection and connect the standard output / error to the docker run command, --interactive means that you can type and your input will be connected to the containers standard input, --rm means that the container will be removed when it exits (this means you can reuse the container name and don't have lots of expired containers hanging around) Finally --entrypoint is the command to use when running the docker container, in this case the shell. jib actually set's up a java command to run your program as the default command if you don't override with --entrypoint.

Let's use docker volumes (the docker --volume flag) to inject the configuration for us, each volume argument is the host file system name (this needs to be an absolute pathname) and the location inside the container to mount it. Again in the helidon-labs-stockmanager 

```
docker run --tty --interactive --volume \`pwd\`/Wallet\_ATP:/Wallet\_ATP --volume \`pwd\`/conf:/conf --volume \`pwd\`/confsecure:/confsecure  --rm --entrypoint=/bin/bash stockmanager
```
As before we find ourselves in the container and the root directory looks the same

```
root@bc7d4ae0666b:/# ls
Wallet_ATP  app  app.yml  bin  boot  conf  confsecure dev	etc  home  lib	lib64  media  mnt  opt	proc  root  run  sbin  srv  sys  tmp  usr  var
```
However the conf and Wallet_ATP directories now contain the configuration and database access details we need to run.

```
root@bc7d4ae0666b:/# ls /conf
stockmanager-config.yaml  stockmanager-network.yaml  
root@bc7d4ae0666b:/# ls /confsecure
stockmanager-database.yaml  stockmanager-security.yaml
root@bc7d4ae0666b:/# ls Wallet_ATP
cwallet.sso  ewallet.p12  keystore.jks	ojdbc.properties  sqlnet.ora  tnsnames.ora  truststore.jks
root@bc7d4ae0666b:/# exit
```
(The storefront image does the same if you want to run that container with a shell, but it doesn't need to mount /Wallet_ATP as it doesn't talk to the database)

To save having to copy and paste (or type !) each time in both the helidon-labs-storefront and helidon-labs-stockmanager directories there is a script called runLocalExternalConfig.sh (don't run it until you've read the following)

This script uses a docker command to locates the IP addresses of the containers running dependencies (for stockmanager this is zipkin, and for the storefront this is zipkin and stockmanager) and injects the IP addresses and suitable hostnames into the containers as it starts them using the --add-host option to the docker run command.

The script also used the --publish flag to the docker run command this sets up a port connection from the specified port on the host OS to the specified port within the container. This is how we make a network service available to outside the docker container.

As the storefront depends on the stockmanager (and both depend on zipkin) it's important to ensure that the proper order is followed

Make sure zipkin is running (see above)

Then run the runLocalExternalConfig.sh script in the helidon-labs-stockmanager directory (this generates log info so the script stays connected to the container to display the output)

In a different terminal in the helidon-labs-storefront directory run the runLocalExternalConfig.sh script, this will start the storefront running, again as it generates log data it will remain connected to the container so you can see the output.

If you now make a request to the storefront service you should get a response (As before we ar using curl here, but if you prefer feel free to use the postman program that's also installed in the VM)

```
curl -i -X GET -u jack:password http://localhost:8080/store/stocklevel
HTTP/1.1 200 OK
Content-Type: application/json
Date: Mon, 23 Dec 2019 16:37:30 GMT
connection: keep-alive
content-length: 184
[{"itemCount":4980,"itemName":"rivet"},{"itemCount":4,"itemName":"chair"},{"itemCount":981,"itemName":"door"},{"itemCount":25,"itemName":"window"},{"itemCount":20,"itemName":"handle"}]
```
Should return the entries you added earlier. The outputs for the storefront and stockmanager containers will display the log data generated as the operation was performed.

If you want to see the traces in zipkin use the URL http://localhost:9411/zipkin as before

To stop the containers do Ctrl-C in each of the windows, or in a separate terminal use docker to stop them

```
docker stop storefront stockmanager
```

You may be asking in the storefront why do we need to inject configuration, and not just copy it in and leave it, after all it has no database connection details. The reason is that though we could certainly build the configuration into the container that we should not do this with the authentication data, for a test environment you'd want to inject some hard coded authentication data, but in production you'd want to inject an external authentication service. You certainly would want the microservice to not have default authentication info that would be used if you forgot to do this, having a default that opens up security is a bad thing !

Of course in a production environment you'd probably have a separate folder containing the relevant configuration information (it's highly likely that multiple services would use the same database setup for example) to the host configuration would be in there, not in the development folder.

### Pushing your images to a container repository
The docker container images are currently only held locally, that's not good if you want to distribute them or run them in other locations. We can save the images in an external repository, This could be public - e.g. dockerhub.com, private to your organization or in a cloud registry like the Oracle OCIR. Note that if you wanted to there are docker image save and docker image load commands that will save and load image files from a tar ball, but that's unlikely to be as easy to use as a repository, especially when trying to manage distribution across a large enterprise environment.

As there are probably many attendees doing the lab we need to separate the different images out, so we're also going to use your initials / name / something unique 

Your full repo will be a combination of the repository host name (e.g. fra.ocir.io for an Oracle Cloud Infrastructure Registry) the tenancy name (oractdemeabdmnative) and the  details you've chosen

Chose something unique ** TO YOU ** e.g. tg_repo (those are my initials, ** YOURS WILL NEED TO BE DIFFFERENT, DON'T USE MINE !!! **) this must be in lower case and can only contain letters, numbers and hyphen.

The ultimate full repo will look something like fra.ocir.io/oractdemeabdmnative/tg_repo (**REMEMBER THIS IS FOR ME, YOU NEED TO CHOSE SOMETHING UNIQUE TO YOU**)

Update the repoConfig.sh scripts in both the helidon-labs-stockmanager and helidon-labs-storefront directories to reflect your chosen repo details. The info in the repoConfig.sh is used by the push and also the run scripts, so it will reduce the chance of errors.

The build script is pretty similar to what we had before. It uses mvn package to create the initial image using jib, but the docker build command in the file is different (don't actually run this, just look at it)

```
docker build  --tag my.repo.io/some-id/storefront:latest --tag $REPO/storefront:0.0.1 -f Dockerfile .
```


Note that we have two --tag commands so the resulting image will be pointed to by two names, not just one. Both of the names include the repository information (we use this later on when pushing the images) but they also have a :<something> after the container name we're used to seeing. This is used as the version number, this is not processed in any meaningful way that I've discovered (for example I've yet to find a tool that allows you to do something like Version 1.2.4 or later) but by convention you should tag the most recent version with :latest and all images should be tagged with a version number in the form of :<major>.<minor>.<micro> e.g. 1.2.4

Now the images are tagged with a name that included version and repo information we can push them to a repository, you will need to have logged in to your docker repository (the `docker login` command ) If you are using the VM image we provided then this will have been done for you and for the remainder of this workshop we will use the Oracle Cloud Infrastructure Registry.

To push an image to the repository just push it, for example (don't actually run this, just look at it)

```
docker push my.repo.io/some-id/storefront:latest
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
docker push my.repo.io/some-id/storefront:0.0.1
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

To reduce the chance of typos here we've setup some scripts to assist you. Make sure you've updated the repository information in both of the repoConfig.sh scripts (there is one in each of the helidon-labs-storefront and helidon-labs-stockmanager folders)

Run the buildPushToRepo.sh script in one of the project directories, then once it's finished in the other. The first time you push to the repository it may take a while as mentioned above because you've pushing all of the layers in the runtime, the next time however only changes layers will need to be pushed.

You can now run the images that have been pushed the cloud

run the runRepo.sh script in both directories (as usual do the stockmanager first) then test it as before.

```
curl -i -X GET -u jack:password http://localhost:8080/store/stocklevel
HTTP/1.1 200 OK
Content-Type: application/json
Date: Mon, 24 Dec 2019 13:32:13 GMT
connection: keep-alive
content-length: 184
[{"itemCount":4980,"itemName":"rivet"},{"itemCount":4,"itemName":"chair"},{"itemCount":981,"itemName":"door"},{"itemCount":25,"itemName":"window"},{"itemCount":20,"itemName":"handle"}]
```
As before if you want to look at the trace then in a web browser goto https://localhost:9411/zipkin

Just a note here on where the images are actually coming from. We're actually still using the local one as that's what we pushed, so docker recognizes that there is no point in re-downloading it again. If you want force the use of the remote image then use the command
`docker image`
to get a list of images and then and 
`docker rmi -f <images id`
to remove the images you have build if you want to actually force downloading them from the cloud. If you do this then the docker run command will pull all of the images layers it doesn't have locally into the local docker images cache (the next time its run they will already be in the cache and it will use that rather than downloading them again.)



### Cleaning up

to stop the running images,  Ctrl-C them or in a terminal do 

```
docker stop storefront stockmanager
```
Also we're going to stop the zipkin instance running as well as we're done with it now

```
docker stop zipkin
```



Congratulations, you are now running your microservices on Docker!  Next step is to use these images to run on a Kubernetes cluster.  For this, navigate to the next chapter, [C. Deploying in Kubernetes](../Docker/DockerLabs.md)



------

[Go to Overview Page](../README.md)