/* This is a 79-character-wide ASCII C source-code text file.                */
/*=======|=========|=========|=========|=========|=========|=========|=======*/

/************************************************************************\
 * Program name:  Bytes-Of-Struct Test                                  *
 * Description:   Tests iterating through the bytes of a struct object. *
 * File name:     bytes-of-struct-test.c                                *
 * Source for:    bytes-of-struct-test.exe                              *
 * Author:        Robbie Hatley                                         *
 * Edit history:                                                        *
 *    Sat Jun 16, 2018 - Wrote it.                                      *
\************************************************************************/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

typedef struct Mystruct {
   double         Fred;
   float          Susan;
   unsigned long  Elen;
} MyType;

int main(void)
{
   MyType Object = {30.865, 19.462F, 293746573846576L};
   unsigned char * BytePtr = NULL;
   size_t Size = 0;
   size_t i = 0;

   Size = sizeof(Object);
   BytePtr = (unsigned char *)&Object;
   for ( i = 0 ; i < Size ; ++i )
      printf("%d, ", (int)BytePtr[i]);
   printf("\n");
   return 0;
}
