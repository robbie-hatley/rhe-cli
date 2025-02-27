
/************************************************************************************************************\
 * File name:     field-width-test.c
 * Author:        Robbie Hatley
 * Edit history:
 *    Sun Oct 20, 2024 - Wrote it.
\************************************************************************************************************/

#include <stdio.h>
#include <stdlib.h>
#include <locale.h>
int main(void)
{
   setlocale(LC_NUMERIC, "");
   printf("%'17.2f\n", 763543296.87);
   return 0;
}
