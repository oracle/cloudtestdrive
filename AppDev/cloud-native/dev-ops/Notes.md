

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

