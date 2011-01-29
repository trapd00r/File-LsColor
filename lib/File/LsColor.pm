package File::LsColor;
use strict;

BEGIN {
  use Exporter;
  use vars qw($VERSION @ISA @EXPORT_OK);

  $VERSION = '0.012';
  @ISA = qw(Exporter);

  @EXPORT_OK = qw(
    ls_color
    ls_color_internal
  );
}

use Carp qw(croak);
use Term::ExtendedColor qw(fg);

my $LS_COLORS = $ENV{LS_COLORS}; # Default

# Yes, this is pretty :)
my $internal_ls_color = '
*.cpp=38;5;24;1:*.cs=38;5;74;1:*.java=38;5;142;1:*.js=38;5;42:
*.lisp=38;5;204;1:*.coffee=38;5;94;1:*.asm=38;5;240;1:*.mp4=38;5;124
:*.flv=38;5;131:*.spl=38;5;44:*.sug=38;5;44:*.1=38;5;196;1:*.eps=38;5;192:
*.xpm=38;5;32:*.gif=38;5;35:*.info=38;5;101:*.lua=38;5;34;1:*.t=38;5;028;1:
*.textile=38;5;106:ln=target:*.hs=38;5;159:*.ini=38;5;122:*.part=38;5;240:
*.pid=38;5;160:*.pod=38;5;106:*.vim=1:*.git=38;5;197:*.urlview=38;5;85:
*.dump=38;5;119:*.conf=1:*.md=38;5;184:*.markdown=38;5;184:*.mkd=38;5;184:
*.h=38;5;81:*.rb=38;5;192:*.c=38;5;110:*.diff=42;38:*.yml=38;5;208:
*.PL=38;5;160:*.csv=38;5;78:tw=33;1;38;5;208:*.chm=38;5;144:*.bin=38;5;249:
*.sms=38;5;33:*.pdf=38;5;203:*.cbz=38;5;140:*.cbr=38;5;140:*.nes=38;5;160:
*.mpg=38;5;38:*.ts=38;5;39:*.sfv=38;5;197:*.m3u=38;5;172:*.txt=38;5;192:
*.log=38;5;190:*.bash=38;5;173:*.swp=38;5;241:*.swo=38;5;236:*.theme=38;5;109:
*.zsh=38;5;173:*.nfo=38;5;220:mi=38;5;124:or=38;5;160:ex=33;1;38;5;148:
ln=target:pi=38;5;126:ow=33;1;38;5;208:di=38;5;30:*.pm=33;1;38;5;197:
*.pl=38;5;214:*.sh=38;5;113:*.patch=45;37:*.tar=38;5;118:*.tar.gz=38;5;34:
*.zip=38;5;11:*.rar=38;5;106:*.tgz=38;5;11:*.7z=38;5;11:*.mp3=38;5;191:
*.flac=33;1;38;5;166:*.mkv=38;5;202:*.avi=38;5;114:*.wmv=38;5;113:
*.jpg=38;5;66:*.JPG=38;5;66:*.jpeg=38;5;67:*.png=38;5;68:*.pacnew=38;5;33:
*.xz=38;5;118:*.iso=38;5;124:*.css=38;5;91:*.php=38;5;93:*.gitignore=38;5;240:
*.tmp=38;5;244:*.py=38;5;41:*.rmvb=38;5;112:*.arj=38;5;11:*.a=38;5;59:
*.a00=38;5;11:*.A64=38;5;82:*.pc=38;5;100:*.a52=38;5;112:*.gel=38;5;83:
*.ggl=38;5;83:*.directory=38;5;83:*.a78=38;5;112:*.atr=38;5;213:
*.j64=38;5;102:st=1;38;5;208:*.st=38;5;208:*.dat=38;5;165:*.db=38;5;60:
*.xml=38;5;23:*.cdi=38;5;124:*.nrg=38;5;124:*.32x=38;5;137:*.gg=38;5;138:
*.cue=38;5;112:*.adf=38;5;35:*.nds=38;5;193:*.gb=38;5;203:*.gbc=38;5;204:
*.gba=38;5;205:*.sav=38;5;220:*.r00=38;5;233:*.r01=38;5;234:*.r02=38;5;235:
*.r03=38;5;236:*.r04=38;5;237:*.r05=38;5;238:*.r06=38;5;239:*.r07=38;5;240:
*.r08=38;5;241:*.r09=38;5;242:*.r10=38;5;243:*.r11=38;5;244:*.r12=38;5;245:
*.r13=38;5;246:*.r14=38;5;247:*.r15=38;5;248:*.r16=38;5;249:*.r17=38;5;250:
*.r18=38;5;251:*.r19=38;5;252:*.r20=38;5;253:*.r21=38;5;254:*.r22=38;5;255:
*.r47=38;5;233:*.r46=38;5;234:*.r45=38;5;235:*.r44=38;5;236:*.r43=38;5;237:
*.r42=38;5;238:*.r41=38;5;239:*.r40=38;5;240:*.r39=38;5;241:*.r38=38;5;242:
*.r37=38;5;243:*.r36=38;5;244:*.r35=38;5;245:*.r34=38;5;246:*.r33=38;5;247:
*.r32=38;5;248:*.r31=38;5;249:*.r30=38;5;250:*.r29=38;5;251:*.r28=38;5;252:
*.r27=38;5;253:*.r26=38;5;254:*.r25=38;5;255:*.json=38;5;199:*.SKIP=38;5;244:
*.1p=38;5;160:*.3p=38;5;160:*.r48=38;5;234:*.r49=38;5;235:*.r50=38;5;236:
*.r51=38;5;237:*.r52=38;5;238:*.r53=38;5;239:*.r54=38;5;240:*.r55=38;5;241:
*.r56=38;5;242:*.r57=38;5;243:*.r58=38;5;244:*.r59=38;5;245:*.r60=38;5;246:
*.r61=38;5;247:*.r62=38;5;248:*.r63=38;5;249:*.r64=38;5;250:*.r65=38;5;251:
*.r66=38;5;252:*.r67=38;5;253:*.r68=38;5;254:*.r69=38;5;255:*.r69=38;5;255:
*.r70=38;5;254:*.r71=38;5;253:*.r72=38;5;252:*.r73=38;5;251:*.r74=38;5;250:
*.r75=38;5;249:*.r76=38;5;248:*.r77=38;5;247:*.r78=38;5;246:*.r79=38;5;245:
*.r80=38;5;244:*.r81=38;5;243:*.r82=38;5;242:*.r83=38;5;241:*.r84=38;5;240:
*.r85=38;5;239:*.r86=38;5;238:*.r87=38;5;237:*.r88=38;5;236:*.r89=38;5;235:
*.r90=38;5;234:*.r91=38;5;235:*.r92=38;5;236:*.r93=38;5;237:*.r94=38;5;238:
*.r95=38;5;239:*.r96=38;5;240:*.r97=38;5;241:*.r98=38;5;242:*.r99=38;5;243:
*.r100=38;5;244:*.r101=38;5;240:*.r102=38;5;241:*.r103=38;5;242:
*.r104=38;5;243:*.r105=38;5;244:*.r106=38;5;245:*.r107=38;5;246:*.r108=38;5;247:
*.r109=38;5;248:*.r110=38;5;249:*.r111=38;5;250:*.r112=38;5;251:*.r113=38;5;252:
*.r114=38;5;253:*.r115=38;5;254:*.r116=38;5;255';

$internal_ls_color =~ s/\n//g;


# For situations like *.pl=38;5;196;1 (bold and red)
my %attributes = (
  1 => 'bold',
  2 => 'faint',
  3 => 'italic',
  4 => 'underline',
  5 => 'blink',
  6 => 'blink_ms',
  7 => 'reverse',
);

# Alright, use our own LS_COLORS definition
sub ls_color_internal {
  $LS_COLORS = $internal_ls_color;
  ls_color(@_);
}


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

  if( (!defined($LS_COLORS)) or ($LS_COLORS eq '') ) {
    croak("LS_COLORS variable not set! Nothing to be done...\n");
  }

  for(split(/:/, $LS_COLORS)) {
    if($_ =~ m/\*\.([\w.]+)=([0-9;]+)/) {
      $ft->{$1} = $2;
    }
  }
  return $ft;
}



1;


__END__


=pod

=head1 NAME

File::LsColor - Colorize input filenames just like ls does

=head1 SYNOPSIS

    use File::LsColor qw(ls_color ls_color_internal);

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

Returns a list of filenames colored as specified by the environment LS_COLORS
variable. If the LS_COLORS variable is not set, throws an exception.
In this case, C<ls_color_internal()> can be used.

=head2 ls_color_internal()

The same as C<ls_color()>, with one minor difference; Instead of using the
LS_COLORS variable from the environment, an internal specification is used.
This specification contains about 250 extensions as of this writing.

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
