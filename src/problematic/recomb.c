/*
recomb.c
File recombining utility.
Combines parts of a file which were previously split.
Created by Robbie Hatley, June 2, 2001
Cleaned-up code, Sun Dec 03, 2006.
Exit codes:
  0 - Normal execution
666 - Error
*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>

#define  MAX_ARRAY  405
#define  MAX_CHARS  (MAX_ARRAY - 5)

const char PartList  [MAX_ARRAY] = "C:\\Temp\\PartList.tmp";
const char TempComb  [MAX_ARRAY] = "C:\\Temp\\TempComb.tmp";

char  WildCard     [MAX_ARRAY];
char  NewName      [MAX_ARRAY];
char  PartName     [MAX_ARRAY];
char  Command      [MAX_ARRAY];

void MakeFileList    (void);
void DestroyFileList (void);
void StripNewLine    (char *a);
void MakeCombFile    (void);
void DestroyCombFile (void);

int main(void)
{
  int    filecount  = 0;
  FILE  *fp1        = (FILE*)0;

  printf("%s%s%s%s",
  "Welcome to Robbie Hatley's file combining facility. This program\n",
  "binary-appends the files you specify (using wildcards), in alphabetical\n",
  "(ASCII) order of their names, and stores the combination in a file\n",
  "whose name you specify.\n\n");

  /* Get wildcard for file parts: */
  printf("Enter wildcard for files to be recombined (don't use quotes, and\n"
         "don't enter more than %d characters):\n", MAX_CHARS);
  fgets(WildCard, MAX_CHARS, stdin);
  StripNewLine(WildCard);
  printf("Wildcard is %s.\n", WildCard);

  /* Load part list: */
  sprintf(Command, "dir \"%s\" /b /-p /a:-d > %s", WildCard, PartList);
  system(Command);

  /* Get name for recombined file: */
  printf("\n\nEnter name for new, recombined file (%d characters max):\n",
         MAX_CHARS);
  fgets (NewName, MAX_CHARS, stdin);
  StripNewLine(NewName);
  printf("New file name will be %s.\n", NewName);

  fp1 = fopen(PartList, "r");

  for (filecount = 1; NULL != fgets(PartName,MAX_CHARS,fp1); ++filecount)
  {
    StripNewLine(PartName);
    if (1 == filecount)
    {
      sprintf(Command, "copy /b %s %s /y", PartName, TempComb);
    }
    else
    {
      sprintf(Command, "copy /b %s + %s %s /y", TempComb, PartName, TempComb);
    }
    printf("Combining part %i:\n", filecount);
    printf("%s\n", Command);
    system(Command);
  }

  /* Close temporary part-list file: */
  fclose(fp1);

  /* Erase temporary part-list file: */
  sprintf(Command, "erase %s", PartList);
  system(Command);

  /* Copy temporary recombined file to new file name: */
  sprintf(Command, "copy %s %s", TempComb, NewName);
  system(Command);

  /* Erase temporary recombined file: */
  sprintf(Command, "erase %s", TempComb);
  system(Command);

  /* Return success code: */
  return 0;
}

void StripNewLine(char *a)
{
  char *NLP;
  if ((char*)0 == (NLP=strchr(a, '\n')))
  {
    printf("Error: File name exceeds %u characters.\n", MAX_CHARS);
    exit(666);
  }
  else *NLP='\0';
}

