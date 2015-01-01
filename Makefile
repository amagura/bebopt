rootdir := $(patsubst %/,%,$(dir $(abspath $(lastword $(MAKEFILE_LIST)))))
cwd := $(notdir $(patsubst %/,%,$(dir $(mkfile_path))))
node := /usr/bin/env node
npm := /usr/bin/env npm
coffee := ${rootdir}/node_modules/coffee-script/bin/coffee

SRC = ${rootdir}/index.coffee ${rootdir}/lib/bebopt.coffee


all: lint
	${coffee} ${rootdir}/index.

build:
	$(foreach 
	${coffee} -c ${rootdir}/index.coffee
	${coffee} -

deps:
	${npm} install {-dev,''}

lint:

coffeelint:

