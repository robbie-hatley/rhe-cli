#include <iostream>
#include <vector>
#include <string>
using namespace::std;
int main (void)
{
   auto Fred {37};
	vector<string> Susan {"apple", "banana", "cabbage"};
	cout << "Fred = " << Fred << endl;
	for (string s : Susan) cout << s << endl;
	return 0;
}
