# Humor Directory Make File
# Written by Robbie Hatley on Monday November 6, 2017.
# Edited:
#    Mon Nov 06, 2017 - Wrote it.
#    Sat Jan 08, 2022: Updated for Linux.

# Set collection name:
COLLECTION := Humor

# Set the exe directory suffix:
EXSUFF := humor

# Set source vpath directories so that make can find the c and cpp files for this collection:
vpath %.c   /d/rhe-cli/src/humor
vpath %.cpp /d/rhe-cli/src/humor

# ALL        = list of all *.exe files corresponding to the *.c and *.cpp files in current directory.
# C_PROGRAMS = list of all *.exe files corresponding to the *.c           files in current directory.
# X_PROGRAMS = list of all *.exe files corresponding to the         *.cpp files in current directory.
ALL        = $(shell make-all-list.pl)
C_PROGRAMS = $(shell make-c-list.pl)
X_PROGRAMS = $(shell make-x-list.pl)

#  ****************************************************************************
#  *                                                                          *
#  *  (All the actual compilation is done via the pattern rules in maketail.) *
#  *                                                                          *
#  ****************************************************************************

# Include maketail:
include /d/rhe-cli/src/maketail













