#!/bin/bash
#
# chatgpt_export.sh
#
# Usage:
#   chatgpt_export.sh curlfile chatname
#
# Example:
#   chatgpt_export.sh ai02.curl AI-02
#
# Produces:
#   AI-02.raw.json
#   AI-02.pretty.json
#   AI-02.md
#

set -euo pipefail

########################################
# Check arguments
########################################

if [[ $# -ne 2 ]]; then
    echo "Usage: $(basename "$0") curlfile chatname"
    exit 1
fi

curlfile="$1"
chatname="$2"

raw="${chatname}.raw.json"
pretty="${chatname}.pretty.json"
md="${chatname}.md"

########################################
# Validate input
########################################

if [[ ! -f "$curlfile" ]]; then
    echo "ERROR: curlfile not found: $curlfile"
    exit 1
fi

echo
echo "=================================================="
echo " Exporting ChatGPT conversation:"
echo "   curlfile = $curlfile"
echo "   chatname = $chatname"
echo "=================================================="
echo

########################################
# Run cURL command
########################################

echo "Step 1/3: Fetching raw JSON..."

bash "$curlfile" > "$raw"

echo "  wrote: $raw"
echo

########################################
# Pretty-print JSON
########################################

echo "Step 2/3: Pretty-printing JSON..."

jq . "$raw" > "$pretty"

echo "  wrote: $pretty"
echo

########################################
# Extract markdown
########################################

echo "Step 3/3: Extracting markdown..."

jq -r '.. | .parts? | select(.) | .[]' \
    "$pretty" > "$md"

echo "  wrote: $md"
echo

########################################
# Stats
########################################

echo "Done."
echo

wc -l \
    "$raw" \
    "$pretty" \
    "$md"

echo
echo "Markdown output:"
echo "  $md"
echo
