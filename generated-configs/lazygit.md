# Advanced Lazygit Configuration for Gentoo with Vim Keybindings, Catppuccin Mocha Theme, and Neovim Integration

Here's an optimized `lazygit` configuration tailored for Gentoo Linux with your requested features:

## ~/.config/lazygit/config.yml

```yaml
gui:
  # TokyoNight Night theme
  theme:
    lightTheme: false
    activeBorderColor:
      - '#7aa2f7'
      - bold
    inactiveBorderColor:
      - '#3b4261'
    optionsTextColor:
      - '#7dcfff'
    selectedLineBgColor:
      - '#292e42'
    selectedRangeBgColor:
      - '#292e42'
    cherryPickedCommitBgColor:
      - '#292e42'
    cherryPickedCommitFgColor:
      - '#9ece6a'
    unstagedChangesColor:
      - '#f7768e'
    defaultFgColor:
      - '#a9b1d6'
    searchingActiveBorderColor:
      - '#ff9e64'

  # Vim-like keybindings
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
      startSearch: '/'
      optionMenu: '?'
      optionMenu-alt1: ''

    status:
      checkForUpdate: 'u'
      recentRepos: '<enter>'

    files:
      commitChanges: 'c'
      commitChangesWithoutHook: 'C'
      amendLastCommit: 'A'
      commitChangesWithEditor: '<c-o>'
      ignoreFile: 'i'
      refreshFiles: 'r'
      stashAllChanges: 's'
      viewStashOptions: 'S'
      toggleStagedAll: 'a'
      viewResetOptions: 'D'
      fetch: 'f'
      toggleTreeView: '`'

    branches:
      createPullRequest: 'o'
      viewPullRequestOptions: 'O'
      checkoutBranch: '<space>'
      checkoutBranch-alt: 'c'
      forceCheckoutBranch: 'F'
      rebaseBranch: 'r'
      mergeIntoCurrentBranch: 'm'
      viewBranchOptions: 'M'
      fastForward: 'f'
      push: 'P'
      pull: 'p'
      renameBranch: 'R'
      createResetToBranchMenu: 'g'
      deleteBranch: 'd'
      copyToClipboard: 'y'

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
      pickCommit: 'p'
      revertCommit: 't'
      cherryPickCopy: 'c'
      cherryPickCopyRange: 'C'
      pasteCommits: 'v'
      tagCommit: 'T'
      checkoutCommit: '<space>'
      resetCherryPick: '<c-r>'
      copyCommitAttributeToClipboard: 'y'

    stash:
      popStash: 'g'
      applyStash: 'a'
      viewStashOptions: '<space>'
      dropStash: 'd'

    commitFiles:
      checkoutCommitFile: 'c'

    main:
      toggleDragSelect: 'v'
      toggleDragSelect-alt: 'V'
      toggleSelectHunk: 'a'
      pickBothHunks: 'b'
      editSelectHunk: 'e'
      openFile: 'o'
      openFile-alt: '<space>'
      openMergeTool: 'M'
      openDiffTool: 'd'
      refresh: 'r'
      stageSelection: 's'
      unstageSelection: 'u'
      togglePanel: '<tab>'
      prevConflict: '<'
      nextConflict: '>'
      selectPrevConflict: '['
      selectNextConflict: ']'
      undo: 'U'
      redo: '<c-r>'

    submodules:
      init: 'i'
      update: 'u'
      bulkMenu: 'b'
      delete: 'd'

    commitMessage:
      confirm: '<enter>'
      switchToEditor: '<c-o>'

git:
  paging:
    colorArg: always
    pager: delta --dark --paging=never

os:
  editCommand: nvim
  editCommandTemplate: '{{editor}} "{{filename}}"'
  openCommand: xdg-open

customCommands:
  - key: 'e'
    command: 'git commit --amend --no-edit'
    context: 'commits'
    description: 'Amend commit without editing message'
  - key: 'E'
    command: 'nvim -c "Gedit {{commitHash}}:"'
    context: 'commits'
    description: 'Edit commit in Neovim'
  - key: 'n'
    command: 'nvim {{filename}}'
    context: 'files'
    description: 'Open file in Neovim'
  - key: 'N'
    command: 'nvim +"Gedit {{branchName}}:"'
    context: 'branches'
    description: 'Open branch in Neovim fugitive'

notARepository: skip
disableStartupPopups: true
```

## Installation and Setup on Gentoo

1. First, ensure you have Lazygit installed on Gentoo:

```bash
sudo emerge -a dev-vcs/lazygit
```

2. Install the required dependencies:

```bash
sudo emerge -a app-editors/neovim dev-vcs/git app-shells/delta
```

3. Create the config directory if it doesn't exist:

```bash
mkdir -p ~/.config/lazygit
```

4. Save the above configuration to `~/.config/lazygit/config.yml`

5. For optimal Neovim integration, ensure you have these plugins in your Neovim configuration:

```lua
-- In your init.lua or equivalent
return require('packer').startup(function(use)
  use 'tpope/vim-fugitive'  -- Git integration
  use 'lewis6991/gitsigns.nvim'  -- Git signs in gutter
  use 'catppuccin/nvim'  -- Catppuccin theme
end)
```

## Additional Recommendations

1. For full Catppuccin Mocha theme consistency, add this to your Neovim config:

```lua
vim.cmd.colorscheme('catppuccin-mocha')
```

2. Consider adding these Gentoo-specific optimizations to your shell rc file:

```bash
# Optimize lazygit for Gentoo
export LAZYGIT_USE_SYSTEM_GIT=1
export LAZYGIT_NEW_DIR_FILE=~/.local/share/lazygit/newdir
```

This configuration provides:
- Full Vim keybindings
- Catppuccin Mocha theme
- Deep Neovim integration
- Gentoo-optimized settings
- Delta pager for beautiful diffs
- Custom commands for efficient workflow

The configuration is designed to be both performant and visually consistent with your development environment.
