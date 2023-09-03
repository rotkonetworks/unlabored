#!/bin/bash

set -e

# Variables
NGINX_VERSION="1.25.2"
DOWNLOAD_URL="http://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz"
DOWNLOAD_DIR="/tmp"
BUILD_DIR="${DOWNLOAD_DIR}/nginx-${NGINX_VERSION}"

# Ensure the script is run as root
if [[ "$EUID" -ne 0 ]]; then
   echo "This script must be run as root."
   exit 1
fi

# Check if Nginx is already installed
if which nginx >/dev/null; then
    echo "Nginx is already installed. Please remove it before running this script."
    exit 1
fi

# Update System and Install Dependencies
update_system() {
    apt update && apt upgrade -y
    apt install -y build-essential libpcre3 libpcre3-dev zlib1g zlib1g-dev openssl libssl-dev wget
}

# Download and Extract Nginx
download_nginx() {
    cd "$DOWNLOAD_DIR"
    wget "$DOWNLOAD_URL"
    tar -xzvf "nginx-${NGINX_VERSION}.tar.gz"
}

# Configure, Compile, and Install Nginx
install_nginx() {
    cd "$BUILD_DIR"
    ./configure \
        --prefix=/etc/nginx \
        --sbin-path=/usr/sbin/nginx \
        --modules-path=/usr/lib/nginx/modules \
        --conf-path=/etc/nginx/nginx.conf \
        --error-log-path=/var/log/nginx/error.log \
        --http-log-path=/var/log/nginx/access.log \
        --pid-path=/run/nginx.pid \
        --lock-path=/run/nginx.lock \
        --user=www-data \
        --group=www-data \
        --with-http_ssl_module \
        --with-http_v2_module \
        --with-http_realip_module \
        --with-http_stub_status_module \
        --with-http_gzip_static_module \
        --with-pcre \
        --with-stream \
        --with-stream_ssl_module \
        --with-stream_ssl_preread_module

    make && make install

    # Create additional directories
    mkdir -p /etc/nginx/sites-available
    mkdir -p /etc/nginx/sites-enabled
    mkdir -p /etc/nginx/snippets
    mkdir -p /etc/nginx/conf.d
    mkdir -p /var/log/nginx
    mkdir -p /var/cache/nginx

    # Adjust nginx.conf to include sites-enabled and snippets
    echo "include /etc/nginx/conf.d/*.conf;" >> /etc/nginx/nginx.conf
    echo "include /etc/nginx/sites-enabled/*;" >> /etc/nginx/nginx.conf
    echo "include /etc/nginx/snippets/*;" >> /etc/nginx/nginx.conf
}

# Setup Nginx User
setup_user() {
    id www-data &>/dev/null || useradd -r -d /var/cache/nginx -s /sbin/nologin -U www-data
}

# Setup System Service
setup_service() {
    cat <<EOL > /etc/systemd/system/nginx.service
[Unit]
Description=Nginx HTTP and reverse proxy server
After=network.target

[Service]
Type=forking
PIDFile=/run/nginx.pid
ExecStartPre=/usr/sbin/nginx -t
ExecStart=/usr/sbin/nginx
ExecReload=/usr/sbin/nginx -s reload
ExecStop=/usr/sbin/nginx -s stop

[Install]
WantedBy=multi-user.target
EOL

    systemctl daemon-reload
    systemctl enable nginx
}

# Cleanup downloaded and extracted files
cleanup() {
    rm -rf "$BUILD_DIR" "${DOWNLOAD_DIR}/nginx-${NGINX_VERSION}.tar.gz"
}

# Main Function to Orchestrate Installation
main() {
    update_system
    download_nginx
    setup_user
    install_nginx
    setup_service
    cleanup
    echo "Nginx ${NGINX_VERSION} has been installed and the service has been enabled."
}

# Execute the script
main
