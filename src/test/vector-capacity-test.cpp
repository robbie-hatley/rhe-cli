#include <iostream>
#include <vector>

int main(void)
{
   using std::vector;
   using std::cout;
   using std::endl;
   
   vector<unsigned long int> Andy;
   
   cout << "Initial capacity of vector<unsigned long int> Andy = " << Andy.capacity() << endl;
   cout << "Initial   size   of vector<unsigned long int> Andy = " << Andy.size()     << endl;
   
   Andy.push_back(642);
   cout << "Capacity of Andy after pushing-back 1 unsigned long int  = " << Andy.capacity() << endl;
   cout << "Size     of Andy after pushing-back 1 unsigned long int  = " << Andy.size()     << endl;
   Andy.push_back(978);
   cout << "Capacity of Andy after pushing-back 2 unsigned long ints = " << Andy.capacity() << endl;
   cout << "Size     of Andy after pushing-back 2 unsigned long ints = " << Andy.size()     << endl;
   Andy.push_back(385);
   cout << "Capacity of Andy after pushing-back 3 unsigned long ints = " << Andy.capacity() << endl;
   cout << "Size     of Andy after pushing-back 3 unsigned long ints = " << Andy.size()     << endl;
   Andy.push_back(107);
   cout << "Capacity of Andy after pushing-back 4 unsigned long ints = " << Andy.capacity() << endl;
   cout << "Size     of Andy after pushing-back 4 unsigned long ints = " << Andy.size()     << endl;
   Andy.push_back(934);
   cout << "Capacity of Andy after pushing-back 5 unsigned long ints = " << Andy.capacity() << endl;
   cout << "Size     of Andy after pushing-back 5 unsigned long ints = " << Andy.size()     << endl;
   Andy.push_back(826);
   cout << "Capacity of Andy after pushing-back 6 unsigned long ints = " << Andy.capacity() << endl;
   cout << "Size     of Andy after pushing-back 6 unsigned long ints = " << Andy.size()     << endl;
   
   cout << " ... now executing Andy.reserve(1000) ... " << endl;
   Andy.reserve(1000);
   
   cout << "Capacity of Andy after reserving 1000 slots = " << Andy.capacity() << endl;
   cout << "  Size   of Andy after reserving 1000 slots = " << Andy.size()     << endl;
   
   cout << " ... now executing Andy.reserve(40) ... " << endl;
   Andy.reserve(40);
   
   cout << "Capacity of Andy after reserving   40 slots = " << Andy.capacity() << endl;
   cout << "  Size   of Andy after reserving   40 slots = " << Andy.size()     << endl;
   
   cout << " ... now making vector<unsigned long int> Temp ... " << endl; 
   vector<unsigned long int> Temp;
   
   cout << " ... now pushing 2 elements into Temp ..." << endl;
   Temp.push_back(362);
   Temp.push_back(178);
   
   cout << " ... now executing Andy.swap(Temp) ... " << endl;
   Andy.swap(Temp);
   
   cout << "Capacity of Andy after swapping with Temp = " << Andy.capacity() << endl;
   cout << "  Size   of Andy after swapping with Temp = " << Andy.size()     << endl;
   
   cout << "Capacity of Temp after swapping with Andy = " << Temp.capacity() << endl;
   cout << "  Size   of Temp after swapping with Andy = " << Temp.size()     << endl;
   
   cout << " ... now executing Andy = Temp ... " << endl;
   Andy = Temp;
   
   cout << "Capacity of Andy after assigning Temp to Andy = " << Andy.capacity() << endl;
   cout << "  Size   of Andy after assigning Temp to Andy = " << Andy.size()     << endl;
   
   return 0;
}
