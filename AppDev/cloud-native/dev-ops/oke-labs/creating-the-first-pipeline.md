We're nopw ready to create the actual build pipeline

Navigate to your project page, if need be you can do this form the begininc by : CLick the Hamburger menu -> Developer Services -> Projects (in the DevOps section) and selecting your project.

In the Resources section on the left side of the page click the **Build Pipelies** option

Click create a build pipeline, name it BuildStorefront, provide a description if you want.

After a short while your newly created pipeine will be displayed in the list

We're now going to add a build stage. A build stage runs in it's build runner (each stage has it's own runner)

Click the + icon then **Add Build Stage** to add a build stage

There are multiple types of build stages, The  stage types are described in their boxes, but initially we will be creating a **Managed Build** stage will actually be used to process our build_spec.yaml file

Click the **Managed Build** option, then the **Next** button at the bottom of the page

Name the stage `BuildStorefront`

Enter a description if you like

Leave the Base container image unchanged

In the **Build Spec File Path** enter `${OCI_PRIMARY_SOURCE_DIR}/yaml/build/build_spec.yaml`

Note that we have to specify the location as the build_spec.yaml is not in the root of the project. This is due to the way that Eclipse places projects in a git repo, and I used Eclipse to create the code. (Eclipse allows multiple projects in the same git repo so everything is one level "down" from the top of the repo). If build_spec.yaml has been ad the top level of the git repo the build system would have looked there as the default and we would not have had to specify this.

The devops build system assigns the variable ${OCI_PRIMARY_SOURCE_DIR} to the location in the build runner where the primary git repo is placed during it's setup so for the cloudnative-helidon-storefront this means that build spec is in ${OCI_PRIMARY_SOURCE_DIR}/yaml/build/build_spec.yaml

Note for a full list of the variables setup by the build pipeline infrastructure see the **Build Specification Parameters** section in the [build pipeline documentation](https://docs.oracle.com/en-us/iaas/Content/devops/using/build_specs.htm)

Click the **Select** button in the **Primary Code Repository** section, in the selection type dropdown chose **OCI Code Repository** then once the list has updated and select `cloudnative-helidon-storefront` - the git repo you created for this project, Click the **Save** button

Leave the **Timeout** blank

Click the **Add** button

Note - For this lab we are only using a single git repo which contains all of the code as well as the Kubernetes Manifests, However it's perfectly reasonable for a build to have multiple git repositories, for example if the code and Kubernetes manifests were held in separate repositories (which could with careful pipeline design result in a faster CI/CD process if only the manifests were changed)


Note - For this lab we're only going to create a simple linear pipeline, but if appropriate you can have parallel stages, perhaps you are building multiple library files first which can all be build independently, then combining them all in a last deploy stage and linking the intermediate artifacts with outputArtifact / inputArtifact entries in their build specs

Running our first pipeline 
Let's see this in action, Click the **Start Manual Run** button on the upper right

A window will appear, you can change the Build run name it you needed to, but for now just leave it with the current value. The parameters box should be empty, as for this part of the lab we have not defined any parameters (we will look into this in a little bit) We only using using variables which get their values from inside the build pipeline, from the vault secrets (e.g. OCIR_HOST_VAULT), are determined inside the build stage (e.g. STOREFRONT_VERSION), or are set for us by the build pipeline infrastructure itself (e.g. OCI_PRIMARY_SOURCE_DIR)

Click the **Start Manual Run** button on the lower left to start the build process.

We can now see several aspects on the page

On the left is the build pipeline, at the moment there's only one stage, but if there were multiple the color coding would indicate the progress with completed stages being in green and in progress stages in Amber and pending stages in grey.

In the centre section we can see the list of stages, if you click the arrow to the left of the stage name you will see the individual steps in the stage (these correspond to the steps in your `build_spec.yaml` file. As each stage completed a green checkmark will be displayed next to it

Finally on the right we can see the logs form the build stages, note that if there are multiple steps in a build stage they will all be displayed in the logs for the stage. It can take a while for the logs to start being displayed as they do not update immediately, they can lag by 30 seconds or more between the data being generated and displayed. 

Note If you see a warning about end time cannot be before start time do not worry, that's just the log viewer getting a little confused as the build process is initialized, it will sort itself out once the log data starts arriving.

Navigating the log viewer.

Though it's not that apparent (on Safari at least) there is a scroll bar on the left of the logs, also you can enter text in the **Find** field at the top of the log viewer, currently this highlights the entries rather than jumping to them (so you need to then scroll in most cases). Next to the **Find** field there is an arrow to enable you to download the logs to your own machine, personally I find this the easiest way to browse the logs once the stage has finished - I just load them into a text editor (or on the Mac there is also the console log viewer). The logs can get quite big - even this simple build stage generates over 1MB of log data, though most of that is just updates from Maven as it downloads the jar files specified in the pom.xml file.

There is also the "three dots" menu to the right of each build stage, clicking on that opens a "popup" where you can see the details of the build runner as well as the logs for that stage.

One point here, you can (as long as the logs are preserved - usually that's within the period specified when you Enabled logging for the project (there is a 1 month minimum) go back at any time to look at the output. There are several ways to do this, but if you are already in the build pipeline then the simplest is to click on the **Build History** tab. If this isn't visible (currently it only seems to display if there are no active build runs) Click the **Build pipeline** tab then the **Build History** should be displayed. 

The other way to access the build history is to use the "Breadcrumb" trail at the top of the window and click on your project name, then on the left in the **Resources** section click **Build History** to see the list of builds that have been run.

Admittedly at the moment you probably only have a single build, named something like `BuildStorefront-20211101-21-37` If it's not obvious the `20211101` references the date of the build in YYMMDD format and the `21-37` references the time of the build though I personally find looking at the **Timestamp** column to be easier. Also note that the **Triggerd by** column only contains `-`  this indicates a build process you started manually, it's possible (as we shall see later) to automatically trigger a build pipeline based on a git commit, in that case the **Build Runs** column will include the name of the trigger and the **Triggerd by** will contain the OCID of the trigger (the OCID is unique, wheras a name could be re-used, so this makes traceability easier).

Hopefully, unless there was an error in the `build_spec.yaml` file the build will complete, either using the log viewer or if you prefer by downloading to your own machine and opening it there let's have a log at the build log output.

The initial phases cover the creation and allocation of the build runner to the build stage - remember each build stage will have it's own runner.

Once the build runner is ready then the build runtime does some parsing of the `build_spec.yaml` file. If there is a problem in processing the build spec (e.g. corrupt yaml, or trying to do something like export a vault variable) then it will be flagged here and the build process will stop.

We then see the build process doing a phase **DOWNLOAD_INPUT_ARTIFACTS** This is basically a empty phase as in our build spec we didnt; define any input artifacts, but if there had been multiple build phases in our pipeline (for example creating library files in one build phase, then using them in a subsequent phase) this would allow the import of those artifacts form the previous stage inbto the current one - that's importanrt because each phase geit's it's own brand new runner, which of course initially doesn't know about what has happend in previous stages, so we need a way to transfer resulting artefacts between the stages.

Now we see the actual build steps we defined start running, these are executed in the order defined in the `build_spec.yaml` file, so the first stage is `Extract Export variables` We can see it displaying the various variables we are `echoing` in the buld step, along with the `STOREFRONT_VERSION:` being set to a value that the script extracted forn the source code (`0.0.1` in this case)

A little further down we see the output for the `Install local JDK11` stage, her we can see the output of the commands used to download and install the version of the JDK we wish to use, along with some confirmation output including the updated `PATH` variable, the value assigned to `JAVA_HOME` the output form `java --version` and so on.

The next stage contains a lot of output - it's actually executing the build process and as it useds Maven to do this we get all of the output from the `mvn` command as it downloads first it's own jar files, then the ones specified in the `pom.xml` file for building the image and the jar files to run `jib` which packages the resulting code into a container image. This is a *lot* of output and makes up date build of the output for this stage.

Rather than going through the output page by page in the log viewer just use the scroll bar (or whatever navigation option you chose if looking at this on your own machine) to go to the bottom of the output.

Here you will see the output of the phase `SAVE_OUTPUT_ARTIFACTS` if you don't see this then you may need to scroll up a little in the log output (it should be within around 5-15 lines from the bottom of the output for this stage)

here we will see output similar to the following 

```
2021-11-01T18:23:14.056Z Starting SAVE_OUTPUT_ARTIFACTS   
2021-11-01T18:23:43.420Z Artifact storefront_container_image in build spec file with location storefront:latest successfully saved.   
2021-11-01T18:23:43.542Z Artifact service_yaml in build spec file from location ${OCI_PRIMARY_SOURCE_DIR}/helidon-storefront-full/yaml/deployment/serviceStorefront.yaml successfully saved.   
2021-11-01T18:23:43.579Z Artifact ingressRules_yaml in build spec file from location ${OCI_PRIMARY_SOURCE_DIR}/helidon-storefront-full/yaml/deployment/ingressStorefrontRules.yaml successfully saved.   
2021-11-01T18:23:43.613Z Artifact deployment_yaml in build spec file from location ${OCI_PRIMARY_SOURCE_DIR}/helidon-storefront-full/yaml/deployment/storefront-deployment.yaml successfully saved.   
2021-11-01T18:23:43.613Z Completed SAVE_OUTPUT_ARTIFACT   
```

This phase is the build runner copying the artifacts that we specified in the `outputArtifacts` section of the `build _spec.yaml` out of the build runner and storing them somewhere so they can be picked up by the next stage (I'm guessing they are stored in bit of objects storage private to the build process, but it doesn't really matter) the artifact names are the ones you specified in the `outputArtifacts` section and *must* match the names you use for the artifact in subsequent build phases.

Lastly we see the phase `SAVE_EXPORTED_VARIABLES` This phase is extracting the variables that we specified in the `vars.exportVariables` section in the `build_spec.yaml` file, as tith the output artifacts if we didn't do this they would die when the stage completes (along with everything else not copied out of the the build runner). By requiring the explicit identification of the output from a build stage we avoid polluting subsequent stages with unexpected artifacts and variables - and remember that the people designing one build stage may be different than those designing another, so coordination between the teams designing a build phase is essential to ensure that the expected variables and artifacts (and only those) are transfered between stages.