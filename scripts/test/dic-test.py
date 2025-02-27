#!/bin/python
user3704 = {}
user3704['id'] = 3704
user3704['wealth'] = '$35.42'
user3704['attributes'] = {}
user3704['attributes']['Name'  ] = "Robbie Hatley"
user3704['attributes']['Age'   ] = 61
user3704['attributes']['Height'] = 60
user3704['attributes']['Weight'] = 176
print("Robbie's id#:      ", user3704['id'        ]          )
print("Robbie's wealth:   ", user3704['wealth'    ]          )
print("Robbie's name:     ", user3704['attributes']['Name'  ])
print("Robbie's age:      ", user3704['attributes']['Age'   ])
print("Robbie's height:   ", user3704['attributes']['Height'])
print("Robbie's weight:   ", user3704['attributes']['Weight'])

print("\nNow Robbie goes on a diet...")

user3704['attributes']['Weight'] = 151

print("\nRobbie's weight:   ", user3704['attributes']['Weight'])

print("\nuser3704 = ", user3704)

for x in [y for y in [1,2,3]]:
	print(x)

def oufuiwhj (x):
   return -3.7*x*x +4.8*x -2.9

print (oufuiwhj(11.7))
