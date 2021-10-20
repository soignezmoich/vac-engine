SHELL := /bin/sh
PATH := ./node_modules/.bin:$(PATH)


.PHONY: build

build: export NODE_ENV=production
build: node_modules js optimize

.PHONY: watch

watch: node_modules
	./build.js watch

.PHONY: js

js: node_modules
	./build.js

.PHONY: optimize
optimize: node_modules
	purgecss -c purgecss.config.js -o ../priv/static/assets/css/
	csso ../priv/static/assets/css/app.css --output ../priv/static/assets/css/app.css

.PHONY: clean

clean:
	rm -fr node_modules
	rm -fr ../priv/static/assets/
	rm -fr npm-debug.log*

yarn.lock:
	yarn

node_modules: yarn.lock package.json
	yarn

