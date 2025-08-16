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
