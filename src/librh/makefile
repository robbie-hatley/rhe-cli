# Library Make File
# Written Sat. Apr. 26, 2003 by Robbie Hatley.
# Edited:
#    Sun Apr 27, 2003
#    Wed Mar 02, 2005
#    Sat May 28, 2005 - Changed directories due to restructuring of programming workspace.
#    Sun May 29, 2005 - Included maketail at the bottom (contains some material previously in makehead).
#    Tue Jun 07, 2005 - Added rhncgraphics.
#    Thu Apr 02, 2015 - Drastically streamlined.
#    Sun Feb 21, 2016 - Removed makehead and make-all-list (both now subsumed into maketail).
#    Mon Oct 16, 2017 - Updated for Ketch's new location for rhe at "D:\rhe", which is also ~ in Cygwin.

# Set collection name:
COLLECTION := Robbie Hatley\'s Library

# Set the exe directory suffix (dummy; not actually used because we're not making executables):
EXSUFF := librh

# Set source vpath directories so that make can find the c and cpp files for this collection:
vpath %.c   /d/rhe-cli/src-cli/librh
vpath %.cpp /d/rhe-cli/src-cli/librh

# Since we're compiling and archiving object modules, NOT exe files,
# set variable ALL to a list of all library objects,
# NOT to a list of exe files:
ALL = $(LIBRARY_OBJECTS_C) $(LIBRARY_OBJECTS_X)

# And since no programs are being made from the cpp files in this directory,
# do NOT set variable LIBRARY_DEPENDANT_PROGRAMS here.

#  ****************************************************************************
#  *                                                                          *
#  *  (All the actual compilation is done via the pattern rules in maketail.) *
#  *                                                                          *
#  ****************************************************************************

# Include maketail:
include /d/rhe-cli/src/maketail

















