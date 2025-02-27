#include <stdio.h>
int main(void)
{
	char s[151] = {'\0'};
	char *p = &s[0];
	*p++ = 'a';
	*p++ = 'p';
	*p++ = 'p';
	*p++ = 'l';
	*p++ = 'e';
	p = &s[0];
	printf("%s\n", p);
   return 0;
}
