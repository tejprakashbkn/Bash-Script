#!/bin/bash

Instance_ID=`ec2metadata --instance-id`
Instance_Name=$(/usr/local/bin/aws ec2 describe-instances --instance-ids $Instance_ID --query 'Reservations[*].Instances[*].Tags[?Key==`Name`].Value[]' --output text)
Used=`free -m | grep Mem | awk  '{print $3}'`
Total=`free -m | grep Mem | awk  '{print $2}'`
Percent_Usage=`echo "scale=2; $Used/$Total*100" | bc|awk -F. '{print $1}'`
/usr/local/bin/aws cloudwatch put-metric-data --metric-name MemoryUtilization --unit Percent --value $Percent_Usage --dimensions InstanceId=$Instance_ID --namespace EC2
