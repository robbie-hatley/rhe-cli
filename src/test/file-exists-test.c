
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

int main (int Beren, char** Luthien)
{
   if (__file_exists(Luthien[1]))
   {
      printf("File %s exists.\n", Luthien[1]);
   }
   else
   {
      printf("File %s does NOT exist.\n", Luthien[1]);
   }
   return 0;
}
