# nvim-pylance

Adds support for [Pylance](https://github.com/microsoft/pylance-release) to
[nvim-lspconfig](https://github.com/neovim/nvim-lspconfig).

## Important note!

As of the 2020.10.3 release of Pylance it's no longer possible to run it in
a stand-alone fashion as you will onle get prompted with this:

> You may install and use any number of copies of the software only with
> Microsoft Visual Studio, Visual Studio for Mac, Visual Studio Code, Azure
> DevOps, Team Foundation Server, and successor Microsoft products and services
> (collectively, the “Visual Studio Products and Services”) to develop and test
> your applications. The software is licensed, not sold. This agreement only
> gives you some rights to use the software. Microsoft reserves all other
> rights. You may not: work around any technical limitations in the software
> that only allow you to use it in certain ways; reverse engineer, decompile or
> disassemble the software, or otherwise attempt to derive the source code for
> the software, except and to the extent required by third party licensing
> terms governing use of certain open source components that may be included in
> the software; remove, minimize, block, or modify any notices of Microsoft or
> its suppliers in the software; use the software in any way that is against
> the law or to create or propagate malware; or share, publish, distribute, or
> lease the software (except for any distributable code, subject to the terms
> above), provide the software as a stand-alone offering for others to use, or
> transfer the software or this agreement to any third party.

## Installation

First install the [Pylance
extension](https://marketplace.visualstudio.com/items?itemName=ms-python.vscode-pylance)
from the VS Code marketplace.

```vim
" Using vim-plug
Plug 'lithammer/nvim-pylance'

" Using vim-packager
call packager#add('lithammer/nvim-pylance')
```

```lua
local nvim_lsp = require('nvim_lsp')
local pylance = require('pylance')

pylance.setup()
nvim_lsp.pylance.setup({
  -- https://github.com/microsoft/pylance-release#settings-and-customization
  settings = {
    python = {
      analysis = {
        indexing = true,
        typeCheckingMode = 'basic',
      }
    }
  }
})
```

## Upgrade

Upgrade Pylance via VS Code.
