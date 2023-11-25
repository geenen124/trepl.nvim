local tmux = require("trepl.tmux")

local core = {}

core.store = {
  pane = nil,
  socket = nil
}

local function create_pane_arg(pane)
  if pane == "" then
    -- if pane is nil, then we can act on the next pane
    return "-t+"
  else
    return "-t " .. pane
  end
end

local function create_key_opt_args(keyopts)
  if keyopts == nil then
    return ""
  else
    return keyopts .. " "
  end
end

core.send_keys = function(line --[[string]], opts --[[table]])
  opts = opts or {}

  local pane = opts.pane or core.store.pane or ""
  local pane_input = create_pane_arg(pane)

  local keyopt_input = create_key_opt_args(opts.keyopts)

  local send_command = "send-keys " .. pane_input .. " " .. keyopt_input .. line

  tmux.run_command(send_command)
end

core.set_pane = function(pane --[[string]])
  core.store.pane = pane
end

core.set_socket = function(socket --[[string]])
  if socket == nil then
    socket = tmux.current_tmux_socket()
  end
  core.store.socket = socket
end

core.send_string = function(text --[[string]], add_newline --[[boolean]], escape_line --[[boolean]])
  if escape_line == nil then
    escape_line = true
  end

  local formatted_text = text

  if escape_line then
    formatted_text = vim.fn.shellescape(text)
  end

  if tmux.is_reserved_keyword(text) then
    core.send_keys(formatted_text, {keyopts="-l"})
    if add_newline then
      core.send_keys("ENTER")
    end
  else
    if add_newline then
      formatted_text = formatted_text .. " ENTER"
    end
    core.send_keys(formatted_text)
  end
end

return core
