// struct-demo-test.c

#include <stdio.h>

// make a struct:
typedef struct Parabola_tag
{
   double a;
   double b;
   double c;
} Parabola;

// Parameterized constructor:
void ConstructParabola (Parabola * Fred, double a, double b, double c)
{
   Fred->a = a;
   Fred->b = b;
   Fred->c = c;
}

// Application operator:
double ParabolaFunction (Parabola const * Fred, double x)
{
   return Fred->a*x*x + Fred->b*x + Fred->c;
}

int main (void)
{
   double x;

   // Make an object ("instance") of class Parabola:
   Parabola MyParabola;
   ConstructParabola (&MyParabola, 2.1, -1.7, 3.6);

   // Print some values of the parabola:
   for ( x = -10.0 ; x < 10.05 ; x+=0.1 )
   {
      printf("f(%f) = %f\n", x, ParabolaFunction(&MyParabola, x));
   }

   return 0;
}
