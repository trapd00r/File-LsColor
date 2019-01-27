#!/usr/bin/perl
# test for syntax, strict and warnings

use strict;
use warnings;
use Test::More;

unless(exists($ENV{RELEASE_TESTING})) {
  plan skip_all => 'these tests are for release candidate testing';
}

eval 'use Test::Strict';    ## no critic
plan skip_all => 'Test::Strict required' if $@;

{
    no warnings 'once';
    $Test::Strict::TEST_WARNINGS = 0;
}

all_perl_files_ok(qw/ lib t /);
