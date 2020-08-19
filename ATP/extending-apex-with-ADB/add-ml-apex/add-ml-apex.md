# Adding Machine Learning to your APEX application
## Introduction
In this lab we will add machine learning to an existing APEX application. The actual machine learning logic takes place in the database and the APEX application will pick up the predictions. As an example, we will apply machine learning on a sales scenario, in this case we will predict which customers are most likely to buy a certain product.

The product is called "Y Box Games". Our fictional company has been moderately successful in selling this product so far. Although some of our customers already own this product, we believe we could do much better. The problem is that it's very difficult to understand what type of customer is interested in it. That's why we're calling in the help of machine learning!

We will use [Apache Zeppelin](http://www.oracle.com/technetwork/database/options/oml/overview/index.html), which comes pre-installed with the autonomous database. This will be our frontend for the Machine Learning algorithms in the database. For more background on machine learning in the database see [Oracle Advanced Analytics documentation](https://docs.oracle.com/en/database/oracle/oracle-database/12.2/dmapi/mining-fuctions.html#GUID-3BC8FD92-9B6A-4612-A458-7E5FFDDC5EA7).

Estimated Time: 60 minutes

### Objectives
- Understand the components involved to add machine learning to APEX.
- Become familiar with machine learning algorithms.
- Create a machine learning model to identify customers that are likely to buy a certain product.

### Prerequisites

* An Oracle Cloud paid account or free trial. To sign up for a trial account with $300 in credits for 30 days, click [here](http://oracle.com/cloud/free).
* An Oracle Autonomous Transaction Process instance
* An APEX Workspace


## **STEP 1**: Import the APEX application

Our starting point is an existing CRM application used by a fictional company. This contains basic information about our company's customers. The application is used by the sales/service employees of our company to look up details whenever a customer calls them.

1. Click this link to [**download the application**](./files/f100.sql).

   *If you are already logged into your APEX Workspace, skip to Step 4.*

2. Open APEX. If you have don't have the direct link, click **Tools**, then click **Open APEX** on the Oracle Application Express tile.

  ![](./images/click-tools.png " ")

  ![](./images/open-apex.png " ")

3. Login to the workspace that we created earlier. Workspace name: WORKSHOPATP, User name: WORKSHOPATP, use the password that you entered when you created the workspace.

  ![](./images/open_workspace.png " ")

4. Import the example APEX application. Click **App Builder**, then **Import**.

  ![](./images/app_builder.png " ")

  ![](./images/import-app.png " ")

5. Click Browse and locate the `f100.sql` file and click **Next**.

  ![](./images/01_import_02.png " ")

6. Keep the defaults and click **Next**. When you get to the Install Database Application screen, click **Install Application**.

  ![](./images/01_import_03.png " ")

7. On the Install Application Screen, click **Next**, and on the next screen click **Install**.

  ![](./images/01_import_03B.png " ")

## **STEP 2**: Review the APEX application (before Machine Learning)

1. Open the existing application by clicking **Run Application**.

  ![](./images/01_import_04.png " ")

2. Login using the password that you used when creating the workspace.

  ![](./images/login.png " ")

3. You see the Customer Service Application, with a list of customers.

  ![](./images/customer_list.png " ")

4. Our goal is to upsell something to these customers. We want to alert our employee whenever he/she has a customer on the screen that is a good candidate for a particular product that we're trying to sell.
  In practice this means that we want to add a column on this screen that shows whether it's a good idea to try to upsell to this customer.
  This will be the topic for the rest of the lab.

  ![](./images/customer_details_with_goal.png " ")

## **STEP 3**: Create an Oracle Machine Learning user

We will develop the machine learning model using Zeppelin, which comes included in the autonomous database. Zeppelin is a web-based notebook environment that allows us to analyze and experiment with data. In our case we will be using it to build a machine learning model.
First we will set up a user for Zeppelin.

1. Go to the Service Console of ATP.

  ![](./images/open_service_console.png " ")

2. Next, select "Administration" and "Manage ML Users".

  ![](./images/manage_ml_users.png " ")

3. Click **Create** and a user called "MLUSER1".

    - Username: mluser1
    - First Name: Zeppelin
    - Last Name: User
    - Email Address: `your e-mail`
    - Uncheck: Generate password and e-mail account details to user.
    - Password: `SecretPassw0rd`

  ![](./images/create_ml_user.png " ")

4. Click on the tab for the Service Console, then Development, then Oracle Machine Learning Notebooks.

  ![](./images/open_notebook.png " ")

5. Sign in with the new user MLUSER1.

  ![](./images/sign_in_mluser.png " ")

6. Navigate around to get familiar with the ML pages. Click **Examples**.

  ![](./images/examples.png " ")

7. Note the various ML notebook examples. Feel free to review some of these. We will be creating a new ML notebook in this lab.

  ![](./images/examples_2.png " ")

8. Click the hamburger menu (![](images/hamburger-menu.png)) in the upper left to bring back the menu.  select **Notebooks** and click **Create**. Name the new notebook "Predict Y Box Games".

  ![](./images/create_notebook.png " ")

## **STEP 4**: Build the machine learning model with Zeppelin

  In this case we will build a model by letting it learn from existing customers.

1. Review the following table with customer information that we'll use as input data for the model. Copy the query into the Notebook:

    ```
    <copy>SELECT * FROM SH.SUPPLEMENTARY_DEMOGRAPHICS</copy>
    ```
2. Press Shift-Enter or click **Run**.

  ![](images/run-sql-command.png " ")

  Result:

  ![](./images/review_input_data.png " ")

  See the column "Y\_BOX\_GAMES", which tells us whether the customer already owns Y Box Games.
  And we see many other attributes of which we believe they may have some influence on whether a customer owns Y Box Games.
  For example, the level of education might be an influencing factor for Y Box Games ownership, and so may  Occupation, Household Size, et cetera.

  The *magic* of machine learning is that it will find out exactly what the relationships are between these variables and our target variable, Y Box Games.

3. Split the input data into two sets: 60% for training and 40% for testing.

    ```
    <copy>CREATE TABLE N1_TRAIN_DATA AS SELECT * FROM SH.SUPPLEMENTARY_DEMOGRAPHICS SAMPLE (60) SEED (1);</copy>
    ```

    ```
    <copy>CREATE TABLE N1_TEST_DATA AS SELECT * FROM SH.SUPPLEMENTARY_DEMOGRAPHICS MINUS SELECT * FROM N1_TRAIN_DATA;</copy>
    ```

    ![](./images/split_dataset.png " ")

4. The model will contain the definition of the relationship between the driving attributes and the target attribute (Y Box Games).
  Creating those relationships is done during the training phase.
  Defining a model requires several parameters. We first store those parameters in a table. This table can have any name.
  In our case the only parameter is the type of algorithm, in this case a decision tree model.

  Copy the following SQL to create the parameters table:

    ```
    <copy>CREATE TABLE N1_BUILD_SETTINGS (SETTING_NAME VARCHAR2(30), SETTING_VALUE VARCHAR2(4000));</copy>
    ```

    ```
    <copy>INSERT INTO N1_BUILD_SETTINGS (SETTING_NAME, SETTING_VALUE) VALUES ('ALGO_NAME', 'ALGO_DECISION_TREE');</copy>
    ```

  ![](./images/create_hyper_parameters_table.png " ")

5. Now we are ready to create and train the model. Run the following PL/SQL to do this.

    ```
    <copy>CALL DBMS_DATA_MINING.CREATE_MODEL('N1_CLASS_MODEL', 'CLASSIFICATION', 'N1_TRAIN_DATA', 'CUST_ID', 'Y_BOX_GAMES', 'N1_BUILD_SETTINGS');</copy>
    ```

  The parameters mean the following:
    - The name that our model will have. This is stored in the database as a special type of object.
    - Whether it's a classification or a regression algorithm. In this case it's a classification algorithm, because we're predicting a class (ownership yes/no) rather than a continuous value.
    - The name of the table to use for training. We created this earlier when we split the dataset.
    - The name of the column that uniquely identifies each row in the training data. In this case the customer ID.
    - The name of the target column that we want to find the driving factors for, Y Box Games.
    - Lastly, the name of the hyperparameters table. In this case it only contains a parameter with the type of model (decision tree).

  The result:

  ![](./images/create_model.png " ")


## **STEP 5**: Validate the results and the quality of the model

1. We would like to know in what percentage of the cases, the model makes a correct prediction of Y Box Games ownership.
  This is where the test set, that we created earlier, comes in handy. Since the test set contains real customers, we know whether they actually own Y Box Games.
  We will verify the performance by letting our model predict Y Box Games for those same records.
  This will allow us to verify if the predicted value of Y Box Games is the same as the actual value.

  First, create a new placeholder column in the test set that will hold the predicted value.

    ```
    <copy>ALTER TABLE N1_TEST_DATA ADD Y_BOX_GAMES_PRED NUMBER(1);</copy>
    ```

  Next, actually make the prediction.

    ```  
    <copy>UPDATE N1_TEST_DATA SET Y_BOX_GAMES_PRED = PREDICTION(N1_CLASS_MODEL USING *);</copy>
    ```

  ![](./images/run_prediction_on_testset.png " ")

  You see that this uses special SQL syntax. The above means that we want to predict the value using model 'N1_CLASS_MODEL' and all of the driving columns in the dataset will be used.

2. Let's see the result:

    ```
    <copy>SELECT CUST_ID, Y_BOX_GAMES, Y_BOX_GAMES_PRED FROM N1_TEST_DATA;</copy>
    ```

  ![](./images/review_predicted_values.png " ")

3. Let's see in what percentage of cases our prediction is correct.

    ```
    <copy>SELECT TO_CHAR(((SELECT COUNT(*) FROM N1_TEST_DATA WHERE Y_BOX_GAMES = Y_BOX_GAMES_PRED)
          / (SELECT COUNT(*) FROM N1_TEST_DATA)) * 100, '999.99') CORRECT_PRED_PERCENTAGE FROM DUAL;</copy>
    ```

  ![](./images/check_percentage_correct.png " ")

  The result is an accuracy of about 90%.

4. We can look into this number in more detail with a [confusion matrix](https://en.wikipedia.org/wiki/Confusion_matrix).

  This can easily be created by grouping on the two Y Box Games columns.

    ```
    <copy>SELECT Y_BOX_GAMES, Y_BOX_GAMES_PRED, COUNT(*)
    FROM N1_TEST_DATA GROUP BY Y_BOX_GAMES, Y_BOX_GAMES_PRED ORDER BY 1, 2;</copy>
    ```

  ![](./images/create_confusion_matrix.png " ")

  We see, from top to bottom: 1. The true negatives, 2. The false positives, 3. The false negatives and 4. The true positives.

## **STEP 6**: Run the prediction

  So far we've built and validated the model.
  You can basically run the prediction in two ways:
  - In batch. Make a prediction for ALL customers at a certain point in time.
  - Case by case. Make a prediction per customer when it is needed. For example when opening the customer details screen.

  In our case we are going to do this in batch.

  We select all the customers that don't have Y Box Games yet, then predict whether they are likely to be interested in a purchase.

    ```
    <copy>CREATE TABLE CUST_PREDICTION AS
      SELECT CUST_ID, PREDICTION(N1_CLASS_MODEL USING *) PREDICTION,
      PREDICTION_PROBABILITY(N1_CLASS_MODEL USING *) PRED_PROBABILITY
      FROM SH.SUPPLEMENTARY_DEMOGRAPHICS WHERE Y_BOX_GAMES = 0;</copy>
    ```

  ![](./images/create_prediction.png " ")

  Note that we could go a step further and schedule this prediction, but this is not part of the workshop today.

## **STEP 7**: Integrate the result into the APEX application

1. Now let's tie it all together and go back to the APEX application.

  Remember, we want to show a recommendation to our employee when the customer he's speaking to it a likely candidate to buy Y Box Games.

  For the APEX application (schema WORKSHOPATP) to be able to access the prediction results, we have to give it access to the machine learning schema (MLUSER1).

    ```
    <copy>grant select on cust_prediction to workshopatp;</copy>
    ```

  ![](./images/give_access_pred_table_mluser1_to_workshopatp.png " ")

2. Open APEX. If you have don't have the direct link, click **Tools**, then click **Open APEX** on the Oracle Application Express tile.

  ![](./images/click-tools.png " ")

  ![](./images/open-apex.png " ")

3. Login to the workspace that we created earlier.

  Workspace name: WORKSHOPATP, User name: WORKSHOPATP, use the password that you entered when you created the workspace.

4. Open the "Customer Service App" application for editing.

  ![](./images/app_builder.png " ")

  ![](./images/edit_app.png " ")

5. Edit the Customers page.

  ![](./images/select_customers_page.png " ")

  Find out what view is being used to show the customer information.

  ![](./images/customers_v.png " ")

  You see that the data comes from the CUSTOMER_V view.

6. We are going to edit the definition of this view to add a column that contains our recommendation.

  Find the view in APEX. Open the SQL Workshop, then Object Browser, select View from the dropdown and then select our view.

   ![](./images/open_customer_v.png " ")

  Have a look at the view definition. It basically selects all its values from the SH.CUSTOMERS table.

7. We will extend the view by adding a "RECOMMENDATION" column to it.

  Open the [new view definition](./files/customers_v_new_SQL.sql).

  ![](./images/sql.png " ")

  Note how this SQL will add a column "Recommendation", and it will be a text that explains whether the employee should try to upsell Y Box Games to this customer. In addition, the recommendation will only be added when the probability of an upsell is high enough.

  Open the SQL Workshop and execute the SQL script to overwrite the view with the new definition.

  ![](./images/run_sql.png " ")

  Paste in the SQL that you have just downloaded. Click **Run** to execute it.

  ![](./images/paste-sql-and-run.png " ")

8. Go back to the APEX application and edit the Customers page.

  ![](./images/edit-customers-page.png " ")

9. Add the "RECOMMENDATION" column in the select statement. Don't forget the comma just after the previous column.
  Then **Save** the page.

  ![](./images/add_recommendation_column.png " ")

## **STEP 8**: Review the ML-enabled APEX application

1. Click **Run** to run the APEX application

2. In the main screen you see that for most customers it's not recommended to try to upsell Y Box Games.
  It's unlikely that these customers will be interested.

  ![](./images/recommendations_usually_empty.png " ")

3. Now look for a customer with first name "Connor" and last name "Clark".
  Note that in this case we see a recommendation to try to upsell Y Box Games, because the customer is very likely to be interested in this offer.

  ![](./images/interested_customer.png " ")

## Conclusion

  One added column in an application might not look like much, but the value to the business can be significant.
  In this case an employee receives very valuable advise on which customer to try to upsell a product to and he/she can use that to be more effective.

  - You have learned how to predict values (a classifier in this case) based on sample training data.
  - Specifically, you have learned how to predict which customer may be interested in a certain product.
  - You have learned how to operate the Zeppelin notebooks.
  - You have learned how to integrate the prediction in an APEX application.

## Acknowledgements
* **Author** - Jeroen Kloosterman, Technology Product Strategy Manager, Melanie Ashworth-March, Principal Sales Consultant, EMEA Oracle Solution Center
* **Last Updated By/Date** - Tom McGinn, Database Innovations Architect, Database Product Management, July 2020

See an issue?  Please open up a request [here](https://github.com/oracle/learning-library/issues).   Please include the workshop name and lab in your request.
