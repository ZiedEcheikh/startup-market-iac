output "market_order_table_name" {
  value       = aws_dynamodb_table.market_order_table.name
  description = "Market order table name"
}

output "market_order_table_arn" {
  value       = aws_dynamodb_table.market_order_table.arn
  description = "Market order table arn"
}
