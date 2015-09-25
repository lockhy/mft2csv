# Project have been moved to: https://github.com/jschicht #

# Description #
This tool will extract files from an NTFS volume. It supports resident, non-resident, compressed, sparse, normal, alternate data streams (ADS). It has several different methods/modes to choose from.  In short the choices are:
  * Mounted volume, image file, direct access to \\.\PhysicalDriveN, detect and access shadow copies
  * Active files, deleted files, or all files.
  * Choose individual files based on their index number.

At program start all mounted NTFS volumes are populated in the second combobox at the top. You can also rescan for volumes by pressing the button 'Rescan Mounted Drives'.

To scan \\.\PhysicalDrive for attached disks press the button "Scan Physical". The detected drives will be visible in the first combo at the top. Select a drive and press the button "Test it". The detected NTFS volumes on the drive will be displayed in the second combo. Select what files to extract and press "Start Extraction" to start extracting the files.

To scan for shadow copies press the button "Scan Shadows". The detected shadow copies will be visible in the first combo at the top. Select a shadow copy and press the button "Test it" to get detected NTFS volumes. The result is displayed in the second combo. Select what files to extract and press "Start Extraction" to start extracting the files.

By default the output directory is set to the directory the program is executed from. In order to set it differently, press the button 'Choose Output'.

Selecting the target volume is done by choosing the right one in the combobox. When using image file, the detected volumes in the image are populated into the combobox, where you can choose the right one.
The support for image files are for disk and partition images. For disk images both MBR and GPT style are supported.

When choosing which files to extract from target volume, choose right selection on the left side from:
  * All (both active and deleted)
  * Deleted (only deleted files)
  * Active (only active files)
  * User Select (choose files to extract based on their index number)

The 'User Select' mode will fire up an input box after you have pressed 'Start Extraction'. In there you can put a comma separated list of the index numbers you want to have extracted. For instance if you want to extract $MFT and $LogFile you will enter '0,2' which are their respective index numbers.

Extracted Alternate Data Streams (ADS) will be outputted in the format:
  * basefile.ext[ADS\_adsname.ext]

Extracted files that have been deleted are outputted in the format:
  * [DEL+IndexNumber]FileName.ext

Because of this prefix of deleted files, there is a possibility of running into file paths that are too long to make your filesystem happy. This possible issue will only be relevant if extracting deleted files that was stored inside a deep path where the whole path have been deleted. This prefix is necessary though to differentiate deleted from active files.

Reparse points and hardlinks are extracted as they are, which means they will have the correct type set, but the link will always point to the extracted target, and not the original target.

Since this tool extract directly off physical disk, it will effectively bypass any file access restriction/security otherwise imposed by the filesystem. For instance the SAM or SYSTEM hive, or the pagefile can be extracted by using their index numbers. And obviously the same also goes for the NTFS systemfiles/metafiles which are not even visible in explorer.

The extracted $MFT is perfect to feed into mft2csv, which will decode the file records and produce a csv with the information.

The tools have been tested on almost all recent Windows version, from 32-bit XP to 64-bit Windows 8, and it works great.


# Latest Version #

v4.0.0.3

# Changelog #
v4.0.0.2 Added support for extracting from shadow copies.

v4.0.0.1 Fixed the flag filter to also include 0x04/0x05 (deactivated/active $UsnJrnl). Added support for accessing \\.\PhysicalDriveN, and thus completely removing the requirement of having a mounted volume to extract from.

v4.0.0.0 Merged together the data recovery tool. Added full native support for reparse points. Option to choose between Active files, deleted files, and All files. Option to choose individual files. Support for image files. Added nice progress bars.

v3.2 Changes by DDan implmented that fixed slightly wrong data extracted when initialized file size differed from logical filesize. Some other minor things too.

v3.1 Added generation of some MFT arrays with indexnumber and disk offset, to speed up processing of files with attribute list (for instance fragmented and/or compressed files).

v3.0 With quite substantial support from DDan, much of the code was reorganized and improved. Most importantly, compression and sparse files are now fully supported. Complete $ATTRIBUTE\_LIST is also solved. Full support for ADS's are also added. Plus a lot more that makes the code easier to reuse.

v1.6 Temporary fix for $MFT record size, now fixed at 1024 bytes (2 sectors) (but must be changed to correct formula later anyway), that caused issues on certain volumes. Also fixed support for unicode names in output.

Added preliminary/experimental support for extraction of compressed files.

v1.5 Fixed extraction of resident data. Temporarily forgot that ReadFile on physical disks only handle chunks of data aligned to sector size.

v1.4 Solved several bugs in the solution that calculated runs. Negative moves where reloved wrongly. And very fragmented files with runs located past record offset 0x1fd was also incorrectly solved. Actually that last fix also fixed decoding of attributes extending over that same offset. Note however that compressed and/or sparse files are not yet supported for extraction. I therefore added a break when trying to extract such a file.

v1.3 Added a FileSelectFolder function to specify where to save the output. Removed the default ".bin" extension, so that the outputted extension is as given in $MFT.

v1.2 Large files are now supported, because extraction split chunks in 40 MB each at most. That means the $LogFile or any other large file can be exported fine. Also fixed fragmentation in $MFT itself when attempting raw extract functionality by record number. That means it should now work regardless of size and fragmentation in either $MFT or target file. The extraction now also targets real size as opposed to allocated size, and prevents slack data to be appended.

v1.1. Tiny error inside the function _GetAllRuns() as well as when calling it. Wrong variabel name was used pluss a wrong offset. I believe runs are correctly solved now as my SOFTWARE hive is extractable and mountable. But because $MFT fragmentation is not really working I've temporarily put a hardcoded exit after record 1000, until it's fixed._


# ToDo #

  * Optionally choose which attribute to extract.

# Thanks and credits #

  * DDan at forensicfocus for being an enormous contributor both with code and advice.
  * AutoIt forums (KaFu & trancexxx) where the starter code was provided; http://www.autoitscript.com/forum/topic/94269-mft-access-reading-parsing-the-master-file-table-on-ntfs-filesystems/