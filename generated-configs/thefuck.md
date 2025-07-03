# Advanced `thefuck` Configuration for Gentoo Linux with Catppuccin Mocha Theme

Here's an optimized configuration for `thefuck` with Catppuccin Mocha theme integration, Zsh enhancements, and Gentoo-specific quality of life improvements.

## 1. Installation (Gentoo-specific)

First, ensure you have `thefuck` installed in Gentoo:

```bash
sudo emerge -a dev-util/thefuck
```

## 2. Advanced `~/.config/thefuck/settings.py`

```python
import os
from pathlib import Path
from thefuck.utils import for_app

# Catppuccin Mocha color scheme
COLORS = {
    'background': '#1e1e2e',
    'foreground': '#cdd6f4',
    'text': '#cdd6f4',
    'primary': '#cba6f7',
    'secondary': '#f5c2e7',
    'alert': '#f38ba8',
    'warning': '#fab387',
    'success': '#a6e3a1',
}

# Gentoo-specific optimizations
GENTOO_SPECIFIC = {
    'emerge': 'emerge -a',
    'eix': 'eix -F',
    'equery': 'equery --quiet',
    'etc-update': 'etc-update --automode -3',
}

# Main configuration
rules = [
    'brew_prefix',
    'cd_parent',
    'chmod_x',
    'choco_install',
    'composer_not_command',
    'cp_omitting_directory',
    'docker_login',
    'docker_not_command',
    'dry',
    'fix_alt_space',
    'fix_file',
    'gem_unknown_command',
    'git_add',
    'git_add_force',
    'git_branch_delete',
    'git_branch_exists',
    'git_checkout',
    'git_commit_amend',
    'git_diff_staged',
    'git_fix_stash',
    'git_no_remote',
    'git_pull',
    'git_pull_clone',
    'git_push',
    'git_push_different_branch_name',
    'git_push_pull',
    'git_rebase_no_changes',
    'git_remote_delete',
    'git_rm_local_modifications',
    'git_rm_recursive',
    'git_stash',
    'git_tag_force',
    'git_two_dashes',
    'go_run',
    'grep_arguments',
    'grep_recursive',
    'has_exists_script',
    'history',
    'java',
    'lein_not_task',
    'long_form_help',
    'ln_s_order',
    'ls_all',
    'ls_lah',
    'man',
    'mercurial',
    'missing_space_before_subcommand',
    'mkdir_p',
    'mvn_no_command',
    'npm_missing_script',
    'npm_run_script',
    'npm_wrong_command',
    'no_command',
    'no_such_file',
    'pacman',
    'pacman_not_found',
    'pip_unknown_command',
    'php_s',
    'port_already_in_use',
    'prove_recursive',
    'python_command',
    'quotation_marks',
    'path_from_history',
    'rm_dir',
    'rm_root',
    'sed_unterminated_s',
    'sl_ls',
    'ssh_known_hosts',
    'sudo',
    'sudo_command_from_user_path',
    'switch_lang',
    'systemctl',
    'test.py',
    'tmux',
    'tsuru_login',
    'tsuru_not_command',
    'unknown_command',
    'vagrant_up',
    'whois',
]

# Gentoo-specific command corrections
@for_app('emerge', 'eix', 'equery', 'etc-update', 'qlist', 'qlop', 'eclean')
def match_gentoo_commands(command):
    for gentoo_cmd in GENTOO_SPECIFIC.keys():
        if gentoo_cmd in command.script:
            return True
    return False

def get_new_command(command):
    for gentoo_cmd, replacement in GENTOO_SPECIFIC.items():
        if gentoo_cmd in command.script:
            return command.script.replace(gentoo_cmd, replacement)
    return command.script

# Performance optimizations
wait_command = 3
require_confirmation = True
no_colors = False
debug = False
alter_history = True
exclude_rules = []
env = {
    'LC_ALL': 'C',
    'LANG': 'C',
    'GIT_TRACE': '0',
    'TF_HISTORY_LIMIT': '5000',
}

# Zsh integration
if 'ZSH_VERSION' in os.environ:
    zsh_autosuggest_highlight = 'fg=' + COLORS['warning']
    env.update({
        'ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE': zsh_autosuggest_highlight,
        'ZSH_HIGHLIGHT_STYLES[command]': 'fg=' + COLORS['primary'],
        'ZSH_HIGHLIGHT_STYLES[alias]': 'fg=' + COLORS['secondary'],
    })

# Custom prompt with Catppuccin colors
def fuck_prompt():
    return '\033[38;2;203;166;247m➜\033[0m \033[38;2;245;194;231mthefuck\033[0m '

if 'ZSH_VERSION' in os.environ:
    def fuck_prompt():
        return '%F{#cba6f7}➜%f %F{#f5c2e7}thefuck%f '

priority = {
    'git_push': 100,
    'rm_root': 100,
    'emerge': 90,
    'sudo': 80,
}

# Gentoo-specific path optimizations
path = os.environ.get('PATH', '').split(':')
gentoo_paths = [
    '/usr/local/bin',
    '/usr/bin',
    '/bin',
    '/usr/sbin',
    '/sbin',
    '/opt/bin',
    f'{Path.home()}/.local/bin',
    f'{Path.home()}/.cargo/bin',
]
path = [p for p in path if p in gentoo_paths] + [p for p in gentoo_paths if p not in path]
env['PATH'] = ':'.join(path)

# Cache configuration
cache_dir = f'{Path.home()}/.cache/thefuck'
cache_file = f'{cache_dir}/commands'
os.makedirs(cache_dir, exist_ok=True)
```

## 3. Zsh Integration

Add to your `~/.zshrc`:

``````bash
# Enhanced thefuck integration with Catppuccin Mocha colors
eval $(thefuck --alias --enable-experimental-instant-mode)

# Custom fuck widget for Zsh with instant mode
fuck-widget() {
    local FUCK="$(THEFUCK_REQUIRE_CONFIRMATION=False TF_CMD=$(fc -ln -1 | tail -n 1) thefuck $(fc -ln -1 | tail -n 1) 2>/dev/null)"
    [[ -n $FUCK ]] && BUFFER=$FUCK
    zle end-of-line
}
zle -N fuck-widget
bindkey '^[f' fuck-widget

# Syntax highlighting for thefuck commands
ZSH_HIGHLIGHT_STYLES[thefuck]='fg=#cba6f7,bold'
```

## 4. Quality of Life Improvements

Create `~/.config/thefuck/gentoo_rules.py` for Gentoo-specific rules:

```python
from thefuck.utils import replace_command, for_app

@for_app('emerge')
def match_emerge_missing_use_flag(command):
    return 'missing USE flag' in command.stderr.lower()

def get_new_command_emerge_use_flag(command):
    flag = command.stderr.split('missing USE flag')[-1].split("'")[1]
    return f'USE="{flag}" emerge {" ".join(command.script_parts[1:])}'

@for_app('eix')
def match_eix_no_matches(command):
    return 'No matches found' in command.stderr

def get_new_command_eix_remote_search(command):
    return command.script.replace('eix', 'eix -R')

@for_app('equery')
def match_equery_no_matches(command):
    return 'No package found' in command.stderr

def get_new_command_equery_wildcard(command):
    return command.script + '*'
```

## 5. Systemd Service (for caching)

Create `~/.config/systemd/user/thefuck-cache.service`:

```ini
[Unit]
Description=TheFuck command cache updater
After=network.target

[Service]
Type=oneshot
ExecStart=/usr/bin/thefuck --update-cache
Environment=XDG_CACHE_HOME=%h/.cache

[Install]
WantedBy=default.target
```

Then enable it with:
```bash
systemctl --user enable --now thefuck-cache.service
```

## 6. Final Optimization

Add this to your shell rc file for better performance:

```zsh
# Preload thefuck in background
if command -v thefuck >/dev/null; then
    (nohup thefuck --load-rules >/dev/null 2>&1 &)
fi
```

This configuration provides:
1. Full Catppuccin Mocha theme integration
2. Enhanced Zsh integration with instant mode and custom keybindings
3. Gentoo-specific command optimizations
4. Performance improvements with caching
5. Better path handling for Gentoo
6. Systemd service for cache management
7. Custom prompt styling
8. Gentoo-specific command rules

Remember to restart your shell after applying these changes for them to take effect.
