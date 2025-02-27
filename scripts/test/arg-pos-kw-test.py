#!/usr/bin/python

def Fred(a, b, *, c=0):
   return a*7*7 + b*7 + c;

print(Fred(2.1,a=1.43,c=-0.37))
