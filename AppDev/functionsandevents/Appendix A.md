# Appendix A: How do you use Putty with Windows to ssh to an OCI based virtual machine?

As part of this hands on lab there is a need to ssh on to a virtual machine. If you are using a Windows based laptop and are not sure how to use the ssh client Putty, available to install, this guide will help.

Download the latest release of Putty for Windows here : https://www.putty.org/

Double click on the downloaded installer and follow the instructions to simply install on your laptop.

Execute Putty from the desktop shortcut created at installation time or by searching for putty in the Windows 'Start' search.

Using the Public IP Address for the virtual machine you want to ssh to enter this in the 'Hostname (or IP address) section of the Putty configuration screen.

![Oracle Solution Center EMEA > Fn Handson: Functions and Events > image2019-3-7_6-49-53.png](/home/amyles/fnaas/cloudtestdrive/AppDev/functionsandevents/image2019-3-7_6-49-53.png)

Now in the left-hand pane select Connection → SSH → Auth

 ![Oracle Solution Center EMEA > Fn Handson: Functions and Events > image2019-3-7_6-51-39.png](/home/amyles/fnaas/cloudtestdrive/AppDev/functionsandevents/image2019-3-7_6-51-39.png)

Press the 'Browse' button and search for the private key file downloaded as part of the artifacts.zip earlier. You are looking for the file **id_rsa.ppk**

If you wish to enable connection keepalive (if you experience session dropout) select Connection and give a value for the 'Seconds between keepalives ...'

The screen below should help here.

![Oracle Solution Center EMEA > Fn Handson: Functions and Events > image2019-10-7_11-11-59.png](/home/amyles/fnaas/cloudtestdrive/AppDev/functionsandevents/image2019-10-7_11-11-59.png)

Now press the 'Open' button at the bottom of the panel.

![Oracle Solution Center EMEA > Fn Handson: Functions and Events > image2019-3-7_6-56-32.png](/home/amyles/fnaas/cloudtestdrive/AppDev/functionsandevents/image2019-3-7_6-56-32.png)

Say 'Yes' to trust the key and add it to Putty's cache.

![Oracle Solution Center EMEA > Fn Handson: Functions and Events > image2019-3-7_7-28-1.png](/home/amyles/fnaas/cloudtestdrive/AppDev/functionsandevents/image2019-3-7_7-28-1.png)

Give the username as opc when prompted in the new putty terminal session and hit RETURN

You should now be logged in to your virtual machine.

![Oracle Solution Center EMEA > Fn Handson: Functions and Events > image2019-3-7_7-29-15.png](/home/amyles/fnaas/cloudtestdrive/AppDev/functionsandevents/image2019-3-7_7-29-15.png)