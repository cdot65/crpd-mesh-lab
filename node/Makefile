all: build

build:
	docker build -t crpdnode .

run: build
	docker run --name crpdnode --rm -d crpdnode
	docker exec -ti crpdnode bash || true
	docker kill crpdnode
