output "paisa_bachau_webhook_url" {
  sensitive   = true
  description = "Webhook URL"
  value       = azurerm_automation_webhook.paisa_bachaera_lyau.uri
}

output "chux_password" {
  sensitive   = true
  description = "Webhook URL"
  value       = random_password.chux_password
}

output "use_garera_lyau_webhook_url" {
  sensitive   = true
  description = "Webhook URL"
  value       = azurerm_automation_webhook.use_garaera_lyau.uri
}
