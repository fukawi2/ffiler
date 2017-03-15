#!/bin/bash

###############################################################################
# Copyright (C) 2015 Phillip Smith
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
###############################################################################

set -eu

bomb() {
  echo "BOMBS AWAY: $1" >&2
  exit 1;
}

usage() {
  printf 'Usage: %s [options] file1 file2 fileN\n' "$0"
  printf 'File filer; sort files into a structured directory tree.\n'
  printf 'Example: %s -sm -dm file.txt\n\n' "$0"
  printf 'Options:\n'
  printf '   %-10s %-50s\n' \
    '-s X' 'Filing structure to use. X can be one of:' \
    ''     'm = File by modified timestamp of file' \
    ''     's = File by first X chars of the md5 hash of the file name (faster than -S)' \
    ''     'S = File by first X chars of the md5 hash of the file contents (slow)' \
    ''     'f = File by first X chars of file name (eg, -f3 a/f/i/afile.txt)' \
    ''     't = File by mime-type of file (eg, image/jpeg)' \
    '-d NUM' 'Depth of tree structure (see documentation)' \
    '-o /path/' 'Output directory for sorted files (eg /mnt/archive/' \
    '-r'   'Recurse into directories' \
    '-M'   'Move files into tree structure (This is the default)'  \
    '-C'   'Copy files into tree structure'  \
    '-L'   'Symbolic link files into tree structure'  \
    '-H'   'Hard link files into tree structure'  \
    '-v'   'Verbose output' \
    '-n'   'Dry run only (do not touch files; implies -v)' \
    '-h'   'This help'
}

dirsplitfilename() {
  string=$1
  depth=$2
  output=
  for ((X=0; X < $depth; X++)) ; do
    char=${string:$X:1}
    # replace non-alphanumeric with an underscore
    if [[ ! $char =~ [A-Za-z0-9] ]] ; then
      char=_
    fi
    output="${output}${char}/"
  done
  echo "$output"
}
appendtrailingslash() {
  str="$1"

  # dont append a slash to a blank string; very important!!!!
  [[ -z "$str" ]] && return

  length=${#str}
  last_char=${str:length-1:1}
  [[ $last_char != "/" ]] && str="$str/"
  echo "$str"
}
process_file() {
  local _fname="$1"
  local _file_method="$2"
  local _file_depth="$3"
  local _action="$4"
  local _output_path="$5"

  # strip any leading path from the file name
  base_fname=${_fname##*/}

  # find the canonical path for the file
  canon_fname=$(readlink --canonicalize "$_fname")

  # get the file modified timestamp in epoch format
  mod_tz_epoch=$(stat --format=%Y "$_fname")

  # work out the destination path for this file
  declare destdir=''
  case $_file_method in
    m)
      case $_file_depth in
        y) destdir=$(date --date=@${mod_tz_epoch} +%Y/)                   ;;
        m) destdir=$(date --date=@${mod_tz_epoch} +%Y/%m-%b/)             ;;
        d) destdir=$(date --date=@${mod_tz_epoch} +%Y/%m-%b/%d/)          ;;
        H) destdir=$(date --date=@${mod_tz_epoch} +%Y/%m-%b/%d/%H/)       ;;
        M) destdir=$(date --date=@${mod_tz_epoch} +%Y/%m-%b/%d/%H/%M/)    ;;
        S) destdir=$(date --date=@${mod_tz_epoch} +%Y/%m-%b/%d/%H/%M/%S)  ;;
      esac ;;
    s) md5hash=$(printf '%s' "$base_fname" | md5sum | awk '{ print $1 }')
       destdir=$(dirsplitfilename "$md5hash" $_file_depth)      ;;
    S) md5hash=$(md5sum "$_fname" | awk '{ print $1 }')
       destdir=$(dirsplitfilename "$md5hash" $_file_depth)      ;;
    f) destdir=$(dirsplitfilename "$base_fname" $_file_depth)   ;;
    t) destdir=$(file --brief --mime-type "$_fname")           ;;
  esac

  # prepend $output_path so we don't write to the cwd
  destdir="$(printf '%s%s' "$_output_path" "$destdir")"
  if [[ ! -d "$destdir" ]] ; then
    [[ -n $verbose ]] && printf 'Create destination: %s\n' "$destdir"
    [[ -z $dry_run ]] && mkdir -p "$destdir"
  fi

  # give feedback
  if [[ -n $verbose ]] ; then
    case $_action in
      m) printf '[Move] %s  =>  %s\n' "$_fname" "$destdir" ;;
      c) printf '[Copy] %s  =>  %s\n' "$_fname" "$destdir" ;;
      l) printf '[Symlink] %s  =>  %s\n' "$_fname" "$destdir" ;;
      h) printf '[Hardlink] %s  =>  %s\n' "$_fname" "$destdir" ;;
    esac
  fi

  # do the action
  if [[ -z $dry_run ]] ; then
    case $_action in
      m) mv -f "$_fname" "$destdir" ;;
      c) cp -f "$_fname" "$destdir" ;;
      l) ln -f --symbolic "$canon_fname" "$destdir" ;;
      h) ln -f "$_fname" "$destdir" ;;
  esac
  fi
}

### Global Variables
declare verbose=
declare dry_run=

### Main Code
main() {
  declare file_method=undefined
  declare file_depth=
  declare output_path=
  declare action=m
  declare recurse=

  ### fetch our cmdline options
  while getopts ":hs:d:o:rMCLHvn" opt; do
    case $opt in
      s)  file_method=$OPTARG ;;
      d)  file_depth=$OPTARG  ;;
      o)  output_path="$(appendtrailingslash "$OPTARG")" ;;
      r)  recurse=yes         ;;  # recurse into directories
      M)  action=m            ;;  # action == move
      C)  action=c            ;;  # action == copy
      L)  action=l            ;;  # action == sym-link
      H)  action=h            ;;  # action == hard-link
      n)  dry_run=1
          verbose=1           ;;
      v)  verbose=1           ;;
      h)  usage
          exit 0              ;;
      \?) echo "ERROR: Invalid option: -$OPTARG" >&2
          usage
          exit 1              ;;
      :)  echo "ERROR: Option -$OPTARG requires an argument." >&2
          exit 1              ;;
      esac
  done
  shift $((OPTIND-1))

  # make these vars readonly to prevent accidentally changing them beyond this point
  readonly file_method file_depth output_path action dry_run verbose

  # validate user input
  [[ ! $file_method =~ ^[msSft]$ ]] && { bomb "Invalid filing method: $file_method"; }
  if [[ $file_method == 'm' ]] ; then
    # depth is the timestamp granularity: ymdHMS
    [[ ! $file_depth =~ ^[ymdHMS]$ ]] && { bomb "Invalid tree depth: $file_depth"; }
  elif [[ $file_method =~ ^[Ssf]$ ]] ; then
    # depth is a number
    [[ ! $file_depth =~ ^[0-9]+$ ]] && { bomb "Invalid tree depth: $file_depth"; }
  fi

  # validate $output_path
  if [[ -n "$output_path" ]] ; then
    [[ -n $verbose ]] && printf 'Output path: %s\n' "$output_path"
    [[ ! -d "$output_path" ]] && mkdir -p "$output_path"
  fi

  # loop over the remaining command line arguments as files/directories
  for X in "$@" ; do
    fname="${1:-}"
    shift

    # is it blank?
    [[ -z "$fname" ]]   && { usage; exit -1; }

    # is it a directory?
    if [[ -d "$fname" ]] ; then
      if [[ -z "$recurse" ]] ; then
        # this is a directory, but user has not asked us to recurse
        printf 'Skipping directory: %s\n' "$fname"
        continue
      else
        # a directory, and the user wants us to recurse!
        # TODO: this is not proper recursion, but I'm in a rush today
        # this needs to actually descend into child directories
        cd "$fname"
        for C in $(ls "$fname/") ; do
          [[ ! -f "$C" ]] && continue
          process_file "$C" "$file_method" "$file_depth" "$action" "$output_path"
        done
      fi
    else
      # is it a file?
      [[ ! -f "$fname" ]] && { bomb "File not found: $fname"; }
      process_file "$fname" "$file_method" "$file_depth" "$action" "$output_path"
    fi
  done
}

main $@
exit 0
