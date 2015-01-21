# convenience variables
mkfile_path := $(abspath $(lastword $(MAKEFILE_LIST)))
mydir := $(abspath $(lastword $(dir $(MAKEFILE_LIST))))
cwd := $(notdir $(patsubst %/,%,$(dir $(mkfile_path))))

# source code
DOC := $(wildcard $(mydir)/src/*.m4)
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

.PHONY: clean release all doc publish expand-doc test
all: build doc

build: deps ugly test

deps:
	cd $(mydir); $(npm) install
	@touch deps

%.md : %.m4
	$(m4) -I $(mydir)/src -P $< > $@

doc: $(DOC:.m4=.md)

publish: $(DOC:.m4=.md)
	$(foreach d,$(DOC:.m4=.md),git add $(d:.md=.m4); git commit -m '.'; mv $(d) $(mydir)/wiki/"$(notdir $(subst -, ,$(d)))";)
	$(foreach d,$(DOC:.m4=.md),cd $(mydir)/wiki/; git add $(mydir)/wiki/"$(notdir $(subst -, ,$(d)))"; git commit -m '.'; git push;)

lint: style
	@touch lint

style:
	$(foreach f,$(SRC),sed -ri 's/\s+$$//' $(f);)
	@touch style

ugly: $(SRC:.js=.min.js)

%.min.js : %.js
	$(uglify) $< > $@

clean:
	$(foreach f,$(SRC:.js=.min.js),$(RM) $(f);)
	$(foreach f,$(DOC:.m4=.md),$(RM) $(f);)
	$(foreach f,$(DOC:.m4=.html),$(RM) $(f);)
	$(foreach t,deps ugly style doc,$(RM) $(t);)
	$(RM) $(mydir)/test/test.sh

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

%.sh : %.m4
	$(m4) -P $(@:.sh=.m4) > $@;

check: $(mydir)/test/test.sh
	bash $(mydir)/test/test.sh

test: $(mydir)/test/test.sh
