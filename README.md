# foldout.vim

foldout provides an outline structure based on a hierarchy of headings. A
heading is a string like "/* ## Title */", consisting of an optional prefix
("/*") and suffix ("*/"), a string of heading symbols ("#"), and a title
("Title"). The number of heading symbols determines the heading level. The
default prefix and suffix are computed from 'commentstring', so in a code file,
you can create a heading by typing your language's comment prefix followed by
heading symbols, without any per-language configuration.

foldout provides syntax highlighting of headings, automatic folding based on
the outline structure, and an additional vim mode called navigation mode, which
provides quick navigation of the outline structure.

## Installation

Use your preferred installation method; for example, with
[vim-plug](https://github.com/junegunn/vim-plug), use:

```
Plug 'msuperdock/vim-foldout'
```

foldout can save and restore view data; this includes cursor position, open and
closed folds, and anything else provided by vim's `viewoptions` option. To
enable this, remove any calls to `mkview` and `loadview` in your `.vimrc` and
set `g:foldout_save`. (The `mkview` and `loadview` commands need to be called
in certain sequence with foldout commands, and foldout handles this for you.)
Consider also modifying `viewoptions`, which controls which view data is saved
and restored; for example:

```
let &viewoptions = 'folds,cursor'
let g:foldout_save = 1
```

To enable entering navigation mode, bind a key to the special key sequence
`<Plug>FoldoutNavigation`. Use `map` rather than `noremap` so that
`<Plug>FoldoutNavigation` can be further expanded; for example:

```
map <leader>n <Plug>FoldoutNavigation
```

foldout is automatically enabled by default in all buffers with non-empty file
names. You can change this using the `g:foldout_files` variable; see below.

## Bindings

On `<Plug>FoldoutNavigation`, foldout enters navigation mode; you will see
`-- NAVIGATION --` below the status bar, and the following bindings are active:

| key | function | description |
| --- | --- | --- |
| `h` | `foldout#parent()` | Go to parent heading. |
| `j` | `foldout#down()` | Go to next sibling heading. |
| `k` | `foldout#up()` | Go to previous sibling heading. |
| `l` | `foldout#child()` | Go to first child heading. |
| `gj` | `foldout#down_graphical()` | Go to next visible heading of any level. |
| `gk` | `foldout#up_graphical()` | Go to previous visible heading of any level. |
| `t` | `foldout#top()` | Go to first sibling heading. |
| `b` | `foldout#bottom()` | Go to last sibling heading. |
| `<tab>` | `foldout#toggle_fold` | Toggle fold at cursor. |
| `s` | `foldout#show()` | Open all folds. |
| `f` | `foldout#focus()` | Close all folds but those necessary to see cursor. |
| `c` | `foldout#center()` | Redraw so that cursor is vertically centered. |
| `a` | `foldout#append()` | Go to end of current section and enter insert mode. |
| `o` | `foldout#open()` | Create heading below and enter insert mode. |

To customize navigation mode bindings, foldout provides `foldout#map()` and
`foldout#unmap()` functions; use `:h foldout-map` or see the source at
`autoload/foldout.vim` for documentation. The above bindings are set in
`plugin/foldout.vim` using `foldout#map()`; this is a good reference for
customization.

If you don't want foldout to set any navigation mode bindings, set the
`g:foldout_bindings` variable to 0.

## Options

foldout provides the following option variables for configuration. The prefix
column indicates whether the option is a global option, a buffer-local option,
or both. Buffer-local options override global options where both are present.
You can set an option in your `.vimrc` using, for example:

```
let g:foldout_heading_symbol = '*'
```

| prefix | variable | default | description |
| --- | --- | --- | --- |
| `g` | `foldout_bindings` | 1 | Allow foldout to set navigation mode bindings. |
| `g` | `foldout_files` | `'?*'` | Pattern determining whether to enable foldout. |
| `g` | `foldout_save` | 0 | Allow foldout to save & restore view data. |
| `b`, `g` | `foldout_heading_symbol` | `'#'` | Repeated symbol indicating heading level. |
| `b`, `g` | `foldout_max_level` | 6 | Maximum allowed heading level. |
| `b`, `g` | `foldout_min_fold` | 1 | Minimum level at which to enable folding. |
| `b`, `g` | `foldout_append_pattern` | `'\@!'` | Pattern determining whether to insert empty line in `foldout#append()`. |
| `b`, `g` | `foldout_append_text` | `''` | Prefix text to insert in `foldout#append()`. |
| `b` | `foldout_heading_comment` | 1 | Highlight heading delimiters as comments. |
| `b` | `foldout_heading_string` | `commentstring` | Heading pattern, in `commentstring` format. |

Use the vim help files (e.g., `:h foldout_bindings`) for documentation.

## Functions

foldout provides the following functions, in addition to the functions bound in
navigation mode:

| function | description |
| --- | --- |
| `foldout#enable()` | Enable foldout in the current buffer. |
| `foldout#disable()` | Disable foldout in the current buffer. |
| `foldout#toggle()` | Toggle foldout in the current buffer. |
| `foldout#level()` | Get level of heading, or 0 if not at a heading. |
| `foldout#demote()` | Demote current heading. Don't change children. |
| `foldout#promote()` | Promote current heading. Don't change children. |
| `foldout#map(lhs, rhs)` | Map `lhs` to `rhs` in navigation mode. |
| `foldout#unmap(lhs)` | Unmap `lhs` in navigation mode. |
| `foldout#call(expr)` | Convenience function for creating mappings. |
| `foldout#tab()` | Demote if at heading, else simulate tab. |
| `foldout#shift_tab()` | Promote if at heading, else simulate shift-tab. |

The `foldout#tab()` and `foldout#shift_tab()` functions are designed to be
bound to tab and shift-tab in insert mode; for example:

```
inoremap <tab> <c-\><c-o>:silent call foldout#tab()<cr>
inoremap <s-tab> <c-\><c-o>:silent call foldout#shift_tab()<cr>
```

## Credits

foldout relies critically on two plugins:

- [vim-submode](https://github.com/kana/vim-submode): provides the framework
  for navigation mode.
- [FastFold](https://github.com/Konfekt/FastFold): makes certain folding
  operations much more efficient.

Both are slightly modified and packaged with foldout. If you like foldout, give
these plugins some love, too.
