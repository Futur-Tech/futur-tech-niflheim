#!/bin/bash

BLACKLIST_FILE="$(dirname "$0")/nidhogg_ipv4.txt"

function show_help() {
    echo "Usage: $0 [add|remove|sort|check_list] [IP_ADDRESS]"
    echo "   add IP_ADDRESS       - Adds an IP address to the blacklist"
    echo "   remove IP_ADDRESS    - Removes an IP address from the blacklist"
    echo "   sort                 - Sorts the blacklist and removes duplicates"
    echo "   check_list           - Checks if all IPs in the blacklist are valid"
}

function is_valid_ip() {
    local ip="$1"
    local stat=1

    # Check if the given string is a valid CIDR notation
    if [[ $ip =~ ^[0-9]{1,3}(\.[0-9]{1,3}){3}/[0-9]{1,2}$ ]]; then
        # Extract IP and prefix
        IFS='/' read -ra parts <<<"$ip"
        local ip_part="${parts[0]}"
        local prefix="${parts[1]}"

        # Check the validity of IP part and prefix range
        if [[ $ip_part =~ ^[0-9]{1,3}(\.[0-9]{1,3}){3}$ ]] && [[ $prefix -ge 0 && $prefix -le 32 ]]; then
            IFS='.' read -ra a <<<"$ip_part"
            [[ ${a[0]} -le 255 && ${a[1]} -le 255 && ${a[2]} -le 255 && ${a[3]} -le 255 ]]
            stat=$?
        fi
    # Check if the given string is a valid IP address
    elif [[ $ip =~ ^[0-9]{1,3}(\.[0-9]{1,3}){3}$ ]]; then
        IFS='.' read -ra a <<<"$ip"
        [[ ${a[0]} -le 255 && ${a[1]} -le 255 && ${a[2]} -le 255 && ${a[3]} -le 255 ]]
        stat=$?
    fi

    return $stat
}

function update_header() {
    local last_updated_line="# Last Updated: $(date '+%Y-%m-%d %H:%M:%S')"

    # Grab the lines that start with '#'
    local header=$(grep '^#' "$BLACKLIST_FILE")

    # Check if 'Last Updated:' is already present in header
    if grep -q 'Last Updated:' <<<"$header"; then
        # Update the Last Updated line
        header=$(sed "s/^# Last Updated:.*/$last_updated_line/" <<<"$header")
    else
        # Append Last Updated line
        header="$header\n$last_updated_line"
    fi

    # Keep the rest of the file contents (excluding lines that start with '#')
    local body=$(grep -v '^#' "$BLACKLIST_FILE")

    # Ensure there is an empty line at the end of the file
    echo -e "$header\n$body\n" >"$BLACKLIST_FILE"
}

function add_ip() {
    if is_valid_ip "$1"; then
        if grep -Fxq "$1" "$BLACKLIST_FILE"; then
            echo "IP $1 is already in the blacklist."
        else
            echo "$1" >>"$BLACKLIST_FILE"
            echo "Added $1 to blacklist."
            sort_and_dedup
            update_header
            check_list
        fi
    else
        echo "IP $1 is not a valid IP address."
    fi
}

function remove_ip() {
    if is_valid_ip "$1"; then
        if grep -Fxq "$1" "$BLACKLIST_FILE"; then
            grep -Fvx "$1" "$BLACKLIST_FILE" >"$BLACKLIST_FILE.tmp" && mv "$BLACKLIST_FILE.tmp" "$BLACKLIST_FILE"
            echo "Removed $1 from blacklist."
            update_header
            check_list
        else
            echo "IP $1 is not in the blacklist."
        fi
    else
        echo "IP $1 is not a valid IP address."
    fi
}

function sort_and_dedup() {
    # Backup the header (lines that start with '#')
    local header=$(grep '^#' "$BLACKLIST_FILE")

    # Sort the body and deduplicate (excluding lines that start with '#')
    local body=$(grep -v '^#' "$BLACKLIST_FILE" | sort -u)

    # Combine header and body back to the blacklist file, ensuring there is an empty line at the end
    echo -e "$header\n$body\n" >"$BLACKLIST_FILE"

    echo "Sorted and removed duplicates from the blacklist."
    update_header
}

function check_list() {
    # Check only the actual IP lines (excluding lines that start with '#' or are empty)
    grep -v '^#\|^$' "$BLACKLIST_FILE" | while IFS= read -r line; do
        if ! is_valid_ip "$line"; then
            echo "IP $line in the blacklist is not a valid IP address."
        fi
    done
}

# Main logic
case $1 in
add)
    if [[ -z $2 ]]; then
        show_help
    else
        add_ip "$2"
    fi
    ;;
remove)
    if [[ -z $2 ]]; then
        show_help
    else
        remove_ip "$2"
    fi
    ;;
sort)
    sort_and_dedup
    ;;
check_list)
    check_list
    ;;
*)
    show_help
    ;;
esac
