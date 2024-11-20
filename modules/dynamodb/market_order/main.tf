resource "aws_dynamodb_table" "market_order_table" {
  name         = "market_order_${var.environment}"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"
  range_key    = "number"

  attribute {
    name = "id"
    type = "S"
  }
  attribute {
    name = "number"
    type = "S"
  }
  attribute {
    name = "status"
    type = "S"
  }
  attribute {
    name = "customer_id"
    type = "S"
  }

  global_secondary_index {
    name            = "status_index"
    hash_key        = "status" # Partition key for the GSI
    projection_type = "ALL"    # Options: ALL, KEYS_ONLY, INCLUDE
    read_capacity   = 1        # Required if using PROVISIONED billing mode
    write_capacity  = 1        # Required if using PROVISIONED billing mode
  }

  global_secondary_index {
    name            = "customer_index"
    hash_key        = "customer_id" # Partition key for the GSI
    projection_type = "ALL"         # Options: ALL, KEYS_ONLY, INCLUDE
    read_capacity   = 1             # Required if using PROVISIONED billing mode
    write_capacity  = 1             # Required if using PROVISIONED billing mode
  }

  tags = {
    Name        = "market_order_${var.environment}"
    Environment = var.environment
  }
}
