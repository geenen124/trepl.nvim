local utils = {}


utils.get_visual_selection = function()
  local viz_start = vim.fn.getpos("'<")
  local viz_end = vim.fn.getpos("'>")

  local start_row = viz_start[2]
  local start_col = viz_start[3]
  local end_row = viz_end[2]
  local end_col = viz_end[3]

  return start_row, start_col, end_row, end_col
end

utils.Set = function(list)
  local set = {}
  for _, l in ipairs(list) do
    set[l] = true
  end
  return set
end

return utils
