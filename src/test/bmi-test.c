// bmi-test.c

#include <stdio.h>
#include <stdlib.h>

#define UNDER   18.5 //      if under 18.5, you're underweight.
#define NORMAL  25.0 // else if under 25.0, you're normal.
#define OVER    30.0 // else if under 30.0, you're overweight
                     // else,               you're obese

int main (void)
{
   double weight,height,bmi;
   printf("Enter your weight: ");
   scanf("%lf", &weight);
   printf("enter your height: ");
   scanf("%lf", &height);
   bmi = weight / (height * height);
   printf("Your bmi = %f\n", bmi);
   if ( bmi < UNDER )
      printf("You are underweight!\n");
   else if ( bmi < NORMAL )
      printf("You are normal.\n");
   else if ( bmi < OVER )
      printf("You are overweight!\n");
   else
      printf("You are obese!\n");
   return 0;
}