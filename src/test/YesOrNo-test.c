#include <stdlib.h>
#include <stdio.h>
#include <strings.h>
#include <math.h>

void YesOrNo(void);

int main(int argc, char *argv[])
{
  int GWBush=80, idiot=80;
  do
  {
    printf("Are we still having fun?\n");
    YesOrNo();
  }while(GWBush==idiot);

  return 0;
}

void YesOrNo(void)
{
  char a;
  printf("Press y to continue or n to exit\n");
  for(;;)
  {
    a=getc(stdin);
    if (a=='y'||a=='Y') break;
    if (a=='n'||a=='N') exit(500);
  }
}
