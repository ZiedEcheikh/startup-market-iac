output "metadata_table_name" {
  value       = aws_dynamodb_table.metadata_table.name
  description = "Metadata table name"
}

output "metadata_table_arn" {
  value       = aws_dynamodb_table.metadata_table.arn
  description = "Metadata table arn"
}
