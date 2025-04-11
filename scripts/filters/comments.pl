#!/usr/bin/env perl
use utf8::all;
print for map {s/^.*?#\s*//r} grep {/#[^!]/} <>;
