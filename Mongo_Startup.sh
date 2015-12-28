#!/bin/bash

mongo --eval "rs.initiate()"



SG=`ec2metadata --security-groups`
Instances=$(aws ec2 describe-instances --filters "Name=instance-state-name,Values=running"  "Name=tag:Environment,Values=prod" "Name=instance.group-name,Values=$SG"  --query 'Reservations[*].Instances[*].Tags[?Key==`Name`].Value[]' --output text)
#echo $Instances
arbiter=""
secondary=""

for instance in $Instances
do
	if [[ $instance == *"arbiter"* ]]
	then
		echo "arbiter"
		arbiter=$(aws ec2 describe-instances --filters "Name=instance-state-name,Values=running"  "Name=tag:Environment,Values=prod" "Name=tag:Name,Values=$instance" --query 'Reservations[*].Instances[*].NetworkInterfaces[*].PrivateIpAddresses[*].PrivateIpAddress' --output text)
		echo $arbiter
		mongo $arbiter:27017/testdb --eval "db.stats()"
		RESULT=$?
		if [ $RESULT -ne 0 ]; then
  			echo "mongodb not running"
    			exit 1
		else
    			echo "mongodb running!"
			mongo --eval "rs.add(\"${arbiter}\")"
		fi
	elif [[ $instance == *"secondary"* ]]
	then
		echo "secondary"
		secondary=$(aws ec2 describe-instances --filters "Name=instance-state-name,Values=running"  "Name=tag:Environment,Values=prod" "Name=tag:Name,Values=$instance" --query 'Reservations[*].Instances[*].NetworkInterfaces[*].PrivateIpAddresses[*].PrivateIpAddress' --output text)
		echo $secondary
		mongo $secondary:27017/testdb --eval "db.stats()"
                RESULT=$?
                if [ $RESULT -ne 0 ]; then
                        echo "mongodb not running"
                        exit 1
                else
                        echo "mongodb running!"
			mongo --eval "rs.add(\"${secondary}\")"
                fi
	else
		echo "primary"
	fi

done
