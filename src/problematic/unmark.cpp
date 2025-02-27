//unmark.cpp
//created in 2000 by Robbie Hatley
//Last updated Sunday July 8, 2001.
//This program removes html markup from *.htm files,
//and stores the unmarked text in *.txt files.
//Note: File names, including extention, must not
//exceed MaxFileName-2 characters in length.
//Exit Codes:
//200 - printed instructions and exited
//300 - normal execution and termination
//401 - too many arguments
//402 - invalid argument
//403 - input over-run on fgets()

//inclusions:
#include <cstdlib>
#include <cstdio>
#include <cstring>
#include <cmath>

#include <iostream>

#include "rhutil.hpp"
#include "rhdir.hpp"


//Definitions:
#define MaxArray    205
#define MaxFileName 150
#define MaxCommand  200

//Global Variables:
char OldFileName[MaxArray];
char NewFileName[MaxArray];

//Global Function Prototypes:
void MakeNewName(void);
void UnMarkFile(void);
void StrInit(char *a);
void CheckNewLine(char *S);
void Instructions(void);
void Error(int code);
void Help(void);

//Global Function Definitions:

int main(int argc, char *argv[])
{
  std::ios_base::sync_with_stdio();
  if (rhutil::HelpDecider(argc, argv, Help)) return 777;
  if (argc>2) Error(401);
  if (argc==2) {
    if (!strcmp(argv[1],"/?")) {
      Instructions();
      exit(200);
    }
    else {
      Error(402);
    }
  }
  char command[MaxArray], files[MaxArray];
  StrInit(command);
  StrInit(files);
  printf("Enter wildcard for files to be unmarked (don\'t use quotes):");
  fgets(files, MaxFileName+2, stdin);
  CheckNewLine(files);
  strcpy(command, "dir ");
  strncat(command, files, MaxFileName);
  strcat(command, " /b /-p /a:-d > C:\\TEMP\\filelist.txt");
  printf("Command string = %s\n", command);
  printf("Press Ctrl-Break, Enter to abort, or Enter to continue.\n");
  system("pause");
  system(command);
  FILE *fp1; // Declare file pointer for reading file-list file
  // Attempt to open file-list file for read-only; terminate if unable:
  if ((fp1 = fopen("C:\\TEMP\\filelist.txt", "r"))==NULL) Error(406);
  for (int FileCount=1 ; ; ++FileCount) {
    StrInit(OldFileName); // Initialize OldFileName
    if (fgets(OldFileName, MaxFileName+2, fp1) == NULL) break; // break if EOF
    CheckNewLine(OldFileName); // Check for input over-run
    printf("\n\nProcessing file #%d: %s\n", FileCount, OldFileName);
    MakeNewName(); // Make new file name
    printf("New file name is:  %s\n", NewFileName);
    UnMarkFile();  // Remove mark-up from text and store in new file
  }
  fclose(fp1);
  system("erase C:\\TEMP\\filelist.txt"); // Delete file-list file
  printf("Unmarked text now stored in files with extention ");
  printf("\".unmarked\".\nUse DOS command \"ren *.unmarked *.txt\" to ");
  printf("rename files to normal text-file extention if you like.\n");
  return 300;
}

void MakeNewName()
{
  StrInit(NewFileName);
  int E=strrchr(OldFileName, '.')-OldFileName;
  strncpy(NewFileName, OldFileName, E);
  strcat(NewFileName, ".unmarked\0");
}

void UnMarkFile()
{
  FILE *fp2, *fp3;
  char ch;
  if ((fp2 = fopen(OldFileName, "r"))==NULL) Error(404);
  if ((fp3 = fopen(NewFileName, "w"))==NULL) Error(405);
  printf("Now writing un-marked text to new file %s...\n", NewFileName);
  int TFlag=0, EFlag=0, BFlag=0, crlfcount=0;
  while ((ch = getc(fp2)) != EOF) {
    if (ch < 9 || ch > 126 || (ch > 10 && ch < 32)) continue;
    if (ch == '<') TFlag = -1;
    if (ch == '&') EFlag = -1;
    BFlag=TFlag|EFlag;          // Bypass Flag = Tag Flag OR Entity Flag
    if (!BFlag) {               // Write chars if Bypass Flag not set
      if (ch==10) {
        if (crlfcount++<2) {
          putc('\n', fp3);
        }
      }
      else {
        crlfcount=0;
        putc(ch, fp3);
      }
    } // end bypass zone
    if (ch == '>') TFlag = 0;
    if (ch == ';') EFlag = 0;
  } // end while loop
  fclose(fp2);
  fclose(fp3);
}

void StrInit(char *a)
{
  int i;
  for(i=0;i<MaxArray;++i) a[i]='\0';
}

void CheckNewLine(char *S) {
  if (strchr(S, '\n')==NULL) Error(403);
  else *strchr(S, '\n')='\0';
}

void Instructions() {
  printf("These instructions not yet written.\n");
}

void Error(int code) {
  switch (code) {
    case 401:
      printf("Error 401: Too many arguments (max is one).\n");
      break;
    case 402:
      printf("Error 402: Invalid argument ");
      printf("(the only valid argument is \"/?\").\n");
      break;
    case 403:
      printf("Error 403: Input over-run in fgets().\n");
      break;
    case 404:
      printf("Error 404: Cannot open input file.\n");
      break;
    case 405:
      printf("Error 405: Cannot open output file.\n");
      break;
    case 406:
      printf("Error 405: Cannot open file-list file.\n");
      break;
    default:
      printf("Unknown error; terminating.\n");
      break;
  }
  exit(code);
}

void Help(void)
{
   std::cout << "Help not yet written for this program." << std::endl;
   return;
}

