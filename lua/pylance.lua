local configs = require('lspconfig/configs')
local util = require('lspconfig/util')

local expand =  vim.fn.expand
local glob = vim.fn.glob
local system = vim.fn.system
local trim = vim.fn.trim

local nvim_command = vim.api.nvim_command

local path = util.path

-- Vim API wrappers.
local function empty(expr) return vim.fn.empty(expr) == 1 end
local function exepath(expr)
  local ep = vim.fn.exepath(expr)
  return ep ~= '' and ep or nil
end

local messages = {}
local function init(_messages, _)
  messages = _messages
end

local function ensure_init(id)
  require('lsp-status/util').ensure_init(messages, id, 'pylance')
end

local handlers =  {
  ['pyright/beginProgress'] = function(_, _, _, client_id)
    ensure_init(client_id)
    if not messages[client_id].progress[1] then
      messages[client_id].progress[1] = { spinner = 1, title = 'Pylance' }
    end
  end,
  ['pyright/reportProgress'] = function(_, _, message, client_id)
    messages[client_id].progress[1].spinner = messages[client_id].progress[1].spinner + 1
    messages[client_id].progress[1].title = message[1]
    nvim_command('doautocmd User LspMessageUpdate')
  end,
  ['pyright/endProgress'] = function(_, _, _, client_id)
    messages[client_id].progress[1] = nil
    nvim_command('doautocmd User LspMessageUpdate')
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
  if vim.env.VIRTUAL_ENV then
    return path.join(vim.env.VIRTUAL_ENV, 'bin', 'python')
  end

  -- 2. Find and use virtualenv in workspace directory.
  for _, pattern in ipairs({'*', '.*'}) do
    local match = glob(path.join(workspace, pattern, 'pyvenv.cfg'))
    if not empty(match) then
      return path.join(path.dirname(match), 'bin', 'python')
    end
  end

  -- 3. Find and use virtualenv managed by Poetry.
  if util.has_bins('poetry') and path.is_file(path.join(workspace, 'poetry.lock')) then
    local output = trim(system('poetry env info -p'))
    if path.is_dir(output) then
      return path.join(output, 'bin', 'python')
    end
  end

  -- 4. Find and use virtualenv managed by Pipenv.
  if util.has_bins('pipenv') and path.is_file(path.join(workspace, 'Pipfile')) then
    local output = trim(system('cd ' .. workspace .. '; pipenv --py'))
    if path.is_dir(output) then
      return output
    end
  end

  -- 5. Fallback to system Python.
  return exepath('python3') or exepath('python') or 'python'
end

local get_script_path = function()
  local scripts = expand('~/.vscode/extensions/ms-python.vscode-pylance-*/dist/server.bundle.js', false, true)
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
      handlers = handlers,
      root_dir = root_dir,
      settings = {
        python = {
          analysis = vim.empty_dict()
        }
      },
      before_init = function(_, config)
        if not config.settings.python then config.settings.python = {} end
        if not config.settings.python.pythonPath then
          config.settings.python.pythonPath = get_python_path(config.root_dir)
        end
      end
    }
  }
end

local M = {
  _init = init,
  setup = setup
}

M = vim.tbl_extend('error', M, handlers)

return M
