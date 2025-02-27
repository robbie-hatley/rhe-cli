#include <string>
#include <cstring>

int main()
{
   std::string Catz = "Round and round.";
   char* Batz = Catz.c_str();
   strcpy(Batz, "Oh my god!");
   return 0;
}
