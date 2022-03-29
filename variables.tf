######
# global variables
######

variable app_gateway {
  type        = object ({
      enabled      = optional(bool)
      name         = optional(string)
      public_ip_id = optional(string)
      sku_capacity = optional(string)
      sku_name     = optional(string)
      sku_tier     = optional(string)
      subnet_id    = optional(string)
  })
  description = "map of all agw variables"
  default     = {}
}

variable node_default_pool {
  type = object({
    enable_auto_scaling          = optional(bool)
    max_count                    = optional(number)
    min_count                    = optional(number)
    name                         = optional(string)
    node_count                   = optional(number)
    only_critical_addons_enabled = optional(bool)
    os_disk_size_gb              = optional(number)
    os_disk_type                 = optional(string)
    vm_size                      = optional(string)
  })
  description = "node default system pool for aks"
  default     = {}
}

variable node_user_pool {
  type = object({
    enabled             = optional(bool)
    enable_auto_scaling = optional(bool)
    max_count           = optional(number)
    min_count           = optional(number)
    mode                = optional(string)
    name                = optional(string)
    node_count          = optional(number)
    os_disk_size_gb     = optional(number)
    os_disk_type        = optional(string)
    priority            = optional(string)
    eviction_policy     = optional(string)
    spot_max_price      = optional(number)
    vm_size             = optional(string)
  })
  description = "node user pool for aks"
  default     = {}
}

variable oms {
  type = object({
    enabled              = optional(bool)
    retention_days       = optional(number)
    storage_account_id   = optional(string)
    workspace_id         = optional(string)
  })
  description = "custom object defining OMS variables"
  default = {}
}

variable acr_list {
  type        = map(any)
  description = "key/value map of acr name = resource group"
  nullable    = false
  default     = {}
}

variable automatic_channel_upgrade {
  type        = string
  description = "the upgrade channel for aks"
  nullable    = false
  default     = ""
}

variable azure_policy {
  type        = bool
  description = "enable azure policies on this cluster"
  nullable    = false
  default     = true
}

variable docker_bridge_cidr {
  type        = string
  description = "IP address (in CIDR notation) used as the Docker bridge IP address on nodes."
  nullable    = false
  default     = "172.17.0.1/16"
}

variable location {
  type        = string
  description = "region to build all resources in"
}

variable name {
  type        = string
  description = "If defined, sets the name of the AKS cluster"
  default     = ""
}

variable name_prefix {
  type        = string
  description = "the prefix used in any generated resource name, if no overriding name is specified"
  nullable    = false
  default     = "aks-baseline"
}

variable resource_group_name {
  type        = string
  description = "name of the resource group to provision in"
}

variable sku_tier {
  type        = string
  description = "Set the SKU for hte aks cluster"
  nullable    = false
  default     = "Free"
}

variable tags {
  type        = map(any)
  description = "map of tags to apply to all resources"
  default     = null
}

variable subnet_id {
  type        = string
  description = "ID of the subnet for all node pools"
}

variable zones {
  type        = list(string)
  description = "list of all supported AZs to deploy to, if available"
  nullable    = false
  default     = []
}
