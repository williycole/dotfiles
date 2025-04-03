-- 💅Autoformatting & Linting Aid, docs: https://github.com/stevearc/conform.nvim
local conform = {
  'stevearc/conform.nvim',
  event = { 'BufWritePre' },
  cmd = { 'ConformInfo' },
  keys = {
    {
      '<leader>f',
      function()
        require('conform').format { async = true, lsp_format = 'fallback' }
      end,
      mode = '',
      desc = '[F]ormat buffer',
    },
  },
  config = function()
    local conform = require 'conform'

    conform.setup {
      formatters_by_ft = {
        lua = { 'stylua' },
        python = { 'isort', 'black' },
        javascript = { 'prettier', stop_after_first = true },
        typescript = { 'prettier', stop_after_first = true },
        typescriptreact = { 'prettier', stop_after_first = true },
        javascriptreact = { 'prettier', stop_after_first = true },
        ['typescript.tsx'] = { 'prettier', stop_after_first = true },
        html = { 'prettier', stop_after_first = true },
        css = { 'prettier', stop_after_first = true },
        markdown = { 'prettier', 'markdownlint-cli2', 'markdown-toc' },
        ['markdown.mdx'] = { 'prettier', 'markdownlint-cli2', 'markdown-toc' },
      },
      formatters = {
        prettier = {
          -- Now conform.util will be available because we're in the config function
          -- after the plugin has loaded
          prepend_args = function()
            local has_config = vim.fn.filereadable '.prettierrc' == 1
              or vim.fn.filereadable '.prettierrc.json' == 1
              or vim.fn.filereadable '.prettierrc.js' == 1

            if not has_config then
              return {
                '--single-quote',
                '--print-width',
                '120',
                '--tab-width',
                '4',
                '--trailing-comma',
                'es5',
              }
            end
            return {}
          end,
        },
      },
      format_on_save = function(bufnr)
        local disable_filetypes = { c = true, cpp = true }
        if disable_filetypes[vim.bo[bufnr].filetype] then
          return
        end
        return { timeout_ms = 1000, lsp_format = 'fallback' }
      end,
    }
  end,
}

return { conform }
