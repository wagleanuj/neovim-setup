-- Auto-restore the per-directory session on a bare `nvim` (matches the way tmux
-- auto-restores its layout). persistence.nvim itself + its <leader>q keymaps come
-- from LazyVim; this only adds the automatic load on startup.
-- Manual control still works: <leader>qs restore, <leader>ql last, <leader>qd don't-save.
return {
  {
    "folke/persistence.nvim",
    opts = {},
    init = function()
      local group = vim.api.nvim_create_augroup("PersistenceAutoload", { clear = true })

      -- piping into nvim (e.g. `git ... | nvim -`) must NOT trigger a restore
      vim.api.nvim_create_autocmd("StdinReadPre", {
        group = group,
        callback = function() vim.g.started_with_stdin = true end,
      })

      vim.api.nvim_create_autocmd("VimEnter", {
        group = group,
        nested = true,
        callback = function()
          -- only auto-restore a "bare" launch: no file args, not stdin, not a git editor
          if vim.fn.argc() > 0 then return end
          if vim.g.started_with_stdin then return end
          local ft = vim.bo.filetype
          if ft == "gitcommit" or ft == "gitrebase" then return end
          require("persistence").load()
        end,
      })
    end,
  },

  -- inc-rename: live, incremental preview of <leader>cr renames (rendered via the
  -- already-enabled noice.nvim cmdline). LazyVim auto-wires <leader>cr to it.
  {
    "smjonas/inc-rename.nvim",
    cmd = "IncRename",
    opts = {},
  },
}
