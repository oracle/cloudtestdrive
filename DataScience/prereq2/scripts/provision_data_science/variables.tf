# Copyright (c) 2020 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl.
#  

#*************************************
#           ODS Specific
#*************************************

variable "ods_compute_shape" {}
variable "ods_storage_size" {}
variable "compartment_ocid" {}
variable "ods_number_of_notebooks" {}
variable "functions_enabled" {}

#*************************************
#         Network Specific
#*************************************

variable "ods_vcn_name" {
  default = "Data Science VCN"
}
variable "ods_vcn_cidr" {
  default = "10.0.0.0/16"
}
variable "ods_subnet_public_name" {
  default = "Data Science - Public"
}
variable "ods_subnet_public_cidr" {
  default = "10.0.0.0/24"
}
variable "ods_subnet_private_name" {
  default = "Data Science - Private"
}
variable "ods_subnet_private_cidr" {
  default = "10.0.1.0/24"
}
variable "ods_vcn_use_existing" {
  default = false
}
variable "ods_vcn_existing" {
  default = ""
}
variable "ods_subnet_public_existing" {
  default = ""
}
variable "ods_subnet_private_existing" {
  default = ""
}

#*************************************
#           TF Requirements
#*************************************
variable "tenancy_ocid" {}
variable "region" {}

#*************************************
#        Local Variables
#*************************************
locals {
  public_subnet_id = var.ods_vcn_use_existing ? var.ods_subnet_public_existing : oci_core_subnet.ods-public-subnet[0].id
  private_subnet_id = var.ods_vcn_use_existing? var.ods_subnet_private_existing : oci_core_subnet.ods-private-subnet[0].id
}

#*************************************
#           Data Sources
#*************************************

data "oci_identity_tenancy" "tenant_details" {
  #Required
  tenancy_id = var.tenancy_ocid
}
data "oci_identity_regions" "home-region" {
  filter {
    name   = "key"
    values = [data.oci_identity_tenancy.tenant_details.home_region_key]
  }
}
data "oci_identity_regions" "current_region" {
  filter {
    name = "name"
    values = [var.region]
  }
}
data "oci_identity_compartment" "current_compartment" {
  #Required
  id = var.compartment_ocid
}