#!/bin/bash

# fail on any error
set -eu

# Set up AWS profile using AWS CLI
aws configure set aws_access_key $aws_access_key_id --profile $aws_profile_name
aws configure set aws_secret_access_key $aws_secret_access_key --profile $aws_profile_name
aws configure set region $aws_default_region --profile $aws_profile_name
aws configure set output $aws_output_format --profile $aws_profile_name

echo "AWS profile '$aws_profile_name' configured successfully."
