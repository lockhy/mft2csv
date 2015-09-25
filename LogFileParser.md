# Project have been moved to: https://github.com/jschicht #

# Features #

  * Decode and dump $LogFile records.
  * Decode many attribute changes.
  * Recreate a dummy $MFT
  * Decode all index related transaction (from IndexRoot/IndexAllocation).
  * Optionally resolve all datarun list information available in $LogFile.
  * Configurable verbose mode (does not affect logging).
  * Optionally decode $UsnJrnl.
  * Logs to csv and imports to sqlite database with several tables (read included readme for details on each csv / table).
  * Optionally import csv output of mft2csv into db.
  * Choose timestamp format and precision.
  * Choose region adjustment for timestamps. Default is UTC 0.0.
  * Choose separator.
  * Configurable MFT record size (1024 or 4096 bytes).


# Background #

NTFS is designed as a recoverable filesystem. This done through logging of all transactions that alters volume structure. So any change to a file on the volume will require something to be logged to the $LogFile too, so that it can be reversed in case of system failure at any time. Therefore a lot of information is written to this file, and since it is circular, it means new transactions are overwriting older records in the file. Thus it is somewhat limited how much historical data can be retrieved from this file. Again, that would depend on the type of volume, and the size of the $LogFile. On the systemdrive of a frequently used system, you will likely only get a few hours of history, whereas an external/secondary disk with backup files on, would likely contain more historical information. And a 2MB file will contain far less history than a 256MB one. So in what size range can this file be configured to? Anything from 256 KB and up. Configure the size to 2 GB can be done like this, "chkdsk D: /L:2097152".

![http://i1100.photobucket.com/albums/g407/joakimschicht/LogFile2Gb_zps1e875dce.png](http://i1100.photobucket.com/albums/g407/joakimschicht/LogFile2Gb_zps1e875dce.png)

How a large sized logfile impacts on performance is beyond the scope of this text. Setting it lower than 2048 is normally not possible.

![http://i1100.photobucket.com/albums/g407/joakimschicht/LogFile_TooSmall_zps1470903f.png](http://i1100.photobucket.com/albums/g407/joakimschicht/LogFile_TooSmall_zps1470903f.png)

However it is possble by patching untfs.dll: http://code.google.com/p/mft2csv/wiki/Tiny_NTFS

# Introduction #
This parser will decode and dump lots of transaction information from the $LogFile on NTFS. There are several csv's generated as well as an sqlite database named ntfs.db containing all relevant information.

The currently decoded transaction types are:
  * InitializeFileRecordSegment
  * CreateAttribute
  * DeleteAttribute
  * UpdateResidentValue
  * UpdateNonResidentValue
  * UpdateMappingPairs
  * SetNewAttributeSizes
  * AddindexEntryRoot
  * DeleteindexEntryRoot
  * AddIndexEntryAllocation
  * DeleteIndexEntryAllocation
  * ResetAllocation
  * ResetRoot
  * SetIndexEntryVcnAllocation
  * UpdateFileNameRoot
  * OpenNonresidentAttribute

The list of currently supported attributes:
  * $STANDARD\_INFORMATION
  * $FILE\_NAME
  * $OBJECT\_ID
  * $VOLUME\_NAME
  * $VOLUME\_INFORMATION
  * $DATA
  * $INDEX\_ROOT
  * $INDEX\_ALLOCATION
  * $REPARSE\_POINT
  * $EA\_INFORMATION
  * $EA
  * $LOGGED\_UTILITY\_STREAM

So basically there's only 3 missing in the decode; $ATTRIBUTE\_LIST, $SECURITY\_DESCRIPTOR and $BITMAP. However, $ATTRIBUTE\_LIST is kind of implemented as records from attribute lists are processed through InitializeFileRecordSegment as separate MFT records, and information about base ref is already logged.

Explanation of the different output generated:
  * LogFile.csv (The main csv generated from the parser)
  * LogFile\_DataRuns.csv (The input information needed for reconstructing dataruns)
  * LogFile\_DataRunsResolved.csv (The final output of reconstructed dataruns)
  * LogFile\_INDX.csv (All dumped and decoded index records (IndexRoot(IndexAllocation), redo operations)
  * LogFileJoined.csv (Same as LogFile.csv, but have filename information joined in from the $UsnJrnl) or csv of mft2csv.
  * UsnJrnl.csv (The output of the $UsnJrnl parser module. File will not be created if not the USN journal is to be analyzed)
  * MFTRecords.bin (Dummy $MFT recreated based on found MFT records in InitializeFileRecordSegment transactions. Can use mft2csv on this one (remember to configure "broken MFT" and "Fixups" properly))
  * LogFile\_lfUsnJrnl.csv (records for the $UsnJrnl that has been decoded within $LogFile)
  * LogFile\_UndoWipe\_INDX.csv (All undo operations for clearing of directory indexes (INDX))

Ntfs.db (An sqlite database file with tables almost equivalent to the above csv's. The database contains 5 tables:
  * DataRuns
  * IndexEntries
  * LogFile
  * LogFileTmp (temp table used when recreating dataruns).
  * UsnJrnl

# Timestamps #
Defaults are presented in UTC 0.00, and with nanosecond precision. The default format is YYYY-MM-DD HH:MM:SS:MSMSMS:NSNSNSNS. These can be configured. The different timestamps refer to:
  * CTime means File Create Time.
  * ATime means File Modified Time.
  * MTime means MFT Entry modified Time.
  * RTime means File Last Access Time.

# Reconstructing DataRuns #
Many operations on the filesystem, will trigger a transaction into the $LogFile. Those relating to the $DATA attribute, ie a file's content are so far identified as:
  * InitializeFileRecordSegment
  * CreateAttribute
  * UpdateMappingPairs
  * SetNewAttributeSizes

They all leave different information in the $LogFile. Resident data modifications behave differently and can not be reconstructed just like that, at least on NTFS volumes originating from modern Windows versions.

**InitializeFileRecordSegment** is when a new file is created. Thus it will have the $FILE\_NAME attribute, as well as the original $DATA atribute content, including dataruns. Since the $LogFile is circular, and older events gets overwritten by newer, the challenge with the $LogFile is to get information long enough back in time. However, if InitializeFileRecordSegment is present, then we should be able to reconstruct everything, since all records written after that will also be available. We will also have information about the offset to the datarun list. This is a relative offset calculated from the beginning of the $DATA attribute. This is important information to have when calculating where in the datarun list the UpdateMappingPairs have done its modification.

**CreateAttribute** is the original attribute when it was first created (if not written as part of InitializeFileRecordSegment). With this one too, we should be able to reconstruct dataruns since we have all transactions available to us. However, this one will not in itself provide us with the file name. Here too, we have the offset to the datarun list available which is extremely useful when solving UpdateMappingPairs.

**UpdateMappingPairs** is a transaction when modifications to the $DATA/dataruns are performed (file content has changed). The information found in this transaction is not complete, and it contains just the new values added to the existing datarun list. It also contains a relative offset that tells us where in the datarun list the changes have been written. This offset is used in combination with the offset to datarun as found in InitializeFileRecordSegment and CreateAttribute.

**SetNewAttributeSizes** is a transaction that contains information about any size value related modifications done to the $DATA attribute. This is tightly connected to UpdateMappingPairs which only contains datarun changes.

With the above 4 different redo operations can for a given reference number (distinct file) reconstruct some of the filesystem change history of file. Because of the circularity of it, we only have part of the history, the most recent. The extent of the history we can retrieve highly depends on what kind of volume the target is. If it is a system volume, then a week of history is probably more than you could expect, while a removable or external or secondary disk will contain far more history. Thus we may reconstruct the full history of a deleted file (having it's $MFT record overwritten), and in turn recreate the datarun list to perform recovery upon. In other cases we may not be able to reconstruct the full history, so only a partial datarun list can be reconstructed. The final csv file with the adjusted dataruns, LogFile\_DatarunsModified.csv, will have the dataruns displayed differently.

**Explanation**
  * Those starting with a '!' indicates the complete datarun list has been recreated.
  * Those starting with a '?' indicates a partial recovery, with the number of 'stars' representing missing nibbles off the original datarun list.

To simplify recovery of a file based on a datarun, one can use the attached PoC called ExtractFromDataRuns. It is quite self explanatory. Just fill in the complete datarun list, the real size and init size, and a name for the output file. Optionally choose to process image files (disk or partition). Also tick off if any compressed/sparse flag have been detected. Feeding it with a partially reconstructed datarun list will not work! Please note that alternate data streams can be distinguished by the presence of a dataname and also by a differing OffsetInMft values for a given fileref.

The separate download package "SampleTinyNtfsVolume.zip" have a partition image with a small NTFS volume to test it on. On the volume there are 2 deleted non-resident files which both have their MFT record overwritten by new files. Any decent recovery software based on data carving (signature or magic number searching) should be able to recover the jpg file (Tulips.jpg), because it is contigous. However, they most likely will not identify its filename, or anything other about the file. The second file will likely not be recoverable using standard tools, because it is fragmented (compressed), and by having its MFT record overwritten, resoving the file without the datarun list is impossible. Using the PoC we can identify the filename (suspicious.zip) and extract it into perfect shape (don't worry it only contains the 7-zip installer). Read the file readme.DataRunsResolved.txt for the details about the sample image and how to interpret output and recover the files.

This is what a sample report for reconstructed dataruns may look like;

![http://i1100.photobucket.com/albums/g407/joakimschicht/SampleReportDataRuns_zps00c072e4.png](http://i1100.photobucket.com/albums/g407/joakimschicht/SampleReportDataRuns_zps00c072e4.png)

The utility to extract from dataruns;

![http://i1100.photobucket.com/albums/g407/joakimschicht/ExtractFromDataruns1002_zpse1c723b8.png](http://i1100.photobucket.com/albums/g407/joakimschicht/ExtractFromDataruns1002_zpse1c723b8.png)

What we have achieved with this is to recover fragmented files which have their MFT record overwritten. Since we have reconstructed partial/complete datarun history, we can with certainty (at least if full history is reconstructed) determine whether file slack data have belonged to the given file or not.


# $LogFile in Volume Shadow Copies #
You can use the NTFS file extractor; http://code.google.com/p/mft2csv/wiki/NTFS_File_Extracter which supports extraction directly from Volume Shadow Copies. Click "Scan Shadows" to get a listing, then select one and click "Test it" to check if volume appears valid. Go with the "User Select" option which will present you with an input box, after pressing "Start Extraction". Then you can type in a comma separated list of MFT reference numbers you want to extract. This can be handy, to get previous versions of $MFT and $LogFile.

![http://i1100.photobucket.com/albums/g407/joakimschicht/NTFSFileExtractor402_zpse7a29230.png](http://i1100.photobucket.com/albums/g407/joakimschicht/NTFSFileExtractor402_zpse7a29230.png)

# Limitation #
  1. Decode does not yet cover $Secure.
  1. Circularity of a 65 MB file poses inherent and absolute restriction on how many historical FS transtions. Systemdrives thus have limited history in $LogFile, whereas external/secondary drives have more histrocal transtions stored. Can increase size of $LogFile with chkdsk (chkdsk c: /L:262144).
  1. Changes to the data of resident files are not stored within $LogFile, only information that a change was done is stored.
  1. If the volume originates from a nix based system, chances are that the $LogFile will contain very little information, which makes parsing much less helpful.

# Note #
  * The $UsnJrnl contains information in a more human friendly way. For instance each record contains fileref, filename, timestamp and explanation of what occurred. It also contains far more historical information than $LogFile, though without a lot of details. From version 1.0.0.14 there is no need to parse $UsnJrnl in order to aid in decoding $LogFile,as all USN records are decoded within the $LogFile.

# ToDo #
  * Implement more analysis of data present in the generated database file ntfs.db.

# Known issues #
  * The 64-bit version seems to sometimes have issues with sqlite3, so better stick to 32-bit which is stable.

# Latest version #
v1.0.0.20

# Changelog #
v1.0.0.17. Another major improvement in the identification of the current attribute.

v1.0.0.16. Fixed bug that caused $UsnJrnl to sometimes be incorrectly displayed in the lf\_TextInformation column.

v1.0.0.15. Fixed CurrentAttribute when $UsnJrnl is writing zeros to align the initialized data to page boundary. Added reference to LogFile\_INDX.csv in column lf\_TextInformation where due. Corrected CurrentAttribute for both UpdateFileNameRoot and UpdateFileNameAllocation, and changed their timestamps from being FN to SI. Changed interpreted meaning of op code 1000 = ResetAllocation, and 1100 = ResetRoot.

v1.0.0.14. More fixes to the OpenNonresidentAttribute. Now current attribute is displayed even more detailed like this: $DATA:$SDS, $INDEX\_ALLOCATION:$I30, $INDEX\_ALLOCATION:$O. Added decode information for DeleteAttribute operations. Fixed a bug that caused certain corrupted values to be displayed as decoded UsnJrnl record values. Added more mapping to filename for transactions. Some minor adjustments on the logic/prediction of reference numbers. Added new column for namespace, and real reference. The new column lf\_RealMFTReference facilitated the addition of a lot more decode output into the core LogFile csv.

v1.0.0.13. Fixed decode of OpenNonresidentAttribute, which may appear differently in certain scenarios. Fixed bug in the integrated UsnJrnl parser. Fixed mapping of MFT ref for SetIndexEntryVcnAllocation operations. Added more decoding to UpdateNonResidentValue operations. Added decode of operation code 1000, which is a clearing of an index. Specifically the redo operation is just a reset, while the undo operation is a complete INDX record (without header) of the original content. With this information it is now possible to start building a history of changes to directory content/indexes.

v1.0.0.12. Fixed a new bug in the reconstruction of dataruns that was introduced in previous version.

v1.0.0.11. Implemented GUI with configurable options, progressbar etc. Fixed a lot of issues when resolving MFT references. Fixed bug that incorrectly updated CurrentAttribute when redo operation was UpdateResidentValue. Added decoding of OpenNonresidentAttribute. Added 3 columns in output: TextInformation, RedoChunkSize and UndoChunkSize. Added more updating of CurrentAttribute. Using undo operations to aid in interpreting data. Changed default separator to "|" to minimize chances for hitting filenames that needed to be changed. Added importing to db of the resolved dataruns csv. Added option to import csv of decoded MFT (mft2csv), and joining file paths. Added option to choose timestamp format and precision, with example displayed in gui. Option to split extra timestamps into separate csv (will slow down processing!).

v1.0.0.5. Added missing reparse types. Added filtering on attribute type for index decoding ($FILE\_NAME -> $I30). Removed program exit when import of indx csv failed. Fixed serious bug when loading the sqlite3 dll. The dll is now included. Added more error checking with the sqlite3 stuff.

# References #
  1. Windows Internals 6th Edition
  1. http://www.opensource.apple.com/source/ntfs/ntfs-80/kext/ntfs_logfile.h
  1. http://forensicinsight.org/wp-content/uploads/2012/05/INSIGHT_A-Dig-into-the-LogFile.pdf
  1. https://dl.dropbox.com/s/c0u980a53ipaq7h/CEIC-2012_Anti-Anti_Forensics.pptx?dl=1