-- docs: https://github.com/ray-x/lsp_signature.nvim, lsp signature hint as you type
return {
  'ray-x/lsp_signature.nvim',
  event = 'InsertEnter',
  opts = {
    bind = true,
    handler_opts = {
      border = 'rounded',
    },
  },
  config = function(_, opts)
    require('lsp_signature').setup(opts)
  end,
}
