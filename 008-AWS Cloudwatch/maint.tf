# main.tf

provider "aws" {
  region = "ap-south-1" # Mumbai Region
}

# --- Variables (replace with actual values or use .tfvars) ---
variable "ec2_instance_id_to_monitor" {
  description = "The ID of the EC2 instance to create an alarm for."
  type        = string
  # default     = "i-xxxxxxxxxxxxxxxxx" # Replace with a real instance ID for testing
}

variable "notification_email" {
  description = "Email address for alarm notifications."
  type        = string
  # default     = "your-email@example.com" # Replace with your email
}

# 1. Create an SNS Topic for notifications
resource "aws_sns_topic" "alarm_notifications" {
  name = "PratikTech-CloudWatchAlarmsTopic"

  tags = {
    Name = "CloudWatchAlarmNotifications"
  }
}

# 2. Subscribe an email endpoint to the SNS Topic
resource "aws_sns_topic_subscription" "email_subscription" {
  topic_arn = aws_sns_topic.alarm_notifications.arn
  protocol  = "email"
  endpoint  = var.notification_email # Make sure to confirm this subscription via email
}

# 3. Create a CloudWatch Metric Alarm for EC2 CPU Utilization
resource "aws_cloudwatch_metric_alarm" "ec2_cpu_high" {
  alarm_name          = "PratikTech-EC2-CPU-High-${var.ec2_instance_id_to_monitor}"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2" # Number of consecutive periods the metric has to be over threshold
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "300" # In seconds (5 minutes)
  statistic           = "Average"
  threshold           = "70" # Percentage
  alarm_description   = "This metric monitors EC2 CPU utilization hitting 70% or more."

  dimensions = {
    InstanceId = var.ec2_instance_id_to_monitor
  }

  alarm_actions = [aws_sns_topic.alarm_notifications.arn] # Notify this SNS topic
  ok_actions    = [aws_sns_topic.alarm_notifications.arn] # Optional: Notify when back to OK

  tags = {
    Name    = "EC2-CPU-High-Alarm"
    Service = "EC2"
  }
}

# 4. Create a CloudWatch Log Group for a hypothetical application
resource "aws_cloudwatch_log_group" "my_app_logs" {
  name              = "/pratik-tech/my-sample-app"
  retention_in_days = 7 # Optional: Set log retention period (0 = indefinite)

  tags = {
    Name        = "MyAppLogs"
    Application = "MySampleApp"
  }
}

# Outputs
output "sns_topic_arn_for_alarms" {
  value = aws_sns_topic.alarm_notifications.arn
}

output "cpu_alarm_name" {
  value = aws_cloudwatch_metric_alarm.ec2_cpu_high.alarm_name
}

output "log_group_name" {
  value = aws_cloudwatch_log_group.my_app_logs.name
}