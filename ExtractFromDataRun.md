# Introduction #

In short this is stripped down version of the NTFS File Extractor; http://code.google.com/p/mft2csv/wiki/NTFS_File_Extracter


# Details #

It supports extraction from:
  * Disk images, both of MBR/GPT style.
  * Partition images.
  * Volume Shadow Copies.
  * Mounted NTFS volumes.
  * Unmounted NTFS volumes, by scanning physical disk.

However, as it is extracting from one given datarun list, it is limited to one data chunk at the time (normally a file). But it can be any attribute, not necessarily $DATA.

This tool works well on the outputted datarun list, as given in the output from the $LogFile parser; http://code.google.com/p/mft2csv/wiki/LogFileParser

# Latest version #
v1.0.0.2

# Changelog #
v1.0.0.2. Added support for scanning physical drive for (unmounted) volumes. Added support for Volume Shadow Copies.