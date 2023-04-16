#!/bin/bash
#
#Purpose:      Delete files recursively from 'directory' with option to add exclude file and other options, display list of all files that will be deleter and prompt for confirmation.
#Author:       Damian Kuraś <https://github.com/DamianKuras>
#Date:         April 16 2023
#Release:      1.0.0

set -o pipefail -e

usage() {
  echo "Usage: $0 [-h]  [-m [+|-]modified_days] [-a [+|-]accessed_days] [-c [+|-]created_days] [-e exclude_file] <directory>"
  echo "  -h                display help message"
  echo "  -i                display help message for the exclude file"
  echo "  -m modified_days  delete files modified n days ago (use +n for files modified more than n days ago, -n for less than n days ago)"
  echo "  -a accessed_days  delete files accessed n days ago (use +n for files accessed more than n days ago, -n for less than n days ago)"
  echo "  -c created_days   delete files created n days ago (use +n for files created more than n days ago, -n for less than n days ago)"
  echo "  -e exclude_file   specify a file containing a list of patterns to exclude for deletion"
 
}
help_exclude_file() {
  echo "The exclude_file option allows you to specify a file that contains a list of patterns to exclude for deletion."
  echo "The file should contain one pattern per line, in the following format:"
  echo "  - A path to match files in a specific directory, e.g. '/path/to/mydir/*'"
  echo "  - A glob pattern to match multiple files, e.g. '*.log'"
  echo "Patterns are matched using the 'find' command, so they must follow the same syntax as find's -path options."
  echo "To use the exclude_file option, specify the path to the file after the -e option, e.g.:"
  echo "  $0 -e /path/to/exclude.txt /path/to/directory"
  echo "Example: to exclude all files in the '/tmp' directory and files with the '.bak' extension, create a file called 'exclude.txt' with the following contents:"
  echo "  /tmp/*"
  echo "  *.bak"
}

if [[ ! -e "deleter-functions.sh" ]]; then
  echo "File 'deleter-functions.sh' not found" 1>&2
  exit 1
fi

if ! source "deleter-functions.sh"; then
  echo "Failed to source 'deleter-functions.sh' file" 1>&2
  exit 1
fi

# Parse command-line options
while getopts "hid:m:a:c:e:" opt; do
  case "${opt}" in
  h)
    usage
    exit 0
    ;;
  i)
    help_exclude_file
    exit 0
    ;;
  m)
    modified_days="${OPTARG}"
    ;;
  a)
    accessed_days="${OPTARG}"
    ;;
  c)
    created_days="${OPTARG}"
    ;;
  e)
    exclude_file="${OPTARG}"
    ;;
  *)
    usage
    ;;
  esac
done

# removes all the options that have been parsed by getopts from the parameters list
# $1 will refer to the first non-option argument passed to the script.
shift "$((OPTIND - 1))"

# Check if directory is provided
if [[ $# -lt 1 ]]; then
  echoerr "Directory not provided"
  exit 1
fi

# Check if directory exists
if [[ ! -e "$1" ]]; then
  echoerr "directory $1 doesn't exist"
  exit 1
fi

find_command=(find "$1" -type f)

#add time options to find command
if [[ -n "$modified_days" ]]; then
  check_number "$modified_days" "modified_days" 
  find_command+=("-mtime" "$modified_days")
fi
if [[ -n "$accessed_days" ]]; then
  check_number "$accesed_days" "accessed_days"
  find_command+=("-atime" "$accesed_days")
fi
if [[ -n "$created_days" ]]; then
  check_number "$created_days" "created_days"
  find_command+=("-ctime" "$created_days")
fi

#protect script from deleting itself
find_command+=(-not -name $(basename "$0") -not -name "deleter-functions.sh")

#protect script from deleting exclude_file if it exists
if [[ -n "$exclude_file" ]]; then
  #check exclude file
  check_exclude_file "$exclude_file"
  find_command+=(-not -name $(basename "$exclude_file"))
  # Add exclude patterns to find command if ignore file is provided and correct
  while read line || [[ -n "$line" ]]; do
    find_command+=(-not -path "$line")
  done <"$exclude_file"
fi

files_to_delete=$("${find_command[@]}")

# If no files found
if [[ -z "$files_to_delete" ]]; then
  echo "No files to delete"
  exit 0
fi

# Print list of files to delete and prompt for confirmation
echo "The following files will be deleted:"
echo "$files_to_delete"
read -p "Are you sure you want to delete these files? (y/n) " answer

# Delete files if confirmed
if [[ "$answer" = "y" ]]; then
  echo "$files_to_delete" | xargs rm -f
  echo "Files deleted"
else
  echo "Deletion aborted"
fi
