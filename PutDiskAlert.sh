#!/bin/bash

SNS=""
Tag="prod"
Alert_Point=70
Period=120
Evaluation_Period=1
Instance_Ids=$(aws ec2 describe-instances --filters "Name=instance-state-name,Values=running" "Name=tag:Environment,Values=prod" --query 'Reservations[].Instances[].[InstanceId]' --output text)
> /home/ubuntu/scripts/DiskAlert.txt

for instance_id in $Instance_Ids;
do
        echo "Instance id="$instance_id;
        instance_name=$(aws ec2 describe-instances --instance-ids $instance_id --query 'Reservations[*].Instances[*].Tags[?Key==`Name`].Value[]' --output text)
        echo "Instance Name="$instance_name;
        disks=$(aws ec2 describe-instances --instance-ids i-6444d9ea --query 'Reservations[*].Instances[*].BlockDeviceMappings[*].DeviceName' --output text)
        disks="$(echo $disks | sed 's/s/xv/g')"
	flag=0
        for disk in $disks;
        do
                echo "disk="$disk
        	matrix=$(aws cloudwatch list-metrics --namespace "EC2" --metric-name "DiskUtilization-"$disk --dimensions "Name=InstanceId,Value=$instance_id" --output text)
        	if [ -n "$matrix" ]
        	then

	               aws cloudwatch put-metric-alarm --alarm-name $instance_name"-high-disk-"$disk --alarm-description "Alarm when Disk exceeds 70%" --metric-name DiskUtilization-$disk --namespace EC2 --statistic Average --period $Period --threshold $Alert_Point --comparison-operator GreaterThanThreshold  --dimensions Name=InstanceId,Value=$instance_id --evaluation-periods $Evaluation_Period --alarm-actions $SNS --unit Percent
	       else
			disk="$(echo $disk | sed 's/\///g')"
			if [ "$flag" -eq 0 ]
			then
				`echo $instance_id"   "$instance_name"   "$disk"   " >> /home/ubuntu/scripts/DiskAlert.txt`
				flag=1
			else
				sed -i '${$s/$/'"${disk}   "'/}' /home/ubuntu/scripts/DiskAlert.txt
			fi
	       fi
	done
done
