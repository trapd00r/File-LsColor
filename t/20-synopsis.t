#!/usr/bin/perl
use strict;
use warnings;
use Test::More;

eval "use Test::Synopsis"; ## no critic

unless(exists($ENV{RELEASE_TESTING})) {
  plan skip_all => 'these tests are for release candidate testing';
}

plan skip_all => 'Test::Synopsis required for testing synopsis' if $@;

all_synopsis_ok()
