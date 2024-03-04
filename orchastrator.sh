#!/bin/bash

# fail on any error
set -eu

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



echo -e "${LIGHT_GREEN}initializing volumes for our mangodb storage"
make init-ebs
echo -e "${LIGHT_CYAN}deploy workloads"
kubectl apply -f eks/workload
kubectl apply -f eks/database
echo -e "${LIGHT_PURPLE}deploy ingress controller"
kubectl apply -f eks/ingress/ingress-controller-cloud.yaml
kubectl apply -f eks/ingress/nginx-ingress-nlb.yaml
sleep 10s
echo -e "${LIGHT_GREY}deploy kibana"
kubectl apply -f eks/elkStack
echo -e "${LIGHT_PURPLE}deploy prometheus"
kubectl apply -f eks/prometheusStack/crds.yaml
kubectl apply -f eks/prometheusStack/eks-monitoring.yaml	
sleep 10s
echo -e "${LIGHT_GREY}deploy ingress"
kubectl apply -f eks/ingress/ingress.yaml
sleep 60s
# Get the DNS name of the Ingress load balancer

RECORD_NAME_QUEUE="queue.fredbitenyo.click"
RECORD_NAME_FLEETMAN="www.fredbitenyo.click"
RECORD_NAME_PROMETHEUS="prometheus.fredbitenyo.click"
RECORD_NAME_GRAFANA="grafana.fredbitenyo.click"
RECORD_NAME_KIBANA="kibana.fredbitenyo.click"
HOSTEDZONEID=$(aws route53 list-hosted-zones-by-name --dns-name fredbitenyo.click \
--query 'HostedZones[0].Id' --output text)
KIBANA_LOADBALANCER_DNS=$(kubectl get svc kibana-logging -n kube-system \
-o json | jq -r '.status.loadBalancer.ingress[0].hostname')
FLEETMAN_DNS=$(kubectl get ingress -o json | jq -r ".items[0].status.loadBalancer.ingress[0].hostname")
MONITORING_DNS=$(kubectl get ingress -n monitoring -o json | jq -r ".items[0].status.loadBalancer.ingress[0].hostname")
KUBE_SYSTEM_DNS=$(kubectl get ingress -n kube-system -o json | jq -r ".items[0].status.loadBalancer.ingress[0].hostname")


# record for www.fredbitenyo.click
aws route53 change-resource-record-sets \
    --hosted-zone-id "$HOSTEDZONEID" \
    --change-batch "{\"Changes\":[{
        \"Action\": \"CREATE\",
        \"ResourceRecordSet\": {
            \"Name\": \"$RECORD_NAME_FLEETMAN\",
            \"Type\": \"A\",
            \"AliasTarget\": {
                \"HostedZoneId\": \"Z26RNL4JYFTOTI\",
                \"DNSName\": \"$FLEETMAN_DNS\",
                \"EvaluateTargetHealth\": false
            }
        }
    }]}"

# record for queue.fredbitenyo.click
aws route53 change-resource-record-sets \
    --hosted-zone-id "$HOSTEDZONEID" \
    --change-batch "{\"Changes\":[{
        \"Action\": \"CREATE\",
        \"ResourceRecordSet\": {
            \"Name\": \"$RECORD_NAME_QUEUE\",
            \"Type\": \"A\",
            \"AliasTarget\": {
                \"HostedZoneId\": \"Z26RNL4JYFTOTI\",
                \"DNSName\": \"$FLEETMAN_DNS\",
                \"EvaluateTargetHealth\": false
            }
        }
    }]}"

# record for prometheus.fredbitenyo.click
aws route53 change-resource-record-sets \
    --hosted-zone-id "$HOSTEDZONEID" \
    --change-batch "{\"Changes\":[{
        \"Action\": \"CREATE\",
        \"ResourceRecordSet\": {
            \"Name\": \"$RECORD_NAME_PROMETHEUS\",
            \"Type\": \"A\",
            \"AliasTarget\": {
                \"HostedZoneId\": \"Z26RNL4JYFTOTI\",
                \"DNSName\": \"$MONITORING_DNS\",
                \"EvaluateTargetHealth\": false
            }
        }
    }]}"

# record for grafana.fredbitenyo.click
aws route53 change-resource-record-sets \
    --hosted-zone-id "$HOSTEDZONEID" \
    --change-batch "{\"Changes\":[{
        \"Action\": \"CREATE\",
        \"ResourceRecordSet\": {
            \"Name\": \"$RECORD_NAME_GRAFANA\",
            \"Type\": \"A\",
            \"AliasTarget\": {
                \"HostedZoneId\": \"Z26RNL4JYFTOTI\",
                \"DNSName\": \"$MONITORING_DNS\",
                \"EvaluateTargetHealth\": false
            }
        }
    }]}"

# record for kibana.fredbitenyo.click
aws route53 change-resource-record-sets \
    --hosted-zone-id "$HOSTEDZONEID" \
    --change-batch "{\"Changes\":[{
        \"Action\": \"CREATE\",
        \"ResourceRecordSet\": {
            \"Name\": \"$RECORD_NAME_KIBANA\",
            \"Type\": \"A\",
            \"AliasTarget\": {
                \"HostedZoneId\": \"Z26RNL4JYFTOTI\",
                \"DNSName\": \"$KUBE_SYSTEM_DNS\",
                \"EvaluateTargetHealth\": false
            }
        }
    }]}"

# Z35SXDOTRQ7X7K hosted zone id for application loadbalancer
# Z26RNL4JYFTOTI hosted zone id for network loadbalancer
# testing our deployment

# Define a list of variables
dns=(
	$RECORD_NAME_QUEUE 
	$RECORD_NAME_FLEETMAN 
	$RECORD_NAME_PROMETHEUS 
	$RECORD_NAME_GRAFANA 
	$RECORD_NAME_KIBANA
	)

# Iterate through each variable
echo checking 
for record in "${dns[@]}"; do
	HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" $record)
    if [ "${HTTP_STATUS}" != 503  ]; then
		echo -e "${LIGHT_CYAN}$record successful!"
	else
		echo -e "${LIGHT_RED}$record failed!"
	fi
done

# echo $FLEETMAN_DNS
# echo $MONITORING_DNS
# echo $KUBE_SYSTEM_DNS
# echo hosted zone id: $HOSTEDZONEID
# a5eaed44bc00647208e05bacb9ffc8c1-a35bd5d727e0c454.elb.us-east-1.amazonaws.com