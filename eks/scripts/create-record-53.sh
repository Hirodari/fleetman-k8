#!/bin/bash

echo "let's create some record"

RECORD_NAME_QUEUE="queue.fredbitenyo.click"
RECORD_NAME_QUEUE_STAGE="stage.queue.fredbitenyo.click"
RECORD_NAME_FLEETMAN="www.fredbitenyo.click"
RECORD_NAME_FLEETMAN_STAGE="stage.fredbitenyo.click"
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

# record for stage.fredbitenyo.click
aws route53 change-resource-record-sets \
    --hosted-zone-id "$HOSTEDZONEID" \
    --change-batch "{\"Changes\":[{
        \"Action\": \"UPSERT\",
        \"ResourceRecordSet\": {
            \"Name\": \"$RECORD_NAME_FLEETMAN_STAGE\",
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
        \"Action\": \"UPSERT\",
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

# record for stage.queue.fredbitenyo.click
aws route53 change-resource-record-sets \
    --hosted-zone-id "$HOSTEDZONEID" \
    --change-batch "{\"Changes\":[{
        \"Action\": \"UPSERT\",
        \"ResourceRecordSet\": {
            \"Name\": \"$RECORD_NAME_QUEUE_STAGE\",
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
        \"Action\": \"UPSERT\",
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
        \"Action\": \"UPSERT\",
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
        \"Action\": \"UPSERT\",
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
    if [ "${HTTP_STATUS}" -eq 200 ] || [ "${HTTP_STATUS}" -eq 307 ]; then
		echo -e "${LIGHT_CYAN}$record successful!"
	else
		echo -e "${LIGHT_RED}$record failed!"
	fi
done