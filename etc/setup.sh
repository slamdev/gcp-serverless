#!/bin/sh

set -euxo

TERRAFORM_ADMIN_PROJECT="gcp-serverless-terraform"
TERRAFRORM_SA="terraform"
TERRAFRORM_SA_FULL="${TERRAFRORM_SA}@${TERRAFORM_ADMIN_PROJECT}.iam.gserviceaccount.com"
TERRAFRORM_BUCKET_NAME="${TERRAFORM_ADMIN_PROJECT}-tfstate"
TERRAFRORM_BUCKET_REGION="eu"
TERRAFRORM_SA_FILE="key.json"
BILLING_ACCOUNT_ID=$(gcloud beta billing accounts list --format='get(name)' | grep -oE '[^/]+$')
APPLICATION_NAME="gcp-serverless"
ENVS="dev prod"

if [ -z "$(gcloud projects list --format='get(projectId)' --filter="${TERRAFORM_ADMIN_PROJECT}")" ]; then
  gcloud projects create "${TERRAFORM_ADMIN_PROJECT}"
fi

if [ -z "$(gcloud beta billing projects list --format='get(projectId)' --filter="${TERRAFORM_ADMIN_PROJECT}" --billing-account="${BILLING_ACCOUNT_ID}")" ]; then
  gcloud beta billing projects link "${TERRAFORM_ADMIN_PROJECT}" --billing-account "${BILLING_ACCOUNT_ID}"
fi

if [ -z "$(gcloud iam service-accounts list --project="${TERRAFORM_ADMIN_PROJECT}" --format='get(email)' --filter="${TERRAFRORM_SA_FULL}")" ]; then
  gcloud iam service-accounts create "${TERRAFRORM_SA}" --display-name "Terraform admin account" --project="${TERRAFORM_ADMIN_PROJECT}"
fi

if [ ! -f "${TERRAFRORM_SA_FILE}" ]; then
  gcloud iam service-accounts keys create "${TERRAFRORM_SA_FILE}" --iam-account "${TERRAFRORM_SA_FULL}"
fi

if [ -z "$(gsutil ls -p "${TERRAFORM_ADMIN_PROJECT}" | grep "${TERRAFRORM_BUCKET_NAME}")" ]; then
  gsutil mb -p "${TERRAFORM_ADMIN_PROJECT}" -l "${TERRAFRORM_BUCKET_REGION}" "gs://${TERRAFRORM_BUCKET_NAME}"
fi

if [ -z "$(gsutil versioning get gs://${TERRAFRORM_BUCKET_NAME} | grep "Enabled")" ]; then
  gsutil versioning set on gs://${TERRAFRORM_BUCKET_NAME}
fi

if [ -z "$(gsutil acl get gs://${TERRAFRORM_BUCKET_NAME} | grep "${TERRAFRORM_SA_FULL}")" ]; then
  gsutil acl ch -u "${TERRAFRORM_SA_FULL}:OWNER" "gs://${TERRAFRORM_BUCKET_NAME}"
fi

for ENV in ${ENVS}; do
  PROJECT_NAME="${APPLICATION_NAME}-${ENV}"

  if [ -z "$(gcloud projects list --format='get(projectId)' --filter="${PROJECT_NAME}")" ]; then
    gcloud projects create "${PROJECT_NAME}"
  fi

  if [ -z "$(gcloud beta billing projects list --format='get(projectId)' --filter="${PROJECT_NAME}" --billing-account="${BILLING_ACCOUNT_ID}")" ]; then
    gcloud beta billing projects link "${PROJECT_NAME}" --billing-account "${BILLING_ACCOUNT_ID}"
  fi

  if [ -z "$(gcloud projects get-iam-policy "${PROJECT_NAME}" | grep "${TERRAFRORM_SA_FULL}")" ]; then
    gcloud projects add-iam-policy-binding "${PROJECT_NAME}" --member="serviceAccount:${TERRAFRORM_SA_FULL}" --role=roles/owner
  fi
done
