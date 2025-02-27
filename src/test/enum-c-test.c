
// enum-c-test.c

#include <stdio.h>

typedef enum
{
   Off, 
   On, 
   Rinse,
   Sauce,
   Centrifuge
}State;

int main (void)
{
    State Status;

    Status = On;
    printf("Current status = %d\n", Status);

    Status = Sauce;
    printf("Current status = %d\n", Status);
    return 0;
}
