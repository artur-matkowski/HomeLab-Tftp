# TFTP Server Docker Setup

A lightweight TFTP server optimized for N100-based systems running in Proxmox VMs.

## Features

- Alpine Linux base for minimal resource usage
- Optimized for Intel N100 processors
- Built-in security with non-root user execution
- Health checks and logging
- Easy deployment with Docker Compose

## Quick Start

1. **Create directories:**
   ```bash
   mkdir -p tftp-files logs
   chmod 755 tftp-files
   ```

2. **Build and run:**
   ```bash
   docker-compose up -d
   ```

3. **Test the server:**
   ```bash
   echo "test file" > tftp-files/test.txt
   tftp localhost 69 -c get test.txt
   ```

## Configuration

### Environment Variables

- `TFTP_ROOT`: Root directory for TFTP files (default: `/var/lib/tftp/files`)
- `TFTP_OPTIONS`: TFTP server options (default: `--secure --create --verbose --foreground`)
- `TFTP_USER`: User to run TFTP server (default: `tftp`)
- `TFTP_GROUP`: Group for TFTP server (default: `tftp`)

### Network Modes

The compose file is configured to use `network_mode: host` by default for best performance on Proxmox. 
For isolated networking, comment out `network_mode: host` and uncomment the ports section.

### Resource Limits

Configured for N100 systems with:
- CPU limit: 0.5 cores
- Memory limit: 128MB
- Memory reservation: 32MB

Adjust these in `docker-compose.yml` based on your needs.

## File Operations

### Upload files to TFTP server:
```bash
# Put a file
tftp <server-ip> 69 -c put local-file.txt remote-file.txt

# Get a file  
tftp <server-ip> 69 -c get remote-file.txt local-file.txt
```

### Directory structure:
```
tftp/
├── Dockerfile
├── docker-compose.yml
├── entrypoint.sh
├── tftp-files/          # TFTP root directory
│   └── test.txt
└── logs/                # Log files
```

## Security Notes

- Server runs as non-root user (`tftp:tftp`)
- Uses `--secure` flag to prevent directory traversal
- Files are served from `/var/lib/tftp/files` only
- Container has `no-new-privileges` security option

## Troubleshooting

### Check logs:
```bash
docker-compose logs -f tftp-server
```

### Health check:
```bash
docker-compose ps
```

### Restart service:
```bash
docker-compose restart tftp-server
```

## Proxmox VM Recommendations

- Allocate at least 1GB RAM
- Use virtio network driver for best performance
- Enable hardware acceleration if available
- Consider using host networking for minimal latency