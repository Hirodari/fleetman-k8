#!/bin/bash


# color code
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'        
BLUE='\033[0;34m'
LIGHT_GREY='\033[0;37m'
BLACK='\033[0;30m'
BROWN='\033[0;33m'
CYAN='\033[0;36m'
DARK_GREY='\033[1;30m'
LIGHT_RED='\033[1;31m'
LIGHT_GREEN='\033[1;32m'
LIGHT_BLUE='\033[1;34m'
LIGHT_PURPLE='\033[1;35m'
LIGHT_CYAN='\033[1;36m'
WHITE='\033[1;37m'


# rolling back scenario
echo "Upgrading to version: Fleet Management System R2"
echo -e "${LIGHT_CYAN}deploy workloads"
kubectl apply -f eks/workload/stage
sleep 10s
echo "${LIGHT_CYAN}routing to stage containers"
kubectl apply -f eks/ingress/ingress.yaml

dns=(
	$RECORD_NAME_QUEUE 
	$RECORD_NAME_FLEETMAN 
	$RECORD_NAME_PROMETHEUS 
	$RECORD_NAME_GRAFANA 
	$RECORD_NAME_KIBANA
	)


echo -e "${LIGHT_PURPLE}checking if the system is up"
for record in "${dns[@]}"; do
	HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" $record)
    if [ "${HTTP_STATUS}" -eq 200 ] || [ "${HTTP_STATUS}" -eq 307 || [ "${HTTP_STATUS}" -eq 302] ]; then
		echo -e "${LIGHT_CYAN}$record successful!"
	else
		echo -e "${LIGHT_RED}$record failed!"
	fi
done
kubectl get po
kubectl get svc
sleep 60s
kubectl describe ingress 