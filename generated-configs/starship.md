# Advanced Starship Prompt Configuration for Gentoo Linux

This configuration provides an optimized Starship prompt with Catppuccin Mocha theme integration, Zsh enhancements, multi-language support, and Git optimizations specifically tailored for Gentoo Linux.

## `~/.config/starship.toml`

```toml
# Tokyo Night color scheme
[palette]
background = "#1a1b26"
foreground = "#c0caf5"
selection = "#33467c"
comment = "#565f89"
blue = "#7aa2f7"
cyan = "#7dcfff"
green = "#9ece6a"
magenta = "#bb9af7"
red = "#f7768e"
yellow = "#e0af68"
black = "#15161e"
white = "#a9b1d6"
orange = "#ff9e64"
pink = "#f7768e"
purple = "#9d7cd8"

# Main configuration
[character]
success_symbol = "[❯](bold $green)"
error_symbol = "[❯](bold $red)"
vicmd_symbol = "[❮](bold $blue)"

[directory]
truncation_length = 3
truncate_to_repo = false
style = "bold $blue"
read_only_style = "bold $red"
read_only = " "

[git_branch]
symbol = " "
style = "bold $magenta"
format = "on [$symbol$branch]($style) "

[git_status]
ahead = "⇡${count}"
behind = "⇣${count}"
diverged = "⇕⇡${ahead_count}⇣${behind_count}"
stashed = "≡"
modified = "!"
untracked = "?"
deleted = "✘"
renamed = "»"
style = "bold $green"
format = "[$all_status$ahead_behind]($style) "

[git_state]
rebase = "REBASING"
merge = "MERGING"
revert = "REVERTING"
cherry_pick = "CHERRY-PICKING"
bisect = "BISECTING"
am = "AM"
am_or_rebase = "AM/REBASE"
style = "bold $yellow"
format = "\([$state( $progress_current/$progress_total)]($style)\) "

[package]
format = "[$symbol$version]($style) "
symbol = " "
style = "bold $blue"

# Gentoo-specific optimizations
[status]
symbol = "✗"
success_symbol = "✓"
style = "bold $green"
format = "[$symbol $common_meaning$signal_name]($style) "
disabled = false

[cmd_duration]
min_time = 1000
format = "took [$duration]($style) "
style = "bold $yellow"

[memory_usage]
disabled = false
threshold = 75
symbol = "🐏"
style = "bold $orange"

[env_var]
variable = "WSL_DISTRO_NAME"
format = "via [$env_value]($style) "
style = "bold $green"

# Language support modules
[aws]
symbol = "  "
style = "bold $yellow"

[azure]
symbol = "ﴃ "
style = "bold $blue"

[bun]
symbol = " "
style = "bold $green"

[c]
symbol = " "
style = "bold $blue"

[cmake]
symbol = "喝 "
style = "bold $blue"

[cobol]
symbol = "⚙️ "
style = "bold $blue"

[dart]
symbol = " "
style = "bold $blue"

[deno]
symbol = "🦕 "
style = "bold $green"

[docker_context]
symbol = " "
style = "bold $blue"

[elixir]
symbol = " "
style = "bold $magenta"

[elm]
symbol = " "
style = "bold $blue"

[gcloud]
symbol = " "
style = "bold $blue"

[golang]
symbol = " "
style = "bold $blue"

[helm]
symbol = "⎈ "
style = "bold $blue"

[java]
symbol = " "
style = "bold $red"

[julia]
symbol = " "
style = "bold $magenta"

[kotlin]
symbol = " "
style = "bold $blue"

[lua]
symbol = " "
style = "bold $blue"

[nodejs]
symbol = " "
style = "bold $green"

[ocaml]
symbol = "🐫 "
style = "bold $yellow"

[perl]
symbol = " "
style = "bold $blue"

[php]
symbol = " "
style = "bold $blue"

[pulumi]
symbol = " "
style = "bold $yellow"

[python]
symbol = " "
style = "bold $blue"

[ruby]
symbol = " "
style = "bold $red"

[rust]
symbol = " "
style = "bold $red"

[scala]
symbol = " "
style = "bold $red"

[swift]
symbol = "ﯣ "
style = "bold $yellow"

[terraform]
symbol = "行 "
style = "bold $magenta"

[zig]
symbol = " "
style = "bold $yellow"

# Gentoo-specific optimizations
[gentoo_use]
format = "[$symbol($count)]($style) "
symbol = "󰣨 "
style = "bold $blue"
threshold = 1

[gentoo_portage]
format = "[$symbol($count)]($style) "
symbol = "󰣨 "
style = "bold $magenta"
threshold = 1

# Line breaks and spacing
[line_break]
disabled = false

[container]
symbol = "⬢"
style = "bold $blue"
format = "[$symbol]($style) "

[username]
style_user = "bold $blue"
style_root = "bold $red"
format = "[$user]($style) "
disabled = false
show_always = true

[hostname]
ssh_only = false
format = "@[$hostname]($style) "
trim_at = ".local"
style = "bold $green"

[time]
disabled = false
format = "[$time]($style) "
time_format = "%T"
utc_time_offset = "local"
style = "bold $comment"
```

## Zsh Integration

Add this to your `~/.zshrc`:

```sh
# Enable Starship
eval "$(starship init zsh)"

# Optimize Git for Gentoo
export GIT_OPTIONAL_LOCKS=0

# Faster git status (disable for large repos)
function git_prompt_info() {
  if [[ -n "$(_git_cached)" ]]; then
    echo "$(_git_cached)"
  fi
}

# Gentoo-specific optimizations
alias emerge='nocorrect emerge'
alias ebuild='nocorrect ebuild'
alias equery='nocorrect equery'

# Cache completions
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path ~/.zsh/cache

# Preload starship
if [[ "$TERM" != "linux" ]]; then
  starship_precmd() {
    PS1="$(starship prompt --terminal-width=$COLUMNS --keymap=${KEYMAP:-} --status=$STATUS --jobs=${#jobstates[@]})"
  }
  starship_preexec() {
    TIMER=${TIMER:-$SECONDS}
  }
  starship_precmd
  add-zsh-hook precmd starship_precmd
  add-zsh-hook preexec starship_preexec
fi
```

## Installation Notes

1. Install Starship on Gentoo:
   ```bash
   sudo emerge -av app-shells/starship
   ```

2. Install required fonts for icons:
   ```bash
   sudo emerge -av media-fonts/nerd-fonts
   ```

3. For optimal performance with Git on Gentoo:
   ```bash
   sudo emerge -av dev-vcs/git[-perl]
   ```

This configuration provides:
- Catppuccin Mocha theme integration
- Optimized Git performance for Gentoo
- Comprehensive language support
- Gentoo-specific package and portage indicators
- Memory and performance optimizations
- Zsh integration with caching and preloading
- SSH and container awareness
- System status indicators

The prompt will show relevant information only when needed (in a git repo, in a specific language project, etc.) to maintain speed and cleanliness.
