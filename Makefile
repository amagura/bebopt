rootdir := $(patsubst %/,%,$(dir $(abspath $(lastword $(MAKEFILE_LIST)))))
cwd := $(notdir $(patsubst %/,%,$(dir $(mkfile_path))))
node := /usr/bin/env node
npm := /usr/bin/env npm
coffee := ${rootdir}/node_modules/coffee-script/bin/coffee
coffeelint := ${rootdir}/node_modules/coffeelint/bin/coffeelint
uglify := ${rootdir}/node_modules/uglify-js/bin/uglifyjs

SRC = ${rootdir}/index.coffee ${rootdir}/lib/bebopt.coffee ${rootdir}/lib/equal.coffee

all: lint build ugly

build:
	$(foreach f,$(SRC),${coffee} -c $(f);)
deps:
	cd ${rootdir}; ${npm} install

lint: deps coffeelint

coffeelint:
	touch coffeelint
	$(foreach f,$(SRC),${coffeelint} -f ${rootdir}/coffeelint.json --rules _lint/* $(f);)

ugly: build
	$(foreach f,$(SRC:.coffee=.js),${uglify} $(f) > $(f:.js=.min.js);)

clean:
	$(foreach f,$(SRC:.coffee=.js),$(RM) $(f);)
	$(foreach f,$(SRC:.coffee=.min.js),$(RM) $(f);)
	$(RM) coffeelint
