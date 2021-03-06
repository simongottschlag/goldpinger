name ?= goldpinger
version ?= 1.3.0
bin ?= goldpinger
pkg ?= "github.com/bloomberg/goldpinger"
tag = $(name):$(version)
goos ?= ${GOOS}
namespace ?= ""
files = $(shell find . -iname "*.go")


bin/$(bin): $(files)
	GOOS=${goos} PKG=${pkg} ARCH=amd64 VERSION=${version} BIN=${bin} ./build/build.sh

clean:
	rm -rf ./vendor
	rm -f ./bin/$(bin)

vendor:
	rm -rf ./vendor
	dep ensure -v -vendor-only

swagger:
	swagger generate server -t pkg -f ./swagger.yml --exclude-main -A goldpinger && \
	swagger generate client -t pkg -f ./swagger.yml -A goldpinger

build-multistage:
	docker build -t $(tag) -f ./Dockerfile .

build: GOOS=linux
build: bin/$(bin)
	docker build -t $(tag) -f ./build/Dockerfile-simple .

tag:
	docker tag $(tag) $(namespace)$(tag)

push:
	docker push $(namespace)$(tag)

run:
	go run ./cmd/goldpinger/main.go
	
version:
	@echo $(tag)

.PHONY: clean vendor swagger build build-multistage tag push run version
