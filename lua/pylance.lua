-- local log = require('vim.lsp.log')
local configs = require('nvim_lsp/configs')
local util = require('nvim_lsp/util')

local path = util.path

local messages = {}
local function init(_messages, _)
  messages = _messages
end

local function ensure_init(id)
  require('lsp-status').util.ensure_init(messages, id, 'pylance')
end

-- XXX: Seems like these callbacks are never called.
local callbacks =  {
  ['pyright/beginProgress'] = function(_, _, _, client_id)
    ensure_init(client_id)
    if not messages[client_id].progress[1] then
      messages[client_id].progress[1] = { spinner = 1, title = 'Pylance' }
    end
  end,
  ['pyright/reportProgress'] = function(_, _, message, client_id)
    messages[client_id].progress[1].spinner = messages[client_id].progress[1].spinner + 1
    messages[client_id].progress[1].title = message[1]
    vim.api.nvim_command('doautocmd User LspMessageUpdate')
  end,
  ['pyright/endProgress'] = function(_, _, _, client_id)
    messages[client_id].progress[1] = nil
    vim.api.nvim_command('doautocmd User LspMessageUpdate')
  end
}

local function root_dir(fname)
  local markers = {
    'Pipfile',
    'pyproject.toml',
    'setup.py',
    'setup.cfg',
    'requirements.txt',
  }
  return util.root_pattern(unpack(markers))(fname) or
    util.find_git_ancestor(fname) or
    path.dirname(fname)
end

local function get_python_path(workspace)
  -- 1. Use activated virtualenv.
  if vim.env.VIRTUAL_ENV ~= nil then
    return path.join(vim.env.VIRTUAL_ENV, 'bin', 'python')
  end

  -- 2. Find and use virtualenv in workspace directory.
  for _, pattern in ipairs({'*', '.*'}) do
    local match = vim.fn.glob(path.join(workspace, pattern, 'pyvenv.cfg'))
    if match ~= '' then
      return path.join(path.dirname(match), 'bin', 'python')
    end
  end

  -- 3. Find and use virtualenv managed by Poetry.
  if vim.fn.executable('poetry') == 1 then
    local output = vim.fn.trim(vim.fn.system('poetry env info -p'))
    if path.is_absolute(output) then
      return path.join(output, 'bin', 'python')
    end
  end

  -- 4. Find and use virtualenv managed by Pipenv.
  if vim.fn.executable('pipenv') == 1 then
    local output = vim.fn.trim(vim.fn.system('pipenv --py'))
    if path.is_absolute(output) then
      return output
    end
  end

  -- 5. Fallback to system Python.
  return vim.fn.exepath('python3') or vim.fn.exepath('python') or 'python'
end

local get_script_path = function()
  local scripts = vim.fn.expand('~/.vscode/extensions/ms-python.vscode-pylance-*/dist/server.bundle.js', false, true)
  -- After an upgrade the old plugin might linger for a while.
  table.sort(scripts, function(a, b)
    return a > b
  end)

  if scripts[1] == nil then
    error('Failed to resolve path to Pylance server')
  end

  return scripts[1]
end

local function setup()
  configs.pylance = {
    default_config = {
      cmd = {'node', get_script_path(), '--stdio'},
      filetypes = {'python'},
      callbacks = callbacks,
      root_dir = root_dir,
      settings = {
        python = {
          analysis = vim.empty_dict()
        }
      },
      -- https://github.com/neovim/nvim-lspconfig/issues/299#issuecomment-689592769
      before_init = function(initialize_params, config)
        initialize_params['workspaceFolders'] = {
          {name = 'workspace', uri = initialize_params['rootUri']}
        }
        config.settings.python.pythonPath = get_python_path(config.root_dir)
      end
    }
  }
end

local M = {
  _init = init,
  setup = setup
}

M = vim.tbl_extend('error', M, callbacks)

return M
