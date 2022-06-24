# GetDiscogsRelease

## Description
Given a Discogs release id this extracts the corresponding record from the Discogs releases `xml` file.<br>Windows and Linux versions are available.

## Basic Operation
The extract function is invoked by a PowerShell script which parses its arguments and then calls a C++ executable.<br>The script may be run from a PowerShell terminal in Windows or the PowerShell environment in Linux.<br>As an example, the command 

`PS_GetDiscogsRelease.ps1` &emsp; `D:\discogs_20220501_releases.xml` &emsp; `1287354`

will extract the record with the given id from the May 2022 release file.<br>The record will be written to the file `discogs_ID_1287354.xml` in the same folder as the PowerShell script.

## Installation
The user need only copy the executable and script files to whatever folder they choose, but the files must reside in the same folder.

For Windows the files are `GetDiscogsRelease.exe`, `fmt.dll` and `PS_GetDiscogsRelease.ps1`.<br>For Linux they are `GetDiscogsRelease` and either of `PS_GetDiscogsRelease.ps1` or `AB_GetDiscogsRelease.sh`.<br>The latter is a bash script which may be used in place of the `.ps1` script if PowerShell is not available in Linux.

## Details
Details of usage and methodology are given in the [documentation](https://github.com/User2429/GetDiscogsRelease/blob/master/docs/Documentation.md).