variable "database_name" {
    description = "Nom de la base de donnees."
    type = string
    default = ""
}

variable "primary_key" {
    description = "Nom de la clé primaire."
    type = string
    default = ""
}

variable "range_key" {
    description = "Nom de la sort key."
    type = string
    default = null
}

variable "attributes" {
    description = "Nom et type des colonnes. Type disponible : S (string), N (number), B (binary)"
    type = list(object({
        name = string
        type = string
    }))
    default = [ {
      name = ""
      type = ""
    } ]
}

variable "common_tags" {
    type = map(string)
    default = {Terraform: "JAJ FrontEnd"}
    description = "Tags."
}