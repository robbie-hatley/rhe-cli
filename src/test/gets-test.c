#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#define max 5
int main(void)
{
  char s[max], *v;
  int i;
  int flag=0;
  while(!flag)
  {
    for(i=0;i<max;++i)s[i]='\0';
    printf("Enter a string into gets, or q to quit\n");
    v=gets(s);
    if (v==NULL) flag=-1;
    if (s[0]=='q') flag=-1;
    printf("string = %s, pointer = %p, v = %p\n", s, s, v);
  }
  return 0;
}

