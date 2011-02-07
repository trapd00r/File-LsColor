use strict;
use Test::More;

eval q{use Test::Synopsis};
plan skip_all => q{Test::Synopsis required for testing synopsis} if $@;

all_synopsis_ok()
