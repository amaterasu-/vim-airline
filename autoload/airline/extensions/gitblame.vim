" MIT License. Copyright (c) 2013-2019 Doron Behar, C.Brabandt et al.
" vim: et ts=2 sts=2 sw=2

scriptencoding utf-8

"TODO - check dir for valid repo, and correct the timings

function! airline#extensions#gitblame#blame()
  if (!exists('g:airline#extensions#gitblame#lastline') ||
     \ !exists('g:airline#extensions#gitblame#rendered') ||
     \ !exists('g:airline#extensions#gitblame#runtime'))
    let g:airline#extensions#gitblame#rendered = 0
    let g:airline#extensions#gitblame#runtime = reltime()
    let g:airline#extensions#gitblame#lastline = line('.')
    let g:airline#extensions#gitblame#render = ''
  endif

  " Jump through some hoops to back off the timer here to prevent terminal corruption:
  if ( g:airline#extensions#gitblame#rendered == 0 &&
     \ line('.') == g:airline#extensions#gitblame#lastline &&
     \ (reltimefloat(reltime(g:airline#extensions#gitblame#runtime)) > 0.3))
    let g:airline#extensions#gitblame#rendered = 1
    let output = system('git -C "'.expand('%:p:h').'" rev-parse --is-inside-work-tree')
    if v:shell_error == 0
      let blame = trim(system('git -C "'.expand('%:p:h').'" blame ' . '-L' . line('.') . ',' . line('.') . ' -- "' . expand('%:t') . '"'))
      let g:airline#extensions#gitblame#render = substitute(substitute(blame, ' [0-9]*).*$', ')', 'g'), '^.*(', '(', 'g')
    else
      let g:airline#extensions#gitblame#render = '--'
    endif
  elseif (line('.') != g:airline#extensions#gitblame#lastline)
    " Line has changed, start the clock
    let g:airline#extensions#gitblame#rendered = 0
    let g:airline#extensions#gitblame#runtime = reltime()
    let g:airline#extensions#gitblame#lastline = line('.')
    let g:airline#extensions#gitblame#render = ''
  endif
  return g:airline#extensions#gitblame#render
endfunction

function! airline#extensions#gitblame#init(ext)
  call airline#parts#define_function('gitblame', 'airline#extensions#gitblame#blame')
endfunction
