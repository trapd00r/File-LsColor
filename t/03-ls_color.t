#!/usr/bin/perl
# vim: ft=perl:fdm=marker:fmr=#<,#>:fen:et:sw=2:

################################################################################
# Be aware that we have to enclose the escape sequences in double quotes
# while testing, or else the compare will fail.
################################################################################


use strict;
use warnings;
use Test::More tests => 9;
#use Data::Dumper;
#
#{
#  package Data::Dumper;
#  no strict 'vars';
#  $Terse = $Indent = $Useqq = $Deparse = $Sortkeys = 1;
#  $Quotekeys = 0;
#}

use File::LsColor qw(
  ls_color
  ls_color_default
  parse_ls_colors
  can_ls_color
);

################################################################################
# Due to the nature of environment variables, we can't predict the value
# on other systems. Therefore, we have to override the internal function
# for parsing LS_COLORS from the system.
################################################################################

*File::LsColor::parse_ls_colors = *mocklscolors;

sub mocklscolors {
  my $mock = {
    '.pl'         => '38;5;197',
    '.pm'         => '38;5;220;1;3;4;7;48;5;196',
    'di'          => '38;5;31',
    '.pl'         => '38;5;197',
    '.txt'        => '38;5;42',
    '.mp3'        => '38;5;44',
    'case.flac'   => '48;5;196',
    'case.FLAC'   => '38;5;65',
    'README'      => '38;5;220;1',
  };

  return $mock;
}


my $fullpath               = '/usr/share/perl5/core_perl/laleh.pm';
my $file_with_extension    = '~/tmp/laleh.mp3';
my $file_without_extension = '~/tmp/Makefile.PL';


################################################################################
# Test 1: A full path with $COLORIZE_PATH set, using nested escape sequences.
################################################################################
$File::LsColor::COLORIZE_PATH = 1;

is(
   ls_color_default($fullpath),
   "\e[38;5;31m/usr/share/perl5/core_perl/\e[m\e[38;5;220;1;3;4;7;48;5;196mlaleh.pm\e[m",
   '+COLORIZE_PATH path with nested escape sequences',
);

################################################################################
# Test 1: A full path with $COLORIZE_PATH unset, using nested escape sequences.
################################################################################
$File::LsColor::COLORIZE_PATH = 0;

is(
   ls_color_default($fullpath),
   "\e[38;5;220;1;3;4;7;48;5;196m/usr/share/perl5/core_perl/laleh.pm\e[m",
   '-COLORIZE_PATH path with extension',
);


################################################################################
# Test 3:
################################################################################
$File::LsColor::COLORIZE_PATH = 1;

is(
   ls_color_default($file_with_extension),
   "\e[38;5;31m~/tmp/\e[m\e[38;5;44mlaleh.mp3\e[m",
   '+COLORIZE_PATH path with extension',
);

################################################################################
# Test 4: Can we color file?
################################################################################

is(
   can_ls_color('file.pl'),
   '38;5;197',
   'can_ls_color("file.pl")',
);

################################################################################
# Test 5: Can we color a directory by 'di' key?
################################################################################


is(
   can_ls_color('di'),
   '38;5;31',
   'can_ls_color("di")',
);

################################################################################
# Test 6: Can we color a file with no extension?
################################################################################

is(
   can_ls_color('README'),
   '38;5;220;1',
   'can_ls_color("README"), (file without extension)',
);

################################################################################
# Test 7, 8: Can we color a file differently with an uppercase extension?
################################################################################
$File::LsColor::IGNORE_CASE = 0;

is(
   can_ls_color('case.flac'),
   '48;5;196',
   'color uppercase extension differently',
);

$File::LsColor::IGNORE_CASE = 1;
is(
   can_ls_color('case.FLAC'),
   '48;5;196',
   'color uppercase extension as lowercase when IGNORE_CASE set',
);
################################################################################
# Test 9: Parsing of LS_COLORS
################################################################################

my $parsed = parse_ls_colors('.patch=31;1:*MANIFEST=38;5;243');

is($parsed->{'.patch'}, '31;1', 'parse_ls_colors() OK');


done_testing();
