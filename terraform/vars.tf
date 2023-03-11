# --------------------------------------
# Variables para el despliegue en Azure
# --------------------------------------

# Variables globales

variable "location" {
  type = string
  description = "Región de Azure donde crearemos la infraestructura"
  default = "West Europe"
}

variable "resource_group_name" {
  type        = string
  description = "Nombre del grupo de recursos en Azure"
}

# Variables del cluster de AKS


variable "cluster_name" {
  type        = string
  description = "Nombre del cluster K8S"
}

variable "kubernetes_version" {
  type        = string
  description = "Versión de K8S"
}

variable "system_node_count" {
  type        = number
  description = "Numero de Workers nodes"
}

# Variables del Registro de contenedores


variable "acr_name" {
  type        = string
  description = "Nombre del registro de contenedores"
}

# Variables de la red


variable "avn_name" {
  type        = string
  description = "Nombre de la red virtual"
}

variable "avns_name" {
  type        = string
  description = "Nombre de la subred virtual"
}


# Variables de la máquina virtual


variable "vm_name" {
  type        = string
  description = "Nombre de la VM"
}

variable "ani_name" {
  type        = string
  description = "Nombre de la interfaz de red de la VM"
}

variable "so_name" {
  type        = string
  description = "Nombre del Sistema Operativo de la VM"
}

variable "so_version" {
  type        = string
  description = "Versión del SO de la VM"
}

variable "public_key_path" {
  type = string
  description = "Ruta para la clave pública de acceso a las instancias"
}

variable "ssh_user" {
  type = string
  description = "Usuario para hacer ssh"
}
