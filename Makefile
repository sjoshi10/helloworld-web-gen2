BINARY_NAME=helloworld-web

.PHONY: all clean fmt lint test sonar build run docker-build docker-push docker-deploy inspec

all: sonar deploy inspec
clean:
	go clean
	rm -f $(BINARY_NAME)
	rm -f tests/reports/golangci-lint.xml
	rm -f tests/reports/coverage.out
fmt:
	go fmt
lint: fmt
	mkdir -p tests/reports && touch tests/reports/.gitkeep
	golangci-lint run --out-format checkstyle | tee tests/reports/golangci-lint.xml
test: lint
	mkdir -p tests/reports && touch tests/reports/.gitkeep
	go test ./... -coverprofile=tests/reports/coverage.out
sonar: test
	sonar-scanner
build: 
	CGO_ENABLED=0 GOOS=linux go build -o $(BINARY_NAME) -v
run:
	./$(BINARY_NAME)
docker-build: build
	docker build --no-cache -t nemonik/helloworld-web .
docker-push: docker-build
	docker tag nemonik/helloworld-web k3d-registry.nemonik.com:5000/nemonik/helloworld-web
	docker push k3d-registry.nemonik.com:5000/nemonik/helloworld-web
deploy: docker-push
	kubectl apply -f kubernetes/helloworld-web-namespace.yaml 2> /dev/null
	kubectl delete -f kubernetes/helloworld-web.yaml 2> /dev/null
	kubectl apply -f kubernetes/helloworld-web.yaml
	kubectl wait --for=condition=ready pod -n helloworld-web -l app.kubernetes.io/component=helloworld-web --timeout=180s
inspec:
	inspec exec tests/inspec/helloworld-web/. --chef-license=accept-silent
