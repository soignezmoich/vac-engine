SHELL := /bin/sh
MDCAT:=$(firstword $(shell which mdcat cat 2>/dev/null))
PATH := ./assets/node_modules/.bin:$(PATH)

.PHONY: help

help:
	@$(MDCAT) MAKE.md

.PHONY: readme

readme:
	@$(MDCAT) README.md


.PHONY: test

test: export MIX_ENV=test
test: export DATABASE_URL=${DATABASE_TEST_URL}
test: deps
	mix test $(test_name)

.PHONY: test-db

test-db: export MIX_ENV=test
test-db: export DATABASE_URL=${DATABASE_TEST_URL}
test-db: db


.PHONY: test-watch

test-watch: export MIX_ENV=test
test-watch: export DATABASE_URL=${DATABASE_TEST_URL}
test-watch:
	fswatch --event=Updated -ro test lib \
		|mix test --listen-on-stdin --stale


.PHONY: deps

deps:
deps:
	mix deps.get --all


.PHONY: build

build: export MIX_ENV=prod
build: deps docs
	mix compile  --warnings-as-errors

.PHONY: migrate

migrate:
migrate: deps
	mix ecto.migrate

.PHONY: clean

clean:
	cd assets && make clean
	- mix phx.digest.clean --all
	rm -fr _build
	rm -fr deps
	rm -fr erl_crash.dump
	rm -fr blueprints/json


.PHONY: server

server: deps assets-deps
	iex -S mix phx.server

.PHONY: prod-test-server

prod-test-server: release
	./_build/prod/rel/vac_engine/bin/vac_engine start

.PHONY: assets

assets:
	cd assets && make build

.PHONY: assets-deps

assets-deps:
	cd assets && make deps

.PHONY: js-watch

js-watch:
	cd assets && make js-watch

.PHONY: css-watch

css-watch:
	cd assets && make css-watch

.PHONY: db

db:
	mix ecto.drop
	mix ecto.create
	mix ecto.migrate
	make db-seed

.PHONY: db-seed

db-seed:
	mix run  -r test/fixtures/helpers.ex -r test/fixtures/blueprints.ex priv/repo/seeds.exs

.PHONY: rollback

rollback:
	mix ecto.rollback

.PHONY: rollback-all

rollback-all:
	mix ecto.rollback --to 20210909075125

.PHONY: remigrate

remigrate: rollback-all migrate

.PHONY: release

release: export MIX_ENV=prod
release: deps assets build
	mix phx.digest
	mix release --overwrite


.PHONY: psql

psql:
	psql ${DATABASE_URL}

.PHONY: test-psql

test-psql:
	psql ${DATABASE_TEST_URL}

.PHONY: format

format:
	mix format mix.exs "lib/**/*.{ex,exs}" "test/**/*.{ex,exs}" \
		"config/**/*.{ex,exs}"  "priv/repo/**/*.{ex,exs}"

.PHONY: docs

docs: deps assets-deps
	redoc-cli bundle docs/swagger.yaml -o priv/static/docs/api.html

.PHONY: docs-server

docs-server:
	redoc-cli serve -w  docs/swagger.yaml

.PHONY: ex-docs

ex-docs:
	mix docs

.PHONY: checks

checks:
	-mix dialyzer
	mix credo suggest -a

.PHONY: coverage

coverage: export MIX_ENV=test
coverage: export DATABASE_URL=${DATABASE_TEST_URL}
coverage:
	mix test --cover
