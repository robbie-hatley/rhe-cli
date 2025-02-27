#include <stdio.h>
int main (void)
{
   FILE * FH = fopen("myfile.txt", "w");
   fprintf(FH, "Bread\n");
   fprintf(FH, "Beef\n");
   fprintf(FH, "Milk\n");
   fprintf(FH, "Eggs\n");
   fclose(FH);
   return 0;
}
