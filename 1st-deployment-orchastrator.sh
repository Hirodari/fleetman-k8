#!/bin/bash



echo "initializing volumes for our mangodb storage"
make init-ebs
echo "deploy workloads"
kubectl apply -f eks/workload/demo
sleep 30s
kubectl get po
kubectl get svc
kubectl apply -f eks/database
echo "deploy ingress controller"
kubectl apply -f eks/ingress/ingress-controller-cloud.yaml
kubectl apply -f eks/ingress/nginx-ingress-nlb.yaml
sleep 30s
kubectl get pods -n ingress-nginx
kubectl describe svc ingress-nginx-controller-admission -n ingress-nginx
echo "deploy kibana"
kubectl apply -f eks/elkStack
echo "deploy prometheus"	
kubectl apply -f eks/prometheusStack/crds.yaml
kubectl apply -f eks/prometheusStack/eks-monitoring.yaml	
sleep 30s
echo "deploy ingress"
kubectl apply -f eks/ingress/ingress.yaml
sleep 60s
kubectl get ingress
kubectl get ingress -n monitoring
kubectl describe ingress 
