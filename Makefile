.PHONY: test
test:
	test -z "$(shell gofmt -l *.go ./cmd)"
	go test -v ./

.PHONY: format
format:
	gofmt -w *.go ./cmd

.PHONY: build
build:
	go build -o portforward ./cmd
