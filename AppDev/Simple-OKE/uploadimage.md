# Push an Image to Oracle Cloud Infrastructure Registry

## Before You Begin

This 10-minute tutorial shows you how to:

- create an auth token for use with Oracle Cloud Infrastructure Registry
- log in to Oracle Cloud Infrastructure Registry from the Docker CLI
- pull a test image from DockerHub
- tag the image
- push the image to Oracle Cloud Infrastructure Registry using the Docker CLI
- verify the image has been pushed to Oracle Cloud Infrastructure Registry using the Console



### Background

Oracle Cloud Infrastructure Registry is an Oracle-managed registry that enables you to simplify your development to production workflow. Oracle Cloud Infrastructure Registry makes it easy for you as a developer to store, share, and manage development artifacts like Docker images. And the highly available and scalable architecture of Oracle Cloud Infrastructure ensures you can reliably deploy your applications. So you don't have to worry about operational issues, or scaling the underlying infrastructure.

In this tutorial, you'll first create an auth token to access Oracle Cloud Infrastructure Registry. You'll then pull a test image from DockerHub and give it a new tag. The new tag identifies the Oracle Cloud Infrastructure Registry region, tenancy, and repository to which you want to push the image.

Having given the image the tag, you then push it to Oracle Cloud Infrastructure Registry using the Docker CLI. Finally, you'll verify the image has been pushed successfully by viewing the repository that has been created.

### What Do You Need?

- An Oracle Cloud Infrastructure username and password.



------

## ![section 1](https://www.oracle.com/webfolder/technetwork/tutorials/obe/oci/registry/img/32_1.png)Start Oracle Cloud Infrastructure

1. In a browser, go to the url you've been given to log in to Oracle Cloud Infrastructure.
2. ![Sign In page](https://www.oracle.com/webfolder/technetwork/tutorials/obe/oci/registry/img/oci-login-page.png)

3. 

4. Enter your username and password, and click **Sign In**. This tutorial assumes the username is jdoe@acme.com.

------

## ![section 2](https://www.oracle.com/webfolder/technetwork/tutorials/obe/oci/registry/img/32_2.png)Visualize the Repository

1. Confirm that you can access Oracle Cloud Infrastructure Registry:

2. 1. In the Console, open the navigation menu. Under **Solutions and Platform**, go to **Developer Services** and click **Registry**.

   2. Choose the region in which you will be working (for example, us-phoenix-1). 

   3. Review the repositories that already exist. This tutorial assumes that no repositories have been created yet.

      ![Registry page](https://www.oracle.com/webfolder/technetwork/tutorials/obe/oci/registry/img/oci-registry-no-images.png)

      

## ![section 3](https://www.oracle.com/webfolder/technetwork/tutorials/obe/oci/registry/img/32_3.png)Login to Oracle Cloud Infrastructure Registry from the Docker CLI

1. In a terminal window on the client machine running Docker, log in to Oracle Cloud Infrastructure Registry by entering:

   ```
   docker login fra.ocir.io
   ```

   When prompted, enter your username in the format `<tenancy-namespace>/<username>`. For example, oractdemeabdmnative/api.user. 

2. When prompted, enter the **auth token** as the password.

   ![Terminal window](https://www.oracle.com/webfolder/technetwork/tutorials/obe/oci/registry/img/oci-docker-login.png)


------

## ![section 4](https://www.oracle.com/webfolder/technetwork/tutorials/obe/oci/registry/img/32_4.png)Pull the hello-world Image from DockerHub

1. In a terminal window on the client machine running Docker, enter

   ```
   docker pull karthequian/helloworld:latest
   ```

   to retrieve the latest version of the hello-world image from DockerHub.

   ![Terminal window](https://www.oracle.com/webfolder/technetwork/tutorials/obe/oci/registry/img/oci-docker-pull.png)

   

   The different layers of the helloworld image are each pulled in turn.

------

## ![section 5](https://www.oracle.com/webfolder/technetwork/tutorials/obe/oci/registry/img/32_5.png)Tag the Image for Pushing

1. In a terminal window on the client machine running Docker, give a tag to the image that you're going to push to Oracle Cloud Infrastructure Registry by entering:

   ```
   docker tag karthequian/helloworld:latest
   fra.ocir.io/oractdemeabdmnative/<repo-name>/<image-name>:<tag>
   ```

   where:

   - `<repo-name>`  is the name of a repository to which you want to push the image (for example, `project01`). Note that specifying a repository is optional. If you don't specify a repository name, the name of the image is used as the repository name in Oracle Cloud Infrastructure Registry.
   - `<image-name>` is the name you want to give the image in Oracle Cloud Infrastructure Registry (for example, `helloworld`).
   - `<tag>` is an image tag you want to give the image in Oracle Cloud Infrastructure Registry (for example, `latest`).

   For example:

   ```
   docker tag karthequian/helloworld:latest fra.ocir.io/oractdemeabdmnative/myrepo/helloworld:latest
   ```

   ![Terminal window](https://www.oracle.com/webfolder/technetwork/tutorials/obe/oci/registry/img/oci-docker-tag.png)

3. Review the list of available images by entering:

   ```
   docker images
   ```

   ![Terminal window](https://www.oracle.com/webfolder/technetwork/tutorials/obe/oci/registry/img/oci-docker-images.png)

   

   Note that although two tagged images are shown, both are based on the same image (with the same image id).

------

## ![section 6](https://www.oracle.com/webfolder/technetwork/tutorials/obe/oci/registry/img/32_6.png)Push the hello-world Image to Oracle Cloud Infrastructure Registry

1. In a terminal window on the client machine running Docker, push the Docker image from the client machine to Oracle Cloud Infrastructure Registry by entering:

   ```
   docker push fra.ocir.io/oractdemeabdmnative/<repo-name>/<image-name>:<tag>
   ```

   For example:

   ```
   docker push fra.ocir.io/oractdemeabdmnative/myrepo/helloworld:latest
   ```

   ![Terminal window](https://www.oracle.com/webfolder/technetwork/tutorials/obe/oci/registry/img/oci-docker-push.png)

   

   The different layers of the helloworld image are each pushed in turn.

------

## ![section 7](https://www.oracle.com/webfolder/technetwork/tutorials/obe/oci/registry/img/32_7.png)Verify the Image has been Pushed to Oracle Cloud Infrastructure Registry

1. In the browser window showing the Console with the **Registry** page displayed, click **Reload**. You see all the repositories in the registry to which you have access, including the private helloworld repository that was created when you pushed the helloworld image.

  ![Registry page](https://www.oracle.com/webfolder/technetwork/tutorials/obe/oci/registry/img/oci-registry-repositories.png)

2. Click the name of the helloworld repository that contains the image you just pushed. You see:

   - The different images in the repository. In this case, there is only one image, with the tag latest.
   - Details about the repository, including who created it and when, its size, and whether it's a public or a private repository
   - The readme associated with the repository. In this case, there is no readme yet.

![Registry page](https://www.oracle.com/webfolder/technetwork/tutorials/obe/oci/registry/img/oci-repository-images.png)

 

3. Provide a readme for the helloworld repository as follows:

   1. Click the **Edit** button in the **Readme** section.

   2. On the **Edit** tab of the Edit Readme dialog, select the **Markdown**

      option, and copy and paste the following description of the helloworld image into the **Content** field:

      ```
      ## Hello World example
      by Karthequian [Pulled from Dockerhub](https://hub.docker.com/r/karthequian/helloworld/)
      ![Helloworld by Karthquian](https://raw.githubusercontent.com/oracle/cloud-native-devops-workshop/master/containers/docker001/images/004-hello-world.png )
      ```

      ![Edit Readme window, Edit tab](https://www.oracle.com/webfolder/technetwork/tutorials/obe/oci/registry/img/oci-image-readme-complete.png)

      

   3. Click the **Preview** tab to see how the readme will appear.

      ![Edit Readme window, Preview tab](https://www.oracle.com/webfolder/technetwork/tutorials/obe/oci/registry/img/oci-image-readme-preview.png)

      

   4. Click **Save** to close the Edit Readme dialog.

4. Click the latest image tag. The Details section shows you the size of the image, when it was pushed and by which user, and the number of times the image has been pulled.

  ![Registry page](https://www.oracle.com/webfolder/technetwork/tutorials/obe/oci/registry/img/oci-image-summary.png)

