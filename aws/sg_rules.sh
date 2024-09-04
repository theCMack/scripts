#!/bin/bash

# sg_rules.sh - Script to display inbound and outbound rules of an AWS Security Group
# 
# This script fetches and prints inbound and outbound security group rules in a human-readable format.
# It shows the protocol, port ranges, IP addresses, and any associated descriptions.
#
# Usage:
#   ./sg_rules.sh <security-group-id>
#
# Example:
#   ./sg_rules.sh sg-8675309
#
# Ensure you have AWS CLI installed and configured with appropriate permissions.

# Check if Security Group ID is passed as an argument
if [ -z "$1" ]; then
  echo "Usage: $0 <security-group-id>"
  exit 1
fi

SECURITY_GROUP_ID=$1

# Inbound Rules
echo "Inbound Rules:"
aws ec2 describe-security-groups --group-ids "$SECURITY_GROUP_ID" --query "SecurityGroups[0].IpPermissions" --output json | jq -r '
  .[] |
  "Protocol: " + (.IpProtocol // "-") + 
  ", Ports: " + (if .FromPort != null and .ToPort != null 
                 then (.FromPort|tostring) + "-" + (.ToPort|tostring) 
                 else "All" end) + 
  ", IPs: " + 
  (if (.IpRanges | length) > 0 then
    (.IpRanges | map(.CidrIp + (if .Description then " (Description: " + .Description + ")" else "" end)) | join(", "))
  else
    "None"
  end)
'
echo "------------------------------------"

# Outbound Rules
echo "Outbound Rules:"
aws ec2 describe-security-groups --group-ids "$SECURITY_GROUP_ID" --query "SecurityGroups[0].IpPermissionsEgress" --output json | jq -r '
  .[] |
  "Protocol: " + (.IpProtocol // "-") + 
  ", Ports: " + (if .FromPort != null and .ToPort != null 
                 then (.FromPort|tostring) + "-" + (.ToPort|tostring) 
                 else "All" end) + 
  ", IPs: " + 
  (if (.IpRanges | length) > 0 then
    (.IpRanges | map(.CidrIp + (if .Description then " (Description: " + .Description + ")" else "" end)) | join(", "))
  else
    "None"
  end)
'
echo "

