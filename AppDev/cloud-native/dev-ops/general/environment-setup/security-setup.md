![](../../../../../common/images/customer.logo2.png)

# Configuring OCI security for DevOps

## Introduction

The Oracle Cloud Infrastructure (OCI) provides a comprehensive set of security mechanisms to control actions within tenancies. One core element of this approach is that security is enabled by default, so to take actions users need to be granted permissions. The tenancy admin of course has full capabilities when the tenancy is setup.

Even though tenancy admins may have full admin rights the DevOps service itself needs to be able to manage other resources, for example to run a build it needs a compute instance and to deploy it needs to be able issue commands against the deployment target (Functions, Kubernetes etc.) so we need to configure policies to allow this.

### Objectives

Using the OCI Cloud shell and Browser User Interface we will :

  - Create user group of users that will run the DevOps services
  
  - Define a policy allowing that group to run DevOps activities in a compartment
  
  - Create dynamic groups defining the DevOps service elements
  
  - Define policies allowing the DevOps service elements to manipulate other services within the compartment.
  
### Prerequisites

You will need to be a user with administrative rights to define policies, dynamic groups and create and manage user groups. If you are using a free trial then you will almost certainly be the admin of that tenancy and have full rights. If you are operating in a commercial or other tenancy then you may not have the admin rights, and may need to ask your tenancy administrator to configure the tenancy security as described below.

Setup a devops user group in the identity services

## Task 1: Gathering information

IMPORTANT unless otherwise told you **MUST** run the setup steps and actual devops lab in the same compartment as the OKE cluster.

If you are doing this lab in a free trial tenancy as part of an Oracle event then you will be the tenancy administrator so can do all of the following yourself, if however you are in a shared or paid tenancy then you may need to get the tenancy administrator (or someone who has the ability to make changed assigned to them) to do these steps. 

In the following instructions you will need to make some substitutions where you see `<YOUR INITIALS>` in the text please replace them with your initials **in lower case**, for example If you were named `John Smith` you'd use `js`. If you think there will be multiple people using the same tennancy (in a lab using free trial accounts this is unlikely to be the case) with the same initials then please decide between yourselves on different ones to use. We do this so if you are running this lab in a shared tenancy then each user will have their own setup. If you used the scripts to create the environment these will have been the initials you used when running the `get-initials.sh` script.

You will also need to substitute `<compartment name>` with the name of the compartment you are using, in a lab using free trial accounts this is likely to be `CTDOKE` is however you are using a corporate or Oracle internal tenancy then this may be different. If you used the script to setup the environment this will be the name you gave to the `compartment-setup.sh` script.

Finally you will need to substitute `<Your Compartment OCID>` with the OCID of your compartment. If you used the scripts to setup the compartment you will have seen this in the `compartment-setup.sh` script output.

### Task 1a: Getting your compartments OCID

Compartment information is held with in the Identity and Access management service.

  1. Open the OCI Web console, Click on the "Hamburger" menu, then **Identity & Security** then **Compartments**
  
  ![](images/compartments-access-service.png)
  
  2. Locate your compartment in the list (`don't click on it) , If your compartment was created as a sub compartment of another you will need to navigate to it by clicking on the names in the hierarchy as if you were using a file manager.
  
  3. Click on the **OCID** for your compartment (for this list there are many compartments, I've chosen the `CTDOKE` one as that was what I used when setting up the compartment in  the earlier instructions). A small popup will display the full OCID, click the **Copy** to copy it to your system
  
  ![](images/compartment-get-ocid.png)
  
  4. Save the OCID you've just copied into a notepad or similar, you will need this later.
  

## Task 2: Defining a group of DevOps users

We need to define a group of users, we will later use this group to create a OCI Security policy that allows users to create, manage and use the Dev Ops service.

  1. Open the OCI Web console, Click on the "shadow" user icon on the upper right, note the user name that's displayed. In trhis case that's `oracleidentitycloudservice/tim.graves` but if you are the administrator of a trial tenancy (highly likely if you are in a Oracle guided lab) you're user name will will include your email address, for example `oracleidentitycloudservice/john.doe@somewhere.com`.
  
  ![](images/bui-shadow-person-menu-username.png)
  
  The next steps will be to create a devops group and assign your user to it. If you are in a free trial tenancy (where you are the administrator) then you can do this yourself, if however you are in a commercial tenancy or using a federated identity system you may not have the rights to do this, in which case you will need to get a the identity administrator to create the group and add you. 
  
  2. Click on the "Hamburger" menu, then **Identity & Security** then **Groups**
  
  ![](images/groups-access-service.png)
  
  Note that the tenancy I'm using to get the images had a number of pre-existing groups, it's likely that a free trial tenancy will not, so ignore the other groups in the list shown here.
  
  3. Start creating the group - click the **Create Group** button

  ![](images/groups-initial-create.png)
  
  4. In the resulting "popup" form, In the **name** field name the group `<your initials>DevOpsUsersGroup` (so for me that would be `tgDevOpsUsersGroup`and in the **Description** put `Users allowed to run the DevOps service` (or anything else you like that describes the group) Click the **Create** button. The group will be created.
  
  ![](images/groups-create-form.png)
  
  5. Click on the newly created `DevOps` group in the list, then click the **Add User to Group** button
  
  ![](images/groups-add-members-initial.png)
  
  6. Click in the **Users** field, a list of all users will be shown, start typing your username and as you type the list will update to only include the matches, in this case I'm using a different user name to show you how this works. **Click on your user from the list of options to select it**. In the image below the tenancy I'm in has many pre-existing users, your user is going to be identified by the email address.
  
  ![](images/group-add-member-select-user.png)
  
  7. It is critical that you actually click on the user name in the list otherwise it won't be selected. Click on the **Add** button to add your user to the list.
  
  ![](*images/group-add-member-user-selected.png)
  
  Your user will now be shown in the list of group members
  
  ![](images/group-add-member-completed.png)
  
## Task 3: Creating the dynamic groups

In OCI there are multiple types of groups, we've seen a group based on users, but it's also possible to create a **dynamic group** which represents resources within OCI itself,usually based on resources in a compartment, and can be further limited to a specific resource type. It's called a **dynamic group** because it matches on any resource, regardless of if the resource was created after the group was created. This means that we can define the group now, and then create the resources it matches against later on.

We are going to create three dynamic groups for identifying the code repositories, the build service and the deploy service
  
  1. Open the OCI Web based interface, Navigate to the dynamic groupspage - Click on the "Hamburger" menu, then **Identity & Security** then **Groups**
  
  ![](images/dynamic-groups-access-service.png)
  
  In this tenancy there are already a lot of dynamic groups, if you are in a free trial tenancy tere will probabaly not be any in the list.

  2. Click the **Create Dynamic Group** button to start the process
  
  ![](images/dynamic-groups-create-group-start.png)
  
  3. In the **Name** field name it `<YOUR INITIALS>BuildDynamicGroup`, In the **Description** enter `This dynamic group identifies the DevOps Build Pipelines`, in the rules section enter this into the **Rule 1** field, replace `<Your Copartment OCID` with the OCID your got earlier for your compartment. `ALL {resource.type = 'devopsbuildpipeline', resource.compartment.id = '<Your Compartment OCID>'}` Click the **Create** button.
  
  Of course in the image below I'm using **my** compartment ID, yours will be different !
  
  ![](images/dynamic-groups-create-group-form.png)
  
  4. The Dynamic group will be created and you'll be taken to it's page. Return to the Dynamic groups list by clicking **Dynamic groups** in the "Breadcrumb" path at the upper right.
  
  ![](images/dynamic-groups-group-page.png)
  
  5. Follow the above process, to create two more groups as described below, remember to replace `<YOUR INITIALS` and `<Your Compartment OCID>` in these groups.
  
  Code dynamic group:

  - Name it `<YOUR INITIALS>CodeReposDynamicGroup`

  - Description is `This dynamic group identifies the OCI code repositories resources`

  - Set the rule to `ALL {resource.type = 'devopsrepository', resource.compartment.id = '<Your Compartment OCID>'}`

  Deployment dynamic group:
  
  - Name It `<YOUR INITIALS>DeployDynamicGroup`

  - Description is `This dynamic group identifies the deployment tools resources`

  - Set the rule to `ALL {resource.type = 'devopsdeploypipeline', resource.compartment.id = '<Your Compartment OCID>'}`
  
  Once you have created the three dynamic groups you will see them in dynamic groups list. It is **critical** that you followed the instructions above and in particular remembered to use the OCID of **your** compartment.
  
  ![](images/dynamic-groups-all-created.pnf)
  
## Task 4: Define the policies

OCI Security uses policies to determine what groups can do. We need to setup policies that will allow our groups to perform operations within OCI. **IMPORTANT** We will be doing this based on your compartment, not on the entire tenancy (which would be a bad thing to do). 

Policies are applied in the parent of the compartment you are operating in, (or actually anything in the hierarchy, but it's easiest to just use the parent). In a free trial tenancy where you created the `CTDOKE` compartment in the tenancy root that means you will be applying the policies in the tenancy root (and these instructions will use that in the examples). However if for some reason you created your compartment as a sub compartment of another compartment you will need to remember to apply the policies in the parent compartment that contains the compartment you created. Of course if you chose a different compartment name you will need to use that instead of `CTDOKE`

  1. Open the OCI Web console, Now create the policies. Click the "Hamburger" menu, then Go to Identity & Security then Policies
  
  ![](images/policies-access-service.png)
  
  2. On the left side of the page locate the **Compartment** selector, In the image be low there are lots of compartments, the list (size and also names) will be different in your case. Click in it and *make certain* that you have selected the *parent* compartment of the compartment you created. If you created the `CTDOKE` compartment in the root (this is what you probably will have done if you are using a free trial and following the instructions) then select the *root*. If for example you had created the `TimGraves` compartment in the `Users-compartment` (this of course is my setup, yours may vary) then you will need to select `Users-Compartment` as that's the parent of the `TimGraves` compartment.
  
  ![](images/policies-select-compartment.png)
  
  3. Click on the `parent` of your compartment, the dropdown will collapse to show it's selected as per the image below. Now click on **Create Policy** to open the Create policy form. (This tenancy has lots of policies already existing in the root compartment, yours probably will not)
  
  ![](images/policies-initial-create.png)
  
  4. Name the policy `<Your initials>DevOpsUsersPolicy` Of course you should replace `<Your initials>` with your initials, so as my initials are `tg` in the example image below I've named the group `tgDevopsUsersPolicy` Set the description to be `This policy allows members of the DevOps user group to interact with the DevOps services`. 
  
  ![](images/policies-create-policy-part1.png)
  
  5. Click the **Manual editor** button if it's not already enabled (it will be grey if not enabled and blue if enabled). In the Policy builder box paste the following AFTER substituting your initials (tg in this image) and your compartment name CTDOKE in this image `Allow group <YOUR INITIALS>DevOpsUsersGroup to manage devops-family in compartment <compartment name>` Then click the **Create** button
  
  ![](images/policy-create-policy-part2.png)
  
  6. The details of your new policy will show up in the UI click **Policies**  in the "Breadcrumb" trail to return to the policies list
  
  ![](images/policy-created-policy.png)
  
  7. Follow the process above to create policies that will allow the build, deploy and code repos dynamic group members (these are built using dynamic groups which will contain resources rather than users) to manage everything in the tenancy (it would be possible to put specific policy approvals in place on specific resources, but for a lab this is easier). Remember you will need to replace `<Your initials>` and `<compartment name>` and also you will need to create these in the **parent** compartment of your compartment.
  
  This allows the code repositories to trigger a build when you do a git push:
  
  - Name `<YOUR INITIALS>DevOpsCodeRepoPolicy`
  
  - Description `This policy allows the dynamic group of code repo resources resources to create trigger the build process`
  
  - Policy text `Allow dynamic-group <YOUR INITIALS>CodeReposDynamicGroup to manage all-resources in compartment <compartment name>`
  
  This allows the Build pipelines to create the build runners when you run a build 
  
  - Name `<YOUR INITIALS>DevOpsBuildPolicy`
  
  - Description `This policy allows the dynamic group of build resources resources to create build runners, and trigger deployments`

  - Policy text `Allow dynamic-group <YOUR INITIALS>BuildDynamicGroup to manage all-resources in compartment <compartment name>`
  
  This allows the deploy pipelines to manipulate the environments they are deloying to
  
  - Name `<YOUR INITIALS>DevOpsDeployPolicy`

  - Description `This policy allows the deployment tooling to interact with the destination systems (OKE, Functions etc.)`
  
  - Policy Text `Allow dynamic-group <YOUR INITIALS>DeployDynamicGroup to manage all-resources in compartment <compartment name>`
  
  Once you have created all the policies if you return to the policies list one more time (Use the "breadcrumb" on the upper left) you will see something like the following
  
  ![](images/policy-all-created.png)
  
  Of course these all use my initials !
  

## End of the Module, what's next ?

Congratulations, you've completed the security configuration to use the OCI DevOps service

Next step is to start creating a DevOps project !

## Acknowledgements

* **Author** - Tim Graves, Cloud Native Solutions Architect, Oracle EMEA Cloud Native Application Development specialists Team
* **Last Updated By** - Tim Graves, May 2023

If you want to see the official documentation on setting these up then please see
https://docs.oracle.com/en-us/iaas/Content/devops/using/devops_iampolicies.htm