#!/bin/bash

set -euo pipefail
# IFS=$'\n\t'


# ========== CONSTANTS & COLORS ==========

readonly SCRIPT_NAME=$(basename "$0")
readonly VERSION="0.1.0"

RED="\033[0;31m"
GREEN="\033[0;32m"
YELLOW="\033[1;33m"
RESET="\033[0m"

# disable colors if output not to terminal
if [[ ! -t 1 ]]; then
    RED=""; GREEN=""; YELLOW=""; RESET="";
fi


# ========== UTILS ==========

show_help() {
    cat <<EOF
$SCRIPT_NAME v$VERSION
--------------------------------------------
Usage:
  $SCRIPT_NAME [CPU_THRESHOLD] [INTERVAL] [MEM_THRESHOLD] [DISK_THRESHOLD] [PATH]


Description:
  Monitors system resource usage in real time.
  Calculates CPU usage over a time interval and
  displays current memory utilization.

Arguments:
  CPU_THRESHOLD   Warning threshold for CPU usage (0–100). Default: 70
  INTERVAL        CPU measurement interval in seconds. Default: 2
  MEM_THRESHOLD   Warning threshold for memory usage (0–100). Default: 80
  DISK_THRESHOLD  Warning threshold for disk usage (0-100). Default: 80
  PATH            PATH for checking disk usage. Default: /

Options:
  --help          Show this help message and exit
  --version       Show script version

Examples:
  $SCRIPT_NAME
  $SCRIPT_NAME 75 3
  $SCRIPT_NAME 90 2 85
  $SCRIPT_NAME 90 2 85 90 /home

EOF
}


is_number() {
    [[ "$1" =~ ^[0-9]+$ ]]
}


get_color_for_usage() {
    local usage=$1
    local threshold=$2

    if (( usage >= threshold )); then
        echo "$RED"
    elif (( usage >= threshold - 20 )); then
        echo "$YELLOW"
    else
        echo "$GREEN"
    fi
}


check_cmd() {
    for cmd in awk df grep; do
        if ! command -v "$cmd" >/dev/null 2>&1; then
            echo -e "${RED}Error:${RESET} required command '$cmd' not found."
            exit 1
        fi
    done
}

# ========== CPU MONITORING ==========

get_cpu_data() {
    local cpu=($(grep '^cpu ' /proc/stat))

    local idle=${cpu[4]}
    local iowait=${cpu[5]}
    local total_idle=$((idle + iowait))

    local total_cpu=0
    for ((i=1; i<${#cpu[@]}; i++)); do
        total_cpu=$((total_cpu + cpu[i]))
    done

    echo "$total_idle $total_cpu"
}


get_cpu_usage() {
    local threshold=${1:-70}
    local interval=${2:-2}

    read idle1 total1 <<< "$(get_cpu_data)"
    sleep "$interval"
    read idle2 total2 <<< "$(get_cpu_data)"

    local total_diff=$((total2 - total1))
    (( total_diff == 0 )) && { echo "CPU usage:\n Usage: 0%"; return; }

    local idle_diff=$((idle2-idle1))
    local usage=$(( (100 * (total_diff - idle_diff)) / total_diff ))

    local color
    color=$(get_color_for_usage "$usage" "$threshold")

    printf "CPU usage:\n"
    printf "  Interval: %2ds\n" "$interval"
    printf "  Usage: ${color}%3d%%${RESET} (threshold: %d%%)\n" "$usage" "$threshold"
}


# ========== MEMORY MONITORING ==========

get_memory_usage() {
    local mem_file="/proc/meminfo"
    local threshold=${1:-80}

    local mem_total=$(grep 'MemTotal' "$mem_file" | awk '{print $2}')
    local mem_available=$(grep 'MemAvailable' "$mem_file" | awk '{print $2}')

    local mem_used=$((mem_total-mem_available))
    local mem_total_mb=$((mem_total / 1024))
    local mem_free_mb=$((mem_available / 1024))
    local mem_used_mb=$((mem_used / 1024))

    if (( mem_total_mb > 0 )); then
        mem_usage=$((100 * mem_used_mb / mem_total_mb))
    else
        mem_usage=0
    fi

    local color
    color=$(get_color_for_usage "$mem_usage" "$threshold")

    printf "Memory usage:\n"
    printf "  Total: %6d MB\n" "$mem_total_mb"
    printf "  Free : %6d MB\n" "$mem_free_mb"
    printf "  Used : %6d MB\n" "$mem_used_mb"
    printf "  Usage: ${color}%3d%%${RESET} (threshold: %d%%)\n" "$mem_usage" "$threshold"
}


# ========== DISK MONITORING ==========

get_disk_usage() {
    local threshold=${1:-80}
    local path=${2:-/}

    if ! output=$(df -P "$path" 2>/dev/null | tail -1); then
        echo -e "${RED}Error:${RESET} path '$path' not found or inaccessible."
        return 1
    fi

    read _ size used avail pcent mount <<< "$output"
    pcent=${pcent%\%}

    local total_gb=$((size / 1024 / 1024))
    local used_gb=$((used / 1024 / 1024))
    local avail_gb=$((avail / 1024 / 1024))

    local color
    color=$(get_color_for_usage "$pcent" "$threshold")

    printf "Disk usage (%s):\n" "$mount"
    printf "  Total: %6d GB\n" "$total_gb"
    printf "  Used : %6d GB\n" "$used_gb"
    printf "  Free : %6d GB\n" "$avail_gb"
    printf "  Usage: ${color}%3d%%${RESET} (threshold: %d%%)\n" "$pcent" "$threshold"
}


# ========== MAIN LOGIC ==========

main() {
    case "${1:-}" in
        --help) show_help; exit 0 ;;
        --version) echo "$SCRIPT_NAME v$VERSION"; exit 0 ;;
    esac

    check_cmd

    local cpu_threshold=${1:-70}
    local interval=${2:-2}

    local mem_threshold=${3:-80}

    local disk_threshold=${4:-80}
    local path=${5:-/}

    echo
    get_cpu_usage "$cpu_threshold" "$interval"
    echo
    get_memory_usage "$mem_threshold"
    echo
    get_disk_usage "$disk_threshold" "$path"
    echo
}

main "$@"
