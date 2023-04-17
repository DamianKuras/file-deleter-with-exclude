#!/bin/bash
#
#Purpose:      Functions used by deleter script
#Author:       Damian Kuraś <https://github.com/DamianKuras>
#Date:         April 16 2023
#Release:      1.0.0

#Check if argument is a number with optional sign
#Arguments:
# $1 number
# $2 number variable name for error message
function check_number() {
  local value="$1"
  local name="$2"
  local sign=${value:0:1}

  # Check for sign at the beginning of the value and remove it
  if [[ "$sign" == "+" || "$sign" == "-" ]]; then
    local days="${value:1}"
    local operator="$sign"
  else
    local days="$value"
    local operator=""
  fi

  # Check if the value is a number
  if ! [[ "$days" =~ ^[0-9]+$ ]]; then
    echoerr "Invalid '$name' value: '$value'. Must be number, with optional sign."
    return 1
  fi
  return 0


  echo "$operator$time_option"
}

#Check if exclude file exist and is correctly formated and readable
#Arguments:
# $1 exclude_file
function check_exclude_file() {
  # Check if file exists
  if [[ ! -e "$1" ]]; then
    echoerr "Exclude_file "$1" doesn't exist."
    return 1
  # Check if file is readable
  fi
  if [[ ! -r "$1" ]]; then
    echoerr "You don't have read privileges to open "$1"."
    return 1
  fi
  # Check if file is formatted correctly
  while read line || [[ -n "$line" ]]; do
    if [[ ! "$line" =~ ^[^[:space:]]+$ ]]; then
      echoerr "File exclude_file contains more than one rule per line or they are incorrectly formatted."
      return 1
    fi
  done <"$1"
  return 0
}

#echo to stderr
echoerr() { echo "$@" 1>&2; }
