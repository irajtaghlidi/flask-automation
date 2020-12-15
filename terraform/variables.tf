
variable "region" {
  type        = string
  description = "Region of the new VPC in AWS Cloud"
}

variable "availability_zones" {
  type        = list
  description = "Availablility zones in VPC"
}

variable "vpc_prefix" {
  type        = string
  description = "Prefix VPC IP range: like 10.0.0.0/16"
}

variable "subnet_prefix" {
  type        = list
  description = "Prefix subnet IP range list: like [10.0.1.0/24]"
}


variable "repo_url" {
  type  = string
  description = "docker image URL"
}

variable "repo_tag" {
  type  = string
  description = "docker image tag"
}


variable "zone_name" {
    type        = string
    description = "Zone name for creating subdomain DNS records"
}

variable "domain_name" {
    type        = string
    description = "Subdomain for ALB and certeficate"
}