The following steps are done using the OCI Cloud shell. To open this click the [cloud shell icon here] Once open you can expand it using the [insert expand button] or minimise it using the [insert minimise cloud shell button]

To interact wihe the OCI DevOps Code Repository we will soon be creating we need to authenticate ourselves to OCI using an authentication token, this will be based on your **Users** SSH key. 

**IMPORTANT** The SSH based API authentication we will be doing is not the same as the SSH setup used when accessing a virtual machine using SSH. If you already have setup a SSH key for **User** API access **In the OCI Cloud Shell** then you can skip the following steps and go to the **.ssh/config** session below in task [insert task link] If you are doing this lab in a free trial account it is unlikely that you will have configured SSH access.

Firstly open the OCI Cloud shell

create the .ssh directory to hold the keys we are about to create.

mkdir -p $HOME/.ssh

cd $HOME/.ssh

Now we can create the keys to use, we are going to do this rather than let the web UI do it as this means we don't have to transfer them over from your computer. Note that if you have already got ssh API keys configured for authentication you can just transfer them into id_rsa and id_rsa.pub files in this folder (if they weren't create in the OC Cloud Shell). If you prefer to use new keys please do so, but remember than you can only have three API Keys in each account.

run the following command to create a key pair, when prompted for a pass phrase just press return (a pass phrase can be used to secure access to the generated key, but that requires some additional setup so in the interests of time not going to use that here). Please replace `<email address>` with the email address for your user (for a free tenancy this is usually the one you provided during the signup process)

`ssh-keygen -t rsa -f $HOME/.ssh/id_rsa -C "<email address>" `

```
Generating public/private rsa key pair.
Enter passphrase (empty for no passphrase): 
Enter same passphrase again: 
Your identification has been saved in id_rsa.
Your public key has been saved in id_rsa.pub.
The key fingerprint is:
SHA256:aeAiZrPoYTT3EtPg8Yq2JDvIovLR0syh/wN3RI8em1M tim_graves@4d82c9745b49
The key's randomart image is:
+---[RSA 2048]----+
|                 |
|        .        |
|   . ... o       |
|  . +...+.E      |
| o=Xo..+S=       |
|++oX*.o.*        |
|===S== . .       |
|B *+o .          |
|o+......         |
+----[SHA256]-----+
```

Now we need to get the public part of the key into PEM format so OCI can process it

ssh-keygen -f ~/.ssh/id_rsa.pub -e -m pkcs8

```
-----BEGIN PUBLIC KEY-----
MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAxkHgmQxKd2jGBK5m3ym0
p5CnvKye0nkMwmE3vXbEwJwfHF16m+eTjpKxRsu6xZE4r4CHtyMm1cE8Tk9Ud8kI
e5RrslqWlPgQhzla7dmB1PiHvPdP2CXpWz5ijlOVayKZ7/yP3W1AtRoMsAgigfLf
v9Kepvaa+6o5846SAS1KcYBxCmNBTvUCRSBCPXNkydtf2z2t071jQP8ZxBw+Tse2
y4mAl0BXd2zThIYd1imkAh/LBcczE8dSXqZUn2070jpjaFzccpzKNNI7KcB/cQsd
tcl+Vi2ZjhRxBQE7Vtrgzgj15cBeWUEFW+5w4vshgnIpP9V+PvsXDvmY0ZmAht++
xwIDAQAB
-----END PUBLIC KEY-----
```

Now let's set this up as an API token in your account

Click the "Shaddow person" on the upper right, then your user name to get to your user details page

On the left side Under `Resoures` click  `API Keys`

Provided you have less than three API keys listed you can proceed with adding your new key, if not you will either have to delete an existing key, or locate the private key that matches one of the existing keys.

Click the `Add API Key` button

Click `Paste public key`

Copy the **entire** output we just got above **including** the Begin and End lines into the box

Click the `Add` button


Next we need to setup our SSH configuration file, to do that we need to get some further information.

Click the "Shaddow person" Icon, but this time just display the menu

Locate and copy the user name from the top of the user details page we're still on, in my case that's oracleidentitycloudservice/tim.graves@oracle.com (as I'm using an account with a federated identity the name of the identity system is also part of my user name) but for users in a non federated system (which will be most free trial users) that's going to be just the user name you used when creating the account.

Locate your tenancy information if you click the little "shaddow person" you can see that, in may case it's oraseemeatechse, though of course yours will vary, for a free trial account it's often based on the name you gave when setting up the account.

vi $HOME/.ssh/config

Add the following details, substiture your username and tenancy name
```
Host devops.scmservice.*.oci.oraclecloud.com
  User <your username>@<tenancy name>
  IdentityFile ~/.ssh/id_rsa
```

As an example mine looks like this - but yours of course will differ

```
Host devops.scmservice.*.oci.oraclecloud.com
  User oracleidentitycloudservice/tim.graves@oracle.com@oraseemeatechse
  IdentityFile ~/.ssh/id_rsa
```

Congratulations, you're now ready to use ssh keys to access OCI services !