#!/bin/sh

set -euo

cat <<< "$SA_KEY" > "/tmp/gcp_sa.json"
export GOOGLE_APPLICATION_CREDENTIALS="/tmp/gcp_sa.json"
gcloud auth activate-service-account --key-file=${GOOGLE_APPLICATION_CREDENTIALS}
gcloud config set container/use_application_default_credentials true

exec "$@"
