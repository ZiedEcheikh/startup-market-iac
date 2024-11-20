resource "aws_dynamodb_table" "metadata_table" {
  name         = "metadata_${var.environment}"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"

  attribute {
    name = "id"
    type = "S"
  }

  tags = {
    Name        = "metadata_${var.environment}"
    Environment = var.environment
  }
}
