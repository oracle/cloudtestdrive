# Copyright (c) 2020 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl.
#

#*************************************
#           API Gateway
#*************************************

// Gateway
resource oci_apigateway_gateway ods-gateway {
  count = var.functions_enabled ? 1:0
  #Required
  compartment_id = var.compartment_ocid
  display_name = "Data Science Gateway"
  endpoint_type = "PUBLIC"
  subnet_id = local.public_subnet_id
}

// gateway Deployment
resource "oci_apigateway_deployment" "ods-gateway-deployment" {
  count = var.functions_enabled ? 1:0
  #Required
  compartment_id = var.compartment_ocid
  display_name = "Data Science Gateway Deployment"
  gateway_id = oci_apigateway_gateway.ods-gateway[0].id
  path_prefix = "/ods"
  specification {
    routes {
      backend {
        type = "ORACLE_FUNCTIONS_BACKEND"
        function_id = oci_functions_function.ods-model-function[0].id
      }
      path = "/model"
      methods = ["POST"]
    }
  }
}

#*************************************
#           Functions
#*************************************
// App
resource "oci_functions_application" "ods-application" {
  count = var.functions_enabled ? 1:0
  #Required
  compartment_id = var.compartment_ocid
  display_name = "odsapp"
  subnet_ids = [local.private_subnet_id]
}

// Function
resource oci_functions_function ods-model-function {
  count = var.functions_enabled ? 1:0
  #Required
  application_id = oci_functions_application.ods-application[0].id
  display_name = "odsfunc"
  image = "${lower(data.oci_identity_regions.current_region.regions.0.key)}.ocir.io/${data.oci_identity_tenancy.tenant_details.name}/odsmodelfunc:0.0.1"
  memory_in_mbs = "1024"

}