################# Dynamodb Table to lock state file ################
resource "aws_dynamodb_table" "stateLock" {
  name           = var.dynamodb_table_name
  billing_mode   = var.dynamodb_table_billing_mode
  read_capacity  = var.dynamodb_table_read_capacity
  write_capacity = var.dynamodb_table_write_capacity
  hash_key       = var.dynamodb_table_hash_key
 

  attribute {
    name        = var.dynamodb_table_hash_key
    type        = var.dynamodb_table_attribute_type
  }
}
