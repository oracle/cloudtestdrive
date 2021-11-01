We're going to setup some secrets in the OCI vault, we created the vault and the master encryption key earlier so we can just setup the secrets

Before we can do this however we need to work out what values we will be using for those secrets which will be the region code for the OCI Registry (where the containewr images will be stored) and your tenancy storage namespace

#### Determining the Oracle Cloud Infrastructure Registry region code

The OCIR region code is based on the IATA code for the city hosting the region, for example Frankfurt has an IATA core of `fra` and Amsterdam is `ams`. Unfortunately some cities (e.g. London) have multiple airports, in others the IATA airport code refers to an old name for the city, or the airport itself is not directly named after the city it serves, so we need to look the right code up based on our region.

  1. To determine your region look at the top of your Oracle Cloud GUI in the web browser and you'll see your current region.

  ![](images/region-name.png)

  2. If you click on the name you'll get a list of regions enabled for your tenancy and your home region

  ![](images/regions-list.png)

You can see here in this example we're using the Frankfurt region, which is also our home region.

  3. Now go to the [OCIR Availability By Region list.](https://docs.cloud.oracle.com/en-us/iaas/Content/Registry/Concepts/registryprerequisites.htm#Availab)

  4. Locate your region on the list and then to the right identify the region code, for example we can see below in the case of Frankfurt the OCIR region code to use is `fra` for Sydney it's `syd`

  ![](images/fra.png)

  5. In this case it means that for the OCIR hostnamne I will be using `fra.ocir.io` If my region has been Sydney it wioudl be `syd.ocir.io` and so on. Note down the OCIR hostname you have just determined.
  
  
#### Determining your tenancy Object Storage Namespace

  1. Click the shaddow person image on the upper right of any page

  2. Click on the entry in the menu for the tennancy

  ![](images/objstor.png) 

  3. Note down the **Object Storage Namespace** of your tenancy, in the example above this is `frjqogy3byob` **but yours will be different** (this is what we mean when we say tenancy storage namespace in these labs)

In the OCI browser UI go to the vault
Click on the Hamburger menu -> Identity and security -> Fault

Click on the name of your vault in the list (If it's not showing be cure to check you are in the right compartment using the copartment selector on the left of the page)

In the Resource section on the left of the page click **Secrets**, then click **Create Secret**

Confirm the compartment is the one you are using

Name the secret `OCIR_HOST_VAULT`

Provide a description if you wish

In the encryption key chose the master key you created earlier

In the **Secret Template Type** be sure it's plain text

In the **Secret Contents** enter the name you determined for the OCIR in your region, for example in my case that's `fra.ocir.io` but of course it may be different for you if you are in a different region.

Click the **Create Secret** button

It will take a short while to create the secret, but you can carry on while that's happening.

Click the three dots on the left of the row containing your secret, take the **Copy OCID** option, paste the OCID into a note pad or somethihng, being sure to identify it so you know its for the OCIR_HOST_VAULT secret

Follow the steps above to create a OCIR_STORAGE_NAMESPACE_VAULT secret, but in this case the contents will be the tenancy storage namespace you determined earlier, remember when you save its OCID away to identify it as the tenancy storage OCID.


We're about to be making changes to the code, so let's create a new git branch to hold these so we don't modify with the underlying main branch (if you wanted you could always delete this branch later on and revert the main branch to return the environment in the cloud shell to it's original condition, git is useful like that !)

In the OCI Cloud shell
git checkout -b my-lab-branch

Let's check this change has happned as expected
In the OCI Cloud shell

git branch --list

Note that our new my-lab-branch branch is the one currently checked out (is has a * in front of it)

Go to the OCI Cloud shell (open it if needed) and make sure you are in the cloud-native-storefront directory that contains the git repo we downloaded earlier

cd $HOME/cloudnative-helidon-storefront

Edit the helidon-storefront-full/yaml/build/build_spec.yaml file in the OCI cloud shell (vi and nano are available), locate the `vaultVariables` section in the YAML and REPLACE the current OCI_HOST_VAULT value (`Needs your host secrets OCID`) with the OCID of the OCIR_HOST_VAULT secret you just created. For the and OCIR_STORAGE_NAMEPACE_VAULT variable REPLACE its current value (`Needs your storage namespace OCID`) with the OCID of the OCIR_STORAGE_NAMESPACE_VAULT you just created.

Save the file away

Let's commit these changes to your local git repo (the one in the cloud shell you are using) 
In the OCI Cloud shell
git commit -a -m 'Set secret OCIDs'

Now push the repo branch to the OCI Code repo you created earlier
In the OCI Cloud shell
git push devops my-lab-branch

Our changes have now been uploaded to the OCI Code repo, if you want go to the `cloud-native-storefront` Code Repository in your project, be sure to select the `my-lab-branch` in the branch selector and look at the build_spec.yaml, you'll see the updated values (of course these are mine, yours will be different)

