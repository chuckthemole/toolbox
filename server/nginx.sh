#!/bin/bash
#
# nginx-helper.sh - A management script for Nginx on Debian/Ubuntu
#
# Provides shortcuts for common systemctl and nginx commands:
#   start, stop, restart, reload, status, enable, disable, test
#
# Usage:
#   nginx-helper.sh <command>
#
# Example:
#   nginx-helper.sh restart
#
# Notes:
# - Requires sudo privileges for systemctl/nginx commands
# - Always runs "nginx -t" before reload/restart to avoid config errors
#

NGINX_SERVICE="nginx"

show_help() {
    cat << EOF
Usage: $0 {start|stop|restart|reload|status|enable|disable|test|help}

Commands:
  start     Start the Nginx service
  stop      Stop the Nginx service
  restart   Restart Nginx (after config validation)
  reload    Reload Nginx config without dropping connections (after validation)
  status    Show Nginx service status
  enable    Enable Nginx to start on boot
  disable   Disable Nginx from starting on boot
  test      Validate Nginx configuration (nginx -t)
  help      Show this help message

Examples:
  $0 restart
  $0 status
EOF
}

validate_config() {
    echo ">> Validating Nginx configuration..."
    if ! sudo nginx -t; then
        echo "!! Configuration test failed. Aborting."
        exit 1
    fi
}

case "$1" in
    start)
        echo ">> Starting Nginx..."
        sudo systemctl start $NGINX_SERVICE
        ;;
    stop)
        echo ">> Stopping Nginx..."
        sudo systemctl stop $NGINX_SERVICE
        ;;
    restart)
        validate_config
        echo ">> Restarting Nginx..."
        sudo systemctl restart $NGINX_SERVICE
        ;;
    reload)
        validate_config
        echo ">> Reloading Nginx configuration..."
        sudo systemctl reload $NGINX_SERVICE
        ;;
    status)
        sudo systemctl status $NGINX_SERVICE
        ;;
    enable)
        echo ">> Enabling Nginx at boot..."
        sudo systemctl enable $NGINX_SERVICE
        ;;
    disable)
        echo ">> Disabling Nginx at boot..."
        sudo systemctl disable $NGINX_SERVICE
        ;;
    test)
        validate_config
        ;;
    help|--help|-h|"")
        show_help
        ;;
    *)
        echo "!! Invalid command: $1"
        show_help
        exit 1
        ;;
esac
