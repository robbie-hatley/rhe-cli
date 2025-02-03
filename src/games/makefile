# Games Directory Make File
# Written by:   Robbie Hatley
# Edit history:
#    ??? Jul 18, 2004 - Wrote it.
#    ??? Jul 19, 2004 - Edited.
#    Sun Feb 21, 2016 - Removed makehead and make-all-list (both now subsumed into maketail).
#    Thu Feb 15, 2018 - Corrected paths because rhe is now directly in / .
#    Sat Jan 08, 2022: Updated for Linux.

# Set collection name:
COLLECTION := Games

# Set the exe directory suffix:
EXSUFF := games

# Set source vpath directories so that make can find the c and cpp files for this collection:
vpath %.c   /d/rhe-cli/src/games
vpath %.cpp /d/rhe-cli/src/games

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













