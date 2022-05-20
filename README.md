# GetDiscogsRelease

## Description
Given a Discogs release id this extracts the corresponding record from the Discogs release file. Exists in both Windows and Linux versions.

## This Repository
The build files are `GetDiscogsRelease.exe` and `fmt.dll` on the Windows side and `GetDiscogsRelease` on the Linux side. These were compiled in Visual Studio 2022. The source C++ and CMake files are also available. The executables are invoked by the PowerShell script `PS_GetDiscogsRelease.ps1` which runs on Windows or Linux. If PowerShell is not available in Linux the bash script `AB_GetDiscogsRelease.sh` may be used instead.

## Input
Discogs release files are found at [Discogs Data](http://data.discogs.com/). The input file for this process is the unzipped Discogs release file, typically named `discogs_release_yyyymmdd.xml`. The file is assumed to be a valid .xml file in which all necessary tags are assumed to exist and to be well-formed. The release ids are assumed to be unique and in increasing order and not longer than 10 digits. These assumptions are not validated by this process.

Each release in the Discogs database has its own webpage whose url has the form `discogs.com/release/n-...` where `n` is the release id. The id is also displayed at the top right of the page with the label Release. Note that the id is a numeric identifier not a database position: id 100 does not mean the 100<sup>th</sup> record in the database. The contents of the release record are the underlying xml data which the page displays. 

## Output
The release record for id `n` consists of the data between (and including) the tags `<release id="n">` and the subsequent `</release>`. This is written to a file named `discogs_ID_n.xml`.

## Installation
The user need only copy the set of source files to whatever folder they choose. In Windows this set consists of the files `GetDiscogsRelease.exe`, `fmt.dll` and `PS_GetDiscogsRelease.ps1`. In Linux the files are `GetDiscogsRelease` and either or both of `PS_GetDiscogsRelease.ps1` and `AB_GetDiscogsRelease.sh`. The files must all reside in the same folder. The file root name GetDiscogsRelease may be changed by the user but must be the same for script and build files (e.g. `abc.exe` and `PS_abc.ps1`). Neither file extensions nor prefixes ("PS_" or "AB_") may be changed; `fmt.dll` may not be renamed.

## Operation
The PowerShell script `PS_GetDiscogsRelease.ps1` parses and validates its arguments which are then passed to the executable. It is possible to invoke the executable directly, but this is not recommended as the user is then solely responsible for ensuring that the arguments are valid and passed in the correct order. The argument syntax for the PowerShell script follows the PowerShell conventions, so optional arguments may be entered in any order or may be omitted. Help for the script is available via `Get-Help` or by supplying the `-?` argument. The Common Parameter `-v` (verbose) is also available and displays the full output folder path.

## Arguments
The PowerShell script takes 8 arguments. The first 2 are mandatory and positional. The last 6 are optional. Positional arguments in PowerShell do not need to be preceded by the parameter name (e.g. `-input_file` or `-i`) but if both parameter names are omitted then `input_file` must precede `release_id`.

input_file 		The discogs release file (full path including the file name). 
release_id 		The id of the release record to be extracted.

output_folder 		Omit to have the output file in the same folder as the script. Include to specify a different path to the output file.
write_mode 		Omit if the output file does not already exist. Include if the file exists, to specify append or overwrite options.
size_block		Omit to use the default block size for reading from the file. Include to specify a different value.
bisection_search	Omit to base the search method on linear interpolation. Include to use interval bisection.
detailed_output		Omit to suppress the display of the intermediate id intervals produced by the search method. Include to display.
no_check 		Omit to validate that the script and executable are in the same folder. Include to skip this check.

In most cases it will be preferable simply to omit all 6 optional arguments (possibly excepting the output_folder).

## Script functionality
The script performs type checking on the arguments and also validates the following:
 - input_file (including the full pathname) must exist.
 - release_id must be a positive integer.
 - output_folder must be a valid path not including a file name.
 - output folder must end in a backslash (if not the script adds it).
 - write_mode must have value 'a' or 'o' (append or overwrite) if it exists.
 - size_block must have an integer value ranging from 18 to 24. The default is 18. 

The 3 arguments bisection_search, detailed_output and no_check are PowerShell switch parameters, which take the values true if included and false if omitted. The bisection_search and detailed_output are converted from their boolean values to string values to be passed to the executable (e.g. boolean true becomes the string 'true'). The script validates that it itself and the executable (and fmt.dll if we are in Windows) are in the same folder (this is skipped if no_check is included).

If the output file does not exist then write-mode is not required by the script. The executable will create an output file with the name discogs_ID_n.xml where n is the requested id. If the output file already exists then write_mode is required by the script. The only admissible values are 'a' for append or 'o' for overwrite.

Once the arguments have been parsed and validated the executable is called. The script passes all arguments other than no_check to the executable in the correct order. The script displays on screen the call to the executable along with the arguments. (If the user chooses to call the executable directly they must conform to this format). The call is then run. If the executable succeeds it returns zero and otherwise a non-zero value. This value is stored in the PowerShell variable $LASTEXITCODE.

## AB_GetDiscogs.sh
If PowerShell is not available in Linux this script may be used instead. It was generated by argbash, with some additional validation code at the end. It uses the same argument names as the PowerShell script and attempts to replicate the functionality. The executable exit code may be retrieved from the Linux variable $? but only immediately after the script has run.
 
## Executable functionality
The executable reads the arguments as a C++ argv[] argument array. No validation of the arguments is performed. Because of the size of the input file it must be read in blocks. A block must be large enough to contain a complete record, which is ensured if the block size is twice that of the longest record in the file. The longest record in the file is currently around 68,000 characters, so the block size must be greater than 136,000. The block size is given by 2^size_block, so for the default value of 18 this is 2^18 = 262,144. The default should be adequate, but if not size_block is allowed to be as large as 24, corresponding to a block size of 2^24 =  16,777,216.

The program reads in the block at the start of the file and records the first id. It then reads backwards from the end of the file and finds the last id. These ids define the first search interval. The program then generates successive search intervals such that the first id is less than or equal to the search id and the last id is greater than or equal to the search id. If the search id matches an endpoint id then the search is over. Otherwise a new smaller interval is created. This continues until either the search id is found or it is shown that it is not in the file. A new search interval is created using either linear interpolat`ion based on the id values or bisection (which typically requires two to three times as many steps as linear interpolation). If the search id is found the corresponding release record is written to the output file. If the detailed_output flag is included then all the search intervals are displayed on the screen.

## Error codes
The following non-zero codes may be returned:
10	Failed to open input file.
20	Id not in the id range given by the input file (includes the file containing no releases).
30	Id not found in the input file.
40	Release record for id not complete (no closing tag).
50	Failed to open output file.