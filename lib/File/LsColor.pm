package File::LsColor;
use strict;

BEGIN {
  use Exporter;
  use vars qw($VERSION @ISA @EXPORT_OK);

  $VERSION = '0.005';
  @ISA = qw(Exporter);

  @EXPORT_OK = qw(
    ls_color
  );
}

use Carp qw(croak);
use Term::ExtendedColor qw(fg);


my %attributes = (
  1 => 'bold',
  2 => 'faint',
  3 => 'italic',
  4 => 'underline',
  5 => 'blink',
  6 => 'blink_ms',
  7 => 'reverse',
);


sub ls_color {
  my @files;

  if(ref($_[0]) eq 'ARRAY') {
    push(@files, @{$_[0]});
  }
  else {
    push(@files, @_);
  }
  my %result;
  my $ls_colors = _parse_ls_colors();

  for my $file(@files) {
    my($ext) = $file =~ m/^.*\.(.+)$/m;
    for my $ft(keys(%{$ls_colors})) {
      if($ext eq $ft) {
      # 38;5;100;1m
        if($ls_colors->{$ft} =~ m/;(\d+;?[1-9]?)$/m) {
          my $n = $1;
          # Account for bold, italic, underline etc
          if($n =~ m/(\d+);([1-7])/) {
            my $attr = $2;
            $n = $1;
            $file = fg($attributes{$2}, $file);
          }
          $file = fg($n, $file);
        }
      }
    }
  }
  return @files;
}

sub _parse_ls_colors {
  my $ft;

  if(!exists($ENV{LS_COLORS})) {
    croak("LS_COLORS variable is NOT set! Nothing to do...\n");
  }

  for(split(/:/, $ENV{LS_COLORS})) {
    if($_ =~ m/\*\.([\w.]+)=([0-9;]+)/) {
      $ft->{$1} = $2;
    }
  }
  return $ft;
}



#TODO include my LS_COLORS variable, export sep. function

1;


__END__


=pod

=head1 NAME

File::LsColor - Colorize input filenames just like ls does

=head1 SYNOPSIS

    use File::LsColor qw(ls_color);

    for my $file(glob("$ENV{HOME}/*")) {
      print ls_color($file);
    }

=head1 DESCRIPTION

This module provides functionality for using the LS_COLORS variable for
colorizing output in a way that's immediately recognized.

Say that you have a list of filenames that's the result of some complex
operation, and you wish to present the result to the user.

If said files have an extension and that extension is present in the users
LS_COLORS variable, they will be colored just like they would have been if the
filenames were output from L<ls(1)> or L<tree(1)>.


=head1 EXPORTS

None by default.

=head1 FUNCTIONS

=head2 ls_color()

Arguments: @files | \@files

Returns:   @files

=head1 AUTHOR

  Magnus Woldrich
  CPAN ID: WOLDRICH
  magnus@trapd00r.se
  http://japh.se

=head1 REPORTING BUGS

Report bugs on rt.cpan.org or to magnus@trapd00r.se

=head1 CONTRIBUTORS

None required yet.

=head1 COPYRIGHT

Copyright 2011 B<THIS MODULE>s L</AUTHOR> and L</CONTRIBUTORS> as listed above.

=head1 LICENSE

This library is free software; you may redistribute it and/or modify it under
the same terms as Perl itself.

=cut

# vim: set ts=2 et sw=2:
