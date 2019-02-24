#!/usr/bin/perl
use strict;
use Test::More tests => 6;
use File::LsColor qw(ls_color_custom ls_color can_ls_color parse_ls_colors);

is(
  (ls_color_custom('*.c=38;5;100;1', 'main.c'))[0],
  "\e[38;5;100m\e[38;1mmain.c\e[m",
  'ls_color_custom() OK',
);


# since we can't modify the LS_COLORS env var here we have to do it like this
*File::LsColor::parse_ls_colors = *mocklscolors;

sub mocklscolors {
  my $mock;
  $mock->{pl}  = '38;5;197';
  $mock->{pm}  = '48;5;220;1;3;7';
  $mock->{mp3} = '38;5;220';
  return $mock;
}


is(can_ls_color('pl'),
  '38;5;197',
  'can_ls_color() OK',
);

is(can_ls_color('pm'),
  '48;5;220;1;3;7',
  'can_ls_color() OK',
);

is(can_ls_color('filename_with_extension.mp3'),
  '38;5;220',
  'can_ls_color() OK',
);

is(can_ls_color('verylongandnonexistanstextension'), undef, 'can_ls_color() OK');

my $parsed = parse_ls_colors('.patch=31;1:*MANIFEST=38;5;243');

is($parsed->{patch}, '31;1', 'parse_ls_colors() OK');
