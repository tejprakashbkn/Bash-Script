
Instance_Ids=$(aws ec2 describe-instances --filters "Name=instance-state-name,Values=running" --filters "Name=tag:Environment,Values=prod" --query 'Reservations[].Instances[].[InstanceId]' --output text)

for instance_id in $Instance_Ids;
do
	aws ec2 monitor-instances --instance-ids $instance_id --profile groupon-write
done
