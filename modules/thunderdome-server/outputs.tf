# =================== #
#   Standard Oututs   #
# =================== #

# Standard Outputs tend to remain the same across every ECS Fargate deployment and never really change.

output "alb_security_group_id" {
  description = "The Security Group ID, allowing access from the ALB to the application deployed to ECS Fargate."
  value       = aws_security_group.alb_security_group.id
}


# ================== #
#   Custom Outputs   #
# ================== #

# Custom Outputs often change from deployment to deployment, and warrant editing.

# output "thunderdome_server_target_group_arn" {
#   description = "The ARN of the Target Group assigned to Thunderdome Server containers deployed to ECS Fargate."
#   value       = aws_lb_target_group.thunderdome_server_target_group.arn
# }