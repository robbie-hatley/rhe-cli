#!/bin/bash
# eval-test.sh
code='say "Hello, World!";'
echo $code | perl -E 'eval <>;'
