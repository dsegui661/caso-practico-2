# --------------------------------------------
# Definición de creación de recursos en Azure
# -------------------------------------------

# ###############################
# Recurso: Resource Group 
# Descripción: Grupo de recursos para elementos de Azure
# ##############################

resource "azurerm_resource_group" "argr" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_role_assignment" "role_acrpull" {
  scope                            = azurerm_container_registry.acr.id
  role_definition_name             = "AcrPull"
  principal_id                     = azurerm_kubernetes_cluster.aks.kubelet_identity.0.object_id
  skip_service_principal_aad_check = true
}

# ###########################
# Recurso: Container Registry
# Descripción: Registro de contenedores para almacenar
#               imagenes docker.
# ##########################

resource "azurerm_container_registry" "acr" {
  name                = var.acr_name
  resource_group_name = azurerm_resource_group.argr.name
  location            = var.location
  sku                 = "Standard"
  admin_enabled       = true
}




# ###########################
# Recurso: Cluster AKS
# Descripción: Cluster K8S en Azure
# ##########################

resource "azurerm_kubernetes_cluster" "aks" {
  name                = var.cluster_name
  kubernetes_version  = var.kubernetes_version
  location            = var.location
  resource_group_name = azurerm_resource_group.argr.name
  dns_prefix          = var.cluster_name

  default_node_pool {
    name                = "system"
    node_count          = var.system_node_count
    vm_size             = "Standard_DS2_v2"
    type                = "VirtualMachineScaleSets"
    enable_auto_scaling = false
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    load_balancer_sku = "Standard"
    network_plugin    = "kubenet" 
  }
}

# ###########################
# Recurso: Virtual Network
# Descripción: Definición de la red
# ##########################

resource "azurerm_virtual_network" "avn" {
  name                = var.avn_name
  address_space       = ["10.0.0.0/16"]
  location            = var.location
  resource_group_name = azurerm_resource_group.argr.name
}

resource "azurerm_subnet" "avns" {
  name                 = var.avns_name
  resource_group_name  = azurerm_resource_group.argr.name
  virtual_network_name = azurerm_virtual_network.avn.name
  address_prefixes     = ["10.0.2.0/24"]
}

# Peticion IP publica
resource "azurerm_public_ip" "public_ip" {
  name                = "vm_public_ip"
  resource_group_name = azurerm_resource_group.argr.name
  location            = var.location
  allocation_method   = "Dynamic"
}

# Apertura puerto 22
resource "azurerm_network_security_group" "nsg" {
  name                = "ports_nsg"
  location            = var.location
  resource_group_name = azurerm_resource_group.argr.name

  security_rule {
    name                       = "allow_ports_sg"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_ranges     = ["22","443"]
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}



# ###########################
# Recurso: Virtual Machine
# Descripción: Definición de la maquina virtual
# ##########################


# Interfaz de red
resource "azurerm_network_interface" "ani01" {
  name                = var.ani_name
  location            = var.location
  resource_group_name = azurerm_resource_group.argr.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.avns.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.public_ip.id
  }
}

# Asociacion de regla de firewall puerto 22 a interfaz de reds
resource "azurerm_network_interface_security_group_association" "association" {
  network_interface_id      = azurerm_network_interface.ani01.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

resource "azurerm_linux_virtual_machine" "vm01" {
  name                = var.vm_name
  resource_group_name = azurerm_resource_group.argr.name
  location            = var.location
  size                = "Standard_F2"
  admin_username      = var.ssh_user
  network_interface_ids = [
    azurerm_network_interface.ani01.id,
  ]

  admin_ssh_key {
    username   = var.ssh_user
    public_key = file(var.public_key_path)
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "OpenLogic"
    offer     = var.so_name
    sku       = var.so_version
    version   = "latest"
  }
}

