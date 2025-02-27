// This is a 79-character-wide utf-8-encoded C++ source-code text file.  
// ¡Hablo Español!  Говорю Русский.  Björt skjöldur.  麦藁雪、富士川町、山梨県。  
//=======|=========|=========|=========|=========|=========|=========|=========|=========|=========|=========|=========|

/**********************************************************************************************************************\
 * Program name:  Custom Inserter Test
 * File name:     custom-inserter-test.cpp
 * Source for:    custom-inserter-test.exe
 * Description:   Tests creation of custom inserter for C++ class.
 * Author:        Robbie Hatley
 * Edit History:
 *   Fri Apr 07, 2023: Wrote it.
\**********************************************************************************************************************/

// Include new C++ headers:
#include <iostream>
#include <ostream>
#include <string>

namespace ns_Cell
{
   class Cell_t // A cell.
   {
      public:
         Cell_t(std::string const & n) : name(n) {}
         friend std::ostream& operator<<(std::ostream& s, const Cell_t& c);
      private:
         std::string name;
   };

   // Inserter for printing name of Cell_t objects:
   std::ostream& operator<<(std::ostream& s, const Cell_t& c)
   {
      s << c.name;
      return s;
   }
}

int main (int Beren, char * Luthien[])
{
   std::string name = "asdf";
   if (Beren > 1) {name = Luthien[1];}
   ns_Cell::Cell_t cell (name);
   std::cout << cell << std::endl;
   return 0;
}
