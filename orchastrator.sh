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
DARK_GEY='\033[1;30m'
LIGHT_RED='\033[1;31m'
LIGHT_GREEN='\033[1;32m'
LIGHT_BLUE='\033[1;34m'
LIGHT_PURPLE='\033[1;35m'
LIGHT_CYAN='\033[1;36m'
WHITE='\033[1;37m'

HAS_Makefile="$(ls | grep Makefile &> /dev/null && echo true || echo false)"

echo -e "This script simulates buildspec.yaml to orchastrate cicd pipeline"
echo "================================================================"
echo 
echo current directory: `pwd`

if [ "${HAS_Makefile}" != "false"  ]; then
	echo "creating cluster fleetman"
	make create-cluster
	echo "initializing volumes for our mangodb storage"
	make init-ebs
	echo -e "${CYAN}deploy workloads"
	kubectl apply -f eks/workload
	kubectl apply -f eks/elkStack
fi
