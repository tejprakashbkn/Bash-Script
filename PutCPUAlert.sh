#!/bin/bash

SNS=""
Tag="prod"
Alert_Point=70
Period=300
Evaluation_Period=1
Instance_Ids=$(aws ec2 describe-instances --filters "Name=instance-state-name,Values=running" "Name=tag:Environment,Values=prod" --query 'Reservations[].Instances[].[InstanceId]' --output text)

for instance_id in $Instance_Ids;
do
	echo "Instance id="$instance_id;
	instance_name=$(aws ec2 describe-instances --instance-ids $instance_id --query 'Reservations[*].Instances[*].Tags[?Key==`Name`].Value[]' --output text)
	echo "Instance Name="$instance_name;
	aws cloudwatch put-metric-alarm --alarm-name $instance_name"-high-cpu" --alarm-description "Alarm when CPU exceeds 70%" --metric-name CPUUtilization --namespace AWS/EC2 --statistic Average --period $Period --threshold $Alert_Point --comparison-operator GreaterThanThreshold  --dimensions Name=InstanceId,Value=$instance_id --evaluation-periods $Evaluation_Period --alarm-actions $SNS --unit Percent
done
