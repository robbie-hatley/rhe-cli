# Math Directory Make File
# Written by Robbie Hatley on 2004-06-11.
# Edit history:
#    2004-07-12
#    2004-10-23
#    2005-08-20 Updated directories.
#    2009-03-15 Dramatically simplified.
#    2015-04-07 Edited.
#    2016-02-14 Edited.
#    2016-02-21 Removed makehead and make-all-list (both now subsumed into maketail).
#    2017-10-15 Changed paths because rhe is now /rhe and ~ .
#    Sat Jan 08, 2022: Updated for Linux.

# Set collection name:
COLLECTION := Math

# Set the exe directory so that gcc & g++ know where to write to:
EXSUFF := math

# Set source vpath directories so that make can find the c and cpp files for this collection:
vpath %.c   /d/rhe-cli/src/math
vpath %.cpp /d/rhe-cli/src/math

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
