output "vm_name" {
  description = "Name of the SHIR virtual machine."
  value       = module.shir_vm.vm_name # adjust attribute name to match company module
}

output "vm_id" {
  description = "Resource ID of the SHIR virtual machine."
  value       = module.shir_vm.vm_id # adjust attribute name to match company module
}

output "private_ip_address" {
  description = "Private IP address of the SHIR VM."
  value       = azurerm_network_interface.shir.private_ip_address
}
