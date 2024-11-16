resource "aws_secretsmanager_secret" "ghcrio" {
  name                    = "startup/ghcrio"
  description             = "Credentials to access github package"
  recovery_window_in_days = 0
  tags = {
    Name = "github_package"
  }
}
resource "aws_secretsmanager_secret_version" "ghcrio_credentials" {
  secret_id     = aws_secretsmanager_secret.ghcrio.id
  secret_string = jsonencode(var.github_credentials)
}
