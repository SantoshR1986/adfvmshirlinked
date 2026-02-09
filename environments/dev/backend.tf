terraform {
  backend "azurerm" {
    resource_group_name  = "rg-terraform-state"
    storage_account_name = "stterraformstatedev"
    container_name       = "tfstate"
    key                  = "adf/dev/terraform.tfstate"
  }
}
