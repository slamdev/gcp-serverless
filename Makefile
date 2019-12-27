SHELL = /bin/bash

lint:
	terragrunt validate-all --terragrunt-non-interactive
	terragrunt hclfmt --terragrunt-check
	terraform fmt -list=true -write=false -check -diff -recursive

format:
	terragrunt hclfmt
	terraform fmt -list=true -write=true -diff -recursive

init:
	find . -mindepth 2 -maxdepth 3 -name main.tf -execdir terragrunt init ';'

plan:
	terragrunt plan-all --terragrunt-non-interactive

apply:
	terragrunt apply-all --terragrunt-non-interactive

destroy:
	terragrunt destroy-all --terragrunt-non-interactive

clean-local-state:
	find . -name terraform.tfstate -delete

init/%:
	cd $* && terragrunt init

plan/%:
	cd $* && terragrunt plan --terragrunt-non-interactive

apply/%:
	cd $* && terragrunt apply --terragrunt-non-interactive

destroy/%:
	cd $* && terragrunt destroy --terragrunt-non-interactive

unlock/%:
	cd $* && terragrunt force-unlock -force $(LOCK_ID)
