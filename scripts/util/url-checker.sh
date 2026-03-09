#!/usr/bin/env bash
# url-checker.sh

while IFS= read -r line; do

   # Skip blank lines:
   [[ $line =~ ^[[:space:]]*$ ]] && continue

   # Extract everything after the first "=":
   url=${line#*=}

   # Trim leading/trailing whitespace:
   url=${url#"${url%%[![:space:]]*}"}
   url=${url%"${url##*[![:space:]]}"}

   # Remove scheme (http://, https://, etc.):
   host=${url#*://}

   # Remove path:
   host=${host%%/*}

   # Remove port:
   host=${host%%:*}

   # Skip if empty after parsing:
   [[ -z $host ]] && {
      echo "BAD   $line"
      continue
   }
   # Skip if empty after parsing:
   [[ -z $host ]] && {
      continue
   }

   if ping -c 1 -W 2 "$host" > /dev/null 2>&1; then
      echo "LIVE:  line = $line  url = $url  host = $host"
   else
      echo "DEAD:  line = $line  url = $url  host = $host"
   fi
done
