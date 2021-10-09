#!/bin/sh
printf  "> default LSCOLORS\n"
for x in /a/longer/path/file.flac Makefile{,.PL} foo.{p{l,m},tar,gz,zip,png,mp3,flac,jpg,JPG} dir/ README; do
  echo "$x";
done | ls_color_default
