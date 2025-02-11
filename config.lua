-- Read the docs: https://www.lunarvim.org/docs/configuration
-- Example configs: https://github.com/LunarVim/starter.lvim
-- Video Tutorials: https://www.youtube.com/watch?v=sFA9kX-Ud_c&list=PLhoH5vyxr6QqGu0i7tt_XoVK9v-KvZ3m6
-- Forum: https://www.reddit.com/r/lunarvim/
-- Discord: https://discord.com/invite/Xb9B4Ny
lvim.plugins = {
  {
    "github/copilot.vim",
    config = function()
      vim.g.copilot_assume_mapped = true
      vim.g.copilot_no_tab_map = true
    end
  }
}
lvim.plugins = {
  {
    "CopilotC-Nvim/CopilotChat.nvim",
    -- branch = "canary",
    branch = "main",
    dependencies = {
      { "github/copilot.vim" },
      { "nvim-lua/plenary.nvim" }
    },
    config = function()
      require("CopilotChat").setup()
      vim.keymap.set('n', '<leader>pc', ':CopilotChatPaste<CR>', { noremap = true, silent = true })
    end
  }
}

vim.api.nvim_create_autocmd({"BufRead", "BufNewFile"}, {
  pattern = {"Vagrantfile"},
  command = "set filetype=ruby"
})

-- Helper function to run terminal command and return to previous window
local function run_vagrant_command(cmd)
    -- Store current window number
    local current_win = vim.api.nvim_get_current_win()
    
    -- Open terminal in split window
    vim.cmd('split')
    vim.cmd('wincmd j')
    
    -- Run the vagrant command with error handling
    vim.cmd(string.format([[
        terminal bash -c "vagrant %s || (echo -e '\nError detected! Press Enter to close window.' && read)"
    ]], cmd))
    
    -- Simple terminal close handler
    vim.api.nvim_create_autocmd("TermClose", {
        pattern = "*",
        once = true,
        callback = function()
            vim.cmd('quit')
            vim.api.nvim_set_current_win(current_win)
        end
    })
end

-- Create Vagrant commands
vim.api.nvim_create_user_command('VagrantUp', function()
    run_vagrant_command('up')
end, {})

vim.api.nvim_create_user_command('VagrantUpProvision', function()
    run_vagrant_command('up --provision')
end, {})

vim.api.nvim_create_user_command('VagrantHalt', function()
    run_vagrant_command('halt')
end, {})

vim.api.nvim_create_user_command('VagrantSSH', function()
    run_vagrant_command('ssh')
end, {})

vim.api.nvim_create_user_command('VagrantStatus', function()
    run_vagrant_command('status')
end, {})

-- Key mappings for Vagrant commands
lvim.keys.normal_mode["<leader>vu"] = ":VagrantUp<CR>"
lvim.keys.normal_mode["<leader>vp"] = ":VagrantUpProvision<CR>"
lvim.keys.normal_mode["<leader>vh"] = ":VagrantHalt<CR>"
lvim.keys.normal_mode["<leader>vs"] = ":VagrantSSH<CR>"
lvim.keys.normal_mode["<leader>vt"] = ":VagrantStatus<CR>"

-- Optional: Add which-key menu for Vagrant
lvim.builtin.which_key.mappings["v"] = {
  name = "Vagrant",
  u = { "<cmd>VagrantUp<cr>", "Vagrant Up" },
  p = { "<cmd>VagrantUpProvision<cr>", "Vagrant Up with Provision" },
  h = { "<cmd>VagrantHalt<cr>", "Vagrant Halt" },
  s = { "<cmd>VagrantSSH<cr>", "Vagrant SSH" },
  t = { "<cmd>VagrantStatus<cr>", "Vagrant Status" },
}
