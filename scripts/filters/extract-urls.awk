#!/usr/bin/awk -f
# extract-urls.awk
# Extracts urls from a file.
# For each line of the input file which contains "http":
/http/ {
   # Split the line into words delimited by spaces or URL-illegal chars.:
   split($0, Words, /[[:blank:]<>\(\)\{\}\\^~\]\[`'"]/);
   # For each word, print only the URL part (if any), on it's own line:
   for (i in Words) {
      if (match(Words[i], /s?https?:\/\/[[:graph:]]+/)) {
         print(substr(Words[i], RSTART, RLENGTH));
      }
   }
}
