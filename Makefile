rootdir := $(patsubst %/,%,$(dir $(abspath $(lastword $(MAKEFILE_LIST)))))
cwd := $(notdir $(patsubst %/,%,$(dir $(mkfile_path))))
node := /usr/bin/env node
npm := /usr/bin/env npm
coffee := ${rootdir}/node_modules/coffee-script/bin/coffee
coffeelint := ${rootdir}/node_modules/coffeelint/bin/coffeelint

SRC = ${rootdir}/index.coffee ${rootdir}/lib/bebopt.coffee


all: lint build

build:
	$(foreach f,$(SRC),${coffee} -c $(f);)
	touch build

deps:
	cd ${rootdir}; ${npm} install

lint: deps coffeelint
	touch lint

coffeelint:
	$(foreach f,$(SRC),${coffeelint} -f ${rootdir}/coffeelint.json --rules lint/* $(f);)

clean:
	$(foreach f,$(SRC:.coffee=.js),$(RM) $(f);)
	$(RM) lint
	$(RM) build
