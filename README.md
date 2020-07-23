# vim-foldout

![demo](https://github.com/msuperdock/vim-foldout/raw/master/demo.gif)

foldout is an outline-based folding plugin for vim & neovim. Its unique feature
is that folds are determined by Markdown-style headings within comments, and
these headings are automatically highlighted. foldout also provides a suite of
functions for manipulating and navigating between headings.

foldout uses vim's `commentstring` option to compute default heading patterns.
As a result, in a code file, if you're using a language-specific plugin that
sets `commentstring`, no further configuration is necessary. Just type the
language's comment prefix, then a string of heading symbols (by default, `#`),
and foldout will recognize a heading.

## Installation

Use your preferred installation method; for example, with
[vim-plug](https://github.com/junegunn/vim-plug), use:

```
Plug 'msuperdock/vim-foldout'
```

If your `.vimrc` uses `mkview` or `loadview` to save and restore view data,
remove these commands and set `g:foldout_save`. (The `mkview` and `loadview`
commands need to be called in certain sequence with foldout commands, and
foldout handles this for you.) For example:

```
let g:foldout_save = 1
```

By default, foldout is automatically enabled in all buffers whose filenames
contain a dot (see option `g:foldout_files` to customize this), and can be
manually enabled & disabled using `:call foldout#enable()`,
`:call foldout#disable()`, and `call foldout#toggle()`.

## Functions

foldout provides the following functions. You can bind a key to a function in
your `.vimrc` using, for example:

```
noremap <silent> <tab> :call foldout#toggle_fold()<cr>
```

This binds `<tab>` to the `foldout#toggle_fold()` function in normal, visual,
select, and operator-pending modes. The `<silent>` flag tells vim to call the
function without first displaying the keybinding.

### Enable

| function | description |
| --- | --- |
| `foldout#enable()` | Enable foldout in the current buffer. |
| `foldout#disable()` | Disable foldout in the current buffer. |
| `foldout#toggle()` | Toggle foldout in the current buffer. |

### Headings

| function | description |
| --- | --- |
| `foldout#level()` | Get level of heading, or 0 if not at a heading. |
| `foldout#demote()` | Demote current heading. Don't change children. |
| `foldout#promote()` | Promote current heading. Don't change children. |
| `foldout#tab()` | Demote if at heading, else simulate tab. |
| `foldout#shift_tab()` | Promote if at heading, else simulate shift-tab. |

The `foldout#tab()` and `foldout#shift_tab()` functions are designed to be
bound to tab and shift-tab in insert mode; for example:

```
inoremap <tab> <c-\><c-o>:silent call foldout#tab()<cr>
inoremap <s-tab> <c-\><c-o>:silent call foldout#shift_tab()<cr>
```

### Navigation

| function | description |
| --- | --- |
| `foldout#parent()` | Go to parent heading. |
| `foldout#down()` | Go to next sibling heading. |
| `foldout#up()` | Go to previous sibling heading. |
| `foldout#down_graphical()` | Go to next visible heading of any level. |
| `foldout#up_graphical()` | Go to previous visible heading of any level. |
| `foldout#top()` | Go to first sibling heading. |
| `foldout#bottom()` | Go to last sibling heading. |
| `foldout#child()` | Go to first child heading. |
| `foldout#goto(heading, level)` | Go to heading with given name & level. |

### Folding

| function | description |
| --- | --- |
| `foldout#toggle_fold()` | Toggle fold at cursor. |
| `foldout#show()` | Open all folds. |
| `foldout#focus()` | Close all folds but those needed to see cursor. |
| `foldout#center()` | Redraw so that cursor is vertically centered. |

### Insertion

| function | description |
| --- | --- |
| `foldout#append()` | Go to end of current section, enter insert mode. |
| `foldout#open()` | Create heading below and enter insert mode. |

### Query

| function | description |
| --- | --- |
| `foldout#syntax()` | View the stack of syntax groups at the cursor. |

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
| `g` | `foldout_files` | `'*.*'` | Pattern determining whether to enable foldout. |
| `g` | `foldout_save` | 0 | Allow foldout to save & restore view data. |
| `b, g` | `foldout_heading_symbol` | `'#'` | Repeated symbol indicating heading level. |
| `b, g` | `foldout_max_level` | 6 | Maximum allowed heading level. |
| `b, g` | `foldout_min_fold` | 1 | Minimum level at which to enable folding. |
| `b, g` | `foldout_append_pattern` | `'\@!'` | Pattern determining whether to insert empty line in `foldout#append()`. |
| `b, g` | `foldout_append_text` | `''` | Prefix text to insert in `foldout#append()`. |
| `b` | `foldout_heading_comment` | 1 (0 for markdown) | Highlight heading delimiters as comments. |
| `b` | `foldout_heading_string` | `commentstring` (`'%s'` for markdown) | Heading pattern, in `commentstring` format. |

Use the vim help files (e.g. `:h foldout_options`) for documentation.

## Known issues

If you see unexpected highlighting, use `:call foldout#syntax()` to see the
stack of syntax groups at the cursor. If foldout is enabled, you should expect
to see `foldoutFile`, followed by one or more foldout-related groups, followed
by zero or more non-foldout-related groups, for example:

```
foldoutFile, foldoutChildren, foldoutBody1, foldoutContent, javaScriptIdentifier -> Identifier
```

If you do not see this general pattern, you are experiencing a foldout-related
issue. The two known issues are:

### Files beginning with keywords

If a file begins with a keyword, then no headings are detected. For example,
consider the following JavaScript file:

```
var x = 2
// # print
console.log(x)
```

The `print` heading is not detected. The issue is that foldout relies on
matching the entire file as a region, but `var` is declared as a keyword in
vim's JavaScript syntax file, and keywords have higher precedence than regions.
An easy fix is to add an empty line to the top of the file.

For a more permanent fix, modify the syntax file to replace any `keyword` that
may occur at the beginning of the file with a `match`. For example, for the
JavaScript keyword `var`, download the default JavaScript syntax file
([link](https://github.com/vim/vim/blob/master/runtime/syntax/javascript.vim))
to `~/.vim/syntax/javascript.vim` (if using vim) or
`~/.config/nvim/syntax/javascript.vim` (if using neovim). vim will now use the
downloaded syntax file instead of the default syntax file. Find the line
declaring `var` as a keyword:

```
syn keyword javaScriptIdentifier arguments this var let
```

Then remove `var` and add a line recognizing `var` using `match`:

```
syn keyword javaScriptIdentifier arguments this let
syn match javaScriptIdentifier "\<var\>"
```

The heading is now detected, and the JavaScript highlighting is unchanged.

### Syntax files using `contains=ALL` or `contains=CONTAINED`

A syntax file may use `contains=ALL` to indicate that within a match or region,
all match groups are in scope, which may cause unexpected highlighting when used
with foldout. The issue is that foldout relies on carefully controlling where
its own syntax groups may match, which is impossible in the presence of the
`contains=ALL` construct. (Similar remarks apply to `contains=CONTAINED`.)

The better syntax files avoid these constructs in favor of explicit lists of
contained clusters and syntax groups. If you encounter this issue, consider
using a vim plugin that provides an alternative syntax file for the affected
filetype, or modify the syntax file yourself to replace the `ALL` or `CONTAINED`
keywords wherever they appear.

## Changelog

### [2.0] - 2020-07-22

- Removed navigation mode. (If you relied on this, tell me by filing an issue.)
- `g:foldout_files` now defaults to `*.*`, matching files with extensions.
- `b:foldout_heading_comment` now defaults to `0` in Markdown files.
- `b:foldout_heading_string` now defaults to `%s` in Markdown files.

## Credits

foldout relies critically on the [FastFold](https://github.com/Konfekt/FastFold)
plugin, which is slightly modified and packaged with foldout.

