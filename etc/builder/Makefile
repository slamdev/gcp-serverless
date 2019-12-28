SHELL = /bin/sh

TAG := "slamdev/gcp-serverless-builder:latest"

push:
	docker pull $(TAG) || true
	docker build . -t $(TAG) --cache-from ${TAG}
	docker push $(TAG)
