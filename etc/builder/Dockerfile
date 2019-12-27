FROM alpine:3.10.2

ENV TF_VERSION=0.12.18
ENV TG_VERSION=v0.21.10
ENV PATH $PATH:/root/google-cloud-sdk/bin

RUN apk add --update --no-cache bash git openssh make curl python2 \
# terraform
 && curl -fL https://releases.hashicorp.com/terraform/${TF_VERSION}/terraform_${TF_VERSION}_linux_amd64.zip -o terraform.zip \
 && unzip terraform.zip && mv terraform /usr/local/bin/ && rm -f terraform.zip && chmod +x /usr/local/bin/terraform \
 && terraform -version \
# terragrunt
 && curl -fL https://github.com/gruntwork-io/terragrunt/releases/download/${TG_VERSION}/terragrunt_linux_amd64 -o /usr/local/bin/terragrunt \
 && chmod +x /usr/local/bin/terragrunt \
 && terragrunt -version \
# gcloud
 && curl -sSL https://sdk.cloud.google.com | bash \
 && gcloud version

ENTRYPOINT ["docker-entrypoint.sh"]
