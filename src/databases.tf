###########################################################
#                        USAGE                            #
###########################################################
/*
module "example_database_one" {
  source  = "./modules/database"
    database_name = "Database1"
    primary_key = "PK_Name"
    range_key = "RK_Name"
    attributes = [
        {
            name: "PK_Name",
            type: "S"
        },
        {
            name: "RK_Name",
            type: "S"
        }
    ]
}

module "example_database_two" {
    source  = "./modules/database"
    database_name = "Database2"
    primary_key = "PK_Name"
    attributes = [
        {
            name: "Id_user",
            type: "N"
        }
    ]
}
*/
###########################################################
