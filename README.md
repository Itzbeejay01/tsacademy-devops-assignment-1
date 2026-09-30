# TS Academy DevOps Assignment 1

## Linux, Bash & Networking Diagnostic Toolkit

This repository contains my solution for **Assignment 1 — Linux, Bash & Networking** from the TS Academy DevOps practical assignment.

The toolkit contains Bash scripts that collect Linux system information, check disk usage against a configurable threshold, perform host/network checks, and write timestamped operation logs under `logs/`.

## Project Structure

```text
.
├── README.md
├── system-info.sh
├── disk-check.sh
├── network-check.sh
├── grade.sh
└── logs/
    └── .gitkeep
```

## Requirements

The scripts are intended to run in a Linux environment with Bash. Common Linux utilities such as `df`, `hostname`, `uname`, `ping`, `getent`, and `ip` are used when available.

No cloud deployment is required.

## Setup

Clone the repository and enter it:

```bash
git clone https://github.com/Itzbeejay01/tsacademy-devops-assignment-1.git
cd tsacademy-devops-assignment-1
```

Ensure the scripts are executable:

```bash
chmod +x grade.sh system-info.sh disk-check.sh network-check.sh
```

## Usage

### System information

```bash
./system-info.sh
```

Displays the hostname, current user, date/time, operating system, kernel version, uptime, CPU information, memory information, and current working directory.

### Disk usage check

```bash
./disk-check.sh <threshold> [path]
```

Examples:

```bash
./disk-check.sh 80
./disk-check.sh 90 /var
```

The threshold must be an integer from 1 to 100. The default path is `/`.

Exit codes:

- `0` — disk usage is below the threshold.
- `1` — disk usage reached/exceeded the threshold or a runtime error occurred.
- `2` — invalid input.

### Network check

```bash
./network-check.sh <hostname-or-ip> [port]
```

Examples:

```bash
./network-check.sh localhost
./network-check.sh example.com 443
```

The optional TCP port must be an integer from 1 to 65535.

## Logging

Operations are logged to:

```text
logs/toolkit.log
```

Each entry includes a timestamp and a short description of the operation.

## Testing / Grading

Run the supplied local grader:

```bash
chmod +x grade.sh *.sh
./grade.sh
```

The grader checks project files, Bash syntax, executable permissions, script behaviour, input validation, logging, and basic Git history.

## Git Workflow

Development is split into meaningful commits. Network functionality is developed on a non-main feature branch and merged back into `main`.

## Assumptions

- The grader runs in a Linux environment, as specified in the assignment brief.
- Some networks block ICMP/ping. Host resolution is therefore reported separately from connectivity.
- TCP checks use `nc` when available and Bash `/dev/tcp` as a fallback.
