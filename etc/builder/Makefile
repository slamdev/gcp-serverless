SHELL = /bin/sh

TAG := "slamdev/gcp-serverless-builder:latest"

push:
	docker pull $(TAG) || true
	docker build . -t $(TAG)
	docker push $(TAG)
