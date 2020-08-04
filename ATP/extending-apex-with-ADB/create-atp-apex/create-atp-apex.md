# Create an APEX Workspace on a Oracle Autonomous Transaction Processing Instance

## Introduction

Oracle Application Express (APEX) is a feature of Oracle Database, including the Autonomous Data Warehouse (ADW) and Autonomous Transaction Processing (ATP) services. To start, you will need to create an ATP instance and then access APEX from within the new database.

An APEX Workspace is a logical domain where you define APEX applications. Each workspace is associated with one or more database schemas (database users) which are used to store the database objects, such as tables, views, packages, and more. These database objects are generally what APEX applications are built on top of.

Estimated Time: 15 minutes

### Objectives
- Create an Oracle Autonomous Transaction Processing instance (ATP)
- Create an APEX Workspace on your ATP instance

### Prerequisites

* An Oracle Cloud paid account or free trial. To sign up for a trial account with $300 in credits for 30 days, click [here](http://oracle.com/cloud/free).

## **STEP 1**: Provision an Autonomous Transaction Processing instance

From within your Oracle Cloud environment, you will create an instance of the Autonomous Transaction Processing database service.

1. From the Cloud Dashboard, select the navigation menu icon in the upper left-hand corner and then select **Autonomous Transaction Processing**.

    ![](images/select-atp-in-nav-menu.png " ")

2. Click **Create Autonomous Database**.

    ![](images/click-create-autonomous-database.png " ")

3. Do the following:
    - Enter **WORKSHOP** as the Display AND Database name
    - Select **Transaction Processing** as the workload type and **Serverless** as the deployment type
    - Select the **Always Free** option
    - Enter **`SecretPassw0rd`** for the ADMIN password, then click **Create Autonomous Database**.

    ![](images/create-atp-1.png " ")
    ![](images/create-atp-2.png " ")
    ![](images/create-atp-3.png " ")

4. After clicking **Create Autonomous Database**, you will be redirected to the Autonomous Database Details page for the new instance.

    Continue when the status changes from:

    ![](images/status-provisioning.png " ")

    to:

    ![](images/status-available.png " ")

## **STEP 2**: Create your APEX Workspace
Within your new database, APEX is not yet configured. Therefore, when you first access APEX you will need to log in as an APEX Instance Administrator to create a workspace.

1. Click the **Tools** then click **Open APEX**.

    ![](images/click-apex.png " ")

2. Enter the password for the Administration Services and click **Sign In to Administration**.     
    The password is the same as the one entered for the ADMIN user when creating the ATP instance: **```SecretPassw0rd```**

    ![](images/log-in-as-admin.png " ")

3. Click **Create Workspace**.

    ![](images/welcome-create-workspace.png " ")

4. In the Create Workspace dialog, enter the following:

    | Property | Value |
    | --- | --- |
    | Database User | WORKSHOPATP |
    | Password | **`SecretPassw0rd`** |
    | Workspace Name | WORKSHOPATP |

    Click **Create Workspace**.

    ![](images/create_workspace_02.png " ")

5. In the APEX Instance Administration page, click the **WORKSHOPATP** link in the success message.         
    *{Note: This will log you out of APEX Administration so that you can log into your new workspace.}*

    ![](images/log-out-from-admin.png " ")

6. On the APEX Workspace log in page, enter **``SecretPassw0rd``** for the password, check the **Remember workspace and username** checkbox, and then click **Sign In**.

    ![](images/log-in-to-workspace.png " ")

This completes the lab setup. At this point, you know how to create an APEX Workspace and you are ready to start building amazing apps, fast.

## Acknowledgements
* **Author** - Juan Cabrera Eisman, Senior Technology Solution Engineer, Oracle Digital, Melanie Ashworth-March, Principal Sales Consultant, EMEA Oracle Solution Center
* **Last Updated By/Date** - Tom McGinn, Database Innovations Architect, Database Product Management, July 2020

See an issue?  Please open up a request [here](https://github.com/oracle/learning-library/issues).   Please include the workshop name and lab in your request.
