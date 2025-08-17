# ~/.config/home-manager/pay-respects/default.nix
#
# This module configures "pay-respects", a fork of "The Fuck" that
# corrects your previous console command.
#
# The Home Manager module for pay-respects only handles installation and
# shell integration. All configuration is therefore handled declaratively by
# writing the settings.py and custom rule files to the correct locations.

{ config, pkgs, lib, ... }:

let
  # Content of your custom fedora_rules.py.
  fedoraRules = ''
    import re

    from thefuck.utils import for_app


    # DNF-specific corrections
    def match_dnf_no_such_command(command):
        return "dnf" in command.script and (
            "No such command" in command.stderr or "Unknown command" in command.stderr
        )


    def get_new_command_dnf_no_such_command(command):
        common_typos = {
            "isntall": "install",
            "intall": "install",
            "instal": "install",
            "instll": "install",
            "installl": "install",
            "remove": "remove",
            "erase": "remove",
            "uninstall": "remove",
            "update": "upgrade",
            "updgrade": "upgrade",
            "upgrad": "upgrade",
            "serach": "search",
            "seach": "search",
            "searh": "search",
            "info": "info",
            "informations": "info",
            "list": "list",
            "ls": "list",
            "history": "history",
            "hist": "history",
            "clean": "clean",
            "autoremove": "autoremove",
            "reinstall": "reinstall",
            "downgrade": "downgrade",
            "repolist": "repolist",
            "repos": "repolist",
            "groupinstall": "groupinstall",
            "grouplist": "grouplist",
            "groupinfo": "groupinfo",
            "groupremove": "groupremove",
            "makecache": "makecache",
            "provides": "provides",
            "whatprovides": "whatprovides",
            "check-update": "check-update",
            "updateinfo": "updateinfo",
            "distro-sync": "distro-sync",
            "shell": "shell",
            "deplist": "deplist",
            "repoquery": "repoquery",
            "builddep": "builddep",
            "changelog": "changelog",
            "config-manager": "config-manager",
            "copr": "copr",
            "download": "download",
            "needs-restarting": "needs-restarting",
            "system-upgrade": "system-upgrade",
        }

        script_parts = command.script.split()
        if len(script_parts) >= 2:
            wrong_cmd = script_parts[1]
            if wrong_cmd in common_typos:
                script_parts[1] = common_typos[wrong_cmd]
                return " ".join(script_parts)

        return command.script


    # SystemD corrections
    def match_systemctl_unit_not_found(command):
        return "systemctl" in command.script and (
            "Unit" in command.stderr and "not found" in command.stderr
        )


    def get_new_command_systemctl_unit_not_found(command):
        if "enable" in command.script and "--now" not in command.script:
            return command.script.replace("enable", "enable --now")
        elif "start" in command.script and "enable" not in command.script:
            return command.script.replace("start", "enable --now")
        return command.script


    # Flatpak corrections
    def match_flatpak_not_installed(command):
        return "flatpak" in command.script and "not installed" in command.stderr


    def get_new_command_flatpak_not_installed(command):
        if "run" in command.script:
            return command.script.replace("run", "install")
        return command.script


    # Podman corrections
    def match_podman_permission_denied(command):
        return "podman" in command.script and "permission denied" in command.stderr.lower()


    def get_new_command_podman_permission_denied(command):
        if not command.script.startswith("sudo"):
            return f"sudo {command.script}"
        return command.script


    # Firewall corrections
    def match_firewall_cmd_permission_denied(command):
        return (
            "firewall-cmd" in command.script
            and "permission denied" in command.stderr.lower()
        )


    def get_new_command_firewall_cmd_permission_denied(command):
        if not command.script.startswith("sudo"):
            return f"sudo {command.script}"
        return command.script


    # SELinux corrections
    def match_setsebool_permission_denied(command):
        return (
            "setsebool" in command.script and "permission denied" in command.stderr.lower()
        )


    def get_new_command_setsebool_permission_denied(command):
        if not command.script.startswith("sudo"):
            return f"sudo {command.script}"
        return command.script


    # Common typo corrections for Fedora commands
    def match_fedora_typos(command):
        fedora_commands = [
            "dnf",
            "rpm",
            "systemctl",
            "firewall-cmd",
            "semanage",
            "setsebool",
            "flatpak",
            "toolbox",
            "podman",
        ]
        return any(cmd in command.script for cmd in fedora_commands)


    def get_new_command_fedora_typos(command):
        typo_map = {
            "dnf": ["dnf", "df", "dn", "dnff"],
            "rpm": ["rpm", "rmp", "prm"],
            "systemctl": ["systemctl", "systmctl", "systemct", "sytemctl"],
            "firewall-cmd": ["firewall-cmd", "firewall", "firewalld"],
            "flatpak": ["flatpak", "flatpack", "flathub"],
            "podman": ["podman", "podmn", "podmn"],
            "toolbox": ["toolbox", "toolbx", "tbox"],
        }

        for correct, typos in typo_map.items():
            for typo in typos:
                if typo in command.script and typo != correct:
                    return command.script.replace(typo, correct, 1)

        return command.script


    # Register the rules
    enabled_by_default = True
    priority = 1000
  '';

  # Content for the settings.py file.
  settingsPy = ''
    # The Fuck configuration file
    # This file is managed declaratively by Home Manager.
    # Visit https://github.com/nvbn/thefuck for more information

    # List of enabled rules. This list is curated for a Fedora/Nix environment.
    rules = [
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
        # Custom Fedora rules are enabled by adding the file name (without .py)
        "fedora_rules",
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
    # This is a string, not a dictionary.
    priority = "no_command=9999:rm_root=1:dnf_no_such_command=50:sudo=100:systemctl=200:git_push=1000"

    # Environment variables for thefuck execution:
    env = {
        "LC_ALL": "C",
        "LANG": "C",
    }

    # Instant mode (faster, but requires shell integration):
    instant_mode = False
  '';
in
{
  # Enable pay-respects and the appropriate shell integration.
  programs.pay-respects = {
    enable = true;
    enableBashIntegration = true;
    enableZshIntegration = true;
  };

  # Use xdg.configFile to place the configuration files in ~/.config/pay-respects/
  # This is the correct, declarative way to manage the configuration.
  xdg.configFile = {
    "pay-respects/rules/fedora_rules.py".text = fedoraRules;
    "pay-respects/settings.py".text = settingsPy;
  };
}
