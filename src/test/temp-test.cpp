#include <iostream>
#include <iomanip>
#include <vector>
using std::vector;
using std::cout;
using std::endl;
using std::setprecision;
struct meta_segment
{
    long double id;
    std::vector<long double> num;
    std::vector<long double> mean;
    bool done;
};
int main()
{
   meta_segment S;
   S.num.push_back(3278.2054);
   S.num.push_back(7284.0355);
   S.mean.push_back(6342.3967);
   S.mean.push_back(3968.2853);
   cout << "S.num[0]  = " << setprecision(10) << S.num[0] << endl;
   cout << "S.num[1]  = " << setprecision(10) << S.num[1] << endl;
   cout << "S.mean[0] = " << setprecision(10) << S.mean[0] << endl;
   cout << "S.mean[1] = " << setprecision(10) << S.mean[1] << endl;
   return 0;
}
