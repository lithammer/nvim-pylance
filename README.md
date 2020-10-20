# nvim-pylance

Adds support for [Pylance](https://github.com/microsoft/pylance-release) to
[nvim-lspconfig](https://github.com/neovim/nvim-lspconfig).

## Installation

```vim
" Using vim-plug
Plug 'lithammer/nvim-pylance'

" Using vim-packager
call packager#add('lithammer/nvim-pylance')

lua << EOF
local nvim_lsp = require('nvim_lsp')
local pylance = require('pylance')

pylance.setup()
nvim_lsp.pylance.setup()
EOF
```
