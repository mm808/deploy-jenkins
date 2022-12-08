resource "aws_cloudwatch_metric_alarm" "server_cpu_alarm" {
  alarm_name                = "jenkins_${var.env}_server_cpu_alarm"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "1"
  metric_name               = "CPUUtilization"
  namespace                 = "AWS/EC2"
  period                    = "360"
  statistic                 = "Average"
  threshold                 = "80"
  alarm_description         = "Alert when cpu use is 80%"
  insufficient_data_actions = []
  actions_enabled     = "true"
  alarm_actions       = ["${var.infra_alarm_sns_arn}"]
  ok_actions       = ["${var.infra_alarm_sns_arn}"]
  dimensions = {
        InstanceId = aws_instance.jenkins-master.id
      }
}

# mem-use-percent alarm, relies on CloudWatch agent installation
resource "aws_cloudwatch_metric_alarm" "mem_use_alarm" {
  alarm_name                = "jenkins_${var.env}_mem_use_alarm"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "2"
  metric_name               = "mem_used_percent"
  namespace                 = "CWAgent"
  period                    = "60"
  statistic                 = "Average"
  threshold                 = "80"
  alarm_description         = "Alert when memory use is 80%"
  insufficient_data_actions = []
  actions_enabled     = "true"
  alarm_actions       = ["${var.infra_alarm_sns_arn}"]
  ok_actions       = ["${var.infra_alarm_sns_arn}"]
  dimensions = {
        InstanceId = aws_instance.jenkins-master.id
      }
}

# disk-use-percent alarm, relies on CloudWatch agent installation
resource "aws_cloudwatch_metric_alarm" "disk_use_alarm" {
  alarm_name                = "jenkins_${var.env}_disk_use_alarm"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "2"
  metric_name               = "disk_used_percent"
  namespace                 = "CWAgent"
  period                    = "60"
  statistic                 = "Average"
  threshold                 = "80"
  alarm_description         = "Alert when disk use is 80%"
  insufficient_data_actions = []
  actions_enabled     = "true"
  alarm_actions       = ["${var.infra_alarm_sns_arn}"]
  ok_actions       = ["${var.infra_alarm_sns_arn}"]
  dimensions = {
         path = "/"
         InstanceId = aws_instance.jenkins-master.id
         device = "${var.disk_monitoring_device}"
         fstype = "xfs"
      }
}