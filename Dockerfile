# Multi-stage build for TFTP server optimized for N100 systems
FROM alpine:3.19 as builder

# Install build dependencies
RUN apk add --no-cache \
    build-base \
    autoconf \
    automake \
    libtool \
    git

# Build tftp-hpa from source for better performance on N100
WORKDIR /tmp
RUN git clone https://git.kernel.org/pub/scm/network/tftp/tftp-hpa.git && \
    cd tftp-hpa && \
    ./configure --prefix=/usr/local --enable-server --enable-client && \
    make && \
    make install DESTDIR=/tmp/tftp-install

# Final stage - minimal runtime image
FROM alpine:3.19

# Install runtime dependencies
RUN apk add --no-cache \
    shadow \
    su-exec \
    tini \
    && addgroup -g 1001 tftp \
    && adduser -D -u 1001 -G tftp -h /var/lib/tftp -s /sbin/nologin tftp

# Copy TFTP server from builder stage
COPY --from=builder /tmp/tftp-install/usr/local/sbin/in.tftpd /usr/local/sbin/
COPY --from=builder /tmp/tftp-install/usr/local/bin/tftp /usr/local/bin/

# Create TFTP root directory
RUN mkdir -p /var/lib/tftp/files && \
    chown -R tftp:tftp /var/lib/tftp && \
    chmod 755 /var/lib/tftp

# Create configuration directory
RUN mkdir -p /etc/tftp

# Copy entrypoint script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Expose TFTP port (UDP 69)
EXPOSE 69/udp

# Set working directory
WORKDIR /var/lib/tftp

# Use tini as init system for proper signal handling
ENTRYPOINT ["/sbin/tini", "--", "/entrypoint.sh"]

# Default command
CMD ["--secure", "--create", "--verbose", "--foreground", "/var/lib/tftp/files"]

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD echo "test" | tftp localhost 69 -c put /dev/stdin test.tmp || exit 1

# Labels for better maintainability
LABEL maintainer="TFTP Server" \
      description="Lightweight TFTP server optimized for N100 systems" \
      version="1.0" \
      architecture="amd64"

# Environment variables for configuration
ENV TFTP_ROOT="/var/lib/tftp/files" \
    TFTP_OPTIONS="--secure --create --verbose --foreground" \
    TFTP_USER="tftp" \
    TFTP_GROUP="tftp"