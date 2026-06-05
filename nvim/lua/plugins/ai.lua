return {
  {
    "olimorris/codecompanion.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
    cmd = { "CodeCompanion", "CodeCompanionChat", "CodeCompanionActions" },
    opts = {
      -- route in-editor AI through the Claude Code CLI (ACP) -> uses your
      -- Claude subscription via CLAUDE_CODE_OAUTH_TOKEN. No metered API key.
      strategies = {
        chat = { adapter = "claude_code" },
        inline = { adapter = "claude_code" },
      },
      adapters = {
        acp = {
          claude_code = function()
            return require("codecompanion.adapters").extend("claude_code", {
              env = {
                -- generated once via:  claude setup-token
                CLAUDE_CODE_OAUTH_TOKEN = "cmd:echo $CLAUDE_CODE_OAUTH_TOKEN",
              },
            })
          end,
        },
      },
    },
    keys = {
      { "<leader>aa", "<cmd>CodeCompanionChat Toggle<cr>", mode = { "n", "v" }, desc = "AI chat toggle" },
      { "<leader>ac", "<cmd>CodeCompanionActions<cr>", mode = { "n", "v" }, desc = "AI actions" },
      { "<leader>ae", "<cmd>CodeCompanion /explain<cr>", mode = "v", desc = "AI explain selection" },
      { "<leader>ar", "<cmd>CodeCompanion /refactor<cr>", mode = "v", desc = "AI refactor selection" },
    },
  },
}
