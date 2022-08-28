variable "domain_name" {
    type = string
    default = "jaj.fr"
    description = "Default domain."
}

variable "common_tags" {
    type = map(string)
    default = {Terraform: "JAJ FrontEnd"}
    description = "Default tags."
}

variable "zone_id" {
    type = string
    default = ""
    description = "Hosted zone ID"  
}

variable "acm_provider_frontend_region" {
    description = "Region ACM provider."
    type = string
    default = "us-east-1"
}