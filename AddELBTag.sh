ELB_Names=$(aws elb describe-load-balancers --query 'LoadBalancerDescriptions[*].LoadBalancerName' --output text)
#echo $Instance_Ids


for elb_name in $ELB_Names;
do
	echo "ELB name="$elb_name;
	env=`echo $elb_name | awk -F'-' '{print $2}'`	
	echo "ENV="$env;
	if [ "$env" == "qa" -o "$env" == "prod" ]
	then
		aws elb add-tags --load-balancer-names $elb_name --tags Key=Environment,Value=$env --profile groupon-write
	else
		aws elb add-tags --load-balancer-names $elb_name --tags Key=Environment,Value=miscellaneous --profile groupon-write
	fi
done
