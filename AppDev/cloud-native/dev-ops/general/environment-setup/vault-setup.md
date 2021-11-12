We need to configure a Vault to hold some secrets. We are going to do this to show one of the several ways we can include customization information into the pipeline.

In the Hamburger menu go to **Identity & Security** then **Vault**

Use the Compartment selector on the left side to be sure to use the compartment you're running this lab in. If you're doing this in a free tiral account that will probably be CTDOKE, in a shared or paid tenancy it will probably be different.

Click the **Create Vault** button to start the wizard

Double check the right compartment is selected and name the vault, I's suggest something like `<YOUR INITIALS>/DevOps` Ensure that the **Make it a private vault** option is not selected, click the **Create Vault** button.

This process can take a few minutes, so if you like do the ssh setup or policy setup while you are waiting and then return back here.

Next you need to creeate a master key to protect the data in the vault, click the vault name to open it's page, make sure you are on the **Master encryption Keys** in the **Resources** section on the left side and click `Create Key`

Confirm that the compartment is the one you're using for this lab, Ensure that the protection mode is set to `HSM` and make the key - I'd suggest something like `<YOUR INITIALS>Key` but as long as you remember it the name doesn't matter. Check the **Key Shape** is set to `AES (Symmetric key used for Encrypt and Decrypt)` and the **Key Shape Length** is set to `256 bits`.

Click the **Create Key** button