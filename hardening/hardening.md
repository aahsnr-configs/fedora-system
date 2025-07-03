``````py
#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
Fedora 42 Desktop Hardening & CIS Compliance Checker

This script performs a comprehensive, read-only security audit of a Fedora 42
desktop system. It is based on a curated set of recommendations from the
CIS Red Hat Enterprise Linux 9 Benchmark and security practices from projects
like secureblue.dev.

It is designed to be non-destructive and is safe to run multiple times.

Usage: sudo python3 fedora_hardening_checker_v2.py
"""

import os
import subprocess
import re

# --- Configuration ---
CIS_BENCHMARK_VERSION = "CIS Red Hat Enterprise Linux 9 Benchmark v2.0.0"
FEDORA_VERSION = 42

# --- ANSI Color Codes for Output Formatting ---
GREEN = '\033[92m'
RED = '\033[91m'
YELLOW = '\033[93m'
BLUE = '\033[94m'
RESET = '\033[0m'

# --- Counters for Final Summary ---
PASS_COUNT = 0
FAIL_COUNT = 0

def print_banner():
    """Prints the script's welcome banner."""
    print("=" * 80)
    print(f"{BLUE}Fedora {FEDORA_VERSION} Desktop Hardening & CIS Compliance Checker (v2){RESET}")
    print(f"Based on: {CIS_BENCHMARK_VERSION} and modern security practices")
    print("=" * 80)
    print("\n🔎 This is a read-only checker and will NOT modify your system.")
    print("   Run with sudo privileges for accurate results.\n")

def run_command(command, check=False):
    """Runs a shell command and returns its output, handling errors."""
    try:
        result = subprocess.run(
            command,
            shell=True,
            capture_output=True,
            text=True,
            check=check,
            timeout=120  # Add a timeout for potentially long-running commands
        )
        return result.stdout.strip()
    except (subprocess.CalledProcessError, subprocess.TimeoutExpired) as e:
        return ""

# --- Core Checking and Reporting Functions ---

def print_section_header(title):
    print(f"\n--- {title} ---")

def record_pass(message):
    global PASS_COUNT
    print(f"[{GREEN}PASS{RESET}] {message}")
    PASS_COUNT += 1

def record_fail(message, remediation=""):
    global FAIL_COUNT
    print(f"[{RED}FAIL{RESET}] {message}")
    if remediation:
        print(f"  {YELLOW}➡️  Remediation:{RESET} {remediation}")
    FAIL_COUNT += 1

def check_file_permissions(path, mode, owner, group):
    if not os.path.exists(path):
        record_fail(f"File '{path}' does not exist.")
        return
    stat = os.stat(path)
    current_mode = oct(stat.st_mode)[-3:]
    current_owner = run_command(f"getent passwd {stat.st_uid} | cut -d: -f1")
    current_group = run_command(f"getent group {stat.st_gid} | cut -d: -f1")
    if current_mode == mode and current_owner == owner and current_group == group:
        record_pass(f"Permissions on '{path}' are correctly set to {mode}/{owner}/{group}.")
    else:
        fail_msg = f"Permissions for '{path}' are {current_mode}/{current_owner}/{current_group}, expected {mode}/{owner}/{group}."
        remediation = f"Run: sudo chmod {mode} {path}; sudo chown {owner}:{group} {path}"
        record_fail(fail_msg, remediation)

def check_kernel_module_disabled(module):
    modprobe_out = run_command(f"modprobe -n -v {module}")
    lsmod_out = run_command(f"lsmod | grep ^{module}")
    if ("install /bin/true" in modprobe_out or "install /bin/false" in modprobe_out) and not lsmod_out:
        record_pass(f"Kernel module '{module}' is disabled and not loaded.")
    else:
        remediation = f"Create a file in /etc/modprobe.d/ with: 'install {module} /bin/false' and 'blacklist {module}'. Then reboot."
        record_fail(f"Kernel module '{module}' is not properly disabled.", remediation)

def check_package_installed(package):
    if "is not installed" in run_command(f"rpm -q {package}"):
        record_fail(f"Package '{package}' is not installed.", f"Install with 'sudo dnf install {package}'.")
    else:
        record_pass(f"Package '{package}' is installed.")

def check_service_enabled(service):
    if "enabled" in run_command(f"systemctl is-enabled {service}"):
        record_pass(f"Service '{service}' is enabled.")
    else:
        record_fail(f"Service '{service}' is disabled.", f"Enable with 'sudo systemctl enable --now {service}'.")

def check_sysctl_setting(setting, expected_value):
    actual_value = run_command(f"sysctl {setting}").split('=')[-1].strip()
    if actual_value == expected_value:
        record_pass(f"sysctl '{setting}' is correctly set to '{expected_value}'.")
    else:
        remediation = f"Set '{setting} = {expected_value}' in a file in /etc/sysctl.d/ and run 'sudo sysctl --system'."
        record_fail(f"sysctl '{setting}' is '{actual_value}', expected '{expected_value}'.", remediation)

# --- MODULES FOR CHECKS ---

def module_initial_setup_and_boot():
    print_section_header("1. Initial Setup & Boot Security")
    # Secure Boot
    if "SecureBoot enabled" in run_command("mokutil --sb-state"):
        record_pass("Secure Boot is enabled.")
    else:
        record_fail("Secure Boot is disabled.", "Enable Secure Boot in your system's UEFI/BIOS settings.")
    # SELinux
    sestatus = run_command("sestatus")
    if "SELinux status:                 enabled" in sestatus and "Current mode:               enforcing" in sestatus:
        record_pass("SELinux is enabled and in enforcing mode.")
    else:
        record_fail("SELinux is not enabled or not in enforcing mode.", "Set 'SELINUX=enforcing' in /etc/selinux/config and reboot.")
    # Bootloader permissions
    check_file_permissions("/boot/grub2/grub.cfg", "600", "root", "root")
    if os.path.exists("/boot/efi/EFI/fedora/grub.cfg"):
        check_file_permissions("/boot/efi/EFI/fedora/grub.cfg", "600", "root", "root")
    # Bootloader password
    if "password_pbkdf2" in run_command("cat /boot/grub2/grub.cfg"):
        record_pass("Bootloader password appears to be set.")
    else:
        record_fail("Bootloader password is not set.", "Set a password with 'sudo grub2-setpassword' to protect boot entries.")

def module_filesystem_and_kernel():
    print_section_header("2. Filesystem & Kernel Hardening")
    # Filesystem & Encryption
    lsblk = run_command("lsblk -f")
    if "btrfs" in lsblk and "crypto_LUKS" in lsblk:
        record_pass("System is using Btrfs on a LUKS-encrypted volume.")
    else:
        record_fail("System is not using Btrfs on a LUKS-encrypted volume.", "For best security, reinstall with the default encrypted Btrfs layout.")
    # Mount options
    check_mount_options("/tmp", ["nodev", "nosuid", "noexec"])
    check_mount_options("/dev/shm", ["nodev", "nosuid", "noexec"])
    check_mount_options("/home", ["nodev"])
    # Kernel Hardening
    if "nosmt" in run_command("cat /proc/cmdline"):
        record_pass("SMT is disabled via 'nosmt' kernel parameter.")
    else:
        record_fail("SMT is enabled.", "Add 'nosmt=1' to kernel boot parameters to mitigate CPU side-channel attacks.")
    check_sysctl_setting("kernel.randomize_va_space", "2")
    # Unused Filesystems
    check_kernel_module_disabled("cramfs")
    check_kernel_module_disabled("udf")

def check_mount_options(mount_point, expected_options):
    """Helper for checking mount point options."""
    opts = run_command(f"findmnt -kn -o OPTIONS {mount_point}")
    if opts:
        missing = [opt for opt in expected_options if opt not in opts.split(',')]
        if not missing:
            record_pass(f"Mount point '{mount_point}' includes required hardening options.")
        else:
            record_fail(f"Mount point '{mount_point}' is missing options: {', '.join(missing)}.", f"Add missing options to /etc/fstab for {mount_point}.")
    else:
        record_fail(f"'{mount_point}' is not a separate mount point.", f"Consider creating a separate mount for {mount_point} for better security.")

def module_attack_surface_and_network():
    print_section_header("3. Attack Surface & Network Configuration")
    # Remove legacy packages
    for pkg in ["telnet", "rsh", "ypbind", "vsftpd", "xinetd"]:
        if "is not installed" in run_command(f"rpm -q {pkg}"):
            record_pass(f"Legacy package '{pkg}' is not installed.")
        else:
            record_fail(f"Legacy package '{pkg}' is installed.", f"Remove with 'sudo dnf remove {pkg}'.")
    # Network Protocols
    check_kernel_module_disabled("dccp")
    check_kernel_module_disabled("sctp")
    # IPv4/IPv6 Hardening
    check_sysctl_setting("net.ipv4.conf.all.send_redirects", "0")
    check_sysctl_setting("net.ipv4.conf.all.accept_redirects", "0")
    check_sysctl_setting("net.ipv4.conf.all.log_martians", "1")
    check_sysctl_setting("net.ipv4.icmp_echo_ignore_broadcasts", "1")
    check_sysctl_setting("net.ipv6.conf.all.accept_ra", "0")
    check_sysctl_setting("net.ipv6.conf.all.accept_redirects", "0")
    # Firewall
    check_package_installed("firewalld")
    check_service_enabled("firewalld")

def module_auditing():
    print_section_header("4. Logging & Auditing (auditd)")
    check_package_installed("audit")
    check_service_enabled("auditd")

    # Check for presence of key audit rules
    audit_rules = run_command("sudo auditctl -l")
    rules_to_check = {
        "-w /etc/sudoers -p wa -k scope": "Sudoers file modification",
        "-w /var/log/sudo.log -p wa -k actions": "Sudo log access",
        "-w /etc/passwd -p wa -k identity": "User/group database modification",
        "-w /etc/selinux/ -p wa -k MAC-policy": "SELinux policy changes",
        "-a always,exit -F arch=b64 -S sethostname -S setdomainname -k system-locale": "System identity changes",
        "-a always,exit -F arch=b64 -S adjtimex -S settimeofday -k time-change": "Time changes",
        "-a always,exit -F arch=b64 -S chmod -S fchmod -S fchmodat -k perm_mod": "Permission modifications"
    }
    for rule, desc in rules_to_check.items():
        if rule in audit_rules:
            record_pass(f"Audit rule for '{desc}' is present.")
        else:
            record_fail(f"Missing audit rule for '{desc}'.", f"Add the rule '{rule}' to your /etc/audit/rules.d/audit.rules file.")

def module_access_and_authentication():
    print_section_header("5. Access, Authentication & Authorization")
    # Password Complexity
    pwquality_conf = run_command("cat /etc/security/pwquality.conf")
    if "minlen = 14" in pwquality_conf and "dcredit = -1" in pwquality_conf and "ucredit = -1" in pwquality_conf and "ocredit = -1" in pwquality_conf and "lcredit = -1" in pwquality_conf:
        record_pass("Password complexity settings meet baseline recommendations.")
    else:
        record_fail("Password complexity settings are weak.", "Edit /etc/security/pwquality.conf to enforce minlen=14 and at least one of each credit type (d,u,o,l).")
    # Account Lockout Policy
    if os.path.exists("/etc/security/faillock.conf"):
        faillock_conf = run_command("cat /etc/security/faillock.conf")
        if "deny = 5" in faillock_conf and "unlock_time = 900" in faillock_conf:
            record_pass("Account lockout policy (faillock) is configured.")
        else:
            record_fail("faillock.conf is not configured securely.", "Ensure 'deny = 5' and 'unlock_time = 900' are set in /etc/security/faillock.conf.")
    else:
        record_fail("faillock.conf does not exist.", "Create and configure /etc/security/faillock.conf and enable pam_faillock.so in your PAM stack.")
    # Password Aging
    login_defs = run_command("cat /etc/login.defs")
    if "PASS_MAX_DAYS\t90" in login_defs and "PASS_MIN_DAYS\t7" in login_defs:
        record_pass("Password aging policies (max/min days) are configured.")
    else:
        record_fail("Password aging policies are not configured.", "Set PASS_MAX_DAYS to 90 and PASS_MIN_DAYS to 7 in /etc/login.defs.")
    # Default umask
    if "umask 027" in run_command("cat /etc/bashrc") and "umask 027" in run_command("cat /etc/profile"):
        record_pass("Default umask is set to 027 for new users.")
    else:
        record_fail("Default umask is not set to 027.", "Set umask to 027 in /etc/bashrc and /etc/profile.")

def module_system_maintenance():
    print_section_header("6. System Maintenance & File Integrity")
    # Core file permissions
    check_file_permissions("/etc/passwd", "644", "root", "root")
    check_file_permissions("/etc/shadow", "000", "root", "root")
    check_file_permissions("/etc/gshadow", "000", "root", "root")
    check_file_permissions("/etc/group", "644", "root", "root")
    # User hygiene
    if not run_command("awk -F: '($2 == \"\") { print $1 }' /etc/shadow"):
        record_pass("No system accounts have empty passwords.")
    else:
        record_fail("Found accounts with empty passwords.", "Lock all unused accounts and ensure all active accounts have strong passwords.")
    if not run_command("awk -F: '($3 == 0 && $1 != \"root\") { print $1 }' /etc/passwd"):
        record_pass("UID 0 is assigned only to the 'root' account.")
    else:
        record_fail("Found non-root accounts with UID 0.", "This is a major security risk. Investigate and remove these accounts immediately.")
    # Find unowned/ungrouped files (can be slow)
    print("\n[INFO] Scanning for unowned or ungrouped files... (this may take a minute)")
    unowned_files = run_command("find / -xdev \\( -nouser -o -nogroup \\) -print")
    if not unowned_files:
        record_pass("No unowned or ungrouped files found on the system.")
    else:
        record_fail("Found unowned or ungrouped files.", "Investigate these files. You can see a list by running: sudo find / -xdev \\( -nouser -o -nogroup \\) -print")

def print_summary():
    total_checks = PASS_COUNT + FAIL_COUNT
    pass_percentage = (PASS_COUNT / total_checks * 100) if total_checks > 0 else 0
    print("\n" + "=" * 80)
    print("🏁 Hardening Check Complete")
    print("-" * 80)
    print(f"Total Checks Performed: {total_checks}")
    print(f"{GREEN}Passed: {PASS_COUNT}{RESET}")
    print(f"{RED}Failed: {FAIL_COUNT}{RESET}")
    print(f"Compliance Score: {pass_percentage:.2f}%")
    print("=" * 80)
    if FAIL_COUNT > 0:
        print("\nPlease review the output above for any failed checks and their remediation steps.")
    else:
        print(f"\n{GREEN}Congratulations! Your system passes all checks.{RESET}")

def main():
    """Main function to orchestrate all security checks."""
    if os.geteuid() != 0:
        print(f"{RED}Error: This script must be run with root privileges (e.g., 'sudo python3 {__file__}').{RESET}")
        exit(1)
    
    print_banner()
    module_initial_setup_and_boot()
    module_filesystem_and_kernel()
    module_attack_surface_and_network()
    module_auditing()
    module_access_and_authentication()
    module_system_maintenance()
    print_summary()

if __name__ == "__main__":
    main()
``````
