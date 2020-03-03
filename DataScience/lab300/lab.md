![](../commonimages/workshop_logo.png)

# Lab: Assessing Credit Risk using Oracle Analytics

In this lab we will take the perspective of a **business user** (as opposed to the expert data scientist). 
Oracle Analytics lets business users build and apply ML models in a very visual and intuitive way. Oracle Analytics provides algorithms in all major ML categories, e.g. Regression, Classification, Clustering and Association Rule Mining.
In addition, there's a set of featured called "Augmented analytics" in this platform that uses ML "under the hood" to automate a lot of the common tasks in the analytics process, think about Data Preparation and Data Exploration.

## Objectives
- Become familiar with Oracle Analytics and self service analysis. 
- See how Oracle Analytics can be used to do Data Preparation and Exploration in a -visual- way, as an alternative to coding.
- Understand the impact of ML in the hands of business users.

# Prerequisites

You require the following: 
- An Oracle Cloud tenancy
- Either an Oracle Analytics Cloud instance **or** a local installation of Oracle Data Visualization Desktop. 

Please follow the [prerequisites](../prereq3/lab.md) first in case you don't have these yet.

# Data Preparation

First we have to upload the data that's required for our model. In this case, the dataset with historical Credit Risk information is mostly ready to go, without requiring any changes.

- Download the [The training dataset](./data/MLTD2_german_credit_historical_applications.csv)

Click on the link, then use the "Raw" button and then right click "Save As". Make sure to save these with extension CSV. Some browsers try to convert this to Excel format, which is incorrect.

The original dataset contains 1000 entries with 20 categorical and numerical attributes prepared by Professor Hofmann and each entry in the dataset represents a person who took a credit and classified as good or bad credit risk.
The dataset provided to you as part of the material was obtained from the following location: https://archive.ics.uci.edu/ml/datasets/Statlog+(German+Credit+Data)

The first task to do is to upload the MLTD2_german_credit_applicants.csv dataset provided to you into Oracle Analytics Cloud. You can find it [here](./data/MLTD2_german_credit_applicants.csv). 

- Open Data Visualization Desktop (or Oracle Analytics Cloud, if you prefer). On the top left corner click on the menu icon and Click on "Data".

![](./images/img2.jpg)

- To import the dataset click on "Create", "Data Set", and select the file that you downloaded earlier.

![](./images/img3.jpg)
![](./images/img4.jpg)

- You see a preview of the dataset. Complete the process by clicking "Add"
![](./images/img5.jpg)

- By default Oracle Analytics incorrectly treats the "recid" column as a measure. Change it to "Attribute" by clicking on "recid", then "treated as", then "attribute".
![](./images/img6.jpg)


- Oracle Analytics records all changes you make in a script. This allows it to easily repeat the process in case data is reloaded. For now, apply the script that has been created by clicking "Apply Script". This makes the change to recid effective.
![](./images/img7.jpg)


# Data Exploration

As you know, this phase in the Data Science process is for us to get to know our data, identify which columns are useful, detect any problems with the data, et cetera.

First of all, let's imagine you want to know how many credit applications have been Accepted vs Denied in the past. We can use Oracle Analytics' visualization capabilities for this.

- Create a project in order to investigate the dataset using visualizations by clicking on the burger menu associated with our dataset and "Select Project".
![](./images/img10.jpg)

- First we need a way to count the credit card applications. We do this as follows: Right-click on ‘My calculation’ folder of the dataset and select "Add Calculation".
![](./images/img11.jpg)

- The name of the field can be anything, e.g. "# Count". Then add a counter by Double-clicking on ‘Count’ in the ‘Aggregation’ list of options. 
![](./images/img12.jpg)

- Define the counter by selecting the column "recid", then click "Save".
![](./images/img13.jpg)

- Now we can find an answer to our questions. Select both the "class" and the "# Count" fields (use Control to select multiple fields). Then ‘Right-Click’ on the blue part and select "Pick Visualization". 
![](./images/img14.jpg)

- Select the ‘donut’ visualization
![](./images/img15.jpg)

- You see that 70% out of 1000 credit applications were good and 30% were bad for the target called ‘class’
![](./images/img16.jpg)

- Now let's say we have a NEW question. We'd like to know how the Credit Amount that's requested is related to to a Good or Bad credit scoring. Again, we can create a visualization to answer that question. This time, select the field "Recid", "Credit_amount" and "Class" and choose the "Boxplot" Visualization.
![](./images/img17.jpg)

- Now, you see ‘Boxplot Visualization’. You can the bulk of applications in terms Credit_amount for class=good and class=bad
It shows the bulk of credit_amounts for good and bad credit, the amount which are not in the bulk. My conclusion is that the range of credit_amount for bad credit is bigger than for good credit, although the average value seems the same.
![](./images/img19.jpg)

- Remember the colinearity issue from the previous labs? Colinearity is the effect of multiple attributes that supply similar information. When we train our model, we should try to only supply attributes that provide unique pieces of information. To investigate this issue, we will create a correlation diagram between the input features. Do this by selecting all the fields from "duration" until "num_dependants". Choose "Pick Visualization" and select "Correlation Matrix".
![](./images/img20.jpg)

- Now you see the correlation matrix visualization. Although there is some correlation between the fields, the correlation does not appear to be too high in any place. Therefore there's no colinearity and no action to be taken. 
![](./images/img23.jpg)
- Save the results of the Data Exploration. Give it a logical name.
![](./images/img25.jpg)

At the is point you are doing with the investigation of the dataset and move on the next task

# Train the model

Our goal is to build a model that can correctly assess the credit of an application for a loan with either "Good" or "Bad".
In Oracle Analytics, this is done by creating a so-called "Data Flow". A "Data Flow" specifies the source of the data for the training, any data transformations, and a step for the actual model training.

- Create a new Data Flow by going to the "Data" menu, then select "Create" and "Data Flow".
![](./images/img26.jpg)
![](./images/img28.jpg)

- Every Data Flow starts with a dataset. Select the dataset that we uploaded earlier (‘MLTD2_german_credit_applicants’) and select "Add".
![](./images/img29.jpg)

- During Data Exploration we found that we want to keep all attributes for training. However, the identifier "recid" does not have any values, so let's remove it.  Use "remove selected" next to this column to remove it.
![](./images/img30.jpg)
![](./images/img31.jpg)

- In this case we need a Binary Classifier algorithm. The reason is that our output are two possible classes: "Good" and "Bad". Add a "Train Binary Classifier" step at the end of the process (see "+" symbol").
![](./images/img32.jpg)

- There are different algorithms available to do binary classification. In this case we will select "Logistic Regression for model training".
![](./images/img33.jpg)

- There are a few hyperparameters for this algorithm. Most importantly, we have to select what the target column is. In this case, select "class". The other hyperparameters are "Positive Class in Target", set this to "Bad". Set the value for "Predict Value Threshold Value" to 30%. Set "Standardization" to True.
![](./images/img46.jpg)
![](./images/img47.jpg)

- You see that a "Save Model" node was automatically created. Click it and set ""MLTD2_trained_german_credit_LR30" as the model name.
![](./images/img50.jpg)

- Now, save the Data Flow. Click on ‘Save’ and choose "MLTD2_train_german_credit_DF".
![](./images/img36.jpg)

- Next, we can finally execute the Data Flow. Effectively this will train the model. Click on "Run Data Flow" (top right). A message will appear saying that the data flow was run successfully.
![](./images/img38.jpg)

# Evaluate the model

Now that you have built the model, you need to assess how good it is and decide if you are happy with it. Oracle Analytics Cloud machine learning provides quality metrics to allow you to evaluate how good the trained models are. 

- First, locate the trained machine model by going to the "Machine Learning" menu and selecting our model. Then select "Inspect".
![](./images/img40.jpg)
![](./images/img50.jpg)

- Go to "Quality" tab to see the quality metrics associated with your model. You can see that the model doesn't predict all cases correctly. You can play with the hyperparameters to improve these results and find the best trade off for your case.
![](./images/img51.jpg)

# Make Predictions (Apply the model)

We have a file with new applications that we wish to score.

Download it [here](./data/MLTD2_german_credit_new_applications.csv)

Click on the link, then use the "Raw" button and then right click "Save As". Make sure to save these with extension CSV. Some browsers try to convert this to Excel format, which is incorrect.




# Apply model data-flow
## In this section, you create s second Data Flow where the model created in the first step gets is applied to score the customer credit applications.

## 1. 

![](./images/img53.jpg)

To define your data-flow to score current credit applications using the model you have built recently:

1.	Click on the burger menu  

2.	Click on ‘Data’ in the main menu

## 2. 

![](./images/img54.jpg)

1.	Click ‘Data-Flows’ tab

## 3. 

![](./images/img55.jpg)

You now have to create a model scoring data-flow:

1.	Click on  ‘Create’

2.	Click on ‘Data-Flow’

## 4. 

![](./images/img56.jpg)

To select the dataset to apply the model:

1	Select ‘MLTD2_german_credit_applicants’ dataset

2	Click on ‘Add’

## 5. 

![](./images/img57.jpg)

1.	Click on the ‘+’ sign next to the last blue node.

2.	Select ‘Select Columns’ as the node to add to data-flow

## 6. 

![](./images/img58.jpg)

To remove unwanted attributes:

A)	Click on ‘class’

B) 	Click on ‘Remove Selected’ to move it to left

Or 

1.	Double-Click on ‘recid’ to move it to the left side

## 7. 

![](./images/img59.jpg)

You now have to specify which model to use: 

1.	Click on the ‘+’ of last node in the data-flow

2.	Select ‘Apply Model’ node

## 8. 

![](./images/img60.jpg)

Select the trained model you did earlier:

1.	Select ‘MLTD2_trained-german_credit_LR30’ that provided  better results

2.	Click on ‘OK’

## 9. 

![](./images/img61.jpg)

You have to add a node to specify which columns to include the final dataset:

1.	Click on the ‘+’ of the last node in the data-flow

2.	Select  ‘Select Columns’ node

## 10. 

![](./images/img62.jpg)

You need to remove unwanted to keep. You will remove all attributes except:
 
•	Recid

•	PredicteValue

•	PredictionConfidence 

Either by

1.	Double clicking on each attribute not listed above

Or

2.	First you have to select the columns:

A)	Using ‘Shift + Click’ on attribute ‘checking_status’

B)	Using ‘Shift + Click’ on attribute ‘foreign_worker’

C)	To move the selected attributes to the left side then either:
 
- 	Click on ‘Remove selected’
- 	Or Double click on the green

## 11. 

![](./images/img63.jpg)

You should end-up with only 3 columns kept on the left hand side:

•	Recid

•	PredicteValue

•	PredictionConfidence

## 12. 

![](./images/img64.jpg)

Now to specify the table to be saved:

1.	Click on the ‘+’ of the last node in the data-flow

2.	Select ‘Save Data’ node

## 13. 

![](./images/img65.jpg)

Set the name of the output dataset to be saved:

1.	Click on ‘Save Data’ node

2.	Set name to ‘MLTD2_Greman_credit_scored’

## 14. 

![](./images/img66.jpg)

You have to save the data-flow:

1.	Set the name of the data flow to ‘MLTD2_scoring_germany_credits_DF’

2.	Click on ‘OK’

3.	Click on ‘save’. You will get a successful message in green

## 15. 

![](./images/img67.jpg)

Now you can run the data-flow:

1.	Click on ‘Run Data Flow’

2.	Once the execution is finished you will see a successful message in green

## 16. 

![](./images/img68.jpg)

To exit the data-flow:

1.	Click on the white back arrow

## 17. 

![](./images/img69.jpg)

You now see your newly created data-flow listed in the repository

## 18. 

![](./images/img70.jpg)

You now see the newly created dataset in the repository list of available datasets

## 19. 

![](./images/img71.jpg)

Now, in order to go back to your current project and create visualization based on the scored data set then 

1.	Click on the burger menu

2.	Click on ‘Catalog’


Now, you are finished with apply model data-flow that creates a scored table for the current credit application. In the next section, you will explore the results visually.

# Credit Prediction Visualization 
## In this section, using the scored table of the previous exercize, you create 3 visuals to understand the predicted values according to some applicants attributes.

## 1. 

![](./images/img72.jpg)

Now, in order to go back to your current project and create visualization based on the cored data set then 

1.	Click on the burger menu

2.	Click on ‘Catalog’

## 2. 

![](./images/img73.jpg)

To open your current project:

1.	Click on the burger menu for the project in left right corner

2.	Click on ‘Open’

## 3. 

![](./images/img74.jpg)

To add a new canvas

1.	Click on the ‘+’ of the credit exploration canvas

## 4. 

![](./images/img75.jpg)

To name the new canvas:

1.	Click on the down arrow associated with the ‘Canvas 2’ name.

2.	Click on ‘Rename’

## 5. 

![](./images/img76.jpg)

1.	Type in ‘Prediction analysis’ as the new name

2.	Click on the check mark sign next to the new name, bottom of the canvas. 

## 6. 

![](./images/img77.jpg)

Now to create visualizations, you have to add the data set:

1.	Click on the ‘+’

2.	Select ‘Add Data Set…’

## 7. 

![](./images/img78.jpg)

To add the correct dataset to the project, the dataset containing the scored credit applications:

1.	Click on ‘MLTD2_german_credit_scored’

2.	Click on ‘Add to Project’

## 8. 

![](./images/img79.jpg)

1.	Click ‘measure’ to change ít to ‘Attribute’ so that it corresponds to the one in the other dataset

## 9. 

![](./images/img80.jpg)

You have to link the 2 dataset to create visualization on attributes from both:

1.	Click on ‘Prepare’ tab

## 10. 

![](./images/img81.jpg)

1.	Click on ‘Data diagram’ canvas

## 11. 

![](./images/img82.jpg)

2.	Click on the first dataset to select it

3.	Click on the "0" between the 2 datasets to define the link between the two

## 12. 

![](./images/img83.jpg)

1.	Click on ‘Add Another Match’

## 13. 

![](./images/img84.jpg)

1.	Select ‘recid’ for both

2.	Click on ‘OK’

## 14. 

![](./images/img85.jpg)

To go back to visualization tab:

1.	Click ‘Visualize’

## 15. 

![](./images/img86.jpg)

To create a visualization for the predicted value distribution:

1.	‘Ctrl + left click’ to select

A)	‘Predcitedvalue’ and

B)	 ‘# Count’

## 16. 

![](./images/img87.jpg)

1.	Select the ‘Donut’ visualization

## 17. 

![](./images/img88.jpg)

Now, you see the % of good and bad predicted values

## 18. 

![](./images/img89.jpg)

To create a second visual to see the predicted value according to employment length of time:

1.	‘Crtl + left click’ to select:

A)	‘Employment’

B)	‘Predictedvalue’

C)	‘# Count’

2.	Select ‘Pick visualization’

## 19. 

![](./images/img90.jpg)

As for selecting the visual:

1.	Select the ‘Bar’ visual option

## 20. 

![](./images/img91.jpg)

Now, you the predicted value according to employment duration.

It seems that people with employment duration of 1 year or less are high risk people

## 21. 

![](./images/img92.jpg)

To create a visual to look at predicted value according personal status:

1.	‘Crtl + left click’ to select 

A)	‘# Count’

B)	PredictedValue

C)	Persona_status

2.	Select ‘Pick Visualization’

## 22. 

![](./images/img93.jpg)

This time for visualization:

1.	Select ‘Stacked Bar’ visual option

## 23. 

![](./images/img94.jpg)

This is what you should see.

## 24. 

![](./images/img95.jpg)

To save the work so far:

1.	Click on ‘save’ and wait until the a successful green message appears

## 25. 

![](./images/img96.jpg)

Now that you are done and exit the project:

1.	Click the white back arrow 


Congratulations, you are now finished with the lab. 


In this section, you will carry out the following tasks using the point and click interface of Oracle Analytics Cloud for machine learning capability:

1.	Build a predictive model
2.	Evaluate the model
3.	Score the customer base using the model
4.	Predictions visualization
