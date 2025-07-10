Here's how to delete all Podman containers and images:

## Delete All Containers

First, stop and remove all containers:

```bash
# Stop all running containers
podman stop $(podman ps -q)

# Remove all containers (stopped and running)
podman rm -f $(podman ps -aq)
```

Or use the more direct approach:
```bash
# Remove all containers forcefully
podman container prune -f
```

## Delete All Images

After removing containers, delete all images:

```bash
# Remove all images
podman rmi -f $(podman images -q)
```

Or use the prune command:
```bash
# Remove all unused images
podman image prune -a -f
```

## One-Line Complete Cleanup

For a complete cleanup in one command:
```bash
podman system prune -a -f --volumes
```

This removes:
- All stopped containers
- All unused networks
- All unused images (not just dangling ones)
- All unused volumes
- All build cache

## Verification

Check that everything is cleaned up:
```bash
podman ps -a    # Should show no containers
podman images   # Should show no images
podman volume ls # Should show no volumes
```

## Important Notes

- The `-f` flag forces removal without confirmation prompts
- The `-a` flag includes all images, not just dangling ones
- Always ensure you don't need any of the containers or images before running these commands
- If you have important data in containers, make sure to back it up first

The `podman system prune -a -f --volumes` command is usually the most efficient way to completely clean your Podman environment.
