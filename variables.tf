######
# global variables
######

variable app_gateway {
  type        = object ({
      enabled      = optional(bool, false)
      name         = optional(string)
      public_ip_id = optional(string, "")
      priority     = optional(number)
      sku_capacity = optional(string, "2")
      sku_name     = optional(string, "WAF_v2")
      sku_tier     = optional(string, "WAF_v2")
      subnet_id    = optional(string, "")
  })
  description = "map of all agw variables"
  default     = {}
}

variable waf_configuration {
  type        = object ({
      enabled                  = optional(bool, true)
      firewall_mode            = optional(string, "Detection")
      rule_set_type            = optional(string, "OWASP")
      rule_set_version         = optional(string, "3.2")
      file_upload_limit_mb     = optional(number, 100)
      request_body_check       = optional(bool, true)
      max_request_body_size_kb = optional(number, 128)
  })
  description = "map of all waf configuration setting required if WAF is enabled"
  default     = {}
}

variable node_default_pool {
  type = object({
    enable_auto_scaling          = optional(bool, true)
    max_count                    = optional(number, 4)
    min_count                    = optional(number, 3)
    name                         = optional(string, "system")
    node_count                   = optional(number, 3)
    only_critical_addons_enabled = optional(bool, true)
    os_disk_size_gb              = optional(number, 70)
    os_disk_type                 = optional(string, "Ephemeral")
    vm_size                      = optional(string, "Standard_D2ds_v5")
  })
  description = "node default system pool for aks"
  default     = {}
}

variable node_user_pool {
  type = object({
    enable_auto_scaling = optional(bool, true)
    enabled             = optional(bool, true)
    eviction_policy     = optional(string, "Delete")
    max_count           = optional(number, 5)
    min_count           = optional(number, 2)
    mode                = optional(string, "User")
    name                = optional(string, "user")
    node_count          = optional(number, 2)
    os_disk_size_gb     = optional(number, 120)
    os_disk_type        = optional(string, "Ephemeral")
    priority            = optional(string, "Regular")
    spot_max_price      = optional(number, -1)
    vm_size             = optional(string, "Standard_D4ds_v5")
  })
  description = "node user pool for aks"
  default     = {}
}

variable oms {
  type = object({
    enabled              = optional(bool, false)
    agw_logs             = optional(object({
      ApplicationGatewayAccessLog      = optional(bool, true)
      ApplicationGatewayPerformanceLog = optional(bool, true)
      ApplicationGatewayFirewallLog    = optional(bool, true)
    }))
    agw_metrics          = optional(bool, true)
    aks_logs             = optional(object({
      cloud-controller-manager         = optional(bool, false)
      cluster-autoscaler               = optional(bool, true)
      csi-azuredisk-controller         = optional(bool, false)
      csi-azurefile-controller         = optional(bool, false)
      csi-snapshot-controller          = optional(bool, false)
      guard                            = optional(bool, false)
      kube-apiserver                   = optional(bool, true)
      kube-audit                       = optional(bool, true)
      kube-audit-admin                 = optional(bool, true)
      kube-controller-manager          = optional(bool, true)
      kube-scheduler                   = optional(bool, false)
    }))
    aks_metrics          = optional(bool, true)
    retention_days       = optional(number, 30)
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
