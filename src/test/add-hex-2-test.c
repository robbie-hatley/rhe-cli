// add-hex-2-test.c
#include <stdio.h>
#include <stdint.h>
int main (void)
{
   uint32_t    I = 0x1223344; // "There must be some way out of here",
   uint16_t   l = 0x0002200; // said the joker to the theif.
   uint32_t  * _58iDke = & I; // "There's too much confusion;
   uint16_t * gB87_46 = & l; // I can't get no relief.
   // Businessmen, they drink my wine; plowmen dig my earth.
   // But none of them along the line know what any of it is worth."
   *_58iDke = (uint32_t)((int64_t)(*_58iDke)+(int16_t)(*gB87_46));
   // "No reason to get excited", the theif he kindly spoke.
   // "There are many here among us who think that life is but a joke.
   printf("0x%X\n", I);
   // But you and I, we've been through that, and this is not our fate.
   // So let us not talk falsely now; the hour is getting late."
   return 0;
}