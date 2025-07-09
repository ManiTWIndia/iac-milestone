resource "aws_dynamodb_table" "users_table" {
  name             = "${var.table_name_prefix}-users"
  billing_mode     = "PAY_PER_REQUEST"
  hash_key         = "userId"

  attribute {
    name = "userId"
    type = "S"
  }

  tags = {
    Name        = "${var.table_name_prefix}-users-table"
    Environment = var.environment
  }
}