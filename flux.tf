# flux installation
resource "azurerm_kubernetes_cluster_extension" "flux" {
  count          = local.flux.enabled == true ? 1 : 0
  name           = "flux-ext"
  cluster_id     = azurerm_kubernetes_cluster.main.id
  extension_type = "microsoft.flux"
  release_train  = try(local.flux.release_train, null)
  version        = try(local.flux.version, null)
}
