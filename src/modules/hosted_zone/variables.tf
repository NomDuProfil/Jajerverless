variable "domain_name" {
    type = string
    default = "jaj.fr"
    description = "Default domain."
}

variable "common_tags" {
    type = map(string)
    default = {Terraform: "JAJ FrontEnd"}
    description = "Tags."
}