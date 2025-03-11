#!/usr/bin/perl
my $dog = 'Spot';
BEGIN     {print("In BEGIN,     \$dog is ", defined($dog)?"defined":"undefined", " and phase is ${^GLOBAL_PHASE}\n");}
UNITCHECK {print("In UNITCHECK, \$dog is ", defined($dog)?"defined":"undefined", " and phase is ${^GLOBAL_PHASE}\n");}
CHECK     {print("In CHECK,     \$dog is ", defined($dog)?"defined":"undefined", " and phase is ${^GLOBAL_PHASE}\n");}
INIT      {print("In INIT,      \$dog is ", defined($dog)?"defined":"undefined", " and phase is ${^GLOBAL_PHASE}\n");}
           print("In script,    \$dog is ", defined($dog)?"defined":"undefined", " and phase is ${^GLOBAL_PHASE}\n");
END       {print("in END,       \$dog is ", defined($dog)?"defined":"undefined", " and phase is ${^GLOBAL_PHASE}\n");}
