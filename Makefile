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

release: ugly
	tar cf bebopt.tar $(SRC) package.json LICENSE
	tar cf bebopt.min.tar $(SRC:.js=.min.js)
	git checkout void
	git clean -e bebopt.tar -e bebopt.min.tar -f
	tar xf bebopt.tar
	tar xf bebopt.min.tar
	git add package.json LICENSE index.js index.min.js lib
