// fizz-buzz-test.c

#include <stdio.h>
#include <stdbool.h>

bool Div (int x, int y)
{
   return 0 == x%y;
}

int main (void)
{
   int i = 0;
   for ( i = 1 ; i <= 100 ; ++i )
   {
      if (Div(i,3) && !Div(i,5)){printf("Fizz\n");}
      else if (Div(i,5) && !Div(i,3)){printf("Buzz\n");}
      else if (Div(i,3) && Div(i,5)){printf("FizzBuzz\n");}
      else{printf("%d\n",i);}
   }
   return 0;
}