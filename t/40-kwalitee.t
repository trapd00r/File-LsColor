#!/usr/bin/perl
# test the kwalitee of a distribution

use strict;
use warnings;
use Test::More;

unless(exists($ENV{RELEASE_TESTING})) {
  plan skip_all => 'these tests are for release candidate testing';
}

eval {
    require Test::Kwalitee;
    Test::Kwalitee->import(
        tests => [
            qw(
              -has_test_pod
              -has_test_pod_coverage
              -has_readme
              -has_manifest
              -has_changelog
              -has_meta_yml
              )
        ]
    );
};

plan( skip_all => 'Test::Kwalitee not installed; skipping' ) if $@;

