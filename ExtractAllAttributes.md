# Introduction #

This another specialized tool for NTFS. It extracts all attributes for a given MFT reference. Normally when extracting files off an NTFS volume, you are extracting the $DATA attribute. With this tool you can extract all attributes in one go.

![http://i1100.photobucket.com/albums/g407/joakimschicht/ExtractAllAttributes_zpsd148c66b.png](http://i1100.photobucket.com/albums/g407/joakimschicht/ExtractAllAttributes_zpsd148c66b.png)


# Details #

Just like with the $DATA attribute, there is an attribute header, and the core attribute content (think of it as the data), can be resident or non-resident. The attribute can be named too (not the same as the attribute type). Ie, the $FILE\_NAME is an attribute type that contains the name of a file as displayed on the filesystem. However, the attribute itself, is un-named. Take Alternate Data Streams as an example. They are named $DATA attributes. Another example is INDX records, which can be of different types. Maybe the most familiar one is the $I30. Here, $I30 is the name of the stream and the attribute type is $INDEX\_ALLOCATION. As an exercise you can extract MFT reference 5 and 9, and see what gets extracted.

Features:
  * Partition and disk images.
  * Disk images can be of either MBR or GPT style.
  * Direct access into Volume Shadow Copies.
  * Direct access to PhysicalDrive and into un-mounted volumes.
  * Mounted volumes.
  * Browse to target file on mounted volumes.
  * Specify MFT reference number in all other modes than "Browse".
  * Supports compression and fragmentation.
  * Handles attribute lists.

**The tool can thus in theory extract an unlimited amount of attributes of any kind for a given file.**

Default output directory is current directory.

The format of the output files are:

MFTRef + underscore + attribute type + underscore + stream name + underscore + attribute type counter + bin extension

This is how output looked like after extracting the atributes for MFT ref 9 ($Secure):

![http://i1100.photobucket.com/albums/g407/joakimschicht/AllAttributesOutput_zps6c8cea54.png](http://i1100.photobucket.com/albums/g407/joakimschicht/AllAttributesOutput_zps6c8cea54.png)

**Example 1:**

"1_$DATA__1.bin"_

Explanation:
  * MFT reference number = 1
  * Attribute type = $DATA
  * Stream name = "" (empty)
  * Attribute counter = 1 (meaning it is the first $DATA attribute for that particular file.

**Example 2:**

'9_$INDEX\_ALLOCATION_$SII\_2.bin'

Explanation:
  * MFT reference number = 9
  * Attribute type = $INDEX\_ALLOCATION
  * Stream name = $SII
  * Attribute counter = 2 (the second $INDEX\_ALLOCATION attribute)

# ToDo #
Option to extract only particular attributes.

# Current Version #
v1.0.0.1

# Changelog #
v1.0.0.0. First version.