# Graphics Directory Make File
# Written 2003-04-27 by Robbie Hatley.
# Edited:
#    2004-09-22
#    Tue Jun 07, 2005 - Updated directories; added congraph.cpp.
#    Thu Mar 19, 2009 - Dramatically simplified; all of the actual
#                       compilation is now via pattern rules.
#    Sun Feb 21, 2016 - Removed makehead and make-all-list (both now subsumed into maketail).
#    Mon Feb 05, 2018 - Edited for new Ketch file-system configuration (rhe is now on drive D).
#    Sat Jan 08, 2022: Updated for Linux.

# Set collection name:
COLLECTION := Graphics

# Set the exe directory suffix:
EXSUFF := graphics

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

