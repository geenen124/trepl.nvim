local cmd = require("trepl.cmd")

local M = {}

local function setup_commands()
  for _, command in ipairs(cmd.commands) do
    vim.api.nvim_create_user_command(command.name,
      function(opts)
        command.callable(opts)
      end,
      command.options
    )
  end
end

M.setup = function(opts)
  if opts == nil then
    opts = {}
  end
  if opts.commands == nil then
    opts.commands = true
  end

  if opts.commands then
    setup_commands()
  end
end

return M
