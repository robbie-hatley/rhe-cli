
// assign-once-test.c

#include <stdio.h>
#include <stdlib.h>

typedef struct assign_once_tag
{
   int variable;
   int assigned;
   int success;
} assign_once_t;

assign_once_t OneShot (int value);

int main (void)
{
   assign_once_t Susan;
   printf("Attempt to assign 17:\n");
   Susan = OneShot(17);
   printf("variable = %d\n", Susan.variable);
   printf("assigned = %d\n", Susan.assigned);
   printf("success  = %d\n", Susan.success);
   printf("Attempt to assign 42:\n");
   Susan = OneShot(42);
   printf("variable = %d\n", Susan.variable);
   printf("assigned = %d\n", Susan.assigned);
   printf("success  = %d\n", Susan.success);
   return 0;
}

assign_once_t OneShot (int value)
{
   static assign_once_t Fred = {0,0,0,};
   if (!Fred.assigned)
   {
      Fred.variable = value; 
      Fred.assigned = 1;
      Fred.success  = 1;
      return Fred;
   }
   else
   {
      Fred.success = 0;
      return Fred;
   }
}
