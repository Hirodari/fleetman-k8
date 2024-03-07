#!/bin/bash


# rolling back scenario
echo "preparing production code"
echo  "deploy workloads"
kubectl apply -f eks/workload/production
# kubectl delete -f eks/workload/stage
echo "routing to stage containers"
kubectl apply -f eks/ingress/ingress.yaml

dns=(
	$RECORD_NAME_QUEUE 
	$RECORD_NAME_FLEETMAN 
	$RECORD_NAME_PROMETHEUS 
	$RECORD_NAME_GRAFANA 
	$RECORD_NAME_KIBANA
	$RECORD_NAME_FLEETMAN_STAGE
	$RECORD_NAME_QUEUE_STAGE
	)


echo  "${LIGHT_PURPLE}checking if the system is up"
for record in "${dns[@]}"; do
	HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" $record)
    if [ "${HTTP_STATUS}" -eq 200 ] || [ "${HTTP_STATUS}" -eq 307 || [ "${HTTP_STATUS}" -eq 302] ]; then
		echo  "$record successful!"
	else
		echo  "$record failed!"
	fi
done
curl $RECORD_NAME_FLEETMAN_STAGE