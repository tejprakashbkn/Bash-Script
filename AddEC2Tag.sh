



Instance_Ids=$(aws ec2 describe-instances  --query 'Reservations[].Instances[].[InstanceId]' --output text)
#echo $Instance_Ids


for instance_id in $Instance_Ids;
do
	echo "Instance id="$instance_id;
	instance_name=$(aws ec2 describe-instances --instance-ids $instance_id --query 'Reservations[*].Instances[*].Tags[?Key==`Name`].Value[]' --output text)
	env=`echo $instance_name | awk -F'-' '{print $2}'`
	echo "ENV="$env;
	if [ "$env" == "qa" -o "$env" == "prod" -o "$env" == "dev" ]
	then
		aws ec2 create-tags --resources $instance_id  --tags Key=Environment,Value=$env --profile groupon-write
	else
		aws ec2 create-tags --resources $instance_id  --tags Key=Environment,Value=miscellaneous --profile groupon-write
	fi
done
