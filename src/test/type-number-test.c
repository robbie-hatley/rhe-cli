#include <stdio.h>
#include <stdlib.h>
int main (void)
{
   char buf [50] = {'\0'};
   double number = 0.0;
   printf("Enter floating-point number:");
   fgets(buf, 45, stdin);
   sscanf(buf, "%lf", &number);
   printf("You typed: %lf\n", number);
   return 0;
}
