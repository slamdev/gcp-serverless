init:
	GO111MODULE=off go get github.com/deepmap/oapi-codegen/cmd/oapi-codegen

build:
	oapi-codegen -generate types,chi-server -o swagger.gen.go -package function ../../frontend/swagger.yaml

mod:
	go mod tidy
	go mod verify
