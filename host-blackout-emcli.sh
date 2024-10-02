#!/bin/bash

# Blackout Management Script
# Author: Anilkumar Sonawane
# Version: 1.0
# Date: $(date +%Y-%m-%d)
#
# Description:
# This script manages blackouts for hosts in Oracle Enterprise Manager.
# It can start, remove, and list blackouts for all hosts in a hostlist.txt file
# or for a single specified host.
#
# Usage:
#   ./blackout_manager.sh [start|remove|list|summary] [hostname]
#
#   start   - Start blackout for all hosts in hostlist.txt or a single host if specified
#   remove  - Remove blackouts for all hosts or a single host if specified
#   list    - List current blackouts for all hosts or a single host if specified
#   summary  - Show blackout summary for all hosts in hostlist.txt
#
# Examples:
#   ./blackout_manager.sh start           # Start blackout for all hosts in hostlist.txt
#   ./blackout_manager.sh start host1     # Start blackout for host1
#   ./blackout_manager.sh remove          # Remove blackouts for all hosts
#   ./blackout_manager.sh remove host1    # Remove blackout for host1
#   ./blackout_manager.sh list            # List blackouts for all hosts
#   ./blackout_manager.sh list host1      # List blackout for host1
#   ./blackout_manager.sh summary          # Show blackout summary for all hosts

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# Function to display usage
usage() {
    echo "Usage: $0 [start|remove|list|summary] [hostname]"
    echo "  start   - Start blackout for all hosts in hostlist.txt or a single host if specified"
    echo "  remove  - Remove blackouts for all hosts or a single host if specified"
    echo "  list    - List current blackouts for all hosts or a single host if specified"
    echo "  summary  - Show blackout summary for all hosts in hostlist.txt"
    exit 1
}

# Function to generate blackout name
generate_blackout_name() {
    local host=$1
    local date=$(date +%Y%m%d)
    echo "Patching_Blackout_${date}_${host}"
}

# Function to start blackout
start_blackout() {
    if [ -n "$1" ]; then
        # Start blackout for a single host
        local blackout_name=$(generate_blackout_name "$1")
        emcli create_blackout -name="${blackout_name}" \
            -add_targets="${1}:host" \
            -reason="Scheduled Maintenance" \
            -schedule="duration:12:0"
        echo "Blackout started for ${1}"
    else
        # Start blackout for all hosts in hostlist.txt
        while IFS= read -r host; do
            local blackout_name=$(generate_blackout_name "$host")
            emcli create_blackout -name="${blackout_name}" \
                -add_targets="${host}:host" \
                -reason="Scheduled Maintenance" \
                -schedule="duration:12:0"
            echo "Blackout started for ${host}"
        done < hostlist.txt
    fi
}

# Function to stop blackout
stop_blackout() {
    if [ -n "$1" ]; then
        # Stop blackout for a single host
        local blackout_name=$(generate_blackout_name "$1")
        emcli stop_blackout -name="${blackout_name}"
        echo "Blackout stopped for ${1}"
    else
        # Stop blackout for all hosts in hostlist.txt
        while IFS= read -r host; do
            local blackout_name=$(generate_blackout_name "$host")
            emcli stop_blackout -name="${blackout_name}"
            echo "Blackout stopped for ${host}"
        done < hostlist.txt
    fi
}

# Function to remove blackout
remove_blackout() {
    stop_blackout "$1"  # Stop the blackout before removing it
    if [ -n "$1" ]; then
        # Remove blackout for a single host
        local blackout_name=$(generate_blackout_name "$1")
        emcli delete_blackout -name="${blackout_name}"
        echo "Blackout removed for ${1}"
    else
        # Remove blackout for all hosts in hostlist.txt
        while IFS= read -r host; do
            local blackout_name=$(generate_blackout_name "$host")
            emcli delete_blackout -name="${blackout_name}"
            echo "Blackout removed for ${host}"
        done < hostlist.txt
    fi
}

# Function to list blackouts
list_blackouts() {
    local blackout_found=false
    local date=$(date +%Y%m%d)

    if [ -n "$1" ]; then
        # Check blackout for a single host
        local blackout_name="Patching_Blackout_${date}_${1}"
        if emcli get_blackout_details -name="${blackout_name}" &>/dev/null; then
            echo "Host under blackout: ${1}"
            blackout_found=true
        fi
    else
        # Check blackouts for all hosts in hostlist.txt
        while IFS= read -r host; do
            local blackout_name="Patching_Blackout_${date}_${host}"
            if emcli get_blackout_details -name="${blackout_name}" &>/dev/null; then
                echo "Host under blackout: ${host}"
                blackout_found=true
            fi
        done < hostlist.txt
    fi

    if [ "$blackout_found" = false ]; then
        echo "No hosts are currently under blackout from your hostlist.txt file."
    fi
}

# Function to show blackout summary
blackout_summary() {
    local date=$(date +%Y%m%d)
    echo -e "Hostname\t| Blackout\t|"
    echo -e "-------------------------------"

    while IFS= read -r host; do
        local blackout_name="Patching_Blackout_${date}_${host}"
        if emcli get_blackout_details -name="${blackout_name}" &>/dev/null; then
            echo -e "${RED}${host}\t| YES\t\t|${NC}"
        else
            echo -e "${GREEN}${host}\t| NO\t\t|${NC}"
        fi
    done < hostlist.txt
}

# Main script logic
case "$1" in
    start)
        start_blackout "$2"
        ;;
    remove)
        remove_blackout "$2"
        ;;
    list)
        list_blackouts "$2"
        ;;
    summary)
        blackout_summary
        ;;
    *)
        usage
        ;;
esac
