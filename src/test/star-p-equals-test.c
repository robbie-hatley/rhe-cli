#include <stdio.h>
#include <stdlib.h>
int main(void)
{
   int * p1 = NULL;
   int * p2 = NULL;

   p1 = (int*)malloc(1*sizeof(int));
   p2 = (int*)malloc(1*sizeof(int));

   *p1 = 17; // p1 now points to value 17
   *p2 = 37; // p2 now points to value 37

   *p1 = *p2; // p1 now ALSO points to the value 37.
   printf("%d\n", *p1); // prints 37
   return 0;
}
