// chatgpt4o-pear-tree.c
#include <stdio.h>

#define DAYS 12

const char* ordinals[DAYS] = {
    "first", "second", "third", "fourth", "fifth", "sixth",
    "seventh", "eighth", "ninth", "tenth", "eleventh", "twelfth"
};

const char* gifts[DAYS] = {
    "a partridge in a pear tree.\n",
    "two turtle doves,\n",
    "three french hens,\n",
    "four calling birds,\n",
    "five gold rings;\n",
    "six geese a-laying,\n",
    "seven swans a-swimming,\n",
    "eight maids a-milking,\n",
    "nine ladies dancing,\n",
    "ten lords a-leaping,\n",
    "eleven pipers piping,\n",
    "twelve drummers drumming,\n"
};

void sing_gifts(int day) {
    if (day < 0) return;
    if (day == 0 && day != DAYS - 1)
        printf("and %s", gifts[0]);
    else
        printf("%s", gifts[day]);
    sing_gifts(day - 1);
}

void sing_day(int day) {
    printf("On the %s day of Christmas my true love gave to me\n", ordinals[day]);
    sing_gifts(day);
    printf("\n");
}

int main(void) {
    for (int day = 0; day < DAYS; ++day)
        sing_day(day);
    return 0;
}
