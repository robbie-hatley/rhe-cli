// table-with-numbers-test.c
#include <stdlib.h>
#include <stdio.h>
int main (void)
{
   int i, n;
   LOOP:
   printf("Enter a positive integer from 1 to 500.\n");
   scanf("%d", &n);
   while(getchar() != '\n');
   if (n < 1 || n > 500)
      goto LOOP;
   printf("Here is a table with the first %d positive integers:\n", n);
   for ( i = 1 ; i <= n ; ++i )
   {
      printf("%4d", i);
      if (0 == i%10)
         printf("\n");
   }
   exit(EXIT_SUCCESS);
}