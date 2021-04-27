#!/bin/sh
printf  "environment LSCOLORS\n"
for x in Makefile{,.PL} foo.{p{l,m},tar,gz,zip,png,mp3,flac,jpg,JPG} dir/ README; do
  echo "  $x";
done | ls_color
