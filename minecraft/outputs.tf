output "paisa_bachau_webhook_url" {
  sensitive   = true
  description = "Webhook URL"
  value       = azurerm_automation_webhook.paisa_bachau.uri
}

output "chux_password" {
  sensitive   = true
  description = "Webhook URL"
  value       = random_password.chux_password
}
