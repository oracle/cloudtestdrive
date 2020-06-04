# Bonus Lab 01: Deploy Oracle Data Science Module

![Workshop Data Science](../commonimages/workshop_logo.png)

This bonus lab will guide you through the steps required to store a model in Oracle Data Science Platform and deploy the model to Oracle Functions, which is the current preffered deployment process. We will also utilize Oracle API Gateway to define a REST API to access our model.

**This lab is based on LAB100 which you have to finish to be able to proceed.**

## Store the model

In `LAB100` we build a linear regression model. To be able to use the model, we have to store it in a way that it is deployable. Currently Oracle Data Science Service uses Oracle Functions to deploy the models. Oracle Data Science Service stores the serialized weights of the model as pickle file, which does not require any proprietary software to be read and can be used or deployed to any cloud vendor, compute instance or service you prefer.

**To store the model continue to work in the notebook yo used for the LAB100.**

The last step was that you used the RMSE to validated the performance of the model. Let's now store the model. To do so we need to initialize the ADS (Oracle Accelerated Data Science) library. Before we could use the library you have to make sure that you generated your OCI private key.

**Please follow the steps in the `getting-started.ipynb` file to register your account and generate a key that would allow you to use the ADS library.**

After you finish the registration and validate that the ADS works, we are going to initialize the library now in **the notebook we used for LAB100**.

