" Highlight liquid syntax in markdown file (for Github Jekyll)

" 1. Temporarily un-define the syntax guard to bypass Vim 9.1's lock
unlet! b:current_syntax

" 2. Explicitly pull in the Liquid syntax engine
runtime! syntax/liquid.vim

" 3. Tell Vim's markdown regions to allow Liquid tags inside them
syn cluster markdownExpression add=liquidRegion,liquidStatement,liquidTag,liquidVar
syn cluster markdownInline     add=liquidRegion,liquidStatement,liquidTag,liquidVar

" 4. Restore the overall syntax block tracking variable
let b:current_syntax = "markdown.liquid"
