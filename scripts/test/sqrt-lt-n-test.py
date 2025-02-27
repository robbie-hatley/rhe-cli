#!/bin/python3
import sys
import math
n=int(sys.argv[1])
i=1
while i < n:
   print("sqrt(", i, ") = ", math.sqrt(i))
   i+=1
