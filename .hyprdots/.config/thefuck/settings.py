# The Fuck configuration file
# Visit https://github.com/nvbn/thefuck for more information

# List of enabled rules, comment out to disable:
rules = [
    "apt_get",
    "brew_install",
    "brew_link",
    "brew_uninstall",
    "brew_unknown_command",
    "cd_correction",
    "cd_mkdir",
    "cd_parent",
    "chmod_x",
    "composer_not_command",
    "cp_omitting_directory",
    "django_south_ghost",
    "django_south_merge",
    "docker_login",
    "docker_not_command",
    "dry",
    "fix_alt_space",
    "fix_file",
    "gem_unknown_command",
    "git_add",
    "git_add_force",
    "git_branch_delete",
    "git_branch_exists",
    "git_checkout",
    "git_commit_amend",
    "git_diff_staged",
    "git_fix_stash",
    "git_merge",
    "git_no_remote",
    "git_pull",
    "git_pull_clone",
    "git_push",
    "git_push_different_branch_name",
    "git_push_pull",
    "git_push_upstream",
    "git_rebase_no_changes",
    "git_remote_delete",
    "git_rm_local_modifications",
    "git_rm_recursive",
    "git_stash",
    "git_tag_force",
    "git_two_dashes",
    "go_run",
    "grep_arguments",
    "grep_recursive",
    "has_exists_script",
    "history",
    "java",
    "lein_not_task",
    "long_form_help",
    "ln_s_order",
    "ls_all",
    "ls_lah",
    "man",
    "mercurial",
    "missing_space_before_subcommand",
    "mkdir_p",
    "mvn_no_command",
    "npm_missing_script",
    "npm_run_script",
    "npm_wrong_command",
    "no_command",
    "no_such_file",
    "pacman",
    "pacman_not_found",
    "pip_unknown_command",
    "php_s",
    "port_already_in_use",
    "prove_recursive",
    "python_command",
    "quotation_marks",
    "path_from_history",
    "rm_dir",
    "rm_root",
    "sed_unterminated_s",
    "sl_ls",
    "ssh_known_hosts",
    "sudo",
    "sudo_command_from_user_path",
    "switch_lang",
    "systemctl",
    "tmux",
    "tsuru_login",
    "tsuru_not_command",
    "unknown_command",
    "vagrant_up",
    "whois",
    "dnf_no_such_command",
]

# Rules to exclude (comment out to enable):
exclude_rules = []

# Maximum time in seconds for getting previous command output:
wait_command = 3

# Require confirmation before running new command:
require_confirmation = True

# Max amount of previous commands to keep in history:
history_limit = 2000

# The number of close matches to suggest when a rule is not found:
num_close_matches = 5

# Disable colors in output:
no_colors = False

# Enable debug mode:
debug = False

# Alter history file (requires proper shell integration):
alter_history = True

# Priority settings for rules (lower number = higher priority):
priority = "no_command=9999:apt_get=100:git_push=1000:rm_root=1:dnf_no_such_command=50:sudo=100:systemctl=200"

# Environment variables for thefuck execution:
env = {
    "LC_ALL": "C",
    "LANG": "C",
}

# Instant mode (faster, but requires shell integration):
instant_mode = False

# Slow commands (ignored in instant mode):
slow_commands = ["lein", "react-native", "gradle", "./gradlew", "vagrant"]

# Wait slow command timeout:
wait_slow_command = 15

# History limit for slow commands:
slow_commands_history_limit = 999


# Get corrected commands function (required for proper operation):
def get_corrected_commands():
    return []
