// struct-demo.c
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
typedef struct
{
   char name[128];
   int  age;
   char location[128];
} Person;
int main (void)
{
   Person person;
   strcpy(person.name, "Samuel James Smith");
   person.age  = 54;
   strcpy(person.location, "Lisbon, Portugal");
   printf("person's name     is %s\n", person.name);
   printf("person's age      is %d\n", person.age);
   printf("person's location is %s\n", person.location);
   return 0;
}
