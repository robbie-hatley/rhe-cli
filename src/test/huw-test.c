
/* huw-test.c */

#include <stdio.h>
#include <stdlib.h>

unsigned int adcISRStack[3] = {
   ((unsigned int)0xa5a5a5a5),
   ((unsigned int)0xa5a5a5a5),
   ((unsigned int)0xa5a500a5)
};

/*
 * This prints "i = (value) and *p = (value) here.\n" 9 times and sets i to 9:
 */
void ADCStats() {
   int i = 0;
   unsigned char *p;
   p=(unsigned char *)&adcISRStack[0];
   printf("0th byte of 0th cell of adcISRStack = 0x%x\n", *p);
   while (*p == (unsigned char)0xa5) {                  /* compare ONE byte!!!         */
      printf("i = %u here and *p = 0x%x.\n", ++i, *p);  /* announce each new i and *p  */
      ++p;                                              /* advance pointer ONE byte!!! */
   }
   printf("Final value of i = %u\n", i);
   /* The next line will print "2.250000" on little-endian systems,
                            or "2.500000" on    big-endian systems: */
   printf("ISR stack high water = %f\n", (double)i/(double)sizeof(unsigned int));
}

void main (void) {
   ADCStats();
}
