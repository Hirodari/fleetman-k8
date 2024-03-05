create-cluster:
	eksctl create cluster --name "fleetman" --region=us-east-1 --node-type t3.medium \
	--zones=us-east-1a,us-east-1b,us-east-1c,us-east-1d,us-east-1f --nodegroup-name=standard-workers \
	--nodes=4 --nodes-min=2 --nodes-max=4 --version 1.27 --managed
delete-cluster:
	eksctl delete cluster --name "fleetman-test"
init-ebs:
	bash init_ebs.sh
update-confg:
	aws eks --region "us-east-1" update-kubeconfig --name "fleetman"
check-config:
	kubectl config current-context
update-config-minikube:
	kubectl config use-context minikube
testing:
	echo "Makefile is working!"