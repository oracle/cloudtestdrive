![](../../../../common/images/customer.logo2.png)

# Creating your DevOps project

## Introduction

A DevOps project is the core starting point for DevOps activities within OCI. Is contains pipelines, information on artifacts and of course an OCI Code repository.

### Objectives

Using the OCI Cloud shell and Browser User Interface we will :

  - Create a Notifications topic used for the DevOps services elements to communicate between themselves
  
  - Create a DevOps project
  
 
### Prerequisites

We've done all the background setup needed for DevOps, and have our Kubernetes cluster running with the Storefront and Stockmanager services in place, so it's time to start creating our DevOps projects.

Our first task it to create a notification service that DevOps will use to communicate progress between it's different elements.


## Task 1: Create the notifications topic used by the DevOps service

  1. Open the OCI Web UI, Go to the notifications service page Click the "Hamburger" menu, chose **Developer Services**, select **Notifications** (In the Application Integration section)
  
  ![](images/notifications-access-service.png)

  2. Confirm you are in the right compartment using the compartment selector on the left, if you're in a free trial this is probably `CTDOKE`, but if you're in a commercial tenancy you may have used something different
  
  ![](images/notifications-confirm-compartment.png)
  
  3. Click **Create Topic** top open the create popup
  
  ![](images/notifications-create-topic-initial.png)

  4. In the form enter a name of the form `<YOUR INITIALS>DevOpsTopic`, Enter a description of `Communication between DevOps service elements`, Click the **Create** button
  
  ![](images/notifications-create-topic-form.png)

  5. It will take a short while for the topic to be created, once it has you will see it in the topics list
  
  ![](images/notifications-created-topic.png)
  
## Task 2: Creating the DevOps Service

Now we can create the DevOps service instance

  1. Navigate to the Dev Ops service, click the "Hamburger" menu select  **Developer Services** select **Overview**
  
  ![](images/devops-access-service.png)

  2. Click the **Create DevOps Project** button to open the create project form
  
  ![](images/devops-create-project-initial.png)

  3. Provide a name for your project, this should be `<YOUR INITIALS>DevOpsProject` where you replace `<YOUR INITIALS>` with the actual initials you provided when you ran the `core-environment-setup.sh` script at the start of the lab, sofor me the name would be `tgDevOpsProject` If you don't name your project  like this then you will be unable to use the scripts we provide to do some tasks which will mean you take longer in the labs. Add a description if you want, Click the **Select Topic** button, this will open a new topic selection popup
  
  ![](images/devops-create-project-form-part1.png)
  
  4. In the topic selection popup make sure your compartment is selected and chose your topic (which should be named along the lines of `<YOUR INITIALS>DevOpsTopic`) from the topic dropdown if it's not already selected. Click the **Select Topic** button, the topic selection popup will close
  
  ![](images/devops-create-project-topic-selection.png)
  
  5. The create project form will update to display the topic you selected, click the **Create project** button
  
  ![](images/devops-create-project-form-part2.png)

After a short while the project will be created and you will be at the main page for your newly created project.

  ![](images/devops-created-project.png)
  
## Task 3: Enable logging in the project

The DevOps services used the OCI logging service to record the output it generates during the pipeline runs. This will mean that the build logs are available for use in other tooling.

  1. On the page of your newly created project click the **Enable Log** button which will take you to the log management page
  
  ![](images/devops-enable-logging.png)

  2. Click the toggle to enable the log 
  
  ![](images/devops-enable-logging-toggle.png)
  
  3. In the popup leave all the fields unchanged from the provided defaults and click the **Enable log** button at the bottom. 
  
  ![](images/devops-enable-logging-popup.png)
  
  The logs will go through the "Creating" stage to the "Active" state
  
  ![](images/devops-enable-logs-enabled.png)

  4. Use the "Breadcrumbs" to return to your project home page - just click the project name, in my case that's `tgDevOpsProject`
  
  ![](images/devops-breadcrumbs-to-project-page.png)
  
  Once you are on the project home page you will see that the *Enable logging* warning is no longer there.
  
  ![](images/devops-project-home-with-no-logging-warning.png)
  
## End of the Module, what's next ?

Congratulations, you're now ready to start using your DevOps project.

## Acknowledgements

* **Author** - Tim Graves, Cloud Native Solutions Architect, Oracle EMEA Cloud Native Application Development specialists Team
* **Last Updated By** - Tim Graves, May 2023
