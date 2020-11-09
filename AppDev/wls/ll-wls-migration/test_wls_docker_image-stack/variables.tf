
/**
*/


variable "tenancy_ocid" {
  type        = string
  description = "tenancy id"
}



variable "region" {
  type        = string
  description = "tenancy id"
  default     = ""
}


variable "compartment_ocid" {
  type        = string
  description = "compartment for weblogic instances"
}

// Note: This is the opc user's SSH public key text and not the key file path.
variable "ssh_public_key" {
  type        = string
  description = "public key for ssh access to weblogic instances"
  default     = "ssh-rsa AAAAB3NzaC1yc2EAAAABJQAAAQEAt9LIaTOzZ53jUYWmWLYPYakXx39BkJPYzgrXCL+1haFXM4drNapwWiJaJ4d/4mTfLBOA4QiZ4DyiRGfhOwontPsU/XjPyVAw59S3LDaWZx5tS3KX5UUlEL6yFbwdE7O8ovpYxkaFzCKnkSshlPXITBMMID8nelomiyGsEf2ea0EOT25xhf7iW7Q/tlM74QxdI/N5ea3Pqiu4H3yjotC+/ozl+OYNRVLKr/TtTMvlGMkk7uDdQVUTG1Vzm96Eu8bbjTNVYqHLqx0U131UI/xKkTJa+65iRf9NMLzvuNqzR8mt5OGSjTFyXi5xNepRSiRPSuGPV1IIBYl4iB6cxcFolQ== rsa-key-20200601"
}

/*
variable "vcn_use_existing" {
  default = ""
}


variable "vnc_id" {
default =""
}

variable "vnc_public_subnet_id" {
default =""
}


variable "user_ocid" {
default    = ""
 }
 
 
variable "fingerprint" {
default    = ""
 } 

variable "private_key_path" {
default    = ""
 } 

*/
 




















