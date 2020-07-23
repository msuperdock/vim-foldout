" vim-foldout - Outline-based folding with syntax highlighting.
" Maintainer:   Matt Superdock
" Version:      1.0
" License:      MIT

if exists('g:foldout_loaded')
  finish
else
  let g:foldout_loaded = 1
endif

" ## Global options

" Pattern matched against file names to determine whether to enable foldout. If
" the empty string, foldout is never automatically enabled. Defaults to `?*`,
" which matches all non-empty strings.
if !exists('g:foldout_files')
  let g:foldout_files = '?*'
endif

" Indicates whether to let foldout handle saving and loading view data.
" If 1, foldout calls `loadview` and `mkview` at the appropriate times in
" buffers where foldout is enabled, to save view data (like folds & cursor
" position) according to the value of the `viewoptions` option.
" If 0, foldout does not save or load view data. In this case, it is
" recommended not to use `loadview` and `mkview` at all, since calling these
" commands must be done in a particular order relative to foldout commands.
" Defaults to 0.
if !exists('g:foldout_save')
  let g:foldout_save = 0
endif

" ## Buffer options

" Each of these options has a global variable and a buffer-local variable
" (prefixed by `b` instead of `g`). The buffer-local variable takes precedence;
" the global variable serves as a default across all buffers.

" A one-character string representing the repeated character in headings.
if !exists('g:foldout_heading_symbol')
  let g:foldout_heading_symbol = '#'
elseif len(g:foldout_heading_symbol) != 1
  throw 'g:foldout_heading_symbol must have length 1.'
endif

" The upper limit on the number of heading levels; defaults to 6.
if !exists('g:foldout_max_level')
  let g:foldout_max_level = 6
endif

" The first level at which to enable folding; defaults to folding all levels.
if !exists('g:foldout_min_fold')
  let g:foldout_min_fold = 1
endif

" Pattern matched against last line of section in `foldout#append`. If it
" matches, an empty line is inserted before appending text. The default value
" matches nothing, so that an empty line is always inserted.
if !exists('g:foldout_append_pattern')
  let g:foldout_append_pattern = '\@!'
endif

" Prefix text to insert in `foldout#append`; defaults to an empty line.
if !exists('g:foldout_append_text')
  let g:foldout_append_text = ''
endif

" ## Enable

" Enable foldout in files according to `g:foldout_files` setting.
if g:foldout_files != ''
  execute 'autocmd BufWinEnter ' . g:foldout_files . ' call foldout#enable()'
endif

" Enable saving view data in files according to `g:foldout_files` setting.
if g:foldout_files != '' && g:foldout_save
  " The `loadview` must occur after foldout#enable(), or folds are lost.
  " We set `foldmethod` to `syntax`, since FastFold changes it to `manual`.
  execute 'autocmd BufWinEnter ' . g:foldout_files . ' silent! loadview'
  execute 'autocmd BufWinLeave ' . g:foldout_files 
    \ . " let &l:foldmethod = 'syntax'"
  execute 'autocmd BufWinLeave ' . g:foldout_files . ' mkview'
endif

