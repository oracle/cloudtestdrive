These are obselete for the K8S lab I think

### 4. Getting your docker credentials and other information

There are a few details (registry id, authentication tokens and the like) you will need to get before you push your images. 

- Please follow the instructions in this document for [getting your docker details](../ManualSetup/GetDockerDetailsForYourTenancy.md)

As there are may be many attendees doing the lab going through the same tenancy we need to separate the different images out, so we're also going to use your initials / name / something unique 

Your full repo will be a combination of the repository host name (e.g. fra.ocir.io for an Oracle Cloud Infrastructure Registry) the tenancy storage name (for example oractdemeabdmnative) and the  details you've chosen

### 5. Docker login in to the Oracle Container Image Registry (OCIR)

We need to tell docker your username and password for the registry. 

You will have gathered the information needed in the previous step. You just need to execute the following command, of course you need to substitute the fields

`docker login <region-code>.ocir.io --username=<tenancy object storage name>/oracleidentitycloudservice/<user name> --password='<auth token>'`

where :

- `<region-code>` : 3-letter code of the region you are using
- `<tenancy object storage name>` : name of your tenancy's Object Storage namespace
- `<user name>` : user name you used to register
- `<auth token>`: Auth token you associated with your username

All of this is information you gathered when you were [getting your docker details](../ManualSetup/GetDockerDetailsForYourTenancy.md)

For example a completed version may look like this (this is only an example, use your own values) **Important** The auth token being used for the password may well contain characters with special meaning to the Unix shell, so it's important to include it in single quotes as in the example below ( ' )

`docker login fra.ocir.io --username=cdtemeabdnse/oracleidentitycloudservice/my.email@company.com --password='q)u70[]eUkM1u}zu;:[L'`

Enter the command with **your** details into the OCI Cloud Shell to log in to the Oracle Cloud Image Registry


### 6. Copy the pre-built Docker images  

- Download the pre-built docker images by executing following commands: **IMPORTANT** run these exactly as they are, don't change any of the parameters as here you are downloading from an existing repository

```
docker pull fra.ocir.io/oractdemeabdmnative/h-k8s_repo/storefront:0.0.1
docker pull fra.ocir.io/oractdemeabdmnative/h-k8s_repo/storefront:0.0.2
docker pull fra.ocir.io/oractdemeabdmnative/h-k8s_repo/stockmanager:0.0.1
```

- Change the docker image tags as follows, replacing following strings:
  - the target OCIR name  **\<myregion\>** with your datacenter name (for example fra.ocir.io)
  - the tenancy Object Storage Namespace (**\<mytenancystoragenamespace\>** in the example)
  - your chosen repository name (**\<myrepo\>** in the example)

```
docker tag fra.ocir.io/oractdemeabdmnative/h-k8s_repo/storefront:0.0.1 <myregion>.ocir.io/<mytenancystoragenamespace>/<myrepo>/storefront:0.0.1
docker tag fra.ocir.io/oractdemeabdmnative/h-k8s_repo/storefront:0.0.2 <myregion>.ocir.io/<mytenancystoragenamespace>/<myrepo>/storefront:0.0.2
docker tag fra.ocir.io/oractdemeabdmnative/h-k8s_repo/stockmanager:0.0.1 <myregion>.ocir.io/<mytenancystoragenamespace>/<myrepo>/stockmanager:0.0.1
```



- Push the images up to your tenancy repo
  - Again changing the myregion, mytenancystoragenamespace and myrepo parameters in the following commands to match the ones you used when you tagged the images

```
  docker push <myregion>.ocir.io/<mytenancystoragenamespace>/<myrepo>/storefront:0.0.1
  docker push <myregion>.ocir.io/<mytenancystoragenamespace>/<myrepo>/storefront:0.0.2
  docker push <myregion>.ocir.io/<mytenancystoragenamespace>/<myrepo>/stockmanager:0.0.1
```

<details><summary><b>Upload denied error?</b></summary>
<p>

If during the docker push stage you get image upload denied errors then it means that you do not have the right policies set for your groups in your tenancy. This can happen in existing tenancies if you are not an admin or been given rights via a policy. (In a trial tenancy you are usually the admin with all rights so it's not generally an issue there.) You will need to ask your tenancy admin to add you to a group which has rights to create repos in your OCIR instance and upload them. See the [Policies to control repository access](https://docs.cloud.oracle.com/en-us/iaas/Content/Registry/Concepts/registrypolicyrepoaccess.htm) document.

</p></details>