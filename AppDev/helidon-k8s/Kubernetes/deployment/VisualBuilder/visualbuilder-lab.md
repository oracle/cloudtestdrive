[Go to Overview Page](../README.md)

![](../../../../../common/images/customer.logo2.png)

# Migration of Monolith to Cloud Native

## D. Building a Mobile Application in Visual Builder



### Introduction

---

Lorem ipsum
Lorem ipsum
Lorem ipsum



### Chapter 1

---

Lorem ipsum
Lorem ipsum
Lorem ipsum



Visual Builder Applications Home Screen

![image-20200621164217085](images/image-010.png)



Create new Application:

![image-20200621164326270](images/image-020.png)



Expand the Navigator:

![image-20200621164436541](images/image-030.png)



Create new Mobile Application:

![image-20200621164611363](images/image-040.png)



Setup an Application Name, choose *Vertical* Navigation Style to generate a hamburger type of menu, setup one page named *Stock Items* and remove the other sample pages:

![image-20200621164703151](images/image-050.png)



Choose *List* Page Template for the *Stock Items* page:

![image-20200621164928679](images/image-060.png)



Mobile application created and *Stock Items* page opened for editing:

![image-20200621165142956](images/image-070.png)



Navigate to *Service Connections* to setup a connection to the Kubernetes service backend:

![image-20200621165256215](images/image-080.png)



Add a new *Service Connection* and choose *Define by Specification*:

![image-20200621165405723](images/image-090.png)



Setup the Open API Endpoint exposed through the API Gateway; Choose *Basic* Authentication

![image-20200621165915753](images/image-100.png)



Setup credentials:

![image-20200621171108806](images/image-110.png)



Choose to use the Proxy and create the Connection:

![image-20200621171207235](images/image-120.png)



Service Connection Page:

![image-20200621171350021](images/image-130.png)



Switch to *Servers* tab; Edit the Server information:

![image-20200621172439191](images/image-140.png)



Add the */sf* suffix, as the application root context is missing:

![image-20200621172552409](images/image-150.png)



Switch to *Endpoints* tab; click on the *List stock items* endpoint:

![image-20200621172649975](images/image-160.png)



See that the *Summary* and *Description* information is coming from the Open API specification; Switch to *Test* tab:

![image-20200621172805667](images/image-170.png)



Click *Send*:

![image-20200621172952330](images/image-180.png)



The call was successful! Save the response as *Example*:

![image-20200621173037527](images/image-190.png)



We can close the Service Connection main tab and go back to the mobile application page:

![image-20200621173216469](images/image-200.png)



Select the List View on the canvas and in the Component details go to Wizard tab (graduated student icon); Click *Add Data*:

![image-20200621173311282](images/image-210.png)



To populate the Stock Items list, the wizard filters for the available *GET* methods from the Service Connections; Choose the */store/stocklevel* one from the *sfOpenapi* connection; Click *Next*:

![image-20200621173435393](images/image-220.png)



You may leave the default template:

![image-20200621173649477](images/image-230.png)



Drag and drop the *itemName* and *itemCount* fields on the first two Template Fields; Choose *itemName* as the *Primary Key*:

![image-20200621173731686](images/image-240.png)



No need do define further filtering, click *Finish* to end the wizard:

![image-20200621173917069](images/image-250.png)



The Visual Builder Page designer renders real results even at design time:

![image-20200621174014359](images/image-260.png)



Next, we want to select an Item and reserve a quantity from the stock; First step is to enable Single Row selection on the *List View* component; Switch to *General* tab in the component properties and choose *Single* for *Selection Mode*:

![image-20200621174246405](images/image-270.png)



Next, we want to add a *Reserve* button; Activate the *Page Structure* panel and find the *Button* component in the *Components* Panel:

![image-20200621174418016](images/image-280.png)

 

Drag an drop the *Button* component right above the *List View* on in the *Page Structure* panel:

![image-20200621174605394](images/image-290.png)



Change Button's name to *Reserve*; you may hide the *Page Structure* to make some room for the canvas:

![image-20200621174721054](images/image-300.png)



Now, what we want to achieve is that once a row in the Stock Items list is selected, to activate the *Reserve* button and map the selected row information so that we'll used it in a new page where we'll input the quantity that we want to reserve and where we'll call the second Service endpoint to perform the reservation.

To make it more ease, we setup a variable at Flow scope level.

From the Mobile Application Structure click on the *stock-items* flow:

![image-20200621175332298](images/image-310.png)



Switch to *Variables and Types* sub-tab:

![image-20200621175421178](images/image-320.png)



Let's define first a type based on the request body structure that we need to send to the *reserveStock* endpoint; [...]:

![image-20200621175540112](images/image-330.png)



Expand the *Service Connections* and choose the POST endpoint:

![image-20200621175614346](images/image-340.png)



Expand and click on the *Request* element; Click *Finish*:

![image-20200621175716782](images/image-350.png)



We see that a complex type have been defined based on the fields that need to be part of the request body:

![image-20200621175908543](images/image-360.png)



Switch back to the *Variables* tab to define a new variable; setup a variable *ID* (name) and the type that you have just created; Click *Create*:

![image-20200621180123733](images/image-370.png)



Let's setup a default value for the items *requestedCount* field:

![image-20200621180306236](images/image-380.png)



Everything in place, we may close the *stock-items* flow settings tab; Let's rename the page; By clicking the page header we open up the *Mobile Page Template* properties:

![image-20200621180507029](images/image-390.png)



We can can change the *Page title* to *Stock Items*:

![image-20200621180704589](images/image-400.png)



Now, we want to have the *Reserve* button de-activated if now row selected; Click on the button in the canvas and for the *Disabled* property choose to select a variable:

![image-20200621181017274](images/image-410.png)



[...] select *requestedItem* field from the *selectedStockItem* flow variable:

![image-20200621181134313](images/image-420.png)



As we want the button to be disabled when no value, we can edit the expression function and add a comparison with null:

![image-20200621181326018](images/image-430.png)



Now, when we select a row in the list, we want to populate the *requestItem* field. Select the *List View* component on the canvas, switch to *Events* tab and click to create a *selected* quick start event handler:

![image-20200621181445812](images/image-440.png)



This will create an event handler and an action chain that will be called each time row selection changes for the List view:

![image-20200621181828109](images/image-450.png)



Drag and drop the *Assign Variables* [...]; Click on the *Assign* link .. [...]:

![image-20200621181936271](images/image-460.png)



Do the below mapping and save it:

![image-20200621182035194](images/image-470.png)



You may go back to the *Designer*, switch to *Live* mode and test this functionality:

![image-20200621182205406](images/image-480.png)



Next, we want to create a new page where user's will input desired quantity for the item; Click to create a sibling page:

![image-20200621182421493](images/image-490.png)



Give it a name and leave the blank default page template:

![image-20200621182514203](images/image-500.png)



Let's change the display name of the page:

![image-20200621182608748](images/image-510.png)



Drag and drop a *Form Layout* on the canvas:

![image-20200621182726732](images/image-520.png)



Setup the label positioning of the form items to *Start*:

![image-20200621183113894](images/image-530.png)



Drag an drop an input text; Setup the name to *Item*, make it *Required*, but also *Disabled*:

![image-20200621183217157](images/image-540.png)



Switch to *Data* to populate the field with the selected item name from the List items page:

![image-20200621183338215](images/image-550.png)



Drag and drop an Input Number component right beneath the Input Text:

![image-20200621183509901](images/image-560.png)



Change the Label name and make it *Required*:

![image-20200621183552958](images/image-570.png)



Switch to *Data* and map it to the *requestedCount* field of the flow variable:

![image-20200621183649624](images/image-580.png)



Drag and drop a Toolbar beneath the form:

![image-20200621183838849](images/image-590.png)



Inside the toolbar we are creating two buttons: one to Cancel and go back to the List Items page and one to call the REST service to reserve the item. For the first one set the label text to *Cancel* and change the *Chroming* style:

![image-20200621184028194](images/image-600.png)



Go to *Events* and add an *ojAction* event handler that will be called when the *Cancel* button is being clicked (or tapped):

![image-20200621184202997](images/image-610.png)



You may change the Action Chain ID; Drag a *Navigation Back* action:

![image-20200621184342913](images/image-620.png)



Back to page designer, add a new button in the toolbar; Change the name to *Reserve*:

![image-20200621184527043](images/image-630.png)



Add an *ojAction* event handler for this one too:

![image-20200621184643556](images/image-640.png)



Drag and Drop a *Call REST Endpoint* action; Click *Select Endpoint*:

![image-20200621184745690](images/image-650.png)



Select the POST endpoint method of the *sfOpenapi* service connection:

![image-20200621184915577](images/image-660.png)



Map the request body:

![image-20200621185016042](images/image-670.png)



Map the *selectedStockItem* flow variable; click *Save*:

![image-20200621185050735](images/image-680.png)



Setup a *Transient* display mode for the notification (it will disappear after a couple of seconds) and change the *Notification Type* from *error* to *info*:

![image-20200621185610032](images/image-690.png)



Use the Expression Editor for the *Summary* to setup below message:

> 'You have successfully reserved ' + $flow.variables.selectedStockItem.requestedCount + ' ' + $flow.variables.selectedStockItem.requestedItem + '!'

![image-20200621185536131](images/image-700.png)



It should look like this:

![image-20200621185946685](images/image-710.png)



Lastly, add *Navigate Back* action:

![image-20200621190028099](images/image-720.png)



No matter if the user reserves a stock item or cancels, we want to reset the item selection and the input quantity to default. We can do this in an unitary way, by adding a custom event listener; Switch to *Events* tab and add a new *Event Listener*: 

![image-20200621190353178](images/image-730.png)



Select *vbBeforeExit*:

![image-20200621190455566](images/image-740.png)



Create a new *Page Action Chain*:

![image-20200621190550822](images/image-750.png)



Give it a name and click on *Select*:

![image-20200621190643262](images/image-760.png)



Hover on the action chain [...]:

![image-20200621190752661](images/image-770.png)



In the Action Chain designer, drag and drop a *Reset Variables* action; Select the *selectedStockItem* variable:

![image-20200621190901360](images/image-780.png)



The last step that we need to do, is to setup the navigation to  the *Reserve Item* page; Switch back to the *stock-items-start* page, select the *Reserve* button, and add an *ojAction* event:

![image-20200621191053377](images/image-790.png)



Drag and drop a *Navigate* action in the action chain designer; Select the *stock-items-page* page as Target:

![image-20200621191225679](images/image-800.png)



Let's test the application by clicking in the *Play* button:

![image-20200621191426581](images/image-810.png)



This runs the application in ... mode:

![image-20200621191557188](images/image-820.png)



Select an item and click *Reserve*:

![image-20200621192056102](images/image-830.png)



Setup a quantity and reserve:

![image-20200621191911356](images/image-840.png)



Back to previous page:

![image-20200621192238985](images/image-850.png)



Let's deploy this application to mobile device.

Back in designer, open application properties:

![image-20200621200759179](images/image-860.png)



Go to *PWA* tab and enable this mobile application to be *Progressive Web App*; Change the *Application Name*:

![image-20200621200925840](images/image-870.png)



Run again the application in [...] mode; now we see the option to build the mobile application:

![image-20200621201124361](images/image-880.png)



Click on *Build my App* and accept to stage the application:

![image-20200621201434552](images/image-890.png)



A QR code has been generated with the Staged application link:

![image-20200621201948640](images/image-900.png)



Take you mobile device and scan the code:

![image-20200621201948640](images/image-910.png)



Once the application loads (you might to authenticate to your tenancy), add it to home screen (you can use it from the browser too):

![image-20200621201948640](images/image-920.png)



Choose to *Add*:

![image-20200621201948640](images/image-930.png)



Open the application from the Home screen:

![image-20200621201948640](images/image-940.png)



Store Front application running on device:

![image-20200621201948640](images/image-950.png)







### Chapter 2:

---

Lorem ipsum
Lorem ipsum
Lorem ipsum