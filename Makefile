repo_organization = skycatch
repo_name = $(shell basename $(shell git config --get remote.origin.url) | cut -d. -f1)

lambda_function = thumbnail-url

repo_full_name = $(repo_organization)/$(repo_name)
git_sha = $(shell git rev-parse --short HEAD)
git_branch ?= $(shell git symbolic-ref HEAD 2>/dev/null | cut -d"/" -f 3-)
region ?= us-west-2
publish ?= false

WARN_COLOR=\x1b[33;01m
NO_COLOR=\x1b[0m

ifeq ($(environment),staging)
	account_id = 942381384083
	bucket = skycatch-staging-v2-terra-state
	role_arn = arn:aws:iam::942381384083:role/skyapi-v2-stage-terraform
else ifeq ($(environment),production)
	account_id = 405381464100
	bucket = skycatch-production-v2-terra-state
	role_arn = arn:aws:iam::405381464100:role/skyapi-v2-prod-terraform
endif

include ./terraform/Makefile

# Instructions for building the application
build: compile
	@echo "> build"

# Fetch application dependencies
fetch-dependencies:
	GO111MODULE=on \
	go get -u golang.org/x/lint/golint
	GO111MODULE=on \
	go get ./...

# Test the application
test:
	golint -set_exit_status
	go vet .
	go test idnetify

# Compile the application
compile:
	GOOS=linux go build -o main main.go

build-clean:
	@echo "> build-clean"
	-rm main
	-rm -rf .cache

package: clean build


# This will build the application without requiring go on the machine
docker-package:
	docker build . -t go-builder
	docker run --rm -v ${PWD}:/root go-builder


package-clean:
	@echo "> package-clean"
	-rm -rf deployment

default: build
