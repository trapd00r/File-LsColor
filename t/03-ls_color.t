#!/usr/bin/perl
use Test::More tests => 1;
use File::LsColor qw(ls_color_custom);



is(
  (ls_color_custom('*.c=38;5;100;1', 'main.c'))[0],
  "\e[38;5;100m\e[38;1mmain.c\e[m",
  'ls_color_custom() OK',
);
