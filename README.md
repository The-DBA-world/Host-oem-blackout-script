# Host-oem-blackout-script
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
