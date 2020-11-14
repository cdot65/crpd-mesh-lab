all: build run

build:
	docker build -t addlink .

run: 
	docker run -ti --rm --privileged -v ${PWD}:/u -v /var/run/docker.sock:/var/run/docker.sock --pid host --entrypoint /bin/bash addlink
