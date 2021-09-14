SHELL := /bin/sh
MDCAT:=$(firstword $(shell which mdcat cat 2>/dev/null))

.PHONY: help

help:
	@$(MDCAT) MAKE.md

.PHONY: readme

readme:
	@$(MDCAT) README.md

.PHONY: all

all:
	echo "Run make with a task"


.PHONY: test

test: export MIX_ENV=test
test:
	mix test

.PHONY: test-db

test-db: export MIX_ENV=test
test-db: db


.PHONY: watch-test

watch-test:
	fswatch --event=Updated -ro test lib \
	|mix test --listen-on-stdin --stale


.PHONY: deps

deps:
deps:
	mix deps.get --all


.PHONY: build

build: export MIX_ENV=prod
build: deps
	mix compile

.PHONY: migrate

migrate:
migrate: deps
	mix ecto.migrate

.PHONY: clean

clean:
	cd assets && make clean
	rm -fr _build
	rm -fr deps
	rm -fr erl_crash.dump


.PHONY: server

server: deps
	iex -S mix phx.server

.PHONY: assets

assets:
	cd assets && make build

.PHONY: assets-watch

assets-watch:
	cd assets && make watch

.PHONY: import

import:
	mix import

.PHONY: db

db:
	mix ecto.drop
	mix ecto.create
	mix ecto.migrate

.PHONY: rollback

rollback:
	mix ecto.rollback

.PHONY: rollback-all

rollback-all:
	mix ecto.rollback --to 20210909075125

.PHONY: release

release: export MIX_ENV=prod
release: clean deps assets build
	mix phx.digest
	mix release


.PHONY: psql

psql:
	psql ${DATABASE_URL}

.PHONY: deploy

deploy: release
	echo "NO RELEASE SCRIPT"
