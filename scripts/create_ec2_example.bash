#!/bin/bash
set -euo pipefail

AWS_REGION="eu-central-1"
AMI_ID="ami-020510cc1127d41e9"
INSTANCE_TYPE="t3.micro"
KEY_NAME="mgm-keypair"
SECURITY_GROUP_ID="sg-0a644c3be5f47bfa5"
SUBNET_ID="subnet-018f15ab7481de6cb"
INSTANCE_NAME="mgm-ec2-welcome-dev"
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
        --tag-specifications 'ResourceType=instance,Tags=[
            {Key=Name,Value=mgm-ec2-welcome-dev},
            {Key=Project,Value=cloud-data-portfolio},
            {Key=Owner,Value=mgm},
            {Key=Environment,Value=dev}
        ]' \
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