#!/bin/bash-e


echo  "shutting down the project and cluster"
echo  "deleting workloads"
kubectl delete -f eks/workload/stage
kubectl delete -f eks/workload/production
echo  "deleting database"
kubectl delete -f eks/database
echo  "deleting elkStack"
kubectl delete -f eks/elkStack
echo  "deleting prometheus"	
kubectl delete -f eks/prometheusStack/crds.yaml
kubectl delete -f eks/prometheusStack/eks-monitoring.yaml
echo  "deleting ingress controller"
kubectl delete -f eks/ingress/ingress-controller-cloud.yaml
kubectl delete -f eks/ingress/nginx-ingress-nlb.yaml
kubectl delete -f eks/ingress/ingress.yaml
sleep 10s
echo "checking pods and services"
kubectl get all
kubectl get all -n monitoring
kubectl get all -n kube-system
sleep 5s
echo "all pods and services down"