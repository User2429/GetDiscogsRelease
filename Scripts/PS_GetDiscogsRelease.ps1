<#
.SYNOPSIS
 A script which parses arguments for and then invokes the executable GetDiscogsRelease.
 Given a Discogs release file and an id the executable extracts the corresponding release record from the file.

.DESCRIPTION
 Arguments for this script follow PowerShell conventions. They are parsed, validated and passed to the executable.
 The executable requires arguments to have a specific form and order and does not validate them. So while it is possible to invoke it directly without this script it is not recommended.

.PARAMETER input_file
 Mandatory. The Discogs xml file from which the particular release record is sought. Must be a complete path including the filename and extension. Positional (position 1).

.PARAMETER release_id
 Mandatory. The release id of the requested discogs release. Must be a positive integer. Positional (position 2; so must follow the input file).

.PARAMETER output_folder
 Optional. The folder to which the release record is written. If not supplied the release record is written to the folder where this script resides.
 If supplied it must exist and be a valid folder name, ending in a backslash, and may not include a file name. The executable creates a file name for the record of the form discogs_ID_n.xml where n is the release id.

 .PARAMETER write_mode
 Optional. If the output file already exists then write_mode must be supplied and may have values 'a' or 'o' to tell the executable to append to or overwrite the output file. If the output file does not exist then write-mode has no effect and may be omitted.

.PARAMETER size_block
 Optional. Because the input file is too large to hold in memory the executable reads data in blocks. A block must be large enough to ensure that it always contains a complete record, so must be twice the length of the longest record, which is currently around 825,000 bytes. The read block size in bytes is 2^size_block, so for the default value of 23 this is 8 MiB. The minimum allowed is 21, corresponding to 2 MiB.

.PARAMETER bisection_search
 Switch parameter. Omit to base the search method on linear interpolation. Include to use interval bisection.

.PARAMETER detailed_output
 Switch parameter. Omit to suppress the display of the intermediate id intervals produced by the search method. Include to display.

.PARAMETER no_check
 Switch parameter. Omit to validate that the script and executable are in the same folder. Include to skip this check.

.EXAMPLE
PS_GetDiscogsRelease.ps1   "D:\discogs_releases.xml"   12

Description
---------------------------------------------------------------
EXAMPLE 1. Searches the input file for release id 12 and writes the record to a file discogs_ID_12.xml in the folder containing this script. Mandatory parameters are identified by position.

.EXAMPLE
PS_GetDiscogsRelease.ps1   "D:\discogs_releases.xml"   12   -o "D:\DiscogFiles\" 

Description
---------------------------------------------------------------
EXAMPLE 2. Same as EXAMPLE 1 but with the record written to the output file "D:\DiscogsFiles\discogs_ID_12.xml". This is valid only if the output file does not already exist. Otherwise the write_output parameter must also be supplied.

.EXAMPLE
PS_GetDiscogsRelease.ps1   "D:\discogs_releases.xml"   12   -o "D:\DiscogFiles\"   -w a

Description
---------------------------------------------------------------
EXAMPLE 3. Same as EXAMPLE 2 but with the write_output parameter set to 'a': If the file already exists the record is appended. 

.EXAMPLE
PS_GetDiscogsRelease.ps1   -input_file "D:\discogs_releases.xml"   -release_id 12   -output_folder "D:\DiscogFiles\"   -write_mode o   -size_block 24   -bisection_search

Description
---------------------------------------------------------------
EXAMPLE 4. Same as EXAMPLE 3 but with the write_output parameter changed to 'o' (overwrite). Data is read in blocks of size 2^24 = 16 MiB. The bisection search method is used. Parameters are identified by their full names. 

.INPUTS
 None.

.OUTPUTS
 None. Success or failure is indicated by messages to the console.

.NOTES
 Created by    : User2429
 Date          : May 2022

#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory, Position = 0)] [ValidateScript({$_.Exists})] [System.IO.FileInfo] $input_file,
    [Parameter(Mandatory, Position = 1)] [ValidateRange(1,[int]::MaxValue)] [int] $release_id,
    [Parameter()] [ValidateScript({Test-Path $_})] [System.IO.FileInfo] $output_folder,
    [Parameter()] [ValidateSet('a','o')] [string] $write_mode, 
    [Parameter()] [ValidateRange(21,40)] [int] $size_block= 23,
    [Parameter()] [switch] $bisection_search,
    [Parameter()] [switch] $detailed_output,
    [Parameter()] [switch] $no_check)
    
# Stop script on error.
# The executable name is the name of this script after removing the prefix "PS_" and extension ".ps1".
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
$executable_name = [System.IO.Path]::GetFileNameWithoutExtension($MyInvocation.MyCommand.Name)
$executable_name = $executable_name.Substring($executable_name.IndexOf("_") + 1)
$not_found = "not found in folder $PSScriptRoot\"

# If the output_folder argument is not supplied make it the local path (i.e. the path of this script as given by $PSScriptRoot).
if ($null -eq $output_folder ) { 
    Write-Verbose "Output file will be written to folder $PSScriptRoot"
    $output_folder = $PSScriptRoot 
}

# The output folder must be a folder, so may not have a file extension.
$output_ext = Split-Path -Path $output_folder -Extension
if($output_ext.Length -gt 0) { throw "Invalid output $output_folder. Must be a folder." }

# If the output file already exists AND the write_mode argument is not supplied then terminate. Otherwise set the write_mode to 'o' (overwrite).
$output_file = 'discogs_ID_' + [string]$release_id + '.xml'
$output_file_full = Join-Path -Path $output_folder -ChildPath $output_file
if((Test-Path -Path $output_file_full) -and ($write_mode.Length -eq 0)) {
    throw "Output file $output_file already exists in the output folder. write_mode must be 'a' or 'o' (append or overwrite)." 
}
if ($write_mode.Length -eq 0) { $write_mode = 'o'}

# Ensure there is a backslash at the end of the output folder name. Convert to string in order to apply Trimend().
$output_folder_string = ([string]$output_folder).Trim()
$delimiter ='\'
if($IsLinux) {$delimiter = '/'}
$output_folder_string = $output_folder_string.Trimend($delimiter) + $delimiter 

# Convert boolean to string for the executable.
if ($bisection_search){ $b = 'true' } else { $b = 'false' }
if ($detailed_output){ $d = 'true' } else { $d = 'false' }

# Check that the executable and dll files are found in the same folder as the script. 
# $no_check = $false (the default) means the check is carried out.
if (-not $no_check){
    if($IsWindows){ 
        if(-not (Test-Path -Path "$PSScriptRoot/$executable_name.exe")) {throw "Executable $executable_name.exe $not_found"}
        if(-not (Test-Path "$PSScriptRoot/fmt.dll")){throw "Required file fmt.dll $not_found"}
    }
    if($IsLinux){
        if (-not (Test-Path -Path "$PSScriptRoot/$executable_name")){throw "Executable $executable_name $not_found"}
    }
}

# Call the executable. All parameters must be supplied, must be in the given order and may not be empty.
if($IsWindows) { $cmd = "$PSScriptRoot/$executable_name.exe" }
if($IsLinux) { $cmd = "$PSScriptRoot/$executable_name" }
Write-Host "`n*** CALLING  $executable_name with inputs:   $input_file    $output_folder_string    $release_id    $write_mode    $size_block    $b    $d"
& $cmd $input_file $output_folder_string $release_id $write_mode $size_block $b $d