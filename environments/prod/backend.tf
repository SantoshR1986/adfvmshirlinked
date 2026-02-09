terraform {
  backend "azurerm" {
    resource_group_name  = "rg-terraform-state"
    storage_account_name = "stterraformstateprd"
    container_name       = "tfstate"
    key                  = "adf/prod/terraform.tfstate"
  }
}
