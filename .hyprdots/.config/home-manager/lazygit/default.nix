# ~/.config/home-manager/lazygit/default.nix
{ config, pkgs, ... }:

{
  # 1. Install necessary packages for lazygit and its integrations.
  home.packages = with pkgs; [
    delta # The pager for git diffs.
  ];

  # 2. Configure and enable the lazygit program.
  programs.lazygit = {
    enable = true;
    settings = {
      gui = {
        # NOTE: The theme is intentionally omitted as per instructions,
        # to be handled by the catppuccin/nix flake.
        scrollHeight = 2;
        scrollPastBottom = true;
        mouseEvents = true;
        skipDiscardChangeWarning = false;
        skipStashWarning = false;
        showFileTree = true;
        showListFooter = true;
        showRandomTip = true;
        showBranchCommitHash = true;
        showBottomLine = true;
        showPanelJumps = true;
        showCommandLog = true;
        nerdFontsVersion = "3";
        commitLength.show = true;
        splitDiff = "auto";
        skipRewordInEditorWarning = false;
        border = "rounded";
        animateExpansion = true;
        portraitMode = "auto";
        filterMode = "substring";
        spinner = {
          frames = [ "⠋" "⠙" "⠹" "⠸" "⠼" "⠴" "⠦" "⠧" "⠇" "⠏" ];
          rate = 50;
        };
      };

      keybinding = {
        universal = {
          quit = "q";
          "quit-alt1" = "<c-c>";
          "return" = "<esc>";
          quitWithoutChangingDirectory = "Q";
          togglePanel = "<tab>";
          prevItem = "k";
          nextItem = "j";
          "prevItem-alt" = "<up>";
          "nextItem-alt" = "<down>";
          prevPage = "<c-u>";
          nextPage = "<c-d>";
          scrollLeft = "H";
          scrollRight = "L";
          gotoTop = "<home>";
          gotoBottom = "<end>";
          toggleRangeSelect = "v";
          rangeSelectDown = "J"; # Corrected from <s-j>
          rangeSelectUp = "K";   # Corrected from <s-k>
          prevBlock = "<left>";
          nextBlock = "<right>";
          "prevBlock-alt" = "h";
          "nextBlock-alt" = "l";
          nextTab = "]";
          prevTab = "[";
          nextScreenMode = "+";
          prevScreenMode = "_";
          undo = "z";
          redo = "<c-z>";
          filteringMenu = "<c-s>";
          diffingMenu = "W";
          "diffingMenu-alt" = "<c-e>";
          copyToClipboard = "<c-o>";
          openRecentRepos = "<c-r>";
          submitEditorText = "<enter>";
          extrasMenu = "@";
          toggleWhitespaceInDiffView = "<c-w>";
          increaseContextInDiffView = "}";
          decreaseContextInDiffView = "{";
          increaseRenameSimilarityThreshold = ")";
          decreaseRenameSimilarityThreshold = "(";
          openDiffTool = "<c-t>";
        };
        status = {
          checkForUpdate = "u";
          recentRepos = "<enter>";
          allBranchesLogGraph = "a";
        };
        files = {
          commitChanges = "c";
          commitChangesWithoutHook = "C";
          amendLastCommit = "A";
          commitChangesWithEditor = "<c-o>";
          findBaseCommitForFixup = "<c-f>";
          confirmDiscard = "x";
          ignoreFile = "i";
          refreshFiles = "r";
          stashAllChanges = "s";
          viewStashOptions = "S";
          toggleStagedAll = "a";
          viewResetOptions = "D";
          fetch = "f";
          toggleTreeView = "`";
          openStatusFilter = "<c-b>";
        };
        branches = {
          createPullRequest = "o";
          viewPullRequestOptions = "O";
          copyPullRequestURL = "<c-y>";
          checkoutBranch = "<space>";
          "checkoutBranch-alt" = "c";
          forceCheckoutBranch = "F";
          rebaseBranch = "r";
          renameBranch = "R";
          mergeIntoCurrentBranch = "m";
          viewBranchOptions = "M";
          fastForward = "f";
          createTag = "T";
          push = "P";
          pull = "p";
          setUpstream = "u";
          fetchRemote = "f";
          sortOrder = "s";
          gitFlowOptions = "i";
          createResetToBranchMenu = "g";
          viewResetOptions = "R";
          deleteBranch = "d";
          copyToClipboard = "y";
        };
        worktrees = {
          viewWorktreeOptions = "w";
        };
        commits = {
          squashDown = "s";
          renameCommit = "r";
          renameCommitWithEditor = "R";
          viewResetOptions = "g";
          markCommitAsFixup = "f";
          createFixupCommit = "F";
          squashAboveCommits = "S";
          moveDownCommit = "<c-j>";
          moveUpCommit = "<c-k>";
          amendToCommit = "A";
          amendAttributeMenu = "a";
          pickCommit = "p";
          revertCommit = "t";
          cherryPickCopy = "c";
          pasteCommits = "v";
          markCommitAsBaseForRebase = "B";
          tagCommit = "T";
          checkoutCommit = "<space>";
          resetCherryPick = "<c-r>";
          copyCommitAttributeToClipboard = "y";
          openLogMenu = "<c-l>";
          openInBrowser = "o";
          viewBisectOptions = "b";
          startInteractiveRebase = "i";
        };
        amendAttribute = {
          resetAuthor = "a";
          setAuthor = "A";
          addCoAuthor = "c";
        };
        stash = {
          popStash = "g";
          renameStash = "r";
          applyStash = "a";
          viewStashOptions = "<enter>";
          dropStash = "d";
        };
        commitFiles = {
          checkoutCommitFile = "c";
        };
        main = {
          pickBothHunks = "b";
          editSelectHunk = "e";
          openFile = "o";
          openDiffTool = "<c-t>";
          refreshStagingPanel = "r";
          stageSelection = "s";
          resetSelection = "r";
          togglePanel = "<tab>";
          prevConflict = "[";
          nextConflict = "]";
          selectPrevConflict = "<";
          selectNextConflict = ">";
          selectPrevHunk = "K";
          selectNextHunk = "J";
          undo = "z";
          redo = "<c-z>";
          toggleDragSelect = "v";
          "toggleDragSelect-alt" = "V";
          toggleSelectHunk = "a";
          copyToClipboard = "<c-o>";
        };
        submodules = {
          init = "i";
          update = "u";
          bulkMenu = "b";
          "delete" = "d";
          enter = "<enter>";
        };
        commitMessage = {
          confirm = "<enter>";
          switchToEditor = "<c-o>";
        };
      };

      os = {
        editCommand = "nvim";
        editCommandTemplate = "{{editor}} \"{{filename}}\"";
        editPreset = "nvim";
        openCommand = "xdg-open";
        openLinkCommand = "xdg-open {{link}}";
        copyToClipboardCmd = "wl-copy";
        readFromClipboardCmd = "wl-paste";
      };

      update = {
        method = "prompt";
        days = 14;
      };

      refresher = {
        refreshInterval = 10;
        fetchInterval = 60;
      };

      confirmOnQuit = false;
      quitOnTopLevelReturn = false;
      disableStartupPopups = true;
      notARepository = "prompt";

      customCommands = [
        {
          key = "E";
          command = "git commit --amend --no-edit";
          context = "commits";
          description = "Amend commit without editing message";
          output = "log";
        }
        {
          key = "n";
          command = "nvim {{.SelectedFile.Name}}";
          context = "files";
          description = "Open file in AstroNvim";
          output = "terminal";
        }
        {
          key = "T";
          command = "nvim -c \"lua require(\\\"telescope.builtin\\\").git_files()\"";
          context = "global";
          description = "Open AstroNvim with Telescope git files";
          output = "terminal";
        }
        {
          key = "H";
          command = "nvim -c \"lua require(\\\"telescope.builtin\\\").git_bcommits()\" {{.SelectedFile.Name}}";
          context = "files";
          description = "View file history with Telescope";
          output = "terminal";
        }
        {
          key = "I";
          command = "git rebase -i {{.SelectedLocalCommit.Sha}}^";
          context = "commits";
          description = "Interactive rebase from selected commit";
          output = "terminal";
        }
        {
          key = "B";
          command = "nvim -c \"lua require(\\\"telescope.builtin\\\").git_branches()\"";
          context = "localBranches";
          description = "Browse branches with Telescope";
          output = "terminal";
        }
        {
          key = "/";
          command = "nvim -c \"lua require(\\\"telescope.builtin\\\").git_commits()\"";
          context = "commits";
          description = "Search commits with Telescope";
          output = "terminal";
        }
        {
          key = "D";
          command = "nvim -c \"Gvdiffsplit\" {{.SelectedFile.Name}}";
          context = "files";
          description = "View diff in AstroNvim with fugitive";
          output = "terminal";
        }
        {
          key = "P";
          command = "git push --force-with-lease";
          context = "global";
          description = "Force push with lease (safer)";
          output = "log";
        }
        {
          key = "S";
          command = "git stash push -m \"{{.Form.Message}}\"";
          context = "files";
          description = "Stash with custom message";
          prompts = [
            {
              type = "input";
              key = "Message";
              title = "Stash Message";
              initialValue = "WIP: ";
            }
          ];
          output = "log";
        }
        {
          key = "o";
          command = "nvim .";
          context = "global";
          description = "Open current repository in AstroNvim";
          output = "terminal";
        }
        {
          key = "b";
          command = "nvim -c \"Git blame\" {{.SelectedFile.Name}}";
          context = "files";
          description = "View git blame in AstroNvim";
          output = "terminal";
        }
        {
          key = "v";
          command = "nvim -c \"G stash show -p {{.SelectedStashEntry.Index}}\"";
          context = "stash";
          description = "View stash content in AstroNvim";
          output = "terminal";
        }
        {
          key = "M";
          command = "nvim -c \"Gvdiffsplit!\" {{.SelectedFile.Name}}";
          context = "files";
          description = "Open merge tool in AstroNvim";
          output = "terminal";
        }
        {
          key = "N";
          command = "git checkout -b {{.Form.BranchName}}";
          context = "localBranches";
          description = "Create new branch";
          prompts = [
            {
              type = "input";
              key = "BranchName";
              title = "Branch Name";
              initialValue = "feature/";
            }
          ];
          output = "log";
        }
        {
          key = "C";
          command = "git cherry-pick --edit {{.SelectedLocalCommit.Sha}}";
          context = "commits";
          description = "Cherry pick with edit";
          output = "terminal";
        }
        {
          key = "R";
          command = "nvim -c \"lua require(\\\"telescope.builtin\\\").git_branches({show_remote_tracking_branches=true})\"";
          context = "remoteBranches";
          description = "Browse remote branches with Telescope";
          output = "terminal";
        }
      ];

      services = {
        "github.com" = "https://github.com";
        "gitlab.com" = "https://gitlab.com";
      };

      performance = {
        useAsyncGit = true;
        reportRuntimeErrors = true;
      };
    };
  };
}
