**Note: Projects have been moved to: https://github.com/jschicht**


This is a suite of NTFS and security utilities.

The application NTFS File Extracter can export systemfiles (metafiles) off an NTFS volume. In fact, it can extract any file off the volume by traversing the $MFT and resolving all runs (if its record is intact and its sectors not overwritten). It will thus bypass filesystem security.

The mft2csv application will take an $MFT file as input and ripp information from all its records and log it to a csv file. A rather large amount of data is currently decoded. The point is to save all information to a csv (well supported format) for later analysis.

The MFTRCRD application is a commandline file information dumper. It will dump all information that mft2csv can decode, and also have the option to dump the $MFT record of target file to the console. Additionally it displayes detailed runs information.

SetMACE is a NTFS timestamp manipulating tool. It is nice to run alongside with MFTRCRD when testing stuff on NTFS.

Tiny\_NTFS is an older project of mine, the smallest possible NTFS partition.

SetRegTime is a PoC for manipulating timestamps in the registry.

LogFileParser is a tool for decoding and dumping of $LogFile.

StegoMft is a PoC for hiding data within $MFT.

AutoIt is a scripting language that is easy to work with and understand, which makes it appealing for many people. It is therefore very easy to customize the source of these provided apps to fit whatever you would like it to. Read the respective wiki pages for more details about them.

Currently developed by Joakim Schicht