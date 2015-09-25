# Project have been moved to: https://github.com/jschicht #

# Introduction #

This tool will decode the $MFT record for a given file. It is a combination of mft2csv and NtfsFileExtracter. That means it is a tool for quick decode and dumping of file records. It does not write any csv, but dumps the information to the console. It is very handy when testing stuff and learning NTFS, as you can do stuff to a file and get it decoded right away, without first having to extract the whole $MFT and then decode it to a csv, before importing it into Excel or something and get the actual result. MFTRCRD is therefore for quick dumping of record information for individual files, whereas mft2csv is for decoding the complete $MFT with all its records, which may be a substantial amount and timeconsuming task.

It supports both file name+path and IndexNumber (MFT record) as input (param1). Now also disk offset can be specified as alternative. See examples below for syntax. Param4 is for choosing wether to hexdump resolved INDX records from the $INDEX\_ALLOCATION attribute.

Attributes currently handled:
  * $STANDARD\_INFORMATION
  * $ATTRIBUTE\_LIST
  * $FILE\_NAME
  * $OBJECT\_ID
  * $SECURITY\_DESCRIPTOR (just raw hex dump)
  * $VOLUME\_NAME
  * $VOLUME\_INFORMATION
  * $DATA
  * $INDEX\_ROOT
  * $INDEX\_ALLOCATION
  * $BITMAP (just raw hex dump)
  * $REPARSE\_POINT
  * $EA\_INFORMATION
  * $EA
  * $LOGGED\_UTILITY\_STREAM

Detailed runs information for $DATA can be retrived with version v1006.

Beware that running MFTRCRD against the winsxs folder may take quite a long time (10 minutes or so). On my Windows 7 machine there is almost 24000 entries in the INDX records to decode when resolving the $INDEX\_ALLOCATION atribute.

Here is a sample console dump (older version): http://mft2csv.googlecode.com/files/dump_MTFRCRD.zip


# How to run MFTRCRD #

It is command line and the syntax is:

### Usage: "MFTRCRD param1 param2 param3" ###

param1 can be a valid file path or an IndexNumber ($MFT record number)

param2 can be -d or -a:
-d means just decode $MFT entry
-a same as -d but also dumps the whole $MFT entry to console

param3 for specifying wether to hexdump complete INDX records and can be either indxdump=on or indxdump=off. Beware that indxdump=on may generate a significant amount of dump to console for certain directories.

### Example for dumping an $MFT decode for boot.ini: ###

MFTRCRD C:\boot.ini -d indxdump=off

### Example for dumping an $MFT decode + a 1024 byte $MFT record dump for $MFT itself from the C: drive: ###

MFTRCRD C:0 -a indxdump=off

### Example for dumping an $MFT decode for $LogFile from the D: drive: ###

MFTRCRD D:2 -d indxdump=off

### Example for dumping an $MFT record decode + hexdump of its resolved INDX records for the root directory on C:, equivalent to the 'folder' named C:\ ###

MFTRCRD C:5 -d indxdump=on

### Example for decoding what is found at offset 3246809088 on the c drive: ###

MFTRCRD C?3246809088 -a indxdump=off

(Offset specified in hex must be prefixed with "0x", ie C?0xC1866000)


Running the tool without any parameter will display help information.


# Latest version #
v1.0.0.29

# Changelog #

v1.0.0.28: Fixed the displayed offset of found record which was 1024 bytes off.

v1.0.0.27: Fixed small "cosmetic bug" with INDX records where zero'ed timestamps showed a strange ":0000". Now it simply displays "-".

v1.0.0.26: Fixed a bug that caused incorrect decode of file flag for entries inside INDX records. Added the allocated flag to header decode.

v1.0.0.25: Reorganized output of the $DATA attribute. Added dataruns as separate output variable. Removed limitation on how many $DATA attributes to decode (now virtually unlimited to support heavy attribute lists).

v1.0.0.24: General speed improvement. Added missing header flags. Added missing file attribute flags. Added missing reparse type tag. Fixed decode of indx to only cover $I30. Remove some uneeded stuff. Syntax changed (1 param less). Slightly changed how some of the output is displayed.

v1.0.0.23: Fixed a missing declaration of 2 global variables that caused certain issues under certain circumstances. Fixed issue with the "NT style" record identification.

v1.0.0.22: Added text "NT style" in place of MFT reference when NT style record. Fixed bug in idenfying hte "param attriblist=on". Also fixed a small bug in the MFT array generation, that caused certain index numbers not to be found.

v1.0.0.21: Fixed the split of 6+2 bytes (Reference and SeqNo) for both MFTRef and Parent MFTRef when index decoding. Also changed SI\_USN to display in decimal.

v1.0.0.20: Fixed small bug in header decode that returned the whole 8 bytes of the base records, instead of the 4 bytes that are used.

v1.0.0.19: Fixed bug that caused "attriblist=on" not to be caught. Also added a timer.

v1.0.0.18: Fixed INDX decode when using offset mode. Added offset correction when entering offset not aligned to sector size.

v1.0.0.17: Fixed wrong logic when displaying hex dump of attribute with the new offset mode.

v1.0.0.16: Added option of specifying disk offset to decode. The syntax for using offset is driveletter+?+offset.

v1.0.0.15: Fixed a bug when handling attribute lists.

v1.0.0.14: Added ability to also decode files marked as deleted. Fixed a wrong return when record not found. Changed some output text.

v1.0.0.13: Fixed small bug in decode of certain weird INDX records. Also added full decode of all resident index entries in $INDEX\_ROOT

v1.0.0.12: Fixed the bug in extraction of non-resident INDX records that caused some duplication of entries to occur. The INDX entry arrays logic have been turned aroung into a much easier and better way.

v1.0.0.11: Changed syntax slightly, and introduced a new parameter called indxdump. Fixed lots of stuff for INDX records decoding. Still unknown why some duplicate entries appear though.

v1.0.0.10: Added test decode of $INDEX\_ROOT and $INDEX\_ALLOCATION. Added INDX record decoding and raw hex dump.

v1009: Added decoding of resident and nonresident $REPARSE\_POINT, $EA\_INFORMATION, $EA and $LOGGED\_UTILITY\_STREAM. Added an extra switch to speed up $MFT processing when $ATTRIBUTE\_LIST is present/not present. Fixed an extra error in the raw hex dump of $EA.

v1008: Now hexdumps of all attributes are displayed with the -a switch, and not just the ones that are decoded.

v1007: Switched code base to the same as of NTFS File Extracter. Now full $ATTRIBUTE\_LIST is decoded and resolved. A pregeneration of an internal $MFT array is added to substantially speed up decoding of files with attribute list. Added raw dump of record slack.