#include <iostream>
#include <map>
#include <utility>
#include <string>

struct StudentData
{
   std::string name;
   int age;
   int score;
};

int main(void)
{
   std::multimap<int, StudentData> StudentMap;
   StudentData temp;
   
   temp.name = "Ralph";
   temp.age = 7;
   temp.score = 86;
   StudentMap.insert(std::make_pair(temp.score, temp));
   
   temp.name = "Tom";
   temp.age = 9;
   temp.score = 52;
   StudentMap.insert(std::make_pair(temp.score, temp));
   
   temp.name = "Susan";
   temp.age = 8;
   temp.score = 94;
   StudentMap.insert(std::make_pair(temp.score, temp));

   temp.name = "Fred";
   temp.age = 10;
   temp.score = 86;
   StudentMap.insert(std::make_pair(temp.score, temp));

   // The above will automatically sort students by score.
   // Use lower_bound(), upper_bound(), and equal_range() to get
   // iterators to students with particular scores.  For example, the
   // following will print all the students who scored each possible score
   // from 0 to 100:
   
   typedef std::multimap<int, StudentData>::iterator SMI;
   std::pair<SMI, SMI> Range;
   for (int score = 0; score<=100; ++score)
   {
      Range = StudentMap.equal_range(score);
      if (Range.first == Range.second) continue;
      std::cout << "Students with score " << score << ":" << std::endl;
      for (SMI iter = Range.first; iter != Range.second; ++iter)
      {
         std::cout << (*iter).second.name << std::endl;
      }
   }
}

