#!/bin/sh
perl -MFile::LsColor -E 'say "> File::LsColor v" .$File::LsColor::VERSION'
for x in lsc-*.sh; do sh $x; done
