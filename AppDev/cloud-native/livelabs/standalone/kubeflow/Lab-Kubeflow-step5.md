# Optional Tasks

1. Optional Port forwarding

If you deploy Kubeflow using API public access from your laptop you can use port forwarding to access Kubeflow Dashboard.

        export NAMESPACE=istio-system
        kubectl port-forward -n ${NAMESPACE} svc/istio-ingressgateway 8080:80

2. Enable OKE Autoscaler

    https://docs.oracle.com/en-us/iaas/Content/ContEng/Tasks/contengusingclusterautoscaler.htm

3. Enabble NFS StorageClass

    [Task - Add NFS Storage Class](./Lab-Kubeflow-step2.md)
