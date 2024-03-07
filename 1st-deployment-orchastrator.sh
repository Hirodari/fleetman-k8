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



echo -e "${LIGHT_GREEN}initializing volumes for our mangodb storage"
make init-ebs
echo -e "${LIGHT_CYAN}deploy workloads"
kubectl apply -f eks/workload/stage
sleep 30s
kubectl get po
kubectl get svc
kubectl apply -f eks/database
echo -e "${LIGHT_PURPLE}deploy ingress controller"
kubectl apply -f eks/ingress/ingress-controller-cloud.yaml
kubectl apply -f eks/ingress/nginx-ingress-nlb.yaml
sleep 30s
kubectl get pods -n ingress-nginx
kubectl describe svc ingress-nginx-controller-admission -n ingress-nginx
echo -e "${LIGHT_GREY}deploy kibana"
kubectl apply -f eks/elkStack
echo -e "${LIGHT_PURPLE}deploy prometheus"	
kubectl apply -f eks/prometheusStack/crds.yaml
kubectl apply -f eks/prometheusStack/eks-monitoring.yaml	
sleep 30s
echo -e "${LIGHT_GREY}deploy ingress"
kubectl apply -f eks/ingress/ingress.yaml
sleep 60s
kubectl get ingress
kubectl get ingress -n monitoring
kubectl describe ingress 
