#!/usr/bin/perl
# test code for FIXME/BUG/TODO/XXX/NOTE labels

use strict;
use warnings;
use Test::More;

unless(exists($ENV{RELEASE_TESTING})) {
  plan skip_all => 'these tests are for release candidate testing';
}

eval 'use Test::Fixme';    ## no critic
plan skip_all => 'Test::Fixme required' if $@;

run_tests(
  match          => qr/FIXME|BUG\b|XXX/,
  filename_match => qr/\.(pm)$/,
  where          => [ qw( lib ) ]
);

