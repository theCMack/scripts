#!/bin/bash

# Summary:
# This script searches for a specific user across all GCP projects associated with a given billing account.
# It accepts two arguments:
#   1. Billing account ID (required)
#   2. User email to search for in IAM policies (required)
#
# If no arguments are provided, default values for BILLING_ACCOUNT_ID and USER_EMAIL will be used.
#
# Usage:
#   ./search_user_in_projects.sh <billing-account-id> <user-email>
# Example:
#   ./search_user_in_projects.sh ABC123-XYZ456 user@example.com
#

# Set the billing account and user email either from args or default values
BILLING_ACCOUNT_ID=${1:-"your-billing-account-id"}
USER_EMAIL=${2:-"user@example.com"}

# Check if the billing account ID and user email are set
if [ -z "$BILLING_ACCOUNT_ID" ] || [ -z "$USER_EMAIL" ]; then
    echo "Usage: $0 <billing-account-id> <user-email>"
    exit 1
fi

# List projects associated with the billing account and search for the user in each project
gcloud beta billing projects list --billing-account="$BILLING_ACCOUNT_ID" --format="value(projectId)" | while read project; do
    echo "Searching in Project: $project"
    gcloud projects get-iam-policy "$project" --flatten="bindings[].members" --format="table(bindings.members)" --filter="bindings.members:$USER_EMAIL"
done

