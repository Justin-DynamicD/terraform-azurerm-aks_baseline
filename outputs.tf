output "cluster" {
  value = {
    fqdn               = try(azurerm_kubernetes_cluster.main.fqdn, null)
    id                 = azurerm_kubernetes_cluster.main.id
    kubernetes_version = azurerm_kubernetes_cluster.main.kubernetes_version
    name               = azurerm_kubernetes_cluster.main.name
    portal_fqdn        = try(azurerm_kubernetes_cluster.main.portal_fqdn, null)
    private_fqdn       = try(azurerm_kubernetes_cluster.main.private_fqdn, null)
  }
  description = "All attributes related to the cluster resource (id, fqdn, etc)."
}

output "app_gateway" {
  value = {
    id   = try(azurerm_application_gateway.main[0].id, null)
    name = try(azurerm_application_gateway.main[0].name, null)
  }
  description = "All attributes related to the application gateway (id, name)."
}

output "flux" {
  value = {
    id            = try(azurerm_kubernetes_cluster_extension.flux[0].id, null)
    release_train = try(azurerm_kubernetes_cluster_extension.flux[0].release_train, null)
    version       = try(azurerm_kubernetes_cluster_extension.flux[0].current_version, null)
  }
  description = "Flux installation information."
}
