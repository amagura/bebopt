# convenience variables
rootdir := $(patsubst %/,%,$(dir $(abspath $(lastword $(MAKEFILE_LIST)))))
cwd := $(notdir $(patsubst %/,%,$(dir $(mkfile_path))))
TARGET := deps lint style ugly

# source code
DOC = $(wildcard ${rootdir}/src/*.m4)
SRC = $(wildcard ${rootdir}/src/*.js)
EXT = package.json LICENSE

# compilers/tools
node := /usr/bin/env node
m4 := /usr/bin/env m4
npm := /usr/bin/env npm
coffee := ${rootdir}/node_modules/coffee-script/bin/coffee
coffeelint := ${rootdir}/node_modules/coffeelint/bin/coffeelint
uglify := ${rootdir}/node_modules/uglify-js/bin/uglifyjs

.PHONY: clean release all
all: deps ugly

deps:
	cd ${rootdir}; ${npm} install
	touch deps

doc:
	$(foreach d,$(DOC),${m4} $(d) ${rootdir}/wiki/$(d:.m4=.md);)

lint: style
	touch lint

style:
	$(foreach f,$(SRC),sed -ri 's/\s+$$//' $(f);)
	touch style

ugly: deps
	$(foreach f,$(SRC),${uglify} $(f) > $(f:.js=.min.js);)
	touch ugly

clean:
	$(foreach f,$(SRC:.js=.min.js),$(RM) $(f);)
	$(foreach t,$(TARGET),$(RM) $(t);)

release: deps ugly
	sed -i '1s/src/lib/' $(
	tar cf bebopt.tar $(SRC) $(EXT)
	sed -i 's/index/index.min/' package.json
	tar czf bebopt.min.tar.gz $(SRC:.js=.min.js) $(EXT)
	sed -i 's/index[.]min/index/' package.json
	git checkout void
	git clean -e bebopt.tar -e bebopt.min.tar.gz -f
	tar xf bebopt.tar
	git add package.json LICENSE index.js lib
	$(RM) -r node_modules
	git clean -e bebopt.min.tar.gz -f
