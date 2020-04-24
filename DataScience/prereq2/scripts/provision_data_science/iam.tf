# Copyright (c) 2020 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl.
#

#*************************************
#           Groups
#*************************************

resource "oci_identity_group" "ods-group" {
  provider = oci.home
  compartment_id = var.tenancy_ocid
  description = "Data Science Group"
  name = "Data_Science_Group"
}

#*************************************
#          Dynamic Groups
#*************************************

resource "oci_identity_dynamic_group" "ods-dynamic-group" {
  provider = oci.home
  compartment_id = var.tenancy_ocid
  description = "Data Science Dynamic Group"
  name = "Data_Science_Dynamic_Group"
  matching_rule = "any {all {resource.type='fnfunc',resource.compartment.id='${var.compartment_ocid}'}, all {resource.type='ApiGateway',resource.compartment.id='${var.compartment_ocid}'} }"
}

#*************************************
#           Policies
#*************************************

resource "oci_identity_policy" "ods-policy" {
  provider = oci.home
  compartment_id = var.compartment_ocid
  description = "Data Science Policies"
  name = "Data_Science_Policies"
  statements = [
        "Allow group ${oci_identity_group.ods-group.name} to manage data-science-family in compartment ${data.oci_identity_compartment.current_compartment.name}",
        "Allow group ${oci_identity_group.ods-group.name} use virtual-network-family in compartment ${data.oci_identity_compartment.current_compartment.name}",
        "Allow service datascience to use virtual-network-family in compartment ${data.oci_identity_compartment.current_compartment.name}",
        "Allow dynamic-group ${oci_identity_dynamic_group.ods-dynamic-group.name} to use virtual-network-family in compartment ${data.oci_identity_compartment.current_compartment.name}",
        "Allow dynamic-group ${oci_identity_dynamic_group.ods-dynamic-group.name} to use functions-family in compartment ${data.oci_identity_compartment.current_compartment.name}",
        "Allow dynamic-group ${oci_identity_dynamic_group.ods-dynamic-group.name} to manage public-ips in compartment ${data.oci_identity_compartment.current_compartment.name}",
        "Allow service FaaS to use virtual-network-family in compartment ${data.oci_identity_compartment.current_compartment.name}"
  ]
}

resource "oci_identity_policy" "ods-root-policy" {
  provider = oci.home
  compartment_id = var.tenancy_ocid
  description = "Data Science Root Policies"
  name = "Data_Science_Root_Policies"
  statements = [
      "Allow service FaaS to read repos in tenancy"
  ]
}