#!/usr/bin/env raku

my $a = 10;
my $b = 20;
say "The log of ($a + $b) is {log($a + $b)}.";
say "e**3.401197 = {e**3.401197}";
say "\"你好世界\" has {'你好世界'.chars} chars";
say "\"你好世界\" has {'你好世界'.encode('UTF-8').bytes} bytes";
say "\"i̢͋ͫ̆͗̉͐ͤ͊ͨ̓̾̏͏͔̘͇͓̰͔̰͈͚͍̠̺̯̥̻̠̫̘̀\" has {'i̢͋ͫ̆͗̉͐ͤ͊ͨ̓̾̏͏͔̘͇͓̰͔̰͈͚͍̠̺̯̥̻̠̫̘̀'.chars} chars";
say "\"i̢͋ͫ̆͗̉͐ͤ͊ͨ̓̾̏͏͔̘͇͓̰͔̰͈͚͍̠̺̯̥̻̠̫̘̀\" has {'i̢͋ͫ̆͗̉͐ͤ͊ͨ̓̾̏͏͔̘͇͓̰͔̰͈͚͍̠̺̯̥̻̠̫̘̀'.codes} codes";
