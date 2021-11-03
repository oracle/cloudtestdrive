We've done all the background setup needed for DevOps, and have our Kubernetes cluster running with the Storefront and Stockmanager services in place, so it's time to start creating our DevOps projects.

Our first task it to create a notification service that DevOps will use to communicate progress between it's different elements.

Go to the notifications service page
Hamburger menu -> Developer Services -> Notifications

Confirm you are in the right compartment 

Click **Create Topic**

In the form enter a name of the form `<YOUR INITIALS>DevOpsTopic`

Enter a description if you like

Click the **Create** button

It will take a short while for ther topic to be created

Now we can create the DevOps service instance

Navigate to the Dev Ops service

Hamburger menu -> Developer Services -> Overview

Click the **Create DevOps Project** button

Provide a name for your project alont the lines of `<YOUR INITIALS>/DevOpsProject`

Add a description if you want

Click the **Select Topic** button, this will open a new popup

in the popup check you are using the correct compartment in the Compartment selector

In the popup topic selector chose the topic you created earlier, you should have named it something like `<YOUR INITIALS>DevOpsTopic`

Click the **Select Topic** button at the bottom of the popup

Click the **Create DevOps project** as the bottom of the devops form

After a short while the project will be created and you will be at the main page for your newly created project.

Enable logging in the project, this will mean that the build logs are avaialble for use in other tooling.

On the page of your newly created project in the amber "Warning" box titled **Enable Logging** click the **Enable Log** button which will take you to the log management page

Use the toggle to enable the log and in the popup leave all the fields unchanged from theprovide defaults and click the **Enable log** button at the bottom. It will take a short while to setup the login 
