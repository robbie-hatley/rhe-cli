// singleton-test.cpp
#include <iostream>
using namespace std;

class Singleton
{
   public:
      ~Singleton()
      {
         if (instance_ptr)
         {
            delete instance_ptr;
            instance_ptr = NULL;
         }
      }
      static Singleton* GetInstance() 
      {
         if ( NULL == instance_ptr )
         {
            instance_ptr = new Singleton;
         }
         else
         {
            ++attempt_cntr;
         }
         return instance_ptr;
      }
      static void ReportAttempts (void)
      {
         cout << "Failed attempts at making copy: " << attempt_cntr << endl;
         return;
      }

   // Note: the default and copy constructors, and the assignment operator,
   // are made "private" and given empty function bodies in order to prevent
   // them from ever being called except by "GetInstance()":
   private:
      static Singleton* instance_ptr;         // Ptr to 0 or 1 instance.
      static int attempt_cntr;                // Count of rejected create attempts.
      Singleton(){};                          // Default constructor is private.
      Singleton(Singleton const&){};          // Copy constructor is private.
      Singleton& operator=(Singleton const&)
         {return *this;};                     // Assignment operator is private.
};

Singleton* Singleton::instance_ptr = NULL;
int        Singleton::attempt_cntr = 0;

int main (void)
{
   Singleton* MySingleton1 = Singleton::GetInstance();
   Singleton* MySingleton2 = Singleton::GetInstance();
   Singleton* MySingleton3 = Singleton::GetInstance();
   Singleton* MySingleton4 = Singleton::GetInstance();

   cout << "Made 4 attempts at creating Singleton objects." << endl;
   Singleton::ReportAttempts();
   return 0;
}
