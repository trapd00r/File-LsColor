#!/usr/bin/perl
use strict;
use Test::More tests => 3;
use File::LsColor qw(ls_color_custom ls_color ls_color_lookup);

is(
  (ls_color_custom('*.c=38;5;100;1', 'main.c'))[0],
  "\e[38;5;100m\e[38;1mmain.c\e[m",
  'ls_color_custom() OK',
);


# since we can't modify the LS_COLORS env var here we have to do it like this
*File::LsColor::_parse_ls_colors = *mocklscolors;

sub mocklscolors {
  my $mock;
  $mock->{pl} = '38;5;197';
  $mock->{pm} = '48;5;220;1;3;7';
  return $mock;
}


is(ls_color_lookup('pl'),
  '38;5;197',
  'ls_color_lookup() OK',
);

is(ls_color_lookup('pm'),
  '48;5;220;1;3;7',
  'ls_color_lookup() OK',
);
