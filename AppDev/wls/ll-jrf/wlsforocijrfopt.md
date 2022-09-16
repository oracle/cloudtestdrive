# WebLogic for OCI (JRF)



## Optional steps

This chapter contains 2 optional steps you can execute :

- Deploying a 2nd ADF application that showcases all the features of an ADF Faces Rich Client
- Destroy the various resources you created in this lab to preserve resources on your tenancy



## 1. [Optional] Deploy ADF Faces Rich Client Components Demo Application

If you want to explore the ADF Faces components at runtime, the ADF Faces development team at Oracle created a component demo that showcases the various components and framework capabilities and allows you to try different property settings on the selected component. The components demo is provided with full source code and is a great way to learn how to work with the components in general. 

![img](images/wlscnonjrfwithenv/image700.png)



- First, you need to download the faces-12.2.1.4.0.war Oracle ADF Faces Components Demo archive from the Oracle website.  To do this you need to go through the following steps : 
    - Go to [this page](https://www.oracle.com/tools/downloads/application-development-framework-downloads.html), and **scroll down** to the place where you can download the **Oracle ADF Faces Components Demo**.  Attention, do NOT use the very first link on the page which leads to the full ADF runtime library!
    - Click on the "Download button for the **Oracle ADF Faces Components Demo**, where you have to login with your **Oracle account** - this is NOT your cloud tenancy account!.
    - You now have downloaded the downloader utility (approx 2,7 MB), which you need to launch to download the actual WAR file (which has a size of approx 126,6 MB).  The WAR file will be named somthing like V996797-01.war, rename it to faces-12.2.1.4.0.war 
    - Then, in a similar way as at step **Deploy sample ADF application**, install the faces-12.2.1.4.0.war application. 

- Then, from *Deployments* -> *Control* tab start the application:

![](images/wlscnonjrfwithenv/image710.png)



- Once *Active*, another browser tab navigate to *https://< public load balancer IP >/faces-12.2.2.1.0/*:

![](images/wlscnonjrfwithenv/image720.png)



The **Tag Guide** is the entry link to the component demo and shows a list of ADF Faces components that you can select to further explore. Each component demo is launched in a browser that has a split screen layout. The split screen's right content area has a property inspector functionality that you can use to set properties for the individual component. Note that the right content area might be closed so that you have to drag it open before using it. Also of interest is that in addition to the rich client components, the data visualization components which allow you to graphically represent your data are also present in this listing.

The **Feature Demos** include a variety of demonstrations for the frameworks capabilities including a rich set of demos for the data visualization components, active data services, drag and drop and other client behaviors.

A demo of interest should be the **Styles** demo. Users frequently get confused by which part of a component is styled by the **inlineStyle** attribute and which part is styled by the **contentStyle** attribute. The demo also contains a skinning demonstration that allows developers to play with various skin definitions per component.



## 2. [Optional] Destroy resources

If you don't plan to use the WebLogic Domain anymore, to spare tenancy resources, the quickest way to delete the resources created during this lab is to run *Terraform Destroy*  on the Stack.

- Navigate to *Solutions and Platform* > *Resource Manager* > *Stacks*, identify and click on the Stack name you have created at the beginning of this lab.

- By running the *Destroy* Terraform Action, a Terraform job will kick off and delete all created resources.

![](images/wlscnonjrfwithenv/image600.png)



- When the job ends, you should see a similar log output:

![](images/wlscnonjrfwithenv/image610.png)



You can check that the Compute Instances and the Block Volumes have been terminated.

- At the end you can also delete the Stack:

![](images/wlscnonjrfwithenv/image620.png)