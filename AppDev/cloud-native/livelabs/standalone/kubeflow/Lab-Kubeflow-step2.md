## Task 2 -  NFS StorageClass

Kubeflow recognizes default StorageClass
Follow the steps to add FileStorage service (NFS) as StorageClass.

1. Create File Storage

  In the Console, open the navigation menu and click Storage. Under File Storage click File Systems.
  ![Create File Storage Menu](images/CreateFileStorageMenu.png)

  Click Create File System
  ![Create File System](images/CreateFileSystem.png)

  Edit export information
  ![Export Path](images/CreateExportPath.png)

  Edit Mount target information
  Use the worker node subnet.
  ![Mount Target Information](images/MounTargetInformation.png)

  To get the mount point IP Address.
  Click on the Mount Target to get the IP Address of the mount point. To get Linux Mount commands on the moun and export path.
  ![Mount Point IP](images/MountPointIP.png)

  2. Install NFS subdir external provisioner

  Using the path and IP collected you can deploy NFS helm chart.
  
    helm repo add nfs-subdir-external-provisioner https://kubernetes-sigs.github.io/nfs-subdir-external-provisioner/
    helm install nfs-subdir-external-provisioner nfs-subdir-external-provisioner/nfs-subdir-external-provisioner \
    --set nfs.server=10.0.0.7 \
    --set nfs.path=/kubeflow

  Documentation
  https://kubernetes.io/docs/concepts/storage/storage-classes/#nfs
