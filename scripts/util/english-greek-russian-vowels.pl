#!/usr/bin/env perl
# generate-egr-vowels-stripped.pl
use v5.36;
use utf8::all;
use Unicode::Normalize 'NFD';
use List::Util 'uniq';
my ($v_eng, $v_grk, $v_rus, $v_cmb);          # Declare variables.
$v_eng = 'aeiouy';                            # English vowels.
say "English   vowels = $v_eng";               # Say English vowels.
$v_grk = 'αεηιοωυῑῡ';                         # Greek   vowels.
say "Greek     vowels = $v_grk";               # Say Greek   vowels.
$v_rus = 'ауоыиэяюёе';                        # Russian vowels.
say "Russian   vowels = $v_rus";               # Say Russian vowels.
$v_cmb = $v_eng . $v_grk . $v_rus;            # Combine them.
say "Combined  vowels = $v_cmb";               # Say combined vowels.
$v_cmb = NFD $v_cmb;                          # Break-up extended grapheme clusters to letters + marks.
$v_cmb = $v_cmb =~ s/\pM//gr;                 # Erase marks.
$v_cmb = fc $v_cmb;                           # Fold case.
$v_cmb = join '', uniq sort split //, $v_cmb; # Sort letters, then remove adjacent duplicates.
say "Processed vowels = $v_cmb";        # Print processed vowel string.
