#n
#loop-test.sed
#extracts and prints lines from a file containing "unrise"
:top
/unrise/{
   p
   n
   b top
}

