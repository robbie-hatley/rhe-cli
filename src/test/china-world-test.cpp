// china-world.cpp
#include <iostream>
int main (void)
{
	std::string 你好("\x48\x65\x6c\x6c\x6f\x20\x57\x6f\x72\x6c\x64");
	std::cout << 你好 << std::endl;
	return 0;
}
