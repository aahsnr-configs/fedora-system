{...}: {
  programs.starship = {
    enable = true;
    enableZshIntegration = true;

    settings = {
      # --- Core Layout Settings ---
      add_newline = false;
      continuation_prompt = "[>>](bold mauve) ";
      format = "$character";
      right_format = "$directory$git_branch$git_status$package$rust$nodejs$python$time";

      # --- Catppuccin Macchiato Palette ---
      palette = "catppuccin_macchiato";
      palettes.catppuccin_macchiato = {
        rosewater = "#f4dbd6";
        flamingo = "#f0c6c6";
        pink = "#f5bde6";
        mauve = "#c6a0f6";
        red = "#ed8796";
        maroon = "#ee99a0";
        peach = "#f5a97f";
        yellow = "#eed49f";
        green = "#a6da95";
        teal = "#8bd5ca";
        sky = "#91d7e3";
        sapphire = "#7dc4e4";
        blue = "#8aadf4";
        lavender = "#b7bdf8";
        text = "#cad3f5";
        subtext1 = "#b8c0e0";
        subtext0 = "#a5adce";
        overlay2 = "#939ab7";
        overlay1 = "#8087a2";
        overlay0 = "#6e738d";
        surface2 = "#5b6078";
        surface1 = "#494d64";
        surface0 = "#363a4f";
        base = "#24273a";
        mantle = "#1e2030";
        crust = "#181926";
      };

      # --- Screenshot-Specific Module Configurations ---

      character = {
        format = "$symbol ";
        success_symbol = "[◎](bold yellow)";
        error_symbol = "[○](bold subtext0)";
        vimcmd_symbol = "[■](bold green)";
      };

      directory = {
        use_os_path_sep = true;
        style = "bold blue";
        format = "[□ $path]($style) ";
        truncation_symbol = "…/";
        home_symbol = "⌂";
        read_only = " ◈";
        repo_root_style = "bold blue";
        repo_root_format = "[$before_root_path]($before_repo_root_style)[$repo_root]($repo_root_style)[$path]($style)[$read_only]($read_only_style) [△](bold blue)";
      };

      time = {
        disabled = false;
        format = "[⌂ $time]($style) ";
        time_format = "%R";
        style = "mauve";
      };

      git_branch = {
        format = "[$symbol$branch]($style) ";
        symbol = "△ ";
        style = "bold blue";
      };

      git_status = {
        style = "bold blue";
        format = "[|$all_status$ahead_behind|]($style) ";
        staged = "▪\${count}";
        modified = "●\${count}";
        untracked = "○\${count}";
        deleted = "✕\${count}";
        conflicted = "[◪◦](italic pink)";
        ahead = "[▴│[\${count}](bold text)│](italic green)";
        behind = "[▿│[\${count}](bold text)│](italic red)";
        diverged = "[◇ ▴┤[\${ahead_count}](regular text)│▿┤[\${behind_count}](regular text)│](italic pink)";
        stashed = "[◃◈](italic text)";
        renamed = "[◎◦](italic blue)";
      };

      package = {
        format = "[pkg $symbol$version]($style) ";
        symbol = "◨ ";
        style = "bold yellow";
        version_format = "\${raw}";
      };

      rust = {
        format = "[rs $symbol$version]($style) ";
        symbol = "⊃ ";
        style = "bold red";
        version_format = "\${raw}";
      };

      nodejs = {
        format = "[node $symbol$version]($style) ";
        symbol = "◫ ";
        style = "bold green";
        version_format = "\${raw}";
        detect_files = ["package-lock.json" "yarn.lock"];
        detect_folders = ["node_modules"];
        detect_extensions = [];
      };

      python = {
        format = "[py $symbol$version]($style) ";
        symbol = "⌊ ";
        style = "bold yellow";
        version_format = "\${raw}";
      };

      # --- Comprehensive Modules from jetpack.txt ---

      fill.symbol = " ";
      env_var.VIMSHELL = {
        format = "[$env_value]($style)";
        style = "green italic";
      };
      sudo = {
        format = "[$symbol]($style)";
        style = "bold italic mauve";
        symbol = "⋈┈";
        disabled = false;
      };
      username = {
        style_user = "yellow bold italic";
        style_root = "mauve bold italic";
        format = "[⭘ $user]($style) ";
        disabled = false;
        show_always = false;
      };
      cmd_duration = {format = "[◄ $duration ](italic text)";};
      jobs = {
        format = "[$symbol$number]($style) ";
        style = "text";
        symbol = "[▶](blue italic)";
      };
      localip = {
        ssh_only = true;
        format = " ◯[$localipv4](bold pink)";
        disabled = false;
      };
      battery = {
        format = "[ $percentage $symbol]($style)";
        full_symbol = "█";
        charging_symbol = "[↑](italic bold green)";
        discharging_symbol = "↓";
        unknown_symbol = "░";
        empty_symbol = "▃";
        display = [
          {
            threshold = 20;
            style = "italic bold red";
          }
          {
            threshold = 60;
            style = "italic dimmed mauve";
          }
          {
            threshold = 70;
            style = "italic dimmed yellow";
          }
        ];
      };
      git_metrics = {
        format = "([▴$added]($added_style))([▿$deleted]($deleted_style))";
        added_style = "italic dimmed green";
        deleted_style = "italic dimmed red";
        ignore_submodules = true;
        disabled = false;
      };
      deno = {
        format = " [deno](italic) [∫ $version](green bold)";
        version_format = "\${raw}";
      };
      lua = {
        format = "[lua](italic) [\${symbol}\${version}]($style)";
        version_format = "\${raw}";
        symbol = "⨀ ";
        style = "bold yellow";
      };
      ruby = {
        format = "[rb](italic) [\${symbol}\${version}]($style)";
        symbol = "◆ ";
        version_format = "\${raw}";
        style = "bold red";
      };
      swift = {
        format = "[sw](italic) [\${symbol}\${version}]($style)";
        symbol = "◁ ";
        style = "bold red";
        version_format = "\${raw}";
      };
      aws = {
        disabled = true;
        format = " [aws](italic) [$symbol $profile $region]($style)";
        style = "bold blue";
        symbol = "▲ ";
      };
      buf = {
        symbol = "■ ";
        format = " [buf](italic) [$symbol $version $buf_version]($style)";
      };
      c = {
        symbol = "ℂ ";
        format = " [$symbol($version(-$name))]($style)";
      };
      cpp = {
        symbol = "ℂ ";
        format = " [$symbol($version(-$name))]($style)";
      };
      conda = {
        symbol = "◯ ";
        format = " conda [$symbol$environment]($style)";
      };
      pixi = {
        symbol = "■ ";
        format = " pixi [$symbol$version ($environment )]($style)";
      };
      dart = {
        symbol = "◁◅ ";
        format = " dart [$symbol($version )]($style)";
      };
      docker_context = {
        symbol = "◧ ";
        format = " docker [$symbol$context]($style)";
      };
      elixir = {
        symbol = "△ ";
        format = " exs [$symbol $version OTP $otp_version ]($style)";
      };
      elm = {
        symbol = "◩ ";
        format = " elm [$symbol($version )]($style)";
      };
      golang = {
        symbol = "∩ ";
        format = " go [$symbol($version )]($style)";
      };
      haskell = {
        symbol = "❯λ ";
        format = " hs [$symbol($version )]($style)";
      };
      java = {
        symbol = "∪ ";
        format = "java [\${symbol}(\${version} )]($style)";
      };
      julia = {
        symbol = "◎ ";
        format = " jl [$symbol($version )]($style)";
      };
      memory_usage = {
        symbol = "▪▫▪ ";
        format = "mem [\${ram}( \${swap})]($style)";
      };
      nim = {
        symbol = "▴▲▴ ";
        format = " nim [$symbol($version )]($style)";
      };
      nix_shell = {
        style = "bold italic dimmed blue";
        symbol = "✶";
        format = "[$symbol nix⎪$state⎪]($style) [$name](italic dimmed text)";
        impure_msg = "[⌽](bold dimmed red)";
        pure_msg = "[⌾](bold dimmed green)";
        unknown_msg = "[◌](bold dimmed yellow)";
      };
      spack = {
        symbol = "◇ ";
        format = " spack [$symbol$environment]($style)";
      };
    };
  };
}
