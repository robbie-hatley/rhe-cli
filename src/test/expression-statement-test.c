/****************************************************************************\
 * expression-statement-test.c
 * by Robbie Hatley
 * Last edited Sun. June 16, 2002
 * This is a test of expression statements and pointers to string-literals
\****************************************************************************/

#include <stdlib.h>
#include <stdio.h>

int main(void) {
  char *p1, *p2;
  "This is a very bizzare way to comment a program!";
  "These three \"string-literal\" statements do nothing,";
  "as do the following numerical expression statements:";
  5;
  5+5;
  5+5*5/5;
  p1=(char*)&"These weird statements are fully-valid C-code, however.";
  p2=(char*)&"At least the two statements below actually do something....";
  printf("Cowabunga, dude!\n");
  printf("%s\n%s\n", p1, p2);
  if ((char*)&"President Bush" != (char*)&"intelligent lifeform")
    printf("The president is a dork!\n");
  return 43;
}

