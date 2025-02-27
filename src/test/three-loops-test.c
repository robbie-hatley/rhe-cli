#include <stdio.h>
#include <stdlib.h>
int main(void)
{
   int i;

   /* WHILE: */
   i=0;
   while(i<5)
   {
      ++i;
   }

   /* DO-WHILE: */
   i=0;
   do
   {
      ++i;
   }while(i<5);

   /* FOR: */
   for(i=0;i<5;++i);

   /* THE LINE THAT DOES ALL THE WORK: */   
   system("perl -E 'say(2*$_)for(0..25);'");

   /* SCRAM: */
   return 0;
}
