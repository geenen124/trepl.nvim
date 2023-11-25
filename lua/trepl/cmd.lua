local tmux = require("trepl.tmux")
local core = require("trepl.core")
local utils = require("trepl.utils")
local cmd = {}

-- goals:
-- todo: handle repeating command
-- todo: use lsp to get current block

cmd.send_line = function(line --[[string]], use_carriage --[[boolean]], escape_line --[[boolean]])
  if escape_line == nil then
    escape_line = true
  end

  local formatted_line = line

  if escape_line then
    formatted_line = vim.fn.shellescape(line)
  end

  if tmux.is_reserved_keyword(line) then
    core.send_keys(formatted_line, {keyopts="-l"})
    core.send_keys("ENTER")
    return
  else
    if use_carriage then
      formatted_line = formatted_line .. " ENTER"
    end
    core.send_keys(formatted_line)
  end
end

cmd.send_current_line = function(use_carriage --[[boolean]])
  use_carriage = use_carriage or true
  local line = vim.api.nvim_get_current_line()
  cmd.send_line(line, use_carriage)
end

local function send_table(lines)
  for _, line in ipairs(lines) do
    cmd.send_line(line, true)
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
        return {"current_line", "selection", "selected_lines"}
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
