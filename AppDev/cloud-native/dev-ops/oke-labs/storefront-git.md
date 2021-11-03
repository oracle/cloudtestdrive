We need a git repo to work with. There are many ways we can work with git in the DevOps service, we could use a repo in github or gitlab directly or create a OCI Code repo (basically a git repo) inside your project which is an automatically updating a mirror of an external git repo on gitlab or github. You could even create your own separate copy of the origional rep in github, but for all of these options you would need to have a github account and also a personal access token and that complicates things (and keeping up with changes to the OCI web UI is hard enough, having to keep up with github / gitlab changes as well would make it difficult to keep this lab up to date.

So for this lab we are going to chose a different approach where every one has a OCI Code repo in their own project, that way you can easily update it and I don't have to worry about trying to push into my main repo holding the demo code !

To start with we're going to create a the OCI Code repo in your project.

On the left side of the project page click on the **Code Repositories** link

Click on the **Create repository** button

Name the repository cloudnative-storefront-helidon

Provide a description if you like, but leave the default branch name blank (it will be set to `main`)

It will take a short while to create the repository

Now we are going download the original repo with the source code for this lab into the OCI cloud shell. We are using the OCI Cloud shell because it has all of the commands we need to do this lab, so you don't need to setup anything on your laptop, we can even make changes to the source code to demonstrate that the pipelines do deploy them! In a production environment of course you'd use your own development systems.

Open the OCI Cloud Shell

First we are going to download the origional repo from github. This is a public repo so you don't need a github account.

make sure you are in your home directory 

cd $HOME

git clone https://github.com/oracle-devrel/cloudnative-helidon-storefront.git

This will create a folder called cloudnative-helidon-storefront in your home directory

switch to it

cd cloudnative-helidon-storefront

tell git who we are so it can track who makes changes, run the commands below replacing `<your email` and `<your name>` you can use anything you want here as this is just a lab, but in a real project you'd use your real email and name

  git config  user.email "<your email>"
  git config user.name "<your name>"
  
We are only setting these for this specific project, do don;t worry, doing this will not effect any other git projects you have in the OCI Cloud Shell

Git operates on the idea of branches, like a tree, there is the `main` branch and then the sub branches. Each branch has it's own view ot the file structure based on what the parent branch looked like when the sub-branch was created It's regarded as good practice to do your development in a sub branch and make sure it's all working fine before merging your changes into the `main` branch, usually with some form of review and approval process.  This is a simplistic description, but for the purposes of this lab it covers what you need to know, there are **lots** of places on the wab and published books where you can get more details if you want.

switch to the right branch (ONLY NEEDED RIGHT NOW, in the finished lab I'll have committed initial-code-added into the main branch)
git checkout initial-code-added

in the OCI Code Repository page for your newly created repo  page click the **Clone** button, to the right of the **Clone with SSH** field click the `Copy` link to get the path to access the repo with git. For this to work you **must** have setup ssh keys in your account and updated the .ssh/config file as described in the ssh setup step.

We are not going to create a connection to the OCI Code Repository you created
git remote add <paste the ssh path here>

for saftey remove the connection to the original repo in github - you shoudln't be able to push to this anyway, but it will prevent me getting lot's of pull requests !
git remote remove origin

Let's confirm we've made the changes - this output should only contain `devops`
git remote

make sure we're "up to date" with our new code repo, the --no-edit option just tells git to use default text when combingin the content, normally that's a bad ide, but here we're just setting things up so it's fine
git pull --no-edit devops main

Now let's push our active branch to the repo ( NEED TO CHECK THIS WORKS PROPERLY IF USING main RATHER THEN initial-code-added on the github repo)
git push devops initial-code-added

