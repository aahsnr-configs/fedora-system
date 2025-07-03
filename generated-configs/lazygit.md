# Lazygit with Catppuccin Mocha theme, astronvim integrationa and fedora optimization
``````sh
# Lazygit Configuration for Fedora 42 with AstroNvim Integration
# Location: ~/.config/lazygit/config.yml

gui:
  # Catppuccin Mocha Theme (maintained from original)
  theme:
    lightTheme: false
    activeBorderColor:
      - '#cba6f7'  # Catppuccin Mocha Mauve
      - bold
    inactiveBorderColor:
      - '#6c7086'  # Catppuccin Mocha Surface2
    optionsTextColor:
      - '#89b4fa'  # Catppuccin Mocha Blue
    selectedLineBgColor:
      - '#313244'  # Catppuccin Mocha Surface0
    selectedRangeBgColor:
      - '#313244'  # Catppuccin Mocha Surface0
    cherryPickedCommitBgColor:
      - '#313244'  # Catppuccin Mocha Surface0
    cherryPickedCommitFgColor:
      - '#a6e3a1'  # Catppuccin Mocha Green
    unstagedChangesColor:
      - '#f38ba8'  # Catppuccin Mocha Red
    defaultFgColor:
      - '#cdd6f4'  # Catppuccin Mocha Text
    searchingActiveBorderColor:
      - '#fab387'  # Catppuccin Mocha Peach
    cherryPickedCommitBgColor:
      - '#313244'  # Catppuccin Mocha Surface0
    cherryPickedCommitFgColor:
      - '#a6e3a1'  # Catppuccin Mocha Green
    unstagedChangesColor:
      - '#f38ba8'  # Catppuccin Mocha Red
    defaultFgColor:
      - '#cdd6f4'  # Catppuccin Mocha Text

  # Enhanced display settings for better AstroNvim integration
  scrollHeight: 2
  scrollPastBottom: true
  mouseEvents: true
  skipDiscardChangeWarning: false
  skipStashWarning: false
  showFileTree: true
  showListFooter: true
  showRandomTip: true
  showBranchCommitHash: true
  showBottomLine: true
  showPanelJumps: true
  showCommandLog: true
  showIcons: true
  nerdFontsVersion: "3"
  commitLength:
    show: true
  splitDiff: 'auto'
  skipRewordInEditorWarning: false
  border: 'rounded'
  animateExpansion: true
  portraitMode: 'auto'
  filterMode: 'substring'
  spinner:
    frames: ['⠋', '⠙', '⠹', '⠸', '⠼', '⠴', '⠦', '⠧', '⠇', '⠏']
    rate: 50

  # Vim-like keybindings optimized for AstroNvim users
  keybinding:
    universal:
      quit: 'q'
      quit-alt1: '<c-c>'
      return: '<esc>'
      quitWithoutChangingDirectory: 'Q'
      togglePanel: '<tab>'
      prevItem: 'k'
      nextItem: 'j'
      prevItem-alt: '<up>'
      nextItem-alt: '<down>'
      prevPage: '<c-u>'
      nextPage: '<c-d>'
      scrollLeft: 'H'
      scrollRight: 'L'
      gotoTop: 'gg'
      gotoBottom: 'G'
      toggleRangeSelect: 'v'
      rangeSelectDown: '<s-j>'
      rangeSelectUp: '<s-k>'
      prevBlock: '<left>'
      nextBlock: '<right>'
      prevBlock-alt: 'h'
      nextBlock-alt: 'l'
      nextTab: ']'
      prevTab: '['
      nextScreenMode: '+'
      prevScreenMode: '_'
      undo: 'z'
      redo: '<c-z>'
      filteringMenu: '<c-s>'
      diffingMenu: 'W'
      diffingMenu-alt: '<c-e>'
      copyToClipboard: '<c-o>'
      openRecentRepos: '<c-r>'
      submitEditorText: '<enter>'
      extrasMenu: '@'
      toggleWhitespaceInDiffView: '<c-w>'
      increaseContextInDiffView: '}'
      decreaseContextInDiffView: '{'
      increaseRenameSimilarityThreshold: ')'
      decreaseRenameSimilarityThreshold: '('
      openDiffTool: '<c-t>'

    status:
      checkForUpdate: 'u'
      recentRepos: '<enter>'
      allBranchesLogGraph: 'a'

    files:
      commitChanges: 'c'
      commitChangesWithoutHook: 'C'
      amendLastCommit: 'A'
      commitChangesWithEditor: '<c-o>'
      findBaseCommitForFixup: '<c-f>'
      confirmDiscard: 'x'
      ignoreFile: 'i'
      refreshFiles: 'r'
      stashAllChanges: 's'
      viewStashOptions: 'S'
      toggleStagedAll: 'a'
      viewResetOptions: 'D'
      fetch: 'f'
      toggleTreeView: '`'
      openMergeTool: 'M'
      openStatusFilter: '<c-b>'

    branches:
      createPullRequest: 'o'
      viewPullRequestOptions: 'O'
      copyPullRequestURL: '<c-y>'
      checkoutBranch: '<space>'
      checkoutBranch-alt: 'c'
      forceCheckoutBranch: 'F'
      rebaseBranch: 'r'
      renameBranch: 'R'
      mergeIntoCurrentBranch: 'm'
      viewBranchOptions: 'M'
      fastForward: 'f'
      createTag: 'T'
      push: 'P'
      pull: 'p'
      setUpstream: 'u'
      fetchRemote: 'f'
      sortOrder: 's'
      gitFlowOptions: 'i'
      createResetToBranchMenu: 'g'
      viewResetOptions: 'R'
      deleteBranch: 'd'
      mergeBranch: 'm'
      copyToClipboard: 'y'

    worktrees:
      viewWorktreeOptions: 'w'

    commits:
      squashDown: 's'
      renameCommit: 'r'
      renameCommitWithEditor: 'R'
      viewResetOptions: 'g'
      markCommitAsFixup: 'f'
      createFixupCommit: 'F'
      squashAboveCommits: 'S'
      moveDownCommit: '<c-j>'
      moveUpCommit: '<c-k>'
      amendToCommit: 'A'
      amendAttributeMenu: 'a'
      pickCommit: 'p'
      revertCommit: 't'
      cherryPickCopy: 'c'
      pasteCommits: 'v'
      markCommitAsBaseForRebase: 'B'
      tagCommit: 'T'
      checkoutCommit: '<space>'
      resetCherryPick: '<c-r>'
      copyCommitAttributeToClipboard: 'y'
      openLogMenu: '<c-l>'
      openInBrowser: 'o'
      viewBisectOptions: 'b'
      startInteractiveRebase: 'i'

    amendAttribute:
      resetAuthor: 'a'
      setAuthor: 'A'
      addCoAuthor: 'c'

    stash:
      popStash: 'g'
      renameStash: 'r'
      applyStash: 'a'
      viewStashOptions: '<enter>'
      dropStash: 'd'

    commitFiles:
      checkoutCommitFile: 'c'

    main:
      toggleSelectHunk: 'a'
      pickBothHunks: 'b'
      editSelectHunk: 'e'
      openFile: 'o'
      openFileInEditor: '<c-o>'
      openDiffTool: '<c-t>'
      refreshStagingPanel: 'r'
      stageSelection: 's'
      resetSelection: 'r'
      togglePanel: '<tab>'
      prevConflict: '['
      nextConflict: ']'
      selectPrevConflict: '<'
      selectNextConflict: '>'
      selectPrevHunk: 'K'
      selectNextHunk: 'J'
      undo: 'z'
      redo: '<c-z>'
      toggleDragSelect: 'v'
      toggleDragSelect-alt: 'V'
      toggleSelectHunk: 'a'
      copyToClipboard: '<c-o>'

    submodules:
      init: 'i'
      update: 'u'
      bulkMenu: 'b'
      delete: 'd'
      enter: '<enter>'

    commitMessage:
      confirm: '<enter>'
      switchToEditor: '<c-o>'

git:
  # Git configuration optimized for Fedora 42
  paging:
    colorArg: always
    pager: delta --dark --paging=never --line-numbers --side-by-side
    useConfig: false
    externalDiffCommand: ''

  # Fedora 42 specific settings
  commit:
    signOff: false
    autoWrapCommitMessage: true
    autoWrapWidth: 72

  merging:
    manualCommit: false
    args: ''
    tool: 'nvimdiff'
    conflictStyle: 'zdiff3'

  log:
    order: 'topo-order'
    showGraph: 'when-maximised'
    showWholeGraph: false

  skipHookPrefix: WIP
  autoFetch: true
  autoRefresh: true
  fetchAll: true
  branchLogCmd: 'git log --graph --color=always --abbrev-commit --decorate --date=relative --pretty=medium {{branchName}} --'
  allBranchesLogCmd: 'git log --graph --all --color=always --abbrev-commit --decorate --date=relative --pretty=medium'
  overrideGpg: false
  disableForcePushing: false
  parseEmoji: false
  truncateCopiedCommitHashesTo: 12

# OS-specific settings for Fedora 42
os:
  # Use nvim (AstroNvim) as the default editor
  editCommand: 'nvim'
  editCommandTemplate: '{{editor}} "{{filename}}"'
  editPreset: 'nvim'
  
  # Fedora 42 specific open command
  openCommand: 'xdg-open'
  openLinkCommand: 'xdg-open {{link}}'
  
  # Copy commands for Fedora 42
  copyToClipboardCmd: 'wl-copy'  # For Wayland
  readFromClipboardCmd: 'wl-paste'  # For Wayland
  
  # Alternative for X11 sessions
  # copyToClipboardCmd: 'xclip -selection clipboard'
  # readFromClipboardCmd: 'xclip -selection clipboard -o'

# Update and notification settings
update:
  method: 'prompt'
  days: 14

# Refresh settings
refresher:
  refreshInterval: 10
  fetchInterval: 60

# Confirmation settings
confirmOnQuit: false
quitOnTopLevelReturn: false

# Startup settings
disableStartupPopups: true
notARepository: 'prompt'

# Custom commands for enhanced AstroNvim integration
customCommands:
  # Quick commit amendments
  - key: 'e'
    command: 'git commit --amend --no-edit'
    context: 'commits'
    description: 'Amend commit without editing message'
    stream: true
  
  # Open files in AstroNvim
  - key: 'n'
    command: 'nvim {{filename}}'
    context: 'files'
    description: 'Open file in AstroNvim'
    subprocess: true
  
  # Advanced AstroNvim integration
  - key: 'N'
    command: 'nvim -c "lua require(\"telescope.builtin\").git_files()"'
    context: 'global'
    description: 'Open AstroNvim with Telescope git files'
    subprocess: true
  
  # View file history in AstroNvim
  - key: 'H'
    command: 'nvim -c "lua require(\"telescope.builtin\").git_bcommits()"'
    context: 'files'
    description: 'View file history with Telescope'
    subprocess: true
  
  # Interactive rebase with AstroNvim
  - key: 'I'
    command: 'git rebase -i {{.CheckedOutBranch.Name}}~{{.SelectedLocalCommit.Sha}}'
    context: 'commits'
    description: 'Interactive rebase from selected commit'
    subprocess: true
  
  # Create new branch with AstroNvim telescope
  - key: 'B'
    command: 'nvim -c "lua require(\"telescope.builtin\").git_branches()"'
    context: 'branches'
    description: 'Browse branches with Telescope'
    subprocess: true
  
  # Search commits with AstroNvim
  - key: '/'
    command: 'nvim -c "lua require(\"telescope.builtin\").git_commits()"'
    context: 'commits'
    description: 'Search commits with Telescope'
    subprocess: true
  
  # View diff in AstroNvim
  - key: 'D'
    command: 'nvim -c "Gvdiffsplit" {{filename}}'
    context: 'files'
    description: 'View diff in AstroNvim with fugitive'
    subprocess: true
  
  # Quick push with force-with-lease
  - key: 'P'
    command: 'git push --force-with-lease'
    context: 'global'
    description: 'Force push with lease (safer)'
    stream: true
  
  # Stash with message
  - key: 'S'
    command: 'git stash push -m "{{.Form.Message}}"'
    context: 'files'
    description: 'Stash with custom message'
    prompts:
      - type: 'input'
        key: 'Message'
        title: 'Stash Message'
        initialValue: 'WIP: '
    stream: true

# AstroNvim specific services configuration
services:
  # Enable GitHub integration if available
  github: 'github.com'
  gitlab: 'gitlab.com'

# Fedora 42 performance optimizations
performance:
  useAsyncGit: true
  reportRuntimeErrors: true
``````

# AstroNvim Lazygit Integration for Fedora 42

## Installation on Fedora 42

``

## AstroNvim Integration

### Launching Lazygit from AstroNvim

AstroNvim includes built-in lazygit support with keybindings. You can launch lazygit from within AstroNvim using:

**Default AstroNvim Keybindings:**
- `<leader>tl` - Open lazygit in toggleterm
- `<leader>gg` - Alternative lazygit keybinding

**Manual Launch:**
- `:LazyGit` - Command to open lazygit
- `:ToggleTerm` - Open terminal and run `lazygit`

### Enhanced AstroNvim Integration Setup

Create a custom AstroNvim configuration file to enhance lazygit integration:

**File: `~/.config/nvim/lua/user/plugins/lazygit.lua`**

```lua
return {
  {
    "kdheepak/lazygit.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    config = function()
      -- Configure lazygit floating window
      vim.g.lazygit_floating_window_winblend = 0
      vim.g.lazygit_floating_window_scaling_factor = 0.9
      vim.g.lazygit_floating_window_border_chars = {'╭','─', '╮', '│', '╯','─', '╰', '│'}
      vim.g.lazygit_floating_window_use_plenary = 0
      vim.g.lazygit_use_neovim_remote = 1
      vim.g.lazygit_use_custom_config_file_path = 1
      vim.g.lazygit_config_file_path = vim.fn.expand("~/.config/lazygit/config.yml")
    end,
    keys = {
      { "<leader>gg", "<cmd>LazyGit<cr>", desc = "Open LazyGit" },
      { "<leader>gG", "<cmd>LazyGitCurrentFile<cr>", desc = "Open LazyGit for current file" },
      { "<leader>gl", "<cmd>LazyGitFilter<cr>", desc = "Open LazyGit log" },
      { "<leader>gc", "<cmd>LazyGitFilterCurrentFile<cr>", desc = "Open LazyGit commits for current file" },
    },
  },
  {
    "akinsho/toggleterm.nvim",
    opts = {
      size = function(term)
        if term.direction == "horizontal" then
          return 15
        elseif term.direction == "vertical" then
          return vim.o.columns * 0.4
        end
      end,
      open_mapping = [[<c-\>]],
      hide_numbers = true,
      shade_terminals = false,
      start_in_insert = true,
      insert_mappings = true,
      terminal_mappings = true,
      persist_size = true,
      direction = "float",
      close_on_exit = true,
      shell = vim.o.shell,
      float_opts = {
        border = "curved",
        winblend = 0,
        highlights = {
          border = "Normal",
          background = "Normal",
        },
      },
    },
  },
}
```

### Custom Keybindings

Add these to your AstroNvim configuration for enhanced lazygit workflow:

**File: `~/.config/nvim/lua/user/mappings.lua`**

```lua
return {
  n = {
    -- Lazygit mappings
    ["<leader>g"] = { name = "Git" },
    ["<leader>gg"] = { "<cmd>LazyGit<cr>", desc = "Open LazyGit" },
    ["<leader>gG"] = { 
      function()
        local Terminal = require("toggleterm.terminal").Terminal
        local lazygit = Terminal:new({
          cmd = "lazygit",
          direction = "float",
          float_opts = {
            border = "curved",
            width = math.floor(vim.o.columns * 0.9),
            height = math.floor(vim.o.lines * 0.9),
          },
          on_open = function(term)
            vim.cmd("startinsert!")
            vim.api.nvim_buf_set_keymap(term.bufnr, "n", "q", "<cmd>close<CR>", {noremap = true, silent = true})
          end,
          on_close = function(term)
            vim.cmd("startinsert!")
          end,
        })
        lazygit:toggle()
      end,
      desc = "Open LazyGit (Float)"
    },
    ["<leader>gl"] = { 
      function()
        local Terminal = require("toggleterm.terminal").Terminal
        local lazygit_log = Terminal:new({
          cmd = "lazygit log",
          direction = "float",
          float_opts = {
            border = "curved",
          },
        })
        lazygit_log:toggle()
      end,
      desc = "LazyGit Log"
    },
    ["<leader>gf"] = { 
      function()
        local file = vim.fn.expand("%:p")
        if file ~= "" then
          local Terminal = require("toggleterm.terminal").Terminal
          local lazygit_file = Terminal:new({
            cmd = "lazygit -f " .. file,
            direction = "float",
            float_opts = {
              border = "curved",
            },
          })
          lazygit_file:toggle()
        end
      end,
      desc = "LazyGit Current File"
    },
  },
}
```````
