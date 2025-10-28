#!/bin/bash

#---------------------------------------------------
# Show help to user.
#---------------------------------------------------
show_help() {
    echo "CPU Usage Monitor"
    echo
    echo "Usage:"
    echo "  $0 [THRESHOLD] [INTERVAL]"
    echo
    echo "Arguments:"
    echo "  THRESHOLD   Warning threshold in %, default: 70"
    echo "  INTERVAL    Measurement interval in seconds, default: 2"
    echo "  --help      Show this help message"
    exit 0
}


#---------------------------------------------------
# Validate that argument is a number
#---------------------------------------------------
is_number() {
    [[ "$1" =~ ^[0-9]+$ ]]
}


#---------------------------------------------------
# Read raw CPU statistics from /proc/stat.
# Returns:
#   echo "<idle> <total>"
#---------------------------------------------------
get_cpu_data() {
    idle_col=4
    iowait_col=5

    CPU=($(grep '^cpu ' /proc/stat))

    idle=${CPU[$idle_col]}
    iowait=${CPU[$iowait_col]}

    total_idle=$((idle + iowait))

    total_cpu=0

    for (( i=1; i<${#CPU[@]}; i++ )); do
        total_cpu=$((total_cpu + CPU[i]))
    done

    echo $total_idle $total_cpu
}


#---------------------------------------------------
# Calculate CPU usage percentage over interval.
# Arguments:
#   $1 - warning threshold (default: 70)
#   $2 - measurement interval (default: 2 seconds)
#---------------------------------------------------
get_cpu_usage() {
    threshold=${1:-70}
    interval=${2:-2}

    if ! is_number "$threshold" || (( threshold < 0 || threshold > 100 )); then
        echo "Error: Threshold must be a number between 0 and 100."
        exit 1
    fi

    if ! is_number "$interval" || (( interval <= 0 )); then
        echo "Error: Interval must be a positive number."
        exit 1
    fi
    
    read idle1 total1 <<< $(get_cpu_data)
    sleep $interval
    read idle2 total2 <<< $(get_cpu_data)

    total_diff=$((total2 - total1))
    if (( total_diff == 0 )); then
        echo "CPU usage: 0%"
        return
    fi

    idle_diff=$((idle2 - idle1))
    cpu_usage=$(( (100 * (total_diff - idle_diff)) / total_diff ))

    if (( cpu_usage >= threshold )); then
        echo -e "CPU usage: \e[31m${cpu_usage}%\e[0m (HIGH)"
    else
        echo -e "CPU usage: \e[32m${cpu_usage}%\e[0m"
    fi
}


if [[ "$1" == "--help" ]]; then
    show_help
fi

get_cpu_usage "$1" "$2"
