# Jive Makefile
# Written by Robbie Hatley.
# Edit history:
#    Mon Aug 25, 1997: Written (by original author of Jive collection).
#    Sun Feb 21, 2016: Removed makehead and make-all-list (both now subsumed into maketail).
#    Sun Jan 07, 2018: Changed paths for new location of rhe at "D:\rhe".
#    Tue Jan 23, 2018: Added   ".INTERMEDIATE:" line for the 3 c files compile by flex from lex files.
#    Sat Jan 08, 2022: Updated for Linux. This directory is tricky. I can't use maketail because under
#                      Linux, I can't include -lfl without causing errors in programs that DON'T use
#                      Flex, and I can't NOT include it on programs that DO use Flex. So I'm importing
#                      a lot of stuff from maketail into this file instead.
#    Sat Aug 06, 2022: I changed EXEDIR to point to the currently-correct locations.

# Set source vpath directories so that make can find the c and cpp files for this collection:
vpath %.c   /d/rhe-cli/src/jive
vpath %.cpp /d/rhe-cli/src/jive

# Set PLATFORM, EXEDIR, MACROS, and ALL:
ifeq ($(PLATFORM),Win64)
   EXEDIR   := /d/rhe2/bin_cyg/jive
   MACROS   := -DPLATFORM_IS_WIN64 -D_GNU_SOURCE
   ALL      := piglatin.exe chef.exe jive.exe valspeak.exe
   EXEPATHS := $(EXEDIR)/piglatin.exe $(EXEDIR)/chef.exe $(EXEDIR)/jive.exe $(EXEDIR)/valspeak.exe
else ifeq ($(PLATFORM),Linux)
   EXEDIR   := /d/rhe2/bin_lin/jive
   MACROS   := -DPLATFORM_IS_LINUX -D_GNU_SOURCE
   ALL      := piglatin chef jive valspeak
   EXEPATHS := $(EXEDIR)/piglatin $(EXEDIR)/chef $(EXEDIR)/jive $(EXEDIR)/valspeak
else
   $(error Error: Unknown PLATFORM)
endif

$(info $$PLATFORM is ${PLATFORM})
$(info $$EXEDIR   is ${EXEDIR})

# ============================================================================================================
# Set vpaths to tell GNU Make where to look for headers, objects, libraries, and executables:
vpath %.exe $(EXEDIR)
vpath %     $(EXEDIR)
# Note: these are separate from variables which tell gcc & g++ where to find files;
# vpaths tell Make ITSELF where to find files. This helps it navigate dependencies.

# ============================================================================================================
# SET VARIABLES:

# C warning flags:
WC := -Wall -Wfloat-equal -Wshadow -Wcast-qual \
-Wcast-align -Wconversion -Wcomments -Wundef -Wnested-externs

# Compilation Command string for C files which WERE    made from Flex:
COMPILE_FLEX_YES = gcc $(MACROS) $(WC) -s -O2 -std=gnu17 $< -L/usr/lib -lfl -o $(EXEDIR)/$@

# Compilation Command string for C files which WEREN'T made from Flex:
COMPILE_FLEX_NO  = gcc $(MACROS) $(WC) -s -O2 -std=gnu17 $< -L/usr/lib      -o $(EXEDIR)/$@

# ============================================================================================================
# DECLARE PHONY TARGETS:

.PHONY: all clean clobber

# ============================================================================================================
# MAKE ALL (SINCE THIS IS THE FIRST ACTUAL RULE, THIS IS THE DEFAULT RULE):

# Make dummy target "all" dependent on $(ALL):
all: $(ALL)
	@echo Jive Program Collection is up to date.

# ============================================================================================================
# BUILD RULES C -> EXE :

piglatin: piglatin.c
	-$(COMPILE_FLEX_NO)

piglatin.exe: piglatin.c
	-$(COMPILE_FLEX_NO)

chef: chef.c
	-$(COMPILE_FLEX_YES)

chef.exe: chef.c
	-$(COMPILE_FLEX_YES)

jive: jive.c
	-$(COMPILE_FLEX_YES)

jive.exe: jive.c
	-$(COMPILE_FLEX_YES)

valspeak: valspeak.c
	-$(COMPILE_FLEX_YES)

valspeak.exe: valspeak.c
	-$(COMPILE_FLEX_YES)


# ============================================================================================================
# BUILD RULES L -> C :

chef.c:     chef.l
jive.c:     jive.l
valspeak.c: valspeak.l

%.c: %.l
	flex $*.l
	mv lex.yy.c $*.c

# ============================================================================================================
# CLEANUP RULES:

clean:
	rm -f $(EXEPATHS)

clobber:
	rm -f chef.c jive.c valspeak.c

