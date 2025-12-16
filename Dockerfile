FROM alpine:3.19

# Install TFTP server from Alpine packages
RUN apk add --no-cache tftp-hpa

# Create TFTP directory
RUN mkdir -p /var/lib/tftpboot && \
    chmod 755 /var/lib/tftpboot

# Expose TFTP port
EXPOSE 69/udp

# Start TFTP server
CMD ["/usr/sbin/in.tftpd", "--foreground", "--secure", "/var/lib/tftpboot"]