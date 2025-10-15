#!/usr/bin/env bash
# password_checker.sh - minimal password strength checker

usage() {
  prog="$(basename "$0")"
  echo ""
  echo "Usage: $prog [-h] [-m MIN_LEN] [-f FILE] [-o FILE] [-v] [password]"
  echo ""
  echo "Options:"
  echo "  -h            Show this help message"
  echo "  -m MIN_LEN    Minimum length (default 8)"
  echo "  -f FILE       Read passwords from FILE (one per line)"
  echo "  -o FILE       Write results to FILE"
  echo "  -v            Verbose"
  echo ""
  echo ""
}

MIN_LEN=8
INPUT_FILE=""
OUT_FILE=""
VERBOSE=0

# parse options
while getopts ":hm:f:o:v" opt; do
  case "$opt" in
    h) usage; exit 0 ;;
    m) [[ "$OPTARG" =~ ^[0-9]+$ ]] && MIN_LEN="$OPTARG" || { echo "Error: -m needs a number" >&2; usage; exit 2; } ;;
    f) INPUT_FILE="$OPTARG" ;;
    o) OUT_FILE="$OPTARG" ;;
    v) VERBOSE=1 ;;
    \?) echo "Error: invalid option -$OPTARG" >&2; usage; exit 2 ;;
    :) echo "Error: option -$OPTARG requires an argument" >&2; usage; exit 2 ;;
  esac
done
shift $((OPTIND-1))









