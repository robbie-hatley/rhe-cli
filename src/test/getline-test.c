// getline-test.c

#include <stdio.h>
#include <stdlib.h>

int main (void)
{
   // FIRST, DECLARE, DEFINE, AND INITIALIZE ALL NECESSARY VARIABLES:
   char   * buffer  = NULL; // POINTER TO 0th BYTE OF BUFFER
   size_t   n       = 0;    // BYTES STORED IN BUFFER
   int      result  = 0;    // DID BUFFER ALLOCATION WORK?
   int      nums[6] = {0};  // TRANSFER BUFFER CONTENTS TO HERE

   // NEXT, REQUEST USER TO TYPE FIVE INTEGERS:
   printf("Enter five positive integers: ");

   // THIS NEXT LINE ALLOCATES ENOUGH MEMORY TO STORE THE TEXT
   // TYPED BY THE USER, POINTS "buffer" TO THE 0TH BYTE OF THE
   // ALLOCATED MEMORY BLOCK, AND STORES THE BLOCK SIZE IN "n":
   getline(&buffer, &n, stdin);

   // NEXT, WE SCAN THE BUFFER, LOOKING FOR INTS:
   result = 
      sscanf
      (
         buffer, 
         "%d%d%d%d%d%d", 
         &nums[0], &nums[1], &nums[2], &nums[3], &nums[4], &nums[5]
      );

   // ALWAYS GET INTO THE HABIT OF RELEASING ALL DYNAMICALLY-ALLOCATED
   // MEMORY IMMEDIATELY AFTER YOU'RE FINISHED USING IT:
   free(buffer);

   // IF WE FAILED TO GET 5 INTS, PRINT ERROR MESSAGE AND EXIT:
   if (5 != result)
   {
      fprintf
      (
         stderr, 
         "Error: you entered more or less than 5 numbers.\n"
      );
      exit(EXIT_FAILURE);
   }

   // IF WE SUCCEEDED IN GETTING 5 INTS, PRINT THOSE INTS:
   printf("You wrote: %d %d %d %d %d\n", 
      nums[0], nums[1], nums[2], nums[3], nums[4]);

   // WE'RE DONE, SO EXIT:
   exit(EXIT_SUCCESS);
}