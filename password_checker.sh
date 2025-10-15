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

# --- Password Checking Logic (rules: min length, contains number, contains special) ---
check_password() {
  local pwd="$1"
  local fail_reasons=()

  # 1. Length check
  if (( ${#pwd} < MIN_LEN )); then
    fail_reasons+=("Too short (length ${#pwd}, min $MIN_LEN)")
  fi

  # 2. Number check
  if [[ ! "$pwd" =~ [0-9] ]]; then
    fail_reasons+=("Missing number")
  fi

  # 3. Special character check (basic set)
  if [[ ! "$pwd" =~ [\@\#\$\%\^\&\*\!\_\+\=\-] ]]; then
    fail_reasons+=("Missing special character")
  fi

  # Output block (friendly)
  if ((${#fail_reasons[@]})); then
    local out="Password: '$pwd' -> Weak\n"
    for reason in "${fail_reasons[@]}"; do
      out+="$reason\n"
    done
    printf "%b\n" "$out"
    return 1
  else
    printf "Password: '%s' -> Strong password\n\n" "$pwd"
    return 0
  fi
}

# Helper: process a list of passwords from stdin/file/array and optionally write to OUT_FILE
process_passwords() {
  local source="$1"   # path or "-" for stdin
  local line
  while IFS= read -r line || [[ -n "$line" ]]; do
    # skip empty lines
    if [[ -z "$line" ]]; then
      continue
    fi

    # run check_password and capture exit status
    if output="$(check_password "$line")"; then
      # strong
      if [[ -n "$OUT_FILE" ]]; then
        printf "%b\n" "$output" >> "$OUT_FILE"
      else
        printf "%b\n" "$output"
      fi
      ((count_strong++))
    else
      # weak (check_password already printed details to stdout in this flow, but we want consistent behavior)
      if [[ -n "$OUT_FILE" ]]; then
        printf "%b\n" "$output" >> "$OUT_FILE"
      else
        printf "%b\n" "$output"
      fi
      ((count_weak++))
    fi
    ((count_total++))
  done < "$source"
}

# --- Input selection: use -f file if provided, else positional arg, else stdin pipe ---
count_total=0
count_strong=0
count_weak=0

if [[ -n "$INPUT_FILE" ]]; then
  if [[ ! -f "$INPUT_FILE" || ! -r "$INPUT_FILE" ]]; then
    echo "Error: Input file '$INPUT_FILE' not found or not readable." >&2
    exit 3
  fi
  # prepare/clear output file if specified
  if [[ -n "$OUT_FILE" ]]; then
    : > "$OUT_FILE"
  fi
  process_passwords "$INPUT_FILE"
elif [[ $# -ge 1 ]]; then
  # single positional password
  if output="$(check_password "$1")"; then
    printf "%b\n" "$output"
    ((count_strong++, count_total++))
  else
    printf "%b\n" "$output"
    ((count_weak++, count_total++))
  fi
else
  # no positional; check for piped input (stdin)
  if [[ ! -t 0 ]]; then
    # prepare/clear output file if specified
    if [[ -n "$OUT_FILE" ]]; then
      : > "$OUT_FILE"
    fi
    process_passwords /dev/stdin
  else
    echo "Error: No password provided. Use -f file, pipe input, or pass a password." >&2
    usage
    exit 2
  fi
fi

# Print summary (to stdout and append to OUT_FILE if used)
summary="SUMMARY: total=${count_total}, strong=${count_strong}, weak=${count_weak}, min_len=${MIN_LEN}"
if [[ -n "$OUT_FILE" ]]; then
  printf "%s\n" "$summary" >> "$OUT_FILE"
fi
printf "%s\n" "$summary"

exit 0
