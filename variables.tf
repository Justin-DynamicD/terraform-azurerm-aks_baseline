######
# global variables
######

variable global_settings {
  type        = map(any)
  description = "map of global variables"
  default     = null
}

variable network {
  type        = object({
    agw_subnet_id      = string
    aks_subnet_id      = string
    zones              = list(string)
  })
  description = "custom object defining the network"
  default     = null
}

variable app_gateway {
  type        = map(any)
  description = "map of all agw variables"
  default     = null
}

variable aks {
  type        = map(any)
  description = "map of all aks variables"
  default     = null
}

variable oms {
  type = object({
    storage_account_id   = string
    storage_account_name = string
    workspace_id         = string
    workspace_name       = string
  })
  description = "custom object defining OMS variables"
  default     = null
}
variable acr_list {
  type        = map(any)
  description = "key/value map of acr name = resource group"
  default     = null
}

variable zones {
  type        = map(any)
  description = "map of all agw variables"
  default     = null
}

variable tags {
  type        = map(any)
  description = "map of tags to apply to all resources"
  default     = null
}