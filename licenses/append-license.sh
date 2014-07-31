#!/bin/bash 
# Standard input: one line per file to append license to
# First arg: file to put at top

set -e

hdr=$1

while read file
do
  echo "Processing $file"
  cat $hdr $file > ${file}.tmp
  mv ${file}.tmp $file
done
