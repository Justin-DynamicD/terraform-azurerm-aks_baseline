######
# global variables
######

variable location {
  type        = string
  description = "region to build all resources in"
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

variable aks {
  type = object({
    automatic_channel_upgrade = optional(string)
    azure_policy              = optional(bool)
    docker_bridge_cidr        = optional(string)
    max_count                 = optional(number)
    min_count                 = optional(number)
    name                      = optional(string)
    node_count                = optional(number)
    os_disk_size_gb           = optional(number)
    os_disk_type              = optional(string)
    sku_tier                  = optional(string)
    subnet_id                 = string
    vm_size                   = optional(string)
  })
  description = "map of all aks variables"
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

variable zones {
  type        = list(string)
  description = "list of all supported AZs to deploy to, if available"
  nullable    = false
  default     = []
}

variable tags {
  type        = map(any)
  description = "map of tags to apply to all resources"
  default     = null
}