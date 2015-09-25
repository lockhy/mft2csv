# Project have been moved to: https://github.com/jschicht #

# Introduction #

The tool resolves content in directories by resolving INDX ($I30) records. It is very powerful and easy to use. It has 2 mode, one verbose output and one compact output.

# Details #

The output of mode 2 (verbose) will include the following for each entry within the INDX:

  * Entry number
  * FileName
  * MFT Ref
  * MFT Ref SeqNo
  * Parent MFT Ref
  * Parent MFT Ref SeqNo
  * Flags
  * File Create Time
  * File Modified Time
  * MFT Entry modified Time
  * File Last Access Time
  * Allocated Size
  * Real Size
  * NameSpace
  * IndexFlags
  * SubNodeVCN

Timestamps are presented in UTC 0.00 at the nanosec precision. Format is YYYY-MM-DD HH:MM:SS:MSMSMS:NSNSNSNS

# Syntax #

**Example printing verbose output from the hidden system folder C:\$Extend
  * RawDir.exe 1 C:\$Extend**

**Example printing compact output on the root of the C: volume**
  * RawDir.exe 2 C:\

# Limitation #
Will not show files marked as deleted.

# Current version #
v1.0.0.2

# Changelog #
v1.0.0.0: First version.