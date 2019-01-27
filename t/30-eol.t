#!/usr/bin/perl
# test for correct line endings

use strict;
use warnings;
use Test::More;

unless(exists($ENV{RELEASE_TESTING})) {
  plan skip_all => 'these tests are for release candidate testing';
}

eval 'use Test::EOL';    ## no critic
plan skip_all => 'Test::EOL required' if $@;

all_perl_files_ok( { trailing_whitespace => 1 }, qw/ lib t / );
