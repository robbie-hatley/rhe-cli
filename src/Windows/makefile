# Windows-Utility Collection Make File
# Written by Robbie Hatley on Sun. Dec. 01, 2002.
# Edit history:
# Sun Jan 16, 2022: Wrote it.

# Set collection name:
COLLECTION := Windows

# Set the exe directory so that gcc & g++ know where to write to:
EXSUFF := /Windows

# Set source vpath directories so that make can find the c and cpp files for this collection:
vpath %.c   /rhe-cli/src/Windows
vpath %.cpp /rhe-cli/src/Windows

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
