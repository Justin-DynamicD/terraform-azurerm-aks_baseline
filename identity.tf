#User Assigned Identities
#  Creates an Azure Identity used in VNET joining
#  and DNS updating

resource "azurerm_user_assigned_identity" "main" {
  resource_group_name = local.global_settings.resource_group_name
  location            = local.global_settings.location
  name                = local.names.aks
  tags                = local.tags
}

# grants AKS permissions to the listed registry
resource "azurerm_role_assignment" "attach_acr" {
  for_each             = local.acr_list
  scope                = data.azurerm_container_registry.list[each.key].id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_kubernetes_cluster.main.kubelet_identity[0].object_id
}

# grants rights to the built role as well as the subnet (only needed for kubenet, but added for completeness)
resource "azurerm_role_assignment" "subnet" {
    scope                = local.aks.subnet_id
    role_definition_name = "Network Contributor"
    principal_id         = azurerm_kubernetes_cluster.main.kubelet_identity[0].object_id
}

resource "azurerm_role_assignment" "identity" {
    scope                = azurerm_user_assigned_identity.main.id
    role_definition_name = "Managed Identity Operator"
    principal_id         = azurerm_kubernetes_cluster.main.kubelet_identity[0].object_id
}

# This assigns permissions to the AGW using discovered Idenitity

resource "azurerm_role_assignment" "agwaks" {
  count                = local.app_gateway.enabled ? 1 : 0
  scope                = azurerm_application_gateway.main[0].id
  role_definition_name = "Contributor"
  principal_id         = azurerm_kubernetes_cluster.main.addon_profile[0].ingress_application_gateway[0].ingress_application_gateway_identity[0].object_id
}

resource "azurerm_role_assignment" "agwaksrg" {
  count                = local.app_gateway.enabled ? 1 : 0
  scope                = data.azurerm_resource_group.source.id
  role_definition_name = "Reader"
  principal_id         = azurerm_kubernetes_cluster.main.addon_profile[0].ingress_application_gateway[0].ingress_application_gateway_identity[0].object_id
}