## Application Lifecycle Management ##

In this part of the lab we will experience the Application Lifecycle Management management of the environment:

1. Change the context path of the backend microservice using a new branch.
2. Commit the changes and check the CI/CD workflow. The non-master branch executes the test route.
3. The test fails.
4. Update the test case and the UI REST endpoint address and commit.
5. Test passes.
6. Create pull request to the master branch.
7. Merge the pull request.
8. The master branch executes the store and deploy route.
9. Check the modified application.

### Change the application source code ###

First switch to the browser where [github.com](https://github.com) is opened (or open and sign in) and find the `app.js` file in your *userxx-angular-node* repository which defines the REST endpoint's context path. Click on the pencil icon to edit.

![alt text](images/wercker.change.01.png)

Modify the following method's first parameter (~31. line):

	app.post('/creditscore', creditscore.score);

to

	app.post('/creditscoreV2', creditscore.score);

Set the commit message and select the **Create new branch** option. You can leave the default name and click **Propose file change**.

![alt text](images/wercker.change.02.png)

Change the browser to Oracle Container Pipelines and wait for the build's result. The test fails. To get more details click on the *functional-test* pipeline.

![alt text](images/wercker.change.03.png)

Scroll down to the *Test Microservice* part and you can see the original context path and the 404 HTTP error code.

![alt text](images/wercker.change.04.png)

### Update the test case and other references to the new endpoint ###

Change back to the browser where [github.com](https://github.com) is opened and find the `wercker.yml` file in your *userxx-angular-node* repository. Click on the pencil icon to edit.

![alt text](images/wercker.change.05.png)

Update the `CREDITSCORE_URL` variable which defines the REST endpoint URL to:

	CREDITSCORE_URL=http://localhost:3000/creditscoreV2

Set a commit message and make sure the patch branch (previously created) is selected. Commit the changes.

![alt text](images/wercker.change.06.png)

Finally modify the UI REST endpoint configuration. Find the `/public/js/service/customer_service.js` file in your *userxx-angular-node* repository. Make sure the patch branch selected. Click on the pencil icon to edit.

![alt text](images/wercker.change.07.png)

Update the `REST_SERVICE_URI` variable properly in the line #5 to:

	var REST_SERVICE_URI = './creditscoreV2';

Set a commit message and commit changes directly to the patch branch.

![alt text](images/wercker.change.08.png)

The commit triggers the build workflow. Change the browser window/tab to Oracle Container Pipelines and wait for the result. When the workflow completed click on the *functional-test* pipeline to check the test log.

Please note you have two successful workflow runs because each commit triggered one. Usually developers use git client and commits more changes together which makes one run. It is not general to change the sources using Git Web UI which caused the multiple run.

![alt text](images/wercker.change.09.png)

Scroll down and open the *Test Microservice* log. Please note the URL changes and the successful request what is confirmed by HTTP 200 response.

![alt text](images/wercker.change.10.png)

Now the application changes has been tested. Now the source changes are ready to push to the master branch.

### Create pull request and merge the changes ###

Switch back to the browser where the [github.com](https://github.com) is already opened. Go to the root of the *userxx-angular-node* repository and select the patch branch and click **New pull request**.

![alt text](images/wercker.change.11.png)

Using this page you can create a pull request to master branch. It is important to select the correct base and head. Most likely the default base (fork) is set to the original (*https://github.com/<GITHUB_USER>/userxx-angular-node*) repository. Change this base to your fork. Make sure the base fork has the master branch. The head fork defaults usually good, but please check the head fork points to your (forked) repository and the pull request based on the patch you created.

![alt text](images/wercker.change.12.png)

After the correct configuration set github shows the merge has no conflict. Set the pull request message and click **Create pull request**.

![alt text](images/wercker.change.13.png)

Because you don't use different roles (github.com users) the merge for pull request immediately appears. You can check the commits belong to the patch and initiate the merge by click **Merge pull request**.

![alt text](images/wercker.change.14.png)

After the automatic merge you need to commit the changes to the master branch. Click **Confirm merge** to do so.

![alt text](images/wercker.change.15.png)

This commit to the master branch triggers the build workflow again. Change the browser window/tab to Oracle Container Pipelines and wait for the result. Now the store and deploy route runs. Please note the generated commit tag what is the name of the workflow execution.

![alt text](images/wercker.change.16.png)

### Check the application changes ###

Finally test the application which now uses the new endpoint of the backend service. Open a new browser window/tab and open your sample application or reload if already opened. Use the following URL to open your application: `https://PUBLIC_IP_ADDRESS/USERNAME/`. Where the USERNAME is your Oracle Container Pipelines (former Wercker) user name. It should be a similar to: `https://129.213.15.72/johnasmith/`. (To get the Public IP address of the Ingress controller you need to click on the *deploy-to-Prod* pipeline in the completed workflow and open the *get LoadBalancer public IP address* step's log.)

Before the application test open the browser's console using **Ctrl+Shift+I** and select the **Network** tab. Set the necessary fields and click **Score**. In the network console page you have to see the REST endpoint invocation which is `creditscoreV2`. You can see the complete backend service URL when you hover the mouse pointer on `creditscoreV2` network event. Please note the `V2` postfix in the complete URL.

![alt text](images/wercker.change.17.png)

## Next Steps ##

This is the end of the second exercise on Container pipelines. Follow the link below to go back to the main Container Native page, where other steps are available.

---
[Go to Container Lab Overview Page](readme.md)
