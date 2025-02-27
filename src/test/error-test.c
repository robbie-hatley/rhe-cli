/* error-test.c */
#include <stdio.h>
#include <errno.h>
#include <error.h>

int main (void)
{
   int i = 0;
   for ( i = 0 ; i < 256 ; ++i )
   {
      error( 0, i, "om");
   }
   fprintf(stderr, "error message count: %d\n", error_message_count);
   return 0;
}
