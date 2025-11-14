# Server Stats Monitor

A lightweight Bash script for monitoring system resources on Linux servers: CPU, memory, disk usage, and processes.

## Features

- 📊 CPU usage monitoring with configurable measurement interval
- 💾 Memory usage tracking
- 💿 Disk space monitoring for any mounted filesystem
- 🔝 Top processes by CPU and memory consumption
- 🎨 Color-coded output for quick status assessment
- ⚙️ Flexible threshold configuration

## Requirements

- Linux system with access to `/proc/stat` and `/proc/meminfo`
- Bash 4.0+
- Standard utilities: `awk`, `df`, `grep`, `ps`

## Installation
```bash
# Clone the repository
git clone https://github.com/your-username/server-stats.git
cd server-stats

# Make it executable
chmod +x server-stats.sh
```

## Usage

### Basic Usage
```bash
./server-stats.sh
```

### With Parameters
```bash
./server-stats.sh [CPU_THRESHOLD] [CPU_INTERVAL] [MEM_THRESHOLD] [DISK_THRESHOLD] [DISK_PATH] [TOP_CPU_PROCESSES] [TOP_MEM_PROCESSES]
```

### Parameters

| Parameter | Description | Default |
|-----------|-------------|---------|
| `CPU_THRESHOLD` | Warning threshold for CPU usage (0-100%) | 70 |
| `CPU_INTERVAL` | CPU measurement interval in seconds | 2 |
| `MEM_THRESHOLD` | Warning threshold for memory usage (0-100%) | 80 |
| `DISK_THRESHOLD` | Warning threshold for disk usage (0-100%) | 80 |
| `DISK_PATH` | Filesystem path to check | / |
| `TOP_CPU_PROCESSES` | Number of top processes by CPU | 5 |
| `TOP_MEM_PROCESSES` | Number of top processes by memory | 5 |

### Examples
```bash
# Use default thresholds
./server-stats.sh

# Set CPU threshold to 75% and interval to 3 seconds
./server-stats.sh 75 3

# Custom CPU, memory thresholds
./server-stats.sh 90 2 85

# Monitor /home partition with custom disk threshold
./server-stats.sh 90 2 85 90 /home

# Show top 10 CPU processes and top 5 memory processes
./server-stats.sh 90 2 85 90 /home 10 5
```

### Help and Version
```bash
# Show help
./server-stats.sh --help

# Show version
./server-stats.sh --version
```

## Sample Output
```
CPU usage:
  Interval:  2s
  Usage:  45% (threshold: 70%)

Memory usage:
  Total:   8192 MB
  Free :   3456 MB
  Used :   4736 MB
  Usage:  58% (threshold: 80%)

Disk usage (/):
  Total:    100 GB
  Used :     65 GB
  Free :     35 GB
  Usage:  65% (threshold: 80%)

Top 5 processes by CPU usage:
    PID COMMAND         %CPU
   1234 firefox         12.5
   5678 chrome           8.3
   9012 node             5.1
   3456 python           2.8
   7890 java             1.9

Top 5 processes by memory usage:
  1234   firefox               1024.5 MB
  5678   chrome                 856.2 MB
  9012   mysqld                 645.8 MB
  3456   java                   432.1 MB
  7890   python                 289.6 MB
```

## Color Coding

- 🟢 **Green**: Usage below (threshold - 20%)
- 🟡 **Yellow**: Usage between (threshold - 20%) and threshold
- 🔴 **Red**: Usage at or above threshold

Colors are automatically disabled when output is redirected to a file or pipe.

## Use Cases

- Quick server health checks
- Integration with monitoring dashboards
- Scheduled cron jobs for periodic checks
- Troubleshooting performance issues
- Capacity planning

## Automation Example

Add to crontab for hourly monitoring:
```bash
# Edit crontab
crontab -e

# Add line (runs every hour, logs to file)
0 * * * * /path/to/server-stats.sh >> /var/log/server-stats.log 2>&1
```

## License

MIT License - feel free to use and modify as needed.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## Acknowledgments

- Inspired by roadmap.sh platform
- https://roadmap.sh/projects/server-stats
