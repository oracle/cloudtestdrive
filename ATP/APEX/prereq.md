![](images/general/workshop_logo.png)

# Prerequisites for the workshop

## Step 1: Request an Oracle Cloud Free Tier account
Your lab instructor will assist you to obtaining the account during the event.

To sign up for the Free Tier: [http://bit.ly/registeroraclecloud](http://bit.ly/registeroraclecloud). 


![](./images/prereq/create_cloud_trial.png)

### Account Details
- On the next page you will be asked for the Cloud Account Name. This is what will uniquely identify your cloud environment. You will see it as part of the URL when you access it later.
- You will also be asked for the "Home Region". This is the location of the physical data center. Choose you nearest location.

![](./images/prereq/create_cloud_trial2.png)

-
- At the end of this process, you should receive an email titled "Get Started Now With Oracle Cloud".
- To login to your cloud account, use the same email address that you used for registration.
- If you have to choose your identify domain, this is the same as the value that you chose for "Cloud Account Name" during registration.
  
![](./images/prereq/create_cloud_trial3.png)

# Step 2: Provision an Autonomous Transaction Processing database

  - On the left hand menu, choose Autonomous Transaction Processing.

  ![](./images/prereq/go_to_atp.png)

  - Choose to create a new instance.
  
  ![](./images/prereq/create_atp_01.png)

  - Choose any name for the database, in this case "WORKSHOP".
  
  ![](./images/prereq/create_atp_02.png)

  - Choose the Transaction Processing option. This will optimize the database for daily transactional processing. 
  
  ![](./images/prereq/create_atp_03.png)
  
  - Choose the Serverless deployment type.
  
  ![](./images/prereq/create_atp_serverless.png)

  - In order to have an equal performance over all of the ATP instances of all the workshop participants, we recommend that you __keep the Always Free option turned off__. 

  ![](./images/prereq/create_atp_free.png)

  - Set the admin password. *Make a note of this as you will need it.*

  ![](./images/prereq/create_atp_04.png)

  - Create the database. 

  ![](./images/prereq/create_atp_05.png)
  
  This process typically completes within about 5 minutes, after which you will see the status "AVAILABLE".
