// cross-2-test.cpp
// To make "cross-test", compile-and-link this together with "cross-test-1.cpp".
#include "cross-test.hpp"
extern CounterClass Bob;
void fifty_plus (int x)
{
	if (x>=50)
	{
		Bob.increment();
	}
}