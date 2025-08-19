# ~/.config/home-manager/bat/default.nix
{pkgs, ...}: {
  programs.bat = {
    enable = true;
    extraPackages = with pkgs; [
      bat-extras.batdiff
      bat-extras.batman
      bat-extras.prettybat
    ];
    config = {
      style = "numbers,changes,header";
      "show-all" = true;
      "italic-text" = "always";
      color = "always";

      # All syntax mappings go here as a list of strings.
      "map-syntax" = [
        # Fedora-specific file mappings
        "*.repo:INI"
        "kickstart.cfg:Bash"
        "*.ks:Bash"

        # System configuration files
        "/etc/sysconfig/*:Bash"
        "/etc/dnf/*.conf:INI"
        "/etc/dnf/*.repo:INI"
        "/etc/yum.repos.d/*.repo:INI"
        "/etc/security/*.conf:INI"
        "/etc/NetworkManager/system-connections/*:INI"
        "/etc/modprobe.d/*.conf:Bash"

        # SystemD unit files
        "/usr/lib/systemd/system/*:SystemD"
        "/etc/systemd/system/*:SystemD"
        "/home/*/.config/systemd/user/*:SystemD"

        # SELinux policy files
        "*.te:C"
        "*.if:C"
        "*.fc:Plain Text"

        # Container files
        "Containerfile:Dockerfile"
        "*.containerfile:Dockerfile"

        # Log files and plain text
        "/var/log/dnf.log:Log"
        "/var/log/dnf.rpm.log:Log"
        "*.log:Log"

        # Fedora-specific release files
        "/etc/fedora-release:Plain Text"
        "/etc/system-release:Plain Text"
      ];
    };
  };

  programs.zsh = {
    shellAliases = {
      cat = "bat --paging=never";
      batl = "bat --paging=always";
      batp = "bat --plain";
      dnf-log = "bat /var/log/dnf.log";
      dnf-repos = ''find /etc/yum.repos.d -name "*.repo" -exec bat {} \;'';
      fedora-release = "bat /etc/fedora-release";
    };
    initContent = ''
        # Bat helper functions
        batgit() {
            if git rev-parse --git-dir > /dev/null 2>&1; then
                local branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
                local modified=$(git diff --name-only 2>/dev/null | wc -l)
                local staged=$(git diff --cached --name-only 2>/dev/null | wc -l)
                echo "Git Status: [Branch: ''${branch:-unknown}] [Modified: $modified] [Staged: $staged]"
                echo "----------------------------------------"
            fi
            bat "$@"
        }
      # DNF and RPM related functions
        dnf-rpm-log() {
            if [[ -f "/var/log/dnf.rpm.log" ]]; then
                bat /var/log/dnf.rpm.log --language=log
            else
                echo "DNF RPM log file not found"
            fi
        }

        # Function to view RPM spec files
        spec() {
            if [[ -z "$1" ]]; then
                echo "Usage: spec <spec_file>"
                return 1
            fi
            if [[ -f "$1" ]]; then
                bat "$1" --language=bash
            else
                echo "Spec file not found: $1"
            fi
        }

        # Function to view package changelogs
        changelog() {
            if [[ -z "$1" ]]; then
                echo "Usage: changelog <package_name>"
                return 1
            fi
            if rpm -q "$1" > /dev/null 2>&1; then
                rpm -q --changelog "$1" | bat --language=diff --paging=always
            else
                echo "Package not found or not installed: $1"
            fi
        }

        # Function to view system configuration files
        sysconfig() {
            if [[ -z "$1" ]]; then
                echo "Usage: sysconfig <config_name>"
                echo "Available configs in /etc/sysconfig:"
                ls /etc/sysconfig/ 2>/dev/null || echo "Directory not accessible"
                return 1
            fi
            local config_file="/etc/sysconfig/$1"
            if [[ -f "$config_file" ]]; then
                bat "$config_file"
            else
                echo "Sysconfig file not found: $config_file"
            fi
        }

        # Function to view systemd unit files
        unit() {
            if [[ -z "$1" ]]; then
                echo "Usage: unit <unit_name>"
                return 1
            fi
            local unit_file
            unit_file=$(systemctl show -p FragmentPath "$1" 2>/dev/null | cut -d= -f2)
            if [[ -n "$unit_file" && -f "$unit_file" ]]; then
                bat "$unit_file" --language=ini
            else
                echo "Unit file not found for: $1"
            fi
        }

        # Function to view SELinux policy files
        sepolicy() {
            if [[ -z "$1" ]]; then
                echo "Usage: sepolicy <policy_name>"
                echo "Look for .te files in /usr/share/selinux/targeted/"
                return 1
            fi
            local policy_file
            if [[ -f "$1" ]]; then
                policy_file="$1"
            elif [[ -f "/usr/share/selinux/targeted/$1.te" ]]; then
                policy_file="/usr/share/selinux/targeted/$1.te"
            elif [[ -f "/usr/share/selinux/targeted/$1" ]]; then
                policy_file="/usr/share/selinux/targeted/$1"
            else
                echo "SELinux policy file not found: $1"
                return 1
            fi
            bat "$policy_file" --language=c
        }

        # Function to view Fedora-specific information
        fedora-info() {
            echo "=== Fedora Release Information ==="
            if [[ -f "/etc/fedora-release" ]]; then
                bat /etc/fedora-release
            fi
            if [[ -f "/etc/os-release" ]]; then
                echo -e "\n=== OS Release Information ==="
                bat /etc/os-release
            fi
            if [[ -f "/etc/system-release" ]]; then
                echo -e "\n=== System Release Information ==="
                bat /etc/system-release
            fi
        }

        # Function to view container files
        container-config() {
            if [[ -z "$1" ]]; then
                echo "Usage: container-config <dockerfile|containerfile>"
                return 1
            fi
            if [[ -f "$1" ]]; then
                bat "$1" --language=dockerfile
            else
                echo "Container file not found: $1"
            fi
        }

        # Function to view kickstart files
        kickstart() {
            if [[ -z "$1" ]]; then
                echo "Usage: kickstart <kickstart_file>"
                return 1
            fi
            if [[ -f "$1" ]]; then
                bat "$1" --language=bash
            else
                echo "Kickstart file not found: $1"
            fi
        }

        # Function for viewing JSON with proper syntax highlighting
        json() {
            if [[ -z "$1" ]]; then
                echo "Usage: json <json_file>"
                return 1
            fi
            if [[ -f "$1" ]]; then
                bat "$1" --language=json
            else
                echo "JSON file not found: $1"
            fi
        }

        # Function for viewing YAML files
        yaml() {
            if [[ -z "$1" ]]; then
                echo "Usage: yaml <yaml_file>"
                return 1
            fi
            if [[ -f "$1" ]]; then
                bat "$1" --language=yaml
            else
                echo "YAML file not found: $1"
            fi
        }

        # Find and view files with bat using fzf
        fbat() {
            local file
            if command -v fzf >/dev/null 2>&1; then
                if command -v fd >/dev/null 2>&1; then
                    file=$(fd --type f | fzf --preview 'bat --color=always --style=numbers --line-range=:500 {}') && bat "$file"
                else
                    file=$(find . -type f | fzf --preview 'bat --color=always --style=numbers --line-range=:500 {}') && bat "$file"
                fi
            else
                echo "fzf not installed. Install with: sudo dnf install fzf"
            fi
        }

        # Function for large files with minimal styling
        batfast() {
            bat --style=plain --paging=always "$@"
        }

        # Function to check file size before using bat
        smartbat() {
            local file="$1"
            if [[ -f "$file" ]]; then
                local size=$(stat -c%s "$file" 2>/dev/null || stat -f%z "$file" 2>/dev/null)
                if [[ $size -gt 1048576 ]]; then  # 1MB
                    echo "Large file detected ($(( size / 1024 ))KB). Using plain mode."
                    batfast "$file"
                else
                    bat "$file"
                fi
            else
                echo "File not found: $file"
            fi
        }

        # Function to view mock configuration
        mock-config() {
            if [[ -z "$1" ]]; then
                echo "Usage: mock-config <config_name>"
                echo "Available configs in /etc/mock/:"
                find /etc/mock/ -name "*.cfg" -type f 2>/dev/null | xargs -n1 basename 2>/dev/null || echo "No mock configs found"
                return 1
            fi
            local config_file
            if [[ -f "$1" ]]; then
                config_file="$1"
            elif [[ -f "/etc/mock/$1.cfg" ]]; then
                config_file="/etc/mock/$1.cfg"
            elif [[ -f "/etc/mock/$1" ]]; then
                config_file="/etc/mock/$1"
            else
                echo "Mock config file not found: $1"
                return 1
            fi
            bat "$config_file" --language=python
        }

        # Function to view RPM build logs
        rpm-buildlog() {
            if [[ -z "$1" ]]; then
                echo "Usage: rpm-buildlog <log_file>"
                return 1
            fi
            if [[ -f "$1" ]]; then
                bat "$1" --language=log
            else
                echo "Build log file not found: $1"
            fi
        }

        # Function to view DNF configuration
        dnf-config() {
            if [[ -f "/etc/dnf/dnf.conf" ]]; then
                echo "=== DNF Main Configuration ==="
                bat /etc/dnf/dnf.conf
            fi

            echo -e "\n=== DNF Repository Files ==="
            find /etc/yum.repos.d/ -name "*.repo" -type f 2>/dev/null | while read -r repo; do
                echo "--- $(basename "$repo") ---"
                bat "$repo"
                echo
            done
        }

        # Function to view logs with automatic language detection
        viewlog() {
            if [[ -z "$1" ]]; then
                echo "Usage: viewlog <log_file>"
                return 1
            fi
            if [[ -f "$1" ]]; then
                bat "$1" --language=log
            else
                echo "Log file not found: $1"
            fi
        }


        # Function to view systemd service status and config together
        service-info() {
            if [[ -z "$1" ]]; then
                echo "Usage: service-info <service_name>"
                return 1
            fi
            echo "=== Service Status ==="
            systemctl status "$1" 2>/dev/null || echo "Service status not available"
            echo -e "\n=== Service Configuration ==="
            unit "$1"
        }

        # Function to compare files side by side
        batdiff() {
            if [[ $# -ne 2 ]]; then
                echo "Usage: batdiff <file1> <file2>"
                return 1
            fi
            if [[ -f "$1" && -f "$2" ]]; then
                diff -u "$1" "$2" | bat --language=diff
            else
                echo "One or both files not found: $1, $2"
            fi
        }

        # Function to view git diff with delta and bat syntax highlighting
        gitdiff() {
            if git rev-parse --git-dir > /dev/null 2>&1; then
                git diff "$@"
            else
                echo "Not in a git repository"
            fi
        }

        # Function to view git log with delta
        gitlog() {
            if git rev-parse --git-dir > /dev/null 2>&1; then
                git log --oneline --graph --decorate "$@"
            else
                echo "Not in a git repository"
            fi
        }

        # Function to use bat as a replacement for 'less' when viewing regular files
        batless() {
            if [[ -f "$1" ]]; then
                bat --paging=always "$1"
            else
                echo "File not found: $1"
            fi
        }
    '';
  };
}
