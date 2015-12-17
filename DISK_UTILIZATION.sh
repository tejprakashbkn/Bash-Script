#!/bin/bash

Instance_ID=`ec2metadata --instance-id`
Instance_Name=$(/usr/local/bin/aws ec2 describe-instances --instance-ids $Instance_ID --query 'Reservations[*].Instances[*].Tags[?Key==`Name`].Value[]' --output text)
Count=`df -h | grep \/dev\/ | wc -l`
for ((i=1;i<=$Count;i++));
do
	disk_usage=`df -h | grep \/dev\/ | awk -F' ' '{print $5}' | head -"$i" | tail -1 | awk -F% '{print $1}'`
	disk_name=`df -h | grep \/dev\/ | awk -F' ' '{print $1}' | head -"$i" | tail -1`
	/usr/local/bin/aws cloudwatch put-metric-data --metric-name "DiskUtilization-"$disk_name --unit Percent --value $disk_usage --dimensions InstanceId=$Instance_ID --namespace EC2
done
