# Project have been moved to: https://github.com/jschicht #

# Introduction #

This program will turn a regular file into an NTFS system file, by changing it's MFT reference number to one between 12 and 15, which are reserved by the filesystem. By doing this, the file becomes invisible and protected from modification. By invisible it means, no tool depending on the filsystem like for instance explorer or the dir command will see it. However the filesystem regard it as a systemfile, and will thus prevent writing any file to that location with that name. It is like when you try to create a file named $MFT in the root of the volume, which the filesystem will prevent you from doing. The only way to modify this file is by a hex editor writing to physical disk. Alternatively you could extract the file from volume (datarecovery), modify the extracted file, and then lastly use the tool to inject it back into the same MFT reference number as it was. In other words it is impossible to overwrite such a file.


# Details #

What we do is we take a copy of the original MFT record and write it to the location of where the record of the new MFT reference number is located. We wipe (or mark as deleted) the original record. Then we modify the backup, change MFT ref and sequence number, and write it to disk. Then we let chkdsk do the rest of the job to make Windows happy about the new NTFS systemfile (it will correct timestamps in $FILE\_NAME attribute, update flags in both $STANDARD\_INFORMATION and $FILE\_NAME ATTRIBUTE, correct the index in $I30 in the root directory (MFT ref 5), and a few more like in $Bitmap. These last steps are tricky if done manually, so using chkdsk for it is all fine.


# Usage #

Example using path to source file and target IndexNumber 12:
  * HideAndProtect.exe C:\bootmgr 12

Example using IndexNumber of source file (33) on volume C: and target IndexNumber 13:
  * HideAndProtect.exe C:33 13

Example to wipe the record of MFT reference number 14 on volume C:
  * HideAndProtect.exe C:W 14


# Practical Use #
Hide and protect up to 4 files per NTFS volume.

  * If you want to reserve certain file names, it can be achieved with this tool. For instance you may want to prevent the creation of certain files, like for instance autorun.inf.
  * You want to hide your boot files. I have tested with hidden bootmgr, which booted fine. Also tested with grub4dos, which in addition to be hidden itself, also could handle hidden iso's (and probably more).


# Limitation #

At nt6.x new security measures have been implemented, preventing you from writing directly to sectors inside filesystem. Before doing anything like this, we obtain a lock on the target volume. However, this is not possible to in a few situations (systemdrive, volume where pagefile is on, volume where HideAndProtect is run from, and maybe a ew more). These restrictions do not apply for nt5.x (anything before Vista). In any case there is an absolute restriction of a maximum of 4 files per volume that you can hide. Basically any file or folder can be converted. However a few restrictions apply (at least with this tool):
  * Target can not have $ATTRIBUTE\_LIST in its MFT record (content span across several MFT records).
  * Content in subdirectories, except root dir.
  * New MFT reference must be between 12 and 15.


# Warning #

Due to the very hacky nature of this application, you must understand that this may corrupt your filesystem, and that I take no responsibility for what this application may cause. Use at own risk! Important to close any open files on the target volume before trying this.

# Testing #
The tool has been tested with success on XP SP2 32-bit and Windows 7 SP1 64-bit.

# Current Version #
v1.0.0.2

# Changelog #
v1.0.0.1. Added option to wipe/delete previous hack. Added help/usage printed to console. More understandable and direct information for how to and when to use chkdsk after modification.

v1.0.0.0. First version.

# Credits #
User DeltaRocked at autoit forums who made me aware of this trick