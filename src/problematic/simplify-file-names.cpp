/************************************************************************************************************\
 * File name:       simplify-file-names.cpp
 * Source for:      simplify-file-names.exe
 * Program name:    File-Name Simplifier
 * Author:          Robbie Hatley
 * Date written:    Thursday March 11, 2004
 * Description:     See Help() function definition at bottom of this file for description of this program.
 * To make:         Compile with djgpp and link with modules "rhdir.o" and "rhutil.o" in library "librh.a".
 * Edit history:
 *    Thu Mar 11, 2004 - Wrote it.
 *    Sat Jul 10, 2004 - Edited it.
 *    Sat Jan 15, 2005 - Added namespaces and chaged _rename() call to RenameFile() call.
 *    Sun Jan 16, 2005 - Dramatically simplified implimentation and added comments.
 *    Fri May 27, 2005 - Catch exceptions thrown by RenameFile().
 *    Wed Jun 08, 2005 - Updated conversions.
 *    Wed Aug 10, 2005 - Moved function SimplifyFileName to library rhdir.  Also, altered algorithm so it
 *                       leaves extra dots intact.
 *    Mon Aug 22, 2005 - Got rid of try/catch of exceptions for RenameFile().
 *    Sat May 31, 2008 - Corrected errors in the "Notes" section of this header block.
 *    Thu Feb 25, 2010 - 1. Took SimplifyFileName() out of library and put it in this application only.
 *                       2. Moved character map to main() so that it's only created and initialized ONCE,
 *                          at program startup, even if recursing hundreds of folders and processing
 *                          thousands of files.  Should speed things up dramatically.
 *                       3. I'm now passing CharMap
 *                       3. Made converting spaces to '_' non-default, much like dots and Hex.
 *                       4. Created boolians bSpaces, bDots, and bHex for controlling whether or not to
 *                          convert spaces/dots/Hex to "safe-n-sane" characters.
 *    Thu Mar 04, 2010 - Replaced "Notes" above with referal to "Help()" below.  (The Notes were getting
 *                       more and more out-of-sync with Help().)
\************************************************************************************************************/

#include <ctime>

#include <iostream>
#include <list>
#include <deque>
#include <string>

// To use asserts, undef NDEBUG.
// To NOT use asserts, define NDEBUG.
#define NDEBUG
#undef  NDEBUG
#include <assert.h>
#include <errno.h>

// To use BLAT, define BLAT_ENABLE.
// To NOT use BLAT, undef BLAT_ENABLE.
#define BLAT_ENABLE
#undef  BLAT_ENABLE

#include "rhutil.hpp"
#include "rhdir.hpp"

namespace ns_SFN
{
   using std::cout;
   using std::cerr;
   using std::endl;
   using std::setfill;
   using std::setw;

   typedef  std::list<std::string>    LS;
   typedef  LS::iterator              LSI;
   typedef  LS::const_iterator        LSCI;
   typedef  std::vector<std::string>  VS;
   typedef  VS::iterator              VSI;
   typedef  VS::const_iterator        VSCI;
   typedef  rhdir::FileRecord         FR;
   typedef  std::list<FR>             LFR;
   typedef  LFR::iterator             LFRI;
   typedef  LFR::const_iterator       LFRCI;
   typedef  std::vector<FR>           VFR;
   typedef  VFR::iterator             VFRI;
   typedef  VFR::const_iterator       VFRCI;

   struct Bools_t // program boolean settings
   {
      bool bHelp;     // Print help and exit.
      bool bRecurse;  // Recursively descend directory tree from current node.
      bool bVerbose;  // Be talkative.
      bool bCommas;   // Convert ,;^        to '$'.
      bool bSpaces;   // Convert spaces     to '_'.
      bool bHyphens;  // Convert spaces     to '-' instead (overrides bSpaces).
      bool bDots;     // Convert extra dots to '`'.
      bool bHex;      // Convert "%5A" etc  to appropriate characters.
   };

   struct Stats_t // program run-time statistics
   {
      time_t    StartTime; // Time we started  this program run.
      time_t    EndTime;   // Time we finished this program run.
      time_t    RunTime;   // Elapsed time.
      uint32_t  DirCount;  // Directories processed.
      uint32_t  FilCount;  // Files processed.
      uint32_t  BypCount;  // Files bypassed.
      uint32_t  BadCount;  // Files with bad names.
      uint32_t  EnuCount;  // Files with undenumerable names.
      uint32_t  AttCount;  // File renames attempted.
      uint32_t  SucCount;  // File renames succeeded.
      uint32_t  FaiCount;  // File renames failed.
      void PrintStats (void)
      {
         RunTime = EndTime - StartTime;
         cout
                                                                               << endl
            << "Simplify-File-Names run finished."                             << endl
            << "Elapsed time:           " << setw(7) << RunTime << " seconds." << endl
            << "Directories processed:  " << setw(7) << DirCount               << endl
            << "Files processed:        " << setw(7) << FilCount               << endl
            << "Files bypassed:         " << setw(7) << BypCount               << endl
            << "Files with bad names:   " << setw(7) << BadCount               << endl
            << "Undenumerable files:    " << setw(7) << EnuCount               << endl
            << "File renames attempted: " << setw(7) << AttCount               << endl
            << "File renames succeeded: " << setw(7) << SucCount               << endl
            << "File renames falied:    " << setw(7) << FaiCount               << endl
                                                                               << endl;
         return;
      }
   };

   void
   ProcessFlags
   (
      VS           const  &  Flags,
      Bools_t             &  Bools
   );

   void InitializeCharMap (char * CharMap);

   class ProcessCurDirFunctor
   {
      public:
         ProcessCurDirFunctor
            (
               Bools_t   const  &  Bools_,
               VS        const  &  Arguments_,
               char      const  *  CharMap_,
               Stats_t          &  Stats_,
               VFR              &  FileList_
            )
            :
               Bools        (Bools_),
               Arguments    (Arguments_),
               CharMap      (CharMap_),
               Stats        (Stats_),
               FileList     (FileList_)
            {}
         void operator()(void); // defined below
      private:
         Bools_t   const  &  Bools;
         VS        const  &  Arguments;
         char      const  *  CharMap;
         Stats_t          &  Stats;
         VFR              &  FileList;
   };

   void
   ProcessCurrentFile
   (
      char     const  *  CharMap,
      Bools_t  const  &  Bools,
      Stats_t         &  Stats,
      FR       const  &  FileRec
   );

   std::string
   SimplifyFileName
   (
      std::string  const  &  Name,
      char         const  *  CharMap,
      Bools_t      const  &  Bools
   );

   char GetCharFromHex (std::string Hex);

   void Help (void);

} // end namespace ns_SFN


//////////////////////////////////////////////////////////////////////////////
//                                                                          //
//  main()                                                                  //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////

int main (int Beren, char * Luthien[])
{
   using namespace ns_SFN;
   srand(time(0));
   VS Flags;
   rhutil::GetFlags (Beren, Luthien, Flags);

   Bools_t Bools = {false};
   ProcessFlags(Flags, Bools);

   if (Bools.bHelp)
   {
      Help();
      return 777;
   }

   VS Arguments;
   rhutil::GetArguments(Beren, Luthien, Arguments);

   Stats_t Stats = Stats_t();
   time(&Stats.StartTime);

   static VFR FileRecords;
   FileRecords.reserve(10000);

   // Create a 256-element array of char called "char_map":
   char char_map [256]; // Don't bother initializing on this line (see next line).

   // Load char_map with a map from raw to processed character values
   // (note that this initializes each of the 256 values of char_map):
   InitializeCharMap(char_map);

   ProcessCurDirFunctor ProcessCurDir (Bools, Arguments, char_map, Stats, FileRecords);

   if (Bools.bRecurse)
   {
      rhdir::CursDirs(ProcessCurDir);
   }
   else
   {
      ProcessCurDir();
   }

   time(&Stats.EndTime);

   Stats.PrintStats();

   return 0;
} // end main()


//////////////////////////////////////////////////////////////////////////////
//                                                                          //
//  void ns_SFN::InitializeCharMap (char * CharMap);                        //
//                                                                          //
//  Initializes an array of 256 chars with a remapping from unsafe to safe  //
//  values.                                                                 //
//                                                                          //
//  WARNING: This function must initialize all indexes from 0 to 255 and    //
//  ONLY the indexes from 0 to 255.  If it ever accesses indexes outside    //
//  that range, it could crash the application or the operating system!     //
//  SO TAKE NOTE OF THIS BEFORE EDITING THIS FUNCTION!                      //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////

void
ns_SFN::
InitializeCharMap
   (
      char * CharMap
   )
{
   // Map all possible characters (0 through 255) to safe-and-sane values:
   CharMap [  0] = '+'; //  NUL -> '+' (control character)
   CharMap [  1] = '+'; //  SOH -> '+' (control character)
   CharMap [  2] = '+'; //  STX -> '+' (control character)
   CharMap [  3] = '+'; //  ETX -> '+' (control character)
   CharMap [  4] = '+'; //  EOT -> '+' (control character)
   CharMap [  5] = '+'; //  ENQ -> '+' (control character)
   CharMap [  6] = '+'; //  ACK -> '+' (control character)
   CharMap [  7] = '+'; //  BEL -> '+' (control character)
   CharMap [  8] = '+'; //   BS -> '+' (control character)
   CharMap [  9] = '+'; //   HT -> '+' (control character)
   CharMap [ 10] = '+'; //   LF -> '+' (control character)
   CharMap [ 11] = '+'; //   VT -> '+' (control character)
   CharMap [ 12] = '+'; //   FF -> '+' (control character)
   CharMap [ 13] = '+'; //   CR -> '+' (control character)
   CharMap [ 14] = '+'; //   SO -> '+' (control character)
   CharMap [ 15] = '+'; //   SI -> '+' (control character)
   CharMap [ 16] = '+'; //  DLE -> '+' (control character)
   CharMap [ 17] = '+'; //  DC1 -> '+' (control character)
   CharMap [ 18] = '+'; //  DC2 -> '+' (control character)
   CharMap [ 19] = '+'; //  DC3 -> '+' (control character)
   CharMap [ 20] = '+'; //  DC4 -> '+' (control character)
   CharMap [ 21] = '+'; //  NAK -> '+' (control character)
   CharMap [ 22] = '+'; //  SYN -> '+' (control character)
   CharMap [ 23] = '+'; //  ETB -> '+' (control character)
   CharMap [ 24] = '+'; //  CAN -> '+' (control character)
   CharMap [ 25] = '+'; //   EM -> '+' (control character)
   CharMap [ 26] = '+'; //  SUB -> '+' (control character)
   CharMap [ 27] = '+'; //  ESC -> '+' (control character)
   CharMap [ 28] = '+'; //   FS -> '+' (control character)
   CharMap [ 29] = '+'; //   GS -> '+' (control character)
   CharMap [ 30] = '+'; //   RS -> '+' (control character)
   CharMap [ 31] = '+'; //   US -> '+' (control character)
   CharMap [ 32] = ' '; //  ' ' -> ' ' (space) (illegal in unix/linux file names, but leave it for now)
   CharMap [ 33] = '!'; //  '!' -> '!' (exclamation; bang)
   CharMap [ 34] = '\'';//  '"' -> '@' (double quote) (illegal in windows long file names)
   CharMap [ 35] = '#'; //  '#' -> '#' (octothorpe; pound; number sign)
   CharMap [ 36] = '$'; //  '$' -> '$' (dollar sign)
   CharMap [ 37] = '%'; //  '%' -> '%' (percent)
   CharMap [ 38] = '&'; //  '&' -> '&' (ampersand) (requires quoting in DOS)
   CharMap [ 39] = '\'';//  ''' -> ''' (single quote)
   CharMap [ 40] = '('; //  '(' -> '(' (left/opening parenthesis)
   CharMap [ 41] = ')'; //  ')' -> ')' (right/closing parenthesis)
   CharMap [ 42] = '\'';//  '*' -> '@' (asterisk; star; splat) (illegal in windows long file names)
   CharMap [ 43] = '+'; //  '+' -> '+' (plus)
   CharMap [ 44] = ','; //  ',' -> ',' (comma) (requires quoting in DOS)
   CharMap [ 45] = '-'; //  '-' -> '-' (hyphen; minus-sign; dash
   CharMap [ 46] = '.'; //  '.' -> '.' (dot; period)
   CharMap [ 47] = '@'; //  '/' -> '@' (slant; slash) (illegal in windows long file names)
   CharMap [ 48] = '0'; //  '0' -> '0' (numeral 0)
   CharMap [ 49] = '1'; //  '1' -> '1' (numeral 1)
   CharMap [ 50] = '2'; //  '2' -> '2' (numeral 2)
   CharMap [ 51] = '3'; //  '3' -> '3' (numeral 3)
   CharMap [ 52] = '4'; //  '4' -> '4' (numeral 4)
   CharMap [ 53] = '5'; //  '5' -> '5' (numeral 5)
   CharMap [ 54] = '6'; //  '6' -> '6' (numeral 6)
   CharMap [ 55] = '7'; //  '7' -> '7' (numeral 7)
   CharMap [ 56] = '8'; //  '8' -> '8' (numeral 8)
   CharMap [ 57] = '9'; //  '9' -> '9' (numeral 9)
   CharMap [ 58] = '-'; //  ':' -> '@' (colon) (illegal in windows long file names)
   CharMap [ 59] = ';'; //  ';' -> ';' (semicolon) (requires quoting in DOS)
   CharMap [ 60] = '('; //  '<' -> '@' (less than) (illegal in windows long file names)
   CharMap [ 61] = '='; //  '=' -> '=' (equals)
   CharMap [ 62] = ')'; //  '>' -> '@' (greater than) (illegal in windows long file names)
   CharMap [ 63] = 'Q'; //  '?' -> '@' (question mark) (illegal in windows long file names)
   CharMap [ 64] = '@'; //  '@' -> '@' (at)
   CharMap [ 65] = 'A'; //  'A' -> 'A' (UPPER-CASE LETTER A)
   CharMap [ 66] = 'B'; //  'B' -> 'B' (UPPER-CASE LETTER B)
   CharMap [ 67] = 'C'; //  'C' -> 'C' (UPPER-CASE LETTER C)
   CharMap [ 68] = 'D'; //  'D' -> 'D' (UPPER-CASE LETTER D)
   CharMap [ 69] = 'E'; //  'E' -> 'E' (UPPER-CASE LETTER E)
   CharMap [ 70] = 'F'; //  'F' -> 'F' (UPPER-CASE LETTER F)
   CharMap [ 71] = 'G'; //  'G' -> 'G' (UPPER-CASE LETTER G)
   CharMap [ 72] = 'H'; //  'H' -> 'H' (UPPER-CASE LETTER H)
   CharMap [ 73] = 'I'; //  'I' -> 'I' (UPPER-CASE LETTER I)
   CharMap [ 74] = 'J'; //  'J' -> 'J' (UPPER-CASE LETTER J)
   CharMap [ 75] = 'K'; //  'K' -> 'K' (UPPER-CASE LETTER K)
   CharMap [ 76] = 'L'; //  'L' -> 'L' (UPPER-CASE LETTER L)
   CharMap [ 77] = 'M'; //  'M' -> 'M' (UPPER-CASE LETTER M)
   CharMap [ 78] = 'N'; //  'N' -> 'N' (UPPER-CASE LETTER N)
   CharMap [ 79] = 'O'; //  'O' -> 'O' (UPPER-CASE LETTER O)
   CharMap [ 80] = 'P'; //  'P' -> 'P' (UPPER-CASE LETTER P)
   CharMap [ 81] = 'Q'; //  'Q' -> 'Q' (UPPER-CASE LETTER Q)
   CharMap [ 82] = 'R'; //  'R' -> 'R' (UPPER-CASE LETTER R)
   CharMap [ 83] = 'S'; //  'S' -> 'S' (UPPER-CASE LETTER S)
   CharMap [ 84] = 'T'; //  'T' -> 'T' (UPPER-CASE LETTER T)
   CharMap [ 85] = 'U'; //  'U' -> 'U' (UPPER-CASE LETTER U)
   CharMap [ 86] = 'V'; //  'V' -> 'V' (UPPER-CASE LETTER V)
   CharMap [ 87] = 'W'; //  'W' -> 'W' (UPPER-CASE LETTER W)
   CharMap [ 88] = 'X'; //  'X' -> 'X' (UPPER-CASE LETTER X)
   CharMap [ 89] = 'Y'; //  'Y' -> 'Y' (UPPER-CASE LETTER Y)
   CharMap [ 90] = 'Z'; //  'Z' -> 'Z' (UPPER-CASE LETTER Z)
   CharMap [ 91] = '['; //  '[' -> '[' (left/opening bracket)
   CharMap [ 92] = '@'; //  '\' -> '@' (backslant; backslash) (illegal in windows long file names)
   CharMap [ 93] = ']'; //  ']' -> ']' (right/closing bracket)
   CharMap [ 94] = '^'; //  '^' -> '^' (caret; circumflex) (requires quoting in DOS)
   CharMap [ 95] = '_'; //  '_' -> '_' (underscore)
   CharMap [ 96] = '`'; //  '`' -> '`' (left single quote; grave accent; backtick)
   CharMap [ 97] = 'a'; //  'a' -> 'a' (lower-case letter a)
   CharMap [ 98] = 'b'; //  'b' -> 'b' (lower-case letter b)
   CharMap [ 99] = 'c'; //  'c' -> 'c' (lower-case letter c)
   CharMap [100] = 'd'; //  'd' -> 'd' (lower-case letter d)
   CharMap [101] = 'e'; //  'e' -> 'e' (lower-case letter e)
   CharMap [102] = 'f'; //  'f' -> 'f' (lower-case letter f)
   CharMap [103] = 'g'; //  'g' -> 'g' (lower-case letter g)
   CharMap [104] = 'h'; //  'h' -> 'h' (lower-case letter h)
   CharMap [105] = 'i'; //  'i' -> 'i' (lower-case letter i)
   CharMap [106] = 'j'; //  'j' -> 'j' (lower-case letter j)
   CharMap [107] = 'k'; //  'k' -> 'k' (lower-case letter k)
   CharMap [108] = 'l'; //  'l' -> 'l' (lower-case letter l)
   CharMap [109] = 'm'; //  'm' -> 'm' (lower-case letter m)
   CharMap [110] = 'n'; //  'n' -> 'n' (lower-case letter n)
   CharMap [111] = 'o'; //  'o' -> 'o' (lower-case letter o)
   CharMap [112] = 'p'; //  'p' -> 'p' (lower-case letter p)
   CharMap [113] = 'q'; //  'q' -> 'q' (lower-case letter q)
   CharMap [114] = 'r'; //  'r' -> 'r' (lower-case letter r)
   CharMap [115] = 's'; //  's' -> 's' (lower-case letter s)
   CharMap [116] = 't'; //  't' -> 't' (lower-case letter t)
   CharMap [117] = 'u'; //  'u' -> 'u' (lower-case letter u)
   CharMap [118] = 'v'; //  'v' -> 'v' (lower-case letter v)
   CharMap [119] = 'w'; //  'w' -> 'w' (lower-case letter w)
   CharMap [120] = 'x'; //  'x' -> 'x' (lower-case letter x)
   CharMap [121] = 'y'; //  'y' -> 'y' (lower-case letter y)
   CharMap [122] = 'z'; //  'z' -> 'z' (lower-case letter z)
   CharMap [123] = '{'; //  '{' -> '{' (left/opening brace)
   CharMap [124] = '@'; //  '|' -> '@' (vertical bar) (illegal in windows long file names)
   CharMap [125] = '}'; //  '}' -> '}' (right/closing brace)
   CharMap [126] = '-'; //  '~' -> '-' (tilde) (interferes with DOS 8x3 file names)
   CharMap [127] = '+'; //  DEL -> '+' (control character)
   CharMap [128] = '!'; //  '€' -> '!' (Not part of iso-8859-1.)
   CharMap [129] = '!'; //  '' -> '!' (Not part of iso-8859-1.)
   CharMap [130] = '!'; //  '‚' -> '!' (Not part of iso-8859-1.)
   CharMap [131] = '!'; //  'ƒ' -> '!' (Not part of iso-8859-1.)
   CharMap [132] = '!'; //  '„' -> '!' (Not part of iso-8859-1.)
   CharMap [133] = '!'; //  '…' -> '!' (Not part of iso-8859-1.)
   CharMap [134] = '!'; //  '†' -> '!' (Not part of iso-8859-1.)
   CharMap [135] = '!'; //  '‡' -> '!' (Not part of iso-8859-1.)
   CharMap [136] = '!'; //  'ˆ' -> '!' (Not part of iso-8859-1.)
   CharMap [137] = '!'; //  '‰' -> '!' (Not part of iso-8859-1.)
   CharMap [138] = '!'; //  'Š' -> '!' (Not part of iso-8859-1.)
   CharMap [139] = '!'; //  '‹' -> '!' (Not part of iso-8859-1.)
   CharMap [140] = '!'; //  'Œ' -> '!' (Not part of iso-8859-1.)
   CharMap [141] = '!'; //  '' -> '!' (Not part of iso-8859-1.)
   CharMap [142] = '!'; //  'Ž' -> '!' (Not part of iso-8859-1.)
   CharMap [143] = '!'; //  '' -> '!' (Not part of iso-8859-1.)
   CharMap [144] = '!'; //  '' -> '!' (Not part of iso-8859-1.)
   CharMap [145] = '!'; //  '‘' -> '!' (Not part of iso-8859-1.)
   CharMap [146] = '!'; //  '’' -> '!' (Not part of iso-8859-1.)
   CharMap [147] = '!'; //  '“' -> '!' (Not part of iso-8859-1.)
   CharMap [148] = '!'; //  '”' -> '!' (Not part of iso-8859-1.)
   CharMap [149] = '!'; //  '•' -> '!' (Not part of iso-8859-1.)
   CharMap [150] = '!'; //  '–' -> '!' (Not part of iso-8859-1.)
   CharMap [151] = '!'; //  '—' -> '!' (Not part of iso-8859-1.)
   CharMap [152] = '!'; //  '˜' -> '!' (Not part of iso-8859-1.)
   CharMap [153] = '!'; //  '™' -> '!' (Not part of iso-8859-1.)
   CharMap [154] = '!'; //  'š' -> '!' (Not part of iso-8859-1.)
   CharMap [155] = '!'; //  '›' -> '!' (Not part of iso-8859-1.)
   CharMap [156] = '!'; //  'œ' -> '!' (Not part of iso-8859-1.)
   CharMap [157] = '!'; //  '' -> '!' (Not part of iso-8859-1.)
   CharMap [158] = '!'; //  'ž' -> '!' (Not part of iso-8859-1.)
   CharMap [159] = '!'; //  'Ÿ' -> '!' (Not part of iso-8859-1.)
   CharMap [160] = '!'; //  NBS -> '!' (non-breaking space)
   CharMap [161] = '!'; //  '¡' -> '!'
   CharMap [162] = '!'; //  '¢' -> '!' (cents)
   CharMap [163] = '!'; //  '£' -> '!' (pounds)
   CharMap [164] = '!'; //  '¤' -> '!' (currency)
   CharMap [165] = '!'; //  '¥' -> '!' (yen)
   CharMap [166] = '!'; //  '¦' -> '!' (vertical bar)
   CharMap [167] = '!'; //  '§' -> '!' (section)
   CharMap [168] = '!'; //  '¨' -> '!' (umlaut)
   CharMap [169] = '!'; //  '©' -> '!' (copyright)
   CharMap [170] = '!'; //  'ª' -> '!'
   CharMap [171] = '!'; //  '«' -> '!' (guillemotleft)
   CharMap [172] = '!'; //  '¬' -> '!' (not sign)
   CharMap [173] = '!'; //  '­' -> '!' (soft hyphen)
   CharMap [174] = '!'; //  '®' -> '!' (registered trademark)
   CharMap [175] = '!'; //  '¯' -> '!' (macron accent)
   CharMap [176] = '!'; //  '°' -> '!' (degrees)
   CharMap [177] = '!'; //  '±' -> '!'
   CharMap [178] = '!'; //  '²' -> '!'
   CharMap [179] = '!'; //  '³' -> '!'
   CharMap [180] = '!'; //  '´' -> '!'
   CharMap [181] = '!'; //  'µ' -> '!'
   CharMap [182] = '!'; //  '¶' -> '!'
   CharMap [183] = '!'; //  '·' -> '!'
   CharMap [184] = '!'; //  '¸' -> '!'
   CharMap [185] = '!'; //  '¹' -> '!'
   CharMap [186] = '!'; //  'º' -> '!'
   CharMap [187] = '!'; //  '»' -> '!'
   CharMap [188] = '!'; //  '¼' -> '!'
   CharMap [189] = '!'; //  '½' -> '!'
   CharMap [190] = '!'; //  '¾' -> '!'
   CharMap [191] = '!'; //  '¿' -> '!'
   CharMap [192] = '!'; //  'À' -> '!'
   CharMap [193] = '!'; //  'Á' -> '!'
   CharMap [194] = '!'; //  'Â' -> '!'
   CharMap [195] = '!'; //  'Ã' -> '!'
   CharMap [196] = '!'; //  'Ä' -> '!'
   CharMap [197] = '!'; //  'Å' -> '!'
   CharMap [198] = '!'; //  'Æ' -> '!'
   CharMap [199] = '!'; //  'Ç' -> '!'
   CharMap [200] = '!'; //  'È' -> '!'
   CharMap [201] = '!'; //  'É' -> '!'
   CharMap [202] = '!'; //  'Ê' -> '!'
   CharMap [203] = '!'; //  'Ë' -> '!'
   CharMap [204] = '!'; //  'Ì' -> '!'
   CharMap [205] = '!'; //  'Í' -> '!'
   CharMap [206] = '!'; //  'Î' -> '!'
   CharMap [207] = '!'; //  'Ï' -> '!'
   CharMap [208] = '!'; //  'Ð' -> '!' (Icelandic capital Edh) (voiced "th" sound)
   CharMap [209] = '!'; //  'Ñ' -> '!'
   CharMap [210] = '!'; //  'Ò' -> '!'
   CharMap [211] = '!'; //  'Ó' -> '!'
   CharMap [212] = '!'; //  'Ô' -> '!'
   CharMap [213] = '!'; //  'Õ' -> '!'
   CharMap [214] = '!'; //  'Ö' -> '!'
   CharMap [215] = '!'; //  '×' -> '!'
   CharMap [216] = '!'; //  'Ø' -> '!'
   CharMap [217] = '!'; //  'Ù' -> '!'
   CharMap [218] = '!'; //  'Ú' -> '!'
   CharMap [219] = '!'; //  'Û' -> '!'
   CharMap [220] = '!'; //  'Ü' -> '!'
   CharMap [221] = '!'; //  'Ý' -> '!'
   CharMap [222] = '!'; //  'Þ' -> '!' (Icelandic capital Thorn) (unvoiced "th" sound)
   CharMap [223] = '!'; //  'ß' -> '!' (German small sharp s)
   CharMap [224] = '!'; //  'à' -> '!'
   CharMap [225] = '!'; //  'á' -> '!'
   CharMap [226] = '!'; //  'â' -> '!'
   CharMap [227] = '!'; //  'ã' -> '!'
   CharMap [228] = '!'; //  'ä' -> '!'
   CharMap [229] = '!'; //  'å' -> '!'
   CharMap [230] = '!'; //  'æ' -> '!'
   CharMap [231] = '!'; //  'ç' -> '!'
   CharMap [232] = '!'; //  'è' -> '!'
   CharMap [233] = '!'; //  'é' -> '!'
   CharMap [234] = '!'; //  'ê' -> '!'
   CharMap [235] = '!'; //  'ë' -> '!'
   CharMap [236] = '!'; //  'ì' -> '!'
   CharMap [237] = '!'; //  'í' -> '!'
   CharMap [238] = '!'; //  'î' -> '!'
   CharMap [239] = '!'; //  'ï' -> '!'
   CharMap [240] = '!'; //  'ð' -> '!' (Icelandic small Edh) (voiced "th" sound)
   CharMap [241] = '!'; //  'ñ' -> '!' (Spanish small Enye) ("ny" sound)
   CharMap [242] = '!'; //  'ò' -> '!'
   CharMap [243] = '!'; //  'ó' -> '!'
   CharMap [244] = '!'; //  'ô' -> '!'
   CharMap [245] = '!'; //  'õ' -> '!'
   CharMap [246] = '!'; //  'ö' -> '!'
   CharMap [247] = '!'; //  '÷' -> '!' (division sign)
   CharMap [248] = '!'; //  'ø' -> '!'
   CharMap [249] = '!'; //  'ù' -> '!'
   CharMap [250] = '!'; //  'ú' -> '!'
   CharMap [251] = '!'; //  'û' -> '!'
   CharMap [252] = '!'; //  'ü' -> '!'
   CharMap [253] = '!'; //  'ý' -> '!'
   CharMap [254] = '!'; //  'þ' -> '!' (Icelandic small Thorn) (unvoiced "th" sound)
   CharMap [255] = '!'; //  'ÿ' -> '!'

   // At this point, CharMap should be completely initialized to its final
   // values.  Let's assert that all of its values are > 31 and < 127:
   for ( int i = 0 ; i < 256 ; ++i )
   {
      assert((int)(unsigned char)CharMap[i] >  31);
      assert((int)(unsigned char)CharMap[i] < 127);
   }

} // end ns_SFN::InitializeCharMap()


//////////////////////////////////////////////////////////////////////////////
//                                                                          //
//  ProcessFlags()                                                          //
//                                                                          //
//  Sets program-state booleans based on Flags.                             //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////

void
ns_SFN::
ProcessFlags
   (
      VS       const  &  Flags,
      Bools_t         &  Bools
   )
{
   BLAT("\nJust entered ProcessFlags().  About to set Bools.\n")

   // Use InVec from rhutil:
   using rhutil::InVec;

   Bools.bHelp    = InVec(Flags, "-h") or InVec(Flags, "--help"   ); // Print help and exit?
   Bools.bRecurse = InVec(Flags, "-r") or InVec(Flags, "--recurse"); // Recurse?
   Bools.bCommas  = InVec(Flags, "-c") or InVec(Flags, "--commas");  // Convert ,;^&       to '$'?
   Bools.bSpaces  = InVec(Flags, "-s") or InVec(Flags, "--spaces");  // Convert spaces     to '_'?
   Bools.bHyphens = InVec(Flags, "-p") or InVec(Flags, "--hyphens"); // Convert spaces     to '-'?
   Bools.bDots    = InVec(Flags, "-d") or InVec(Flags, "--dots");    // Convert extra dots to '`'?
   Bools.bHex     = InVec(Flags, "-H") or InVec(Flags, "--hex");     // Convert "%5A" etc  to chars?

   // If a "-a" or "--all" flag is used, then turn on commas, spaces, dots, and hex:
   if (InVec(Flags, "-a") or InVec(Flags, "--all"))
   {
      Bools.bCommas  = true;
      Bools.bSpaces  = true;
      Bools.bDots    = true;
      Bools.bHex     = true;
   }

   BLAT("About to return from ProcessFlags.\n")
   return;
} // end ns_SFN::ProcessFlags()


//////////////////////////////////////////////////////////////////////////////
//                                                                          //
//  ProcessCurDirFunctor::operator()                                        //
//                                                                          //
//  Processes current directory.                                            //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////

void ns_SFN::ProcessCurDirFunctor::operator() (void)
{
   // ABSTRACT:
   // For each file in current directory, calls ProcessCurrentFile(),
   // which which converts all unsafe characters in file name to safe characters.


   BLAT("\nJust entered ProcessCurDir::operator().\n")

   // Increment directory counter:
   ++Stats.DirCount;

   // Get current directory:
   std::string CurDir = rhdir::GetFullCurrPath();

   // If being verbose, announce processing current directory:
   if (Bools.bVerbose)
   {
      cout
         << "\n"
         << "=================================================================\n"
         << "Directory #" << Stats.DirCount << ":\n"
         << CurDir << "\n"
         << endl;
   }

   // Get vector of file records for all files in current directory which match
   // the wildcards given by the command-line arguments, if any.
   // If no arguments were given, get all files:
   FileList.clear();
   std::string Wildcard;
   if (Arguments.size() > 0)
   {
      for (VS::const_iterator i = Arguments.begin(); i != Arguments.end(); ++i)
      {
         Wildcard = *i;
         rhdir::LoadFileList
         (
            FileList,  // Name of container to load.
            Wildcard,  // File-name wildcard.
            1,         // Files only (not dirs).
            2          // Append to list without clearing.
         );
      }
   }
   else
   {
      rhdir::LoadFileList(FileList); // Get all files.
   }

   BLAT("\nIn ProcessCurDirFunctor::operator().")
   BLAT("Finished building file list.")
   BLAT("File list size is " << FileList.size())
   BLAT("About to enter file-iteration for loop.\n")

   // Process all files in list:
   for ( VFRCI i = FileList.begin() ; i != FileList.end() ; ++i )
   {
      ++Stats.FilCount;
      ProcessCurrentFile(CharMap, Bools, Stats, *i);
   } // End for (each file in FileList)

   BLAT("\nAt bottom of ProcessCurDirFunctor::operator(); about to return.\n")
   return;
} // end ns_SFN::ProcessCurDirFunctor::operator()


//////////////////////////////////////////////////////////////////////////////
//                                                                          //
//  ProcessCurrentFile()                                                    //
//                                                                          //
//  Processes current file.                                                 //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////

void
ns_SFN::
ProcessCurrentFile
   (
      char     const  *  CharMap,
      Bools_t  const  &  Bools,
      Stats_t         &  Stats,
      FR       const  &  FileRec
   )
{
   // ABSTRACT:
   // Changes unsafe characters to safe characters in name of current file.
   // Also enumerates name of current file if required because of existing files.
   //

   BLAT("\nJust entered ProcessCurrentFile().")
   BLAT("About to get old and simplified file names.\n")

   std::string OldName = FileRec.name;
   std::string SimName = SimplifyFileName(OldName, CharMap, Bools);
   std::string NewName = SimName;

   BLAT("\nIn ProcessCurrentFile(); finished getting old and simplified file names.")
   BLAT("Old name = " << OldName)
   BLAT("New name = " << NewName)
   BLAT("About to see if a file with old name actually does exist.\n")

   // If no file with name = OldName actually exists, this means that djgpp's
   // findfirst() and findnext() functions have "sanitized" a file with a name
   // which is similar (but not identical) to OldName, and which contains
   // characters which findfirst() and findnext() don't like.  If this happens,
   // warn the user:
   if (!__file_exists(OldName.c_str()))
   {
      BLAT("\nIn ProcessCurrentFile().  No file exists with old file name.")
      BLAT("Old name: " << OldName << "\n")
      ++Stats.BadCount;
      cerr
                                                                                         << endl
      << "WARNING: No file exists with this old file name:"                              << endl
      << OldName                                                                         << endl
      << "This is probably because djgpp's findfirst() or findnext() returned a version" << endl
      << "of the file name which differs from that which the OS is using.  It will do"   << endl
      << "this if a file name contains certain characters which djgpp can't read."       << endl
      << "Simplify File Names will skip this file and move on to next."                  << endl
                                                                                         << endl;
      BLAT("\nAbout to return from ProcessCurrentFile()\n")
      return;
   }

   BLAT("About to check to see if old and simplified names are the same.\n")

   // If SimName is the same as OldName, skip to next file:
   if (SimName == OldName)
   {
      BLAT("\nIn ProcessCurrentFile(); old and simplified file names are identical,")
      BLAT("so we're bypassing this file and moving on to the next.")
      BLAT("About to return from ProcessCurrentFile().\n")
      ++Stats.BypCount;
      return;
   }

   BLAT("\nIn ProcessCurrentFile(); old and simplified file names are different.\n")

   // If a file already exists with name NewName, try to find an unused enumerated
   // version of NewName:
   if (__file_exists(NewName.c_str()))
   {
      BLAT("\nIn ProcessCurrentFile().  A file with the simplified file name already exists.")
      BLAT("About to try to find an unused enumerated version of simplified file name.\n")
      for ( int i = 0 ; i < 25 && __file_exists(NewName.c_str()) ; ++i )
      {
         NewName = rhdir::Enumerate(SimName);
      }
      if (__file_exists(NewName.c_str()))
      {
         BLAT("\nIn ProcessCurrentFile().  Couldn't find unused name.")
         BLAT("Aborting rename of current file and moving on to next file.\n")
         ++Stats.EnuCount;
         cerr
            << "Error: unable to find non-existing enumerated name for file"      << endl
            << SimName                                                            << endl
            << "even after 25 tries.  Bypassing this file and moving on to next." << endl
                                                                                  << endl;
         BLAT("\nAbout to return from ProcessCurrentFile().\n")
         return; // Move on to next file.
      }
      else
      {
         BLAT("\nIn ProcessCurrentFile().  Found unused name.\n")
         cout
            << "Note: had to enumerate " << SimName << " to " << NewName << endl;
      }
   }

   // If we get to here, we're about to attempt to rename a file,
   // so increment the rename-attempt counter:
   ++Stats.AttCount;
   cout
      << "File rename attempt #" << Stats.AttCount << ":"  << endl
      << "Old file name = "      << OldName                << endl
      << "New file name = "      << NewName                << endl;

   BLAT("\nIn ProcessCurrentFile().  About to attempt the following file rename:")
   BLAT("Old name: " << OldName)
   BLAT("New name: " << NewName << "\n")

   bool Success = rhdir::RenameFile(OldName, NewName);
   if (Success)
   {
      BLAT("\nIn ProcessCurrentFile().  File rename succeeded.\n")
      ++Stats.SucCount;
      cout
         << "Succeeded!"  << endl
                          << endl;
   }
   else
   {
      BLAT("\nIn ProcessCurrentFile().  File rename failed.\n")
      ++Stats.FaiCount;
      cout
         << "Failed!"     << endl
                          << endl;
   }

   BLAT("\nAt bottom of ProcessCurrentFile(); about to return.\n")
   return;
} // end ns_SFN::ProcessCurrentFile()


/////////////////////////////////////////////////////////////////////////////////////////////////
//                                                                                             //
//  std::string ns_SFN::SimplifyFileName (std::string const & Name, char const * CharMap);     //
//                                                                                             //
//  This function converts non-printable, illegal, or troublesome characters                   //
//  in a file name into non-troublesome characters, so that the file name becomes              //
//  as unlikely as possible to cause problems, over a wide spectrum of platforms.              //
//  For a detailed description of what this function does, see help()  below.                  //
//                                                                                             //
/////////////////////////////////////////////////////////////////////////////////////////////////

std::string
ns_SFN::
SimplifyFileName
   (
      std::string  const  &  Name,
      char         const  *  CharMap,
      Bools_t      const  &  Bools
   )
{


   //---------------------------------------------------------------------------
   // Character conversion, phase 0 (prepare input copy, iterators, and indexes):

   // Grab a local copy of the input string:
   std::string NewName (Name);

   // Make an iterator and two indexes:
   std::string::iterator  Iter;
   std::string::size_type Index1;
   std::string::size_type Index2;

   // Make an integer "character value" variable i:
   int i = 0;


   //---------------------------------------------------------------------------
   // Character conversion, phase 1 (Hexidecimal Numbers):

   // If user requested %HH removal, convert "%HH" (where 'H' is any hexidecimal digit)
   // to the corresponding extended-ASCII character.  (Note this this character might
   // very well be illegal in file names!  We don't worry about that here, though,
   // because that will all be straightened out in phase 2.)
   if (Bools.bHex)
   {
      bool done = false;
      Index1 = 0;
      while (not done)
      {
         if (std::string::npos != (Index1 = NewName.find('%', Index1)))
         {
            if (Index1 >= NewName.length() - 2)
            {
               done = true;
               continue;
            }
            else if (!(isxdigit(NewName[Index1 + 1])&&isxdigit(NewName[Index1 + 2])))
            {
               done = false;
               ++Index1;
               continue;
            }
            else
            {
               int Char = GetCharFromHex(NewName.substr(Index1, 3));
               NewName.replace(Index1, 3, 1, Char);
               done = false;
               ++Index1;
               continue;
            }
         }
         else
         {
            done = true;
            continue;
         }

      } // end while (not done)

   } // end if (2&Code)


   //---------------------------------------------------------------------------
   // Character conversion, phase 2 (remapping insane to sane characters):

   // Iterate through characters of NewName, converting each character to it's
   // re-mapped version, using character map:
   for (Iter = NewName.begin(); Iter != NewName.end(); ++Iter)
   {
      // We can't use the raw numerical values of objects of type "char" because
      // they are in the -128 to +127 range, whereas we need values in the
      // 0 to 255 range.  So first explicitly cast the current character to type
      // unsigned char, then implicitly convert it to int (by assignment):
      i = static_cast<unsigned char>(*Iter); // implicit conversion to int

      // Print error message if renormalized value of current character is
      // outside of the 0 to 255 range:
      if (i < 0 || i > 255) std::cerr << "i = " << i << std::endl;

      // Also "assert" that the current character is in the 0 to 255 range:
      assert(i >=   0);
      assert(i <= 255);

      // If BLAT is enabled, and if the current character is extended-ASCII
      // (128 to 255), then print the value of the current character, and also
      // the corresponding re-mapped ASCII glyph:
      #ifdef BLAT_ENABLE
         if (i > 127)
         {
            BLAT("i = " << i)
            BLAT("CharMap[i] = " << CharMap[i])
         }
      #endif

      // Re-map the current character:
      (*Iter) = CharMap[i];

   }


   //---------------------------------------------------------------------------
   // Character conversion, phase 3 (commas, semicolons, carets, and ampersands):

   // If user requested comman/semicolon/caret removal, convert all ,;^& to '$':
   if (Bools.bCommas)
   {
      while (std::string::npos != (Index1 = NewName.find_first_of(",;^&")))
      {
         NewName[Index1] = '$';
      }
   }



   //---------------------------------------------------------------------------
   // Character conversion, phase 4 (Extra Dots):

   // If user requested extra-dot removal, convert all dots except last to '`':
   if (Bools.bDots)
   {
      if (std::string::npos != (Index1 = NewName.rfind('.')))
      {
         while
            (
               std::string::npos != (Index2 = NewName.find('.'))
               &&
               Index2 != Index1
            )
         {
            NewName[Index2]='`';
         }
      }
   }


   //---------------------------------------------------------------------------
   // Character conversion, phase 5 (spaces):

   // If user requested spaces->hyphens, convert all ' ' to '-':
   if (Bools.bHyphens)
   {
      while (std::string::npos != (Index1 = NewName.find(' ')))
      {
         NewName[Index1] = '-';
      }
   }
   // Else if user requested spaces->underscores, convert all ' ' to '_':
   else if (Bools.bSpaces)
   {
      while (std::string::npos != (Index1 = NewName.find(' ')))
      {
         NewName[Index1] = '_';
      }
   }
   // Else don't convert spaces to anything (leave them as-is).


   // We're finished, so return the new name:
   return NewName;
} // end SimplifyFileName()


//////////////////////////////////////////////////////////////////////////////
//                                                                          //
// GetCharFromHex()                                                         //
// Given a hexidecimal code, such as "%A5", or "%3b", return the ASCII      //
// (or extended-ASCII) character specified by that code.                    //
//                                                                          //
// Note:                                                                    //
// This function returns '\0' if Hex is not exactly 3 characters long,      //
// or if its first character is not '%'.                                    //
//                                                                          //
// Note:                                                                    //
// If Hex[1] or Hex[2] is not 0-9, a-f, or A-F, it will be counted as 0.    //
// Hence code "%QK" will return '\0', and "%4Z" will return '@' (0x40).     //
//                                                                          //
// Note:                                                                    //
// If the value of the code is > 127, it will be rolled-over to a negative  //
// number by the process of casting it to char.  If the value is outside    //
// the range of 0-255, it will be coerced to within that range before       //
// casting it to char.  The returned value will always be in the range of   //
// -128 to +127.                                                            //
//                                                                          //
// Note:                                                                    //
// Due to the way this function is implimented, usage of character codes    //
// other than ASCII or some form of extended ASCII may result in this       //
// function exhibiting bizarre, unexpected behaviour.  This is because it   //
// assumes that the character groups 0-9, a-f, A-F are contiguous and       //
// sequential.  If they aren't, all bets are off.                           //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////

char ns_SFN::GetCharFromHex (std::string Hex)
{
   if (  3  != Hex.size() ) {return (char)0;}
   if ( '%' != Hex[0]     ) {return (char)0;}

   int Value0 = 0;
   if (Hex[2] >= '0' && Hex[2] <= '9') {Value0 = (int)Hex[2] - (int)'0' +  0;}
   if (Hex[2] >= 'a' && Hex[2] <= 'f') {Value0 = (int)Hex[2] - (int)'a' + 10;}
   if (Hex[2] >= 'A' && Hex[2] <= 'F') {Value0 = (int)Hex[2] - (int)'A' + 10;}

   int Value1 = 0;
   if (Hex[1] >= '0' && Hex[1] <= '9') {Value1 = (int)Hex[1] - (int)'0' +  0;}
   if (Hex[1] >= 'a' && Hex[1] <= 'f') {Value1 = (int)Hex[1] - (int)'a' + 10;}
   if (Hex[1] >= 'A' && Hex[1] <= 'F') {Value1 = (int)Hex[1] - (int)'A' + 10;}

   int Value = 16 * Value1 + Value0;
   if (Value <   0) Value =   0;
   if (Value > 255) Value = 255;

   return (char)(Value); // (Values 128 to 255 will be cast to -128 to -1.)
}


//////////////////////////////////////////////////////////////////////////////
//                                                                          //
//  Help()                                                                  //
//                                                                          //
//  Prints help.                                                            //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////

void
ns_SFN::
Help
   (
      void
   )
{
   //  12345678901234567890123456789012345678901234567890123456789012345678901234567890
   cout
   << "Welcome to simplify-file-names, Robbie Hatley's file-name-simplifying utility."         << endl
   << "This version compiled at " << __TIME__ << " on " << __DATE__ << "."                     << endl
   << "This program converts any non-printable, illegal, or troublesome characters"            << endl
   << "in the names of the files in the current directory into safe characters,"               << endl
   << "so that the file names become as unlikely as possible to cause problems,"               << endl
   << "over a wide spectrum of platforms.  If the new name generated is the same as"           << endl
   << "the name of an existing file, this program will try to generate an enumerated"          << endl
   << "version of the name which is different from the name of any existing file."             << endl
   << "But if it fails 25 times in a row (VERY unlikely!), it will bypass the current"         << endl
   << "file and move on to the next file."                                                     << endl
                                                                                               << endl
   << "This program alters seven categories of troublesome characters:"                        << endl
   << " #  Category:                           Characters:     Action taken:"                  << endl
   << " 1. ASCII control characters            (0-32,127-159)  convert to '+'"                 << endl
   << " 2. Non-ASCII characters                (128-255)       convert to '!'"                 << endl
   << " 3. Illegal in Windows long file names  \"*/:<>?\\|       convert to '@'"               << endl
   << " 4. Interferes with DOS file names      ~               convert to '-'"                 << endl
   << "*5. Requires quoting in DOS             ,;^&            convert to '$'"                 << endl
   << "*6. Illegal in Unix file names          (space)         convert to '_'"                 << endl
   << "*7. Extra dots                          .               convert to '`'"                 << endl
   << "*8. \"%HH\" where 'H' is any hex digit    eg: %3a%B2      convert to chars"             << endl
                                                                                               << endl
   << "*Note that items 5, 6, 7, 8 are deactivated by default."                                << endl
   << "Use the switches below to activate these."                                              << endl
                                                                                               << endl
   << "Command-line syntax:"                                                                   << endl
   << "simplify-file-names [switches]"                                                         << endl
                                                                                               << endl
   << "Switch:                      Meaning:"                                                  << endl
   << "\"-h\" or \"--help\"             Print help and exit."                                  << endl
   << "\"-r\" or \"--recurse\"          Process all subdirectories."                           << endl
   << "\"-v\" or \"--verbose\"          Be verbose."                                           << endl
   << "\"-c\" or \"--commas\"           Convert ,;^& to '$'."                                  << endl
   << "\"-s\" or \"--spaces\"           Convert spaces to '_'."                                << endl
   << "\"-p\" or \"--hyphens\"          Convert spaces to '-'."                                << endl
   << "\"-d\" or \"--dots\"             Convert extra dots to '`'."                            << endl
   << "\"-H\" or \"--hex\"              Convert \"%5A\" etc to characters."                    << endl
   << "\"-a\" or \"--all\"              same as all of -c -s -d -H"                            << endl
   << "(Note: \"-p\" or \"--hyphens\" overrides \"-s\" or \"--spaces)\"."                      << endl
                                                                                               << endl;
   return;
} // end ns_SFN::Help()

