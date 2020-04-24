# Copyright (c) 2020 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl.
#

#*************************************
#               VCN
#*************************************

resource "oci_core_vcn" "ods-events-vcn" {
  count = var.ods_vcn_use_existing ? 0 : 1
  cidr_block     = var.ods_vcn_cidr
  compartment_id =   var.compartment_ocid
  dns_label      = "ods"
  display_name = var.ods_vcn_name
}

#*************************************
#           Subnet
#*************************************

resource "oci_core_subnet" "ods-public-subnet" {
  count = var.ods_vcn_use_existing ? 0 : 1
  #Required
  cidr_block     = var.ods_subnet_public_cidr
  compartment_id =   var.compartment_ocid
  vcn_id         = oci_core_vcn.ods-events-vcn[0].id
  display_name   = var.ods_subnet_public_name

  # Public Subnet
  prohibit_public_ip_on_vnic = false
  dns_label                  = "odspublic"
  route_table_id = oci_core_route_table.ods-public-rt[0].id
  security_list_ids = [oci_core_security_list.ods-public-sl[0].id]
}

resource "oci_core_subnet" "ods-private-subnet" {
  count = var.ods_vcn_use_existing ? 0 : 1
  #Required
  cidr_block     = var.ods_subnet_private_cidr
  compartment_id =   var.compartment_ocid
  vcn_id         = oci_core_vcn.ods-events-vcn[0].id
  display_name   = var.ods_subnet_private_name

  # Private Subnet
  prohibit_public_ip_on_vnic = true
  dns_label                  = "odsprivate"
  route_table_id = oci_core_route_table.ods-private-rt[0].id
  security_list_ids = [oci_core_security_list.ods-private-sl[0].id]
}


#*************************************
#         Internet Gateway
#*************************************

resource "oci_core_internet_gateway" "ods-gateway" {
  count = var.ods_vcn_use_existing ? 0 : 1
  #Required
  compartment_id =   var.compartment_ocid
  vcn_id         = oci_core_vcn.ods-events-vcn[0].id

  #Optional
  display_name = "Data Science Internet Gateway"
  enabled      = true
}

#*************************************
#         NAT Gateway
#*************************************

resource "oci_core_nat_gateway" "ods-nat-gateway" {
  count = var.ods_vcn_use_existing ? 0 : 1
  #Required
  compartment_id = var.compartment_ocid
  vcn_id = oci_core_vcn.ods-events-vcn[0].id

  #Optional
  display_name = "Data Science Nat Gateway"
}


#*************************************
#           Route Tables
#*************************************

resource "oci_core_route_table" "ods-public-rt" {
  count = var.ods_vcn_use_existing ? 0 : 1
  #Required
  compartment_id =   var.compartment_ocid
  vcn_id         = oci_core_vcn.ods-events-vcn[0].id
  display_name = "Data Science Public RT"

  // Internet Gateway
  route_rules {
    #Required
    network_entity_id = oci_core_internet_gateway.ods-gateway[0].id

    #Optional
    destination      = "0.0.0.0/0"
    destination_type = "CIDR_BLOCK"
  }

}

resource "oci_core_route_table" "ods-private-rt" {
  count = var.ods_vcn_use_existing ? 0 : 1
  #Required
  compartment_id =   var.compartment_ocid
  vcn_id         = oci_core_vcn.ods-events-vcn[0].id
  display_name = "Data Science Private RT"

  // NAT Gateway
  route_rules {
    #Required
    network_entity_id = oci_core_nat_gateway.ods-nat-gateway[0].id

    #Optional
    destination      = "0.0.0.0/0"
    destination_type = "CIDR_BLOCK"
  }

}

#*************************************
#         Security List
#*************************************

resource "oci_core_security_list" "ods-public-sl" {
  count = var.ods_vcn_use_existing ? 0 : 1
  #Required
  compartment_id = var.compartment_ocid
  vcn_id = oci_core_vcn.ods-events-vcn[0].id
  display_name = "Data Science Public SL"
  # Egress - Allow All
  egress_security_rules {
    destination = "0.0.0.0/0"
    protocol = "All"
    stateless = false
    destination_type = "CIDR_BLOCK"

  }
  # Ingress - Allow All
  ingress_security_rules {
    #Required
    protocol = "All"
    source = "0.0.0.0/0"
    source_type = "CIDR_BLOCK"
    stateless = false
  }
}

resource "oci_core_security_list" "ods-private-sl" {
  count = var.ods_vcn_use_existing ? 0 : 1
  #Required
  compartment_id = var.compartment_ocid
  vcn_id = oci_core_vcn.ods-events-vcn[0].id
  display_name = "Data Science Private SL"
  # Egress - Allow All
  egress_security_rules {
    destination = "0.0.0.0/0"
    protocol = "All"
    stateless = false
    destination_type = "CIDR_BLOCK"
  }
  # Ingress - Allow All
  ingress_security_rules {
    #Required
    protocol = "All"
    source = "0.0.0.0/0"
    source_type = "CIDR_BLOCK"
    stateless = false
  }
}
