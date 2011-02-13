#!/usr/bin/perl
use Test::More tests => 2;
use File::LsColor qw(ls_color_internal ls_color_custom);



is(
  (ls_color_custom('*.c=38;5;100;1', 'main.c'))[0],
  "\e[38;5;100m\e[38;1mmain.c\e[m",
  'ls_color_custom() OK',
);

is(
  (ls_color_internal('Makefile.PL'))[0],
  "\e[38;5;160mMakefile.PL\e[m",
  'ls_color_internal() OK',
);
