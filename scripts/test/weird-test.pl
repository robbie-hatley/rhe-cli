#!/usr/bin/perl

use v5.32;
use strict;
use warnings;
no strict "refs";

*{'@$%^&*<'} = \3.1459;
print ${ pack 'H14','4024255e262a3c' }
