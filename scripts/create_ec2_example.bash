#!/bin/bash
set -euo pipefail

AWS_REGION="eu-central-1"
AMI_ID="ami-xxxxxxxxxxxxxxxxx"
INSTANCE_TYPE="t3.micro"
KEY_NAME="your-keypair-name"
SECURITY_GROUP_ID="sg-xxxxxxxxxxxxxxxxx"
SUBNET_ID="subnet-xxxxxxxxxxxxxxxxx"
INSTANCE_NAME="ec2-welcome-app-demo"
USER_DATA_FILE="userdata/userdata_httpd.bash"

INSTANCE_ID=$(
    aws ec2 run-instances \
        --region "${AWS_REGION}" \
        --image-id "${AMI_ID}" \
        --instance-type "${INSTANCE_TYPE}" \
        --key-name "${KEY_NAME}" \
        --security-group-ids "${SECURITY_GROUP_ID}" \
        --subnet-id "${SUBNET_ID}" \
        --user-data "file://${USER_DATA_FILE}" \
        --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=${INSTANCE_NAME}}]" \
        --query 'Instances[0].InstanceId' \
        --output text
)

echo "Created instance: ${INSTANCE_ID}"

aws ec2 wait instance-running \
    --region "${AWS_REGION}" \
    --instance-ids "${INSTANCE_ID}"

echo "Instance is running."

PUBLIC_IP=$(
    aws ec2 describe-instances \
        --region "${AWS_REGION}" \
        --instance-ids "${INSTANCE_ID}" \
        --query 'Reservations[0].Instances[0].PublicIpAddress' \
        --output text
)

echo "Public IP: ${PUBLIC_IP}"
echo "Open in browser: http://${PUBLIC_IP}"