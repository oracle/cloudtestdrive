# Run Kubeflow pipelines on OKE

Kubeflow is a collection of cloud native tools for all of the stages of MDLC (data exploration, feature preparation, model training/tuning, model serving, model testing, and model versioning).

Kubeflow provides a unified system—leveraging Kubernetes for containerization and scalability, for the portability and repeatability of its pipelines.

<!-- (source https://learning.oreilly.com/library/view/kubeflow-for-machine/9781492050117/ch01.html#idm45831188258120) -->

## Introduction

This lab covers the steps to install Kubeflow v1.5 and run your first pipelines.

You will learn:

- Deploy Kubeflow with OKE
- Enable NFS class storage
- Run your first Pipelines
  - Kubeflow Demo XGBoost - Iterative model training
  - Run a piple with node pool selector (CPU or GPU)
  - Run MNIST E2E Demo on Kubeflow
- optional to enable OKE autoscaling

## Prerequisites

Use Cloud Shell console
oci-cli, kubectl, git are integrated

<!-- ### Install OCI client

    sudo dnf -y install oraclelinux-developer-release-el8
    sudo dnf install python36-oci-cli

oci setup autocomplete

    eval "$(_OCI_COMPLETE=source oci)"

### Install Kubectl

    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
    sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

### Install git

    sudo dnf install git

### Install Helm

    curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
    chmod 755 get_helm.sh
    sudo ./get_helm.sh

Install in /usr/local/bin/helm
 -->
## Warning

- **Kubeflow 1.6.0 is not compatible with version 1.21 and backwards.**
  - You can track the remaining work for K8s 1.22 support in kubeflow/kubeflow#6353
https://github.com/kubeflow/kubeflow/issues/6353

- Kustomize (version 3.2.0) ([download link](https://github.com/kubernetes-sigs/kustomize/releases/tag/v3.2.0))
    - Kubeflow 1.6.0 is not compatible with the latest versions of Kustomize.
  <!-- - This is due to changes in the order resources are sorted and printed. Please see kubernetes-sigs/kustomize#3794 and kubeflow/manifests#1797. We know this is not ideal and are working with the upstream kustomize team to add support for the latest versions of kustomize as soon as we can. -->
<!-- - kubectl -->

## Steps

[Task 1 - Create an OKE cluster](./Lab-Kubeflow-step1.md)

[Task 2 - Install Kubeflow](./Lab-Kubeflow-step3.md)

[Task 3 - Run Kubeflow pipelines](./Lab-Kubeflow-step4.md)

[Task Optional](./Lab-Kubeflow-step5.md)
