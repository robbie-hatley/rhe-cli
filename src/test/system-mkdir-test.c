#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/stat.h>
#include <errno.h>
#include <error.h>
int main (void)
{
   FILE * fp;
   chdir("/cygdrive/d");
   if (mkdir("aaa", S_IRWXU|S_IRWXG|S_IROTH))
   {
      error(EXIT_FAILURE, errno, "Failed to create directory aaa");
   }
   chdir("aaa");
   if (mkdir("bbb", S_IRWXU|S_IRWXG|S_IROTH))
   {
      error(EXIT_FAILURE, errno, "Failed to create directory bbb");
   }
   chdir("bbb");
   if (mkdir("ccc", S_IRWXU|S_IRWXG|S_IROTH))
   {
      error(EXIT_FAILURE, errno, "Failed to create directory ccc");
   }
   chdir("ccc");
   fp=fopen("MyFile.txt", "w");
   if (!fp)
   {
      error(EXIT_FAILURE, errno, "Failed to open file for writing");
   }
   fprintf(fp, "Test.\n");
   fclose(fp);
   return 0;
}
