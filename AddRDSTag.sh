
RDS_Names=$(aws rds describe-db-instances --query 'DBInstances[*].DBInstanceIdentifier' --output text)


for RDS_Name in $RDS_Names;
do
	echo "RDS_Name="$RDS_Name;
	env=`echo $RDS_Name | awk -F'-' '{print $2}'`
	echo "ENV="$env;
	if [ "$env" == "qa" -o "$env" == "prod" -o "$env" == "dev" ]
	then
		echo "yes"
	else
		echo "no"
	fi
done
