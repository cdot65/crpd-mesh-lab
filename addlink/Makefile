all: build

build:
	docker build -t addlink .

run:
	#	docker run -ti --rm --privileged -v /var/run/docker.sock:/var/run/docker.sock --pid host addlink
	docker run -ti --rm --privileged -v /var/run/docker.sock:/var/run/docker.sock --pid host --entrypoint /bin/ash addlink
