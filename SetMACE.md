# Project have been moved to: https://github.com/jschicht #

# Introduction #

The SetMACE tool is a timestomp re-invention, and more like a timestomp on steriods. It is basically a tool to manipulate/dump timestamps on NTFS volumes.


# Details #

So what is file timestamps on NTFS? There exist 4 different timestamps that can be found in several of the attributes of a file. The different timestamps are MACE.

  * M: stands for last write time.
  * A: stands for last access time.
  * C: stands for creation time.
  * E: stands for change time ($MFT record)

The MACE values are 64-bit timestamps, which are the number of 100 nanoseconds since 01. January 1601 00:00:00 UTC. These values can further be found in the $STANDARD\_INFORMATION and $FILE\_NAME attributes. Additioanlly there may also exist more than 1 $FILE\_NAME attribute for a file if the file name is longer than fitting the DOS naming. So for Win32 names there may exist 12 timestamps in the record.

You may find it handy to use MFTRCRD to dump the file record and see if your new timestamps are present.

The original way of changing the 4 MACE values, as implemented in timestomp, was to use the NtSetInformationFile function inside ntdll.dll and the FILE\_BASIC\_INFORMATION structure in FILE\_INFORMATION\_CLASS. That will let you change all 4 values in the $STANDARD\_INFORMATION, but not in the $FILE\_NAME attribute. I therefore added support for that in SetMACE to make it more interesting. The first version (v1005) implemented the file move trick, which sets the timestamps then move the file to a different folder before moving the file back again and resetting the timestamps. That effectively changed both attributes timestamps. However, evidence of such activity could be found in the $LogFile. Later in the next version (v1006) I added support for writing the $FILE\_NAME timestamps directly to the physical disk, and eliminating the need to move the file around to set $FILE\_NAME timestamps. Writing the timestamps to physical disk is an operation that by its nature impose rather big security implications. Luckily such access was locked down in nt6.x from Vista and later. Since nt6.x writing to physical disk is no longer possible to the systemdrive without a kernel mode driver. Kernel mode driver would use SL\_FORCE\_DIRECT\_WRITE according to MS documentation. It is still possible though to write directly to physical disk on any NTFS volume not being the systemdrive on nt6.x. Booting to WinPE and write to local systemdrive will also work though, as will also the earlier move trick implemented in the previous version. The latest version, v1007, was completely re-written, to remove any depency on NtSetInformationFile and only modify timestamps by writing them directly to the disk. That require the tool to resolve NTFS accurately, in order to not mess up the volume, and should therefore be considered experimental. But it has been tested quite a lot, and seems stable.

Interestingly, and only after writing v1006 of SetMACE, I truly realized how important the new security measures in nt6.x actually are. On nt5.x (XP, 2003) it's ridiculas.

# Some of the nice features of SetMACE #

  * Works on both 32-bit and 64-bit, from XP to Windows 8.
  * Accuracy down to the nanosec level.
  * Both $FILE\_NAME and $STANDARD\_INFORMATION timestamps.
  * Supports both files and directories.
  * Clone timestamps from a second file (removed in v1007).
  * Dump timestamps of files from within shadow copies.

# Dumping information with the -d switch #
From version 1.0.0.9 the -d switch will also dump timestamp information from the target volume, as well as from present any shadow copies of that volume. So if the volume that the target file resides on, also have shadow copies, the -d switch will also dump information for the same MFT reference for every relevant shadow copy. Matching shadow copies are identified by the volume name and serial number. The dumped information includes filename, parent ref, sequence number and hardlink number to help identify if the same file actually holds a particular MFT ref across shadow copies.



# Limitations #

When will version 1007 or later not work?
  * Tweaking files off the systemdrive in Vista - Windows 8 when the OS is running.
  * Tweaking files on a volume where a pagefile is located (if OS is Vista - Windows 8).
  * Tweaking files on the same volume as setmace is located on (if OS is Vista - Windows 8).


# Syntax explanation #

**Parameter 1** is input/target file. Must be full path like C:\file.ext or c:\folder\file.ext

**Parameter 2** is determining which timestamp to update.
  * "-m" = LastWriteTime
  * "-a" = LastAccessTime
  * "-c" = CreationTime
  * "-e" = ChangeTime (in $MFT)
  * "-z" = all 4
  * "-d" = Dump existing timestamps (in UTC 0.00 and adjusted for timezone configuration)

**Parameter 3** is the wanted new timestamp. Format must be strictly followed like; "1954:04:01:22:39:44:666:1234". That is YYYY:MM:DD:HH:MM:SS:MSMSMS:NSNSNSNS. The smallest possible value to set is; "1601:01:01:00:00:00:000:0001". Timestamps are written as UTC and thus will show up in explorer as interpreted by your timezone location. Note that nanoseconds are supported.

**Parameter 4** determines if $STANDARD\_INFORMATION or $FILE\_NAME attribute or both should be modified.
  * "-si" will only update timestamps in $STANDARD\_INFORMATION (4 timestamps), or just LastWriteTime, LastAccessTime and CreationTime (3 timestamps) for non-NTFS.
  * "-fn" will only update timestamps in $FILE\_NAME (4 timestamps for short names and 8 timestamps for long names).
  * "-x" will update timestamps in both $FILE\_NAME and $STANDARD\_INFORMATION (8 or 12 timestamps depending on filename length).


# Examples #

### Setting the CreationTime in the $STANDARD\_INFORMATION attribute: ###
setmace.exe C:\file.txt -c "2000:01:01:00:00:00:789:1234" -si

### Setting the LastAccessTime in the $STANDARD\_INFORMATION attribute: ###
setmace.exe C:\file.txt -a "2000:01:01:00:00:00:789:1234" -si

### Setting the LastWriteTime in the $FILE\_NAME attribute: ###
setmace.exe C:\file.txt -m "2000:01:01:00:00:00:789:1234" -fn

### Setting the ChangeTime(MFT) in the $FILE\_NAME attribute: ###
setmace.exe C:\file.txt -e "2000:01:01:00:00:00:789:1234" -fn

### Setting all 4 timestamps in both $FILE\_NAME and $STANDARD\_INFORMATION attributes: ###
setmace.exe C:\file.txt -z "2000:01:01:00:00:00:789:1234" -x

### Setting all 8 timestamps in the $FILE\_NAME attribute for a file with long filename: ###
setmace.exe "C:\alongfilename.txt" -z "2000:01:01:00:00:00:789:1234" -fn

### Setting 2 timestamps ($MFT creation time **2) in the $FILE\_NAME attribute for a file with long filename: ###
setmace.exe "C:\alongfilename.txt" -e "2000:01:01:00:00:00:789:1234" -fn**

### Setting all 4 timestamps in $STANDARD\_INFORMATION attribute for a directory: ###
setmace.exe D:\tmp -z "2000:01:01:00:00:00:789:1234" -si

### Dumping all timestamps for $MFT itself: ###
setmace.exe C:\$MFT -d

or

setmace.exe C:0 -d



# ToDo #
Handle index entries.

# Latest version #
v1.0.0.14

# Changelog #
v1.0.0.9. Added support for dumping timestamp information also from within shadow copies with the -d switch.

v1.0.0.8. Fixed mixup up of mapping for LastAccessTime, LastWriteTime and ChangeTime(MFT). Fixed bug in logic for lock/dismount handling of external drives and nt5.x vs nt6.x. Fixed a bug that caused only last $FILE\_NAME timestamps to be displayed/written, instead of for all $FILE\_NAME attributes.