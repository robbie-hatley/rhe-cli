#!/usr/bin/bash
# bad-char-test.sh
# Looks for soft hyphens, non-breaking spaces, zero-width spaces, and byte order marks
# in all non-hidden files in non-hidden directories, other than "*.txt" and "*.log".
# This is especially useful for finding and removing such characters from header,
# source-code, and script files.
grep -rPIn \
--exclude-dir='.[!.]*' \
--exclude='.*' \
--exclude='*.txt' \
--exclude='*.log' \
'\x{00AD}|\x{00A0}|\x{200B}|\x{FEFF}' \
.
