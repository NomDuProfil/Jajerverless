###########################################################
#                        USAGE                            #
###########################################################
/*
module "example_api" {
    source  = "./modules/api"
    name_api = "ExampleAPI"
    path_base = "./api/example/"
    domain_name_api = "api.jaj.fr"
    zone_id = module.hosted_zone_principal.zone_id_output
    endpoints_name = {
        "exampleEndpoint1" = {
            permissions_databases = [{
                databases = ["Database1"],
                permissions = [
                    "BatchGetItem",
                    "GetItem",
                    "Query",
                    "Scan",
                    "BatchWriteItem",
                    "PutItem",
                    "UpdateItem"
                ] 
            }]
        },
        "exampleEndpoint2" = {
            permissions_databases = [{
                databases = ["Database1", "Database2"],
                permissions = [
                    "GetItem",
                    "Query",
                    "Scan"
                ] 
            }]
        }
    }
}
*/
###########################################################