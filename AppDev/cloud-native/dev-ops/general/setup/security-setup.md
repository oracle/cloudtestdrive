
Setup a devops user group in the identity services


IMPORTANT unless otherwise told you **MUST** run the setup steps and actual devops lab in the same compartment as the OKE cluster.

If you are doing this lab in a free trial tenancy as part of an Oracle event then you will be the tenancy administrator so can do all of the following yourself, if however you are in a shared or paid tenancy then you may need to get the tenancy administrator (or someone who has the ability to make changed assigned to them) to do these steps. 

In the following instructions you will need to make some substitutions where you see `<YOUR INITIALS>` in the text please replace them with your initials, for example If you were named `John Smith` you'd use `JS`. If you think there will be multiple people using the same tennancy (in a lab using free trial accounts this is unlikely to be the case) with the same initials then please decide between yourselves on different ones to use. We do this so if you are running this lab in a shared tennancy then each user will have their own setup.

You will also need to substitute <`compartment name` with the name of the compartment you are using, in a lab using free trial accounts this is likely to be `CTDOKE` is however you are using a corporate ot Oracle internal tennancy then this may be different. 

Finally you may need to substitute `<Your Compartment OCID>` with the OCID of your compartment - there are instructions on how to get this below.

The following steps are done using the OCI web based interface

First we need to setup some policies and dynamic groups to allow the build and deploy pipeline to manipulate other resources


Create the group <YOUR INITIALS>DevOpsUsersGroup in the Identity and Security section

Assign your user to it.

Note that if using federated identity (by default Free trial accounts will not be using this) then you will need to get the federated identity admin to create a group in the IDCS and assign your user in IDCS to the group. Then the tenancy admin can create a the group  <YOUR INITIALS>DevOpsUsersGroup and map it onto the IDCS group just created


Locate the compartment OCID your OKE cluster is in, you will be creating and running your build pipelines in here. Go to Identity & Security -> Compartments. Locate your compartment in the list (If needed navigate to it using it's parents) Once you can see your compartment click the test in the OCID column, then in the popup click the copy button. Save this OCID away in a text edit / note pad or something, you will need it a few times in the next steps.

In Identity and security -> Dynamic groups

Create the following dynamic groups

This identifies the build services resources
Name it <YOUR INITIALS>BuildDynamicGroup
ALL {resource.type = 'devopsbuildpipeline', resource.compartment.id = '<Your Compartment OCID>'}

This identifies the OCI code repositories resources
Name It <YOUR INITIALS>CodeReposDynamicGroup
ALL {resource.type = 'devopsrepository', resource.compartment.id = '<Your Compartment OCID>'}

This identifies the deployment tools resources
Name It <YOUR INITIALS>DeployDynamicGroup
ALL {resource.type = 'devopsdeploypipeline', resource.compartment.id = '<Your Compartment OCID>'}

Now create the policies. Go to Identity & Security -> Policies
Note you have to set the policies in a parent of your compartment, so if your compartment is /CTDOKE (most likley if you are running in a free trial account) then in the Compartment selector (Under List scope on the left side of the UI) make sure that the root is selected (this will be your tenancy name followed by (root) )
If however your compartment is say MyProject within another compartment, for example /Dev/MyTeam/MyProject then the easiest approach is to make sure in the compartment selector that /Dev/MyTeam is chosen.

Create the following policies  - note that you should replace <compartment name> with the name of the compartment you created / are using for the lab, if you are doing this lab externally then that will probably be CTDOKE, if you are doing this in a non free trial and your compartmenbt is say /Dev/MyTeam/MyProject then <compartment name> would neet to be replaced by `MyProject`

This policy allows the user group to do interact with the devops services
Allow group <YOUR INITIALS>DevOpsUsersGroup to manage devops-family in compartment <compartment name>

This policy allows the dynamic group of build resources resources to create build runners and the similar things
Allow dynamic-group <YOUR INITIALS>BuildDynamicGroup to manage all-resources in <compartment name>

This policy allows the deployment tooling to interact with the destination systems (OKE, Functions etc.)
Allow dynamic-group <YOUR INITIALS>DeployDynamicGroup to manage all-resources in compartment <compartment name>

If you want to see the official documentation on setting these up then please see
https://docs.oracle.com/en-us/iaas/Content/devops/using/devops_iampolicies.htm