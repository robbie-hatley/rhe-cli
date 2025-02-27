#!/bin/python3
import sys
print(sys.argv[1])
myfile = open(sys.argv[1], 'r')

while 1:
   myline=myfile.readline()
   if not myline:
	   print('end of file')
	   break
   else:
	   print(myline,end='')
