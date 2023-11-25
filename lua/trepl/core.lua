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

return core
