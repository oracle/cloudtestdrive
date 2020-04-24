# Copyright (c) 2020 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl.
#

#*************************************
#           ODS Project
#*************************************

resource "oci_datascience_project" "ods-project" {
  #Required
  compartment_id = var.compartment_ocid
  display_name = "Data Science Project"
  description = "Data Science"
}

#*************************************
#           ODS Project Session
#*************************************

resource "oci_datascience_notebook_session" "ods-notebook-session" {
  count = var.ods_number_of_notebooks
  #Required
  compartment_id = var.compartment_ocid
  notebook_session_configuration_details {
    #Required
    shape = var.ods_compute_shape
    subnet_id = local.public_subnet_id

    #Optional
    block_storage_size_in_gbs = var.ods_storage_size
  }
  project_id = oci_datascience_project.ods-project.id

  display_name = "Data Science Session-${count.index}"
}