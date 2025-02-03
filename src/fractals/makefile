# Fractals Directory Make File
# Written by Robbie Hatley on Sun. Apr. 27, 2003.
# Edited:
#    Wed Sep 22, 2004
#    Sun Oct 24, 2004
#    Wed Mar 02, 2005
#    Sat May 28, 2005 - Changed directories due to restructuring of programming workspace.
#    Sun Feb 21, 2016 - Removed makehead and make-all-list (both now subsumed into maketail).
#    Thu Jan 11, 2018 - Corrected paths because rhe is now in /cygwin/d/ .
#    Sat Jan 08, 2022: Updated for Linux.

# Set collection name:
COLLECTION := Fractals

# Set the exe directory suffix:
EXSUFF := fractals

# Set source vpath directories so that make can find the c and cpp files for this collection:
vpath %.c   /d/rhe-cli/src/fractals
vpath %.cpp /d/rhe-cli/src/fractals

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












