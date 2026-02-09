output "vm_names" {
  description = "List of SHIR VM names."
  value       = [for vm in module.shir_vm : vm.vm_name] # adjust attribute name
}

output "vm_ids" {
  description = "List of SHIR VM resource IDs."
  value       = [for vm in module.shir_vm : vm.vm_id] # adjust attribute name
}

output "private_ip_addresses" {
  description = "List of private IP addresses of the SHIR VM nodes."
  value       = [for nic in azurerm_network_interface.shir : nic.private_ip_address]
}

output "node_count" {
  description = "Number of SHIR nodes deployed."
  value       = var.node_count
}

output "nodes" {
  description = "Map of node index to name and IP for relationship mapping."
  value = {
    for i in range(var.node_count) : format("node-%02d", i + 1) => {
      vm_name    = module.shir_vm[i].vm_name # adjust attribute name
      private_ip = azurerm_network_interface.shir[i].private_ip_address
    }
  }
}
