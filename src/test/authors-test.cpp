#include <iostream>
#include <list>
#include <string>

typedef std::list<std::string>           LS;
typedef std::list<std::string>::iterator LSI;

class BookType
{
   public:
      
      void AddAuthor(std::string const & A)
      {
         ListOfAuthors.push_back(A);
      }
      
      LS GetAuthors ()
      {
         return ListOfAuthors;
      }

   private:
      std::list<std::string> ListOfAuthors;
};

int main()
{
   BookType CookBooks;
   CookBooks.AddAuthor("Child, Julia"); 
   CookBooks.AddAuthor("Puck, Wolfgang"); 
   CookBooks.AddAuthor("Pepin, Jacques");
   LS  CBAuthors = CookBooks.GetAuthors();
   LSI i;
   for ( i = CBAuthors.begin() ; i != CBAuthors.end() ; ++i )
   {
      std::cout << (*i) << std::endl;
   }
   return 0;
}

