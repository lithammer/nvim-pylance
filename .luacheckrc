std = "lua51+vim"

stds.vim = {
  read_globals = {
    vim = {
      fields = {
        api = {
          fields = {
            "nvim_command",
          }
        },
        fn = {
          fields = {
            "empty",
            "executable",
            "exepath",
            "expand",
            "glob",
            "system",
            "trim",
          }
        },

        "empty_dict",
        "env",
        "tbl_extend"
      }
    }
  }
}
