# Forms on OCI with Universal Credits 

## Extra operations
### Rebuild the WLS_STACK based on a new version of WLS on OCI stack.
This script is based on the WebLogic Marketplace automation version 21.1.3-210316164607, that was published in March 2021.  As this script is updated regularly, you might want to rebase your Forms automation to be based on the latest version.  This script will allow you to adapt the base WLS for OCI Marketplace script to include the required steps to launch the Forms installation at the end of the process.

One of the key drivers is the use of newer images of the the WLS VM Image, with newer patch sets or higher versions of the JDK.

Execute following steps:

* Create a new WLS stack on OCI. When created in resource manager. Download the terraform script. (zip file)

* Rename the file `wls_stack.zip` and place it in directory `WLS_STACK`

* Run below command: 

  ```
  bin/wls_stack_build/terraform_wls_stack_build.sh
  ```




## Additional notes
- To restart the domain:
  /opt/scripts/restart_domain.sh
- Tp recreate the domain when the wls instance is created:
  - Drop the domain directory in /u01/data/domain/xxxx
  - Check what terraform/wls_stack/compute/instance/bootstrap does
  - In short, often, it is:
```
    cd /opt/scripts/
    ./terraform_init.sh
    sudo /mnt/software/install_bin/install_part2.sh
```