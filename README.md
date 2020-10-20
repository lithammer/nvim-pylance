# nvim-pylance

Adds support for [Pylance](https://github.com/microsoft/pylance-release) to
[nvim-lspconfig](https://github.com/neovim/nvim-lspconfig).

## Installation

First install the [Pylance
extension](https://marketplace.visualstudio.com/items?itemName=ms-python.vscode-pylance)
from the VS Code marketplace.

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

## Upgrade

Upgrade Pylance via VS Code.
