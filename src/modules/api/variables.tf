variable "endpoints_name" {
    description = "Nom des lambdas."
    type = map(
        object({
            permissions_databases = list(
                object({
                    databases = list(string)
                    permissions = list(string)
                })
            )
        })
    )
}

variable "name_api" {
    description = "Nom de l'API gateway."
    type = string
    default = "JAJ"
}

variable "path_base" {
    description = "Chemin vers le dossier de l'api où se trouve le swagger et les fonctions."
    type = string
    default = "../api/"
}

variable "domain_name_api" {
    description = "Domaine de l'API."
    type = string
    default = "api.jaj.fr"
}

variable "zone_id" {
    description = "Hosted zone ID."
    type = string
    default = ""
}

variable "common_tags" {
    type = map(string)
    default = {Terraform: "JAJ FrontEnd"}
    description = "Tags."
}

variable "lambda_region" {
    description = "Lambda region."
    type = string
    default = "eu-west-3"
}

variable "acm_provider_api_region" {
    description = "ACM provider region."
    type = string
    default = "eu-west-3"
}