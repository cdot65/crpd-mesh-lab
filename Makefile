PROJECT=honeycomb

all: up

up: build down
	docker-compose --project-name ${PROJECT} up -d
	./validate.sh
	./test-nodes.sh

scale400: build down
	docker-compose -f docker-compose-400.yml --project-name ${PROJECT} up -d
	./validate.sh
	./test-nodes.sh

build:
	docker-compose --project-name ${PROJECT} build

ps:
	docker-compose -f docker-compose-400.yml --project-name ${PROJECT} ps
	@echo -n "total routes: "
	@docker exec -ti honeycomb_node_1 ip -6 r |grep -v / |wc -l

down:
	docker-compose -f docker-compose-400.yml --project-name ${PROJECT} down --remove-orphans
