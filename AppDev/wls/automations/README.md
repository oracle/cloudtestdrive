# Using Terraform to launch the WebLogic Marketplace Stack - Overview

Using Marketplace to launch Marketplace Images is one thing, and a few blogs have already been written on that topic.  But what about automating the launch of a Marketplace **Stack**, in particular a "Pay-as-you-go" stack like WebLogic ?

This is an article series that will explore your options to work with Terraform and the Marketplace Stacks and Images of WebLogic as provided on the Marketplace, offering you the ability to spin up your own customized stacks using the "Pay-as-you-go" consumption of WebLogic licenses.

- In [the first article](Automated_wls_stack_launch.md) I will focus on how you can **automate the launch of the WebLogic stack** as it is provided on Marketplace, using Terraform and a bit of OCI Command Line.

- In [the second article](WebLogic_Pay-as-you-go_Image.md) I will detail how you can omit the provided automation of the stack, and spin up a UC consumping instance as part of a **custom configuration of WLS** you might already have
- And finally in [the third article](WebLogic_Pay-as-you-go_Nodepool.md) I'll explain how you can **add Kubernetes node pools consuming the UC flavor** of WebLogic to an existing, customer-build setup of WebLogic on Kubernetes.



Happy Terraforming !