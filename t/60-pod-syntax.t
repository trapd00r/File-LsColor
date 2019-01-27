#!/usr/bin/perl
# test sources for POD syntax

use strict;
use warnings;
use Test::More;

unless(exists($ENV{RELEASE_TESTING})) {
  plan skip_all => 'these tests are for release candidate testing';
}

eval 'use Test::Pod 1.22';    ## no critic
plan skip_all => 'Test::Pod (>=1.22) is required' if $@;

all_pod_files_ok(qw/ lib t /);

