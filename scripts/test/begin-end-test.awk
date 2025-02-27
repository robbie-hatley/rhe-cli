#!/bin/awk -f
BEGIN {print("AAARRRFFF!!!!!!!")}
{print("arf arf")}
END {print("Arf arf arf arf arf arf arf!!!")}
# Note: It works, though you need to input something on
# STDIN to get the {print("arf arf")} to actually execute.
# It will execute once for each line of STDIN, then stop
# executing at EOF (Ctrl-D); then END executes.
