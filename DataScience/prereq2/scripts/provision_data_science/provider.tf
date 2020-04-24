# Copyright (c) 2020 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl.
# 

terraform {
  required_version = ">= 0.12"
}

provider "oci" {
  region = var.region
  tenancy_ocid = var.tenancy_ocid
}

provider "oci" {
  alias            = "home"
  region           = lookup(data.oci_identity_regions.home-region.regions[0], "name")
  tenancy_ocid = var.tenancy_ocid

}