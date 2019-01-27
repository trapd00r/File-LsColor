#!/usr/bin/perl

use strict;
use warnings;
use Test::More;

unless(exists($ENV{RELEASE_TESTING})) {
  plan skip_all => 'these tests are for release candidate testing';
}

eval 'use Test::MinimumVersion'; ## no critic

plan skip_all => 'Test::MinimumVersion required' if $@;

all_minimum_version_ok('5.010');
