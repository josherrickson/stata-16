md=$(shell find stata_markdown -name "*.md")
Stata_Rmd=$(md:.md=.Rmd)
md2=$(shell find stata_markdown -name "*.md" | sed 's.stata_markdown/..')
Stata_Ready=$(md2:.md=.Rmd)

stata_markdown/%.Rmd: stata_markdown/%.md
	@echo "$< -> $@"
	@/Applications/Stata/StataSE.app/Contents/MacOS/stata-se -b 'dyndoc "$<", saving("$@") replace nostop'
# Remove <p> at the front of sections
	@sed -E -i '' '/^\<p\>\^#/s/\<\/?p\>//g' $@
# Convert ^#^ to #
	@sed -i '' 's.\^#\^.#.g' $@
# Convert ^$^ to $ and ^$$^ to $$
	@sed -i '' 's.\^$$^.$$.g' $@
	@sed -i '' 's.\^$$$$\^.$$$$.g' $@
# This line makes all links open in new windows.
	@sed -i '' 's|href="|target="_blank" href="|g' $@

_book/index.html: index.Rmd $(Stata_Rmd)
	@echo "$< -> $@"
#	Get a list of Rmd files; we'll be temporarily copying them to the main directory
	@$(eval TMPPATH := $(shell find stata_markdown -name "*.Rmd"))
	@$(eval TMP := $(shell find stata_markdown -name "*.Rmd" | sed 's.stata_markdown/..'))
	@cp $(TMPPATH) .
	@Rscript -e "bookdown::render_book('$<', 'bookdown::gitbook')"
#	Remove any files copies up
	@rm -rf $(TMP)

default: $(Stata_Rmd)  _book/index.html

clean:
	@git clean -xdf

open:
	@open _book/index.html

publish:
	@mkdir -p ~/repositories/josherrickson.github.io/stata-16
	@cp -r _book/* ~/repositories/josherrickson.github.io/stata-16/.
