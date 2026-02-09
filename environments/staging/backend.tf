terraform {
  backend "azurerm" {
    resource_group_name  = "rg-terraform-state"
    storage_account_name = "stterraformstatestg"
    container_name       = "tfstate"
    key                  = "adf/staging/terraform.tfstate"
  }
}
