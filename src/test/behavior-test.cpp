#include <cstdlib>
#include <iostream>

class Client
{
   public:
      int behavior()
      {
         return MyController().behavior();
      }
   private:
      class Server
      {
         public:
            int behavior()
            {
               std::cout << "Server::behavior" << std::endl;
               return 0;
            }
      };
      static Server& MyController()
      {
         static Server Instance; 
         return Instance;
      }
};

int main()
{
   Client obj1;
   obj1.behavior();
   Client obj2;
   obj2.behavior();
   return 0;
}
