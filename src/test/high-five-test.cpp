#include <iostream>

class Five
{
   public:
      virtual void GiveFive() = 0; // pure virtual function
};

class HighFive : public Five
{
   public:
      void GiveFive() // virtual high five
      {
         std::cout << "High Five!!!" << std::endl;
      }
};

class LowFive : public Five
{
   public:
      void GiveFive() // virtual low five
      {
         std::cout << "Low Five!!!" << std::endl;
      }
};

int main(void)
{
   Five* FivePointer;          // pointer to a "Five" object (or derived class)

   FivePointer = new HighFive;
   FivePointer->GiveFive();    // polymorphic virtual high five for Tiff
   
   FivePointer = new LowFive;
   FivePointer->GiveFive();    // polymorphic virtual low  five for Tiff

   return 0;   
}

