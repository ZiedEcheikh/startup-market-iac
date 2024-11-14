output "arn_ghcrio_credentials" {
  value       = aws_secretsmanager_secret.ghcrio.arn
  description = "Secret ghcrio credentials"
}
