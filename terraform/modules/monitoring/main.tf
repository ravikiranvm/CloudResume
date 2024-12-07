# Create SNS topic for CW Alarms
resource "aws_sns_topic" "alerts" {
    name = "alerts"
}

resource "aws_sns_topic_subscription" "alerts_subscription" {
    topic_arn = aws_sns_topic.alerts.arn
    protocol = "email"
    endpoint = "mrtravelok@gmail.com"
}

# Alarm for monthly budget projection
resource "aws_cloudwatch_metric_alarm" "monthly_cost_projection" {
    alarm_name = "MonthlyCostProjection"
    comparison_operator = "GreaterThanThreshold"
    evaluation_periods = 1 # checks once during the below mentioned period
    metric_name = "EstimatedCharges"
    namespace = "AWS/Billing"
    period = 43200 # checks once every 12 hours
    statistic = "Maximum"
    threshold = 2
    alarm_description = "Triggered when monthly AWS costs projection exceeds USD 2"
    alarm_actions = [ aws_sns_topic.alerts.arn ]
}

