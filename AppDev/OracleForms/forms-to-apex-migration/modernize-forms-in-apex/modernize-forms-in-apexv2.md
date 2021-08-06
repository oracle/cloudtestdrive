# Modernizing Customer Oracle Form to Oracle APEX Page

## Introduction
In this lab, You will learn how to create the apex application and learn how to modernize the Customer Form.  The objective is to show you the options for these sample forms and then you can get an idea to modernize your own Forms Application.

Depending on your requirements you can take advantage of this modernization to update also the business rules, not just the screens. Because this is not a trivial process, so it's the right moment to review the business logic and check what you need to update or remove.

Having said that, let's focus on creating the APEX Application.

Estimated Lab Time: 30 minutes

### Objectives

* Creating an Oracle APEX application
* Modernize the Customer Form from Oracle Forms in Oracle APEX.


### Prerequisites

- Have Oracle APEX Workspace defined for the migration project


## Task 1: Creating an App

1. In the App Builder menu, click **App Builder**.
2. Click **Create**.

    ![](images/go-create-app.png " ")

3. Click **New Application**.

    ![](images/new-app.png " ")

4. Enter "Summit" in the application name, select appearance (Vita-Slate, Side Menu) and coninue on to add pages to the new application
    ![](images/create-app.png " ")

## Task 2: Create Oracle APEX page for Customer Form


We will be walking through series of steps on how to create Customer Faceted Search, Summary Report in Interactive Report and Tree Report along with a modal form to create/update/delete customers. We will also be comparing with APEX migration project on how we can transform the Forms  Blocks/Triggers/LOV and Alerts into APEX.

1. From the Create Application Screen, Click **Add Page**.
    ![](images/create-app_page.png " ")

2. From the Add Page Screen, Click **Faceted Search**
    ![](images/create-app_page_form_faceted_search.png " ")

3. From the Add Faced Search Page Screen, Enter **Customer - Faceted Search** in the Page Name.

    Select the **S\_CUSTOMER** table using the **Select Table** item next to the table text area and check the box to Include Form

    Click **Add Page**
    ![](images/create-app_page_form_faceted_search1.png " ")

## Task 3: Create Oracle APEX Page for Customer Report

1. Click **Add Page** to add another page
    ![](images/create-app_pages.png " ")

2. From the Add Page Screen, Click **Interactive Report**
    ![](images/create-app_page_form_interactive_report.png " ")

3. From the Add Report Page Screen , Enter **Customer - Interactive Report** in the Page Name.

    Select the **S\_CUSTOMER** table using the **Select Table** item next to the table text area and check the box to Include Form

    ![](images/create-app_page_add_interactive_report1.png " ")

    We will now add two Lookup Columns as we create the page, that will references Dynamic List of Values (LOVs) based on simple queries. The first for the Sales Representative and the Second for the Region.

    Expand Lookup Columns by Clicking on the arrow to the left of **Lookup Columns**
    ![](images/create-app_page_add_interactive_report_lookups.png " ")

    The Lookup Columns will use the foreign key IDs in the **S\_CUSTOMER** table to look up the display value. Use the values from the table below to complete this task.

    | Row | Query Column | Display Column |
    | --- | --- | --- |
    | 1 | SALES\_REP\_ID | S\_EMP.LAST\_NAME |
    | 2 | REGION\_ID | S\_REGION.NAME |

    Click **Add Page**
    ![](images/create-app_page_add_interactive_report2.png " ")

## Task 4: Create Oracle APEX page for Orders Master Detail Form

  1. Click **Add Page** to add another page
      ![](images/create-app_pages.png " ")

  2. From the Add Page Screen, Click **Master Detail**
      ![](images/create-app_page_form_master_detail.png " ")

  3. From the Add Master Detail Page Screen , Enter **Orders - Stacked** in the Page Name. Select **Stacked**

  Select the **S\_ORD** table using the **Select Table** item next to the table text area

  Select **S\_ITEM** from the **Detail Table** pulldown list

  Click **Add Page**
  ![](images/create-app_page_form_master_detail1.png " ")

## Task 5: Create Oracle APEX page for Orders Form

  1. Click **Add Page** to add another page
      ![](images/create-app_pages.png " ")

  2. From the Add Page Screen, Click **Faceted Search**
      ![](images/create-app_page_form_faceted_search.png " ")

  3. From the Add Faced Search Page Screen, Enter **Orders - Faceted Search** in the Page Name.

      Select the **S\_ORD** table using the **Select Table** item next to the table text area and check the box to Include Form

      Click **Add Page**
      ![](images/create-app_page_form_faceted_search2.png " ")

## Task 6: Finalise the Oracle APEX Application Creation

  1. Select Relevant Out-of-the-Box Features to be included with the new application. For now, ust Check the boxes for the **About Page** and **Feedback** features, Click **Create Application**
  ![](images/create-app_page1.png " ")

  This will create the navigation menu entries, pages for all the Forms and other related application objects. Once completed it will take you to the App Builder for the application.
    ![](images/create-app_page2.png " ")

## Task 7: Explore the new Oracle APEX Application

  1. When you run the Page, you will be able to see Report with all the customers listed and you can edit or create new customer from the Report page
      ![](images/interactive_report.png " ")

  2. **Customer Form** works in the similar way as **Forms Data Block**.
      If you want to manage the create/update operation from the **Interactive Reports** Page you can make the **Customer Form** to be a modal page.
      The **Customer Form** is created as a modal page by default.

      From the Application Home Page, Click on Customer Form Page
      ![](images/customer_form.png " ")
      Review the **Page Mode** and verfiy the default is **Modal Dialog**
      ![](images/modal-form.png " ")

      From the Application Builder, Go to **Customer-Interactive Report** and run the page and click on **Create Button** or **Pencil Icon** , the customer modal window opens , you will be able to make changes or create new customer from the form.
      ![](images/creat-edit-customer-form.png " ")

      ![](images/customer-modal-form.png " ")

      Creating Customer Modal Form takes care of **Data Block** conversion and **Items** from Forms to APEX

## Task 8: Review the List of Values in Oracle APEX page

  During the Create Application step we create the LOVs at the same time as the pages for the Forms. Let's review the migrated objects and update the created LOV for the Sales Representatives.

1. From the App Builder Home Page, Click on **Migrations**
  ![](images/migration.png " ")

2. Click on **Forms Migration** Project you have created
  ![](images/migration-project.png " ")

3. Click on **List of Values** on the **customers_fmb.xml** file name row
   ![](images/LOV.png " ")

4. There is only one LOV for **Sales Rep LOV** , Click on the pencil icon , Copy the **Record Group Query**
  ![](images/record-group-details.png " ")

    ````
    <copy>
    select id, first_name||' '||last_name Name from s_emp where title='Sales Representative' order by last_name
    </copy>
    ````
5. Go to your Application Home Page, Click on **Shared Components** and Click on **List of Values**
  ![](images/apex_lov.png " ")

6. Click on Create and choose **Source** as **From Scratch** and Click next
  ![](images/lov_step1.png " ")

7. Specify the name of the List of Values , you can name it as **Salesrep LOV** and Click next
      ![](images/lov_step2.png " ")

8. Choose the source type as **SQL Query** and paste the query copied from the **Record Group Query** and click next
      ![](images/lov_step3.png " ")

9. Leave the default value and Click Create
      ![](images/lov_step4.png " ")

10. **List of values** will be created Successfully
      ![](images/lov_success.png " ")

11. To change the List of Values to an item in the Page, Go to your Application Home Page, Click on Customer Form page
      ![](images/customer_form.png " ")

12. Identify the **Customers** Region and Click on **P5\_SALES\_REP\_ID** Item,Under the Page item Section , Change the **List of Values** Section and select **Salesrep LOV** for **List of Values** and Save the page.
      ![](images/sales-rep-lov.png " ")
      ![](images/list-of-values.png " ")

That completes the List of Values section of the Migration.

## Task 9:Migrate Alerts from Forms to APEX  

1. From the App Builder Home Page, Click on **Migrations**
    ![](images/migration.png " ")

2. Click on **Forms Migration** Project you have created
    ![](images/migration-project.png " ")

3. Click on **Alerts** on the **customers\_fmb.xml** file name row
    ![](images/alerts.png " ")

4. You will see two Alerts **DELETE\_ALERT** and **CONFIRM\_REVERT**
    ![](images/alert-summary.png " ")

5. To See how we can migrate to APEX,Go to your Application Home Page, Click on Customer Form page
    ![](images/customer_form.png " ")

6. Navigate to **DELETE** button Page item Property, you will see **DELETE_ALERT** is automatically handled by APEX
    ![](images/delete-alert.png " ")

7. **CONFIRM_ALERT** is handled by Page setting , Change the **Warn on unsaved changes** to **Page Default**
    ![](images/confirm-revert-alert.png " ")

## Task 10: Migrate Program Units from Forms to APEX  

- **Program Units** logic of customer form does not apply to APEX as it is handled by default processing of APEX.

## Task 11: Migrate Triggers from Forms to APEX  

- **Triggers** logic of customer form does not apply to APEX as it is handled by default processing of APEX.

## Task 12: Recreate Forms Tree Structure Triggers from Forms to APEX  

- **Customer Form** in the Oracle Forms Service was represented in a **Tree** Structure , You can easily recreate the tree structure in APEX.

1. From the Application Home Page, click **Create Page** and Click **Next**
  ![](images/create_page.png " ")

2. From the Create Page, click **Blank Page** and Click **Next**
![](images/create_blank_page.png " ")

3. From the Create Blank Page, Enter the  **Page Name** and Click **Next**
    ![](images/create_blank_page.png " ")

4. Enter the name for the menu entry and Click **Next**
    ![](images/blank_page_menu.png " ")     

5. Finish the page
    ![](images/blank_page_success.png " ")   

6. From the Blank Page, Click on **Create Region**
    ![](images/create-region.png " ")   

7. Choose the **Tree** type under the **Identification** section of the region settings and **Source** as **SQL Query**
    ![](images/customer_tree.png " ")  

    Enter the below SQL

    ````
    <copy>
    SELECT CASE
        WHEN connect_by_isleaf = 1 THEN 0
        WHEN LEVEL = 1 THEN 1
        ELSE -1
        END  AS status,
        LEVEL,
        name AS title,
        icon,
        id   AS value,
        NULL AS tooltip,
        NULL AS LINK,
        parent_id,
        name,
        id_c
        FROM   (SELECT DISTINCT To_char (d.country) id,
                                To_char (NULL)      parent_id,
                                d.country           name,
                                'fa fa-globe'       icon,
                                NULL                id_c
                FROM   s_customer d
                UNION
                SELECT e.id
                        ||'_'
                        ||e.name,
                        e.country,
                        e.name
                        ||' - '
                        || e.address AS name,
                        'fa fa-user' icon,
                        id           id_c
                FROM   s_customer e)
        START WITH parent_id IS NULL
        CONNECT BY parent_id = PRIOR id
    </copy>
    ````
  8. In order for the Tree to show up , make the changes as shown below to **Settings** under **Attributes** Section and save the form.
        ![](images/change_tree_attribute.png " ")

  9. Link the tree node to **Customer Modal Form**
     ![](images/link-to-customer.png " ")

    and specify the values to be passed

    ![](images/link_to_customer_form.png " ")

  10. Save and Run the Page
        ![](images/customer_tree_runtime.png " ")

  11. Click on the tree node will open the **Customer Modal Form**
        ![](images/customer-modal-form.png " ")

  Great Job !! You have successfully completed transforming the **Customer** Form to **Interactive Report and Form** in APEX and also recreated the **Tree** Structure similar to **Oracle Forms Structure**.



## Acknowledgements

- **Author** -  Vanitha Subramanyam, Senior Solution Architect
- **Contributors** -Abhinav Jain, Staff Cloud Engineer, Sakthikumar Periyasamy Senior Cloud Engineer, Nayan Karumuri Staff Cloud Engineer
- **Last Updated By/Date** - Vanitha Subramanyam, Senior Solution Architect, December 2020

## Need Help?

Please submit feedback or ask for help using our [LiveLabs Support Forum](https://community.oracle.com/tech/developers/categories/oracle-apex-development-workshops). Please click the **Log In** button and login using your Oracle Account. Click the **Ask A Question** button to the left to start a *New Discussion* or *Ask a Question*.  Please include your workshop name and lab name.  You can also include screenshots and attach files.  Engage directly with the author of the workshop.

If you do not have an Oracle Account, click [here](https://profile.oracle.com/myprofile/account/create-account.jspx) to create one.
