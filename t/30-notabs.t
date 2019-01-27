#!/usr/bin/perl
# test for presence of tabs in sources

use strict;
use warnings;
use Test::More;

unless(exists($ENV{RELEASE_TESTING})) {
  plan skip_all => 'these tests are for release candidate testing';
}

eval 'use Test::NoTabs';    ## no critic
plan skip_all => 'Test::NoTabs required' if $@;

all_perl_files_ok(qw/ lib t /);

