#!/bin/bash
if
   test $1 -lt 17
then
   echo 'under 17'
elif
   test $1 -gt 54
then
   echo 'over 54'
else
   echo 'just right'
fi
