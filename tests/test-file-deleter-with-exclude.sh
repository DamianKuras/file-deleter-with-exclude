#!/bin/bash
#
#Purpose:      Unit test for file-deleter-with-exlcude script
#Author:       Damian Kuraś <https://github.com/DamianKuras>
#Date:         April 17 2023
#Release:      1.0.0
# file: file-deleter-with-exclude.sh
source "./deleter-functions.sh"
script_under_test="./file-deleter-with-exclude.sh"

#Function to test the check_number function from deleter_functions
test_check_number() {
  # Test case with valid number without sign
  check_number 10 "test value"
  assertEquals "Should return 0 for valid number without sign" 0 $?

  # Test case with valin negative number
  check_number -5 "test value"
  assertEquals "Should return 0 for valid negative number" 0 $?

  # Test case with valid positive number
  check_number +7 "test value"
  assertEquals "Should return 0 for valid positive number" 0 $?

  # Test case with invalid value (not a number)
  check_number "not a number" "test value" 2>/dev/null
  assertNotEquals "Should return non-zero for invalid value not a number" 0 $?

  # Test case with invalid value (double sign)
  check_number "++50" "test value" 2>/dev/null
  assertNotEquals "Should return non-zero for invalid value double sign" 0 $?
}

#Function to test the check_exclude_file function from deleter_functions
test_check_exclude_file() {
  tmp_exclude_file="tmp_exclude_file.txt"

  # Test case with incorrectly formated exclude_file
  echo "rule one
  rule two" >"$tmp_exclude_file"
  check_exclude_file "$tmp_exclude_file" 2>/dev/null
  assertNotEquals "Should return non-zero for incorrectly formated exclude_file" 0 $?
  rm -f "$tmp_exclude_file"

  # Test case with exclude_file not existing file
  check_exclude_file "nonexistent_file.txt" 2>/dev/null
  assertNotEquals "Should return non-zero for non existent exclude_file" 0 $?

  # Test case with valid rule in exclude_file
  echo "rule_one" >"$tmp_exclude_file"
  check_exclude_file "$tmp_exclude_file" # valid rule
  assertEquals "Should return 0 for valid rule in exclude file" 0 $?
  rm -f "$tmp_exclude_file"

  # Test case with valid multiple rules in exclude_file
  echo "rule_one" >"$tmp_exclude_file"
  echo "rule_two" >"$tmp_exclude_file"
  echo "rule_three" >"$tmp_exclude_file"
  check_exclude_file "$tmp_exclude_file"
  assertEquals "Should return 0 for valid multiple rules in exclude_file" 0 $?
  rm -f "$tmp_exclude_file"
}

#test main script file
test_file_deleter_script() {
  tmp_dir="temp_test_dir"
  tmp_file_1="temp_test_file_1.txt"
  tmp_file_2="temp_test_file_2.txt"
  tmp_file_3="temp_test_file_3.txt"
  tmp_file_4="temp_test_file_4.txt"

  # Test case where no arguments are provided
  output=$($script_under_test 2>&1)
  assertEquals "Directory not provided" "$output"

  # Test case where directory provided doesn't exist
  output=$($script_under_test "nonexistent_dir" 2>&1)
  assertEquals "directory nonexistent_dir doesn't exist" "$output"

  # Test case where no files match the provided criteria
  mkdir "$tmp_dir"
  output=$($script_under_test "$tmp_dir")
  assertEquals "No files to delete" "$output"
  rm -r "$tmp_dir"

  # Test case where files are found and confirmation is given and files are deleted
  mkdir "$tmp_dir"
  touch "${tmp_dir}/${tmp_file_1}"
  touch "${tmp_dir}/${tmp_file_2}"
  output=$($script_under_test -m -1 "$tmp_dir" <<<"y")
  expected_output=$(
    cat <<EOF
The following files will be deleted:
$tmp_dir/$tmp_file_1
$tmp_dir/$tmp_file_2
Files deleted
EOF
  )
  assertEquals "$expected_output" "$output"
  assertTrue "Files should be deleted after removing" "test ! -f ${tmp_dir}/${tmp_file_1} && test ! -f ${tmp_dir}/${tmp_file_2}"
  rm -r "$tmp_dir"

  # Test case where files are found but confirmation is not given and files are not deleted
  mkdir "$tmp_dir"
  touch "${tmp_dir}/${tmp_file_1}"
  touch "${tmp_dir}/${tmp_file_2}"
  output=$($script_under_test -m -1 "$tmp_dir" <<<"n")
  expected_output=$(
    cat <<EOF
The following files will be deleted:
$tmp_dir/$tmp_file_1
$tmp_dir/$tmp_file_2
Deletion aborted
EOF
  )
  assertEquals "$expected_output" "$output"
  assertTrue "Files should not be deleted after not giving confirmation" "test -f ${tmp_dir}/${tmp_file_1} && test -f ${tmp_dir}/${tmp_file_2}"
  rm -r "$tmp_dir"

  # Test case where exclude file is provided and files should be ignored
  mkdir "$tmp_dir"
  touch "${tmp_dir}/${tmp_file_1}"
  echo "*/$tmp_file_1" >$tmp_dir/$tmp_file_1
  output=$($script_under_test -e "$tmp_dir/$tmp_file_1" "$tmp_dir")
  assertEquals "No files to delete" "$output"
  rm -r "$tmp_dir"

  # Test case where exclude file with multiple rules is provided and some files should be ignored
  mkdir "$tmp_dir"
  touch "${tmp_dir}/${tmp_file_1}"
  touch "${tmp_dir}/${tmp_file_2}"
  touch "${tmp_dir}/${tmp_file_3}"
  touch "${tmp_dir}/${tmp_file_4}"
  echo "*$tmp_file_2" >$tmp_dir/$tmp_file_1
  echo "*$tmp_file_3" >>$tmp_dir/$tmp_file_1
  output=$($script_under_test -e "$tmp_dir/$tmp_file_1" "$tmp_dir" <<<"y")
  expected_output=$(
    cat <<EOF
The following files will be deleted:
$tmp_dir/$tmp_file_4
Files deleted
EOF
  )
  assertEquals "$expected_output" "$output"
  rm -r "$tmp_dir"

}

# Load shUnit2.
. shunit2
