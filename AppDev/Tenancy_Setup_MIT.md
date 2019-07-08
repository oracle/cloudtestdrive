# Setting up a Cloud Tenancy for a MIT session

## Introduction ##

This page describes the steps to prepare an Oracle Cloud Tenancy for the MIT type of Hands-on activities.  Following types of activities need to be performed:

- Identity Management
  - Group creation (idcs and oci) and linking between groups
  - On-boarding of workshop participants
  - Generic API user creation
  - Compartment creation
  - Policy definitions
- Creation of required Cloud Service instances



## Identity Management activities

### Group Creation

#### IDCS groups

- Navigate to the PaaS Console, and select User Management
- Select the Identity Console, and navigate to the Groups screen
- Add a group for the workshop, for example: **MIT-Group**

#### OCI groups

- Open a second window where you navigate to the OCI console
- Navigate to the Identity menu, and select **Groups**
- Create a new group, preferably the same name as used for the IDCS group: **MIT-Group**
- Create a second group for the Developer Cloud Service, called **DevCSGroup**

#### Linking idcs and OCI groups

- On the OCI console, navigate to the "Identity" and "Federation" menu
- Open the existing federation profile **OracleIdentityCloudService**
- Select "Group Mapping" in the menu on the right
- Click the "Edit Mapping" button
- Scroll down to the bottom and hit the "+ Add Mapping" button
- Select the IDCS group and the OCI groups you just created: MIT-Group and MIT-Group



### User onboarding

Participants to the workshop need to be defined as a user on the level of the Identity Management service of the tenancy.  This can be done in 2 ways:

#### Manual

- Navigate to the PaaS console
- Open the IDCS console, and navigate to the User Definition page
- Add each user manually, by specifying a username & email.  The user will receive an email where he can set his password

#### Self-registration

- Navigate to the PaaS console
- Open the IDCS console, and select the "Settings" and "Self Registration" page
- Add a new profile, referring to the IDCS group you created previously
- Activate the new profile, and note the ID of the profile.  You will need this to construct the link of the self-registration profile to be shared with the participants
- Construct the URL as follows:
  - https://idcs-<your_idcs_id>.identity.oraclecloud.com/ui/v1/signup?profileid=<self_registration_profile_id>
    - You can copy the idcs_id from the URL to the idcs console you are on
    - Copy the self_registration_profile_id from the self-registration profile you just created
- Test The URL

### API User Creation

For executing infrastructure operations via the API interface of the Cloud Tenancy, we need a native OCI user with the appropriate privileges and certificates.

- Navigate to the OCI console
- In the menu **Identity**, select the **User** item
- Create a new user called api.user
- Create an Auth Token, and note down the passphrase
- Create an API key, and note the fingerprint
- Add api.user to the DevCSGroup group

### Compartment creation

- Create a compartment for the workshop, called **MIT-Compartment**

#### Policy Creation

Create a policy for the MIT-Group, referring to the compartment you just created

- Navigate to the **Identity** and then **Policies** menu
- Create a new policy, with following items, to grant all rights in the 
  - Allow group MIT-Group to manage all-resources IN COMPARTMENT MIT-Compartment
  - Allow group  MIT-Group to read all-resources in tenancy
  - Allow group MIT-Group to manage repos in tenancy
  - allow group MIT-Group to manage functions-family in compartment CTDOKE
  - Allow group MIT-Group to manage buckets in tenancy
- Create a second policy for the Managed Kubernetes service
  - allow service OKE to manage all-resources in tenancy
- Create a third policy for the Developer Cloud Service:
  - ALLOW GROUP DevCSGroup to manage all-resources IN COMPARTMENT DevOciComp
  - ALLOW GROUP DevCSGroup to read all-resources IN TENANCY
  - Allow group DevCSGroup to use tag-namespaces in tenancy       



## Cloud Service Instance Creation

To make it easy to execute the labs by the particpants, we will create the relevant Cloud Services upfront and perform the required configuration.

### VBCS Cloud

- Navigate to the PaaS Dashboard
- Make sure the **Visual Builder** service is visible in the dashboard.  If necessary, select it via the button **Customize Dashboard**
- Navigate to the Visual Builder Cloud Console
- Create a new instance
- Once the instance is created, navigate to the IDCS console, select the **Applications** menu locate the DevServiceAppAUTO_<your_instance_name> application
- Add the group **MIT-Group** to the Application Roles called **DEVELOPER_ADMINISTRATOR** and **DEVELOPER_USER**

### Developer Cloud

A detailed explanation for setting up Developer Cloud can be found following the below link, and executing steps 1 and 2:

- [Link to environment setup](ATP-OKE/env-setup.md)

### Managed Kubernetes

Setting up an instance of Managed Kubernetes for deploying containers

- Request a Limit Increase for the required number of OKE instances you are expected to be using in your environment.  This parameter is not yet visible in the Service Limit dashboard, so it is best to request this beforehand.
  - Select the Service Limit Increase menu
  - Select the Service Category **OKE**
  - Select the Resource **OCI Container Engine for Kubernetes**
  - Select the limit required

- Detailed instructions are available on the link below:
  - Link to Step 3 - [Setup your Managed Kubernetes Instance](ATP-OKE/LabGuide660OKE_Create.md)

### Functions

If required you can request access to the Functions service, only available in Limited Availability.  For this you need to communicate your **tenancy name** and **tenancy OCID** to your Oracle contact.

