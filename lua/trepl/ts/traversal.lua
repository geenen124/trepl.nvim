local traversal = {}
local utils = require("trepl.utils")

local function filter_keys(table, to_keep)
  for key in pairs(table) do
    if not to_keep[key] then
      table[key] = nil
    end
  end
end

traversal._traverse_for_types = function(starting_node, valid_types)
  local node = starting_node
  while node ~= nil do
    if valid_types[node:type()] then
      return node
    end
    node = node:parent()
  end
  -- if nothing is found
  return nil
end

traversal._traverse_parents = function(node, wrappable)
  local valid_parents = utils.deepcopy(wrappable)
  while node:parent() ~= nil do
    if valid_parents[node:parent():type()] ~= nil then
      local parent_info = valid_parents[node:parent():type()]
      node = node:parent()
      if parent_info.terminal then
        return node
      end
      -- filter keys in place
      filter_keys(valid_parents, parent_info.valid_parents)
    else
      break
    end
  end
  return node
end

traversal.get_node_for_mapping = function(bufnr, mapping_options)
  local opts = {}
  if bufnr ~= nil then
    opts.bufnr = bufnr
  end
  local starting_node = vim.treesitter.get_node(opts)
  local first_result = traversal._traverse_for_types(starting_node, mapping_options.node_types)
  if first_result == nil then
    return nil
  end
  if mapping_options.wrappers ~= nil and mapping_options.wrappers[first_result:type()] ~= nil then
    -- handle wrappers
    return traversal._traverse_parents(
      first_result,
      mapping_options.wrappers[first_result:type()]
    )
  end
  return first_result
end

return traversal
