// pointer-equality-test.c
#include <stdio.h>
typedef struct Adam_tag {
   int    number;
   char   name[55];
} Adam;
int main (void)
{
   Adam   obj1;
   Adam   obj2;
   Adam * ptr1;
   Adam * ptr2;
   ptr1 = &obj1;
   ptr2 = &obj1; // Error; programmer meant "obj2"
   if (ptr1 == ptr2)
   {
      printf("Error: ptr1 == ptr2\n");
   }
   else
   {
      printf("ptr1 != ptr2\n");
   }
   return 0;
} 
