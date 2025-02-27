#!/usr/bin/python
# for-while-test.py

import timeit
import numpy

def while_loop(n=100_000_000):
   i = 0
   s = 0
   while i < n:
      s += i
      i += 1
   print(s)

def forrr_loop(n=100_000_000):
   s = 0
   for i in range(n):
      s+= i
   print(s)

def sumno_loop(n=100_000_000):
   print(sum(range(n)))

def npyno_loop(n=100_000_000):
   print(numpy.sum(numpy.arange(n)))

def gauno_loop(n=100_000_000):
   print(n*(n-1)//2)

def main():
   print('while loop: ', timeit.timeit(while_loop, number=1))
   print('forrr loop: ', timeit.timeit(forrr_loop, number=1))
   print('sumno loop: ', timeit.timeit(sumno_loop, number=1))
   print('npyno loop: ', timeit.timeit(npyno_loop, number=1))
   print('gauno loop: ', timeit.timeit(gauno_loop, number=1))

if __name__ == '__main__':
   main()
