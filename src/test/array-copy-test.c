// array-copy-test.c 
#include <stdio.h> 
#include <wchar.h> 
int main (void) 
{ 
   // First, make two wchar_t arrays, 
   // and put strings in them: 
   wchar_t A [75] = {u"She was a 747 captain."}; 
   wchar_t B [75] = {u"Empty."}; 
   // Now, make two pointers of type wchar_t, 
   // pointing to the 0th elements of arrays A and B. 
   // Note that we MUST inform the compiler that we 
   // are making pointers to 2-byte-wide referents: 
   wchar_t * a = &A[0]; 
   wchar_t * b = &B[0]; 
   // Copy contents of A to B: 
   while(*b++=*a++); 
   // Print B: 
   printf("%ls\n", B); 
   return 0; 
} 