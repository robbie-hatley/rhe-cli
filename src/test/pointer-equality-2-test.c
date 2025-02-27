// pointer-equality-2-test.c
#include <stdio.h>
#include <string.h>
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
   ptr2 = &obj2;
   strcpy(ptr1->name, "obj1");
   strcpy(ptr2->name, "obj2");
   if ( 0 == strcmp(ptr1->name, ptr2->name))
   {
      printf("*ptr1 and *ptr2 have same name\n");
   }
   else
   {
      printf("*ptr1 and *ptr2 have different names\n");
   }
   return 0;
} 
