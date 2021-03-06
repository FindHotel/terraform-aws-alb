output "alb_arn" {
  description = "ARN of the ALB itself. Useful for debug output, for example when attaching a WAF."
  value       = "${element(concat(aws_alb.main.*.arn, list("")), 0)}"
}

output "alb_arn_suffix" {
  description = "ARN suffix of our ALB - can be used with CloudWatch"
  value       = "${element(concat(aws_alb.main.*.arn_suffix, list("")), 0)}"
}

output "alb_dns_name" {
  description = "The DNS name of the ALB presumably to be used with a friendlier CNAME."
  value       = "${element(concat(aws_alb.main.*.dns_name, list("")), 0)}"
}

output "alb_id" {
  description = "The ID of the ALB we created."
  value       = "${element(concat(aws_alb.main.*.id, list("")), 0)}"
}

output "alb_listener_https_arn" {
  description = "The ARN of the HTTPS ALB Listener we created."
  value       = "${element(concat(aws_alb_listener.frontend_https.*.arn, list("")), 0)}"
}

output "alb_listener_http_arn" {
  description = "The ARN of the HTTP ALB Listener we created."
  value       = "${element(concat(aws_alb_listener.frontend_http.*.arn, list("")), 0)}"
}

output "alb_listener_https_id" {
  description = "The ID of the ALB Listener we created."
  value       = "${element(concat(aws_alb_listener.frontend_https.*.id, list("")), 0)}"
}

output "alb_listener_http_id" {
  description = "The ID of the ALB Listener we created."
  value       = "${element(concat(aws_alb_listener.frontend_http.*.id, list("")), 0)}"
}

output "alb_zone_id" {
  description = "The zone_id of the ALB to assist with creating DNS records."
  value       = "${element(concat(aws_alb.main.*.zone_id, list("")), 0)}"
}

output "principal_account_id" {
  description = "The AWS-owned account given permissions to write your ALB logs to S3."
  value       = "${element(concat(data.aws_elb_service_account.main.*.id, list("")), 0)}"
}

output "target_group_arn" {
  description = "ARN of the target group. Useful for passing to your Auto Scaling group module."
  value       = "${element(concat(aws_alb_target_group.application_target_group.*.arn, aws_alb_target_group.network_target_group.*.arn, list("")), 0)}"
}

output "target_group_name" {
  description = "Name of the target group. Useful for passing to your CodeDeploy Deployment Group."
  value       = "${element(concat(aws_alb_target_group.application_target_group.*.arn, aws_alb_target_group.network_target_group.*.arn, list("")), 0)}"
}
