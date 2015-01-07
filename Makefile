# convenience variables
mkfile_path := $(abspath $(lastword $(MAKEFILE_LIST)))
mydir := $(abspath $(lastword $(dir $(MAKEFILE_LIST))))
cwd := $(notdir $(patsubst %/,%,$(dir $(mkfile_path))))

# source code
DOC = $(wildcard $(mydir)/src/*.m4)
SRC = $(filter-out %.min.js, $(wildcard $(mydir)/src/*.js))
EXT = package.json LICENSE

# compilers/tools
node := /usr/bin/env node
m4 := /usr/bin/env m4
npm := /usr/bin/env npm
coffee := $(mydir)/node_modules/coffee-script/bin/coffee
coffeelint := $(mydir)/node_modules/coffeelint/bin/coffeelint
uglify := $(mydir)/node_modules/uglify-js/bin/uglifyjs

SUBDIRS = src

.PHONY: clean release all doc
all: deps ugly

deps:
	cd $(mydir); $(npm) install
	@touch deps

doc:
	$(foreach d,$(DOC),$(m4) $(d) $(rootdir)/wiki/$(d:.m4=.md);)

lint: style
	@touch lint

style:
	$(foreach f,$(SRC),sed -ri 's/\s+$$//' $(f);)
	@touch style

ugly: deps
	$(foreach f,$(SRC),$(uglify) $(f) > $(f:.js=.min.js);)
	@touch ugly

clean:
	echo $(SRC)
	$(foreach f,$(SRC:.js=.min.js),$(RM) $(f);)
	$(foreach t,deps ugly style,$(RM) $(t);)

release: deps ugly
	cd $(mydir); \
	  sed -i '1s/src/lib/' $(filter index%, $(SRC)); \
	  tar cf bebopt.tar $(SRC) $(EXT); \
	  sed -i 's/index/index.min/' package.json; \
	  tar czf bebopt.min.tar.gz $(SRC:.js=.min.js) $(EXT); \
	  sed -i 's/index[.]min/index/' package.json; \
	  git checkout void; \
	  git clean -e bebopt.tar -e bebopt.min.tar.gz -f; \
	  tar xf bebopt.tar; \
	  git add package.json LICENSE index.js lib; \
	  $(RM) -r node_modules; \
	  git clean -e bebopt.min.tar.gz -f
