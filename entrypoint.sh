#!/bin/sh
set -e

# Default values
TFTP_ROOT="${TFTP_ROOT:-/var/lib/tftp/files}"
TFTP_USER="${TFTP_USER:-tftp}"
TFTP_GROUP="${TFTP_GROUP:-tftp}"
TFTP_OPTIONS="${TFTP_OPTIONS:---secure --create --verbose --foreground}"

# Ensure TFTP root directory exists and has correct permissions
mkdir -p "${TFTP_ROOT}"
chown -R "${TFTP_USER}:${TFTP_GROUP}" "${TFTP_ROOT}"
chmod 755 "${TFTP_ROOT}"

# Create a simple test file if it doesn't exist
if [ ! -f "${TFTP_ROOT}/test.txt" ]; then
    echo "TFTP server is working - $(date)" > "${TFTP_ROOT}/test.txt"
    chown "${TFTP_USER}:${TFTP_GROUP}" "${TFTP_ROOT}/test.txt"
fi

echo "Starting TFTP server..."
echo "TFTP Root: ${TFTP_ROOT}"
echo "User: ${TFTP_USER}"
echo "Options: ${TFTP_OPTIONS}"

# Handle command line arguments
if [ $# -gt 0 ]; then
    # If arguments provided, use them as TFTP options
    TFTP_CMD="/usr/local/sbin/in.tftpd $*"
else
    # Use environment variable options
    TFTP_CMD="/usr/local/sbin/in.tftpd ${TFTP_OPTIONS} ${TFTP_ROOT}"
fi

echo "Executing: ${TFTP_CMD}"

# Start TFTP server as the tftp user
exec su-exec "${TFTP_USER}" ${TFTP_CMD}