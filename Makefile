.PHONY: all test clean

clean:
	docker-compose down;

init:
	docker-compose up -d

test:
	make init
	lua test/test.lua
