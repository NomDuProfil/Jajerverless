###########################################################
#                        USAGE                            #
###########################################################
/*
module "jaj_frontend" {
    source  = "./modules/frontend"
    domain_name = "jaj.fr"
    zone_id = module.hosted_zone_principal.zone_id_output
    common_tags = {Terraform: "JAJ FrontEnd"}
}
*/
###########################################################