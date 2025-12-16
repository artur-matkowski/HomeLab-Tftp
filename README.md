# TFTP Server MVP

Simple TFTP server using Alpine Linux and stable packages.

## Quick Start

1. **Create directory for files:**
   ```bash
   mkdir tftp-files
   ```

2. **Start the server:**
   ```bash
   docker-compose up -d
   ```

3. **Test:**
   ```bash
   echo "test" > tftp-files/test.txt
   tftp localhost -c get test.txt
   ```

## Files

- `Dockerfile` - Alpine + tftp-hpa package
- `docker-compose.yml` - Basic compose setup
- `tftp-files/` - Put your files here