# Utilities Directory Make File
# Written by Robbie Hatley on Sun. Dec. 01, 2002.
# Edited:
#    Mon Jul 19, 2004
#    Sat Jan 08, 2005
#    Wed Mar 02, 2005
#    Thu Jun 02, 2005
#    Thu Jun 09, 2005 - changed "filename-pattern-replace" to "file-name-pattern-replace".
#    Sat Aug 20, 2005 - Dramatically simplified.  Erased CURDIR def.  (CURDIR is an automatic variable.)
#                       Changed all program names to *.exe .  Removed compilation commands (now using
#                       pattern rules instead).  Removed multilevel scheme.  Removed echos.
#    Wed Nov 24, 2010 - Changed working drive for all my programming on sloop from E: (which doesn't
#                       exist, anyway) to C:.  Also, changed bin and script folders to nested format;
#                       eg, "bin/util" instead of "bin-util".
#    Mon Nov 29, 2010 - Moved all programming stuff back to /cygdrive/c/E/ . (Using "subst" to set
#                       "/cygdrive/c/E/" to "T:\E:\".)
#    Sun Dec 19, 2010 - Added "find-spacey-file-names.exe".
#    Sun Oct 15, 2017 - Changed paths because rhe is now /rhe and ~ .
#    Sat Jan 08, 2022: Updated for Linux.

# Set collection name:
COLLECTION := Utility

# Set the exe directory so that gcc & g++ know where to write to:
EXSUFF := util

# Set vpath directories so that make can find the files it needs:
vpath %.c      .
vpath %.cism   .
vpath %.cpp    .
vpath %.cppism .
vpath %.h      ../../include /usr/include
vpath %.hpp    ../../include /usr/include

# ALL        = list of all *.exe files corresponding to the *.c and *.cpp files in current directory.
# C_PROGRAMS = list of all *.exe files corresponding to the *.c           files in current directory.
# X_PROGRAMS = list of all *.exe files corresponding to the         *.cpp files in current directory.
ALL        = $(shell make-all-list.pl)
C_PROGRAMS = $(shell make-c-list.pl)
X_PROGRAMS = $(shell make-x-list.pl)

#  ******************************************************************************
#  *                                                                            *
#  *  All of the actual compilation is done via the pattern rules in maketail:  *
#  *                                                                            *
#  ******************************************************************************

# Include maketail:
include ../maketail

