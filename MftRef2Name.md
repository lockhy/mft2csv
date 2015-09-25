# Project have been moved to: https://github.com/jschicht #

# Introduction #

A simpel tool that just converts MFT reference number to file name and path, or the other way around. It is handy to have and very easy to use. It takes only 1 parameter, the target. It should be able to resolve any reference number if it is present in $MFT. Also any filename and path will work, as long as it is valid on the filesystem.


# Syntax #

MftRef2Name.exe Target

**Example resolving the USN journal file C:\$Extend\$UsnJrnl**
  * MftRef2Name.exe C:\$Extend\$UsnJrnl

**Example resolving the directory C:\WINDOWS**
  * MftRef2Name.exe C:\WINDOWS

**Example resolving MFT reference number 3366 on the C: volume**
  * MftRef2Name.exe C:3366

# Limitation #
If the target has been marked as deleted, resolving the path is aborted, as it may turn incorrect.

# Current version #
v1.0.0.1

# Changelog #
v1.0.0.0: First version.