local Set = require("trepl.utils").Set

local mapping = {
  fn_opts = {
    -- Todo: add support for decorators and lambdas
    node_types = Set{
      "function_definition"
    },
    wrappers = {
      function_definition = {
        decorated_definition = {
          terminal = false,
          valid_parents = Set{"decorated_definition"}
        },
      },
    },
  },
  var_opts = {
    node_types = Set{
      "assignment"
    },
  },
  class_opts = {
    node_types = Set{
      "class_definition"
    },
    wrappers = {
      class_definition = {
        decorated_definition = {
          terminal = false,
          valid_parents = Set{"decorated_definition"}
        }
      },
    },
  },
}

return mapping
