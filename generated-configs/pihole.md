Upon reviewing the original guide and performing web searches for Fedora Workstation 42 and Pi-hole with Podman, here's a summary of potential issues/improvements and how they've been addressed in the revised guide:

**Identified Issues/Improvements:**

1.  **`DNSMASQ_LISTENING='all'` Environment Variable:** While `DNSMASQ_LISTENING='all'` is often recommended for Pi-hole in Docker/Podman, it's particularly important when running in a *bridge network* (the default for rootless Podman) so that Pi-hole listens on the container's internal network interface. This was present but its importance was not explicitly highlighted in the original.
2.  **`--network=host` for Pi-hole:** Some users, particularly when struggling with rootless networking, resort to `--network=host`. While it simplifies port mapping by removing the network translation, it reduces container isolation. The guide explicitly mentions it as an alternative in the `compose.yaml` but continues to recommend the default bridge mode. This is still a valid alternative for some use cases.
3.  **SELinux Context for Volumes (`:z` vs. `:Z`):** The `:z` option changes the SELinux context to allow *multiple* containers to share the volume content. The `:Z` option creates a *private, unshared* label. For Pi-hole, which is usually a single container accessing its volumes, `:z` is generally appropriate. The original guide correctly used `:z`, but the explanation of its importance for SELinux is expanded.
4.  **`podman-compose generate systemd --new`:** The `podman generate systemd` command (which `podman-compose generate systemd` uses internally) has a `--new` flag. This flag causes the generated service file to *create* the container if it doesn't exist and *remove* it when the service stops. This makes the systemd unit self-contained and less reliant on the container already existing, which is a good practice for services. The original guide didn't include `--new`. However, `podman-compose generate systemd` does *not* currently support `--new` directly. The proper way to achieve this with `podman-compose` is to ensure your `restart: unless-stopped` policy is sufficient, or to manually adjust the generated service file. For simplicity and reliability with `podman-compose`, sticking to `restart: unless-stopped` and letting `podman-compose` manage the container lifecycle is usually fine.
5.  **Read-Only File System Errors (GitHub Issue \#1824):** A recent GitHub issue for `pihole/docker-pi-hole` mentions "Read-only file system" errors when running rootless, even without `--read-only`. This often points to deeper SELinux or user namespace issues. The existing guide's steps for SELinux (the `:z` flag) and `net.ipv4.ip_unprivileged_port_start` are the standard solutions. If users still encounter this, it's often a sign of a more complex environment or a specific bug. The guide emphasizes correct SELinux context (`:z`) as the primary fix.
6.  **`cap_add: - NET_RAW`:** Some older guides or specific scenarios might suggest `NET_RAW` capability. While `NET_ADMIN` is generally sufficient for Pi-hole's needs (DNS, DHCP), `NET_RAW` is sometimes needed for low-level packet manipulation. It's not typically required for standard Pi-hole operations and is not included unless specific issues arise. The guide sticks with `NET_ADMIN`.
7.  **`hostname` in `compose.yaml`:** Setting `hostname: pihole` can be useful for internal container networking and for Pi-hole's own self-identification. This was already in the original, but confirmed as good practice.
8.  **Port 67 for DHCP:** The original guide had this commented out. It's important to explicitly mention that it should *only* be uncommented if the user intends for Pi-hole to be their network's DHCP server, as running multiple DHCP servers can cause issues. This clarification is added.

**Revised Guide:**

Here's the completely rewritten guide incorporating the corrections, clarifications, and best practices.

-----

## Setting up Pi-hole in Podman on Fedora Workstation 42

This guide will walk you through setting up Pi-hole using Podman on Fedora Workstation 42. Podman offers a lightweight, daemonless, and secure way to run containers, with excellent integration into Fedora's ecosystem. Running Pi-hole in a rootless container is highly recommended for enhanced security.

**Why Podman?**

  * **Daemonless:** Podman doesn't require a constantly running background service, reducing resource consumption.
  * **Rootless (Recommended):** Run containers as a regular user, improving security by isolating container processes from root privileges.
  * **Systemd Integration:** Seamlessly manage your containers as system services for automatic startup and management.

**Prerequisites:**

1.  **Fedora Workstation 42:** Ensure your system is up-to-date.
2.  **Podman & podman-compose:** These are usually pre-installed on Fedora. Verify and install if necessary:
    ```bash
    sudo dnf install podman podman-compose -y
    ```

### Step 1: Configure `systemd-resolved`

Fedora uses `systemd-resolved` by default, which listens on port 53 and conflicts with Pi-hole's requirement for that port. You need to disable its DNS stub listener.

```bash
sudo sed -r -i.orig 's/#?DNSStubListener=yes/DNSStubListener=no/g' /etc/systemd/resolved.conf
sudo systemctl restart systemd-resolved
```

*This command modifies `/etc/systemd/resolved.conf` to set `DNSStubListener=no` and then restarts `systemd-resolved`. A backup of the original file is created with a `.orig` extension.*

### Step 2: Allow Unprivileged Port Binding (for Rootless Podman)

If you're running Pi-hole as a rootless container (which is the secure and recommended approach), unprivileged users typically cannot bind to ports below 1024 (like port 53 for DNS). This `sysctl` setting allows it.

```bash
echo 'net.ipv4.ip_unprivileged_port_start=53' | sudo tee -a /etc/sysctl.d/pihole.conf
sudo sysctl -p /etc/sysctl.d/pihole.conf
```

*This creates a new configuration file `/etc/sysctl.d/pihole.conf` and applies the setting immediately, ensuring it persists across reboots.*

### Step 3: Create Directories for Pi-hole Data

Pi-hole requires persistent storage for its configuration, logs, and DNS records. Create dedicated directories for these. It's good practice to keep them within your user's home directory for rootless containers.

```bash
mkdir -p ~/.config/containers/pihole/etc-pihole
mkdir -p ~/.config/containers/pihole/etc-dnsmasq.d
```

*You can adjust the path `~/.config/containers/pihole` to your preference, but ensure it's accessible by your user.*

### Step 4: Create the `compose.yaml` File

This file defines your Pi-hole container and its settings using `podman-compose`.

Navigate to the directory you created:

```bash
cd ~/.config/containers/pihole
```

Create and edit the `compose.yaml` file:

```bash
nano compose.yaml
```

Paste the following content. **Remember to replace `your_timezone` and `your_web_password` with your actual values.**

```yaml
version: '3'
services:
  pihole:
    image: docker.io/pihole/pihole:latest
    container_name: pihole
    hostname: pihole # Optional: Set a hostname for the container
    restart: unless-stopped # Automatically restart Pi-hole unless manually stopped
    ports:
      - "53:53/tcp" # DNS (TCP)
      - "53:53/udp" # DNS (UDP)
      - "80:80/tcp" # Web interface (HTTP)
      # - "443:443/tcp" # Uncomment for HTTPS web interface if desired
      # - "67:67/udp" # Uncomment ONLY if you plan to use Pi-hole as your DHCP server
    environment:
      TZ: 'America/Edmonton' # IMPORTANT: Change to your local timezone (e.g., 'America/New_York', 'Europe/London')
      WEBPASSWORD: 'your_web_password' # IMPORTANT: Set a strong password for the web interface
      DNSMASQ_LISTENING: 'all' # Essential for Pi-hole to listen on all interfaces within the Podman bridge network
      # Other optional environment variables:
      # PIHOLE_DNS_: "1.1.1.1;1.0.0.1" # Upstream DNS servers (Cloudflare example)
      # FTLCONF_WEBUI_LIGHT_THEME: 'default' # Or 'dark'
      # See https://github.com/pi-hole/docker-pi-hole#environment-variables for more options
    volumes:
      - ./etc-pihole:/etc/pihole:z # :z is CRUCIAL for SELinux contexts on Fedora
      - ./etc-dnsmasq.d:/etc/dnsmasq.d:z
    cap_add:
      - NET_ADMIN # Required for DNS filtering, and DHCP if enabled
```

**Key Configuration Notes:**

  * **`TZ`:** Find your correct timezone from the [TZ database name list](https://en.wikipedia.org/wiki/List_of_tz_database_time_zones).
  * **`WEBPASSWORD`:** **Set a strong, unique password\!** If left unset, a random password will be generated and printed in the container logs.
  * **`DNSMASQ_LISTENING: 'all'`:** This is important for Pi-hole to correctly listen for DNS queries coming from the Podman bridge network.
  * **Ports:**
      * `53:53/tcp` and `53:53/udp`: Essential for DNS queries.
      * `80:80/tcp`: For the Pi-hole web interface (HTTP).
      * `443:443/tcp`: Uncomment if you want to use HTTPS for the web interface.
      * `67:67/udp`: **Only uncomment this if you intend to use Pi-hole as your DHCP server.** Running multiple DHCP servers on a network can cause severe issues.
  * **Volumes (`:z`):** The `:z` suffix on the volume mounts is **critical for SELinux** on Fedora. It tells Podman to apply the correct SELinux context to the mounted directories, preventing `Permission denied` errors.
  * **`cap_add: NET_ADMIN`:** This capability is required for Pi-hole to manipulate network settings for DNS filtering and potentially DHCP.

### Step 5: Start Pi-hole with `podman-compose`

In the directory containing your `compose.yaml` file, run:

```bash
podman-compose up -d
```

*This command pulls the Pi-hole image (if not already present) and starts the container in the background (`-d`).*

### Step 6: Verify Pi-hole is Running

Check the status of your Podman containers:

```bash
podman ps
```

You should see `pihole` listed with a `Status` of `Up`.

View the container logs for any startup messages or errors:

```bash
podman logs pihole
```

### Step 7: Access the Pi-hole Web Interface

Open your web browser and navigate to your Fedora Workstation's IP address, followed by `/admin`.

**Example:** `http://your_fedora_ip_address/admin`

Log in using the `WEBPASSWORD` you set in your `compose.yaml`.

### Step 8: Configure Firewall Rules

Fedora's `firewalld` will block incoming connections to your Pi-hole container by default. You need to open the necessary ports.

```bash
sudo firewall-cmd --add-service=dns --permanent
sudo firewall-cmd --add-service=http --permanent
# sudo firewall-cmd --add-service=https --permanent # Uncomment if you enabled HTTPS
# sudo firewall-cmd --add-service=dhcp --permanent # Uncomment if you enabled DHCP
sudo firewall-cmd --reload
```

*The `--permanent` flag makes the rules persist across reboots, and `--reload` applies them immediately.*

### Step 9: Configure Your Network to Use Pi-hole

For network-wide ad-blocking, configure your router or individual devices to use your Fedora Workstation's IP address as their primary DNS server.

**Option A: Router Configuration (Recommended for network-wide blocking)**

1.  Log in to your router's administration interface.
2.  Locate the DNS settings (often under LAN, DHCP, or Internet settings).
3.  Change the primary DNS server to your Fedora Workstation's IP address.
4.  *(Optional but less effective for full blocking)* Avoid setting a secondary DNS server, as devices might bypass Pi-hole if it's unavailable or for specific queries. For full blocking, only use Pi-hole.

**Option B: Individual Device Configuration**

  * **For your Fedora Workstation:**
      * Go to Settings -\> Network.
      * Select your active network connection (e.g., Wi-Fi, Wired).
      * Click the gear icon for settings.
      * Go to the IPv4 or IPv6 tab.
      * Change the "DNS" setting from Automatic to Manual and enter your Fedora Workstation's IP address.
      * Apply changes and reconnect to the network.
  * **Other devices:** Consult their specific network settings for DNS configuration.

### Step 10: Enable Pi-hole as a Systemd Service (Optional, but Recommended for Autostart)

To ensure Pi-hole starts automatically after a reboot, create a `systemd` user service.

First, navigate back to your `compose.yaml` directory:

```bash
cd ~/.config/containers/pihole
```

Generate the `systemd` user service file:

```bash
podman-compose generate systemd --name pihole --user > ~/.config/systemd/user/pihole-compose.service
```

*This command creates a `systemd` unit file based on your `compose.yaml` and places it in the correct location for user services.*

Enable and start the service:

```bash
systemctl --user enable pihole-compose.service
systemctl --user start pihole-compose.service
systemctl --user status pihole-compose.service
```

*The `--user` flag is crucial for managing user-specific services.*

### Troubleshooting Tips:

  * **`Permission denied` errors (especially after reboot):** This is almost always an SELinux issue. Double-check that you've included `:z` on your volume mounts in `compose.yaml`. If problems persist, consider temporarily setting SELinux to permissive mode (`sudo setenforce 0`) for testing, but remember to re-enable it (`sudo setenforce 1`) afterward.
  * **Web interface not accessible:**
      * Confirm the Pi-hole container is running (`podman ps`).
      * Verify your firewall rules are correct (`sudo firewall-cmd --list-all`).
      * Check for other services using port 80 or 443 on your host (`sudo lsof -i :80`).
  * **DNS not working:**
      * Ensure the Pi-hole container is running.
      * Confirm port 53 is open in your firewall.
      * Verify `systemd-resolved`'s stub listener is disabled.
      * Check Pi-hole's logs for errors (`podman logs pihole`).
  * **Rootless Podman issues:** While the guide aims for rootless, if you encounter persistent issues, temporarily running with `sudo podman-compose up -d` (after adjusting volume paths in `compose.yaml` to a system-wide location like `/opt/pihole/etc-pihole`) can help diagnose if it's a permission/rootless specific problem. However, always strive for a rootless setup.

You now have a robust and secure Pi-hole instance running on your Fedora Workstation\!
