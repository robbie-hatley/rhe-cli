// getline-test-2.c
#include <stdio.h>
int main (void)
{
   char     * buffer    = NULL;
   size_t     n         = 0;
   ssize_t    c         = 0;
   printf("Enter a string: ");
   // The next line allocates the buffer for you:
   c = getline(&buffer, &n, stdin);
   printf("Buffer size     = %lu\n", n);
   printf("Characters read = %ld\n", c);
   printf("You wrote:\n%s\n", buffer);
   return 0;
}
