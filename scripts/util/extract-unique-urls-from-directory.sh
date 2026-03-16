#!/usr/bin/bash
# extract-unique-urls-from-directory.sh
/usr/bin/grep -PsIr --color=never 'https?://' * | extract-urls.pl | sort | uniq
