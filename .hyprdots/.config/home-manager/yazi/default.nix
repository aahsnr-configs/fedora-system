# ~/.config/home-manager/yazi/default.nix
{ pkgs, ... }:
let
  # --- Application Paths ---
  nvim = "/usr/bin/nvim";
  file-roller = "/usr/bin/file-roller";
  imv = "/usr/bin/imv";
  mpv = "/usr/bin/mpv";
  zathura = "/usr/bin/zathura";
  xdg-open = "/usr/bin/xdg-open";

  # --- Plugin Dependencies ---
  pluginDeps = with pkgs; [ rich-cli ouch ];
in {
  # Install plugin dependencies alongside Yazi
  home.packages = pluginDeps;

  # Enable the Yazi program
  programs.yazi = {
    enable = true;
    enableZshIntegration = true;

    # --- Yazi Plugins ---
    # This section declaratively installs the plugins for Yazi.
    plugins = with pkgs.yaziPlugins; {
      # Essential
      inherit full-border toggle-pane smart-enter chmod;

      # Preview and Media
      inherit rich-preview ouch;

      # Navigation
      inherit jump-to-char;

      # Git and Development
      inherit git lazygit;

      # UI and Theming
      inherit starship yatline;
    };

    # This corresponds to your yazi.toml file
    settings = {
      manager = {
        show_hidden = false;
        show_symlink = true;
        linemode = "size";
        scrolloff = 5;
        mouse_events = [ "click" "scroll" ];
        title_format = "Yazi: {cwd}";
        sort_by = "natural";
        sort_dir_first = true;
        sort_reverse = false;
        sort_translit = false;
        tab_size = 4;
      };
      preview = {
        image_filter = "triangle";
        image_quality = 75;
        max_width = 600;
        max_height = 900;
        cache_dir = "";
        wrap = "no";
        tab_size = 2;
      };
      opener = {
        edit = [{
          run = ''${nvim} "$@"'';
          desc = "Edit with Neovim";
          block = true;
        }];
        archive = [{
          run = ''${file-roller} "$@"'';
          desc = "Open with File Roller";
        }];
        image = [{
          run = ''${imv} "$@"'';
          desc = "Open with Feh";
        }];
        video = [{
          run = ''${mpv} "$@"'';
          desc = "Play with mpv";
        }];
        audio = [{
          run = ''${mpv} "$@"'';
          desc = "Play with mpv";
        }];
        document = [{
          run = ''${zathura} "$@"'';
          desc = "Open with Zathura";
        }];
        fallback = [{
          run = ''${xdg-open} "$@"'';
          desc = "Open with default application";
        }];
      };
      open = {
        rules = [
          {
            name = "*/";
            use = "edit";
          }
          {
            mime = "text/*";
            use = "edit";
          }
          {
            mime = "image/*";
            use = "image";
          }
          {
            mime = "video/*";
            use = "video";
          }
          {
            mime = "audio/*";
            use = "audio";
          }
          {
            mime = "application/pdf";
            use = "document";
          }
          {
            mime = "application/*zip";
            use = "archive";
          }
          {
            mime = "application/x-tar";
            use = "archive";
          }
          {
            mime = "application/x-bzip2";
            use = "archive";
          }
          {
            mime = "application/x-gzip";
            use = "archive";
          }
          {
            mime = "application/x-7z-compressed";
            use = "archive";
          }
          {
            name = "*";
            use = "fallback";
          }
        ];
      };
      tasks = {
        micro_workers = 5;
        macro_workers = 10;
        bizarre_retry = 5;
        image_alloc = 536870912;
        image_bound = [ 0 0 ];
        suppress_preload = false;
      };
    };

    # This corresponds to your keymap.toml file
    keymap = {
      manager = {
        prepend = [
          # Navigation
          {
            on = "h";
            run = "leave";
            desc = "Go back to parent directory";
          }
          {
            on = "j";
            run = "arrow 1";
            desc = "Move cursor down";
          }
          {
            on = "k";
            run = "arrow -1";
            desc = "Move cursor up";
          }
          {
            on = "l";
            run = "enter";
            desc = "Enter directory";
          }
          {
            on = [ "g" "g" ];
            run = "arrow top";
            desc = "Move cursor to top";
          }
          {
            on = "G";
            run = "arrow bot";
            desc = "Move cursor to bottom";
          }
          {
            on = "<C-d>";
            run = "arrow 5";
            desc = "Move cursor down 5 lines";
          }
          {
            on = "<C-u>";
            run = "arrow -5";
            desc = "Move cursor up 5 lines";
          }
          {
            on = "<C-f>";
            run = "arrow 10";
            desc = "Move cursor down 10 lines";
          }
          {
            on = "<C-b>";
            run = "arrow -10";
            desc = "Move cursor up 10 lines";
          }
          # File operations
          {
            on = "y";
            run = "yank";
            desc = "Copy selected files";
          }
          {
            on = "x";
            run = "yank --cut";
            desc = "Cut selected files";
          }
          {
            on = "d";
            run = "yank --cut";
            desc = "Cut selected files";
          }
          {
            on = "p";
            run = "paste";
            desc = "Paste files";
          }
          {
            on = [ "d" "d" ];
            run = "remove";
            desc = "Remove selected files";
          }
          {
            on = "v";
            run = "visual_mode";
            desc = "Enter visual mode";
          }
          {
            on = "V";
            run = "visual_mode --unset";
            desc = "Enter visual mode (unset)";
          }
          {
            on = "a";
            run = "create";
            desc = "Create new file or directory";
          }
          {
            on = "r";
            run = "rename --cursor=before_ext";
            desc = "Rename selected file";
          }
          {
            on = "u";
            run = "undo";
            desc = "Undo last operation";
          }
          {
            on = "<C-r>";
            run = "redo";
            desc = "Redo last operation";
          }
          {
            on = "c";
            run = "cd --interactive";
            desc = "Change directory";
          }
          {
            on = "o";
            run = "open";
            desc = "Open file";
          }
          {
            on = "O";
            run = "open --interactive";
            desc = "Open file interactively";
          }
          # Search and find
          {
            on = "/";
            run = "find --smart";
            desc = "Find files";
          }
          {
            on = "n";
            run = "find_arrow";
            desc = "Go to next found file";
          }
          {
            on = "N";
            run = "find_arrow --previous";
            desc = "Go to previous found file";
          }
          {
            on = "f";
            run = "filter --smart";
            desc = "Filter files";
          }
          # Selection
          {
            on = "<Space>";
            run = "toggle";
            desc = "Toggle selection";
          }
          {
            on = "<C-a>";
            run = "toggle_all --state=on";
            desc = "Select all files";
          }
          {
            on = [ "g" "r" ];
            run = "toggle_all --state=off";
            desc = "Deselect all files";
          }
          {
            on = [ "g" "t" ];
            run = "toggle_all";
            desc = "Toggle selection for all files";
          }
          # Tabs
          {
            on = "t";
            run = "tab_create --current";
            desc = "Create new tab";
          }
          {
            on = "T";
            run = "tab_close 0";
            desc = "Close current tab";
          }
          {
            on = "w";
            run = "tab_close 0";
            desc = "Close current tab";
          }
          {
            on = "<C-t>";
            run = "tab_create --current";
            desc = "Create new tab";
          }
          {
            on = "<C-w>";
            run = "tab_close 0";
            desc = "Close current tab";
          }
          {
            on = "[";
            run = "tab_switch -1 --relative";
            desc = "Switch to previous tab";
          }
          {
            on = "]";
            run = "tab_switch 1 --relative";
            desc = "Switch to next tab";
          }
          {
            on = [ "g" "T" ];
            run = "tab_switch -1 --relative";
            desc = "Switch to previous tab";
          }
          {
            on = [ "g" "t" ];
            run = "tab_switch 1 --relative";
            desc = "Switch to next tab";
          }
          {
            on = "{";
            run = "tab_swap -1";
            desc = "Swap current tab with previous";
          }
          {
            on = "}";
            run = "tab_swap 1";
            desc = "Swap current tab with next";
          }
          # Tab switching with numbers
          {
            on = "1";
            run = "tab_switch 0";
            desc = "Switch to tab 1";
          }
          {
            on = "2";
            run = "tab_switch 1";
            desc = "Switch to tab 2";
          }
          {
            on = "3";
            run = "tab_switch 2";
            desc = "Switch to tab 3";
          }
          {
            on = "4";
            run = "tab_switch 3";
            desc = "Switch to tab 4";
          }
          {
            on = "5";
            run = "tab_switch 4";
            desc = "Switch to tab 5";
          }
          {
            on = "6";
            run = "tab_switch 5";
            desc = "Switch to tab 6";
          }
          {
            on = "7";
            run = "tab_switch 6";
            desc = "Switch to tab 7";
          }
          {
            on = "8";
            run = "tab_switch 7";
            desc = "Switch to tab 8";
          }
          {
            on = "9";
            run = "tab_switch 8";
            desc = "Switch to tab 9";
          }
          # Directory navigation
          {
            on = "~";
            run = "cd ~";
            desc = "Go to home directory";
          }
          {
            on = "-";
            run = "leave";
            desc = "Go to parent directory";
          }
          # Miscellaneous
          {
            on = "q";
            run = "quit";
            desc = "Quit yazi";
          }
          {
            on = "Q";
            run = "quit --no-cwd-file";
            desc = "Quit yazi without saving cwd";
          }
          {
            on = ":";
            run = "shell --interactive";
            desc = "Run shell command";
          }
          {
            on = "!";
            run = "shell --block";
            desc = "Run shell command and wait";
          }
          {
            on = "?";
            run = "help";
            desc = "Show help";
          }
          {
            on = "<Esc>";
            run = "escape";
            desc = "Exit current mode";
          }
          {
            on = "<C-l>";
            run = "refresh";
            desc = "Refresh current directory";
          }
          {
            on = "<C-h>";
            run = "hidden toggle";
            desc = "Toggle hidden files";
          }
          {
            on = "<C-s>";
            run = "spot";
            desc = "Peek file content";
          }
          {
            on = "<C-z>";
            run = "suspend";
            desc = "Suspend yazi";
          }
          {
            on = "i";
            run = "spot";
            desc = "Inspect file";
          }
          {
            on = "R";
            run = "refresh";
            desc = "Refresh current directory";
          }
          # Sorting
          {
            on = [ "s" "n" ];
            run = "sort natural";
            desc = "Sort naturally";
          }
          {
            on = [ "s" "s" ];
            run = "sort size";
            desc = "Sort by size";
          }
          {
            on = [ "s" "m" ];
            run = "sort mtime";
            desc = "Sort by modified time";
          }
          {
            on = [ "s" "c" ];
            run = "sort btime";
            desc = "Sort by created time";
          }
          {
            on = [ "s" "e" ];
            run = "sort extension";
            desc = "Sort by extension";
          }
          {
            on = [ "s" "r" ];
            run = "sort reverse";
            desc = "Reverse sort order";
          }
        ];
      };
      input = {
        prepend = [
          {
            on = "<Esc>";
            run = "close";
            desc = "Cancel input";
          }
          {
            on = "<C-c>";
            run = "close";
            desc = "Cancel input";
          }
          {
            on = "<C-n>";
            run = "move 1";
            desc = "Move cursor down in history";
          }
          {
            on = "<C-p>";
            run = "move -1";
            desc = "Move cursor up in history";
          }
          {
            on = "<C-f>";
            run = "forward";
            desc = "Move cursor forward";
          }
          {
            on = "<C-b>";
            run = "backward";
            desc = "Move cursor backward";
          }
          {
            on = "<C-a>";
            run = "move -999";
            desc = "Move cursor to start";
          }
          {
            on = "<C-e>";
            run = "move 999";
            desc = "Move cursor to end";
          }
          {
            on = "<C-u>";
            run = "kill bol";
            desc = "Kill from cursor to beginning of line";
          }
          {
            on = "<C-k>";
            run = "kill eol";
            desc = "Kill from cursor to end of line";
          }
          {
            on = "<C-w>";
            run = "kill backward";
            desc = "Kill word backward";
          }
          {
            on = "<C-d>";
            run = "delete";
            desc = "Delete character forward";
          }
          {
            on = "<C-h>";
            run = "backspace";
            desc = "Delete character backward";
          }
          {
            on = "<Backspace>";
            run = "backspace";
            desc = "Delete character backward";
          }
          {
            on = "<Delete>";
            run = "delete";
            desc = "Delete character forward";
          }
          {
            on = "<Enter>";
            run = "close --submit";
            desc = "Submit input";
          }
        ];
      };
      tasks = {
        prepend = [
          {
            on = "<Esc>";
            run = "close";
            desc = "Close task manager";
          }
          {
            on = "<C-c>";
            run = "close";
            desc = "Close task manager";
          }
          {
            on = "j";
            run = "arrow 1";
            desc = "Move cursor down";
          }
          {
            on = "k";
            run = "arrow -1";
            desc = "Move cursor up";
          }
          {
            on = "w";
            run = "inspect";
            desc = "Inspect task";
          }
          {
            on = "c";
            run = "cancel";
            desc = "Cancel task";
          }
        ];
      };
      help = {
        prepend = [
          {
            on = "<Esc>";
            run = "close";
            desc = "Close help";
          }
          {
            on = "<C-c>";
            run = "close";
            desc = "Close help";
          }
          {
            on = "j";
            run = "arrow 1";
            desc = "Move cursor down";
          }
          {
            on = "k";
            run = "arrow -1";
            desc = "Move cursor up";
          }
          {
            on = "<C-d>";
            run = "arrow 5";
            desc = "Move cursor down 5 lines";
          }
          {
            on = "<C-u>";
            run = "arrow -5";
            desc = "Move cursor up 5 lines";
          }
        ];
      };
      confirm = {
        prepend = [
          {
            on = "<Esc>";
            run = "close";
            desc = "Cancel confirmation";
          }
          {
            on = "<C-c>";
            run = "close";
            desc = "Cancel confirmation";
          }
          {
            on = "j";
            run = "arrow 1";
            desc = "Move cursor down";
          }
          {
            on = "k";
            run = "arrow -1";
            desc = "Move cursor up";
          }
          {
            on = "<Enter>";
            run = "close --submit";
            desc = "Submit confirmation";
          }
        ];
      };
      pick = {
        prepend = [
          {
            on = "<Esc>";
            run = "close";
            desc = "Cancel picker";
          }
          {
            on = "<C-c>";
            run = "close";
            desc = "Cancel picker";
          }
          {
            on = "j";
            run = "arrow 1";
            desc = "Move cursor down";
          }
          {
            on = "k";
            run = "arrow -1";
            desc = "Move cursor up";
          }
          {
            on = "<Enter>";
            run = "close --submit";
            desc = "Submit selection";
          }
        ];
      };
      completion = {
        # Note: The TOML section was [cmp], which maps to `completion` here
        prepend = [
          {
            on = "<Esc>";
            run = "close";
            desc = "Cancel completion";
          }
          {
            on = "<C-c>";
            run = "close";
            desc = "Cancel completion";
          }
          {
            on = "j";
            run = "arrow 1";
            desc = "Move cursor down";
          }
          {
            on = "k";
            run = "arrow -1";
            desc = "Move cursor up";
          }
          {
            on = "<Enter>";
            run = "close --submit";
            desc = "Submit completion";
          }
        ];
      };
      spot = {
        prepend = [
          {
            on = "<Esc>";
            run = "close";
            desc = "Close spotter";
          }
          {
            on = "<C-c>";
            run = "close";
            desc = "Close spotter";
          }
          {
            on = "j";
            run = "arrow 1";
            desc = "Move cursor down";
          }
          {
            on = "k";
            run = "arrow -1";
            desc = "Move cursor up";
          }
          {
            on = "<C-d>";
            run = "arrow 5";
            desc = "Move cursor down 5 lines";
          }
          {
            on = "<C-u>";
            run = "arrow -5";
            desc = "Move cursor up 5 lines";
          }
        ];
      };
    };
  };
}
