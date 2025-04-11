#!/usr/bin/python3
# all-vowels.py
import sys
import re
if len(sys.argv) != 2:
   sys.exit()
word=sys.argv[1]
if (     re.search(r'a', word)
     and re.search(r'e', word)
     and re.search(r'i', word)
     and re.search(r'o', word)
     and re.search(r'u', word) ) :
   print("Word has all vowels!")
else:
   print("Word does NOT have all vowels.")
