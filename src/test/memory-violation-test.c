
/* 
 *     /rhe/src/test/memory-violation-test.c
 */

#include "stdio.h"
#include "stdlib.h"

int foo (char * bar)
{
    for ( unsigned index = 0; index < 10; ++index )
       bar[ index ] = 'a';

    return 0;
}

int main( int argc, char **argv )
{
    char * array[ 100 ];

    int  max = atoi( argv[ 1 ] );

    for ( int index = max; index >= 0; --index )
    {
       array[ index ] = malloc( index + 1 );
    }

    for ( int index = max; index >= 0; --index )
    {
       foo( array[ index ] );
    }

    exit (0);
}
