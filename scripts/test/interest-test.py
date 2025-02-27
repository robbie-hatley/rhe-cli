#!/bin/python
def main():
	print("This program calculates the future value of a 10 - year investment.")
	principal = eval(input("Enter the initial principle:"))
	apr = eval(input("Enter the annual interest rate: "))
	for i in range(10):
		principal = principal * (1 + apr/100)
	print("The value in 10 years is:", principal)
main()
