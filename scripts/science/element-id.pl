#!/usr/bin/env perl
# element-id.pl
# Gives information on chemical elements.
# Searches multiple inputs by symbol, name, or atomic number.
# Written on Tue Aug 18 2026 by Robbie Hatley.
use v5.16;     # To get feature "say".
use utf8::all; # To use UTF-8 for everything.

# Page-global lexical variables:
my $help = 0;
my @args;

# Subroutine predeclarations:
sub help;

# If user wants help, just give help and exit:
foreach my $arg (@ARGV) {
   if ($arg =~ m/^-/) {
      if ( '-h' eq $arg || '--help' eq $arg ) {
         $help = 1;
      }
   }
   else {
      push @args, $arg;
   }
}

$help and help and exit;

my @data =
(
   'Ac,Actinium,89',
   'Ag,Silver,47',
   'Al,Aluminum,13',
   'Am,Americium,95',
   'Ar,Argon,18',
   'As,Arsenic,33',
   'At,Astatine,85',
   'Au,Gold,79',
   'B,Boron,5',
   'Ba,Barium,56',
   'Be,Beryllium,4',
   'Bh,Bohrium,107',
   'Bi,Bismuth,83',
   'Bk,Berkelium,97',
   'Br,Bromine,35',
   'C,Carbon,6',
   'Ca,Calcium,20',
   'Cd,Cadmium,48',
   'Ce,Cerium,58',
   'Cf,Californium,98',
   'Cl,Chlorine,17',
   'Cm,Curium,96',
   'Cn,Copernicium,112',
   'Co,Cobalt,27',
   'Cr,Chromium,24',
   'Cs,Cesium,55',
   'Cu,Copper,29',
   'Db,Dubnium,105',
   'Ds,Darmstadtium,110',
   'Dy,Dysprosium,66',
   'Er,Erbium,68',
   'Es,Einsteinium,99',
   'Eu,Europium,63',
   'F,Fluorine,9',
   'Fe,Iron,26',
   'Fl,Flerovium,114',
   'Fm,Fermium,100',
   'Fr,Francium,87',
   'Ga,Gallium,31',
   'Gd,Gadolinium,64',
   'Ge,Germanium,32',
   'H,Hydrogen,1',
   'He,Helium,2',
   'Hf,Hafnium,72',
   'Hg,Mercury,80',
   'Ho,Holmium,67',
   'Hs,Hassium,108',
   'I,Iodine,53',
   'In,Indium,49',
   'Ir,Iridium,77',
   'K,Potassium,19',
   'Kr,Krypton,36',
   'La,Lanthanum,57',
   'Li,Lithium,3',
   'Lr,Lawrencium,103',
   'Lu,Lutetium,71',
   'Lv,Livermorium,116',
   'Mc,Moscovium,115',
   'Md,Mendelevium,101',
   'Mg,Magnesium,12',
   'Mn,Manganese,25',
   'Mo,Molybdenum,42',
   'Mt,Meitnerium,109',
   'N,Nitrogen,7',
   'Na,Sodium,11',
   'Nb,Niobium,41',
   'Nd,Neodymium,60',
   'Ne,Neon,10',
   'Nh,Nihonium,113',
   'Ni,Nickel,28',
   'No,Nobelium,102',
   'Np,Neptunium,93',
   'O,Oxygen,8',
   'Og,Oganesson,118',
   'Os,Osmium,76',
   'P,Phosphorus,15',
   'Pa,Protactinium,91',
   'Pb,Lead,82',
   'Pd,Palladium,46',
   'Pm,Promethium,61',
   'Po,Polonium,84',
   'Pr,Praseodymium,59',
   'Pt,Platinum,78',
   'Pu,Plutonium,94',
   'Ra,Radium,88',
   'Rb,Rubidium,37',
   'Re,Rhenium,75',
   'Rf,Rutherfordium,104',
   'Rg,Roentgenium,111',
   'Rh,Rhodium,45',
   'Rn,Radon,86',
   'Ru,Ruthenium,44',
   'S,Sulfur,16',
   'Sb,Antimony,51',
   'Sc,Scandium,21',
   'Se,Selenium,34',
   'Sg,Seaborgium,106',
   'Si,Silicon,14',
   'Sm,Samarium,62',
   'Sn,Tin,50',
   'Sr,Strontium,38',
   'Ta,Tantalum,73',
   'Tb,Terbium,65',
   'Tc,Technetium,43',
   'Te,Tellurium,52',
   'Th,Thorium,90',
   'Ti,Titanium,22',
   'Tl,Thallium,81',
   'Tm,Thulium,69',
   'Ts,Tennessine,117',
   'U,Uranium,92',
   'V,Vanadium,23',
   'W,Tungsten,74',
   'Xe,Xenon,54',
   'Y,Yttrium,39',
   'Yb,Ytterbium,70',
   'Zn,Zinc,30',
   'Zr,Zirconium,40',
);

my (%by_sym, %by_nam, %by_num);
foreach my $line (@data) {
   my ($sym, $nam, $num) = split ',', $line;
   my $e = {
      sym => $sym,
      nam => $nam,
      num => $num,
   };
   $by_sym{$sym} = $e;
   $by_nam{$nam} = $e;
   $by_num{$num} = $e;
}

my %suggestions = (
   'Aluminium'       => 'Aluminum',
   'Antinomy'        => 'Antimony',
   'Stibium'         => 'Antimony',
   'Argentum'        => 'Silver',
   'Aurum'           => 'Gold',
   'Berillium'       => 'Beryllium',
   'Glucinum'        => 'Beryllium',
   'Ns'              => 'Bohrium',
   'Neilsborium'     => 'Bohrium',
   'Neilsbohrium'    => 'Bohrium',
   'Nielsborium'     => 'Bohrium',
   'Nielsbohrium'    => 'Bohrium',
   'Caesium'         => 'Cesium',
   'Cromium'         => 'Chromium',
   'Chrome'          => 'Chromium',
   'Crome'           => 'Chromium',
   'Cuprum'          => 'Copper',
   'Ferrum'          => 'Iron',
   'Plumbum'         => 'Lead',
   'Lutecium'        => 'Lutetium',
   'Hydrargyrum'     => 'Mercury',
   'Nickle'          => 'Nickel',
   'Columbium'       => 'Niobium',
   'Kalium'          => 'Potassium',
   'Natrium'         => 'Sodium',
   'Sulphur'         => 'Sulfur',
   'Stannum'         => 'Tin',
   'Technecium'      => 'Technetium',
   'Technicium'      => 'Technetium',
   'Wolfram'         => 'Tungsten',
);

foreach my $arg (@args) {
   $arg = ucfirst lc $arg;
   if ($by_sym{$arg}) {
      say '';
      say 'Element symbol: ', $by_sym{$arg}->{sym};
      say 'Element name  : ', $by_sym{$arg}->{nam};
      say 'Atomic number : ', $by_sym{$arg}->{num};
   }
   elsif ($by_nam{$arg}) {
      say '';
      say 'Element symbol: ', $by_nam{$arg}->{sym};
      say 'Element name  : ', $by_nam{$arg}->{nam};
      say 'Atomic number : ', $by_nam{$arg}->{num};
   }
   elsif ($by_num{$arg}) {
      say '';
      say 'Element symbol: ', $by_num{$arg}->{sym};
      say 'Element name  : ', $by_num{$arg}->{nam};
      say 'Atomic number : ', $by_num{$arg}->{num};
   }
   elsif ($suggestions{$arg}) {
      say '';
      say 'Element symbol: ', $by_nam{$suggestions{$arg}}->{sym};
      say 'Element name  : ', $by_nam{$suggestions{$arg}}->{nam};
      say 'Atomic number : ', $by_nam{$suggestions{$arg}}->{num};
   }
   else {
      say '';
      say "No information found for \"$arg\".";
   }
}

exit;

# Subroutine definitions:

# Print help:
sub help {
   print STDERR ((<<"   END_OF_HELP") =~ s/^   //gmr);

   -------------------------------------------------------------------------------
   Introduction:

   Welcome to "element-id.pl", Robbie Hatley's nifty chemical element lookup
   program. This program can be used in three ways:
   1. Search by element symbol
   2. Search by element name
   3. Search by atomic number
   In all three cases, if a match is found, the relevant info will be printed.
   If multiple arguments are given, info will be printed for each argument.

   -------------------------------------------------------------------------------
   Command lines:

   element-id.pl -h | --help   (to print this help and exit)
   element-id.pl argument(s)   (to print info on element(s))

   -------------------------------------------------------------------------------
   Description of Options:

   Option:            Meaning:
   -h or --help       Print this help and exit.

   All options not listed above are ignored.

   -------------------------------------------------------------------------------
   Description of Arguments:

   This program accepts multiple arguments. For each argument, if it's a valid
   element symbol, element name, or atomic number, all relevant information will
   be printed. If no arguments are given, no information will be given. For each
   unrecognized argument, "No information found" will be printed.

   Happy chemical element info finding!

   Cheers,
   Robbie Hatley,
   programmer.
   END_OF_HELP
   return 1;
} # end sub help
