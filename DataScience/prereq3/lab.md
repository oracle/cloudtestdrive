![](../commonimages/workshop_logo.png)

This lab can be executed using either Oracle Analytics Desktop (local installation) or Oracle Analytics Cloud (cloud environment). 

**Option 1: Install Oracle Analytics Desktop and Machine Learning packages**

Important: Don't forget to **install the open source Machine Learning packages** after you've installed Oracle Analytics Desktop.

1. Download DVD by clicking [here](https://www.oracle.com/middleware/technologies/oracle-data-visualization-desktop.html#) and follow the instructions. 
2. Install DVD locally on your computer. 
3. The Machine Learning in DVD relies on open source packages that are -not- installed by default. To install these packages, go to the Windows Start menu, browse to Oracle (or type "install DVML") and click Install DVML. **You need a non-proxy connection to the internet for this to work.**
4. The installer starts on completion of the download. Simply follow the instructions.
5. If Oracle Analytics Desktop was running during the installation, then restart it for the changes to take effect.


**Option 2: Provision Oracle Analytics Cloud**

1. Click the "hamburger" menu on the top left.

![](./images/oac1.png)

2. Select Analytics from the menu.

![](./images/oac2.png)

3. Choose a compartment.

![](./images/oac3.png)

4. In the configuration screen, do the following:
- Instance name: Any name you choose
- Feature Set: Enterprise Analytics
- OCPU: 2
- Network access: Public
- License type: "Subscribe to a new Analytics Cloud...". Note that you are in a free trial.

Click Next.
  
- Click "Create". The status changes to "Creating...". Provisioning can take up to 30min.
![](./images/oac8.png)


## Next

Continue to [Prerequisite 4: Provision Autonomous Transaction Processing database](../prereq4/lab.md).
