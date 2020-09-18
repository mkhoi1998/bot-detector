.PHONY: all test clean

init:
	docker-compose stop; docker-compose rm -f
	docker-compose up -d

test:
	make init
	lua test/test.lua