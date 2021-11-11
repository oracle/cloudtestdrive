Let's have a look at the state of our project code repository

IN the branch selector switch to initial-code-added (REMOVE THIS INSTRUCTION ONCE SWITCHED TO main in github)

We can see the files in the repo, following the links navigate to helidon-storefront-full -> src -> main -> java -> com -> oracle -> labs -> helidon -> storefront -> resources -> StatusResource.java

Once you click on the StaturResourece.java this will open the source code file. This is a simple file, and if you have done the Helidon labs you will know it's the code that is run when  the /status REST API is called, Note the line

```java
public final static String VERSION = "0.0.1";
```

This is the version string that is returned when we call the `/status` end point, and as we go through the lab it's what we will be changing to show the CI/CD process has worked.

Feel free to look at the other files in the repo if you wish.

Using the path "breadcrumb" at the top of the code display return to the `helidon-storefront-full` directory, then navigate to yaml -> build

This directory contains the build_spec.yaml file which we use to actually run the build process. Please don;t go there, but the `helidon-storefront-full` -> yaml -> deplpoyment directory holds the Kubernetes manifests that do the actuall deployment. In this case they are in the same git repo as the source code, however that's not required, you could have multiple repos, one for the source code and another for the manifests if you wished and use files from either or both in the build and deploy process.

Click on the build_spec.yal to open it.

let's explain the build pipeline, this is sadly in YAML (I loathe YAML because it's whitespace sensitive, virtually every problem I've had with a YAML file has been because of that, it'a like going back to my very early days of programming at university when I had to use punch cards for Fortran befor being allowed to use the CRT terminals - but at least they always reserved 8 characters for the line number and didn't vary that indentation) 
 
Variables
variables names in this section persist across build steps, but not across pipeline stages unless explicityly exported
vaultVariables are replaced with the content of the vault secrets we will setup soon, these also persist across steps, but they cannot be exported themselves to prevent leakage of confidential information like logins and so on that are often stored in these variables
exportedVariables are passed out of the build process to the following stages, ONLY variables named here are exported, so if you want a standard or vault variable to be exported you need to specify it here, you can't export a vaultVariable for security reasons, so if you want to do that you have to crate another variable to export, then in one of the stages transfer the values over.

Note that it's also possible to define parameters that you can set when the pipeline is run, those are processed as ${VARIABLE_NAME} we'll look at how to set them up later on

Steps - these are individual stages executed by the build pipeline, the run in the same OS instance, BUT not in the same shell instance. If you want a variable to persist across steps you need to specify it in the variables section. Note that some variables like PATH are automatically persisted across sessions for you and you don't need to specify them.
Each step has a name and timeout (in case the step hands for some reason) unless otherwise specified it will run as root
The core of the step is the commands that it runs, 

In our step 1 "Extract Export variables" we setup the variables and extract the version information from the code, other ways to get the version are of course available, we could even feed it into the pipeline and then modify the code to match the version if we wanted !
Note that we also "transfer" the values from our vaultVariables OCIR_HOST_VAULT to the exported variable OCIR_HOST and OCIR_STORAGE_NAMESPACE_VAULT to OCIR_STORAGE_NAMESPACE, this is because vaultVariables cannot be exported (as mentioned earlier they coudl contain confidential information so we don;t want any accidetal leakage of their contents - deliberate transfer is of course acceptable !) but we can of course create another variable that is exported and deliberatly copy the value over and that's what we're doing here.
Notice the cd ${OCI_PRIMARY_SOURCE_DIR} - this is how we make sure we are in the location for the git prohecxtr that has been automatically imported into the build pipeline for us. OCI_PRIMARY_SOURCE_DIR contains the location in the build image of that git repo
One other section that's important is the onFailure section. There can be many reasons for a failiure, in the case of this pupeline everything is handled in the build instance, but in some cases there may be external side effects and cleanup may need to be done. The onFaliure section allows us to specify what to do, though in this case it's just displaying a message, Like the main step a failure handler can also have a time out and may need to run as a specific user

Let's have a look at the other steps
The 2nd step named "Install local JDK11" this has the same structure as the previous step, but it downloads and installs a JDK for us. We need to do this to ensure that we know exactly what JDK is used to run the build. The image used to run the buiuld process does have a JDK in it, but it may not be the one we expect, so this way we know wehat we're getting

As you can see this updates  JAVA_HOME which we defined earlier as a vatiable so it will be automatically transfered between build stages. The PATH is automatcally transfered

Step 3 "Confirm Variables and versions" it really there to enable us to confirm what the settings are, it's not needed for the build, but it helps to diagnose potential problems due to wront versions shoudl they occur

Step 4 "Build Source and pack into container image" is what does the actual work, this really just calls mvn, we should really have installed the version of mvn as well, but as mvn is basically a framework that doenloads it's own build engine (using the version specified in the pom.xml file) for now that's not critical - and I don't want to spend all day downloading stuff !
The mvn package process uses a tool called JIB (Java Image Builder) that will create a local docker image called jib-storefront (have a look at the pom.xml file to see more on how that's configured) we'll see the images in the output of the docker images command which is run once the mvn command has finished.

Step 5 "Fix resources location in container image" is needed because jib doesn't put the resouces in the locations expected by the Helidon framework and the Java run time (in theory the location is correct, but if you just use that image the code fails as it can't find the resoiurces, I'm still trying to resolve that one)
This step runs a small docker file which copies the commands to the correct location in the image then deletes the old resources location 

Notice that we didn't do a docker push to upload the image to the container registry, we could have, but that woudl mean getting the users login credentials in to the image, and fortunately for us the devops tooling provides a way to avoid doing that using the outputartifacts section.

output Artifacts tells the build pipline what the results of the build are, once it's completed the steps you specified the pipeline will automatically extract the items specified in the output artifacts section and save them away for later use in the next staged of the pipeline, thois could be another build stage (in which case the build_spec of that stage will define input artifacts that match the ones you've just outputted)
Note that the output artifacts include not only the container image we build, but alto the YAML files containing the Kubernetes manifests. We're not modifying those in the build pipeline, but as we want to use them later on we need to specify that they are also output artifacts
