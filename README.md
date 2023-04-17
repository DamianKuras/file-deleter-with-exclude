# file-deleter-with-exclude

file_deleter_with_exclude.sh is a bash script that helps delete files recursively from 'directory' with option to add exclude file and other options. Display list of all files that will be deleted and prompt for confirmation. Display user-friendly error messages.

## Installation

Download the file_deleter_with_exclude.sh script from the repository.
Make the script executable with the command chmod +x file_deleter_with_exclude.sh

## Usage
Usage: ./file-deleter-with-exclude.sh [-h] [-m [+|-]modified_days] [-a [+|-]accessed_days] [-c [+|-]created_days] [-e exclude_file] <directory>

to delete files in
/logs
using exclude files located in /Excludes/exclude.txt
./file-deleter-with-exclude.sh -e ./Excludes/exclude.txt ./logs
Before deleting you will get list of files to delete with prompt

```
The following files will be deleted:
./logs/log123.txt
./logs/log234.txt
Are you sure you want to delete these files? (y/n)
```
## Exclude file
The exclude_file option allows you to specify a file that contains a list of patterns to exclude for deletion.
The file should contain one pattern per line, in the following format:
- A path to match files in a specific directory, e.g. '/path/to/mydir/*'
- A global pattern to match multiple files, e.g. '*.log'

Patterns are matched using the 'find' command, so they must follow the same syntax as find's -path options.
To use the exclude_file option, specify the path to the file after the -e option, e.g.:
file-deleter-with-exclude -e /path/to/exclude.txt /path/to/directory"
Example: to exclude all files in the '/tmp' directory and files with the '.bak' extension, create a file called 'exclude.txt' with the following contents:
```
/tmp/*
*.bak
```


## Optional Argurments

* [-h]  display help message
* [-i]  display help message for the exclude file
* [-m] modified_days  delete files modified n days ago (use +n for files modified more than n days ago, -n for less than n days ago)
* [-a] accessed_days  delete files accessed n days ago (use +n for files accessed more than n days ago, -n for less than n days ago)
* [-c] created_days   delete files created n days ago (use +n for files created more than n days ago, -n for less than n days ago)
* [-e] exclude_file   specify a file containing a list of patterns to exclude for deletion


## License

This script is licensed under the MIT License.

## Testing

The `file-deleter-with-exclude.sh` script includes a unit tests implemented with Shunit2. To run the tests, make sure Shunit2 is installed and run the following script in script folder:
./tests/test-file-deleter-with-exclude.sh

The tests will validate "file-deleter-with-exclude" as well as the `check_number`, `check_exclude_file`, and `deleter_script` functions defined in `deleter-functions.sh`. These tests verify that the script can correctly handle valid and invalid input, correctly parse exclude rules, and correctly delete files in a specified directory.

Note that the tests will generate temporary files and directories during execution, which will be deleted upon completion.
