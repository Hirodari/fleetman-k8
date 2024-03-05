#!/usr/bin/env bash

# fail on any error
set -eu

: ${REGION:="us-east-1"}
: ${ClusterName:="fleetman-test"}
: ${aws_account_id:=$(aws sts get-caller-identity --query Account --output text)}

eksctl utils associate-iam-oidc-provider --region=$REGION --cluster=$ClusterName --approve
eksctl create iamserviceaccount --name ebs-csi-controller-sa --namespace kube-system --cluster \
$ClusterName --attach-policy-arn arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy --approve  \
--role-only  --role-name AmazonEKS_EBS_CSI_DriverRole
eksctl create addon --name aws-ebs-csi-driver --cluster $ClusterName --service-account-role-arn \
arn:aws:iam::$aws_account_id:role/AmazonEKS_EBS_CSI_DriverRole \
--force