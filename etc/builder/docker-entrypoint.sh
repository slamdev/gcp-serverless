#!/bin/sh

set -e

echo "$SA_KEY" > "/tmp/gcp_sa.json"
gcloud auth activate-service-account --key-file=${GOOGLE_APPLICATION_CREDENTIALS}
gcloud config set container/use_application_default_credentials true

exec "$@"
