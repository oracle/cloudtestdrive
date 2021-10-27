
Setup a devops user group in the identity services


IMPORNT unless otherwise told you **MUST** run the setup steps and actual devops lab in the same compartment as the OKE cluster. 

setup policies - my compartment OCID ocid1.compartment.oc1..aaaaaaaac23qko3ji4d2j745sdn5e4vbc5e6pzocv73kubbippqkpyvkdgha

First we need to setup some policies and dynamic groups to allow the build and deploy pipeline to manipulate other resources


Create the group <YOUR INITIALS>DevOpsUsersGroup in the Identity and Security section

Assign your user to it.

Note that if using federated identity (by default Free trial accounts will not be using this) then you will need to get the federated identity admin to create a group in the IDCS and assign your user in IDCS to the group. Then the tenancy admin can create a the group  <YOUR INITIALS>DevOpsUsersGroup and map it onto the IDCS group just created


Locate the compartment OCID your OKE cluster is in, you will be creating and running your build pipelines in here. Go to Identity & Security -> Compartments. Locate your compartment in the list (If needed navigate to it using it's parents) Once you can see your compartment click the test in the OCID column, then in the popup click the copy button. Save this OCID away in a text edit / note pad or something, you will need it a few times in the next steps.

In Identity and security -> Dynamic groups

Create the following dynamic groups

This identifies the build services resources
Name it <YOUR INITIALS>BuildDynamicGroup
ALL {resource.type = 'devopsbuildpipeline', resource.compartment.id = 'ReplaceThisTextWithYourCompartmentOCID'}

This identifies the OCI code repositories resources
Name It <YOUR INITIALS>CodeReposDynamicGroup
ALL {resource.type = 'devopsrepository', resource.compartment.id = 'ReplaceThisTextWithYourCompartmentOCID'}

This identifies the deployment tools resources
Name It <YOUR INITIALS>DeployDynamicGroup
ALL {resource.type = 'devopsdeploypipeline', resource.compartment.id = 'ReplaceThisTextWithYourCompartmentOCID'}

Now create the policies. Go to Identity & Security -> Policies
Note you have to set the policies in a parent of your compartment, so if your compartment is /CTDOKE (most likley if you are running in a free trial account) then in the Compartment selector (Under List scope on the left side of the UI) make sure that the root is selected (this will be your tenancy name followed by (root) )
If however your compartment is say MyProject within another compartment, for example /Dev/MyTeam/MyProject then the easiest approach is to make sure in the comparment selector that /Dev/MyTeam is chosen.

Create the following policies
Allow the user group to do devops stuff
Allow group MyUserGroup to manage devops-family in compartment name

Allow the dynamic group of compute resources to do stuff
Allow dynamic-group <YOUR INITIALS>BuildDynamicGroup to manage all-resources in compartment replace with the compartment 

Now need to setup for deployments
Create a dynamic group TGDevopsDeployPipeline {resource.type = 'devopsdeploypipeline', resource.compartment.id = '<compartment_ocid>'} 

In parent copmpartment create policy

TGDevOpsDeployPolicy - Allow dynamic-group TGDevopsDeployPipeline to manage all-resources in compartment Tim

policies stuff
https://confluence.oci.oraclecorp.com/pages/viewpage.action?pageId=554345218

For this lab we're going to be using the results of the Kubernetes hands on lab, this has two microservices, storefront that does simple business logic and stockmanager that interacts with the database. These have already been deployed into our cluster and we are going to use the CI/CD tools to update the storefront microservice

make sure you have an auth token USING SSH setup (the PEM one won't work)
create an ssh key pair - in cloud shall use ssh-keygen

to convert an ssh key pair intpo the PEM one required by the auth token
ssh-keygen -f ~/.ssh/id_rsa.pub -e -m pkcs8 | pbcopy

make sure that once you've done that you setup the .ssh/config file like this (note that you drop the oracleidentitycloudservice if not using federation)

Host devops.scmservice.*.oci.oraclecloud.com
  User oracleidentitycloudservice/tim.graves@oracle.com@oraseemeatechse
  IdentityFile ~/.ssh/id_rsa

Create the git repo in the dev ops project

we're going to create our own copy of the repo - this is faster than doign all of the setup to setup an ongoing mirror

https://docs.github.com/en/repositories/creating-and-managing-repositories/duplicating-a-repository

Clone your source repo into a directory (use githib to get the clone command of the remo)

get the ssh clone path (it says it's read only, ignore that for now)

Add the git as a new remote
git remote add devops ssh://devops.scmservice.eu-frankfurt-1.oci.oraclecloud.com/namespaces/oraseemeatechse/projects/DevOpsLab/repositories/cloudnative-helidon-storefront
 
 Push the git repo - lot's of output, numbers may vary
git push devops
Enumerating objects: 97, done.
Counting objects: 100% (97/97), done.
Delta compression using up to 16 threads
Compressing objects: 100% (86/86), done.
Writing objects: 100% (97/97), 43.58 KiB | 4.84 MiB/s, done.
Total 97 (delta 20), reused 20 (delta 4)
remote: Resolving deltas: 100% (20/20)
To ssh://devops.scmservice.eu-frankfurt-1.oci.oraclecloud.com/namespaces/oraseemeatechse/projects/DevOpsLab/repositories/cloudnative-helidon-storefront
 * [new branch]      initial-code-added -> initial-code-added

 can go look at it in the repo now if you want
 
 This command gets the version info from the status resource
 grep "VERSION = " /Users/tg13456/Development/cloudnative-helidon-storefront/helidon-storefront-full/src/main/java/com/oracle/labs/helidon/storefront/resources/StatusResource.java  | awk '{print $7}' | sed -e 's/"//g' -e s'/;//'
 
 
USE THE CLOUD SHELL
 
IN THE LAB SETUP THE VAULT AND MASTER KEY
IN THE LAB Create and setup the users ssh key 
ssh-keygen -t rsa -C "<user.alias>@example.com"

IN THE LAB setup the users .ssh/config
Host devops.scmservice.*.oci.oraclecloud.com
  User oracleidentitycloudservice/tim.graves@oracle.com@oraseemeatechse
  IdentityFile ~/.ssh/id_rsa
  
  the host allows access to any of the git repos in the service
format is User <username>@<tenancy name>
that's the user name oracleidentitycloudservice/tim.graves@oracle.com
tenancy oraseemeatechse

IN THE LAB Create the notifications topic name it DevOpsLab
IN THE LAB create the DevOps project using the notification
Enable logging on the project page
IN THE LAB Show how to do a git pull from the public repo
git clone https://github.com/oracle-devrel/cloudnative-helidon-storefront.git
IN THE LAB CREATE THE GIT REPO (don't set it up as a mirror) name it cloudnative-helidon-storefront leave the default branch blank
add the new git repo as a destination and remove the origional
switch to our local repo
cd cloudnative-helidon-storefront
tell git who we are
  git config  user.email "you@example.com"
  git config user.name "Your Name"

switch to the right branch (if needed)
git checkout initial-code-added

in the git page click clone, get the ssh key - MUST have setup ssh keys in your account and update the .ssh/config file
git remote add devops ssh://devops.scmservice.eu-frankfurt-1.oci.oraclecloud.com/namespaces/oraseemeatechse/projects/DevOpsLab/repositories/cloudnative-helidon-storefront
for saftey remove the connection to the origional - shoudln't be able to push to this anyway, but just to prevent me getting lot's of pull requests !
git remote remove origin

make sure we're up to date with the remote repo in our local branch
git remote (should only have devops)

 make sure we're "up to date" with our new code repo
git pull devops main

git push devops initial-code-added

Let's have a look at the state of our project code repository


let's explain the build pipeline, this is sadly in YAML :-( go to the code repo then navigate to helidon-storefromt-full/yaml/build/build_spec.yaml 

Variables
variables names in this section persist across build steps, but not across pipeline stages unless explicityly exported
vaultVariables are replaced with the content of the vault secrets we will setup soon, these also persist across steps, but they cannot be exported themselves to prevent leakage of confidential information like logins and so on that are often stored in these variables
exportedVariables are passed out of the build process to the following stages, ONLY variables named here are exported, so if you want a standard or vault variable to be exported you need to specify it here, you can't export a vaultVariable for security reasons, so if you want to do that you have to crate another variable to export, then in one of the stages transfer the values over.

Note that it's also possible to define parameters that you can set when the pipeline is run, those are processed as ${VARIABLE_NAME} we'll look at how to set them up later on

Steps - these are individual stages executed by the build pipeline, the run in the same OS instance, BUT not in the same shell instance. If you want a variable to persist across steps you need to specify it in the variables section. Note that some variables like PATH are automatically persisted across sessions for you and you don't need to specify them.
Each step has a name and timeout (in case the step hands for some reason) unless otherwise specified it will run as root
The core of the step is the commands that it runs, 

In our step 1 "Extract Export variables" we setup the variables and extract the version information from the code, other ways to get the version are of course available, we could even feed it into the pipeline and then modify the code to match the version if we wanted !
Note that we also "transfer" the values form out vaultVariables OCIR_HOST_VAULT to the exported variable OCIR_HOST, this is because vaultVariabls cannot be exported, nut we can of course create another variable that is exported and deliberatly copy the value over.
Notice the cd ${OCI_PRIMARY_SOURCE_DIR} - this is how we make sure we are in the location for the git prohecxtr that has been automatically imported into the build pipeline for us. OCI_PRIMARY_SOURCE_DIR contains the location in the build image of that git repo
One other section that's important is the onFailure section. There can be many reasons for a failiure, in the case of this pupeline everything is handled in the build instance, but in some cases there may be external side effects and cleanup may need to be done. The onFaliure section allows us to specify what to do, though in this case it's just displaying a message, Like the main step a failure handler can also have a time out and may need to run as a specific user

Let's have a look at the other steps
The 2nd step named "Install local JDK11" this has the same structure as the previous step, but it downloads and installs a JDK for us. We need to do this to ensure that we know exactly what JDK is used to run the build. The image used to run the buiuld process does have a JDK in it, but it may not be the one we expect, so this way we know wehat we're getting

As you can see this updates  JAVA_HOME which we defined earlier as a vatiable so it will be automatically transfered between build stages. The PATH is automatcally trnsfered

Step 3 "Confirm Variables and versions" it really there to enable us to confirm what the settings are, it's not needed for the build, but it helps to diagnose potential problems due to wront versions shoudl they occur

Step 4 "Build Source and pack into container image" is what does the actual work, this really just calls mvn, we should really have installed the version of mvn as well, but as mvn is basically a framework that doenloads it's own build engine (using the version specified in the pom.xml file) for now that's not critical - and I don't want to spend all day downloading stuff !
The mvn package process uses a tool called JIB (Java Image Builder) that will create a local docker image called jib-storefront (have a look at the pom.xml file to see more on how that's configured) we'll see the images in the output of the docker images command which is run once the mvn command has finished.

Step 5 "Fix resources location in container image" is needed because jib doesn't put the resouces in the locations expected by the Helidon framework and the Java run time (in theory the location is correct, but if you just use that image the code fails as it can't find the resoiurces, I'm still trying to resolve that one)
This step runs a small docker file which copies the commands to the correct location in the image then deletes the old resources location 

Notice that we didn't do a docker push to upload the image to the container registry, we could have, but that woudl mean getting the users login credentials in to the image, and fortunately for us the devops tooling provides a way to avoid doing that using the outputartifacts section.

output Artifacts tells the build pipline what the results of the build are, once it's completed the steps you specified the pipeline will automatically extract the items specified in the output artifacts section and save them away for later use in the next staged of the pipeline, thois could be another build stage (in which case the build_spec of that stage will define input artifacts that match the ones you've just outputted)
Note that the output artifacts include not only the container image we build, but alto the YAML files containing the Kubernetes manifests. We're not modifying those in the build pipeline, but as we want to use them later on we need to specify that they are also output artifacts

The vaultVariables to need to be specified, even though they are not used  these are used in naming the container images we produce when they are uploaded to OCIR, 

We're going to be making changes to the code later on, so let's create a new git branch to hold these so we don't modify with the underlying code

git checkout -b my-lab-branch
git branch --list


Firstly we're going to setup some secrets in the OCI vault, I created the vault and the master encryption key earlier so we can just setup the secrets
be sure to use plain text
Create the secret OCIR_HOST value is fra.ocir.io (or other region)
SAVE THE OCID in a note pad or something
Create the secret OCIR_STORAGE_NAMESPACE value is oraseemeatechse (or yours)
Save the OCID in a note pad or something


Using edit the helidon-storefront-full/yaml/build/build_spec.yaml file in the cloud shell, set the OCIR_HOST and OCIR_STORAGE_NAMEPACE OCIDs
git commit -a -m 'Set secret OCIDs'

Now push the repo branch to the OCH Code repo you just created
git push devops my-lab-branch



In the project create a build pipeline, name it BuildStorefront

remember that the devops variable ${OCI_PRIMARY_SOURCE_DIR} is the location the primary git repo is downloaded to
for the cloudnative-helidon-storefront this means that build spec is in ${OCI_PRIMARY_SOURCE_DIR}/yaml/build/build_spec.yaml

probabaly not to explain in the video
Note that this build_spec.yaml is already created, but to avoid doing many changes tot he file, then pushing and running the build process if you wanted to validate the commands in it you could just run the docker container iad.ocir.io/idllbnfszw6v/commandstep:latest at least at the moment !


Add a stage, type managed build, name BuildStorefront you can't change the build shape at the moment, OS is OL 7 x86_64 standard:1.0
set the build spec part to the location in the repo which is helidon-storefront-full/yaml/build/build_spec.yaml
Set the primary code repo to be the one you just pushed to, for now chose the my-lab-branch
set the build source name to be Storefront
Don't add any further repos
add the stage

Note that if appropriate you can have parallel stages, perhaps you are building multiple library files first which can all be build independently, then combining them all in a last deploy stage and linking the intermediate artifacts with outputArtifact / inputArtifact entries in their build specs

do a manual run on the stage
Make a cup of tea while the build runner is provisioned and the pipeline runs, not that the step progress bar runs faster than the logs as the logs are only updated every 30 seconds or so
 Eventually you will see the log data, note that there is a **lot** of log data from the maven build process as it downloads many, many jar files for the build and also the packaging step using jib
 
 The BuildStorefront stage can be expanded to see the individual steps as they run, unfortunately there is no mechanism to isolate the log output on a step by step basis, but you can search in the logs using the "Find" box at the top of the log output

You can look at the logs later by going to the logs menu, then clicking on the log name, this works, but as you have a detailed history of each build it's easier to just look at them
open the build pipleines history
show the logs in there

The build should have worked, use the scroll bar (it's hidden on Safari !) to scroll to the bottom, you will see the message "Starting SAVE_OUTPUT_ARTIFACTS" and the artifacts we specified in the output stage will be shown, but where have the gone ? The answer is that they are stored in data structures associated with the build pipeline, nbut that's not mush use to us, we need to get them to somewhere we can do somethign useful with.
 
Note we could do a docker push in the build pipeline, we're going to use the deliver artifacts stage, that means we need the output artifacts to be uploaded

We're going to create the container repo first, though the policies I've applied allow the creation of repos dynamically the upload artifacts stage doesn't seem to want to upload container images to a repor that doesn't exist.
Go to the container repo in the compartment and region specified
DeveloperServcies -> Container Registry check compartment 
Create the repo <YOUR_INITIALS>/storefront  make it public for now
We'd need one of these for each container image type you will upload, but for this lab we'll only be doing this with the storefront deployment

Now we'll create  the artifact registry 
DeveloperServices -> artifact registry -> create repo, name it <Your initials>DevOps
Confirm the compartment
set the immutable to be off, in production you  wouldn't do this as imuttable artifacts can never be re-used (this is for security purposes, and also to ensure that deployments are reprodicible) but for the lab where you will be doing multiple tests with the same version that woudl just make things difficult so we'll allow for replacement for now

Create the YOUR_INITIALS **build pipeline ** param, default to <your initials> this will be used by the output artifacts stage, but there is no mechanism to specify params for just that stage so we need to do it on the entire build pipeline - to "commit" the param we need to click the + button

No we have the places to store the artifacts we need to extract them form the build pipeline, the artifacts are currently "hanging around" in the build pipeline, the outputArtifacts stage of the build process saved them somewhere in the build pipeline, but that's not permanent, they are just held for other pipeline stages (which have their own runner) so make use of them we need to upload them to OCIR and the artifact registry
I appreciate that this as an additional stage is a bit of an irritation - esp for artifacts that are in effect being copied from the git repo, but this is needed because the deploy processes don't know about the git repo, they only know about OCIR and the artifact repo, so if the container image / YAML files aren't there then the deploy engine can't deploy them. One reason that it doesn't know about them is that the deployment pipelines can run independently of the build pipelines, some customers may use a different build tool like Jenkins, but then upload the outputs to the registries and then use the DevOps CD tooling for the final delivery.


the output artifacts stage  is where we do the tagging and so on, note that this uses the build pipeline variables as part of the naming,

Create a new stage using DeliverArtifacts
Name it UploadStorefrontArtifacts

We need to specify the artifacts to extract and store

First we're going to do the YAML files, yes I know that this doesn't make sense but remember the build pipelines only use the artifact repo and don't know about the git repo (hopefully that will change) so we have to copy them across

In the artifacts chose Create artifact (remember the deploy artifacts phase is about uploading new artifacts from the build, not using existing ones - We could have previously defined the artifacts description, but for now we'll do that here. Understand that this is defining what the build output will be, this is not connecting to an existing artifact in the registry, the output artifacts stage will use this template to upload the artifact making it "real" and then the deploy stage can use that artifact

Set the name to be StorefrontServiceYAML
Set the type to be Kubernetes manifest
Set the artifact registry to be the one we just created (check the name, region and compartment to be sure)
Set the location to be Set a custom artifact location and version
Set the path to be serviceStorefront.yaml
Set the version to be ${STOREFRONT_VERSION} this is a param exported from the build process (in the build process we extract it from the source code, so we know we match the image and YAML versions with the code version)
Make sure that replace parameters is set to Yes, substiture placeholders - this will mean that the variables we have specified like ${STOREFRONT_VERSION} will be replaced during the artifact creation phase with their values


Click add

Let's create the other two YAML artifacts, do the above process
All have the same settings except name and path
First
Named StorefrontIngressRuleYAML  path is ingressStorefrontRules.yaml
Second named StorefrontDeploymentYAML path is storefront-deployment.yaml

Now let's setup the container image location
Click create artifact
Name if StorefrontContainer
Type is Container Image Repo
Artifact source is ${OCIR_HOST}/${OCIR_STORAGE_NAMESPACE}/${YOUR_INITIALS}/storefront:${STOREFRONT_VERSION}
Note that OCIR_HOST and OCIR_STORAGE_NAMEPACE are variables specified in the build file as coming from the vault secrets
STOREFRONT_VERSION is generated withuiin the build spec and names as an exported variable
YOUR_INITIALS is a param we pass to the build process, though it could of course come form the vault we use YOUR_INITIALS so that if there are multiple people running the lab in the same tenancy we have a good chance to keep things separate !

FYI the artifacts we have defined here could in theory be used by other pipelines in the project 9or even other projects using the repo) but be careful with this, often they are unique to a deployment, so be carefull if you re-use them

We have defined where the artifacts are going, but we havent connected the outputartifacts to the ultimate destinations yet.

Here we created the artifacts as part of defining the stage, we could of course have done this in advance using the artifacts side tab

In the stage section scroll down a bit past the artifact selections to the Associate Artifacts with Build Result section

You can see the artifacts that are in the list, we now need to specify the names in the build outputs for each artifact.
StorefrontServiceYAML -> service_yaml
StorefrontIngressRuleYAML -> ingressRules_yaml
StorefrontDeploymentYAML -> deployment_yaml
StorefrontContainer -> storefront_container_image

Note that we have not provided any OCI credentials, this is a major advantage of using the upload artifacts process, if we had done this within the build spec we'd have had to do docker logins, setup a .oci credentials folder and so on as part of the build process, though a little clunky at the moment this is far easier overall !

the YAML files themselves contain params (can look at this in the git repo for the ingress rule) clearly structure of paramed values (like image location) needs to map to the ones in the repo show the deployment file and note the KUBERNETES_NAMESPACE and image location variables used in the yaml, but we haven't set that yet. We will do that in the deployment phase. Note that we have paramed the region, the tenancy object storage namespace, the version and the intiials (to split things out if lots of folks are running this in the same tenancy / compartmnent) these are params available form the build spec, the inputs to the build pipeline or generated withiin the build pipeline.

Let's run this with the Upload Artifacts stage now

Note that there are two stages listed in the outputs, the log file will hold all of them, but you can click on the three dot's 

While this is running we can have a look at the build pipeline history.  click the "build history" you will see the current pipeline as being in progress, you can also see the pipeline we ran earlier, click on that to review it's output if you want to 


After the run show that the artifacts stage happened (show the output) and that the artifacts do indeed exist in OCIR and the artifact registry  with the versions (or for OCIR full path) as specified.

Download the storefront-deploy.yaml to look at, note that though the **path** has been updated based on the various variables the **content** is unchanged, and we have place holders for KUBERNETES_NAMESPACE and so on, these will be substituted with params in the deployment pipeline phase (the params can also be set on the deployment pipeline as well as the build pipelines)



For the deploy process

Link the environment to the OKE environment, name the env it StoreOKE


Create a depoloyment DevOpsStorefrontDeploy in this case

Create a param called EXTERNAL_IP and set the default to the IP address to be the external IP of your cluster ( 130.162.40.241 ). This will be used when we deploy the ingress rule due to the specifc nature of the way we handle certs in this lab (explain about DNS and certs and duration) in a real-world you'd probably use a param to hold the DNS name rather than the IP (though that is kind of what we're doing here) 
Create a param called KUBERNETES_NAMESPACE to define the namespace we're going to deploy into, set the default to be the namespace you've been using in the OKE lab

Note that in the yaml we specify the namespace as a variable, means we don't need to specify it in the deployment process. This is different from the origional lab where we set default namespace so use in the kubectl configuration


First add the deployment for the deployment itself and the service.

Name DeployStorefrontDeploymentAndService
Description Deploys the Storefront deployment and the service that matches it
Environment DevOpsLab

Artifacts StorefrontDeploymentYAML and StorefrontServiceYAML Note that we are specifying ${STOREFRONT_VERSION} this variable is "inherited" by the deployment pipeline from the build pipeline and we defined in the build spec that ${STOREFRONT_VERSION} was an exported variable

Namespace as default
rollback as yes

Click save


How does the variable for the version of the image get passed though ? When we defined the container image artifact you remember that we defined the path ${OCIR_HOST}/${OCIR_STORAGE_NAMEPACE}/${YOUR_INITIALS}/storefront:${STOREFRONT_VERSION} for the artifact and also defined this in the StorefrontDeploymentYAML
Build pipeline variabels are automatically transfered to the deploy pipeline and as part of the deployment process the variables specified in the deployment yaml are substituted when we deploy the deployment, those variables will match the ones used when the artifact was uploaded - so we can use variables to automativally ensure we are on the correct version - of course the ones in the deployment yaml must match the ones in the artifact definition !

Add a stage to deploy the ingress rule, we do this after as we need to have the service available before the deployment, and if we want to have something running we can interact with then the deployment needs to be in place. If we did the ingress rule first then things might get out of order

Name DeployStorefrontIngressRule
Description Deploys the ingress rule, this needs to be done a after the service has been deployed so it's got something to match against
To your environment (DevOpsLab)

Select the artifact StorefrontIngressRuleYAML note this also picked up the version information from the artifact stage

Leave the namespace override as blank / default

If validation fails do a rollback

Of course we don;t deploy the container image here, that's deployed by kubernetes itself when the storefront-deployment.yaml is deployed

Lastly we can link the build pipeline to 
name a deploy pipeline. 
In the build pipeline create a new stage of type Trigger deployment
name DeployStorefrontToOKE 
description Delivers the build to OKE
Select the deploy pipeline we created earlier


Now we can do a pipeline run with a deploy.
Let's check what the status version currently returns
in the OCI Cloud shell do curl -i -k https://store.$EXTERNAL_IP.nip.io/sf/status

edit helidon-storefront-full/src/main/java/com/oracle/labs/helidon/storefront/resources/StatusResource.java with the new version (0.0.3), there are of course other ways to do this with properties files, pulling the maven project info and the like
Commit and push the new version
git commit -a -m 'Update version'
git push devops my-lab-branch

Run the build
Wait .....
Notice we have the deploy stage now

WARNIG, the deploy stage is considered sucesfull if it triggers the deploy pipleint, to see how that's going you need to switch to that, click the three dots, then chose view deployment


once deployed rerun curl -i -k https://store.$EXTERNAL_IP.nip.io/sf/status it's version 0.0.3


Finally we're going to add a trigger that will cause a git push to start the process

On the left hand menu create the trigger

Name it StorefrontMyBranchTrigger
Set the connection to be OCI Code Repository
Select your repo in the list
Click add action
Chose your build pipeline from the list
Set it to trigger on a push
Chose the branch as my-lab-branch - will only trigger on that branch

(note you could of course have other triggers on other branches with a different build / deploy pipelibne for say a commit to  main that delivers into test (and then potentially production), but a commit to the other branch commits to a dev env 

update the version in helidon-storefront-full/src/main/java/com/oracle/labs/helidon/storefront/resources/StatusResource.java to 0.0.4
Commit and push the new version
git commit -a -m 'Update version to test trigger'
git push devops my-lab-branch 
the push will trigger the build

Go to the build pipelines page, look at the build history
Notice this is called StorefrontTrigger now
The pipeline is in progress, come back in a little bit

once it's finished then access the status
 curl -i -k https://store.$EXTERNAL_IP.nip.io/sf/status

now it reports v 0.0.4






(can delete that branch at the end with of the lab with git branch -d my-lab-branch if you want, then push the repo with the deleted branch)

