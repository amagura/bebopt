rootdir := $(patsubst %/,%,$(dir $(abspath $(lastword $(MAKEFILE_LIST)))))
cwd := $(notdir $(patsubst %/,%,$(dir $(mkfile_path))))
node := /usr/bin/env node
npm := /usr/bin/env npm
uglify := ${rootdir}/node_modules/uglify-js/bin/uglifyjs

SRC = ${rootdir}/index.js ${rootdir}/lib/bebopt.js

all: deps ugly

deps:
	cd ${rootdir}; ${npm} install

ugly:
	$(foreach f,$(SRC),${uglify} $(f) > $(f:.js=.min.js);)

clean:
	$(foreach f,$(SRC:.js=.min.js),$(RM) $(f);)
