/* read-numbers.c */
#include <stdio.h>
#define BUF_SIZ 100
int main (int quanto, char ** bento)
{
   char        buffer[BUF_SIZ] = {'\0'};
   int         a,b,c,d,e,f;
   int         count;
   int         row = 0;
   int         sum;
   double      average;
   FILE      * FileHandle;
   if ( 2 != quanto )
   {
      fprintf(stderr, 
      "Error, this program requires 1 argument, which must be\n"
      "a valid path to a text file containing rows of positive\n"
      "integers, 6 wide, separated by spaces.\n");
      return 666;
   }
   FileHandle = fopen(bento[1], "r");
   if (NULL==FileHandle)
   {
      fprintf(stderr, 
      "Error, this program's argument must be a valid path to\n"
      "a text file containing rows of positive integers,\n"
      "6 wide, separated by spaces.\n");
      return 666;
   }
   while ( 1 )
   {
      fgets(buffer, BUF_SIZ - 5, FileHandle);
      if (ferror(FileHandle))
      {
         fprintf(stderr, "Error reading file.\n");
         fclose(FileHandle);
         return 666;
      }
      if (feof(FileHandle)) break;
      count = sscanf(buffer, "%d %d %d %d %d %d", &a, &b, &c, &d, &e, &f);
      ++row;
      if (6 == count)
      {
         sum = a+b+c+d+e+f;
         average = (double)sum / 6.0;
         printf("Row = %3d:  Sum = %5d  Average = %5.3f\n", row, sum, average);
      }
      else
      {
         fprintf(stderr, "Row %d is corrupt.\n", row);
      }
   }
   fclose(FileHandle);
   printf("Processed %d rows.\n", row);
   return 0;
}
