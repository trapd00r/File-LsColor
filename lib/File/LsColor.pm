package File::LsColor;
use strict;
use warnings;

BEGIN {
  use Exporter;
  use vars qw($VERSION @ISA @EXPORT_OK %EXPORT_TAGS);

  $VERSION = '0.499';
  @ISA = qw(Exporter);

  @EXPORT_OK = qw(
    ls_color
    ls_color_custom
    ls_color_default
    ls_color_internal
    get_ls_colors
    can_ls_color
    ls_color_lookup
    parse_ls_colors
  );

  %EXPORT_TAGS = (
    all => [
      qw(
      ls_color ls_color_custom ls_color_default ls_color_internal
      get_ls_colors can_ls_color ls_color_lookup parse_ls_colors
      )
    ],
  );
}

# alias for compatibility reasons with File::LsColor prior to 0.300
{
  no warnings 'once';
  *ls_color_lookup = *can_ls_color;
}

use Carp qw(croak);
use Term::ExtendedColor qw(fg);

my $extracted_ls_colors;
my $LS_COLORS = $ENV{LS_COLORS}; # Default

#<internal LS_COLORS specification
# yes, this is pretty :)
# colors from https://github.com/trapd00r/LS_COLORS
my $internal_ls_color='
bd=38;5;68:ca=38;5;17:cd=38;5;113;1:di=38;5;30:do=38;5;127:ex=38;5;166;1:
pi=38;5;126:fi=38;5;253:ln=target:mh=38;5;222;1:or=48;5;196;38;5;232;1:
ow=38;5;220;1:sg=48;5;3;38;5;0:su=38;5;220;1;3;100;1:so=38;5;197:
st=38;5;232;48;5;30:tw=48;5;235;38;5;139;3:*LS_COLORS=48;5;89;38;5;197;1;3;4;7:
*.msi=38;5;039:*.xys=38;5;204:*README=38;5;220;1:*LICENSE=38;5;220;1:
*COPYING=38;5;220;1:*INSTALL=38;5;220;1:*COPYRIGHT=38;5;220;1:
*AUTHORS=38;5;220;1:*HISTORY=38;5;220;1:*CONTRIBUTORS=38;5;220;1:
*PATENTS=38;5;220;1:*VERSION=38;5;220;1:*NOTICE=38;5;220;1:*CHANGES=38;5;220;1:
*.log=38;5;190:*Makefile=38;5;155:*MANIFEST=38;5;243:*pm_to_blib=38;5;240:
*.txt=38;5;253:*.etx=38;5;184:*.info=38;5;184:*.markdown=38;5;184:*.md=38;5;184:
*.mkd=38;5;184:*.nfo=38;5;184:*.pod=38;5;184:*.tex=38;5;184:*.textile=38;5;184:
*.json=38;5;178:*.msg=38;5;178:*.pgn=38;5;178:*.rss=38;5;178:*.xml=38;5;178:
*.yml=38;5;178:*.RData=38;5;178:*.rdata=38;5;178:*.csv=38;5;78:*.cbr=38;5;141:
*.cbz=38;5;141:*.chm=38;5;141:*.djvu=38;5;141:*.pdf=38;5;141:*.PDF=38;5;141:
*.docm=38;5;111;4:*.doc=38;5;111:*.docx=38;5;111:*.eps=38;5;111:*.ps=38;5;111:
*.odb=38;5;111:*.odt=38;5;111:*.odp=38;5;166:*.pps=38;5;166:*.ppt=38;5;166:
*.ods=38;5;112:*.xla=38;5;76:*.xls=38;5;112:*.xlsx=38;5;112:*.xlsxm=38;5;112;4:
*.xltm=38;5;73;4:*.xltx=38;5;73:*cfg=38;5;204:*conf=38;5;204:*rc=38;5;204:
*.ini=38;5;204:*.gws=38;5;204:*.viminfo=38;5;204:*.pcf=38;5;204:*.psf=38;5;204:
*.reg=38;5;203:*.git=38;5;197:*.gitignore=38;5;240:*.gitattributes=38;5;240:
*.gitmodules=38;5;240:*.awk=38;5;172:*.bash=38;5;172:*.bat=38;5;172:
*.BAT=38;5;172:*.sed=38;5;172:*.sh=38;5;138:*.zsh=38;5;137:*.vim=38;5;254;1:
*.ahk=38;5;41:*.py=38;5;41:*.pl=38;5;208:*.PL=38;5;160:*.t=38;5;114:
*.msql=38;5;222:*.mysql=38;5;222:*.pgsql=38;5;222:*.sql=38;5;222:
*.tcl=38;5;64;1:*.r=38;5;49:*.R=38;5;49:*.gs=38;5;81:*.asm=38;5;81:
*.cl=38;5;81:*.lisp=38;5;81:*.lua=38;5;81:*.moon=38;5;81:*.c=38;5;81:
*.C=38;5;81:*.h=38;5;110:*.H=38;5;110:*.tcc=38;5;110:*.c++=38;5;81:
*.h++=38;5;110:*.hpp=38;5;110:*.hxx=38;5;110:*.ii=38;5;110:*.M=38;5;110:
*.m=38;5;110:*.cc=38;5;81:*.cs=38;5;81:*.cp=38;5;81:*.cpp=38;5;81:*.cxx=38;5;81:
*.cr=38;5;81:*.go=38;5;81:*.f=38;5;81:*.for=38;5;81:*.ftn=38;5;81:*.s=38;5;110:
*.S=38;5;110:*.rs=38;5;81:*.sx=38;5;81:*.hi=38;5;110:*.hs=38;5;81:*.lhs=38;5;81:
*.pyc=38;5;240:*.css=38;5;125;1:*.less=38;5;125;1:*.sass=38;5;125;1:
*.scss=38;5;125;1:*.htm=38;5;125;1:*.html=38;5;125;1:*.jhtm=38;5;125;1:
*.mht=38;5;125;1:*.eml=38;5;125;1:*.mustache=38;5;125;1:*.coffee=38;5;074;1:
*.java=38;5;074;1:*.js=38;5;074;1:*.jsm=38;5;074;1:*.jsm=38;5;074;1:
*.jsp=38;5;074;1:*.php=38;5;81:*.ctp=38;5;81:*.twig=38;5;81:*.vb=38;5;81:
*.vba=38;5;81:*.vbs=38;5;81:*.am=38;5;242:*.in=38;5;242:*.hin=38;5;242:
*.scan=38;5;242:*.m4=38;5;242:*.old=38;5;242:*.out=38;5;242:*.SKIP=38;5;244:
*.diff=48;5;197;38;5;232:*.patch=48;5;197;38;5;232;1:*.bmp=38;5;129:
*.tiff=38;5;97:*.TIFF=38;5;97:*.cdr=38;5;97:*.gif=38;5;97:*.ico=38;5;132:
*.jpeg=38;5;125:*.JPG=38;5;125:*.jpg=38;5;125:*.nth=38;5;97:*.png=38;5;197:
*.svg=38;5;97:*.xpm=38;5;97:*.avi=38;5;114:*.divx=38;5;114:*.IFO=38;5;114:
*.m2v=38;5;114:*.m4v=38;5;114:*.mkv=38;5;114:*.MOV=38;5;114:*.mov=38;5;114:
*.mp4=38;5;114:*.mpeg=38;5;114:*.mpg=38;5;114:*.ogm=38;5;114:*.rmvb=38;5;114:
*.sample=38;5;114:*.wmv=38;5;114:*.3g2=38;5;115:*.3gp=38;5;115:*.gp3=38;5;115:
*.webm=38;5;115:*.gp4=38;5;115:*.asf=38;5;115:*.flv=38;5;115:*.ts=38;5;115:
*.ogv=38;5;115:*.f4v=38;5;115:*.VOB=38;5;115;1:*.vob=38;5;115;1:
*.3ga=38;5;137;1:*.S3M=38;5;137;1:*.aac=38;5;137;1:*.dat=38;5;137;1:
*.dts=38;5;137;1:*.fcm=38;5;137;1:*.m4a=38;5;137;1:*.mid=38;5;137;1:
*.midi=38;5;137;1:*.mod=38;5;137;1:*.mp3=38;5;137;1:*.oga=38;5;137;1:
*.ogg=38;5;137;1:*.s3m=38;5;137;1:*.sid=38;5;137;1:*.ape=38;5;136;1:
*.flac=38;5;136;1:*.alac=38;5;136;1:*.wav=38;5;136;1:*.wv=38;5;136;1:
*.wvc=38;5;136;1:*.afm=38;5;66:*.pfb=38;5;66:*.pfm=38;5;66:*.ttf=38;5;66:
*.otf=38;5;66:*.PFA=38;5;66:*.pfa=38;5;66:*.7z=38;5;40:*.a=38;5;40:
*.arj=38;5;40:*.bz2=38;5;40:*.gz=38;5;40:*.rar=38;5;40:*.tar=38;5;40:
*.tgz=38;5;40:*.xz=38;5;40:*.zip=38;5;40:*.r00=38;5;239:*.r01=38;5;239:
*.r02=38;5;239:*.r03=38;5;239:*.r04=38;5;239:*.r05=38;5;239:*.r06=38;5;239:
*.r07=38;5;239:*.r08=38;5;239:*.r09=38;5;239:*.r10=38;5;239:*.r100=38;5;239:
*.r101=38;5;239:*.r102=38;5;239:*.r103=38;5;239:*.r104=38;5;239:
*.r105=38;5;239:*.r106=38;5;239:*.r107=38;5;239:*.r108=38;5;239:
*.r109=38;5;239:*.r11=38;5;239:*.r110=38;5;239:*.r111=38;5;239:*.r112=38;5;239:
*.r113=38;5;239:*.r114=38;5;239:*.r115=38;5;239:*.r116=38;5;239:*.r12=38;5;239:
*.r13=38;5;239:*.r14=38;5;239:*.r15=38;5;239:*.r16=38;5;239:*.r17=38;5;239:
*.r18=38;5;239:*.r19=38;5;239:*.r20=38;5;239:*.r21=38;5;239:*.r22=38;5;239:
*.r25=38;5;239:*.r26=38;5;239:*.r27=38;5;239:*.r28=38;5;239:*.r29=38;5;239:
*.r30=38;5;239:*.r31=38;5;239:*.r32=38;5;239:*.r33=38;5;239:*.r34=38;5;239:
*.r35=38;5;239:*.r36=38;5;239:*.r37=38;5;239:*.r38=38;5;239:*.r39=38;5;239:
*.r40=38;5;239:*.r41=38;5;239:*.r42=38;5;239:*.r43=38;5;239:*.r44=38;5;239:
*.r45=38;5;239:*.r46=38;5;239:*.r47=38;5;239:*.r48=38;5;239:*.r49=38;5;239:
*.r50=38;5;239:*.r51=38;5;239:*.r52=38;5;239:*.r53=38;5;239:*.r54=38;5;239:
*.r55=38;5;239:*.r56=38;5;239:*.r57=38;5;239:*.r58=38;5;239:*.r59=38;5;239:
*.r60=38;5;239:*.r61=38;5;239:*.r62=38;5;239:*.r63=38;5;239:*.r64=38;5;239:
*.r65=38;5;239:*.r66=38;5;239:*.r67=38;5;239:*.r68=38;5;239:*.r69=38;5;239:
*.r69=38;5;239:*.r70=38;5;239:*.r71=38;5;239:*.r72=38;5;239:*.r73=38;5;239:
*.r74=38;5;239:*.r75=38;5;239:*.r76=38;5;239:*.r77=38;5;239:*.r78=38;5;239:
*.r79=38;5;239:*.r80=38;5;239:*.r81=38;5;239:*.r82=38;5;239:*.r83=38;5;239:
*.r84=38;5;239:*.r85=38;5;239:*.r86=38;5;239:*.r87=38;5;239:*.r88=38;5;239:
*.r89=38;5;239:*.r90=38;5;239:*.r91=38;5;239:*.r92=38;5;239:*.r93=38;5;239:
*.r94=38;5;239:*.r95=38;5;239:*.r96=38;5;239:*.r97=38;5;239:*.r98=38;5;239:
*.r99=38;5;239:*.apk=38;5;215:*.deb=38;5;215:*.jad=38;5;215:*.jar=38;5;215:
*.cab=38;5;215:*.pak=38;5;215:*.pk3=38;5;215:*.vdf=38;5;215:*.vpk=38;5;215:
*.bsp=38;5;215:*.dmg=38;5;215:*.iso=38;5;124:*.bin=38;5;124:*.nrg=38;5;124:
*.qcow=38;5;124:*.sparseimage=38;5;124:*.accdb=38;5;60:*.accde=38;5;60:
*.accdr=38;5;60:*.accdt=38;5;60:*.db=38;5;60:*.localstorage=38;5;60:
*.sqlite=38;5;60:*.typelib=38;5;60:*.nc=38;5;60:*.part=38;5;239:*~=38;5;241:
*.pacnew=38;5;33:*.un~=38;5;241:*.orig=38;5;241:*.BUP=38;5;241:*.bak=38;5;241:
*.o=38;5;241:*.rlib=38;5;241:*.swp=38;5;244:*.swo=38;5;244:*.tmp=38;5;244:
*.sassc=38;5;244:*.pid=38;5;248:*.state=38;5;248:*lockfile=38;5;248:
*.err=38;5;160;1:*.error=38;5;160;1:*.stderr=38;5;160;1:*.dump=38;5;241:
*.stackdump=38;5;241:*.zcompdump=38;5;241:*.zwc=38;5;241:*.pcap=38;5;29:
*.cap=38;5;29:*.dmp=38;5;29:*.allow=38;5;112:*.deny=38;5;196:
*.service=38;5;45:*@.service=38;5;45:*.socket=38;5;45:*.swap=38;5;45:
*.device=38;5;45:*.mount=38;5;45:*.automount=38;5;45:*.target=38;5;45:
*.path=38;5;45:*.timer=38;5;45:*.snapshot=38;5;45:*.application=38;5;116:
*.cue=38;5;116:*.description=38;5;116:*.directory=38;5;116:*.m3u=38;5;116:
*.m3u8=38;5;116:*.md5=38;5;116:*.properties=38;5;116:*.sfv=38;5;116:
*.srt=38;5;116:*.theme=38;5;116:*.torrent=38;5;116:*.urlview=38;5;116:
*.asc=38;5;192;3:*.enc=38;5;192;3:*.gpg=38;5;192;3:*.signature=38;5;192;3:
*.sig=38;5;192;3:*.p12=38;5;192;3:*.pem=38;5;192;3:*.pgp=38;5;192;3:
*.asc=38;5;192;3:*.enc=38;5;192;3:*.sig=38;5;192;3:*.signature=38;5;192;3:
*.32x=38;5;213:*.cdi=38;5;213:*.fm2=38;5;213:*.rom=38;5;213:*.sav=38;5;213:
*.st=38;5;213:*.a00=38;5;213:*.a52=38;5;213:*.A64=38;5;213:*.a64=38;5;213:
*.a78=38;5;213:*.adf=38;5;213:*.atr=38;5;213:*.gb=38;5;213:*.gba=38;5;213:
*.gbc=38;5;213:*.gel=38;5;213:*.gg=38;5;213:*.ggl=38;5;213:*.ipk=38;5;213:
*.j64=38;5;213:*.nds=38;5;213:*.nes=38;5;213:*.sms=38;5;213:*.pot=38;5;7:
*.pcb=38;5;7:*.mm=38;5;7:*.gbr=38;5;7:*.spl=38;5;7:*.scm=38;5;7:
*.Rproj=38;5;11:*.sis=38;5;7:*.1p=38;5;7:*.3p=38;5;7:*.cnc=38;5;7:
*.def=38;5;7:*.ex=38;5;7:*.example=38;5;7:*.feature=38;5;7:*.ger=38;5;7:
*.map=38;5;7:*.mf=38;5;7:*.mfasl=38;5;7:*.mi=38;5;7:*.mtx=38;5;7:*.pc=38;5;7:
*.pi=38;5;7:*.plt=38;5;7:*.pm=38;5;7:*.rb=38;5;7:*.rdf=38;5;7:*.rst=38;5;7:
*.ru=38;5;7:*.sch=38;5;7:*.sty=38;5;7:*.sug=38;5;7:*.tdy=38;5;7:*.tfm=38;5;7:
*.tfnt=38;5;7:*.tg=38;5;7:*.vcard=38;5;7:*.vcf=38;5;7:*.xln=38;5;7';
#>


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
  $extracted_ls_colors = parse_ls_colors($LS_COLORS);
  ls_color(@_);
}

sub ls_color_custom {
  $LS_COLORS = shift;
  $extracted_ls_colors = parse_ls_colors($LS_COLORS);
  ls_color(@_);
}

# Those are the default LS_COLORS mappings from GNU ls
sub ls_color_default {
$LS_COLORS= '
  rs=0:di=01;34:ln=01;36:mh=00:pi=40;33:so=01;35:do=01;35:bd=40;33;01:
  cd=40;33;01:or=40;31;01:mi=00:su=37;41:sg=30;43:ca=30;41:tw=30;42:
  ow=34;42:st=37;44:ex=01;32:*.tar=01;31:*.tgz=01;31:*.arc=01;31:*.arj=01;31:
  *.taz=01;31:*.lha=01;31:*.lz4=01;31:*.lzh=01;31:*.lzma=01;31:*.tlz=01;31:
  *.txz=01;31:*.tzo=01;31:*.t7z=01;31:*.zip=01;31:*.z=01;31:*.dz=01;31:
  *.gz=01;31:*.lrz=01;31:*.lz=01;31:*.lzo=01;31:*.xz=01;31:*.zst=01;31:
  *.tzst=01;31:*.bz2=01;31:*.bz=01;31:*.tbz=01;31:*.tbz2=01;31:*.tz=01;31:
  *.deb=01;31:*.rpm=01;31:*.jar=01;31:*.war=01;31:*.ear=01;31:*.sar=01;31:
  *.rar=01;31:*.alz=01;31:*.ace=01;31:*.zoo=01;31:*.cpio=01;31:*.7z=01;31:
  *.rz=01;31:*.cab=01;31:*.wim=01;31:*.swm=01;31:*.dwm=01;31:*.esd=01;31:
  *.jpg=01;35:*.jpeg=01;35:*.mjpg=01;35:*.mjpeg=01;35:*.gif=01;35:*.bmp=01;35
  :*.pbm=01;35:*.pgm=01;35:*.ppm=01;35:*.tga=01;35:*.xbm=01;35:*.xpm=01;35:
  *.tif=01;35:*.tiff=01;35:*.png=01;35:*.svg=01;35:*.svgz=01;35:*.mng=01;35:
  *.pcx=01;35:*.mov=01;35:*.mpg=01;35:*.mpeg=01;35:*.m2v=01;35:*.mkv=01;35:
  *.webm=01;35:*.ogm=01;35:*.mp4=01;35:*.m4v=01;35:*.mp4v=01;35:*.vob=01;35:
  *.qt=01;35:*.nuv=01;35:*.wmv=01;35:*.asf=01;35:*.rm=01;35:*.rmvb=01;35:
  *.flc=01;35:*.avi=01;35:*.fli=01;35:*.flv=01;35:*.gl=01;35:*.dl=01;35:
  *.xcf=01;35:*.xwd=01;35:*.yuv=01;35:*.cgm=01;35:*.emf=01;35:*.ogv=01;35:
  *.ogx=01;35:*.aac=00;36:*.au=00;36:*.flac=00;36:*.m4a=00;36:*.mid=00;36:
  *.midi=00;36:*.mka=00;36:*.mp3=00;36:*.mpc=00;36:*.ogg=00;36:*.ra=00;36:
  *.wav=00;36:*.oga=00;36:*.opus=00;36:*.spx=00;36:*.xspf=00;36';

  $LS_COLORS =~ s/\n|\s+//g;

  $extracted_ls_colors = parse_ls_colors($LS_COLORS);
  ls_color(@_);
}


# none of the ls_color_* variations are called, so we use the the
# LS_COLORS defined in the environment variable.
$extracted_ls_colors = parse_ls_colors($LS_COLORS);


sub ls_color {
  my @files;

  if(ref($_[0]) eq 'ARRAY') {
    push(@files, @{$_[0]});
    shift @_;
  }
  else {
    push(@files, @_);
  }


  for my $file(@files) {
    chomp $file;
    next if $file =~ m/^\s+$/;
# it's important to keep the dot if there is one. If you remove the dot,
# directories named bin/ can be miscolored given a key like
# *.bin=38;5;220

    my($ext) = $file =~ m/.*([.]+.+)$/;

# since we need to stat files, we need a real filename that's not padded with
# whitespace.

    my $real_file;
    if($file =~ m/^\s+(.+)/) {
      $real_file = $1;
    }
    else {
      $real_file = $file;
    }


# no extension found. let's check file attributes. this will only
# work if called with absolute paths or from ./ since we can't stat files that
# we can't access.
# https://github.com/trapd00r/File-LsColor/issues/1

# ./recup_dir.5/
    -d $real_file and $ext = 'di';

    if(!defined($ext)) {
      -l $real_file and $ext = 'ln'; # symlink
      -x $real_file and $ext = 'ex'; # executable
      -d $real_file and $ext = 'di'; # beware, dirs have +x
      -S $real_file and $ext = 'so'; # socket
      -p $real_file and $ext = 'pi'; # fifo, pipe
      -b $real_file and $ext = 'bd'; # block device
      -c $real_file and $ext = 'ca'; # character special file

# special case for directories that we can't stat, but we can still safely
# assume that they are in fact dirs.

      $real_file =~ m{/$} and $ext = 'di';
    }

    if(!defined($ext)) {
# Since these:
#   Makefile
#   README
#   *Makefile.PL
# are all perfectly valid keys
      $ext = $real_file;
    }

    if(exists($extracted_ls_colors->{$real_file})) {
      $file = fg($extracted_ls_colors->{$real_file}, $file);
    }
    elsif(exists($extracted_ls_colors->{$ext})) {
      $file = fg($extracted_ls_colors->{$ext}, $file);
    }
    else {
#      $file = fg(32, $file);
    }
  }
  return wantarray() ? @files : join('', @files);
}


sub get_ls_colors {
  return parse_ls_colors()
}


sub parse_ls_colors {
  if(@_) {
    $LS_COLORS = shift @_;
  }

  if( (!defined($LS_COLORS)) or ($LS_COLORS eq '') ) {
    croak("LS_COLORS variable not set! Nothing to do...\n");
  }
# *.flac=38;5;196
  my @entities =  split(/:/, $LS_COLORS);

  my %ft;
  for my $ent(@entities) {
# account for:
#   *.flac - but keep the dot in the extension
#   *MANIFEST
    my ($filetype, $attributes) = $ent =~ m/[*]*(.?\S+)=([\d;]+|target)/;
#    print "extracted ft: $filetype | attr: $attributes\n";
    $ft{$filetype} = $attributes;
  }

# if symlink value is target, we use the target key's value
#  if($ft{ln} eq 'target') {
#    $ft{ln} = $ft{target};
#  }

# account for:
#  *.flac
#  *MANIFEST
  return \%ft;
}

sub can_ls_color {
  my $ft = shift;
  my $table = get_ls_colors();

  $ft =~ s/^\s+//;


# if called with an extension that exists, return it.
  return $table->{$ft} if $table->{$ft};
  return $table->{".$ft"} if $table->{".$ft"};

# else, check if called with a filename.ext
# return undef if all else fails
  {
    no warnings;
    my($ext) = $ft =~ m/^.*\.(.+)$/m;
    return $table->{$ext} ? $table->{$ext} : undef;
  }
}


1;


__END__

=pod

=head1 NAME

File::LsColor - Colorize input filenames just like ls does

=head1 SYNOPSIS

    use File::LsColor qw(:all);
    # Is equal to:
    use File::LsColor qw(
      ls_color
      ls_color_custom
      ls_color_default
      ls_color_internal
      get_ls_colors
      can_ls_color
    );

    my @files = glob("$ENV{HOME}/*");

    print "$_\n" for ls_color @files;

    # or specify own pattern

    @files = ls_color_custom('*.pl=38;5;196;1:*.pm=38;5;220', @files);

    # or use the internal mappings

    @files = ls_color_internal(@files);

    # or use the defaults (only ANSI colors)

    @files = ls_color_default(@files);


    # returns a hashref with all defined filetypes and their attributes
    my $ls_colors = get_ls_colors();

    # what's the defined attributes for directories?

    my $dir_color = can_ls_color('di');

    # can we apply attributes to this filetype?
    my $filetype = shift;
    printf "%s can be colored.\n" if can_ls_color($filetype);

    # apply terminal color even if we can't use LS_COLORS to do so.
    my $file_with_extension = 'foobar.flac';
    printf "%s looks nice.\n", can_ls_color($file_with_extension)
      ? ls_color($file_with_extension)
      : Term::ExtendedColor::fg(32, $file_with_extension);


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

Returns:   @files | @files

Returns a list of filenames colored as specified by the environment C<LS_COLORS>
variable. If the C<LS_COLORS> variable is not set, throws an exception.
In this case, C<ls_color_internal()> can be used.

In scalar context a string joined by '' is returned.

=head2 ls_color_default()

The same thing as C<ls_color()>, but uses the default LS_COLORS values from GNU
ls. Those are only ANSI colors.

=head2 ls_color_internal()

The same as C<ls_color()>, with one minor difference; Instead of using the
LS_COLORS variable from the environment, an internal specification is used.
This specification contains about 250 extensions as of this writing.

=head2 ls_color_custom()

The first argument to C<ls_color_custom()> should be a valid LS_COLORS
definition, like so:

  ls_color_custom("*.pl=38;5;196:*.pm=38;5;197;1", @perl_files);

=head2 get_ls_colors()

Returns a hash reference where a key is the extension and its value is the
attributes attached to it.

=head2 can_ls_color()

Arguments: $file
Returns:   $attributes

Given a valid name, returns the defined attributes associated with it.
Else, returns undef.

=head2 ls_color_lookup()

The same as can_ls_color(), exportable because of compatibility reasons.

=head2 parse_ls_colors()
  Arguments: $string
  Returns:   \%hash

Returns a hashref with extension => attribute mappings, i.e:

    '7z'  => '01;31',
    'aac' => '00;36',
    'ace' => '01;31',
    'anx' => '01;35',
    'arj' => '01;31',

=head1 AUTHOR

  Magnus Woldrich
  CPAN ID: WOLDRICH
  m@japh.se
  http://japh.se
  https://github.com/trapd00r

=head1 REPORTING BUGS

Report bugs on L<https://github.com/trapd00r/File-LsColor> or to m@japh.se

=head1 CONTRIBUTORS

None required yet.

=head1 COPYRIGHT

Copyright 2011, 2018, 2019- the B<File::LsColor> L</AUTHOR> and
L</CONTRIBUTORS> as listed above.

=head1 LICENSE

This library is free software; you may redistribute it and/or modify it under
the same terms as Perl itself.

=cut

# vim: ft=perl:fdm=marker:fmr=#<,#>:fen:et:sw=2:
