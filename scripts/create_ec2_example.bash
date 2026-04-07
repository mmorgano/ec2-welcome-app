#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

if [[ ! -f "${PROJECT_ROOT}/config.local.bash" ]]; then
    echo "ERROR: missing config.local.bash"
    echo "Copy config.example.bash to config.local.bash and fill in real values."
    exit 1
fi

source "${PROJECT_ROOT}/config.local.bash"

AWS_REGION="eu-central-1"
INSTANCE_TYPE="t3.micro"
INSTANCE_NAME="mgm-ec2-welcome-dev"
USER_DATA_FILE="${PROJECT_ROOT}/userdata/userdata_httpd.bash"

if [[ "${AMI_ID}" == "<AMI_ID>" || "${KEY_NAME}" == "<KEY_NAME>" || \
      "${SECURITY_GROUP_ID}" == "<SECURITY_GROUP_ID>" || "${SUBNET_ID}" == "<SUBNET_ID>" ]]; then
    echo "ERROR: please replace placeholder values in config.local.bash before running the script."
    exit 1
fi

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
echo "To terminate:"
echo "aws ec2 terminate-instances --region ${AWS_REGION} --instance-ids ${INSTANCE_ID}"