PROJECT=honeycomb

all: up

build:
	docker-compose --project-name ${PROJECT} build

up: build
	docker-compose --project-name ${PROJECT} up -d
#	docker-compose --project-name ${PROJECT} up -d --scale row0=2

ps:
	docker-compose --project-name ${PROJECT} ps
	@echo -n "total routes: "
	@docker exec -ti honeycomb_1_1 ip -6 r |grep -v / |wc -l

down:
	docker-compose --project-name ${PROJECT} down
