#!/usr/bin/perl
# test sources for pod coverage

use strict;
use warnings;
use Test::More;

unless(exists($ENV{RELEASE_TESTING})) {
  plan skip_all => 'these tests are for release candidate testing';
}

{
    ## no critic
    eval '
        use Test::Pod::Coverage 1.08;
        use Pod::Coverage 0.18;
    ';
}
plan skip_all => 'Test::Pod::Coverage (>=1.08) and Pod::Coverage (>=0.18) are required' if $@;

all_pod_coverage_ok(qw/ lib t /);

