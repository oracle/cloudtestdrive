# Testing failover when a node goes down

## Introduction

In this lab we'll be using the database with the NFS volume persistence we set up in the previous lab, and validate that failover happens across the different cluster nodes.

- First we'll create a table and insert a record

- Next we'll manually stop the pod on which the DB is running and check it coming up on another node

- We'll reconnect to the database to validate our data is still there

  

Estimated Lab Time: 10 minutes



## Task 1: Insert some records in the database
1. Login with sqlplus :
   

- Get the connect string with the below command : 

  ```
  kubectl get singleinstancedatabase sidb-test2 -o "jsonpath={.status.pdbConnectString}" && echo -e "\n"
  ```

- Use your string to compose a command looking like the below, replacing <your_passwd> with the one you specified:

  ```
  sqlplus sys/<your_passwd>@132.145.249.43:1521/ORCLPDB1 as sysdba
  ```


2. Create a table called **my_test** and insert some values

```
    create table mytest (my_id int, mytext varchar(255) ) ;
    insert into mytest values (10,'Hello World');
    select * from mytest;
```



3. Visualize the use of the cluster nodes at this point :

   - Check the IP address of the active pod : 

     ```
     kubectl get pods -o wide
     ```

     This should show something like the below:

     ```
     NAME               READY   STATUS    RESTARTS       AGE    IP             NODE          NOMINATED NODE   READINESS GATES
     sidb-test1-xe06x   1/1     Running   0              38h    10.244.0.6     10.0.10.52    <none>           <none>
     sidb-test2-0tcba   0/1     Running   1 (159m ago)   168m   10.244.0.7     10.0.10.52    <none>           <none>
     sidb-test2-8yvyj   1/1     Running   0              168m   10.244.0.133   10.0.10.149   <none>           <none>
     sidb-test2-vwr0n   0/1     Running   0              168m   10.244.1.133   10.0.10.193   <none>           <none>
     ```

     You can see the 2nd pod of the sidb-test2 database is in ready state, this is the pod the DB is active on.  Take a note of the corresponding node address (10.0.10.149 in the above example)

4. On the OCI Cloud Console, navigate to **Compute**, then select **Instances**

   You should see the 3 instances of your OK cluster, with the private IP addresses corresponding with the output of the previous command.

   - Click on the instance that had the active pod
   - Click on the **Stop** button to stop the instance, then the **Stop Instance** button
   - In the Cloud Shell, you can enter the command `kubectl get nodes`to detect the moment the kubernetes cluster detects the stop of the node
   - Now re-issue the command to visualize the pods `kubectl get pods -o wide` and notice another pod has become active, running on another node of the cluster 

   

5. Validate the database is still available
   - reconnect with the database via sqlplus
   - validate the data is available using `select * from mytest;`



Congratulations, you tested the failover of the database across the cluster nodes !

You finished this lab, please don't hesitate to visit the documentation  on the [Single Instance Databases with Oracle Database Operator for Kubernetes](https://github.com/oracle/oracle-database-operator/blob/main/docs/sidb/README.md) page for more options. 



## Acknowledgements
* **Author** - Jan Leemans, July 2022
* **Last Updated By/Date**
