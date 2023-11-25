-- how do we write a conditional import?
local imports = {
  traversal = nil,
}
local Set = require("trepl.utils").Set
local core = require("trepl.core")

local ts_integration = {
  raise_for_unsupported = false,
  supported_languages = Set{
    "python",
    -- TODO:
    -- "c",
    -- "cpp",
    -- "go",
    -- "haskell",
    -- "java",
    -- "javascript",
    -- "julia",
    -- "lua",
    -- "objc",
    -- "ocaml",
    -- "perl",
    -- "php",
    -- "r",
    -- "ruby",
    -- "rust",
    -- "scala",
    -- "swift",
    -- "typescript",
    -- "zig",
  },
  loaded_languages = {}
}

local function lazy_imports()
  if imports.traversal == nil then
    imports.traversal = require("trepl.ts.traversal")
  end
end

ts_integration._get_buffer_language = function(bufnr)
  lazy_imports()
  if bufnr == nil then
    bufnr = vim.api.nvim_get_current_buf()
  end

  local lang, _ = vim.filetype.match({buf=bufnr})
  return lang
end

ts_integration._get_language_mapping = function(lang)
  if ts_integration.supported_languages[lang] == nil then
    error("Unsupported language " .. lang)
  end
  local import_path = "trepl.ts.langs." .. lang
  return require(import_path)
end

ts_integration._load_language = function(lang)
  if ts_integration.loaded_languages[lang] ~= nil then
    return ts_integration.loaded_languages[lang]
  end
  local mapping = ts_integration._get_language_mapping(lang)
  ts_integration.loaded_languages[lang] = mapping
end

ts_integration._load_language_for_buffer = function(bufnr)
  local lang = ts_integration._get_buffer_language(bufnr)
  ts_integration._load_language(lang)
  return lang
end

ts_integration._handle_unsupported_send = function(node_type, lang)
  if ts_integration.raise_for_unsupported then
    error(node_type .. " not implemented for language " .. lang)
  end
end

ts_integration._handle_no_node_found = function(node_type)
  if ts_integration.raise_for_not_found then
    error(node_type .. " not found")
  end
end

local handle_send_node = function(node_type, mapping_option, opts, bufnr)
  if opts == nil then
    -- luacheck: ignore opts
    opts = {}
  end
  if bufnr == nil then
    bufnr = vim.api.nvim_get_current_buf()
  end
  -- first get the required mapping
  local lang = ts_integration._load_language_for_buffer(bufnr)
  local mapping = ts_integration.loaded_languages[lang]
  if mapping[mapping_option] == nil then
    -- if unsupported node type, return early
    return ts_integration._handle_unsupported_send(node_type, lang)
  end

  local mapping_options = mapping[mapping_option]
  -- then handle the traversal of the AST to get the correct Node
  --
  local node = imports.traversal.get_node_for_mapping(bufnr, mapping_options)
  if node ~= nil then
    local node_text = vim.treesitter.get_node_text(node, bufnr)
    core.send_string(node_text, true)
  else
    ts_integration._handle_no_node_found(node_type)
  end
end

ts_integration.send_function = function(opts)
  lazy_imports()
  handle_send_node("function", "fn_opts", opts)
end

ts_integration.send_variable = function(opts)
  lazy_imports()
  handle_send_node("variable", "var_opts", opts)
end

ts_integration.send_class = function(opts)
  lazy_imports()
  handle_send_node("class", "class_opts", opts)
end

return ts_integration
