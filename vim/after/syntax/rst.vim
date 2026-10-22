" Enable concealing globally for this buffer
setlocal conceallevel=2

" Functions are taken from 'syntax/rst.vim' and are modified to enable
" concealment.

"" Inline Markup ""

function! s:DefineOneConcealInlineMarkup(name, start, middle, end, char_left, char_right)
  " Only escape the first char of a multichar delimiter (e.g. \* inside **)
  if a:start[0] == '\'
    let first = a:start[0:1]
  else
    let first = a:start[0]
  endif

  if a:start != '``'
    let rst_contains=' contains=@Spell,rstEscape' . a:name
    execute 'syn match rstEscape'.a:name.' +\\\\\|\\'.first.'+'.' contained'
  else
    let rst_contains=' contains=@Spell'
  endif

  execute 'syn region rst' . a:name .
        \ ' matchgroup=rstSurroundingChars'.
        \ ' start=+' . a:char_left . '\zs' . a:start .
        \ '\ze[^[:space:]' . a:char_right . a:start[strlen(a:start) - 1] . ']+' .
        \ a:middle .
        \ ' end=+' . a:end . '\ze\%($\|\s\|[''"’)\]}>/:.,;!?\\-]\)+' .
        \ ' concealends'.
        \ rst_contains

  if a:start != '``'
    execute 'hi def link rstEscape'.a:name.' Special'
  endif
endfunction

function! s:DefineConcealInlineMarkup(name, start, middle, end)
  if a:middle == '`'
    let middle = ' skip=+\s'.a:middle.'+'
  else
    let middle = ' skip=+\\\\\|\\' . a:middle . '\|\s' . a:middle . '+'
  endif

  " Some characters may precede or follow an inline token
  call s:DefineOneConcealInlineMarkup(a:name, a:start, middle, a:end, "'", "'")
  call s:DefineOneConcealInlineMarkup(a:name, a:start, middle, a:end, '"', '"')
  call s:DefineOneConcealInlineMarkup(a:name, a:start, middle, a:end, '(', ')')
  call s:DefineOneConcealInlineMarkup(a:name, a:start, middle, a:end, '\[', '\]')
  call s:DefineOneConcealInlineMarkup(a:name, a:start, middle, a:end, '{', '}')
  call s:DefineOneConcealInlineMarkup(a:name, a:start, middle, a:end, '<', '>')
  call s:DefineOneConcealInlineMarkup(a:name, a:start, middle, a:end, '’', '’')

  " TODO: Additional whitespace Unicode characters: Pd, Po, Pi, Pf, Ps
  call s:DefineOneConcealInlineMarkup(a:name, a:start, middle, a:end, '\%(^\|\s\|\%ua0\|[/:]\)', '')

  execute 'syn match rst' . a:name .
        \ ' +\%(^\|\s\|\%ua0\|[''"([{</:]\)\zs' . a:start .
        \ '[^[:space:]' . a:start[strlen(a:start) - 1] . ']'
        \ a:end . '\ze\%($\|\s\|[''")\]}>/:.,;!?\\-]\)+'

  execute 'hi def link rst' . a:name . 'Delimiter' . ' rst' . a:name
endfunction

call s:DefineConcealInlineMarkup('Emphasis', '\*', '\*', '\*')
call s:DefineConcealInlineMarkup('StrongEmphasis', '\*\*', '\*', '\*\*')
call s:DefineConcealInlineMarkup('InlineLiteral', '``', '', '``')

"hi rstInlineLiteral ctermfg=blue

" Ensure the surrounding hidden characters link to standard hiding rules
highlight link rstSurroundingChars Ignore


" For leading '*' in front of C comments
if &comments !~ 'mb:\*'
	setlocal comments+=s1:/*,mb:*,ex:*/
endif
setlocal cinoptions+=j0,c1
setlocal indentkeys-=o
setlocal indentkeys-=O

setlocal softtabstop=3
setlocal shiftwidth=3
setlocal expandtab
