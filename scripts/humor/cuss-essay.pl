#!/usr/bin/perl -CSDA

# This is a 110-character-wide Unicode UTF-8 Perl-source-code text file with hard Unix line breaks ("\x0A").
# ¡Hablo Español! Говорю Русский. Björt skjöldur. ॐ नमो भगवते वासुदेवाय.    看的星星，知道你是爱。 麦藁雪、富士川町、山梨県。
# =======|=========|=========|=========|=========|=========|=========|=========|=========|=========|=========|

##############################################################################################################
# "cuss-essay.pl"
# Written by Robbie Hatley at 5:55PM on Wed Sep 2 2026, based on "essay.pl".
# Edit history:
# Wed Sep 02, 2026: Wrote it.
##############################################################################################################

use v5.36;
use strict;
use warnings;
use utf8;

use Time::HiRes 'time';

# ======= VARIABLES: =========================================================================================

# System Variables:
$" = ', ' ; # Quoted-array element separator = ", ".

# Global Variables:
our    $pname;                                 # Declare program name.
BEGIN {$pname = substr $0, 1 + rindex $0, '/'} # Set     program name.
our    $cmpl_beg;                              # Declare compilation begin time.
BEGIN {$cmpl_beg = time}                       # Set     compilation begin time.
our    $cmpl_end;                              # Declare compilation end   time.
INIT  {$cmpl_end = time}                       # Set     compilation end   time.

# Local variables:

# Settings:     Default:      Meaning of setting:       Range:    Meaning of default:
my @Opts      = ()        ; # options                   array     Options.
my @Args      = ()        ; # arguments                 array     Arguments.
my $Debug     =  0        ; # Debug?                    bool      Don't debug.
my $Help      =  0        ; # Just print help and exit? bool      Don't print-help-and-exit.
my $Verbose   =  0        ; # Be verbose?               bool      Shhhh!! Be quiet!!
my $Rows      =  5        ; # Number of paragraphs.     int       Print 5 paragraphs.
my $Cols      = 50        ; # Words per paragraph.      int       Use 50 words per paragraph.

# ======= SUBROUTINE PRE-DECLARATIONS: =======================================================================

sub argv    ; # Process @ARGV.
sub essay   ; # Print random words.
sub error   ; # Handle errors.
sub help    ; # Print help and exit.

# ======= MAIN BODY OF PROGRAM: ==============================================================================

{ # begin main
   # Start execution timer:
   my $t0 = time;

   # Process @ARGV and set settings:
   argv;

   # Print program entry message if being terse or verbose:
   if ( 1 == $Verbose || 2 == $Verbose ) {
      say STDERR "Now entering program \"$pname\" at timestamp $t0.";
      say STDERR '';
   }

   # Also print compilation time if being verbose:
   if ( 2 == $Verbose ) {
      printf(STDERR "Compilation time was %.3fms\n",1000*($cmpl_end-$cmpl_beg));
      say STDERR '';
   }

   # Print the values of all variables if debugging:
   if ( 1 == $Debug ) {
      say STDERR "PName     = $pname";
      say STDERR "cmpl_bed  = $cmpl_beg";
      say STDERR "cmpl_end  = $cmpl_end";
      say STDERR "Options   = (@Opts)";
      say STDERR "Arguments = (@Args)";
      say STDERR "Debug     = $Debug";
      say STDERR "Help      = $Help";
      say STDERR "Verbose   = $Verbose";
      say STDERR "Rows      = $Rows";
      say STDERR "Cols      = $Cols";
      say STDERR '';
   }

   # Print essay, unless user requested help, in which case just print help:
   $Help and help or essay;

   # Stop execution timer:
   my $t1 = time;

   # Print exit message if being terse or verbose:
   if ( 1 == $Verbose || 2 == $Verbose ) {
      my $te = $t1 - $t0; my $ms = 1000 * $te;
      say    STDERR '';
      say    STDERR "Now exiting program \"$pname\" at timestamp $t1.";
      printf STDERR "Execution time was %.3fms.", $ms;
   }

   # Exit program, returning success code "0" to caller:
   exit 0;
} # end main

# ======= SUBROUTINE DEFINITIONS: ============================================================================

# Process @ARGV :
sub argv {
   # Get options and arguments:
   my $end = 0;              # end-of-options flag
   my $s = '[a-zA-Z0-9]';    # single-hyphen allowable chars (English letters, numbers)
   my $d = '[a-zA-Z0-9=.-]'; # double-hyphen allowable chars (English letters, numbers, equal, dot, hyphen)
   for ( @ARGV ) {           # For each element of @ARGV,
      /^--$/ && !$end        # "--" = end-of-options marker = construe all further CL items as arguments,
      and $end = 1           # so if we see that, then set the "end-of-options" flag
      and push @Opts, $_     # and push the "--" to @Opts
      and next;              # and skip to next element of @ARGV.
      !$end                  # If we haven't yet reached end-of-options,
      && ( /^-(?!-)$s+$/     # and if we get a valid short option
      ||  /^--(?!-)$d+$/ )   # or a valid long option,
      and push @Opts, $_     # then push item to @Opts
      or  push @Args, $_;    # else push item to @Args.
   }

   # Process options:
   for ( @Opts ) {
      /^-$s*h/ || /^--help$/    and $Help    =  1  ;
      /^-$s*e/ || /^--debug$/   and $Debug   =  1  ;
      /^-$s*q/ || /^--quiet$/   and $Verbose =  0  ; # Default.
      /^-$s*t/ || /^--terse$/   and $Verbose =  1  ;
      /^-$s*v/ || /^--verbose$/ and $Verbose =  2  ;
   }

   # Get number of arguments:
   my $NA = scalar(@Args);

   # If user typed more than 2 arguments, and we're not debugging, print error and help messages and exit:
   if ( $NA > 2                  # If number of arguments > 2
        && !$Debug && !$Help ) { # and we're not debugging and not getting help,
      error($NA);                # print error message,
      help;                      # and print help message,
      exit 666;                  # and exit, returning The Number Of The Beast.
   }

   # First argument, if present, is number of paragraphs:
   if ( $NA > 0 ) {              # If number of arguments > 0,
      $Rows = $Args[0];          # set $Rows to $Args[0].
   }

   # Second argument, if present, is words per paragraph:
   if ( $NA > 1 ) {              # If number of arguments >= 2,
      $Cols = $Args[1];          # set $Cols to $Args[1].
   }

   # Return success code 1 to caller:
   return 1;
} # end sub argv

# Print essay:
sub essay {
   my $fh;
   my @words;
   for my $word (<DATA>) {
      $word =~ s/\s+$//;
      push @words, $word;
   }
   my $n = scalar(@words);
   for my $row (0..$Rows-1)
   {
      if (0 != $row) {print "\n";}
      for my $col (0..$Cols-1)
      {
         my $word = $words[int rand $n];
         if (0 == $col%20) {$word =~ s/^(\pL)/\u$1/;}
         if (0 != $col) {print " ";}
         print "$word";
         if    (19 == $col%20 && $col > 0 && $col < $Cols-4) {print ".";}
         elsif ( 9 == $col%10 && $col > 0 && $col < $Cols-4) {print ";";}
         elsif ( 4 == $col% 5 && $col > 0 && $col < $Cols-4) {print ",";}
      }
      print ".\n";
   }
   return 1;
}

# Handle errors:
sub error ($NA) {
   print ((<<"   END_OF_ERROR") =~ s/^   //gmr);

   Error: you typed $NA arguments, but this program takes at most
   2 arguments (number of paragraphs, and words-per-paragraph).
   Help follows.
   END_OF_ERROR
   return 1;
} # end sub error

# Print help:
sub help {
   print ((<<'   END_OF_HELP') =~ s/^   //gmr);

   -------------------------------------------------------------------------------
   Introduction:

   Welcome to "essay.pl", Robbie Hatley's nifty random-essay generator. This
   program outputs random words, in the form of sentences and paragraphs, but
   without meaning. By default it prints 5 paragraphs of 50 words each, but these
   numbers can be changed by using "number of paragraphs" as first argument and
   "words-per-paragraph" as second argument.

   -------------------------------------------------------------------------------
   Command lines:

   program-name.pl -h | --help              (to print this help and exit)
   program-name.pl [options] [Arg1] [Arg2]  (to print random words)

   -------------------------------------------------------------------------------
   Description of Options:

   Option:            Meaning:
   -h or --help       Print help and exit.
   -e or --debug      Print diagnostics.
   -q or --quiet      Be quiet.                         (DEFAULT)
   -t or --terse      Be terse.
   -v or --verbose    Be verbose.
         --           End of options (all further CL items are arguments).

   Multiple single-letter options may be piled-up after a single hyphen. For
   example, use -hev to print extended entry and exit messages, help messages,
   and diagnostic info.

   All options not listed above are ignored.

   -------------------------------------------------------------------------------
   Description of Arguments:

   In addition to options, this program can take 1 or 2 optional arguments.

   Arg1 (OPTIONAL), if present, must be an integer specifying number of paragraphs
   to print. This defaults to 5.

   Arg2 (OPTIONAL), if present, must be an integer specifying words-per-paragraph.
   This defaults to 50.

   Arguments and options may be freely mixed, but the arguments must appear in
   the order Arg1, Arg2 (number-of-paragraphs, then words-per-paragraph); if you
   get them backwards, they won't do what you want.

   A number of arguments greater than 2 will cause this program to print an error
   message and abort.

   Happy random essay printing!

   Cheers,
   Robbie Hatley,
   programmer.
   END_OF_HELP
   return 1;
} # end sub help

__DATA__
abbo
abo
abortion
abuse
addict
addicts
adult
africa
african
alla
allah
alligatorbait
amateur
american
anal
analannie
analsex
angie
angry
anus
arab
arabs
areola
argie
aroused
arse
arsehole
asian
ass
assassin
assassinate
assassination
assault
assbagger
assblaster
assclown
asscowboy
asses
assfuck
assfucker
asshat
asshole
assholes
asshore
assjockey
asskiss
asskisser
assklown
asslick
asslicker
asslover
assman
assmonkey
assmunch
assmuncher
asspacker
asspirate
asspuppies
assranger
asswhore
asswipe
athletesfoot
attack
australian
babe
babies
backdoor
backdoorman
backseat
badfuck
balllicker
balls
ballsack
banging
baptist
barelylegal
barf
barface
barfface
bast
bastard
bazongas
bazooms
beaner
beast
beastality
beastial
beastiality
beat-off
beatoff
beatyourmeat
beaver
bestial
bestiality
bi
bi-sexual
biatch
bible
bicurious
bigass
bigbastard
bigbutt
bigger
bisexual
bitch
bitcher
bitches
bitchez
bitchin
bitching
bitchslap
bitchy
biteme
black
blackman
blackout
blacks
blind
blow
blowjob
boang
bogan
bohunk
bollick
bollock
bomb
bombers
bombing
bombs
bomd
bondage
boner
bong
boob
boobies
boobs
booby
boody
boom
boong
boonga
boonie
booty
bootycall
bountybar
bra
brea5t
breast
breastjob
breastlover
breastman
brothel
bugger
buggered
buggery
bullcrap
bulldike
bulldyke
bullshit
bumblefuck
bumfuck
bunga
bunghole
buried
burn
butchbabes
butchdike
butchdyke
butt
butt-bang
butt-fuck
butt-fucker
butt-fuckers
buttbang
buttface
buttfuck
buttfucker
buttfuckers
butthead
buttman
buttmunch
buttmuncher
buttpirate
buttplug
buttstain
byatch
cacker
cameljockey
cameltoe
canadian
cancer
carpetmuncher
carruth
catholic
catholics
cemetery
chav
cherrypopper
chickslick
children's
chin
chinaman
chinamen
chinese
chink
chinky
choad
chode
christ
christian
church
cigarette
cigs
clamdigger
clamdiver
clit
clitoris
clogwog
cocaine
cock
cockblock
cockblocker
cockcowboy
cockfight
cockhead
cockknob
cocklicker
cocklover
cocknob
cockqueen
cockrider
cocksman
cocksmith
cocksmoker
cocksucer
cocksuck
cocksucked
cocksucker
cocksucking
cocktail
cocktease
cocky
cohee
coitus
color
colored
coloured
commie
communist
condom
conservative
conspiracy
coolie
cooly
coon
coondog
copulate
cornhole
corruption
cra5h
crabs
crack
crack-whore
crackpipe
crackwhore
crap
crapola
crapper
crappy
crash
creamy
crime
crimes
criminal
criminals
crotch
crotchjockey
crotchmonkey
crotchrot
cum
cumbubble
cumfest
cumjockey
cumm
cummer
cumming
cumquat
cumqueen
cumshot
cunilingus
cunillingus
cunn
cunnilingus
cunntt
cunt
cunteyed
cuntfuck
cuntfucker
cuntlick
cuntlicker
cuntlicking
cuntsucker
cybersex
cyberslimer
dago
dahmer
dammit
damn
damnation
damnit
darkie
darky
datnigga
dead
deapthroat
death
deepthroat
defecate
dego
demon
deposit
desire
destroy
deth
devil
devilworshipper
dick
dickbrain
dickforbrains
dickhead
dickless
dicklick
dicklicker
dickman
dickwad
dickweed
diddle
die
died
dies
dike
dildo
dingleberry
dink
dipshit
dipstick
dirty
disease
diseases
disturbed
dive
dix
dixiedike
dixiedyke
doggiestyle
doggystyle
dong
doo-doo
doodoo
doom
dope
dragqueen
dragqween
dripdick
drug
drunk
drunken
dumb
dumbass
dumbbitch
dumbfuck
dyefly
dyke
easyslut
eatballs
eatme
eatpussy
ecstacy
ejaculate
ejaculated
ejaculating
ejaculation
enema
enemy
erect
erection
ero
escort
ethiopian
ethnic
european
evl
excrement
execute
executed
execution
executioner
explosion
facefucker
faeces
fag
fagging
faggot
fagot
failed
failure
fairies
fairy
faith
fannyfucker
fart
farted
farting
farty
fastfuck
fat
fatah
fatass
fatfuck
fatfucker
fatso
fckcum
fear
feces
felatio
felch
felcher
felching
fellatio
feltch
feltcher
feltching
fetish
fight
filipina
filipino
fingerfood
fingerfuck
fingerfucked
fingerfucker
fingerfuckers
fingerfucking
fire
firing
fister
fistfuck
fistfucked
fistfucker
fistfucking
fisting
flange
flasher
flatulence
floo
flydie
flydye
fok
fondle
footaction
footfuck
footfucker
footlicker
footstar
fore
foreskin
forni
fornicate
foursome
fourtwenty
fraud
freakfuck
freakyfucker
freefuck
fu
fubar
fuc
fucck
fuck
fucka
fuckable
fuckbag
fuckbuddy
fucked
fuckedup
fucker
fuckers
fuckface
fuckfest
fuckfreak
fuckfriend
fuckhead
fuckher
fuckin
fuckina
fucking
fuckingbitch
fuckinnuts
fuckinright
fuckit
fuckknob
fuckme
fuckmehard
fuckmonkey
fuckoff
fuckpig
fucks
fucktard
fuckwhore
fuckyou
fudgepacker
fugly
fuk
fuks
funeral
funfuck
fungus
fuuck
gangbang
gangbanged
gangbanger
gangsta
gatorbait
gay
gaymuthafuckinwhore
gaysex
geez
geezer
geni
genital
german
getiton
gin
ginzo
gipp
girls
givehead
glazeddonut
gob
god
godammit
goddamit
goddammit
goddamn
goddamned
goddamnes
goddamnit
goddamnmuthafucker
goldenshower
gonorrehea
gonzagas
gook
gotohell
goy
goyim
greaseball
gringo
groe
gross
grostulation
gubba
gummer
gun
gyp
gypo
gypp
gyppie
gyppo
gyppy
hamas
handjob
hapa
harder
hardon
harem
headfuck
headlights
hebe
heeb
hell
henhouse
heroin
herpes
heterosexual
hijack
hijacker
hijacking
hillbillies
hindoo
hiscock
hitler
hitlerism
hitlerist
hiv
ho
hobo
hodgie
hoes
hole
holestuffer
homicide
homo
homobangers
homosexual
honger
honk
honkers
honkey
honky
hook
hooker
hookers
hooters
hore
hork
horn
horney
horniest
horny
horseshit
hosejob
hoser
hostage
hotdamn
hotpussy
hottotrot
hummer
husky
hussy
hustler
hymen
hymie
iblowu
idiot
ikey
illegal
incest
insest
intercourse
interracial
intheass
inthebuff
israel
israel's
israeli
italiano
itch
jackass
jackoff
jackshit
jacktheripper
jade
jap
japanese
japcrap
jebus
jeez
jerkoff
jesus
jesuschrist
jew
jewish
jiga
jigaboo
jigg
jigga
jiggabo
jigger
jiggy
jihad
jijjiboo
jimfish
jism
jiz
jizim
jizjuice
jizm
jizz
jizzim
jizzum
joint
juggalo
jugs
junglebunny
kaffer
kaffir
kaffre
kafir
kanake
kid
kigger
kike
kill
killed
killer
killing
kills
kink
kinky
kissass
kkk
knife
knockers
kock
kondum
koon
kotex
krap
krappy
kraut
kum
kumbubble
kumbullbe
kummer
kumming
kumquat
kums
kunilingus
kunnilingus
kunt
ky
kyke
lactate
laid
lapdance
latin
lesbain
lesbayn
lesbian
lesbin
lesbo
lez
lezbe
lezbefriends
lezbo
lezz
lezzo
liberal
libido
licker
lickme
lies
limey
limpdick
limy
lingerie
liquor
livesex
loadedgun
lolita
looser
loser
lotion
lovebone
lovegoo
lovegun
lovejuice
lovemuscle
lovepistol
loverocket
lowlife
lsd
lubejob
lucifer
luckycammeltoe
lugan
lynch
macaca
mad
mafia
magicwand
mams
manhater
manpaste
marijuana
mastabate
mastabater
masterbate
masterblaster
mastrabator
masturbate
masturbating
mattressprincess
meatbeatter
meatrack
meth
mexican
mgger
mggor
mickeyfinn
mideast
milf
minority
mockey
mockie
mocky
mofo
moky
moles
molest
molestation
molester
molestor
moneyshot
mooncricket
mormon
moron
moslem
mosshead
mothafuck
mothafucka
mothafuckaz
mothafucked
mothafucker
mothafuckin
mothafucking
mothafuckings
motherfuck
motherfucked
motherfucker
motherfuckin
motherfucking
motherfuckings
motherlovebone
muff
muffdive
muffdiver
muffindiver
mufflikcer
mulatto
muncher
munt
murder
murderer
muslim
naked
narcotic
nasty
nastybitch
nastyho
nastyslut
nastywhore
nazi
necro
negro
negro's
negroes
negroid
nig
niger
nigerian
nigerians
nigg
nigga
niggah
niggaracci
niggard
niggard's
niggarded
niggarding
niggardliness
niggardliness's
niggardly
niggards
niggaz
nigger
nigger's
niggerhead
niggerhole
niggers
niggle
niggled
niggles
niggling
nigglings
niggor
niggur
niglet
nignog
nigr
nigra
nigre
nip
nipple
nipplering
nittit
nlgger
nlggor
nofuckingway
nook
nookey
nookie
noonan
nooner
nude
nudger
nuke
nutfucker
nymph
ontherag
oral
orga
orgasim
orgasm
orgies
orgy
osama
paki
palesimian
palestinian
pansies
pansy
panti
panties
payo
pearlnecklace
peck
pecker
peckerwood
pee
pee-pee
peehole
peepshow
peepshpw
pendy
penetration
peni5
penile
penis
penises
penthouse
period
perv
phonesex
phuk
phuked
phuking
phukked
phukking
phungky
phuq
pi55
picaninny
piccaninny
pickaninny
piker
pikey
piky
pimp
pimped
pimper
pimpjuic
pimpjuice
pimpsimp
pindick
piss
pissed
pisser
pisses
pisshead
pissin
pissing
pissoff
pistol
pixie
pixy
playboy
playgirl
pocha
pocho
pocketpool
pohm
polack
pom
pommie
pommy
poo
poon
poontang
poop
pooper
pooperscooper
pooping
poorwhitetrash
popimp
porchmonkey
porn
pornflick
pornking
porno
pornography
pornprincess
pot
poverty
premature
pric
prick
prickhead
primetime
propaganda
pros
prostitute
protestant
pu55i
pu55y
pube
pubic
pubiclice
pud
pudboy
pudd
puddboy
puke
puntang
purinapricness
puss
pussie
pussies
pussy
pussycat
pussyeater
pussyfucker
pussylicker
pussylips
pussylover
pussypounder
pusy
quashie
queef
queer
quickie
quim
ra8s
rabbi
racial
racist
radical
radicals
raghead
randy
rape
raped
raper
rapist
rearend
rearentry
rectum
redlight
redneck
reefer
reestie
refugee
reject
remains
rentafuck
republican
rere
retard
retarded
ribbed
rigger
rimjob
rimming
roach
robber
roundeye
rump
russki
russkie
sadis
sadom
samckdaddy
sandm
sandnigger
satan
scag
scallywag
scat
schlong
screw
screwyou
scrotum
scum
semen
seppo
servant
sex
sexed
sexfarm
sexhound
sexhouse
sexing
sexkitten
sexpot
sexslave
sextogo
sextoy
sextoys
sexual
sexually
sexwhore
sexy
sexy-slim
sexymoma
shag
shaggin
shagging
shat
shav
shawtypimp
sheeney
shhit
shinola
shit
shitcan
shitdick
shite
shiteater
shited
shitface
shitfaced
shitfit
shitforbrains
shitfuck
shitfucker
shitfull
shithapens
shithappens
shithead
shithouse
shiting
shitlist
shitola
shitoutofluck
shits
shitstain
shitted
shitter
shitting
shitty
shoot
shooting
shortfuck
showtime
sick
sissy
sixsixsix
sixtynine
sixtyniner
skank
skankbitch
skankfuck
skankwhore
skanky
skankybitch
skankywhore
skinflute
skum
skumbag
slant
slanteye
slapper
slaughter
slav
slave
slavedriver
sleezebag
sleezeball
slideitin
slime
slimeball
slimebucket
slopehead
slopey
slopy
slut
sluts
slutt
slutting
slutty
slutwear
slutwhore
smack
smackthemonkey
smut
snatch
snatchpatch
snigger
snigger's
sniggered
sniggering
sniggers
sniper
snot
snowback
snownigger
sob
sodom
sodomise
sodomite
sodomize
sodomy
sonofabitch
sonofbitch
sooty
sos
soviet
spaghettibender
spaghettinigger
spank
spankthemonkey
sperm
spermacide
spermbag
spermhearder
spermherder
spic
spick
spig
spigotty
spik
spit
spitter
splittail
spooge
spreadeagle
spunk
spunky
squaw
stagg
stiffy
strapon
stringer
stripclub
stroke
stroking
stupid
stupidfuck
stupidfucker
suck
suckdick
sucker
suckme
suckmyass
suckmydick
suckmytit
suckoff
suicide
swallow
swallower
swalow
swastika
sweetness
syphilis
taboo
taff
tampon
tang
tantra
tarbaby
tard
teat
terror
terrorist
teste
testicle
testicles
thicklips
thirdeye
thirdleg
threesome
threeway
timbernigger
tinkle
tit
titbitnipply
titfuck
titfucker
titfuckin
titjob
titlicker
titlover
tits
tittie
titties
titty
tnt
toilet
tongethruster
tongue
tonguethrust
tonguetramp
tortur
torture
tosser
towelhead
trailertrash
tramp
trannie
tranny
transexual
transsexual
transvestite
triplex
trisexual
trojan
trots
tuckahoe
tunneloflove
turd
turnon
twat
twink
twinkie
twobitwhore
uck
uk
unfuckable
upskirt
uptheass
upthebutt
urinary
urinate
urine
usama
uterus
vagina
vaginal
vatican
vibr
vibrater
vibrator
vietcong
violence
virgin
virginbreaker
vomit
vulva
wab
wank
wanker
wanking
waysted
weapon
weenie
weewee
welcher
welfare
wetb
wetback
wetspot
whacker
whash
whigger
whiskey
whiskeydick
whiskydick
whit
whitenigger
whites
whitetrash
whitey
whiz
whop
whore
whorefucker
whorehouse
wigger
willie
williewanker
willy
wn
wog
women's
wop
wtf
wuss
wuzzie
xtc
xxx
yankee
yellowman
zigabo
zipperhead
