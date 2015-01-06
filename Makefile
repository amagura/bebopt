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
	tar cf bebopt.tar lib/bebopt.js index.js package.json LICENSE
	sed -i 's/index/index.min/' package.json
	tar czf bebopt.min.tar.gz lib/bebopt.min.js index.min.js package.json LICENSE
	sed -i 's/index[.]min/index/' package.json
	git checkout void
	git clean -e bebopt.tar -e bebopt.min.tar -f
	tar xf bebopt.tar
	git add package.json LICENSE index.js lib
