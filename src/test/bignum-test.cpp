#include <iostream>
#include <string>

#define BLAT_ENABLE

#include "rhmath.hpp"


namespace ns_TestBigNum
{
   using std::cout;
   using std::endl;
   using rhmath::BigNum;
}


int main(void)
{
   using namespace ns_TestBigNum;   
/*
   BigNum n_84     (   84);
   BigNum n_16     (   16);
   BigNum n_min_72 (  -72);
   BigNum n_min_63 (  -63);
   BigNum n_15     (   15);
   BigNum n_3704   ( 3704);
   BigNum n_min_17 ("-17");
   BigNum n_42     ( "42");
   BigNum cpy        (n_15);     // Tests copy constructor.

   cpy = n_3704;                 // Tests assignment operator.

   cout << "n_84     + n_16     = " << n_84     + n_16     << endl;
   cout << "n_16     + n_84     = " << n_16     + n_84     << endl;
   cout << "n_84     - n_16     = " << n_84     - n_16     << endl;
   cout << "n_16     - n_84     = " << n_16     - n_84     << endl;

   cout << "n_min_72 + n_min_63 = " << n_min_72 + n_min_63 << endl;
   cout << "n_min_63 + n_min_72 = " << n_min_63 + n_min_72 << endl;
   cout << "n_min_72 - n_min_63 = " << n_min_72 - n_min_63 << endl;
   cout << "n_min_63 - n_min_72 = " << n_min_63 - n_min_72 << endl;

   cout << "n_84     + n_min_17 = " << n_84     + n_min_17 << endl;
   cout << "n_min_17 + n_84     = " << n_min_17 + n_84     << endl;
   cout << "n_84     - n_min_17 = " << n_84     - n_min_17 << endl;
   cout << "n_min_17 - n_84     = " << n_min_17 - n_84     << endl;

   cout << "n_15     + n_min_72 = " << n_15     + n_min_72 << endl;
   cout << "n_min_72 + n_15     = " << n_min_72 + n_15     << endl;
   cout << "n_15     - n_min_72 = " << n_15     - n_min_72 << endl;
   cout << "n_min_72 - n_15     = " << n_min_72 - n_15     << endl;

   cout << "9458478120578573862425742302865673198 + 885523456448318739509782109872342345 =" << endl;
   cout << BigNum("9458478120578573862425742302865673198")+BigNum("885523456448318739509782109872342345")
        << endl;

   cout << "9458478120578573862425742302865673198 - 885523456448318739509782109872342345 =" << endl;
   cout << BigNum("9458478120578573862425742302865673198")-BigNum("885523456448318739509782109872342345")
        << endl;
*/
   cout << "3754 + 87 = "
        << BigNum(3754) + BigNum(87)
        << endl;

   cout << "87 + 3754 = "
        << BigNum(87) + BigNum(3754)
        << endl;
/*
   cout << "17 * 34 = " 
        << BigNum(17) * BigNum(34)
        << endl;

   cout << "25365 * 84662 = " 
        << BigNum(25365) * BigNum(84662)
        << endl;

   cout << "3385027395835275935 * 4846623065837821916 = " 
        << BigNum(3385027395835275935LL) * BigNum(4846623065837821916LL)
        << endl;

   cout << "39475629479374652836 * 93995847408774502846 = " 
        << BigNum("39475629479374652836") * BigNum("93995847408774502846")
        << endl;

   cout << "7185394756882947984305853473746735452836 * 839958474535437408774502843116 = " 
        << BigNum("7185394756882947984305853473746735452836") * BigNum("839958474535437408774502843116")
        << endl;
*/
   return 0;
}
