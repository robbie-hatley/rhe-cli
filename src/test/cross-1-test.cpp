// cross-1-test.cpp
// To make "cross-test", compile-and-link this together with "cross-test-2.cpp".
#include <iostream>
#include <vector>
#include "cross-test.hpp"
extern void fifty_plus(int x);
CounterClass Bob;
int main (void)
{
	std::vector<int> Fred = {2,82,7,16,63,90,11,18,7,3,46,72,13,49,32,30,24,29,49,1,97};
	for ( int x : Fred )
	{
		fifty_plus(x);
	}
	std::cout << Bob.getcount() << std::endl;
	return 0;
}