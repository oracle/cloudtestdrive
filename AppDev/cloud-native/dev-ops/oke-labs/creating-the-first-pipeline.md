We're nopw ready to create the actual build pipeline

Navigate to your project page, if need be you can do this form the begininc by : CLick the Hamburger menu -> Developer Services -> Projects (in the DevOps section) and selecting your project.

In the Resources section on the left side of the page click the **Build Pipelies** option

Click create a build pipeline, name it BuildStorefront, provide a description if you want.

After a short while your newly created pipeine will be displayed in the list

We're now going to add a build stage. A build stage runs in it's build runner (each stage has it's own runner)

Click the + icon then **Add Build Stage** to add a build stage

There are multiple types of build stages, The  stage types are described in their boxes, but initially we will be creating a **Managed Build** stage will actually be used to process our build_spec.yaml file

Click the **Managed Build** option, then the **Next** button at the bottom of the page

Name the stage `BuildStorefront`

Enter a description if you like

Leave the Base container image unchanged

In the **Build Spec File Path** enter `${OCI_PRIMARY_SOURCE_DIR}/yaml/build/build_spec.yaml`

Note that we have to specify the location as the build_spec.yaml is not in the root of the project. This is due to the way that Eclipse places projects in a git repo, and I used Eclipse to create the code. (Eclipse allows multiple projects in the same git repo so everything is one level "down" from the top of the repo). If build_spec.yaml has been ad the top level of the git repo the build system would have looked there as the default and we would not have had to specify this.

The devops build system assigns the variable ${OCI_PRIMARY_SOURCE_DIR} to the location in the build runner where the primary git repo is placed during it's setup so for the cloudnative-helidon-storefront this means that build spec is in ${OCI_PRIMARY_SOURCE_DIR}/yaml/build/build_spec.yaml

Note for a full list of the variables setup by the build pipeline infrastructure see the **Build Specification Parameters** section in the [build pipeline documentation](https://docs.oracle.com/en-us/iaas/Content/devops/using/build_specs.htm)

Click the **Select** button in the **Primary Code Repository** section, in the selection type dropdown chose **OCI Code Repository** then once the list has updated and select `cloudnative-helidon-storefront` - the git repo you created for this project, Click the **Save** button

Leave the **Timeout** blank

Click the **Add** button

Note - For this lab we are only using a single git repo which contains all of the code as well as the Kubernetes Manifests, However it's perfectly reasonable for a build to have multiple git repositories, for example if the code and Kubernetes manifests were held in separate repositories (which could with careful pipeline design result in a faster CI/CD process if only the manifests were changed)


Note - For this lab we're only going to create a simple linear pipeline, but if appropriate you can have parallel stages, perhaps you are building multiple library files first which can all be build independently, then combining them all in a last deploy stage and linking the intermediate artifacts with outputArtifact / inputArtifact entries in their build specs

Running our first pipeline 
Let's see this in action, Click the **Start Manual Run** button on the upper right

A window will appear, you can change the Build run name it you needed to, but for now just leave it with the current value. The parameters box shou0dl be empty, as for this part of the lab we have not defined any parameters (we will look into this in a little bit) We only using using variables which get their values from inside the build pipeline, from the vault secrets (e.g. OCIR_HOST_VAULT), are determined inside the build stage (e.g. STOREFRONT_VERSION), or are set for us by the build pipeline infrastructure itself (e.g. OCI_PRIMARY_SOURCE_DIR)

Click the **Start Manual Run** button on the lower left to start the build process.