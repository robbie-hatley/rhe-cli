
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

int main (int Beren, char** Luthien)
{
   rename(Luthien[1], Luthien[2]);
   return 0;
}
