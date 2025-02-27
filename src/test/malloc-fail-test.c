#include <stdio.h>
#include <stdlib.h>
#include <errno.h>
#include <error.h>
int main (void)
{
   double * Fred = NULL;
   Fred = malloc(10000000000UL*sizeof(double));
   if (!Fred)
      error(EXIT_FAILURE, errno, "can't allocate");
   free(Fred);
   return 0;
}
