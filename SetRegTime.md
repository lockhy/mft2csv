# Introduction #

It is a small utility providing only 1 feature. And that is to manipulate registry key's timestamp (LastWriteTime). From what I have read about forensics and registry, I got the impression that information about timestamp manipulation in registry was lacking. Worth mentioning that I have by no means read the entire litterature on the field, so I may be slightly off. Still, I believe there is some news to be found on this page. My goal is to shed some light on the reality that registry timestamp manipulation is in fact very trivial. As a consequence it further reinforces the importance of proper (timeline) analysis, to get at the full picture and detect such attempts at timestamp modification. So I decided to make a proof of concept.


# Details #

The LastWriteTime timstamps that every registry key has, is similar to NTFS timestamps. They are 64-bit in UTC and  counted in 100 nanosec since 01 January 1601. There does not exist such timestamp for registry values, only for keys.

The tool will let you set any timestamp within the whole 64-bit range. It takes immediate effect, as the key is flushed to disk instantly. Since it uses native NT apis in ntdll.dll, it does not work with user friendly registry names like HKEY\_LOCAL\_MACHINE, HKCU etc. It uwill only take the Windows internal registry names, those starting with \Registry\... Below is a listing of the most important translations:
| **User mode** | **Internal** |
|:--------------|:-------------|
| HKEY\_LOCAL\_MACHINE | \registry\machine |
| HKEY\_USERS   | \registry\user |
| HKEY\_CURRENT\_USER | \registry\user\user\_sid |
| HKEY\_CLASSES\_ROOT | \registry\machine\software\classes |
| HKEY\_CURRENT\_CONFIG  |\Registry\Machine\System\CurrentControlSet\Hardware Profiles\Current |

The user sid is the one similar to this: S-1-5-21-2895024241-3518395705-1366494917-288



**Syntax is:**

SetRegTime.exe RegPath timestamp switch

  * RegPath is a path similar to the ones listed above.

  * Timestamp is in the format YYYY:MM:DD:HH:MM:SS:MSMSMS:NSNSNSNS

  * Switch can be "-s" for recursive mode, or "-n" for singel key




**Some real world command examples:**

  * Reading timestamp:

SetRegTime\_x64.exe "\Registry\Machine\Software\test"

  * Writing timestamp recursively:

SetRegTime\_x64.exe "\Registry\Machine\Software" "1743:04:01:00:00:00:000:0000" -s

  * Writing timestamps on singel keys:

SetRegTime\_x64.exe "\Registry\Machine\System\mounteddevices" "1976:04:01:00:00:00:000:0000" -n

SetRegTime\_x64.exe "\Registry\Machine\Security\policy\polacdms" "1944:12:24:00:00:00:000:0000" -n




Some images to lighten up the dry material:

![http://i402.photobucket.com/albums/pp106/jokke49/Set_Run.png](http://i402.photobucket.com/albums/pp106/jokke49/Set_Run.png)

![http://i402.photobucket.com/albums/pp106/jokke49/Get_Run.png](http://i402.photobucket.com/albums/pp106/jokke49/Get_Run.png)

![http://i402.photobucket.com/albums/pp106/jokke49/Set_MountedDevices.png](http://i402.photobucket.com/albums/pp106/jokke49/Set_MountedDevices.png)

![http://i402.photobucket.com/albums/pp106/jokke49/Get_MountedDevices.png](http://i402.photobucket.com/albums/pp106/jokke49/Get_MountedDevices.png)

![http://i402.photobucket.com/albums/pp106/jokke49/Set_Security.png](http://i402.photobucket.com/albums/pp106/jokke49/Set_Security.png)

![http://i402.photobucket.com/albums/pp106/jokke49/Get_Security.png](http://i402.photobucket.com/albums/pp106/jokke49/Get_Security.png)

Notice how the modifications look like in the output from RegRipper.

Now usually you will not get access to the security hive just like that, so instead we launch a process from the local system account, and then we have full access. A sample program for launching cmd from the system account (RunasSystem) can be found in the download section. Maybe not very surprising that we can do almost anything when the process is running as SYSTEM.

The timstamp format is like this; YYYY:MM:DD:HH:MM:SS:MSMSMS:NSNSNSNS

Setting the timestamps way off, like for instance outside the range for unix time, may prevent certain tools from decoding the true timestamp. Other tools may only decode timestamps correctly when they are within a certain range, because they where coded so. In these cases, extreme timestamps like 1766 or 2387, may not be decoded/displayed. This particular "issue", if one can call it, really has nothing to do with the point being raised on this page. It is just worth noting that this "issue" may be observed when using certain tools, and so that you now know why strange decode-behaviour may occur.

What important winapi are utilized?
  * NtCreateKey
  * NtOpenKey
  * NtSetInformationKey
  * NtEnumerateKey
  * NtQueryKey
  * NtFlushKey

The NtFlushKey is strictly not needed, but I used it to be absolutely sure that the modification is written to disk instantly.

This was tested on Windows 7 SP1 x64 and XP SP3 x86, so I would assume it working on most modern Windows versions.

Note:
To retrieve the current timestamp of a given key, run the tool with just the key path as parameter (ie exclude the timestamp parameter).

# Latest version #
v1.0.0.4

# Changelog #
v1.0.0.4: Added recursion as optional processing.