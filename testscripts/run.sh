#!/bin/sh
perl -MFile::LsColor -E 'say " \e[4mFile::LsColor v" . $File::LsColor::VERSION . "\e[m"'
for x in lsc-*.sh; do sh $x; echo; done
