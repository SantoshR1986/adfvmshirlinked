# =============================================================================
# Self-Hosted Integration Runtime VM Nodes
# Uses company-standard Windows VM module (replace source with your registry).
# All nodes register with the same SHIR auth key – ADF load-balances across them.
# =============================================================================

# -----------------------------------------------------------------------------
# NIC per node (placed in the SHIR subnet, no public IP)
# -----------------------------------------------------------------------------
resource "azurerm_network_interface" "shir" {
  count = var.node_count

  name                = "nic-shir-${var.name_prefix}-${format("%02d", count.index + 1)}"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
  }

  tags = var.tags
}

# -----------------------------------------------------------------------------
# Company-standard Windows VM module – one instance per node
# TODO: Replace the source below with your company's private module registry.
#       e.g. "app.terraform.io/my-company/windows-vm/azurerm"
#       or   "my-company.jfrog.io/terraform/windows-vm/azurerm"
# The module is expected to accept the parameters shown below.  Adjust the
# attribute names if your company module uses different variable names.
# -----------------------------------------------------------------------------
module "shir_vm" {
  source = "app.terraform.io/<YOUR_COMPANY>/windows-vm/azurerm" # <-- REPLACE
  # version = "~> x.x"                                           # <-- PIN VERSION
  count = var.node_count

  name                = "vm-shir-${var.name_prefix}-${format("%02d", count.index + 1)}"
  resource_group_name = var.resource_group_name
  location            = var.location

  vm_size        = var.vm_size
  admin_username = var.admin_username
  admin_password = var.admin_password

  network_interface_ids = [azurerm_network_interface.shir[count.index].id]

  os_disk = {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
    disk_size_gb         = 128
  }

  source_image_reference = {
    publisher = var.vm_image.publisher
    offer     = var.vm_image.offer
    sku       = var.vm_image.sku
    version   = var.vm_image.version
  }

  tags = var.tags
}

# -----------------------------------------------------------------------------
# Custom Script Extension – installs & registers the SHIR agent on each node
# All nodes register with the same auth key; ADF auto-discovers them as
# additional nodes of the same SHIR and load-balances across them.
# -----------------------------------------------------------------------------
resource "azurerm_virtual_machine_extension" "install_shir" {
  count = var.node_count

  name                       = "install-shir"
  virtual_machine_id         = module.shir_vm[count.index].vm_id # adjust attribute name
  publisher                  = "Microsoft.Compute"
  type                       = "CustomScriptExtension"
  type_handler_version       = "1.10"
  auto_upgrade_minor_version = true

  protected_settings = jsonencode({
    commandToExecute = <<-CMD
      powershell -ExecutionPolicy Bypass -Command "
        $ErrorActionPreference = 'Stop'

        # Download latest SHIR installer
        $shirUrl = 'https://download.microsoft.com/download/E/4/7/E4771905-1079-445B-8BF9-8A1A075D8A10/IntegrationRuntime_5.44.8984.1.msi'
        $installerPath = 'C:\\Temp\\IntegrationRuntime.msi'
        New-Item -ItemType Directory -Path 'C:\\Temp' -Force | Out-Null
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        Invoke-WebRequest -Uri $shirUrl -OutFile $installerPath

        # Install silently
        Start-Process msiexec.exe -ArgumentList '/i', $installerPath, '/quiet', '/norestart' -Wait -NoNewWindow

        # Register with ADF auth key
        $irPath = (Get-ItemProperty 'HKLM:\\SOFTWARE\\Microsoft\\DataTransfer\\DataManagementGateway\\ConfigurationManager').Path
        $dmgCmd = Join-Path (Split-Path $irPath) 'dmgcmd.exe'
        & $dmgCmd -Key '${var.shir_auth_key}'
      "
    CMD
  })

  tags = var.tags
}
