// person-class-test.cpp

#include <iostream>
#include <string>

using namespace std;

class Person
{
   public:
       Person () {}
       Person (int MemNo, string fName, string lName, string dateJoined)
       : memno (MemNo), szFirstName (fName), szLastName (lName), doj (dateJoined)
       {}
       void SetMemNo     (int    MemNo) { memno = MemNo; };
       void SetFirstName (string fName) { szFirstName = fName; };
       void SetLastName  (string lName) { szLastName = lName; };
       int GetMemNo      (void)         { return memno; };
       string GetFirstName() { return szFirstName; };
       string GetLastName() { return szLastName; };
       string GetDateJoined() { return doj; };
       void SetDateJoined(string dateJoined) { doj = dateJoined; };
       void displayPerson();
       bool operator < (const Person& str) const
       {
           return (szLastName < str.szLastName);
       }
    
   private:
       int memno = 0;
       string szFirstName{};
       string szLastName{};
       string doj{};
};

int main (void)
{
   Person P;
   P.SetMemNo(9381);
   cout << P.GetMemNo() << endl;
   return 0;
}
