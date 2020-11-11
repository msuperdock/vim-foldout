" ## Enable

" Enable foldout in the current buffer. If called while foldout is already
" enabled, apply current values of the buffer option variables.
function foldout#enable()
  " Set variable indicating that foldout is enabled.
  let b:foldout_enabled = 1

  " Set buffer-local variables to global defaults if not already defined.

  " Indicate whether to highlight heading delimiters as comments.
  if !exists('b:foldout_heading_comment')
    let b:foldout_heading_comment
      \ = &filetype == 'markdown' ? 0 : 1
  endif

  if !exists('b:foldout_heading_ignore')
    let b:foldout_heading_ignore = '\@!'
  endif

  " Use '%s' as default if comment string is unchanged or empty.
  if !exists('b:foldout_heading_string')
    let b:foldout_heading_string
      \ = &filetype == 'markdown' ? '%s'
      \ : &l:commentstring ==# '/*%s*/' ? '%s'
      \ : &l:commentstring ==# '' ? '%s'
      \ : &l:commentstring
  endif

  if !exists('b:foldout_heading_symbol')
    let b:foldout_heading_symbol = g:foldout_heading_symbol
  endif

  if !exists('b:foldout_append_text')
    let b:foldout_append_text = g:foldout_append_text
  endif

  if !exists('b:foldout_append_pattern')
    let b:foldout_append_pattern = g:foldout_append_pattern
  endif

  if !exists('b:foldout_max_level')
    let b:foldout_max_level = g:foldout_max_level
  endif

  if !exists('b:foldout_min_fold')
    let b:foldout_min_fold = g:foldout_min_fold
  endif

  " Save old values of `fillchars`, `foldmethod`, and `foldtext`.
  let s:fillchars_old = &l:fillchars
  let s:foldlevel_old = &l:foldlevel
  let s:foldmethod_old = &l:foldmethod
  let s:foldtext_old = &l:foldtext

  " Set values of fold-related options if necessary.
  if &l:fillchars !=# s:fillchars
    let &l:fillchars = s:fillchars
  endif

  if &l:foldlevel != s:foldlevel
    let &l:foldlevel = s:foldlevel
  endif

  if &l:foldmethod !=# s:foldmethod
    let &l:foldmethod = s:foldmethod
  endif

  if &l:foldtext !=# s:foldtext
    let &l:foldtext = s:foldtext
  endif

  augroup foldout
    autocmd!

    " Needed for multiple-line matches.
    autocmd Syntax * syntax sync fromstart

    " Compute list of sections up to maximum level.
    let l:heading_list = 'foldoutHeadingLine1'
    for l:i in range(2, b:foldout_max_level)
      let l:heading_list .= ',foldoutHeadingLine' . l:i
    endfor

    " Match the whole file, which contains foldoutContent & foldoutChildren.
    execute 'autocmd Syntax * syntax region foldoutFile start="\%^" end="\%$" '
      \ . 'contains=foldoutContent,foldoutChildren'

    " Match the region from the beginning of a section, either after a heading
    " or at the beginning of the file, to the first subheading.
    execute 'autocmd Syntax * syntax region foldoutContent '
      \ . 'start="\_." end=' . s:quote(s:zero_width(s:pattern_any())) . ' '
      \ . 'contains=TOP contained keepend nextgroup=foldoutChildren'

    " Match the region from the first child heading through the end of the last
    " child section, including from the first top-level heading to end of file.
    execute 'autocmd Syntax * syntax region foldoutChildren '
      \ . 'start=' . s:quote(s:pattern_any()) . ' end="\%$" '
      \ . 'contains=' . l:heading_list . ' contained'

    " Match heading, which may be just the initial part of the heading line.
    execute 'autocmd Syntax * syntax region foldoutHeading '
      \ . 'matchgroup=foldoutHeadingDelimiter '
      \ . 'start=' . s:quote(s:pattern_start()) . ' '
      \ . 'end=' . s:quote(s:pattern_end()) . ' '
      \ . 'contained'

    " Highlight foldout headings as titles.
    execute 'autocmd Syntax * highlight! default link foldoutHeading Title'

    " Highlight delimiters of headings as comments, if option is set.
    if b:foldout_heading_comment
      execute 'autocmd Syntax * highlight! default link '
        \ . 'foldoutHeadingDelimiter Comment'
    endif

    " Execute syntax commands to recognize various heading levels.
    for l:i in range(1, b:foldout_max_level)
      execute 'autocmd Syntax * syntax match foldoutHeadingLine' . l:i . ' '
        \ . s:quote(s:pattern_exact('.*', l:i)) . ' '
        \ . 'nextgroup=foldoutBody' . l:i . ' '
        \ . 'contains=foldoutHeading '
        \ . 'contained keepend skipnl'
      execute 'autocmd Syntax * syntax match foldoutHeadingLine' . l:i . ' '
        \ . s:quote(s:pattern_exact(b:foldout_heading_ignore, l:i)) . ' '
        \ . 'nextgroup=foldoutBodyPlain' . l:i . ' '
        \ . 'contains=foldoutHeading '
        \ . 'contained keepend skipnl'
      execute 'autocmd Syntax * syntax region foldoutBody' . l:i . ' '
        \ . 'start="\_." end=' . s:quote(s:zero_width(s:pattern_max(l:i))) . ' '
        \ . 'contains=foldoutContent'
        \ . (l:i < b:foldout_max_level ? ',foldoutChildren ' : ' ')
        \ . (l:i >= b:foldout_min_fold ? 'fold ' : '')
        \ . 'contained keepend'
      execute 'autocmd Syntax * syntax region foldoutBodyPlain' . l:i . ' '
        \ . 'start="\_." end=' . s:quote(s:zero_width(s:pattern_max(l:i))) . ' '
        \ . 'contains=NONE '
        \ . (l:i >= b:foldout_min_fold ? 'fold ' : '')
        \ . 'contained keepend'
    endfor
  augroup END

  " Make sure syntax changes take effect.
  do Syntax
endfunction

" Disable foldout in the current buffer.
function foldout#disable()
  " Set variable indicating that foldout is disabled.
  let b:foldout_enabled = 0

  " Unmap the binding entering navigation mode. (`unmap` doesn't seem to work.)
  nmap <plug>FoldoutNavigation <nop>

  " Restore old value of `fillchars` if unchanged.
  if exists(s:fillchars_old)
    \ && &l:fillchars !=# s:fillchars_old
    \ && &l:fillchars ==# s:fillchars

    let &l:fillchars = s:fillchars_old
  endif

  " Restore old value of `foldlevel` if unchanged.
  if exists(s:foldlevel_old)
    \ && &l:foldlevel != s:foldlevel_old
    \ && &l:foldlevel == s:foldlevel

    let &l:foldlevel = s:foldlevel_old
  endif

  " Restore old value of `foldmethod` if unchanged.
  if exists(s:foldmethod_old)
    \ && &l:foldmethod !=# s:foldmethod_old
    \ && &l:foldmethod ==# s:foldmethod

    let &l:foldmethod = s:foldmethod_old
  endif

  " Restore old value of `foldtext` if unchanged.
  if exists(s:foldtext_old)
    \ && &l:foldtext !=# s:foldtext_old
    \ && &l:foldtext ==# s:foldtext

    let &l:foldtext = s:foldtext_old
  endif

  " Remove autocommands related to syntax highlighting.
  augroup foldout
    autocmd!
  augroup END

  " Recompute syntax highlighting.
  do Syntax
endfunction

" Enable or disable foldout.
function foldout#toggle()
  if b:foldout_enabled
    call foldout#disable()
  else
    call foldout#enable()
  endif
endfunction

" ## Headings

" Determine the current heading level at the given line, or at the cursor if no
" argument is given. Return 0 if not at a heading.
function foldout#level(...)
  let l:line = get(a:, 1, '.')
  let l:match = matchend(getline(l:line), s:pattern_any(2))
  return l:match >= 0 ? l:match - s:prefix_length() : 0
endfunction

" If at a heading, demote the heading. Do not change the child headings.
function foldout#demote()
  let l:level = foldout#level()

  " Handle cases where heading cannot be demoted.
  if l:level == 0
    echo 'Not at a heading.'
    return
  elseif l:level == b:foldout_max_level
    echo 'Heading already at maximum level.'
    return
  end

  " Store current column before modifying heading.
  let l:col = col('.')

  " Add an additional heading symbol.
  let l:line = getline('.')
  let l:index = matchend(l:line, s:pattern_start())
  call setline(line('.'), l:line[0 : l:index - 1] . b:foldout_heading_symbol
    \ . l:line[l:index :])

  " Keep cursor in place if at left margin, otherwise move one space right.
  call cursor(line('.'), l:col == 1 ? 1 : l:col + 1)
endfunction

" If at a heading, promote the heading. Do not change the child headings.
function foldout#promote()
  let l:level = foldout#level()

  " Handle cases where heading cannot be promoted.
  if l:level == 0
    echo 'Not at a heading.'
    return
  elseif l:level == 1
    echo 'Heading already at top level.'
    return
  end

  " Store current column before modifying heading.
  let l:col = col('.')

  " Delete one of the heading symbols.
  let l:line = getline('.')
  let l:index = matchend(l:line, s:pattern_start())
  call setline(line('.'), l:line[0 : l:index - 2] . l:line[l:index :])
  call cursor(line('.'), l:col - 1)
endfunction

" ## Navigation

" Go to previous sibling heading, if at a heading and if there is one.
function foldout#up()
  let l:level = foldout#level()
  if l:level
    if s:up_helper(l:level)
      echo 'No heading above.'
    endif
  else
    echo 'Not at a heading.'
  endif
endfunction

" Go to previous sibling heading, if at a heading and if there is one.
" Assume cursor is at heading. Return 0 if successful, 1 if no heading found.
function s:up_helper(level)
  let l:line = line('.')
  let l:col = col('.')
  call cursor(l:line, 1)
  let l:match = search(s:pattern_max(a:level), 'bnW')
  if l:match && foldout#level(l:match) == a:level
    call cursor(l:match, 1)
  else
    call cursor(l:line, l:col)
    return 1
  endif
endfunction

" Go to previous visible heading, if there is one.
function foldout#up_graphical()
  let l:line = line('.')
  let l:col = col('.')

  " Move down to next line.
  call cursor(l:line - 1, 1)
  
  while 1
    let l:next = search(s:pattern_any(), 'bcW')

    " If no heading below, return.
    if l:next == 0
      call cursor(l:line, l:col)
      echo 'No heading above.'
      return
    endif

    let l:start = foldclosed(l:next)

    " If current heading is visible, return.
    if l:start < 0
      return
    else
      call cursor(l:start - 1, 1)
    endif
  endwhile
endfunction

" Go to next sibling heading, if at a heading and if there is one. If not at a
" heading, go to the next heading if it is a first child.
function foldout#down()
  let l:level = foldout#level()
  if l:level
    if s:down_helper(l:level)
      echo 'No heading below.'
    endif

  else
    let l:parent = search(s:pattern_any(), 'bnW')
    let l:heading = search(s:pattern_any(), 'nW')
    let l:parent_level = l:parent == 0 ? 0 : foldout#level(l:parent)
    let l:heading_level = foldout#level(l:heading)

    if l:heading == 0
      echo 'No heading below.'
      return
    endif

    if l:heading_level > l:parent_level
      call cursor(l:heading, 1)
    else
      echo 'No heading below.'
    endif

  endif
endfunction

" Go to the next sibling heading, if at a heading and if there is one. Assume
" cursor is at heading. Return 0 if successful, 1 if no heading found.
function s:down_helper(level)
  let l:match = search(s:pattern_max(a:level), 'nW')
  if l:match && foldout#level(l:match) == a:level
    call cursor(l:match, 1)
  else
    return 1
  endif
endfunction

" Go to next visible heading, if there is one.
function foldout#down_graphical()
  let l:line = line('.')
  let l:col = col('.')

  " Move down to next line.
  call cursor(l:line + 1, 1)
  
  while 1
    let l:next = search(s:pattern_any(), 'cW')

    " If no heading below, return.
    if l:next == 0
      call cursor(l:line, l:col)
      echo 'No heading below.'
      return
    endif

    let l:end = foldclosedend(l:next)

    " If current heading is visible, return.
    if l:end < 0
      return
    else
      call cursor(l:end + 1, 1)
    endif
  endwhile
endfunction

" Go to first sibling if at a heading, else to beginning of section.
function foldout#top()
  let l:level = foldout#level()

  " If at a heading, go to first sibling.
  if l:level
    while s:up_helper(level) == 0
    endwhile

  " Otherwise, go to beginning of section.
  else
    let l:line = line('.')
    let l:heading = search(s:pattern_any(), 'bnW')

    " Go to line after previous heading, or first line if no heading below.
    call cursor(l:heading ? l:heading + 1 : 1, 1)

    let l:match = search('^.', 'cnW')
    if l:match
      call cursor(l:match, 1)
    else
      call cursor(l:line, 1)
    endif

  endif
endfunction

" Go to last sibling if at a heading, else to end of section.
function foldout#bottom()
  let l:level = foldout#level()

  " If at a heading, go to last sibling.
  if l:level
    while s:down_helper(level) == 0
    endwhile

  " Otherwise, go to end of section.
  else
    let l:line = line('.')
    let l:heading = search(s:pattern_any(), 'nW')

    " Go to line before next heading, or last line if no heading below.
    if l:heading
      call cursor(l:heading - 1, 1)
    else
      call cursor(search('\%$', 'nW'), 1)
    endif

    let l:match = search('^.', 'bcnW')
    if l:match
      call cursor(l:match, 1)
    else
      call cursor(l:line, 1)
    endif

  endif
endfunction

" Go to parent heading, if there is one.
function foldout#parent()
  let l:level = foldout#level()
  
  " If cursor is not at a heading, go up to the nearest heading.
  if l:level == 0
    if search(s:pattern_any(), 'bW') == 0
      echo 'No parent heading.'
    endif

  " If cursor is at a heading not at the top level, go to its parent.
  elseif l:level > 1
    let l:line = line('.')
    let l:col = col('.')
    call cursor(l:line, 1)
    let l:match = search(s:pattern_max(l:level - 1), 'bnW')
    if l:match
      call cursor(l:match, 1)
    else
      call cursor(l:line, l:col)
      echo 'No parent heading.'
    endif

  " If cursor is at a top level heading, do nothing.
  else
    echo 'No parent heading.'

  endif
endfunction

" Go to first nonempty line inside a heading, if there is one.
function foldout#child()
  let l:level = foldout#level()
  if l:level == 0
    echo 'Not at a heading.'
    return
  endif

  let l:match = search('^.', 'nW')
  if l:match == 0
    echo 'No content under heading.'
    return
  endif

  let l:heading = foldout#level(l:match)
  if l:heading == 0 || l:heading > l:level
    call cursor(l:match, 1)
    normal! zv
  else
    echo 'No content under heading.'
  endif
endfunction

" Search for the given heading at the given level; go to heading if found.
" The optional argument indicates whether to enter the section.
" Return 1 if heading is not found, 0 otherwise.
function foldout#goto(name, level, ...)
  let [l:prefix, l:suffix] = s:heading_split()
  let l:pattern = '^'
    \ . s:escape(l:prefix)
    \ . repeat(b:foldout_heading_symbol, a:level)
    \ . '\s\+' . a:name . '\s*'
    \ . s:escape(l:suffix)
    \ . '.*$'

  if search(l:pattern, 'c') == 0
    echo a:name . ' section not found.'
    return 1
  elseif a:0 >= 1 && a:1
    call foldout#child()
  endif
endfunction

" ## Folding

" Toggle current fold, moving down one line if at a header.
function foldout#toggle_fold()
  try
  if foldout#level() > 0
    FastFoldUpdate
    execute "silent normal! jzak"
  else
    FastFoldUpdate
    execute "silent normal! za"
  endif
  catch
    " Handle fold error more gracefully.
    echo 'No fold found.'
    return
  endtry
endfunction

" Show all folds in buffer.
function foldout#show()
  %foldopen!
endfunction

" Focus the cursor by closing all other folds.
function foldout#focus()
  do Syntax
  silent! %foldclose!
  normal! zv

  if foldout#level() > 0
    FastFoldUpdate
    execute "silent normal! jzak"
  endif
endfunction

" Center the cursor vertically, without moving the cursor.
function foldout#center()
  normal! zz
endfunction

" ## Insertion

" Append a new line to the end of the current section, enter insert mode.
function foldout#append()
  " Find `end`, the last line of the current section, and move cursor there.
  let l:heading = search(s:pattern_any(), 'nW')
  let l:end = l:heading ? l:heading - 1 : search('\%$', 'nW')
  call cursor(l:end, 1)

  " Find `text`, the last nonempty line up to and including `end`.
  let l:text = search('^.', 'bcW')

  " Determine whether we will need to add an extra line afterwards.
  let l:after = l:heading && l:text == l:end

  " Add an empty line if this line has text other than a list item.
  if l:text && getline('.') !~ b:foldout_append_pattern
    call append(l:text, '')
    let l:text += 1
  endif

  " Append new list item.
  call append(l:text, b:foldout_append_text)

  " Append extra line afterwards if necessary.
  if l:after
    call append(l:text + 1, '')
  endif

  " Enter insert mode, and put the cursor at the end of the new item.
  startinsert
  call cursor(l:text + 1, len(b:foldout_append_text) + 1)

  " Make sure cursor is visible; return cursor to end of the line.
  normal! zv
  call cursor(l:text + 1, len(b:foldout_append_text) + 1)
endfunction

" Open a new heading line, meant as the foldout analogue of `o`.
" The optional argument indicates whether to always insert at the cursor.
" The default behavior is to insert at the end of a section.
function foldout#open(...)
  let l:cursor = a:0 >= 1 && a:1
  let l:line = line('.')
  let l:level = foldout#level()

  " If not at a heading, move cursor to previous heading.
  " `l:top` represents whether the cursor is above the first heading.
  let l:top = l:level == 0 && search(s:pattern_any(), 'bW') == 0

  " If above all headings, return without doing anything.
  if !l:cursor && l:top
    echo 'Not at a heading.'
    return
  endif

  " Compute level for the new heading.
  let l:new_level = l:level ? l:level : foldout#level() + 1

  " Make sure we don't create a heading with level over the allowed maximum.
  if l:new_level > b:foldout_max_level
    echo 'At maximum outline level.'
    return
  endif

  " Compute line below which to add the new heading, as `l:line`.
  if !l:cursor
    " Compute pattern marking end of the relevant section.
    let l:pattern = l:level ? s:pattern_max(l:level) : s:pattern_any()

    " Find the heading marking the end of the relevant section.
    let l:heading = search(l:pattern, 'nW')

    " Compute `line`, the last line of the relevant section.
    let l:line = l:heading ? l:heading - 1 : line('$')
  endif

  " Create new heading at bottom of section; add blank lines if appropriate.
  let l:before = getline(l:line) != ''
  let l:after = getline(l:line + 1) != ''
  call append(l:line, (l:before ? [''] : []) + [s:heading_text(l:new_level)]
    \ + (l:after ? [''] : []))
  
  " Enter insert mode and move cursor to end of line.
  startinsert
  call cursor(l:line + (l:before ? 2 : 1), s:heading_pos(l:new_level))
endfunction

" Demote heading if at a heading, otherwise simulate tab.
" Designed to be bound to `<tab>` in insert mode.
function foldout#tab()
  if foldout#level() > 0 && col('.') <= s:heading_pos(foldout#level())
    call foldout#demote()
  else
    call feedkeys("\<tab>", 'n')
  endif
endfunction

" Promote heading if at a heading, otherwise simulate shift-tab.
" Designed to be bound to `<shift-tab>` in insert mode.
function foldout#shift_tab()
  if foldout#level() > 0 && col('.') <= s:heading_pos(foldout#level())
    call foldout#promote()
  else
    call feedkeys("\<s-tab>", 'n')
  endif
endfunction

" ## Query

" View the stack of syntax groups at the cursor. Modified from
" https://stackoverflow.com/questions/9464844/how-to-get-group-name-of-highlighting-under-cursor-in-vim.
function foldout#syntax()
  if exists("*synstack")
    let l:g = synIDattr(synIDtrans(synID(line('.'), col('.'), 1)), 'name')
    let l:s = map(synstack(line('.'), col('.')), 'synIDattr(v:val, "name")')
    echo (l:g ==# '' ? '(none)' : join(l:s, ', ') . ' -> ' . l:g)
  else
    echo '(none)'
  endif
endfunction

" ## Defaults

" Store default foldout values of fillchars & foldtext.
let s:fillchars = 'fold: '
let s:foldlevel = 99
let s:foldmethod = 'syntax'
let s:foldtext = 'foldout#fold_text()'

" Trivial string-valued function for the `foldtext` option. Note that it is not
" possible to make this a script-local function.
function foldout#fold_text()
  return ''
endfunction

" ## Utilities

" ### Wrapping strings

" Create a pattern that matches exactly the given string, by escaping chars.
function s:escape(str)
  " Backslash must come first to not interfere with other substitutions.
  let l:chars = ['\', '*', '^', '$', '.', '~', '[', ']']

  " Convert special characters into escape sequences, one by one.
  let l:str = a:str
  for l:char in l:chars
    let l:str = substitute(l:str, '\' . l:char, '\\' . l:char, 'g')
  endfor

  return l:str
endfunction

" Wrap a pattern within an appropriate character, for syntax commands.
function s:quote(pattern)
  " Characters usable as pattern delimiters, in rough order of preference.
  let l:chars =
    \ [ '"', "'", '`', '/', '+', '~', '!', '@', '#', '$', '%', '^', '&', '*'
    \ , '(', ')', '-', '_', '=', '[', '{', ']', '}', '|', ';', ':', ',', '<'
    \ , '.', '>', '?'
    \ ]
  
  " Find the first character that doesn't appear in the given string.
  for l:char in l:chars
    if match(a:pattern, '\V' . l:char) < 0
      return l:char . a:pattern . l:char
    endif
  endfor
endfunction

" Convert a pattern into a zero-width pattern.
function s:zero_width(pattern)
  return '\ze\(' . a:pattern . '\)'
endfunction

" ### Heading text

" Compute the heading prefix & suffix from the heading string, return as list.
" Include a space after prefix if nonempty, and before suffix if nonempty.
function s:heading_split()
  " Compute index after `%s` in the heading string.
  let l:split_index = matchend(b:foldout_heading_string, '%s')
  if l:split_index < 0
    throw "b:foldout_heading_string must contain '%s' substring."
  endif

  " Split the heading string into its prefix & suffix.
  let l:prefix = l:split_index > 2
    \ ? b:foldout_heading_string[: l:split_index - 3] : ''
  let l:suffix = b:foldout_heading_string[l:split_index :]
  
  " Add space after prefix if nonempty, and before suffix if nonempty.
  return
    \ [ l:prefix == '' || l:prefix[-1:] ==# ' ' ? l:prefix : l:prefix . ' '
    \ , l:suffix == '' || l:suffix[0]   ==# ' ' ? l:suffix : ' '. l:suffix
    \ ]
endfunction

" Compute the appropriate cursor position for editing new heading.
function s:heading_pos(level)
  return s:prefix_length() + a:level + 2
endfunction

" Compute the text for a heading of the given level.
function s:heading_text(level)
  let [l:prefix, l:suffix] = s:heading_split()
  return l:prefix . repeat(b:foldout_heading_symbol, a:level) . ' ' . l:suffix
endfunction

" Compute the length of the heading prefix.
function s:prefix_length()
  return len(s:heading_split()[0])
endfunction

" ### Heading patterns

" Compute the heading prefix & suffix patterns, return as list.
" The prefix pattern matches everything up to the heading symbols.
" The suffix pattern matches everything after the heading symbols.
" Include a space after prefix if nonempty, and before suffix if nonempty.
" Takes a pattern to match the heading against.
" With optional flag, include a `\ze` after the caret.
function s:pattern_split(heading, ...)
  let [l:prefix, l:suffix] = s:heading_split()

  let l:prefix_pattern
    \ = '^\s*'
    \ . s:escape(l:prefix)
  let l:suffix_pattern
    \ = (get(a:, 1, 0) ? '\ze' : '')
    \ . ' '
    \ . a:heading
    \ . s:escape(l:suffix)
    \ . '.*$'

  return [l:prefix_pattern, l:suffix_pattern]
endfunction

" Compute a pattern representing a heading of exactly the given level.
" The pattern expects a space character after the prefix if prefix nonempty.
" The pattern expects a space character before the suffix if suffix nonempty.
" Takes a pattern to match the heading against.
" With optional flag, include a `\ze` after the caret.
function s:pattern_exact(heading, level, ...)
  let [l:prefix, l:suffix] = s:pattern_split(a:heading, get(a:, 1, 0))
  return l:prefix . repeat(b:foldout_heading_symbol, a:level) . l:suffix
endfunction

" A pattern representing a top-level heading.
" With optional flag, include a `\ze` after the caret.
function s:pattern_top(...)
  return s:pattern_exact('.*', 1, get(a:, 1, 0))
endfunction

" Compute a pattern representing a heading of at most the given level.
" With optional flag, include a `\ze` after the caret.
function s:pattern_max(level, ...)
  if a:level == 1
    return s:pattern_top(get(a:, 1, 0))
  endif

  let [l:prefix, l:suffix] = s:pattern_split('.*', get(a:, 1, 0))
  return l:prefix
    \ . b:foldout_heading_symbol
    \ . '\%[' . repeat(b:foldout_heading_symbol, a:level - 1) . ']'
    \ . l:suffix
endfunction

" A pattern representing a heading of any level.
" With optional flag, include a `\ze` after the caret.
function s:pattern_any(...)
  return s:pattern_max(b:foldout_max_level, get(a:, 1, 0))
endfunction

" A pattern representing the start of a heading of any level, up to the title.
function s:pattern_start()
  return s:pattern_split('.*')[0]
    \ . b:foldout_heading_symbol
    \ . '\%[' . repeat(b:foldout_heading_symbol, b:foldout_max_level - 1) . ']'
    \ . '\ze '
endfunction

" A pattern representing the end of a heading of any level, after the title.
function s:pattern_end()
  let [l:prefix, l:suffix] = s:heading_split()
  let l:pattern = l:suffix == '' ? '$' : ' \zs' . s:escape(l:suffix[1:])
  return l:pattern
endfunction

