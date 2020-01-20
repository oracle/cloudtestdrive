# Appendix C: How do you examine Function logging in Object Storage?

As part of this lab, we utilise one option for the logging capability of OCI based functions. 

You will configure the function application that gets created to store logs in Oracle Cloud Infrastructure Object Storage.

This appendix is available to give some very brief notes on how to access and use the log files generated as your function is invoked, should you encounter problems.

### Setup

During the lab you will have created a new function application and as part of this you will have selected to 'LOG TO OBJECT STORAGE'.

![loggingpolicy](loggingpolicy.png)

Selecting to use Object Storage will allow a new bucket to be created within the same compartment as your function application. 
This bucket can take up to 15 minutes to appear after you have invoked a function that you have deployed to it. Once the bucket
has been created, a link will appear on the application screen (sse the screenshot below) giving you a simple way to access it.
In order to have the bucket get created and be accessible you need to ensure you have the right policy granted.

For more information on enabling logging go [here](https://docs.cloud.oracle.com/iaas/Content/Functions/Tasks/functionsexportingfunctionlogfiles.htm) 
 
### Accessing the log bucket from the console

Once you have deployed a function and attempted to invoke it, the new logging bucket will get created. This can take up to 15 minutes to happen but when it is available or to check if it is, refresh the browser screen on the function application page.

If for any reason after 15 minutes from a function invocation the logging link does not appear, you can manually open a browser tab within Object Storage and select the same compartment as your function resides from the picker.
Search the list of buckets presented for one that has the same name as XXX

### Viewing the log files
