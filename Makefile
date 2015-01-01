rootdir := $(patsubst %/,%,$(dir $(abspath $(lastword $(MAKEFILE_LIST)))))
cwd := $(notdir $(patsubst %/,%,$(dir $(mkfile_path))))
node := /usr/bin/env node
npm := /usr/bin/env npm
coffee := ${rootdir}/node_modules/coffee-script/bin/coffee
coffeelint := ${rootdir}/node_modules/coffeelint/bin/coffeelint

SRC = ${rootdir}/index.coffee ${rootdir}/lib/bebopt.coffee


all: lint

build:
	$(foreach f,$(SRC),${coffee} -c $(f);)

deps:
	cd ${rootdir}; ${npm} install

lint: deps coffeelint

coffeelint:
	$(foreach f,$(SRC),${coffeelint} -f ${rootdir}/coffeelint.json --rules rule.coffee $(f);)
