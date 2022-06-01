#!/bin/bash

# Created by argbash-init v2.10.0
# ARG_OPTIONAL_SINGLE([output_folder],[o],[Optional. The folder to which the release record is written. If not supplied the release record is written to the folder where this script resides. If supplied it must exist and be a valid folder name, ending in a backslash, and may not include a file name. The executable creates a file name for the record of the form discogs_ID_n.xml where n is the release id.],[])
# ARG_OPTIONAL_SINGLE([write_mode],[w],[Optional. If the output file already exists then write_mode must be supplied and may have values 'a' or 'o' to tell the executable to append to or overwrite the output file. If the output file does not exist then write-mode has no effect and may be omitted.],[])
# ARG_OPTIONAL_SINGLE([size_block],[s],[Optional. Because the input file is too large to hold in memory the executable reads data in blocks. The block size must be greater than the twice the length of the longest record in the file (currently around 825 KB). The block size in bytes is 2^size_block, so for the default value of 23 this is 8 MiB. The minimum allowed is 21; the maximum is 30.],[23])
# ARG_OPTIONAL_BOOLEAN([bisection_search],[b],[Switch parameter. If omitted the executable uses linear interpolation to find the requested release record. If included it uses the (slower) bisection search.],[])
# ARG_OPTIONAL_BOOLEAN([detailed_output],[d],[Switch parameter. If included then extra output is produced. This displays the id intervals in which the executable searches for the requested id.],[])
# ARG_OPTIONAL_BOOLEAN([no_check],[n],[Switch parameter. If omitted the script checks whether the executable and any other required files are in the same directory as this script. If included then the check is skipped.],[])
# ARG_POSITIONAL_SINGLE([input_file],[Mandatory. The Discogs xml file from which the particular release record is sought. Must be a complete path including the filename and extension. Positional (position 1).],[])
# ARG_POSITIONAL_SINGLE([release_id],[Mandatory. The release id of the requested discogs release. Must be a positive integer. Positional (position 2; so must follow the input file).],[])
# ARG_TYPE_GROUP([pint],[r],[release_id])
# ARG_TYPE_GROUP_SET([w],[w],[write_mode],[a,o])
# ARG_TYPE_GROUP_SET([s],[s],[size_block],[21, 22, 23, 24, 25, 26, 27, 28, 29, 30])
# ARG_DEFAULTS_POS([])
# ARG_HELP([Argbash-based argument parsing script for GetDiscogsRelease executable.])
# ARG_VERBOSE([v])
# ARG_VERSION_AUTO([_ARGBASH_VERSION],[],[],[version],[])
# ARGBASH_GO()
# needed because of Argbash --> m4_ignore([
### START OF CODE GENERATED BY Argbash v2.10.0 one line above ###
# Argbash is a bash code generator used to get arguments parsing right.
# Argbash is FREE SOFTWARE, see https://argbash.io for more info


set -euo pipefail  # This line added manually. Skipping -x which prints every executed command to the screen.


die()
{
	local _ret="${2:-1}"
	test "${_PRINT_HELP:-no}" = yes && print_help >&2
	echo "$1" >&2
	exit "${_ret}"
}

# validators

pint()
{
	printf "%s" "$1" | grep -q '^\s*[+]\?0*[1-9][0-9]*\s*$' || die "The value of argument '$2' is '$1', which is not a positive integer."
	printf "%d" "$1"
}


w()
{
	local _allowed=("a" "o") _seeking="$1"
	for element in "${_allowed[@]}"
	do
		test "$element" = "$_seeking" && echo "$element" && return 0
	done
	die "Value '$_seeking' (of argument '$2') doesn't match the list of allowed values: 'a' and 'o'" 4
}


s()
{
	local _allowed=("21" "22" "23" "24" "25" "26" "27" "28" "29" "30") _seeking="$1"
	for element in "${_allowed[@]}"
	do
		test "$element" = "$_seeking" && echo "$element" && return 0
	done
	die "Value '$_seeking' (of argument '$2') doesn't match the list of allowed values: '21', '22', '23', '24', '25', '26', '27', '28', '29' and '30'" 4
}


begins_with_short_option()
{
	local first_option all_short_options='owsbdnhv'
	first_option="${1:0:1}"
	test "$all_short_options" = "${all_short_options/$first_option/}" && return 1 || return 0
}

# THE DEFAULTS INITIALIZATION - POSITIONALS
_positionals=()
_arg_input_file=
_arg_release_id=
# THE DEFAULTS INITIALIZATION - OPTIONALS
_arg_output_folder=
_arg_write_mode=
_arg_size_block="23"
_arg_bisection_search="off"
_arg_detailed_output="off"
_arg_no_check="off"
_arg_verbose=0


print_help()
{
	printf '%s\n' "Argbash-based argument parsing script for GetDiscogsRelease executable."
	printf 'Usage: %s [-o|--output_folder <arg>] [-w|--write_mode <w>] [-s|--size_block <s>] [-b|--(no-)bisection_search] [-d|--(no-)detailed_output] [-n|--(no-)no_check] [-h|--help] [-v|--verbose] [--version] <input_file> <release_id>\n' "$0"
	printf '\t%s\n' "<input_file>: Mandatory. The Discogs xml file from which the particular release record is sought. Must be a complete path including the filename and extension. Positional (position 1)."
	printf '\t%s\n' "<release_id>: Mandatory. The release id of the requested discogs release. Must be a positive integer. Positional (position 2; so must follow the input file)."
	printf '\t%s\n' "-o, --output_folder: Optional. The folder to which the release record is written. If not supplied the release record is written to the folder where this script resides. If supplied it must exist and be a valid folder name, ending in a backslash, and may not include a file name. The executable creates a file name for the record of the form discogs_ID_n.xml where n is the release id. (no default)"
	printf '\t%s\n' "-w, --write_mode: Optional. If the output file already exists then write_mode must be supplied and may have values 'a' or 'o' to tell the executable to append to or overwrite the output file. If the output file does not exist then write-mode has no effect and may be omitted. Can be one of: 'a' and 'o' (no default)"
	printf '\t%s\n' "-s, --size_block: Optional. Because the input file is too large to hold in memory the executable reads data in blocks. The block size must be greater than the twice the length of the longest record in the file (currently around 825 KB). The block size in bytes is 2^size_block, so for the default value of 23 this is 8 MiB. The minimum allowed is 21; the maximum is 30. Can be one of '21', '22', '23', '24', '25', '26', '27', '28', '29' and '30' (default: '23')"
	printf '\t%s\n' "-b, --bisection_search, --no-bisection_search: Switch parameter. If omitted the executable uses linear interpolation to find the requested release record. If included it uses the (slower) bisection search. (off by default)"
	printf '\t%s\n' "-d, --detailed_output, --no-detailed_output: Switch parameter. If included then extra output is produced. This displays the id intervals in which the executable searches for the requested id. (off by default)"
	printf '\t%s\n' "-n, --no_check, --no-no_check: Switch parameter. If omitted the script checks whether the executable and any other required files are in the same directory as this script. If included then the check is skipped. (off by default)"
	printf '\t%s\n' "-h, --help: Prints help"
	printf '\t%s\n' "-v, --verbose: Set verbose output (can be specified multiple times to increase the effect)"
	printf '\t%s\n' "--version: Prints version"
}


parse_commandline()
{
	_positionals_count=0
	while test $# -gt 0
	do
		_key="$1"
		case "$_key" in
			-o|--output_folder)
				test $# -lt 2 && die "Missing value for the optional argument '$_key'." 1
				_arg_output_folder="$2"
				shift
				;;
			--output_folder=*)
				_arg_output_folder="${_key##--output_folder=}"
				;;
			-o*)
				_arg_output_folder="${_key##-o}"
				;;
			-w|--write_mode)
				test $# -lt 2 && die "Missing value for the optional argument '$_key'." 1
				_arg_write_mode="$(w "$2" "write_mode")" || exit 1
				shift
				;;
			--write_mode=*)
				_arg_write_mode="$(w "${_key##--write_mode=}" "write_mode")" || exit 1
				;;
			-w*)
				_arg_write_mode="$(w "${_key##-w}" "write_mode")" || exit 1
				;;
			-s|--size_block)
				test $# -lt 2 && die "Missing value for the optional argument '$_key'." 1
				_arg_size_block="$(s "$2" "size_block")" || exit 1
				shift
				;;
			--size_block=*)
				_arg_size_block="$(s "${_key##--size_block=}" "size_block")" || exit 1
				;;
			-s*)
				_arg_size_block="$(s "${_key##-s}" "size_block")" || exit 1
				;;
			-b|--no-bisection_search|--bisection_search)
				_arg_bisection_search="on"
				test "${1:0:5}" = "--no-" && _arg_bisection_search="off"
				;;
			-b*)
				_arg_bisection_search="on"
				_next="${_key##-b}"
				if test -n "$_next" -a "$_next" != "$_key"
				then
					{ begins_with_short_option "$_next" && shift && set -- "-b" "-${_next}" "$@"; } || die "The short option '$_key' can't be decomposed to ${_key:0:2} and -${_key:2}, because ${_key:0:2} doesn't accept value and '-${_key:2:1}' doesn't correspond to a short option."
				fi
				;;
			-d|--no-detailed_output|--detailed_output)
				_arg_detailed_output="on"
				test "${1:0:5}" = "--no-" && _arg_detailed_output="off"
				;;
			-d*)
				_arg_detailed_output="on"
				_next="${_key##-d}"
				if test -n "$_next" -a "$_next" != "$_key"
				then
					{ begins_with_short_option "$_next" && shift && set -- "-d" "-${_next}" "$@"; } || die "The short option '$_key' can't be decomposed to ${_key:0:2} and -${_key:2}, because ${_key:0:2} doesn't accept value and '-${_key:2:1}' doesn't correspond to a short option."
				fi
				;;
			-n|--no-no_check|--no_check)
				_arg_no_check="on"
				test "${1:0:5}" = "--no-" && _arg_no_check="off"
				;;
			-n*)
				_arg_no_check="on"
				_next="${_key##-n}"
				if test -n "$_next" -a "$_next" != "$_key"
				then
					{ begins_with_short_option "$_next" && shift && set -- "-n" "-${_next}" "$@"; } || die "The short option '$_key' can't be decomposed to ${_key:0:2} and -${_key:2}, because ${_key:0:2} doesn't accept value and '-${_key:2:1}' doesn't correspond to a short option."
				fi
				;;
			-h|--help)
				print_help
				exit 0
				;;
			-h*)
				print_help
				exit 0
				;;
			-v|--verbose)
				_arg_verbose=$((_arg_verbose + 1))
				;;
			-v*)
				_arg_verbose=$((_arg_verbose + 1))
				_next="${_key##-v}"
				if test -n "$_next" -a "$_next" != "$_key"
				then
					{ begins_with_short_option "$_next" && shift && set -- "-v" "-${_next}" "$@"; } || die "The short option '$_key' can't be decomposed to ${_key:0:2} and -${_key:2}, because ${_key:0:2} doesn't accept value and '-${_key:2:1}' doesn't correspond to a short option."
				fi
				;;
			--version)
				printf '%s %s\n\n%s\n' "AB_GetDiscogsRelease.sh" "2.10.0" 'Argbash-based argument parsing script for GetDiscogsRelease executable.'
				exit 0
				;;
			*)
				_last_positional="$1"
				_positionals+=("$_last_positional")
				_positionals_count=$((_positionals_count + 1))
				;;
		esac
		shift
	done
}


handle_passed_args_count()
{
	local _required_args_string="'input_file' and 'release_id'"
	test "${_positionals_count}" -ge 2 || _PRINT_HELP=yes die "FATAL ERROR: Not enough positional arguments - we require exactly 2 (namely: $_required_args_string), but got only ${_positionals_count}." 1
	test "${_positionals_count}" -le 2 || _PRINT_HELP=yes die "FATAL ERROR: There were spurious positional arguments --- we expect exactly 2 (namely: $_required_args_string), but got ${_positionals_count} (the last one was: '${_last_positional}')." 1
}


assign_positional_args()
{
	local _positional_name _shift_for=$1
	_positional_names="_arg_input_file _arg_release_id "

	shift "$_shift_for"
	for _positional_name in ${_positional_names}
	do
		test $# -gt 0 || break
		eval "$_positional_name=\${1}" || die "Error during argument parsing, possibly an Argbash bug." 1
		shift
	done
}

parse_commandline "$@"
handle_passed_args_count
assign_positional_args 1 "${_positionals[@]}"

# OTHER STUFF GENERATED BY Argbash
# Validation of values
_arg_release_id="$(pint "$_arg_release_id" "release_id")" || exit 1


### END OF CODE GENERATED BY Argbash (sortof) ### ])
# [ <-- needed because of Argbash


### ARGUMENT PARSING ###


# Set the executable name to be the name of this script after removing the prefix AB_ and extension .sh
shopt -s extglob
executable_name="$(basename "$0")"
executable_name="${executable_name##*(AB_)}"
executable_name="${executable_name%%*(.sh)}"
executable_path="${0%/*}"
shopt -u extglob


# If the input file is not valid then terminate.
if [[ ! -f "$_arg_input_file" ]]
  then echo -e "\nInput file or path not valid: $_arg_input_file. Process terminated.\n"
  exit
fi


# If the output_folder is not supplied make it the local path (i.e. the path of this script as given by $BASH_SOURCE[0]).
# If the output folder is supplied but is not valid then terminate.
local_folder=$(realpath "$(dirname "${BASH_SOURCE[0]}")")
if [[ -z $_arg_output_folder ]]
  then
    if [[ $_arg_verbose -gt 0 ]] 
      then echo "Output file will be written to folder $local_folder"
	fi
  _arg_output_folder=$local_folder
elif [[ ! -d "$_arg_output_folder" ]]
  then echo -e "\nOutput folder not valid: $_arg_output_folder. Process terminated.\n"
  exit
fi

# Delete leading and trailing whitespaces and trailing / using extglob.
# https://www.cyberciti.biz/faq/bash-remove-whitespace-from-string/
shopt -s extglob
_arg_output_folder="${_arg_output_folder##*( )}"
_arg_output_folder="${_arg_output_folder%%*( )}"
_arg_output_folder="${_arg_output_folder%%*(/)}"
shopt -u extglob

# Ensure the output folder name has a trailing forward slash.
_arg_output_folder+="/"


# Set output file.
output_file="discogs_ID_$_arg_release_id.xml"
output_file_full="$_arg_output_folder$output_file"


# If the output file already exists AND the write_mode argument is not supplied then terminate. Otherwise set the write_mode to 'o' (overwrite).
if [[ -f "$output_file_full" && -z $_arg_write_mode ]]
  then echo -e "\n$output_file already exists in the output folder. write_mode must be 'a' or 'o' (append or overwrite). Process terminated.\n"
  exit
fi
if [[ -z $_arg_write_mode ]]
  then _arg_write_mode="o"
fi


# Convert boolean to string for the executable.
if [[ $_arg_bisection_search == "off"  ]]
  then b="false"
  else b="true"
fi
if [[ $_arg_detailed_output == "off"  ]]
  then d="false"
  else d="true"
fi


# Check that the executable file is found in the same folder as the script. 
# $_arg_no_check = "off" (the default) means the check is carried out.
if [[ $_arg_no_check == "off" ]]
  then if [[ ! -f "$local_folder/$executable_name" ]]
    then echo -e "\nExecutable $executable_name not found in folder $local_folder. Process terminated.\n"
	exit
  fi
fi

if [[ $_arg_verbose -gt 0 ]]
  then
    printf 'Value of --%s: %s\n' 'output_folder' "$_arg_output_folder"
    printf 'Value of --%s: %s\n' 'write_mode' "$_arg_write_mode"
    printf 'Value of --%s: %s\n' 'size_block' "$_arg_size_block"
    printf "'%s' is %s\\n" 'bisection_search' "$_arg_bisection_search"
    printf "'%s' is %s\\n" 'detailed_output' "$_arg_detailed_output"
    printf "'%s' is %s\\n" 'no_check' "$_arg_no_check"
    printf "Value of '%s': %s\\n" 'input_file' "$_arg_input_file"
    printf "Value of '%s': %s\\n" 'release_id' "$_arg_release_id"
    printf "Value of '%s': %s\\n" 'verbose' "$_arg_verbose"
fi

echo -e "\n*** CALLING $executable_name with inputs:   $_arg_input_file   $_arg_output_folder    $_arg_release_id   $_arg_write_mode   $_arg_size_block   $b   $d"

#  Put escaped quotes (\") around input file and output folder names to accomodate possible paths which include white space.
cmd="$executable_path/$executable_name"
cmd=("${cmd[@]}" "\"$_arg_input_file\"" "\"$_arg_output_folder\"" "$_arg_release_id $_arg_write_mode $_arg_size_block $b $d")
eval "${cmd[@]}"

# ^^^  TERMINATE YOUR CODE BEFORE THE BOTTOM ARGBASH MARKER  ^^^

# ] <-- needed because of Argbash