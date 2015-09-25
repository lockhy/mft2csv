# Project have been moved to: https://github.com/jschicht #

# Introduction #

This AutoIt script is parsing, decoding and logging information from the Master File Table ($MFT) to a csv. It is logging a large amount of data and that has been the main purpose from the very start. Having all this data in a csv is therefore nice for easy further analysis. What also should make it appealing is the easyness of understanding the script and the ability for easy customization of it.

# Details #

Input can be any of the following:
  * Raw/dd image of disk (MBR and GPT supported)
  * Raw/dd image of partition
  * $MFT extracted file
  * Reading of $MFT directly from a live system
  * Reading of $MFT by accessing \\.\PhysicalDriveN directly (no mount point needed).
  * Reading of $MFT directly from within shadow copies.
  * $MFT fragments extracted off memory dumps (see MFTCarver)

There is an option to choose which UTC region to decode for. For instance you have a disk image and the target system had a timezone configuration of UTC -9.30, then you can configure it like that and get the timestamps directly into UTC 0.00. Default is UTC 0.00, and if running on a live system, there is no need to do anything as timestamps are automatically set to UTC 0.00.

The format of output can be chosen. Currently it is possible to choose from:
  * All (will write to csv everything it can). Default set.
  * log2timeline: http://code.google.com/p/log2timeline/wiki/l2t_csv
  * bodyfile (v3.x): http://wiki.sleuthkit.org/index.php?title=Body_file

It is possible to parse broken/partial $MFT by configuring "Broken $MFT". This setting is necessary if for instance index number 0 is missing (the record for $MFT itself).

Also it is possible to configure the tool to skip fixups. This is something you may want if you are working on memory dumps. If so, you need to run MFTCarver on the memdump first. Then run mft2csv on the output file from MFTCarver. Must have both "Broken $MFT" and "Skip Fixups" configured in such a case.

The focus have been on the attributes $STANDARD\_INFORMATION, $FILE\_NAME, $DATA and $VOLUME\_ID as well as the file record headers themselves. More attributes will be added for sure.  Here is the listing of data that is currently covered (more descriptive names may be chosen in the future);
  * RecordOffset
  * Signature
  * IntegrityCheck
  * HEADER\_MFTREcordNumber
  * HEADER\_SequenceNo
  * FN\_ParentReferenceNo
  * FN\_ParentSequenceNo
  * FN\_FileName
  * HEADER\_Flags
  * RecordActive
  * FileSizeBytes
  * SI\_FilePermission
  * FN\_Flags
  * FN\_NameType
  * ADS
  * SI\_CTime
  * SI\_ATime
  * SI\_MTime
  * SI\_RTime
  * MSecTest
  * FN\_CTime
  * FN\_ATime
  * FN\_MTime
  * FN\_RTime
  * CTimeTest
  * FN\_AllocSize
  * FN\_RealSize
  * SI\_USN
  * DATA\_Name
  * DATA\_Flags
  * DATA\_LengthOfAttribute
  * DATA\_IndexedFlag
  * DATA\_VCNs
  * DATA\_NonResidentFlag
  * DATA\_CompressionUnitSize
  * HEADER\_LSN
  * HEADER\_RecordRealSize
  * HEADER\_RecordAllocSize
  * HEADER\_FileRef
  * HEADER\_NextAttribID
  * DATA\_AllocatedSize
  * DATA\_RealSize
  * DATA\_InitializedStreamSize
  * SI\_HEADER\_Flags
  * SI\_MaxVersions
  * SI\_VersionNumber
  * SI\_ClassID
  * SI\_OwnerID
  * SI\_SecurityID
  * FN\_CTime\_2
  * FN\_ATime\_2
  * FN\_MTime\_2
  * FN\_RTime\_2
  * FN\_AllocSize\_2
  * FN\_RealSize\_2
  * FN\_Flags\_2
  * FN\_NameLength\_2
  * FN\_NameType\_2
  * FN\_FileName\_2
  * GUID\_ObjectID
  * GUID\_BirthVolumeID
  * GUID\_BirthObjectID
  * GUID\_BirthDomainID
  * VOLUME\_NAME\_NAME
  * VOL\_INFO\_NTFS\_VERSION
  * VOL\_INFO\_FLAGS
  * FN\_CTime\_3
  * FN\_ATime\_3
  * FN\_MTime\_3
  * FN\_RTime\_3
  * FN\_AllocSize\_3
  * FN\_RealSize\_3
  * FN\_Flags\_3
  * FN\_NameLength\_3
  * FN\_NameType\_3
  * FN\_FileName\_3
  * DATA\_Name\_2
  * DATA\_NonResidentFlag\_2
  * DATA\_Flags\_2
  * DATA\_LengthOfAttribute\_2
  * DATA\_IndexedFlag\_2
  * DATA\_StartVCN\_2
  * DATA\_LastVCN\_2
  * DATA\_VCNs\_2
  * DATA\_CompressionUnitSize\_2
  * DATA\_AllocatedSize\_2
  * DATA\_RealSize\_2
  * DATA\_InitializedStreamSize\_2
  * DATA\_Name\_3
  * DATA\_NonResidentFlag\_3
  * DATA\_Flags\_3
  * DATA\_LengthOfAttribute\_3
  * DATA\_IndexedFlag\_3
  * DATA\_StartVCN\_3
  * DATA\_LastVCN\_3
  * DATA\_VCNs\_3
  * DATA\_CompressionUnitSize\_3
  * DATA\_AllocatedSize\_3
  * DATA\_RealSize\_3
  * DATA\_InitializedStreamSize\_3
  * STANDARD\_INFORMATION\_ON
  * ATTRIBUTE\_LIST\_ON
  * FILE\_NAME\_ON
  * OBJECT\_ID\_ON
  * SECURITY\_DESCRIPTOR\_ON
  * VOLUME\_NAME\_ON
  * VOLUME\_INFORMATION\_ON
  * DATA\_ON
  * INDEX\_ROOT\_ON
  * INDEX\_ALLOCATION\_ON
  * BITMAP\_ON
  * REPARSE\_POINT\_ON
  * EA\_INFORMATION\_ON
  * EA\_ON
  * PROPERTY\_SET\_ON
  * LOGGED\_UTILITY\_STREAM\_ON

# Explanation #

They should be quite self explanatory by their name, but anyways here's e few hints;
  * Those ending with a ON is just to indicate whether the attribute was used in the record.
  * Those ending with 2 or 3 or 4 are indicating they are number 2, 3 or 4 in the row of the same attribute on the same record.
  * Prefix of FN means $FILE\_NAME.
  * Prefix of SI means $STANDARD\_INFORMATION
  * Prefix of HEADER means the record header.
  * CTime means File Create Time.
  * ATime means File Modified Time.
  * MTime means MFT Entry modified Time.
  * RTime means File Last Access Time.
  * USN stands for Update Sequence Number.
  * LSN stands for $LogFile Sequence Number.
  * RecordOffset refers to the hex offset inside the $MFT itself, and not on the physical disk. Only meant as a helper when quickly looking up abnormalities found in the csv.
  * Signature refers to whether the record signature equals 0x46494C45 or not.
  * IntegrityCheck refers to a record integrity check by comparing the Update Sequence number to the record page (sector) end markers (2 bytes for each sector).
  * Those starting with GUID belongs to the $OBJECT\_ID attribute.
  * Those starting with INVALID\_FILENAME is when illegal characters are found in the filename. For example, sometimes control characters like line feeds etc exist in filename.

# Alternate Data Streams #

These streams can be identified in the second $DATA attribute. That is under those fields starting with DATA and ending with either 2 or 3. So if a second ADS is attached to a file, it will show up with the details under the third $DATA attribute. As far as I know there do not exist any limit on number of ADS's tied to a file.  For that reason, my limit on support for 3 $DATA attributes per file may miss out on those cases with more than 2 ADS's on the same file (not that I have seen this in multiple though). But to fix this I added a variable that counts the number of $DATA present. It is shown in the csv under Alternate\_Data\_Streams. Note that ADS's can only be attached to the $DATA attribute of a file. It is not possible to create ADS's on any of the other attributes. That may not be surpising as it should be obvious as it's named Alternate **Data** Stream, instead of Alternate File\_Name Stream.

# Timestamps #

The timestamps are now at the precision of nanoseconds. Prior to processing, there is also an option to set how timestamps will be presented in the csv. That is in which UTC region the target system had. The configured setting is visible in the csv header, as well as in the logfile. There are several options for format of the timestamps as well as the precision. The GUI will display the different examples. The timestamps generated are corrected for any time bias on the investigating machine, which means the timezone configuration on the machine where mft2csv is run, should not affect output. There's also an option to directly adjust timestamps for any known timezone bias for images or $MFT taken from a different system. That means with a disk image from a system confgured at UTC -9.30 for instance, can be directly adjusted, so that timestamps are displayed in UTC 0.00.

# Note #

Resolved paths may not be correct for deleted files/folders. That is because its parent ref (or parents parents ref, etc) may have been overwritten with a new entry.

# Usage and examples #

See the readme included in the download package.

# Latest Version #

v2.0.0.20

# Changelog #

v2.0.0.15. Fixed a bug where file paths for certain deleted objects got wrong. Only source of the latest version is available at this site now, since google code don't support new downloads. Binaries will be available again soon, when project is moved somewhere else.

v2.0.0.13. Fixed bug that prevented single records containing $ATTRIBUTE\_LIST (Broken $MFT configured) to be decoded.

v2.0.0.12. Added support for parsing $MFT directly from within shadow copies. Fixed tiny bug that caused FilePath to have 1 erronous character prefixed for all values.

v2.0.0.11. Fixed bug when handling old NT Style records. Added separate variable to indicate the old NT Style recordss, and put a predicted MFT ref into the original MFT record number variable. Added options to specify timestamp formats and level of precision. Was added for easier working/sorting of data in spreadsheets. Added sample output in gui to show what the timestamp format would look like. All timestamp variables are now split into 3. 1 original, and then 1 core containing the timestamp without precision, and 1 timestamp precision variable conatining only the precision depending on the configuration chosen (None, MilliSec, or MilliSec+NanoSec). Added an option to dump these new split timestamp variables to a separate csv, by ticking off the "split csv" option. Removed option to set csv, and replaced with a standard one in current directory identified with a timestamp in the csv file name.

v2.0.0.10. Fixed bug when resolving certain filepaths from an extracted MFT file, when MFT had been fragmented. Changed default separator to | (pipe), which is invalid for filenames. Removed quotes on as default. Removed annoying UTC comment information at the top of csv.

v2.0.0.8. Fixed a bug that caused file paths to be resolved incorrectly with certain fragmented MFT's. Slightly changed how the header flags are interpreted. Added support for accessing \\PhysicalDriveN directly, and thus removed any requirement for having volumes mounted.

v2.0.0.7. Fixed incorrect default value for Bytes Per Cluster when using $MFT file as input (caused some crashes).

v2.0.0.6. Fixed bug when handling attribute lists and broken $MFT file as input.

v2.0.0.5. Added functionality to optionally extract all resident data.

v2.0.0.4. Added functionality to parse broken $MFT. Added option to skip fixups.

v2.0.0.3. Fixed crash on certain MFT's with specific invalid records. Added option to choose separator, and if surrounding quotes. Removed decode of filename attribute number 4, as well as the invalid name variable.

v2.0.0.2. Speed improvement by 30 %. Fixed bug where some columns was missing in csv with the All format.

v2.0.0.1. Added support for choosing output format (all/default, log2timeline, bodyfile)

v2.0.0.0. Fixed bug that caused csv to be messed up when there where commas in filename. New features include support disk and partition images, live system analysis, logfile writer, nicer gui, paths resolved, option to choose any UTC region.

v1.0.0.10. Fixed old NT style records to reflect the text "NT style" in place of MFT reference.

v1.9. Added decode of hardlinks as specified in the record header. Corrected base record to properly reflect 6 bytes, and added new variable as base record sequence number for the last 2 bytes of this 8 byte MFT base reference. Fixed the HEADER\_LSN and SI\_USN to be specified in decimal (consistent views in Excel). Fixed missing clearing of 9 global variables.

v1.8. Changed the progress updating to use AdlibRegister, which increase performance.

v1.7. Removed the record slack option as it was not working. Fixed compilation issues on recent AutoIt version. Fixups was implemented in the previous version I believe.

v1.5 Changed record signature detection to:

46494C45 = GOOD (although FILE is strictly speaking the correct one)
44414142 = BAAD
00000000 = ZERO
all other = UNKNOWN

Added header flag interpretation:
0x9 = FILE+INDEX\_SECURITY (ALLOCATED)
0xD = FILE+INDEX\_OTHER (ALLOCATED)

Fixed crash on decoding of certain corrupt $MFT, by skipping decode of those records.

v1.4 Fixed a bug in the record signature evaluation. Added csv entry for record signature evaluation. Added record integrity check by comparing the Update Sequence number to the record page end markers (2 bytes at 2 places). Some other cosmetic changes.

v1.3 Added nanoseconds to the datetime variables. Changed default datetime format to "YYYY-MM-DD HH:MM:SS:MSMSMS:NSNSNSNS". MSecTest changed to evaluate the last 7 digits (msec + nsec). 64-bit support.

v1.2 Fixed timestamps where a 0 was erronously put in before the milliseconds. Modified version Ascend4nt's (_WinTimeFunctions1.au3) UDF is attached (where the error originated from). Also added an option to choose before processing whether to set timestamps in UTC or local time._

v1.1. Fixed a mixup of ContinueLoop with ContinueCase in the main record processing loop. The error lead to an infinite loop when ADS was more than 3 or $FILE\_NAME more than 4 per file. Added a new variable to the csv as the file size (FileSizeBytes). Basically it is the $DATA size, but I thought it was better to have the file size put into one place instead of spread across two (resident vs non-resident). This is only for the first $DATA attribute.


# ToDo #

  * Move attribute header analysis out as a separate part.
  * Security attribute.
  * Group the data in a more sensible way.
  * Improve the speed.

# Thanks and credits #

  * DDan at forensicfocus.
  * AutoIt forums (KaFu & trancexx) where the starter code was provided; http://www.autoitscript.com/forum/topic/94269-mft-access-reading-parsing-the-master-file-table-on-ntfs-filesystems/
  * Ascend4nt's AutoIt wintimefunctions; http://sites.google.com/site/ascend4ntscode/
  * David Kovar's nice analyzeMFT.py python script; http://www.integriography.com/
  * jennico's extended hex to dec conversion AutoIt udf
  * The "ntfs-cmd" project; http://code.google.com/p/ntfs-cmd/
  * llewxam at the AutoIt forums