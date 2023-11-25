local tmux = {}

local TMUX_KEYWORDS = {
  ["up"] = true,
  ["down"] = true,
  ["left"] = true,
  ["right"] = true,
  ["bspace"] = true,
  ["btab"] = true,
  ["dc"] = true,
  ["end"] = true,
  ["enter"] = true,
  ["escape"] = true,
  ["f1"] = true,
  ["f2"] = true,
  ["f3"] = true,
  ["f4"] = true,
  ["f5"] = true,
  ["f6"] = true,
  ["f7"] = true,
  ["f8"] = true,
  ["f9"] = true,
  ["f10"] = true,
  ["f11"] = true,
  ["f12"] = true,
  ["home"] = true,
  ["ic"] = true,
  ["npage"] = true,
  ["pagedown"] = true,
  ["pgdn"] = true,
  ["ppage"] = true,
  ["pageup"] = true,
  ["pgup"] = true,
  ["space"] = true,
  ["tab"] = true,
}

-- check if input is a tmux keyword
tmux.is_reserved_keyword = function(input)
  return TMUX_KEYWORDS[string.lower(input)] ~= nil
end

tmux.current_tmux_socket = function()
  local tmux_env = os.getenv("TMUX")
  if tmux_env == nil then
    error("TMUX environment variable not set")
  end
  return vim.split(tmux_env, ",")[1]
end

tmux.run_command = function(--[[required]] command --[[string]])
  local full_command = string.format("tmux -S %s %s", tmux.current_tmux_socket(), command)

  local handle = io.popen(full_command)
  assert(handle, "Failed to run command: " .. full_command)
  handle:close()
end

return tmux
