# GetDiscogsRelease

## Description
Given a Discogs release id this extracts the corresponding record from the Discogs release file.<br>Exists in both Windows and Linux versions.

## Basic Example
The script is run from a PowerShell environment (open a PowerShell terminal in Windows or type `pwsh` in Linux).<br>The command 

`PS_GetDiscogsRelease.ps1` &emsp; `D:\discogs_release_20220501.xml` &emsp; `1287354`

will extract the record with the given id from the May 2022 release file. The result will be written to a file `discogs_ID_1287354.xml` in the same folder as the PowerShell script.

## Executable and script files 
The executable files are `GetDiscogsRelease.exe` (which requires `fmt.dll`) on the Windows side and `GetDiscogsRelease` on the Linux side. These were compiled in Visual Studio 2022. The source C++ and CMake files are also available.

The executables are invoked by the PowerShell script `PS_GetDiscogsRelease.ps1` which runs on Windows or Linux.<br>If PowerShell is not available in Linux the bash script `AB_GetDiscogsRelease.sh` may be used instead.

## Input
Discogs release files are found at [Discogs Data](http://data.discogs.com/). The input file for the current process is the unzipped Discogs release file, typically named `discogs_release_yyyymmdd.xml`. The file is assumed to be a valid `.xml` file in which all necessary tags are assumed to exist and to be well-formed. The release ids are assumed to be unique and in increasing order and not longer than 10 digits. These assumptions are not validated by the current process.

Each release in the Discogs database has its own webpage with url of the form `discogs.com/release/n-...` where `n` is the release id. The id is also displayed at the top right of the page with the label `Release`. Note that the id is a numeric identifier not a database position: id 100 does not mean the 100<sup>th</sup> record in the database. The contents of the release record are the underlying xml data which the page displays. 

## Output
The release record for id `n` consists of the data between (and including) the tags `<release id="n">` and the subsequent `</release>`. The record is written to a file named `discogs_ID_n.xml`.

## Installation
The user need only copy the executable and script files to whatever folder they choose. 

In Windows this set consists of the files `GetDiscogsRelease.exe`, `fmt.dll` and `PS_GetDiscogsRelease.ps1`.

 In Linux the files are `GetDiscogsRelease` and either of `PS_GetDiscogsRelease.ps1` and `AB_GetDiscogsRelease.sh`. 
 
 The executable and script files must reside in the same folder. The file root name `GetDiscogsRelease` may be changed by the user but must be the same for the executable and script files (e.g. `abc.exe` and `PS_abc.ps1`). Neither file extensions nor prefixes (`PS_` or `AB_`) may be changed; `fmt.dll` may not be renamed.

## Operation
The PowerShell script `PS_GetDiscogsRelease.ps1` parses and validates its arguments which are then passed to the executable. The argument syntax for the script follows the PowerShell conventions. Help is available via `Get-Help` or by supplying the `-?` argument. The Common Parameter `-v` (verbose) is also available and displays the full output folder path if included.

It is possible to invoke the executable directly from the command line, but this is not recommended as the user is then solely responsible for ensuring that the arguments are valid and supplied in the correct order. 

## Arguments
The PowerShell script takes 8 parameters (arguments) of which 2 are mandatory and positional. Positional parameters in PowerShell do not need to be preceded by the parameter name (e.g. `-input_file` or `-i`) but if both parameter names are omitted then the positional order applies so that `input_file` must precede `release_id`.

| Parameter  | Details |
| ---------- | ------- |
| `input_file` | The discogs release file (full path including the file name). |
| `release_id` | The id of the release record to be extracted.                 |

There are 3 optional parameters.

| Parameter  | Details |
| ---------- | ------- |
| `output_folder` | Omit to have the output file in the same folder as the script. Include to specify a different path to the output file.
| `write_mode` | Omit if the output file does not already exist. Include if the file exists, to specify append or overwrite options. |
| `size_block` | Omit to use the default block size for reading from the file. Include to specify a different value. |

Finally there are 3 switch parameters (optional flags).

| Parameter  | Details |
| ---------- | ------- |
| `bisection_search` | Omit to base the search method on linear interpolation. Include to use interval bisection. |
| `detailed_output` | Omit to suppress the display of the intermediate id intervals produced by the search method. Include to display. |
| `no_check` | Omit to validate that the script and executable are in the same folder. Include to skip this check. |

PowerShell switch parameters take the boolean values `true` if included and `false` if omitted. The `bisection_search` and `detailed_output` parameters are converted to string values to be passed to the executable (e.g. boolean `true` is replaced by the string 'true'). 

In most cases it will be preferable simply to omit all 6 optional arguments (possibly excepting `output_folder`).

## Script functionality
The `PS_GetDiscogsRelease.ps1` script performs type checking on the arguments and also validates the following:
 - `input_file` (including the full pathname) must exist.
 - `release_id` must be a positive integer.
 - `output_folder` must be a valid path not including a file name.
 - `output folder` must end in a backslash (if not the script adds it).
 - `write_mode` must have value `a` or `o` (append or overwrite) if it exists.
 - `size_block` must have an integer value between 21 and 40. The default is 23. 

If the output file does not exist then `write_mode` is not required. The executable will create an output file with the name `discogs_ID_n.xml` where `n` is the requested id. If the output file already exists then `write_mode` is  required.

Once the arguments have been parsed and validated the executable is called. The script passes all arguments other than `no_check` to the executable in the required order. The script echoes on screen the call to the executable. (The user wishing to call the executable directly must conform to this format). The call is then run. 

## AB_GetDiscogs.sh
If PowerShell is not available in Linux this bash script may be used instead. It was created using the script generator [argbash](https://github.com/matejak/argbash) with some additional validation code added at the end. It uses the same argument names as the PowerShell script and attempts to replicate its functionality. 
 
## Executable functionality
##### Arguments
The executable reads the arguments as a C++ `argv[]` argument array. No validation of the arguments is performed. 

##### Reading data
Because of the size of the input file it must be read in blocks. A block must be large enough to contain a complete record, which is ensured if it is twice the length of the longest record, currently around 825,000 bytes. So the block size should be greater than 1.65 MiB. The block size is given by 2 <sup>`size_block`</sup>, so for the default value this is 2<sup>23</sup> = 8 MiB. The minimum allowed value for `size_block` is 21, corresponding to a block size of 2<sup>21</sup> =  2 MiB.

##### Search method
The program finds the first and last ids in the file. These endpoint ids define the first search interval. It then finds an intermediate id which is not an endpoint. This defines two subintervals, one of which must bracket the search id. This becomes the new search interval. This process continues until either the search id is found (as an endpoint of a new search interval) or the search id is not an endpoint but the bracketing interval contains no other ids, so the search id is not in the file. New intermediate ids are found using either linear interpolation or bisection (which typically creates more intervals (so is slower) than linear interpolation). If the search id is found the release record is written to the output file. If the `detailed_output` parameter is included then the intermediate search intervals are displayed on the screen.

## Return codes
The non-zero return codes are as follows:
| Error | Description |
| ----- | ----------- |
| `10` |	Failed to open input file. |
| `20` |	Id larger than the largest id in the input file (or no ids in the file). |
| `30` |	Id not found in the input file. |
| `40` |	Release record for id not complete (no closing tag). |
| `50` |	Failed to open output file. |

In PowerShell the executable return code may be retrieved from the variable `$LASTEXITCODE`. 
If the bash script was used in Linux then the executable return code may be retrieved from the Linux variable `$?` but only immediately after the script has run as it will be overwritten by the return code from the next Linux command.