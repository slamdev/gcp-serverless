# GCP Serverless

## Project AIM

Build a globally distributed application using serverless approach on Google Cloud platform.

### Result

- GCP **Cloud Firestore** is not globally distributed
  * workaround: switch database to FaunaDB
- GCP **Global Load Balancer** doesn't support **Cloud Functions** and **Cloud Storage**
  * workaround: deploy **Envoy Proxy** in each region and put GLB in front; proxy requests to functions\buckets to the corresponding region

## Landscape overview 

![diagram](/etc/diagram.png?raw=true "Diagram")

## Development

### Prerequisites

Create projects for terraform state and a project per environment. [setup.sh](/etc/setup.sh) script covers all the setup.

#### Necessary tools

- [terraform](https://github.com/hashicorp/terraform)
- [terragrunt](https://github.com/gruntwork-io/terragrunt)
- [go](https://golang.org/doc/install)
- [gcloud](https://cloud.google.com/sdk/gcloud/)

macOS:
```shell script
brew install terraform terragrunt go
brew cask install google-cloud-sdk
```

### Build/Deploy

All the interaction with project is implemented via [Makefile](Makefile)

By default all make targets are executed for **dev** environment. It can be changed by providing **TF_VAR_env** variable, e.g.:
```shell script
TF_VAR_env=prod make plan 
```

**make init**|**make plan**|**make apply**|**make destroy** executes corresponding command for all the components in parallel

**make init/{COMPONENT_NAME}**|**make plan/{COMPONENT_NAME}**|**make apply/{COMPONENT_NAME}**|**make destroy/{COMPONENT_NAME}** executes corresponding command for a specified component, e.g.:
```shell script
make plan/backend/functions-bucket
```

**make clean-local-state** target removes local state files from all the projects

**make lint** target does a static validation for all the terraform files (at the moment it validates only code style rules according to the terraform conventions)

**make format** formats all the terraform files according to the terraform conventions

**make unlock/{COMPONENT_NAME}** command unlocks the remote terraform state for a component, e.g.:
```shell script
make unlock/backend/functions-bucket LOCK_ID=123456789
```

#### Remark about **make init**

Terragrunt suppose to do auto-init so in most cases there is no need to invoke this command manually, but some times it fails to do it. There is an open issue about it: https://github.com/gruntwork-io/terragrunt/issues/388

#### Remark about **make clean-local-state**

If there was a deploy to dev, terraform will fail to deploy to prod, because it has a state from dev locally. So it will try to migrate a dev state to prod and this is not a desire behavior.

Subj make target will clean all the local state files so deploy to prod will succeed.

### CI/CD

Flow:
- if a user pushes to **master** branch then the pipeline will apply changes to the **DEV** environment (by executing `TF_VAR_env=DEV make apply`)
- if a user pushes to **production** branch then the pipeline will apply changes to the **PROD** environment (by executing `TF_VAR_env=PROD make apply`)
- if a user pushes to an arbitrary branch then the pipeline will:
  * lint all the files in the project (by executing `make lint`)
  * do **plan** on **dev** environment (by executing `TF_VAR_env=dev make plan`)
