output "rds_secret_arn" {
  value       = aws_rds_cluster.rds_cluster.master_user_secret[0].secret_arn
  description = "The ARN of the RDS Secret which stores the Username and Password for the administrator of the database cluster."
}

output "rds_database_endpoint" {
  value       = aws_rds_cluster.rds_cluster.endpoint
  description = "The DNS name at which the RDS database is accessible from inside of the deployed VPC."
}

output "rds_initial_database_name" {
  value       = var.initial_database_name
  description = "The name assigned to the first automatically created 'database' object, as defined in either PostGres or MySQL."
}

output "rds_access_security_group_id" {
  value       = aws_security_group.rds_access_security_group.id
  description = "The Security Group ID, required for access to the RDS Cluster."
}