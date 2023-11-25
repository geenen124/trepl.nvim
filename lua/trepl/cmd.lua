local core = require("trepl.core")
local utils = require("trepl.utils")
local ts_integration = require("trepl.ts")
local cmd = {}

-- goals:
-- todo: handle repeating command

cmd.send_current_line = function(add_newline --[[boolean]])
  add_newline = add_newline or true
  local line = vim.api.nvim_get_current_line()
  core.send_string(line, add_newline)
end

local function send_table(lines)
  for _, line in ipairs(lines) do
    core.send_string(line, true)
  end
end

cmd.send_selection = function()
  local start_row, start_col, end_row, end_col = utils.get_visual_selection()
  local lines = vim.api.nvim_buf_get_text(0, start_row-1, start_col-1, end_row-1, end_col-1, {})
  send_table(lines)
end

cmd.send_selected_lines = function()
  local start_row, _, end_row, _ = utils.get_visual_selection()
  local lines = vim.api.nvim_buf_get_lines(0, start_row-1, end_row, false)
  send_table(lines)
end

local COMMAND_TO_FNS = {
  current_line = cmd.send_current_line,
  selection = cmd.send_selection,
  selected_lines = cmd.send_selected_lines,
  variable = ts_integration.send_variable,
  ["function"] = ts_integration.send_function,
  class = ts_integration.send_class,
}

cmd.commands = {
  {
    name = "Trepl",
    callable = function(opts)
      if #opts.fargs ~= 1 then
      error("Trepl requires one argument")
      end
      if COMMAND_TO_FNS[opts.fargs[1]] == nil then
      error("Invalid command: " .. opts.fargs[1])
      end
      COMMAND_TO_FNS[opts.fargs[1]]()
    end,
    options = {
      nargs = 1,
      range = true,
      complete = function(_, _, _)
        return {"current_line", "selection", "selected_lines", "function", "class", "variable"}
      end
    }
  },
  {
    name = "TreplSetPane",
    callable = function(opts)
      if #opts.fargs ~= 1 then
        error("TreplSetPane requires one argument")
      end
      core.set_pane(opts.fargs[1])
    end,
    options = {
      nargs = 1,
    }
  },
  {
    name = "TreplSetSocket",
    callable = function(opts)
      if #opts.fargs == 0 then
        core.set_socket()
      elseif #opts.fargs > 1 then
        error("TreplSetSocket does not accept >1 argument")
      else
        core.set_socket(opts.fargs[1])
      end
    end,
    options = {
      nargs = 1,
    }
  }
}

return cmd
