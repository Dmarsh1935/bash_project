# Password Checker

A simple Bash script to check password strength.
It validates passwords against a minimum length requirement and checks for the presence of numbers and special characters.

## Usage

./password_checker.sh [options] [password]

## Options

-h Show help message
-m Set minimum password length (default: 8)
-f Read passwords from file (one per line)
-o Write results to file
-v Verbose mode (more output)

## Examples

### Check a single password:
./password_checker.sh "Weak1!"

### Set a custom minimum length:
./password_checker.sh -m 12 "MyStrongP@ssw0rd"

### Read from a file:
./password_checker.sh -f passwords.txt

### Write results to a file:
./password_checker.sh -f passwords.txt -o results.txt

## Rules

A strong password must:

Be at least the minimum length (default 8)

Contain at least one number

Contain at least one special character

Testing

You can run quick checks after each commit, for example:

./password_checker.sh -h
./password_checker.sh "Strong1!"
./password_checker.sh "Weak1"