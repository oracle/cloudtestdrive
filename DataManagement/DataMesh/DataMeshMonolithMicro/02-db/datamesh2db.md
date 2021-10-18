# Data Mesh for Monolith to Microservices

### Creating an Autonomous Database instance



## Task 1: Create a VCN and subnet

1. Open the **Navigation Menu**, navigate to **Networking**, and select **Virtual Cloud Networks**.

   ![](pictures/s1/networking-vcn.png)

2. Click **Start VCN Wizard**.

3. Select **VCN with Internet Connectivity**, and then click **Start VCN Wizard.**

   ![Select VCN with Internet Connectivity](images/00-03-vcn-wizard.png)

4. Enter a name for the VCN, select a compartment, and then click **Next**.

   ![Start VCN Wizard](images/00-04.png)

5. Verify the configuration, and then click **Create**.

   ![Verify configuration](images/00-05.png)

You can click View VCN Details and see both a Public and Private subnet were created.

## Task 2: Create an ATP Instance

1. Open the **Navigation Menu**, navigate to **Oracle Database**, and select **Autonomous Transaction Processing**.

   ![](images/database-atp.png)

2. Click **Create Autonomous Database**.

   ![Create Autonomous Database](images/01-02-create-adb.png)

3. Select **Compartment** by clicking on the drop-down list. (Note that yours will be different - do not select **ManagedCompartmentforPaaS**) and then enter **ATPSource** for **Display Name** and **Database Name**.

   ![Complete Database Information](images/01-03-compartment.png)

4. Under **Choose a workload type**, select **Transaction Processing**.

   ![Workload Type](images/01-04-workload.png)

5. Under **Choose a deployment type**, select **Shared Infrastructure**.

   ![Deployment Type](images/01-05-deployment.png)

6. Under **Configure the database**, leave **Choose database version** and **Storage (TB)** and **OCPU Count** as they are.

   ![Configure database](images/01-06-db.png)

7. Add a password. Take note of the password, you will need it later in this lab.

   ![Database user and password](images/01-07-pw.png)

8. Under **Choose a license type**, select **License Included**.

   ![License Type](images/01-08-license.png)

9. Click **Create Autonomous Database**. Once it finishes provisioning, you can click on the instance name to see details of it.





You can now navigate to the next chapter of this lab