#!/usr/bin/perl
# test sources by Perl Code Metrics System

use strict;
use warnings;
use Test::More;

unless(exists($ENV{RELEASE_TESTING})) {
  plan skip_all => 'these tests are for release candidate testing';
}

{
    ## no critic
    eval '
        use Perl::Metrics::Simple;
        use File::Find::Rule       ();
        use File::Find::Rule::Perl ();
    ';
}
plan skip_all => 'Perl::Metrics::Simple, File::Find::Rule and File::Find::Rule::Perl required' if $@;

# configure this to match your needs
my $max_complexity = 40;
my $max_lines      = 80;

my @files    = File::Find::Rule->perl_file->in(qw/ lib t /);
my $analzyer = Perl::Metrics::Simple->new;
my @subs;

foreach (@files) {
    my $analysis = $analzyer->analyze_files($_);
    push( @subs, $_ ) foreach ( @{ $analysis->subs } );
}

plan tests => ( scalar @subs ) * 2;

foreach my $sub (@subs) {
    my $name       = $sub->{name} . ' in ' . $sub->{path};
    my $complexity = $sub->{mccabe_complexity};
    my $lines      = $sub->{lines};

    ok( $complexity <= $max_complexity, "Cyclomatic comlexity for $name is too big ($complexity > $max_complexity)" );
    ok( $lines <= $max_lines,           "Lines count for $name is too big ($lines > $max_lines)" );
}

