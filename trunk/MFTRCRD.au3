#RequireAdmin
#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Change2CUI=y
#AutoIt3Wrapper_Res_Comment=Quick $MFT record dump
#AutoIt3Wrapper_Res_Description=Decode some of the attributes
#AutoIt3Wrapper_Res_Fileversion=1.0.0.3
#AutoIt3Wrapper_Res_LegalCopyright=Joakim Schicht
#AutoIt3Wrapper_Res_requestedExecutionLevel=asInvoker
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
#include "_WinTimeFunctions2.au3"
#include <FileConstants.au3>
#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#include <StaticConstants.au3>
#include <EditConstants.au3>
#include <GuiEdit.au3>
#Include <WinAPIEx.au3>
#Include <WinAPI.au3>
#Include <APIConstants.au3>
#Include <Date.au3>
#include <Array.au3>
#Include <String.au3>
;Opt("MustDeclareVars", 1)
Global Const $FileBasicInformation = 4
Global Const $FileInternalInformation = 6
Global Const $OBJ_CASE_INSENSITIVE = 0x00000040
Global Const $FILE_DIRECTORY_FILE = 0x00000002
Global Const $FILE_NON_DIRECTORY_FILE = 0x00000040
Global Const $FILE_RANDOM_ACCESS = 0x00000800
Global Const $tagFILEBASICINFO = "int64 CreationTime;int64 LastAccessTime;int64 LastWriteTime;int64 ChangeTime;ulong FileAttributes;"
Global Const $tagIOSTATUSBLOCK = "dword Status;ptr Information"
Global Const $tagOBJECTATTRIBUTES = "ulong Length;hwnd RootDirectory;ptr ObjectName;ulong Attributes;ptr SecurityDescriptor;ptr SecurityQualityOfService"
Global Const $tagUNICODESTRING = "ushort Length;ushort MaximumLength;ptr Buffer"
Global Const $tagFILEINTERNALINFORMATION = "int IndexNumber;"
Global $file = ""
Global $file2 = ""
Global $IsDirectory = 0, $AttributesArr[18][4], $SIArr[13][4], $FNArr[14][1], $RecordHdrArr[15][2], $FinalOffset, $ObjectIDArr[5][2], $DataArr[20][2]
Global $FormattedTimestamp, $FormattedTimestamp1, $filesystem, $drive, $CreationTime2, $LastAccessTime2, $LastWriteTime2, $ChangeTime2, $IsDirectory
Global $CreationTime, $LastAccessTime, $LastWriteTime, $ChangeTime, $CreationTime3, $LastAccessTime3, $LastWriteTime3, $ChangeTime3
Global $HEADER_LSN,$HEADER_SequenceNo,$HEADER_Flags,$HEADER_RecordRealSize,$HEADER_RecordAllocSize,$HEADER_FileRef,$HEADER_NextAttribID,$HEADER_MFTREcordNumber,$Header_HardLinkCount
Global $SI_CTime,$SI_ATime,$SI_MTime,$SI_RTime,$SI_FilePermission,$SI_USN,$Errors,$DATA_AllocatedSize,$DATA_RealSize,$DATA_InitializedStreamSize,$RecordSlackSpace
Global $FN_CTime,$FN_ATime,$FN_MTime,$FN_RTime,$FN_AllocSize,$FN_RealSize,$FN_Flags,$FN_FileName,$DATA_VCNs,$DATA_NonResidentFlag,$FN_NameType
Global $FN_CTime_2,$FN_ATime_2,$FN_MTime_2,$FN_RTime_2,$FN_AllocSize_2,$FN_RealSize_2,$FN_Flags_2,$FN_NameLength_2,$FN_NameSpace_2,$FN_FileName_2,$FN_NameType_2
Global $FN_CTime_3,$FN_ATime_3,$FN_MTime_3,$FN_RTime_3,$FN_AllocSize_3,$FN_RealSize_3,$FN_Flags_3,$FN_NameLength_3,$FN_NameSpace_3,$FN_FileName_3,$FN_NameType_3
Global $FN_CTime_4,$FN_ATime_4,$FN_MTime_4,$FN_RTime_4,$FN_AllocSize_4,$FN_RealSize_4,$FN_Flags_4,$FN_NameLength_4,$FN_NameSpace_4,$FN_FileName_4,$FN_NameType_4
Global $DATA_NameLength,$DATA_NameRelativeOffset,$DATA_Flags,$DATA_NameSpace,$DATA_Name,$RecordActive,$DATA_CompressionUnitSize,$DATA_CompressionUnitSize_2,$DATA_CompressionUnitSize_3
Global $DATA_NonResidentFlag_2,$DATA_NameLength_2,$DATA_NameRelativeOffset_2,$DATA_Flags_2,$DATA_NameSpace_2,$DATA_Name_2,$DATA_StartVCN_2,$DATA_LastVCN_2,$DATA_VCNs_2,$DATA_AllocatedSize_2,$DATA_RealSize_2,$DATA_InitializedStreamSize_2
Global $DATA_NonResidentFlag_3,$DATA_NameLength_3,$DATA_NameRelativeOffset_3,$DATA_Flags_3,$DATA_NameSpace_3,$DATA_Name_3,$DATA_StartVCN_3,$DATA_LastVCN_3,$DATA_VCNs_3,$DATA_AllocatedSize_3,$DATA_RealSize_3,$DATA_InitializedStreamSize_3
Global $FN_ParentReferenceNo,$FN_ParentSequenceNo,$FN_ParentReferenceNo_2,$FN_ParentSequenceNo_2,$FN_ParentReferenceNo_3,$FN_ParentSequenceNo_3,$FN_ParentReferenceNo_4,$FN_ParentSequenceNo_4,$RecordHealth
Global $DATA_LengthOfAttribute,$DATA_OffsetToAttribute,$DATA_IndexedFlag,$DATA_LengthOfAttribute_2,$DATA_OffsetToAttribute_2,$DATA_IndexedFlag_2,$DATA_LengthOfAttribute_3,$DATA_OffsetToAttribute_3,$DATA_IndexedFlag_3
Global $hFile, $nBytes, $MSecTest, $CTimeTest,$SI_MaxVersions,$SI_VersionNumber,$SI_ClassID,$SI_OwnerID,$SI_SecurityID,$SI_HEADER_Flags,$STANDARD_INFORMATION_ON,$ATTRIBUTE_LIST_ON,$FILE_NAME_ON,$OBJECT_ID_ON,$SECURITY_DESCRIPTOR_ON,$VOLUME_NAME_ON,$VOLUME_INFORMATION_ON,$DATA_ON,$INDEX_ROOT_ON,$INDEX_ALLOCATION_ON,$BITMAP_ON,$REPARSE_POINT_ON,$EA_INFORMATION_ON,$EA_ON,$PROPERTY_SET_ON,$LOGGED_UTILITY_STREAM_ON,$ATTRIBUTE_END_MARKER_ON
Global $GUID_ObjectID,$GUID_BirthVolumeID,$GUID_BirthObjectID,$GUID_BirthDomainID,$VOLUME_NAME_NAME,$VOL_INFO_NTFS_VERSION,$VOL_INFO_FLAGS,$INVALID_FILENAME,$INVALID_FILENAME_2,$INVALID_FILENAME_3,$DATA_Number
Global $FileSizeBytes, $IntegrityCheck,$DATA_Length,$DATA_AttributeID,$DATA_OffsetToDataRuns,$DATA_Padding,$DATA_Length_2,$DATA_AttributeID_2,$DATA_OffsetToDataRuns_2,$DATA_Padding_2
Global $FN_Number,$DATA_Number,$SI_Number,$ATTRIBLIST_Number,$OBJID_Number,$SECURITY_Number,$VOLNAME_Number,$VOLINFO_Number,$INDEXROOT_Number,$INDEXALLOC_Number,$BITMAP_Number,$REPARSEPOINT_Number,$EAINFO_Number,$EA_Number,$PROPERTYSET_Number,$LOGGEDUTILSTREAM_Number
Global $DateTimeFormat = 6 ; YYYY-MM-DD HH:MM:SS:MSMSMS:NSNSNSNS = 2007-08-18 08:15:37:733:1234
Global $tDelta = _WinTime_GetUTCToLocalFileTimeDelta() ; in offline mode we must read the values off the registry..
Global $List[30], $Drive = DriveGetDrive('All')
Global $tSTORAGE_DEVICE_NUMBER, $Volume, $hFile, $SectorsPerCluster, $testfile, $MFT_Record_Size, $RunListOffset
;Global Const $HX_REF="0123456789ABCDEF"
Global $RUN_Cluster[1], $RUN_Sectors[1], $MFT_RUN_Cluster[1], $MFT_RUN_Sectors[1], $RUN_Sparse[1], $MFT_RUN_Sparse[1], $RUN_Complete[1][4], $MFT_RUN_Complete[1][4]
Global $nBytes, $MFT_Offset, $bytes_to_read, $tBuffer, $hdd_handle, $hFile, $MFTFull;, $MFTEntry
Global Const $RecordSignature = '46494C45' ; FILE signature
Global Const $RecordSignatureBad = '44414142' ; BAAD signature
;Global Const $MFT_Record_Size = 1024
Global Const $STANDARD_INFORMATION = '10000000'; Standard Information
Global Const $ATTRIBUTE_LIST = '20000000'
Global Const $FILE_NAME = '30000000' ; File Name
Global Const $OBJECT_ID = '40000000' ; Object ID
Global Const $SECURITY_DESCRIPTOR = '50000000'
Global Const $VOLUME_NAME = '60000000'
Global Const $VOLUME_INFORMATION = '70000000'
Global Const $DATA = '80000000' ; Data
Global Const $INDEX_ROOT = '90000000' ; Index Root
Global Const $INDEX_ALLOCATION = 'A0000000' ; Index Allocation
Global Const $BITMAP = 'B0000000' ; Bitmap
Global Const $REPARSE_POINT = 'C0000000'
Global Const $EA_INFORMATION = 'D0000000'
Global Const $EA = 'E0000000'
Global Const $PROPERTY_SET = 'F0000000'
Global Const $LOGGED_UTILITY_STREAM = '00010000'; 0x100
Global Const $ATTRIBUTE_END_MARKER = 'FFFFFFFF'
Global Const $ATTRIB_HEADER_FLAG_COMPRESSED = 0x0001
Global Const $ATTRIB_HEADER_FLAG_ENCRYPTED = 0x4000
Global Const $ATTRIB_HEADER_FLAG_SPARSE = 0x8000
Global Const $SI_FILE_PERM_READ_ONLY = 0x0001
Global Const $SI_FILE_PERM_HIDDEN = 0x0002
Global Const $SI_FILE_PERM_SYSTEM = 0x0004
;Global Const $SI_FILE_PERM_DIRECTORY = 0x0010
Global Const $SI_FILE_PERM_ARCHIVE = 0x0020
Global Const $SI_FILE_PERM_DEVICE = 0x0040
Global Const $SI_FILE_PERM_NORMAL = 0x0080
Global Const $SI_FILE_PERM_TEMPORARY = 0x0100
Global Const $SI_FILE_PERM_SPARSE_FILE = 0x0200
Global Const $SI_FILE_PERM_REPARSE_POINT = 0x0400
Global Const $SI_FILE_PERM_COMPRESSED = 0x0800
Global Const $SI_FILE_PERM_OFFLINE = 0x1000
Global Const $SI_FILE_PERM_NOT_INDEXED = 0x2000
Global Const $SI_FILE_PERM_ENCRYPTED = 0x4000
;Global Const $SI_FILE_PERM_VIRTUAL = 0x10000
Global Const $SI_FILE_PERM_DIRECTORY = 0x10000000
Global Const $SI_FILE_PERM_INDEX_VIEW = 0x20000000
Global $NeedLock = 0
Dim $FormattedTimestamp

ConsoleWrite("Starting MFTRCRD by Joakim Schicht" & @CRLF)
ConsoleWrite("Version 1.0.0.3" & @CRLF)
ConsoleWrite("" & @CRLF)
_validate_parameters()
$drive = StringMid($cmdline[1],1,3)
$filesystem = DriveGetFileSystem($drive)
If $filesystem = "NTFS" Then
	ConsoleWrite("Filesystem on " & $drive & " is " & $filesystem & @CRLF)
Else
	ConsoleWrite("Error: filesystem on " & $drive & " is " & $filesystem & @CRLF)
	Exit
EndIf
ConsoleWrite("File IndexNumber: " & _GetIndexNumber($cmdline[1], $IsDirectory) & @CRLF)
If $cmdline[2] = "-d" OR $cmdline[2] = "-a" Then
	_GetMFT()
	_DumpInfo()
	ConsoleWrite(@CRLF)
	ConsoleWrite("FINISHED!!" & @CRLF)
	Exit
EndIf
ConsoleWrite("Error: something not right.." & @CRLF)
Exit

Func _validate_parameters()
Local $FileAttrib
If $cmdline[0] <> 2 Then
	ConsoleWrite("Error: Wrong number of parameters supplied: " & $cmdline[0] & @CRLF)
	ConsoleWrite("Usage: " & @CRLF)
	ConsoleWrite("MFTRCRD param1 param2" & @CRLF)
	ConsoleWrite("param1 is valid file path " & @CRLF)
	ConsoleWrite("param2 can be -d or -a: " & @CRLF)
	ConsoleWrite("-d means decode $MFT entry " & @CRLF)
	ConsoleWrite("-a same as -d but also dumps the whole $MFT entry to console " & @CRLF)
	ConsoleWrite("Example: MFTRCRD -d C:\boot.ini " & @CRLF)
	Exit
EndIf
If $cmdline[2] <> "-d" AND $cmdline[2] <> "-a" Then
	ConsoleWrite("Error: Wrong parameter 2 supplied: " & $cmdline[2] & @CRLF)
EndIf
If FileExists($cmdline[1]) <> 1 OR StringMid($cmdline[1],2,2) <> ":\" Then
	ConsoleWrite("Error: Target file does not exist: " & $cmdline[1] & @CRLF)
	Exit
Else
	$FileAttrib = FileGetAttrib($cmdline[1])
	If $FileAttrib <> "D" Then
		$IsDirectory = 0
		ConsoleWrite("Target is a File" & @CRLF)
	EndIf
	If $FileAttrib = "D" Then
		$IsDirectory = 1
		ConsoleWrite("Target is a Directory" & @CRLF)
	EndIf
EndIf
$file = $cmdline[1]
EndFunc

Func NT_SUCCESS($status)
    If 0 <= $status And $status <= 0x7FFFFFFF Then
        Return True
    Else
        Return False
    EndIf
EndFunc

Func _FillZero($inp)
Local $inplen, $out, $tmp = ""
$inplen = StringLen($inp)
For $i = 1 To 4-$inplen
	$tmp &= "0"
Next
$out = $tmp & $inp
Return $out
EndFunc

Func _GetMFT()
$AttributesArr[0][0] = "Attribute name:"
$AttributesArr[1][0] = "STANDARD_INFORMATION"
$AttributesArr[2][0] = "ATTRIBUTE_LIST"
$AttributesArr[3][0] = "FILE_NAME"
$AttributesArr[4][0] = "OBJECT_ID"
$AttributesArr[5][0] = "SECURITY_DESCRIPTOR"
$AttributesArr[6][0] = "VOLUME_NAME"
$AttributesArr[7][0] = "VOLUME_INFORMATION"
$AttributesArr[8][0] = "DATA"
$AttributesArr[9][0] = "INDEX_ROOT"
$AttributesArr[10][0] = "INDEX_ALLOCATION"
$AttributesArr[11][0] = "BITMAP"
$AttributesArr[12][0] = "REPARSE_POINT"
$AttributesArr[13][0] = "EA_INFORMATION"
$AttributesArr[14][0] = "EA"
$AttributesArr[15][0] = "PROPERTY_SET"
$AttributesArr[16][0] = "LOGGED_UTILITY_STREAM"
$AttributesArr[17][0] = "ATTRIBUTE_END_MARKER"
$AttributesArr[0][1] = "Internal offset:"
$bIndexNumber = _GetIndexNumber($cmdline[1], $IsDirectory)
;ConsoleWrite("File IndexNumber: " & $bIndexNumber & @CRLF)
;ConsoleWrite("_DecToLittleEndian($bIndexNumber): " & _DecToLittleEndian($bIndexNumber) & @CRLF)
_ExtractSystemfile(2,_DecToLittleEndian($bIndexNumber))
;_ExtractSystemfile(1,"$MFT")

EndFunc

Func _GetIndexNumber($file, $mode)
	Local $IndexNumber
    Local $hNTDLL = DllOpen("ntdll.dll")
    Local $szName = DllStructCreate("wchar[260]")
    Local $sUS = DllStructCreate($tagUNICODESTRING)
    Local $sOA = DllStructCreate($tagOBJECTATTRIBUTES)
    Local $sISB = DllStructCreate($tagIOSTATUSBLOCK)
    Local $buffer = DllStructCreate("byte[16384]")
    Local $ret, $FILE_MODE
    If $mode == 0 Then
        $FILE_MODE = $FILE_NON_DIRECTORY_FILE
    Else
        $FILE_MODE = $FILE_DIRECTORY_FILE
    EndIf
    $file = "\??\" & $file
;	ConsoleWrite("$file: " & $file & @CRLF)
    DllStructSetData($szName, 1, $file)
    $ret = DllCall($hNTDLL, "none", "RtlInitUnicodeString", "ptr", DllStructGetPtr($sUS), "ptr", DllStructGetPtr($szName))
    DllStructSetData($sOA, "Length", DllStructGetSize($sOA))
    DllStructSetData($sOA, "RootDirectory", Chr(0))
    DllStructSetData($sOA, "ObjectName", DllStructGetPtr($sUS))
    DllStructSetData($sOA, "Attributes", $OBJ_CASE_INSENSITIVE)
    DllStructSetData($sOA, "SecurityDescriptor", Chr(0))
    DllStructSetData($sOA, "SecurityQualityOfService", Chr(0))
    $ret = DllCall($hNTDLL, "int", "NtOpenFile", "hwnd*", "", "dword", $GENERIC_READ, "ptr", DllStructGetPtr($sOA), "ptr", DllStructGetPtr($sISB), _
                                "ulong", $FILE_SHARE_READ, "ulong", BitOR($FILE_MODE, $FILE_RANDOM_ACCESS))
	If NT_SUCCESS($ret[0]) Then
;		ConsoleWrite("NtOpenFile: Success" & @CRLF)
	Else
		ConsoleWrite("Error: NtOpenFile Failed" & @CRLF)
		Exit
	EndIf
    Local $hFile = $ret[1]

    $ret = DllCall($hNTDLL, "int", "NtQueryInformationFile", "hwnd", $hFile, "ptr", DllStructGetPtr($sISB), "ptr", DllStructGetPtr($buffer), _
                                "int", 16384, "ptr", $FileInternalInformation)

    If NT_SUCCESS($ret[0]) Then
        ConsoleWrite("NtQueryInformationFile: Success" & @CRLF)
        Local $pFSO = DllStructGetPtr($buffer)
		Local $sFSO = DllStructCreate($tagFILEINTERNALINFORMATION, $pFSO)
		Local $IndexNumber = DllStructGetData($sFSO, "IndexNumber")
    Else
        ConsoleWrite("Error: NtQueryInformationFile Failed" & @CRLF)
		Exit
    EndIf
    $ret = DllCall($hNTDLL, "int", "NtClose", "hwnd", $hFile)
    DllClose($hNTDLL)
	Return $IndexNumber
EndFunc

Func _ExtractSystemfile($MFTmode,$TARGET_SYSFILE)
;ConsoleWrite("$TARGET_SYSFILE: " & $TARGET_SYSFILE & @crlf)
Global $TargetDrive = StringLeft($Drive,2)
if DriveGetFileSystem($TargetDrive) <> "NTFS" then
	ConsoleWrite("Error: Target volume " & $TargetDrive & " is not NTFS" & @crlf)
	Return
EndIf
;ConsoleWrite("Target volume is: " & $TargetDrive & @crlf)
Global $tBuffer=DllStructCreate("byte[512]"),$nBytes
$IsLocked = 0
$IsDismounted = 0
If @OSBuild >= 6000 AND $NeedLock Then
	If StringLeft(@AutoItExe,2) = $TargetDrive Then
		ConsoleWrite("Hey, you can't lock the volume that this program is run from!!" & @crlf)
		Exit
	EndIf
	$lock = _WinAPI_LockVolume($TargetDrive)
	If @error Then
;	If $lock[0] = 0 Then
		ConsoleWrite("Error when locking " & $TargetDrive & @CRLF)
		ConsoleWrite("Trying to force dismount instead " & @CRLF)
		$dismount = _WinAPI_DismountVolumeMod($TargetDrive)
		If $dismount = 0 Then
			ConsoleWrite("Error when force dismounting " & $TargetDrive & @CRLF)
			ConsoleWrite("Don't know what more to try." & @CRLF)
			Exit
		EndIf
		ConsoleWrite("Successfully force dismounted " & $TargetDrive & @CRLF)
		$IsDismounted = 1
		$hFile1 = $dismount
		$hFile0 = $dismount
		$hFile = $dismount
;		Return
	Else
		$IsLocked = 1
		$hFile1 = $lock
		$hFile0 = $lock
		$hFile = $lock
		ConsoleWrite("Successfully locked " & $TargetDrive & @CRLF)
	EndIf
ElseIf @OSBuild < 6000 AND $NeedLock Then
	Local $hFile1 = _WinAPI_CreateFile("\\.\" & $TargetDrive,2,6,7)
	$lasterror = _WinAPI_GetLastErrorMessage()
	If $hFile1 = 0 then
		ConsoleWrite("Error: " & $lasterror & " in function _WinAPI_CreateFile for: " & "\\.\" & $TargetDrive & @crlf)
		Exit
	EndIf
	$hFile0 = $hFile1
	$hFile = $hFile1
ElseIf $NeedLock = 0 Then
	Local $hFile1 = _WinAPI_CreateFile("\\.\" & $TargetDrive,2,6,7)
	$lasterror = _WinAPI_GetLastErrorMessage()
	If $hFile1 = 0 then
		ConsoleWrite("Error: " & $lasterror & " in function _WinAPI_CreateFile for: " & "\\.\" & $TargetDrive & @crlf)
;		Exit
	EndIf
	$hFile0 = $hFile1
	$hFile = $hFile1
EndIf
$read = _WinAPI_ReadFile($hFile0, DllStructGetPtr($tBuffer), 512, $nBytes)
$lasterror = _WinAPI_GetLastErrorMessage()
If $read = 0 then
	ConsoleWrite("Error: " & $lasterror & " in function _WinAPI_ReadFile for: " & "\\.\" & $TargetDrive & @crlf)
	Exit
EndIf
Global $bRaw = DllStructGetData($tBuffer,1)
Global $tBootSectorSections = DllStructCreate("align 1;byte Jump[3];" & _
        "char SystemName[8];" & _
        "ushort BytesPerSector;" & _
        "ubyte SectorsPerCluster;" & _
        "ushort ReservedSectors;" & _
        "ubyte[3];" & _
        "ushort;" & _
        "ubyte MediaDescriptor;" & _
        "ushort;" & _
        "ushort SectorsPerTrack;" & _
        "ushort NumberOfHeads;" & _
        "dword HiddenSectors;" & _
        "dword;" & _
        "dword;" & _
        "int64 TotalSectors;" & _
        "int64 LogicalClusterNumberforthefileMFT;" & _
        "int64 LogicalClusterNumberforthefileMFTMirr;" & _
        "dword ClustersPerFileRecordSegment;" & _
        "dword ClustersPerIndexBlock;" & _
        "int64 NTFSVolumeSerialNumber;" & _
        "dword Checksum", _
    DllStructGetPtr($tBuffer))

Global $BytesPerSector = DllStructGetData($tBootSectorSections, "BytesPerSector")
Global $SectorsPerCluster = DllStructGetData($tBootSectorSections, "SectorsPerCluster")
ConsoleWrite("$SectorsPerCluster = " & $SectorsPerCluster & @CRLF)
Global $ClustersPerFileRecordSegment = DllStructGetData($tBootSectorSections, "ClustersPerFileRecordSegment")
Global $LogicalClusterNumberforthefileMFT = DllStructGetData($tBootSectorSections, "LogicalClusterNumberforthefileMFT")
$MFT_Offset = $BytesPerSector * $SectorsPerCluster * $LogicalClusterNumberforthefileMFT
$MFT_Record_Size = 1024
$MFT_Record_Size_Inv = $MFT_Record_Size/$BytesPerSector
$tBuffer = DllStructCreate("byte[" & $MFT_Record_Size & "]")
$hdd_handle = "\\.\" & $TargetDrive
If $TARGET_SYSFILE = "$MFT" Then
	$ExpectedRecords = 0
ElseIf $TARGET_SYSFILE = "ALL" Then
	$ExpectedRecords = 30
ElseIf $TARGET_SYSFILE <> "$MFT" AND $TARGET_SYSFILE <> "ALL" Then
;	$ExpectedRecords = $TARGET_SYSFILE
	$ExpectedRecords = 80000
EndIf
;ConsoleWrite("$ExpectedRecords = " & $ExpectedRecords & @CRLF)
If $MFTmode = 1 Then
	For $i = 0 to $ExpectedRecords
		$RecordOffsetDec = $MFT_Offset + $MFT_Record_Size * $i
		If $i > 15 AND $i < 24 Then ContinueLoop
		If $i > 26 Then ExitLoop
		_WinAPI_SetFilePointerEx($hFile, $RecordOffsetDec)
		_WinAPI_ReadFile($hFile, DllStructGetPtr($tBuffer), $MFT_Record_Size, $nBytes)
		$MFTEntry = DllStructGetData($tBuffer, 1)
		If NOT (StringMid($MFTEntry,3,8) = '46494C45') Then
;			$RecordHealth = "BAAD"
			ConsoleWrite("Error: No FILE signature was found in record" & @crlf)
			ContinueLoop
		EndIf
		_ClearVar()
		_DecodeMFTRecord($MFTEntry,0)
		$RecordOffset = "0x" & Hex($RecordOffsetDec)
		ConsoleWrite("$RecordOffset = "& $RecordOffset & @crlf)
	Next
ElseIf $MFTmode = 2 Then
	For $i = 0 to 1
		$RecordOffsetDec = $MFT_Offset + $MFT_Record_Size * $i
		If $i > 0 Then
			$MFTmode = 1
		EndIf
		If $MFTmode = 1 Then
			ConsoleWrite("Searching through $MFT..." & @crlf)
			For $MFTruns = 1 To Ubound($MFT_RUN_Cluster)-1
				$MFTInnerloops = $MFT_RUN_Sectors[$MFTruns]*4
				$MFT_Offset_tmp = $MFT_RUN_Cluster[$MFTruns]*$SectorsPerCluster*512
				For $MFTInnerRuns = 0 To $MFTInnerloops
					_WinAPI_SetFilePointerEx($hFile, $MFT_Offset_tmp+($MFT_Record_Size*$MFTInnerRuns),$FILE_BEGIN)
					_WinAPI_ReadFile($hFile, DllStructGetPtr($tBuffer), $MFT_Record_Size, $nBytes)
					$MFTEntry = DllStructGetData($tBuffer, 1)
					If (StringMid($MFTEntry,47,4) = "0100" AND StringMid($MFTEntry,91,8) = $TARGET_SYSFILE) OR (StringMid($MFTEntry,47,4) = "0300" AND StringMid($MFTEntry,91,8) = $TARGET_SYSFILE) Then
						_ClearVar()
						Global $FinalOffset = DllCall('kernel32.dll', 'int', 'SetFilePointerEx', 'ptr', $hFile, 'int64', 0, 'int64*', 0, 'dword', 1)
;						ConsoleWrite("Record offset: " & $FinalOffset[3]-1024 & @crlf)
						If $cmdline[2] = "-a" Then
							ConsoleWrite("Dump of $MFT record " & @crlf)
							ConsoleWrite(_HexEncode($MFTEntry) & @crlf)
						EndIf
						_DecodeMFTRecord($MFTEntry,1)
						ExitLoop
					EndIf
				Next
			Next
		EndIf
		If $i = 0 AND $MFTmode = 2 Then
			_WinAPI_SetFilePointerEx($hFile, $RecordOffsetDec)
			_WinAPI_ReadFile($hFile, DllStructGetPtr($tBuffer), $MFT_Record_Size, $nBytes)
			$MFTEntry = DllStructGetData($tBuffer, 1)
			If NOT (StringMid($MFTEntry,3,8) = '46494C45') Then
				ConsoleWrite("Error: No FILE signature was found in record 1" & @crlf)
				ContinueLoop
			EndIf
			_ClearVar()
			_DecodeMFTRecord($MFTEntry,2)
		EndIf
	Next
EndIf
If $DATA_Name <> "" Then
	ConsoleWrite("Warning: Alternate data stream (ADS) found in file" & @crlf)
	ConsoleWrite("ADS path = " & $cmdline[1] & ":" & $DATA_name & @crlf)
EndIf
If $DATA_Name_2 <> "" Then
	ConsoleWrite("Warning: Alternate data stream (ADS) found in file" & @crlf)
	ConsoleWrite("ADS path = " & $cmdline[1] & ":" & $DATA_Name_2 & @crlf)
EndIf
If $cmdline[2] = "-d" Then
	Return
EndIf
EndFunc

Func _DecodeMFTRecord($MFTEntry,$MFTMode)
$RecordHdrArr[0][0] = "Field name"
$RecordHdrArr[1][0] = "Offst to update sequence number"
$RecordHdrArr[2][0] = "Update sequence array size (words)"
$RecordHdrArr[3][0] = "$LogFile sequence number (LSN)"
$RecordHdrArr[4][0] = "Sequence number"
$RecordHdrArr[5][0] = "Hard link count"
$RecordHdrArr[6][0] = "Offset to first Attribute"
$RecordHdrArr[7][0] = "Flags"
$RecordHdrArr[8][0] = "Real size of the FILE record"
$RecordHdrArr[9][0] = "Allocated size of the FILE record"
$RecordHdrArr[10][0] = "File reference to the base FILE record"
$RecordHdrArr[11][0] = "Next Attribute Id"
$RecordHdrArr[12][0] = "Number of this MFT Record"
$RecordHdrArr[13][0] = "Update Sequence Number (a)"
$RecordHdrArr[14][0] = "Update Sequence Array (a)"
$SIArr[0][0] = "Field name:"
$SIArr[1][0] = "HEADER_Flags"
$SIArr[2][0] = "CreationTime (CTime)"
$SIArr[3][0] = "LastWriteTime (ATime)"
$SIArr[4][0] = "ChangeTime (MTime)"
$SIArr[5][0] = "LastAccessTime (RTime)"
$SIArr[6][0] = "DOS File Permissions"
$SIArr[7][0] = "Max Versions"
$SIArr[8][0] = "Version Number"
$SIArr[9][0] = "Class ID"
$SIArr[10][0] = "Owner ID"
$SIArr[11][0] = "Security ID"
$SIArr[12][0] = "USN"
$SIArr[0][1] = "Value:"
$SIArr[0][2] = "Field offset:"
$SIArr[0][3] = "Field size (bytes):"
$FNArr[0][0] = "Field name"
$FNArr[1][0] = "ParentSequenceNo"
$FNArr[2][0] = "CreationTime (CTime)"
$FNArr[3][0] = "LastWriteTime (ATime)"
$FNArr[4][0] = "ChangeTime (MTime)"
$FNArr[5][0] = "LastAccessTime (RTime)"
$FNArr[6][0] = "AllocSize"
$FNArr[7][0] = "RealSize"
$FNArr[8][0] = "Flags"
$FNArr[9][0] = "NameLength"
$FNArr[10][0] = "NameType"
$FNArr[11][0] = "NameSpace"
$FNArr[12][0] = "FileName"
$FNArr[13][0] = "ParentReferenceNo"
$ObjectIDArr[0][0] = "Field name"
$ObjectIDArr[1][0] = "GUID Object Id"
$ObjectIDArr[2][0] = "GUID Birth Volume Id"
$ObjectIDArr[3][0] = "GUID Birth Object Id"
$ObjectIDArr[4][0] = "GUID Domain Id"
$DataArr[0][0] = "Field name"
$DataArr[1][0] = "Length"
$DataArr[2][0] = "Non-resident flag"
$DataArr[3][0] = "Name length"
$DataArr[4][0] = "Offset to the Name"
$DataArr[5][0] = "Flags"
$DataArr[6][0] = "Attribute Id"
$DataArr[7][0] = "Resident - Length of the Attribute"
$DataArr[8][0] = "Resident - Offset to the Attribute"
$DataArr[9][0] = "Resident - Indexed flag"
$DataArr[10][0] = "Resident - Padding"
$DataArr[11][0] = "Non-Resident - Starting VCN"
$DataArr[12][0] = "Non-Resident - Last VCN"
$DataArr[13][0] = "Non-Resident - Offset to the Data Runs"
$DataArr[14][0] = "Non-Resident - Compression Unit Size"
$DataArr[15][0] = "Non-Resident - Padding"
$DataArr[16][0] = "Non-Resident - Allocated size of the attribute"
$DataArr[17][0] = "Non-Resident - Real size of the attribute"
$DataArr[18][0] = "Non-Resident - Initialized data size of the stream"
$DataArr[19][0] = "The Attribute's Name"
$Fixup1Needed = 0
$Fixup2Needed = 0
$RecordActive = ""
$HEADER_Flags = ""
$FN_Number = ""
$DATA_Number = ""
$SI_Number = ""
$ATTRIBLIST_Number = ""
$OBJID_Number = ""
$SECURITY_Number = ""
$VOLNAME_Number = ""
$VOLINFO_Number = ""
$INDEXROOT_Number = ""
$INDEXALLOC_Number = ""
$BITMAP_Number = ""
$REPARSEPOINT_Number = ""
$EAINFO_Number = ""
$EA_Number = ""
$PROPERTYSET_Number = ""
$LOGGEDUTILSTREAM_Number = ""
$HEADER_LSN = ""
$HEADER_SequenceNo = ""
$Header_HardLinkCount = ""
$HEADER_RecordRealSize = ""
$HEADER_RecordAllocSize = ""
$HEADER_FileRef = ""
$HEADER_NextAttribID = ""
$HEADER_MFTREcordNumber = ""
$UpdSeqArrOffset = ""
$UpdSeqArrSize = ""
$UpdSeqArrOffset = StringMid($MFTEntry,11,4)
$UpdSeqArrOffset = Dec(StringMid($UpdSeqArrOffset,3,2) & StringMid($UpdSeqArrOffset,1,2))
$UpdSeqArrSize = StringMid($MFTEntry,15,4)
$UpdSeqArrSize = Dec(StringMid($UpdSeqArrSize,3,2) & StringMid($UpdSeqArrSize,1,2))
$UpdSeqArr = StringMid($MFTEntry,3+($UpdSeqArrOffset*2),$UpdSeqArrSize*2*2)
$UpdSeqArrPart0 = StringMid($UpdSeqArr,1,4)
$UpdSeqArrPart1 = StringMid($UpdSeqArr,5,4)
$UpdSeqArrPart2 = StringMid($UpdSeqArr,9,4)
If $UpdSeqArrPart1 <> "0000"  Then
	$Fixup1Needed = 1
EndIf
If $UpdSeqArrPart2 <> "0000" Then
	$Fixup2Needed = 1
EndIf
$RecordEnd1 = StringMid($MFTEntry,1023,4)
$RecordEnd2 = StringMid($MFTEntry,2047,4)
If $RecordEnd1 <> $RecordEnd2 OR $UpdSeqArrPart0 <> $RecordEnd1 Then
	ConsoleWrite("Error the $MFT record is corrupt at $MFTMode = " & $MFTMode & @CRLF)
	Exit
EndIf
$MFTEntry = StringMid($MFTEntry,1,1022) & $UpdSeqArrPart1 & StringMid($MFTEntry,1027,1020) & $UpdSeqArrPart2 ; Stupid fixup to not corrupt decoding of attributes that are located past 0x1fd within record
Local $MFTHeader = StringMid($MFTEntry,1,32)
;ConsoleWrite("$MFTHeader = " & $MFTHeader & @crlf)
$HEADER_LSN = StringMid($MFTEntry,19,16)
;ConsoleWrite("$HEADER_LSN = " & $HEADER_LSN & @crlf)
$HEADER_LSN = StringMid($HEADER_LSN,15,2) & StringMid($HEADER_LSN,13,2) & StringMid($HEADER_LSN,11,2) & StringMid($HEADER_LSN,9,2) & StringMid($HEADER_LSN,7,2) & StringMid($HEADER_LSN,5,2) & StringMid($HEADER_LSN,3,2) & StringMid($HEADER_LSN,1,2)
;ConsoleWrite("$HEADER_LSN = " & $HEADER_LSN & @crlf)
$HEADER_SequenceNo = StringMid($MFTEntry,35,4)
$HEADER_SequenceNo = Dec(StringMid($HEADER_SequenceNo,3,2) & StringMid($HEADER_SequenceNo,1,2))
;$HEADER_SequenceNo = Dec($HEADER_SequenceNo)
;ConsoleWrite("$HEADER_SequenceNo = " & $HEADER_SequenceNo & @crlf)
$Header_HardLinkCount = StringMid($MFTEntry,39,4)
$Header_HardLinkCount = Dec(StringMid($Header_HardLinkCount,3,2) & StringMid($Header_HardLinkCount,1,2))
$HEADER_Flags = StringMid($MFTEntry,47,4);00=deleted file,01=file,02=deleted folder,03=folder
;ConsoleWrite("$HEADER_Flags = " & $HEADER_Flags & @crlf)
;$HEADER_Flags = StringMid($HEADER_Flags,3,2) & StringMid($HEADER_Flags,1,2)
;ConsoleWrite("$HEADER_Flags = " & $HEADER_Flags & @crlf)
;$HEADER_Flags = _FileRecordFlag("0x" & $HEADER_Flags)
;ConsoleWrite("$HEADER_Flags = " & $HEADER_Flags & @crlf)
;#cs
Select
	Case $HEADER_Flags = '0000'
		$HEADER_Flags = 'FILE'
		$RecordActive = 'DELETED'
	Case $HEADER_Flags = '0100'
		$HEADER_Flags = 'FILE'
		$RecordActive = 'ALLOCATED'
	Case $HEADER_Flags = '0200'
		$HEADER_Flags = 'FOLDER'
		$RecordActive = 'DELETED'
	Case $HEADER_Flags = '0300'
		$HEADER_Flags = 'FOLDER'
		$RecordActive = 'ALLOCATED'
	Case $HEADER_Flags <> '0000' AND $HEADER_Flags <> '0100' AND $HEADER_Flags <> '0200' AND $HEADER_Flags <> '0300'
		$HEADER_Flags = 'UNKNOWN'
		$RecordActive = 'UNKNOWN'
EndSelect
;#ce
;ConsoleWrite("$HEADER_Flags = " & $HEADER_Flags & @crlf)
$HEADER_RecordRealSize = StringMid($MFTEntry,51,8)
$HEADER_RecordRealSize = Dec(StringMid($HEADER_RecordRealSize,7,2) & StringMid($HEADER_RecordRealSize,5,2) & StringMid($HEADER_RecordRealSize,3,2) & StringMid($HEADER_RecordRealSize,1,2))
;$HEADER_RecordRealSize = Dec($HEADER_RecordRealSize)
;ConsoleWrite("$HEADER_RecordRealSize = " & $HEADER_RecordRealSize & @crlf)
$HEADER_RecordAllocSize = StringMid($MFTEntry,59,8)
$HEADER_RecordAllocSize = Dec(StringMid($HEADER_RecordAllocSize,7,2) & StringMid($HEADER_RecordAllocSize,5,2) & StringMid($HEADER_RecordAllocSize,3,2) & StringMid($HEADER_RecordAllocSize,1,2))
;$HEADER_RecordAllocSize = Dec($HEADER_RecordAllocSize)
;ConsoleWrite("$HEADER_RecordAllocSize = " & $HEADER_RecordAllocSize & @crlf)
$HEADER_FileRef = StringMid($MFTEntry,67,16)
;ConsoleWrite("$HEADER_FileRef = " & $HEADER_FileRef & @crlf)
$HEADER_NextAttribID = StringMid($MFTEntry,83,4)
;ConsoleWrite("$HEADER_NextAttribID = " & $HEADER_NextAttribID & @crlf)
$HEADER_NextAttribID = StringMid($HEADER_NextAttribID,3,2) & StringMid($HEADER_NextAttribID,1,2)
$HEADER_MFTREcordNumber = StringMid($MFTEntry,91,8)
$HEADER_MFTREcordNumber = Dec(StringMid($HEADER_MFTREcordNumber,7,2) & StringMid($HEADER_MFTREcordNumber,5,2) & StringMid($HEADER_MFTREcordNumber,3,2) & StringMid($HEADER_MFTREcordNumber,1,2))
;$HEADER_MFTREcordNumber = Dec($HEADER_MFTREcordNumber)
;ConsoleWrite("$HEADER_MFTREcordNumber = " & $HEADER_MFTREcordNumber & @crlf)
$NextAttributeOffset = (Dec(StringMid($MFTEntry,43,2))*2)+3
;ConsoleWrite("$NextAttributeOffset = " & $NextAttributeOffset & @crlf)
;ConsoleWrite("$NextAttributeOffset Hex = 0x" & Hex((($NextAttributeOffset-3)/2)) & @crlf)
$AttributeType = StringMid($MFTEntry,$NextAttributeOffset,8)
;ConsoleWrite("$AttributeType = " & $AttributeType & @crlf)
$AttributeSize = StringMid($MFTEntry,$NextAttributeOffset+8,8)
;ConsoleWrite("$AttributeSize = " & $AttributeSize & @crlf)
$AttributeSize = Dec(StringMid($AttributeSize,7,2) & StringMid($AttributeSize,5,2) & StringMid($AttributeSize,3,2) & StringMid($AttributeSize,1,2))
;$AttributeSize = Dec($AttributeSize)
;ConsoleWrite("$AttributeSize = " & $AttributeSize & @crlf)
If $MFTMode = 1 Then
	$RecordHdrArr[0][1] = "Field value"
	$RecordHdrArr[1][1] = $UpdSeqArrOffset
	$RecordHdrArr[2][1] = $UpdSeqArrSize
	$RecordHdrArr[3][1] = $HEADER_LSN
	$RecordHdrArr[4][1] = $HEADER_SequenceNo
	$RecordHdrArr[5][1] = $Header_HardLinkCount
	$RecordHdrArr[6][1] = $NextAttributeOffset
	$RecordHdrArr[7][1] = $HEADER_Flags
	$RecordHdrArr[8][1] = $HEADER_RecordRealSize
	$RecordHdrArr[9][1] = $HEADER_RecordAllocSize
	$RecordHdrArr[10][1] = $HEADER_FileRef
	$RecordHdrArr[11][1] = $HEADER_NextAttribID
	$RecordHdrArr[12][1] = $HEADER_MFTREcordNumber
	$RecordHdrArr[13][1] = $UpdSeqArrPart0
	$RecordHdrArr[14][1] = $UpdSeqArrPart1&$UpdSeqArrPart2
EndIf
$AttributeKnown = 1
While $AttributeKnown = 1
;While $AttributeType <> $ATTRIBUTE_UNKNOWN
;While $NextAttributeOffset < 2048
	$NextAttributeType = StringMid($MFTEntry,$NextAttributeOffset,8)
;	ConsoleWrite("$NextAttributeType = " & $NextAttributeType & @crlf)
	$AttributeType = $NextAttributeType
	$AttributeSize = StringMid($MFTEntry,$NextAttributeOffset+8,8)
	$AttributeSize = Dec(StringMid($AttributeSize,7,2) & StringMid($AttributeSize,5,2) & StringMid($AttributeSize,3,2) & StringMid($AttributeSize,1,2))
;	$AttributeSize = Dec($AttributeSize)
;	ConsoleWrite("$AttributeSize = " & $AttributeSize & @crlf)
;	ConsoleWrite("$NextAttributeOffset Dec = " & $NextAttributeOffset & @crlf)
;	ConsoleWrite("$NextAttributeOffset Hex = 0x" & Hex((($NextAttributeOffset-3)/2)) & @crlf)
	Select
		Case $AttributeType = $STANDARD_INFORMATION
			$AttributeKnown = 1
			$STANDARD_INFORMATION_ON = "TRUE"
			$SI_Number += 1
			If $MFTMode = 1 Then
				$AttributesArr[1][1] = $NextAttributeOffset
				_Get_StandardInformation($MFTEntry,$NextAttributeOffset,$AttributeSize,$MFTMode)
			EndIf

		Case $AttributeType = $ATTRIBUTE_LIST
			$AttributeKnown = 1
			$ATTRIBUTE_LIST_ON = "TRUE"
			$ATTRIBLIST_Number += 1
			If $MFTMode = 1 Then
				$AttributesArr[2][1] = $NextAttributeOffset
			EndIf
;			_Get_AttributeList()

		Case $AttributeType = $FILE_NAME
			$AttributeKnown = 1
			$FILE_NAME_ON = "TRUE"
			$FN_Number += 1 ; Need to come up with something smarter than this
			If $FN_Number > 4 Then
				ContinueCase
			EndIf
			If $MFTMode = 1 Then
				ReDim $FNArr[14][$FN_Number+3]
;				$FNArr[0][$FN_Number] = "FN Number " & $FN_Number
			EndIf
			_Get_FileName($MFTEntry,$NextAttributeOffset,$AttributeSize,$FN_Number,$MFTMode)
;			ConsoleWrite("Now processing: " & $FN_FileName & "..." & @crlf)
			$AttributesArr[3][1] = $NextAttributeOffset

		Case $AttributeType = $OBJECT_ID
			$AttributeKnown = 1
			$OBJECT_ID_ON = "TRUE"
			$OBJID_Number += 1
			If $MFTMode = 1 Then
				$AttributesArr[4][1] = $NextAttributeOffset
				_Get_ObjectID($MFTEntry,$NextAttributeOffset,$AttributeSize)
			EndIf

		Case $AttributeType = $SECURITY_DESCRIPTOR
			$AttributeKnown = 1
			$SECURITY_DESCRIPTOR_ON = "TRUE"
			$SECURITY_Number += 1
			If $MFTMode = 1 Then
				$AttributesArr[5][1] = $NextAttributeOffset
;				_Get_SecurityDescriptor()
			EndIf

		Case $AttributeType = $VOLUME_NAME
			$AttributeKnown = 1
			$VOLUME_NAME_ON = "TRUE"
			$VOLNAME_Number += 1
			If $MFTMode = 1 Then
				$AttributesArr[6][1] = $NextAttributeOffset
				_Get_VolumeName($MFTEntry,$NextAttributeOffset,$AttributeSize)
			EndIf

		Case $AttributeType = $VOLUME_INFORMATION
			$AttributeKnown = 1
			$VOLUME_INFORMATION_ON = "TRUE"
			$VOLINFO_Number += 1
			If $MFTMode = 1 Then
				$AttributesArr[7][1] = $NextAttributeOffset
				_Get_VolumeInformation($MFTEntry,$NextAttributeOffset,$AttributeSize)
			EndIf

		Case $AttributeType = $DATA
			$AttributeKnown = 1
			$DATA_ON = "TRUE"
			$DATA_Number += 1
			If $MFTMode = 1 Then
				ReDim $DataArr[20][$DATA_Number+1]
				$AttributesArr[8][1] = $NextAttributeOffset
			EndIf
			_Get_Data($MFTEntry,$NextAttributeOffset,$AttributeSize,$DATA_Number,$MFTMode)


		Case $AttributeType = $INDEX_ROOT
			$AttributeKnown = 1
			$INDEX_ROOT_ON = "TRUE"
			$INDEXROOT_Number += 1
			If $MFTMode = 1 Then
				$AttributesArr[9][1] = $NextAttributeOffset
;				_Get_IndexRoot()
			EndIf

		Case $AttributeType = $INDEX_ALLOCATION
			$AttributeKnown = 1
			$INDEX_ALLOCATION_ON = "TRUE"
			$INDEXALLOC_Number += 1
			If $MFTMode = 1 Then
				$AttributesArr[10][1] = $NextAttributeOffset
;				_Get_IndexAllocation()
			EndIf

		Case $AttributeType = $BITMAP
			$AttributeKnown = 1
			$BITMAP_ON = "TRUE"
			$BITMAP_Number += 1
			If $MFTMode = 1 Then
				$AttributesArr[11][1] = $NextAttributeOffset
;				_Get_Bitmap()
			EndIf

		Case $AttributeType = $REPARSE_POINT
			$AttributeKnown = 1
			$REPARSE_POINT_ON = "TRUE"
			$REPARSEPOINT_Number += 1
			If $MFTMode = 1 Then
				$AttributesArr[12][1] = $NextAttributeOffset
;				_Get_ReparsePoint()
			EndIf

		Case $AttributeType = $EA_INFORMATION
			$AttributeKnown = 1
			$EA_INFORMATION_ON = "TRUE"
			$EAINFO_Number += 1
			If $MFTMode = 1 Then
				$AttributesArr[13][1] = $NextAttributeOffset
;				_Get_EaInformation()
			EndIf

		Case $AttributeType = $EA
			$AttributeKnown = 1
			$EA_ON = "TRUE"
			$EA_Number += 1
			If $MFTMode = 1 Then
				$AttributesArr[14][1] = $NextAttributeOffset
;				_Get_Ea()
			EndIf

		Case $AttributeType = $PROPERTY_SET
			$AttributeKnown = 1
			$PROPERTY_SET_ON = "TRUE"
			$PROPERTYSET_Number += 1
			If $MFTMode = 1 Then
				$AttributesArr[15][1] = $NextAttributeOffset
;				_Get_PropertySet()
			EndIf

		Case $AttributeType = $LOGGED_UTILITY_STREAM
			$AttributeKnown = 1
			$LOGGED_UTILITY_STREAM_ON = "TRUE"
			$LOGGEDUTILSTREAM_Number += 1
			If $MFTMode = 1 Then
				$AttributesArr[16][1] = $NextAttributeOffset
;				_Get_LoggedUtilityStream()
			EndIf

		Case $AttributeType = $ATTRIBUTE_END_MARKER
			$AttributeKnown = 0
			If $MFTMode = 1 Then
				$AttributesArr[17][1] = $NextAttributeOffset
			EndIf

;		Case $AttributeType <> $LOGGED_UTILITY_STREAM AND $AttributeType <> $EA AND $AttributeType <> $EA_INFORMATION AND $AttributeType <> $REPARSE_POINT AND $AttributeType <> $BITMAP AND $AttributeType <> $INDEX_ALLOCATION AND $AttributeType <> $INDEX_ROOT AND $AttributeType <> $DATA AND $AttributeType <> $VOLUME_INFORMATION AND $AttributeType <> $VOLUME_NAME AND $AttributeType <> $SECURITY_DESCRIPTOR AND $AttributeType <> $OBJECT_ID AND $AttributeType <> $FILE_NAME AND $AttributeType <> $ATTRIBUTE_LIST AND $AttributeType <> $STANDARD_INFORMATION AND $AttributeType <> $PROPERTY_SET
;			$AttributeKnown = 0
;			ConsoleWrite("All attributes processed in the record for: " & $FN_FileName & @CRLF)
;			_DisplayInfo("All attributes processed in the record for: " & $FN_FileName & @crlf)

	EndSelect
;	If $AttributeKnown = 0 Then
;		$RecordSlackSpace = StringMid($MFTEntry,$NextAttributeOffset,2048-$NextAttributeOffset)
;		ConsoleWrite($RecordSlackSpace & @CRLF)
;		MsgBox(0,"$RecordSlackSpace","$RecordSlackSpace")
;		ExitLoop
;	EndIf
	If $AttributeKnown = 0 Then ExitLoop
	$NextAttributeOffset = $NextAttributeOffset + ($AttributeSize*2)
WEnd
If $DATA_ON <> "TRUE" Then
;	ConsoleWrite("No $DATA attribute present so nothing to extract for the file: " & $FN_FileName & @crlf)
EndIf
;_ArrayDisplay($RecordHdrArr,"$RecordHdrArr")
;_ArrayDisplay($SIArr,"$SIArr")
;_ArrayDisplay($FNArr,"$FNArr")
If $MFTMode = 1 Then
	$AttributesArr[1][2] = $STANDARD_INFORMATION_ON
	$AttributesArr[2][2] = $ATTRIBUTE_LIST_ON
	$AttributesArr[3][2] = $FILE_NAME_ON
	$AttributesArr[4][2] = $OBJECT_ID_ON
	$AttributesArr[5][2] = $SECURITY_DESCRIPTOR_ON
	$AttributesArr[6][2] = $VOLUME_NAME_ON
	$AttributesArr[7][2] = $VOLUME_INFORMATION_ON
	$AttributesArr[8][2] = $DATA_ON
	$AttributesArr[9][2] = $INDEX_ROOT_ON
	$AttributesArr[10][2] = $INDEX_ALLOCATION_ON
	$AttributesArr[11][2] = $BITMAP_ON
	$AttributesArr[12][2] = $REPARSE_POINT_ON
	$AttributesArr[13][2] = $EA_INFORMATION_ON
	$AttributesArr[14][2] = $EA_ON
	$AttributesArr[15][2] = $PROPERTY_SET_ON
	$AttributesArr[16][2] = $LOGGED_UTILITY_STREAM_ON
	$AttributesArr[17][2] = $ATTRIBUTE_END_MARKER_ON
	$AttributesArr[1][3] = $SI_Number
	$AttributesArr[2][3] = $ATTRIBLIST_Number
	$AttributesArr[3][3] = $FN_Number
	$AttributesArr[4][3] = $OBJID_Number
	$AttributesArr[5][3] = $SECURITY_Number
	$AttributesArr[6][3] = $VOLNAME_Number
	$AttributesArr[7][3] = $VOLINFO_Number
	$AttributesArr[8][3] = $DATA_Number
	$AttributesArr[9][3] = $INDEXROOT_Number
	$AttributesArr[10][3] = $INDEXALLOC_Number
	$AttributesArr[11][3] = $BITMAP_Number
	$AttributesArr[12][3] = $REPARSEPOINT_Number
	$AttributesArr[13][3] = $EAINFO_Number
	$AttributesArr[14][3] = $EA_Number
	$AttributesArr[15][3] = $PROPERTYSET_Number
	$AttributesArr[16][3] = $LOGGEDUTILSTREAM_Number
	$AttributesArr[17][3] = 1
	$ObjectIDArr[0][1] = "Field value"
	$ObjectIDArr[1][1] = $GUID_ObjectID
	$ObjectIDArr[2][1] = $GUID_BirthVolumeID
	$ObjectIDArr[3][1] = $GUID_BirthObjectID
	$ObjectIDArr[4][1] = $GUID_BirthDomainID
EndIf
EndFunc

Func _Get_Data($MFTEntry,$DATA_Offset,$DATA_Size,$DATA_Number,$MFTMode)
Local $IsCompressed = 0, $RunListSectorsTotal, $NewRunOffsetBase
If $DATA_Number = 1 Then
$maxarr = Ubound($RUN_Cluster)
If $maxarr > 1 Then ; Seems necessary when more than 1 file is to be ripped
	For $j = 1 To $maxarr
;		If $maxarr-$j=1 Then ExitLoop
		_ArrayDelete($RUN_Cluster,$maxarr-$j)
		_ArrayDelete($RUN_Sectors,$maxarr-$j)
		_ArrayDelete($RUN_Sparse,$maxarr-$j)
		If $maxarr-$j=1 Then ExitLoop
	Next
EndIf
If $MFTMode = 2 Then
	$MFTmaxarr = Ubound($MFT_RUN_Cluster)
	If $MFTmaxarr > 1 Then ; Seems necessary when more than 1 file is to be ripped
		For $j = 1 To $MFTmaxarr
;			If $maxarr-$j=1 Then ExitLoop
			_ArrayDelete($MFT_RUN_Cluster,$MFTmaxarr-$j)
			_ArrayDelete($MFT_RUN_Sectors,$MFTmaxarr-$j)
			_ArrayDelete($MFT_RUN_Sparse,$MFTmaxarr-$j)
			If $MFTmaxarr-$j=1 Then ExitLoop
		Next
	EndIf
EndIf
;ConsoleWrite("$DATA_Size = " & $DATA_Size & @crlf)
$DATA_Length = StringMid($MFTEntry,$DATA_Offset+8,8)
$DATA_Length = Dec(StringMid($DATA_Length,7,2) & StringMid($DATA_Length,5,2) & StringMid($DATA_Length,3,2) & StringMid($DATA_Length,1,2))
$DATA_NonResidentFlag = StringMid($MFTEntry,$DATA_Offset+16,2)
;ConsoleWrite("$DATA_NonResidentFlag = " & $DATA_NonResidentFlag & @crlf)
$DATA_NameLength = Dec(StringMid($MFTEntry,$DATA_Offset+18,2))
;$DATA_NameLength = Dec($DATA_NameLength)
;ConsoleWrite("$DATA_NameLength = " & $DATA_NameLength & @crlf)
$DATA_NameRelativeOffset = StringMid($MFTEntry,$DATA_Offset+20,4)
;ConsoleWrite("$DATA_NameRelativeOffset = " & $DATA_NameRelativeOffset & @crlf)
$DATA_NameRelativeOffset = Dec(StringMid($DATA_NameRelativeOffset,3,2) & StringMid($DATA_NameRelativeOffset,1,2))
;$DATA_NameRelativeOffset = Dec($DATA_NameRelativeOffset)
;ConsoleWrite("$DATA_NameRelativeOffset = " & $DATA_NameRelativeOffset & @crlf)
$DATA_Flags = StringMid($MFTEntry,$DATA_Offset+24,4)
$DATA_Flags = StringMid($DATA_Flags,3,2) & StringMid($DATA_Flags,1,2)
;ConsoleWrite("$DATA_Flags = " & $DATA_Flags & @crlf)
If BitAND("0x" & $DATA_Flags,0x0001) Then
	$IsCompressed = 1
;	ConsoleWrite("Error: Can't yet extract compressed files" & @crlf)
;	_DisplayInfo("Error: Can't yet extract COMPRESSED files" & @crlf)
;	Return
;	ConsoleWrite("Warning: Testing experimental extract of COMPRESSED file" & @crlf)
EndIf
;If BitAND("0x" & $DATA_Flags,0x4000) Then $AHoutput &= 'ENCRYPTED+'
If BitAND("0x" & $DATA_Flags,0x8000) Then
;	ConsoleWrite("Error: Can't yet extract sparse files" & @crlf)
;	_DisplayInfo("Error: Can't yet extract SPARSE files" & @crlf)
;	Return
EndIf
$DATA_Flags = _AttribHeaderFlags("0x" & $DATA_Flags)
;ConsoleWrite("$DATA_Flags = " & $DATA_Flags & @crlf)
If $DATA_NameLength > 0 Then
	$DATA_NameSpace = $DATA_NameLength-1
	$DATA_Name = StringMid($MFTEntry,$DATA_Offset+($DATA_NameRelativeOffset*2),($DATA_NameLength+$DATA_NameSpace)*2)
;	$DATA_Name = StringMid($MFTEntry,$DATA_Offset+($DATA_NameRelativeOffset*2),($DATA_NameLength+1)*2)
	ConsoleWrite("$DATA_Name = " & $DATA_Name & @crlf)
	$DATA_Name = _UnicodeHexToStr($DATA_Name)
EndIf
;ConsoleWrite("$DATA_Name = " & $DATA_Name & @crlf)
$DATA_AttributeID = StringMid($MFTEntry,$DATA_Offset+28,4)
$DATA_AttributeID = StringMid($DATA_AttributeID,3,2) & StringMid($DATA_AttributeID,1,2)
If $DATA_NonResidentFlag = '01' Then
	$DATA_StartVCN = StringMid($MFTEntry,$DATA_Offset+32,16)
;	ConsoleWrite("$DATA_StartVCN = " & $DATA_StartVCN & @crlf)
	$DATA_StartVCN = Dec(StringMid($DATA_StartVCN,15,2) & StringMid($DATA_StartVCN,13,2) & StringMid($DATA_StartVCN,11,2) & StringMid($DATA_StartVCN,9,2) & StringMid($DATA_StartVCN,7,2) & StringMid($DATA_StartVCN,5,2) & StringMid($DATA_StartVCN,3,2) & StringMid($DATA_StartVCN,1,2))
;	ConsoleWrite("$DATA_StartVCN = " & $DATA_StartVCN & @crlf)
;	$DATA_StartVCN = Dec($DATA_StartVCN)
;	ConsoleWrite("$DATA_StartVCN = " & $DATA_StartVCN & @crlf)
	$DATA_LastVCN = StringMid($MFTEntry,$DATA_Offset+48,16)
;	ConsoleWrite("$DATA_LastVCN = " & $DATA_LastVCN & @crlf)
	$DATA_LastVCN = Dec(StringMid($DATA_LastVCN,15,2) & StringMid($DATA_LastVCN,13,2) & StringMid($DATA_LastVCN,11,2) & StringMid($DATA_LastVCN,9,2) & StringMid($DATA_LastVCN,7,2) & StringMid($DATA_LastVCN,5,2) & StringMid($DATA_LastVCN,3,2) & StringMid($DATA_LastVCN,1,2))
;	ConsoleWrite("$DATA_LastVCN = " & $DATA_LastVCN & @crlf)
;	$DATA_LastVCN = Dec($DATA_LastVCN)
;	ConsoleWrite("$DATA_LastVCN = " & $DATA_LastVCN & @crlf)
	$DATA_VCNs = $DATA_LastVCN - $DATA_StartVCN
;	ConsoleWrite("$DATA_VCNs = " & $DATA_VCNs & @crlf)
	$DATA_OffsetToDataRuns = StringMid($MFTEntry,$DATA_Offset+64,4)
	$DATA_OffsetToDataRuns = Dec(StringMid($DATA_OffsetToDataRuns,3,1) & StringMid($DATA_OffsetToDataRuns,3,1))
	$DATA_CompressionUnitSize = StringMid($MFTEntry,$DATA_Offset+68,4)
	$DATA_CompressionUnitSize = Dec(StringMid($DATA_CompressionUnitSize,3,2) & StringMid($DATA_CompressionUnitSize,1,2))
;	$DATA_CompressionUnitSize = Dec($DATA_CompressionUnitSize)
;	ConsoleWrite("$DATA_CompressionUnitSize = " & $DATA_CompressionUnitSize & @crlf)
	$DATA_Padding = StringMid($MFTEntry,$DATA_Offset+72,8)
	$DATA_Padding = StringMid($DATA_Padding,7,2) & StringMid($DATA_Padding,5,2) & StringMid($DATA_Padding,3,2) & StringMid($DATA_Padding,1,2)
	$DATA_AllocatedSize = StringMid($MFTEntry,$DATA_Offset+80,16)
;	ConsoleWrite("$DATA_AllocatedSize = " & $DATA_AllocatedSize & @crlf)
	$DATA_AllocatedSize = Dec(StringMid($DATA_AllocatedSize,15,2) & StringMid($DATA_AllocatedSize,13,2) & StringMid($DATA_AllocatedSize,11,2) & StringMid($DATA_AllocatedSize,9,2) & StringMid($DATA_AllocatedSize,7,2) & StringMid($DATA_AllocatedSize,5,2) & StringMid($DATA_AllocatedSize,3,2) & StringMid($DATA_AllocatedSize,1,2))
;	ConsoleWrite("$DATA_AllocatedSize = " & $DATA_AllocatedSize & @crlf)
;	$DATA_AllocatedSize = Dec($DATA_AllocatedSize)
;	ConsoleWrite("$DATA_AllocatedSize = " & $DATA_AllocatedSize & @crlf)
	$DATA_RealSize = StringMid($MFTEntry,$DATA_Offset+96,16)
;	ConsoleWrite("$DATA_RealSize = " & $DATA_RealSize & @crlf)
	$DATA_RealSize = Dec(StringMid($DATA_RealSize,15,2) & StringMid($DATA_RealSize,13,2) & StringMid($DATA_RealSize,11,2) & StringMid($DATA_RealSize,9,2) & StringMid($DATA_RealSize,7,2) & StringMid($DATA_RealSize,5,2) & StringMid($DATA_RealSize,3,2) & StringMid($DATA_RealSize,1,2))
;	ConsoleWrite("$DATA_RealSize = " & $DATA_RealSize & @crlf)
;	$DATA_RealSize = Dec($DATA_RealSize)
;	ConsoleWrite("$DATA_RealSize = " & $DATA_RealSize & @crlf)
	$DATA_InitializedStreamSize = StringMid($MFTEntry,$DATA_Offset+112,16)
;	ConsoleWrite("$DATA_InitializedStreamSize = " & $DATA_InitializedStreamSize & @crlf)
	$DATA_InitializedStreamSize = Dec(StringMid($DATA_InitializedStreamSize,15,2) & StringMid($DATA_InitializedStreamSize,13,2) & StringMid($DATA_InitializedStreamSize,11,2) & StringMid($DATA_InitializedStreamSize,9,2) & StringMid($DATA_InitializedStreamSize,7,2) & StringMid($DATA_InitializedStreamSize,5,2) & StringMid($DATA_InitializedStreamSize,3,2) & StringMid($DATA_InitializedStreamSize,1,2))
;	ConsoleWrite("$DATA_InitializedStreamSize = " & $DATA_InitializedStreamSize & @crlf)
;	$DATA_InitializedStreamSize = Dec($DATA_InitializedStreamSize)
;	ConsoleWrite("$DATA_InitializedStreamSize = " & $DATA_InitializedStreamSize & @crlf)
	$RunListOffset = StringMid($MFTEntry,$DATA_Offset+64,4)
;	ConsoleWrite("$RunListOffset = " & $RunListOffset & @crlf)
	$RunListOffset = StringMid($RunListOffset,3,2) & StringMid($RunListOffset,1,2)
	$RunListOffset = Dec($RunListOffset)
;	ConsoleWrite("$RunListOffset = " & $RunListOffset & @crlf)
	If $IsCompressed AND $RunListOffset = 72 Then
		$DATA_CompressedSize = StringMid($MFTEntry,$DATA_Offset+128,16)
		$DATA_CompressedSize = Dec(StringMid($DATA_CompressedSize,15,2) & StringMid($DATA_CompressedSize,13,2) & StringMid($DATA_CompressedSize,11,2) & StringMid($DATA_CompressedSize,9,2) & StringMid($DATA_CompressedSize,7,2) & StringMid($DATA_CompressedSize,5,2) & StringMid($DATA_CompressedSize,3,2) & StringMid($DATA_CompressedSize,1,2))
	EndIf
	$RunListID = StringMid($MFTEntry,$DATA_Offset+($RunListOffset*2),2)
;	ConsoleWrite("$RunListID = " & $RunListID & @crlf)
	$RunListSectorsLenght = Dec(StringMid($RunListID,2,1))
;	ConsoleWrite("$RunListSectorsLenght = " & $RunListSectorsLenght & @crlf)
	$RunListClusterLenght = Dec(StringMid($RunListID,1,1))
;	ConsoleWrite("$RunListClusterLenght = " & $RunListClusterLenght & @crlf)
	$RunListSectors = StringMid($MFTEntry,$DATA_Offset+($RunListOffset*2)+2,$RunListSectorsLenght*2)
;	ConsoleWrite("$RunListSectors = " & $RunListSectors & @crlf)
	$r = 1
	$entry = ''
	If $RunListClusterLenght = 0 Then
		If $MFTMode = 2 Then
			_ArrayInsert($MFT_RUN_Sectors,$r,0)
			_ArrayInsert($MFT_RUN_Sparse,$r,Dec($RunListSectors))
		EndIf
		_ArrayInsert($RUN_Sectors,$r,0)
		_ArrayInsert($RUN_Sparse,$r,Dec($RunListSectors))
		$RunListClusterNext = $RUN_Cluster[$r-1]
		If $MFTMode = 2 Then
			_ArrayInsert($MFT_RUN_Cluster,$r,$RunListClusterNext)
		EndIf
		_ArrayInsert($RUN_Cluster,$r,$RunListClusterNext)
		$RunListSectors = Dec($RunListSectors)
		$RunListSectorsTotal += $RunListSectors
;		ConsoleWrite("$RunListSectorsTotal = " & $RunListSectorsTotal & @crlf)
		If $RunListSectorsTotal >= $DATA_VCNs+1 Then
;			ConsoleWrite("No more data runs." & @crlf)
			Return
		EndIf
		$NewRunOffsetBase = $NewRunOffsetBase+2+($RunListSectorsLenght+$RunListClusterLenght)*2
	EndIf
	For $u = 0 To $RunListSectorsLenght-1
		$mod = StringMid($RunListSectors,($RunListSectorsLenght*2)-(($u*2)+1),2)
;			ConsoleWrite($mod & @crlf)
		$entry &= $mod
	Next
	$RunListSectors = Dec($entry)
	If $MFTMode = 2 Then
		_ArrayInsert($MFT_RUN_Sectors,1,$RunListSectors)
		_ArrayInsert($MFT_RUN_Sparse,1,0)
	EndIf
	_ArrayInsert($RUN_Sectors,1,$RunListSectors)
	_ArrayInsert($RUN_Sparse,1,0)
;	ConsoleWrite("$RunListSectors = " & $RunListSectors & @crlf)
	$RunListCluster = StringMid($MFTEntry,$DATA_Offset+($RunListOffset*2)+2+($RunListSectorsLenght*2),$RunListClusterLenght*2)
;	ConsoleWrite("$RunListCluster = " & $RunListCluster & @crlf)
	$entry = ''
	For $u = 0 To $RunListClusterLenght-1
		$mod = StringMid($RunListCluster,($RunListClusterLenght*2)-(($u*2)+1),2)
;			ConsoleWrite($mod & @crlf)
		$entry &= $mod
	Next
	$RunListCluster = Dec($entry)
	If $MFTMode = 2 Then
		_ArrayInsert($MFT_RUN_Cluster,1,$RunListCluster)
	EndIf
	_ArrayInsert($RUN_Cluster,1,$RunListCluster)
;	_ArrayDisplay($MFT_RUN_Sectors,"$MFT_RUN_Sectors")
;	_ArrayDisplay($MFT_RUN_Cluster,"$MFT_RUN_Cluster")
;	_ArrayDisplay($RUN_Sectors,"$RUN_Sectors")
;	_ArrayDisplay($RUN_Cluster,"$RUN_Cluster")
;	ConsoleWrite("$RunListCluster = " & $RunListCluster & @crlf)
;	ConsoleWrite("$DATA_VCNs = " & $DATA_VCNs & @crlf)
	If $MFTMode = 1 Then
		$DataArr[0][1] = "Data value " & $DATA_Number
		$DataArr[1][1] = $DATA_Length
		$DataArr[2][1] = $DATA_NonResidentFlag
		$DataArr[3][1] = $DATA_NameLength
		$DataArr[4][1] = $DATA_NameRelativeOffset
		$DataArr[5][1] = $DATA_Flags
		$DataArr[6][1] = $DATA_AttributeID
		$DataArr[7][1] = ""
		$DataArr[8][1] = ""
		$DataArr[9][1] = ""
		$DataArr[10][1] = ""
		$DataArr[11][1] = $DATA_StartVCN
		$DataArr[12][1] = $DATA_LastVCN
		$DataArr[13][1] = $DATA_OffsetToDataRuns
		$DataArr[14][1] = $DATA_CompressionUnitSize
		$DataArr[15][1] = $DATA_Padding
		$DataArr[16][1] = $DATA_AllocatedSize
		$DataArr[17][1] = $DATA_RealSize
		$DataArr[18][1] = $DATA_InitializedStreamSize
		$DataArr[19][1] = $DATA_Name
	EndIf
	If $RunListSectors = $DATA_VCNs+1 Then
;		ConsoleWrite("No more data runs." & @crlf)
	Else
;		ConsoleWrite("More data runs exist." & @crlf)
		$NewRunOffsetBase = $DATA_Offset+($RunListOffset*2)+2+($RunListSectorsLenght+$RunListClusterLenght)*2
;		_GetAllRuns($MFTEntry,$DATA_Offset,$DATA_Size,$DATA_VCNs,$NewRunOffsetBase)
		_GetAllRuns($MFTEntry,$DATA_Offset,$DATA_Size,$DATA_VCNs,$RunListOffset,$MFTMode,$IsCompressed)
	EndIf
;	_ArrayDisplay($RUN_Sectors,"$RUN_Sectors")
;	_ArrayDisplay($RUN_Cluster,"$RUN_Cluster")
	If $MFTMode = 2 Then Return
;	_ReassembleDataRuns($DATA_VCNs,$IsCompressed)

ElseIf $DATA_NonResidentFlag = '00' Then
;	ConsoleWrite("Processing resident data." & @crlf)
	$DATA_LengthOfAttribute = StringMid($MFTEntry,$DATA_Offset+32,8)
;	ConsoleWrite("$DATA_LengthOfAttribute = " & $DATA_LengthOfAttribute & @crlf)
	$DATA_LengthOfAttribute = Dec(StringMid($DATA_LengthOfAttribute,7,2) & StringMid($DATA_LengthOfAttribute,5,2) & StringMid($DATA_LengthOfAttribute,3,2) & StringMid($DATA_LengthOfAttribute,1,2))
;	ConsoleWrite("$DATA_LengthOfAttribute = " & $DATA_LengthOfAttribute & @crlf)
;	$DATA_LengthOfAttribute = Dec($DATA_LengthOfAttribute)
	$DATA_OffsetToAttribute = StringMid($MFTEntry,$DATA_Offset+40,4)
	$DATA_OffsetToAttribute = Dec(StringMid($DATA_OffsetToAttribute,3,2) & StringMid($DATA_OffsetToAttribute,1,2))
;	ConsoleWrite("$DATA_OffsetToAttribute = " & $DATA_OffsetToAttribute & @crlf)
;	$DATA_OffsetToAttribute = Dec($DATA_OffsetToAttribute)
	$DATA_IndexedFlag = Dec(StringMid($MFTEntry,$DATA_Offset+44,2))
;	$DATA_IndexedFlag = Dec($DATA_IndexedFlag)
	$DATA_Padding = StringMid($MFTEntry,$DATA_Offset+46,2)
	If $MFTMode = 1 Then
		$DataArr[0][1] = "Data value " & $DATA_Number
		$DataArr[1][1] = $DATA_Length
		$DataArr[2][1] = $DATA_NonResidentFlag
		$DataArr[3][1] = $DATA_NameLength
		$DataArr[4][1] = $DATA_NameRelativeOffset
		$DataArr[5][1] = $DATA_Flags
		$DataArr[6][1] = $DATA_AttributeID
		$DataArr[7][1] = $DATA_LengthOfAttribute
		$DataArr[8][1] = $DATA_OffsetToAttribute
		$DataArr[9][1] = $DATA_IndexedFlag
		$DataArr[10][1] = $DATA_Padding
		$DataArr[11][1] = ""
		$DataArr[12][1] = ""
		$DataArr[13][1] = ""
		$DataArr[14][1] = ""
		$DataArr[15][1] = ""
		$DataArr[16][1] = ""
		$DataArr[17][1] = ""
		$DataArr[18][1] = ""
		$DataArr[19][1] = $DATA_Name
	EndIf
	If $DATA_LengthOfAttribute = 0 Then Return
;	_ReassembleResidentData($MFTEntry,$DATA_Offset,$DATA_LengthOfAttribute,$IsCompressed)
EndIf
EndIf
If $DATA_Number = 2 Then
$DATA_Length_2 = StringMid($MFTEntry,$DATA_Offset+8,8)
$DATA_Length_2 = Dec(StringMid($DATA_Length_2,7,2) & StringMid($DATA_Length_2,5,2) & StringMid($DATA_Length_2,3,2) & StringMid($DATA_Length_2,1,2))
$DATA_NonResidentFlag_2 = StringMid($MFTEntry,$DATA_Offset+16,2)
;ConsoleWrite("$DATA_NonResidentFlag_2 = " & $DATA_NonResidentFlag_2 & @crlf)
$DATA_NameLength_2 = Dec(StringMid($MFTEntry,$DATA_Offset+18,2))
;$DATA_NameLength_2 = Dec($DATA_NameLength_2)
;ConsoleWrite("$DATA_NameLength_2 = " & $DATA_NameLength_2 & @crlf)
$DATA_NameRelativeOffset_2 = StringMid($MFTEntry,$DATA_Offset+20,4)
;ConsoleWrite("$DATA_NameRelativeOffset_2 = " & $DATA_NameRelativeOffset_2 & @crlf)
$DATA_NameRelativeOffset_2 = Dec(StringMid($DATA_NameRelativeOffset_2,3,2) & StringMid($DATA_NameRelativeOffset_2,1,2))
;$DATA_NameRelativeOffset_2 = Dec($DATA_NameRelativeOffset_2)
;ConsoleWrite("$DATA_NameRelativeOffset_2 = " & $DATA_NameRelativeOffset_2 & @crlf)
$DATA_Flags_2 = StringMid($MFTEntry,$DATA_Offset+24,4)
$DATA_Flags_2 = StringMid($DATA_Flags_2,3,2) & StringMid($DATA_Flags_2,1,2)
;ConsoleWrite("$DATA_Flags_2 = " & $DATA_Flags_2 & @crlf)
$DATA_Flags_2 = _AttribHeaderFlags("0x" & $DATA_Flags_2)
;ConsoleWrite("$DATA_Flags_2 = " & $DATA_Flags_2 & @crlf)
#cs
Select
	Case $DATA_Flags_2 = '0001'
		$DATA_Flags_2 = 'COMPRESSED'
	Case $DATA_Flags_2 = '4000'
		$DATA_Flags_2 = 'ENCRYPTED'
	Case $DATA_Flags_2 = '8000'
		$DATA_Flags_2 = 'SPARSE'
	Case $DATA_Flags_2 <> '0001' AND $DATA_Flags_2 <> '4000' AND $DATA_Flags_2 <> '8000'
		$DATA_Flags_2 = 'UNKNOWN'
EndSelect
#ce
If $DATA_NameLength_2 > 0 Then
	$DATA_NameSpace_2 = $DATA_NameLength_2-1
	$DATA_Name_2 = StringMid($MFTEntry,$DATA_Offset+($DATA_NameRelativeOffset_2*2),($DATA_NameLength_2+$DATA_NameSpace_2)*2)
	$DATA_Name_2 = _UnicodeHexToStr($DATA_Name_2)
EndIf
;ConsoleWrite("$DATA_Name_2 = " & $DATA_Name_2 & @crlf)
$DATA_AttributeID_2 = StringMid($MFTEntry,$DATA_Offset+28,4)
$DATA_AttributeID_2 = StringMid($DATA_AttributeID_2,3,2) & StringMid($DATA_AttributeID_2,1,2)
If $DATA_NonResidentFlag_2 = '01' Then
	$DATA_StartVCN_2 = StringMid($MFTEntry,$DATA_Offset+32,16)
;	ConsoleWrite("$DATA_StartVCN_2 = " & $DATA_StartVCN_2 & @crlf)
	$DATA_StartVCN_2 = StringMid($DATA_StartVCN_2,15,2) & StringMid($DATA_StartVCN_2,13,2) & StringMid($DATA_StartVCN_2,11,2) & StringMid($DATA_StartVCN_2,9,2) & StringMid($DATA_StartVCN_2,7,2) & StringMid($DATA_StartVCN_2,5,2) & StringMid($DATA_StartVCN_2,3,2) & StringMid($DATA_StartVCN_2,1,2)
;	ConsoleWrite("$DATA_StartVCN_2 = " & $DATA_StartVCN_2 & @crlf)
	$DATA_StartVCN_2 = Dec($DATA_StartVCN_2)
;	ConsoleWrite("$DATA_StartVCN_2 = " & $DATA_StartVCN_2 & @crlf)
	$DATA_LastVCN_2 = StringMid($MFTEntry,$DATA_Offset+48,16)
;	ConsoleWrite("$DATA_LastVCN_2 = " & $DATA_LastVCN_2 & @crlf)
	$DATA_LastVCN_2 = StringMid($DATA_LastVCN_2,15,2) & StringMid($DATA_LastVCN_2,13,2) & StringMid($DATA_LastVCN_2,11,2) & StringMid($DATA_LastVCN_2,9,2) & StringMid($DATA_LastVCN_2,7,2) & StringMid($DATA_LastVCN_2,5,2) & StringMid($DATA_LastVCN_2,3,2) & StringMid($DATA_LastVCN_2,1,2)
;	ConsoleWrite("$DATA_LastVCN_2 = " & $DATA_LastVCN_2 & @crlf)
	$DATA_LastVCN_2 = Dec($DATA_LastVCN_2)
;	ConsoleWrite("$DATA_LastVCN_2 = " & $DATA_LastVCN_2 & @crlf)
	$DATA_VCNs_2 = $DATA_LastVCN_2 - $DATA_StartVCN_2
;	ConsoleWrite("$DATA_VCNs_2 = " & $DATA_VCNs_2 & @crlf)
	$DATA_OffsetToDataRuns_2 = StringMid($MFTEntry,$DATA_Offset+64,4)
	$DATA_OffsetToDataRuns_2 = Dec(StringMid($DATA_OffsetToDataRuns_2,3,1) & StringMid($DATA_OffsetToDataRuns_2,3,1))
	$DATA_CompressionUnitSize_2 = StringMid($MFTEntry,$DATA_Offset+68,4)
	$DATA_CompressionUnitSize_2 = StringMid($DATA_CompressionUnitSize_2,3,2) & StringMid($DATA_CompressionUnitSize_2,1,2)
	$DATA_CompressionUnitSize_2 = Dec($DATA_CompressionUnitSize_2)
	$DATA_Padding_2 = StringMid($MFTEntry,$DATA_Offset+72,8)
	$DATA_Padding_2 = StringMid($DATA_Padding_2,7,2) & StringMid($DATA_Padding_2,5,2) & StringMid($DATA_Padding_2,3,2) & StringMid($DATA_Padding_2,1,2)
	$DATA_AllocatedSize_2 = StringMid($MFTEntry,$DATA_Offset+80,16)
;	ConsoleWrite("$DATA_AllocatedSize_2 = " & $DATA_AllocatedSize_2 & @crlf)
	$DATA_AllocatedSize_2 = StringMid($DATA_AllocatedSize_2,15,2) & StringMid($DATA_AllocatedSize_2,13,2) & StringMid($DATA_AllocatedSize_2,11,2) & StringMid($DATA_AllocatedSize_2,9,2) & StringMid($DATA_AllocatedSize_2,7,2) & StringMid($DATA_AllocatedSize_2,5,2) & StringMid($DATA_AllocatedSize_2,3,2) & StringMid($DATA_AllocatedSize_2,1,2)
;	ConsoleWrite("$DATA_AllocatedSize_2 = " & $DATA_AllocatedSize_2 & @crlf)
	$DATA_AllocatedSize_2 = Dec($DATA_AllocatedSize_2)
;	ConsoleWrite("$DATA_AllocatedSize_2 = " & $DATA_AllocatedSize_2 & @crlf)
	$DATA_RealSize_2 = StringMid($MFTEntry,$DATA_Offset+96,16)
;	ConsoleWrite("$DATA_RealSize_2 = " & $DATA_RealSize_2 & @crlf)
	$DATA_RealSize_2 = StringMid($DATA_RealSize_2,15,2) & StringMid($DATA_RealSize_2,13,2) & StringMid($DATA_RealSize_2,11,2) & StringMid($DATA_RealSize_2,9,2) & StringMid($DATA_RealSize_2,7,2) & StringMid($DATA_RealSize_2,5,2) & StringMid($DATA_RealSize_2,3,2) & StringMid($DATA_RealSize_2,1,2)
;	ConsoleWrite("$DATA_RealSize_2 = " & $DATA_RealSize_2 & @crlf)
	$DATA_RealSize_2 = Dec($DATA_RealSize_2)
;	ConsoleWrite("$DATA_RealSize_2 = " & $DATA_RealSize_2 & @crlf)
	$DATA_InitializedStreamSize_2 = StringMid($MFTEntry,$DATA_Offset+112,16)
;	ConsoleWrite("$DATA_InitializedStreamSize_2 = " & $DATA_InitializedStreamSize_2 & @crlf)
	$DATA_InitializedStreamSize_2 = StringMid($DATA_InitializedStreamSize_2,15,2) & StringMid($DATA_InitializedStreamSize_2,13,2) & StringMid($DATA_InitializedStreamSize_2,11,2) & StringMid($DATA_InitializedStreamSize_2,9,2) & StringMid($DATA_InitializedStreamSize_2,7,2) & StringMid($DATA_InitializedStreamSize_2,5,2) & StringMid($DATA_InitializedStreamSize_2,3,2) & StringMid($DATA_InitializedStreamSize_2,1,2)
;	ConsoleWrite("$DATA_InitializedStreamSize_2 = " & $DATA_InitializedStreamSize_2 & @crlf)
	$DATA_InitializedStreamSize_2 = Dec($DATA_InitializedStreamSize_2)
;	ConsoleWrite("$DATA_InitializedStreamSize_2 = " & $DATA_InitializedStreamSize_2 & @crlf)
	If $MFTMode = 1 Then
		$DataArr[0][2] = "Data value " & $DATA_Number
		$DataArr[1][2] = $DATA_Length_2
		$DataArr[2][2] = $DATA_NonResidentFlag_2
		$DataArr[3][2] = $DATA_NameLength_2
		$DataArr[4][2] = $DATA_NameRelativeOffset_2
		$DataArr[5][2] = $DATA_Flags_2
		$DataArr[6][2] = $DATA_AttributeID_2
		$DataArr[7][2] = ""
		$DataArr[8][2] = ""
		$DataArr[9][2] = ""
		$DataArr[10][2] = ""
		$DataArr[11][2] = $DATA_StartVCN_2
		$DataArr[12][2] = $DATA_LastVCN_2
		$DataArr[13][2] = $DATA_OffsetToDataRuns_2
		$DataArr[14][2] = $DATA_CompressionUnitSize_2
		$DataArr[15][2] = $DATA_Padding_2
		$DataArr[16][2] = $DATA_AllocatedSize_2
		$DataArr[17][2] = $DATA_RealSize_2
		$DataArr[18][2] = $DATA_InitializedStreamSize_2
		$DataArr[19][2] = $DATA_Name_2
	EndIf
ElseIf $DATA_NonResidentFlag_2 = '00' Then
	$DATA_LengthOfAttribute_2 = StringMid($MFTEntry,$DATA_Offset+32,8)
	$DATA_LengthOfAttribute_2 = Dec(StringMid($DATA_LengthOfAttribute_2,7,2) & StringMid($DATA_LengthOfAttribute_2,5,2) & StringMid($DATA_LengthOfAttribute_2,3,2) & StringMid($DATA_LengthOfAttribute_2,1,2))
;	$DATA_LengthOfAttribute_2 = Dec($DATA_LengthOfAttribute_2)
	$DATA_OffsetToAttribute_2 = StringMid($MFTEntry,$DATA_Offset+40,4)
	$DATA_OffsetToAttribute_2 = Dec(StringMid($DATA_OffsetToAttribute_2,3,2) & StringMid($DATA_OffsetToAttribute_2,1,2))
;	$DATA_OffsetToAttribute_2 = Dec($DATA_OffsetToAttribute_2)
	$DATA_IndexedFlag_2 = Dec(StringMid($MFTEntry,$DATA_Offset+44,2))
;	$DATA_IndexedFlag_2 = Dec($DATA_IndexedFlag_2)
	$DATA_Padding_2 = StringMid($MFTEntry,$DATA_Offset+46,2)
	If $MFTMode = 1 Then
		$DataArr[0][2] = "Data value " & $DATA_Number
		$DataArr[1][2] = $DATA_Length_2
		$DataArr[2][2] = $DATA_NonResidentFlag_2
		$DataArr[3][2] = $DATA_NameLength_2
		$DataArr[4][2] = $DATA_NameRelativeOffset_2
		$DataArr[5][2] = $DATA_Flags_2
		$DataArr[6][2] = $DATA_AttributeID_2
		$DataArr[7][2] = $DATA_LengthOfAttribute_2
		$DataArr[8][2] = $DATA_OffsetToAttribute_2
		$DataArr[9][2] = $DATA_IndexedFlag_2
		$DataArr[10][2] = $DATA_Padding_2
		$DataArr[11][2] = ""
		$DataArr[12][2] = ""
		$DataArr[13][2] = ""
		$DataArr[14][2] = ""
		$DataArr[15][2] = ""
		$DataArr[16][2] = ""
		$DataArr[17][2] = ""
		$DataArr[18][2] = ""
		$DataArr[19][2] = $DATA_Name_2
	EndIf
EndIf
EndIf
EndFunc

Func _GetAllRuns($MFTEntry,$DATA_Offset,$DATA_Size,$DATA_VCNs,$RunListOffset,$MFTMode,$IsCompressed)
Local $RunListClusterNext, $RunListSectorsTotal, $NewRunOffsetBase
;ConsoleWrite("Started function _GetAllRuns()" & @crlf)
$maxarr = Ubound($RUN_Cluster)
For $j = 1 To $maxarr
	_ArrayDelete($RUN_Cluster,$maxarr-$j)
	_ArrayDelete($RUN_Sectors,$maxarr-$j)
	_ArrayDelete($RUN_Sparse,$maxarr-$j)
	If $maxarr-$j=1 Then ExitLoop
Next
If $MFTMode = 2 Then
	$MFTmaxarr = Ubound($MFT_RUN_Cluster)
	For $j = 1 To $MFTmaxarr
		_ArrayDelete($MFT_RUN_Cluster,$MFTmaxarr-$j)
		_ArrayDelete($MFT_RUN_Sectors,$MFTmaxarr-$j)
		_ArrayDelete($MFT_RUN_Sparse,$MFTmaxarr-$j)
		If $MFTmaxarr-$j=1 Then ExitLoop
	Next
EndIf
;$RunListOffset = StringMid($MFTEntry,$DATA_Offset+20,4)
;ConsoleWrite("$RunListOffset = " & $RunListOffset & @crlf)
;$RunListOffset = StringMid($RunListOffset,3,2) & StringMid($RunListOffset,1,2)
;$RunListOffset = Dec($RunListOffset)
;ConsoleWrite("$RunListOffset = " & $RunListOffset & @crlf)
$RunListID = StringMid($MFTEntry,$DATA_Offset+($RunListOffset*2),2)
;ConsoleWrite("$RunListID = " & $RunListID & @crlf)
$RunListSectorsLenght = Dec(StringMid($RunListID,2,1))
;ConsoleWrite("$RunListSectorsLenght = " & $RunListSectorsLenght & @crlf)
$RunListClusterLenght = Dec(StringMid($RunListID,1,1))
;ConsoleWrite("$RunListClusterLenght = " & $RunListClusterLenght & @crlf)
$RunListSectors = StringMid($MFTEntry,$DATA_Offset+($RunListOffset*2)+2,$RunListSectorsLenght*2)
;ConsoleWrite("$RunListSectors = " & $RunListSectors & @crlf)
$r = 1
If $RunListClusterLenght = 0 Then
	If $MFTMode = 2 Then
		_ArrayInsert($MFT_RUN_Sectors,$r,0)
		_ArrayInsert($MFT_RUN_Sparse,$r,Dec($RunListSectors))
	EndIf
	_ArrayInsert($RUN_Sectors,$r,0)
	_ArrayInsert($RUN_Sparse,$r,Dec($RunListSectors))
	$RunListClusterNext = $RUN_Cluster[$r-1]
	If $MFTMode = 2 Then
		_ArrayInsert($MFT_RUN_Cluster,$r,$RunListClusterNext)
	EndIf
	_ArrayInsert($RUN_Cluster,$r,$RunListClusterNext)
	$RunListSectors = Dec($RunListSectors)
	$RunListSectorsTotal += $RunListSectors
;	ConsoleWrite("$RunListSectorsTotal = " & $RunListSectorsTotal & @crlf)
	If $RunListSectorsTotal >= $DATA_VCNs+1 Then
;		ConsoleWrite("No more data runs." & @crlf)
		Return
	EndIf
	$NewRunOffsetBase = $NewRunOffsetBase+2+($RunListSectorsLenght+$RunListClusterLenght)*2
EndIf
$entry = ''
For $u = 0 To $RunListSectorsLenght-1
	$mod = StringMid($RunListSectors,($RunListSectorsLenght*2)-(($u*2)+1),2)
	$entry &= $mod
Next
$RunListSectors = Dec($entry)
;ConsoleWrite("$RunListSectors = " & $RunListSectors & @crlf)
If $MFTMode = 2 Then
	_ArrayInsert($MFT_RUN_Sectors,1,$RunListSectors)
	_ArrayInsert($MFT_RUN_Sparse,1,0)
EndIf
_ArrayInsert($RUN_Sectors,1,$RunListSectors)
_ArrayInsert($RUN_Sparse,1,0)
;MsgBox(0,"@error - $RUN_Sectors",@error)
$RunListCluster = StringMid($MFTEntry,$DATA_Offset+($RunListOffset*2)+2+($RunListSectorsLenght*2),$RunListClusterLenght*2)
;ConsoleWrite("$RunListCluster = " & $RunListCluster & @crlf)
$entry = ''
For $u = 0 To $RunListClusterLenght-1
	$mod = StringMid($RunListCluster,($RunListClusterLenght*2)-(($u*2)+1),2)
	$entry &= $mod
Next
$RunListCluster = Dec($entry)
;ConsoleWrite("$RunListCluster = " & $RunListCluster & @crlf)
If $MFTMode = 2 Then
	_ArrayInsert($MFT_RUN_Cluster,1,$RunListCluster)
EndIf
_ArrayInsert($RUN_Cluster,1,$RunListCluster)
;MsgBox(0,"@error - $RUN_Cluster",@error)
If $RunListSectors = $DATA_VCNs+1 Then
;	ConsoleWrite("No more data runs." & @crlf)
	Return
EndIf
$NewRunOffsetBase = $DATA_Offset+($RunListOffset*2)+2+($RunListSectorsLenght+$RunListClusterLenght)*2
;ConsoleWrite("$NewRunOffsetBase = " & $NewRunOffsetBase & @crlf)
;ConsoleWrite("$DATA_VCNs = " & $DATA_VCNs & @crlf)
$RunListSectorsTotal = $RunListSectors
While $RunListSectors < $DATA_VCNs+1
	$r += 1
;	ConsoleWrite("$r = " & $r & @crlf)
	$RunListID = StringMid($MFTEntry,$NewRunOffsetBase,2)
;	ConsoleWrite("$RunListID = " & $RunListID & @crlf)
	$RunListSectorsLenght = Dec(StringMid($RunListID,2,1))
;	ConsoleWrite("$RunListSectorsLenght = " & $RunListSectorsLenght & @crlf)
	$RunListClusterLenght = Dec(StringMid($RunListID,1,1))
;	ConsoleWrite("$RunListClusterLenght = " & $RunListClusterLenght & @crlf)
	$RunListSectors = StringMid($MFTEntry,$NewRunOffsetBase+2,$RunListSectorsLenght*2)
;	ConsoleWrite("$RunListSectors = " & $RunListSectors & @crlf)
	If $RunListClusterLenght = 0 Then
		If $MFTMode = 2 Then
			_ArrayInsert($MFT_RUN_Sectors,$r,0)
			_ArrayInsert($MFT_RUN_Sparse,$r,Dec($RunListSectors))
		EndIf
		_ArrayInsert($RUN_Sectors,$r,0)
		_ArrayInsert($RUN_Sparse,$r,Dec($RunListSectors))
;		$RunListClusterNext = $RUN_Cluster[$r-1] + $RunListCluster
;		$RunListClusterNext = $RUN_Cluster[$r-1] + 0
		$RunListClusterNext = $RUN_Cluster[$r-1]
		If $MFTMode = 2 Then
			_ArrayInsert($MFT_RUN_Cluster,$r,$RunListClusterNext)
		EndIf
		_ArrayInsert($RUN_Cluster,$r,$RunListClusterNext)
		$RunListSectors = Dec($RunListSectors)
		$RunListSectorsTotal += $RunListSectors
;		ConsoleWrite("$RunListSectorsTotal = " & $RunListSectorsTotal & @crlf)
		If $RunListSectorsTotal >= $DATA_VCNs+1 Then
;			ConsoleWrite("No more data runs." & @crlf)
			Return
		EndIf
		$NewRunOffsetBase = $NewRunOffsetBase+2+($RunListSectorsLenght+$RunListClusterLenght)*2
		ContinueLoop
	EndIf

	$entry = ''
	For $u = 0 To $RunListSectorsLenght-1
		$mod = StringMid($RunListSectors,($RunListSectorsLenght*2)-(($u*2)+1),2)
		$entry &= $mod
	Next
	$RunListSectors = Dec($entry)
;	ConsoleWrite("$RunListSectors = " & $RunListSectors & @crlf)
	If $MFTMode = 2 Then
		_ArrayInsert($MFT_RUN_Sectors,$r,$RunListSectors)
		_ArrayInsert($MFT_RUN_Sparse,$r,0)
	EndIf
	_ArrayInsert($RUN_Sectors,$r,$RunListSectors)
	_ArrayInsert($RUN_Sparse,$r,0)
	$RunListCluster = StringMid($MFTEntry,$NewRunOffsetBase+2+($RunListSectorsLenght*2),$RunListClusterLenght*2)
;	ConsoleWrite("$RunListCluster = " & $RunListCluster & @crlf)
	$NegativeMove = 0
;Here we must read to check positive/negative relative move
	If Dec(StringMid($RunListCluster,StringLen($RunListCluster)-1,1)) > 7 Then
		$NegativeMove = 1
	EndIf
;	ConsoleWrite("$NegativeMove = " & $NegativeMove & @crlf)
	$entry = ''
	For $u = 0 To $RunListClusterLenght-1
		$mod = StringMid($RunListCluster,($RunListClusterLenght*2)-(($u*2)+1),2)
	$entry &= $mod
	Next
;	ConsoleWrite("$entry = " & $entry & @crlf)
	$RunListCluster = Dec($entry)
;	ConsoleWrite("$RunListCluster = " & $RunListCluster & @crlf)

	If $NegativeMove = 1 Then
		$p2 = ''
		For $hexnum = 1 To $RunListClusterLenght*2 ;My stupid xor substitute
			$p1 = 'F'
			$p2 &= $p1
		Next
		$FFXor = Dec($p2) - $RunListCluster
		$RunListClusterTmp = $FFXor + 1
		$RunListClusterNext = $RUN_Cluster[$r-1] - $RunListClusterTmp
	ElseIf $NegativeMove = 0 Then
		$RunListClusterNext = $RUN_Cluster[$r-1] + $RunListCluster
	EndIf
;	ConsoleWrite("$RunListClusterNext = " & $RunListClusterNext & @crlf)
	If $MFTMode = 2 Then
		_ArrayInsert($MFT_RUN_Cluster,$r,$RunListClusterNext)
	EndIf
	_ArrayInsert($RUN_Cluster,$r,$RunListClusterNext)
	$RunListSectorsTotal += $RunListSectors
;	ConsoleWrite("$RunListSectorsTotal = " & $RunListSectorsTotal & @crlf)
	If $RunListSectorsTotal = $DATA_VCNs+1 Then
;		ConsoleWrite("No more data runs." & @crlf)
		Return
	EndIf
	$NewRunOffsetBase = $NewRunOffsetBase+2+($RunListSectorsLenght+$RunListClusterLenght)*2
;	ConsoleWrite("$NewRunOffsetBase = " & $NewRunOffsetBase & @crlf)
WEnd
ConsoleWrite("DataRuns: Error - Something must have gone wrong. Should not be here..." & @crlf)
;_DisplayInfo("DataRuns: Error - Something must have gone wrong. Should not be here..." & @crlf)
Return
EndFunc

Func _Get_StandardInformation($MFTEntry,$SI_Offset,$SI_Size,$MFTMode)
;ConsoleWrite("$SI_Size = " & $SI_Size & @crlf)
$SI_HEADER_Flags = StringMid($MFTEntry,$SI_Offset+24,4)
$SI_HEADER_Flags = StringMid($SI_HEADER_Flags,3,2) & StringMid($SI_HEADER_Flags,1,2)
;ConsoleWrite("$SI_HEADER_Flags = " & $SI_HEADER_Flags & @crlf)
$SI_HEADER_Flags = _AttribHeaderFlags("0x" & $SI_HEADER_Flags)
;ConsoleWrite("$SI_HEADER_Flags = " & $SI_HEADER_Flags & @crlf)
;
$SI_CTime = StringMid($MFTEntry,$SI_Offset+48,16)
;ConsoleWrite("$SI_CTime = " & $SI_CTime & @crlf)
$SI_CTime = StringMid($SI_CTime,15,2) & StringMid($SI_CTime,13,2) & StringMid($SI_CTime,11,2) & StringMid($SI_CTime,9,2) & StringMid($SI_CTime,7,2) & StringMid($SI_CTime,5,2) & StringMid($SI_CTime,3,2) & StringMid($SI_CTime,1,2)
;$SI_CTime = Dec(StringMid($SI_CTime,15,2) & StringMid($SI_CTime,13,2) & StringMid($SI_CTime,11,2) & StringMid($SI_CTime,9,2) & StringMid($SI_CTime,7,2) & StringMid($SI_CTime,5,2) & StringMid($SI_CTime,3,2) & StringMid($SI_CTime,1,2))
;ConsoleWrite("$SI_CTime = " & $SI_CTime & @crlf)
$SI_CTime_tmp = _WinTime_UTCFileTimeToLocalFileTime("0x" & $SI_CTime)
;ConsoleWrite("$SI_CTime_tmp = " & $SI_CTime_tmp & @crlf)
$SI_CTime = _WinTime_UTCFileTimeFormat(Dec($SI_CTime)-$tDelta,$DateTimeFormat,2)
$SI_CTime = $SI_CTime & ":" & _FillZero(StringRight($SI_CTime_tmp,4))
;ConsoleWrite("$SI_CTime = " & $SI_CTime & @crlf)
;$MSecTest = _Test_MilliSec($SI_CTime)
;
$SI_ATime = StringMid($MFTEntry,$SI_Offset+64,16)
;ConsoleWrite("$SI_ATime = " & $SI_ATime & @crlf)
$SI_ATime = StringMid($SI_ATime,15,2) & StringMid($SI_ATime,13,2) & StringMid($SI_ATime,11,2) & StringMid($SI_ATime,9,2) & StringMid($SI_ATime,7,2) & StringMid($SI_ATime,5,2) & StringMid($SI_ATime,3,2) & StringMid($SI_ATime,1,2)
;$SI_ATime = Dec(StringMid($SI_ATime,15,2) & StringMid($SI_ATime,13,2) & StringMid($SI_ATime,11,2) & StringMid($SI_ATime,9,2) & StringMid($SI_ATime,7,2) & StringMid($SI_ATime,5,2) & StringMid($SI_ATime,3,2) & StringMid($SI_ATime,1,2))
;ConsoleWrite("$SI_ATime = " & $SI_ATime & @crlf)
$SI_ATime_tmp = _WinTime_UTCFileTimeToLocalFileTime("0x" & $SI_ATime)
;ConsoleWrite("$SI_ATime_tmp = " & $SI_ATime_tmp & @crlf)
$SI_ATime = _WinTime_UTCFileTimeFormat(Dec($SI_ATime)-$tDelta,$DateTimeFormat,2)
$SI_ATime = $SI_ATime & ":" & _FillZero(StringRight($SI_ATime_tmp,4))
;ConsoleWrite("$SI_ATime = " & $SI_ATime & @crlf)
;
$SI_MTime = StringMid($MFTEntry,$SI_Offset+80,16)
;ConsoleWrite("$SI_MTime = " & $SI_MTime & @crlf)
$SI_MTime = StringMid($SI_MTime,15,2) & StringMid($SI_MTime,13,2) & StringMid($SI_MTime,11,2) & StringMid($SI_MTime,9,2) & StringMid($SI_MTime,7,2) & StringMid($SI_MTime,5,2) & StringMid($SI_MTime,3,2) & StringMid($SI_MTime,1,2)
;$SI_MTime = Dec(StringMid($SI_MTime,15,2) & StringMid($SI_MTime,13,2) & StringMid($SI_MTime,11,2) & StringMid($SI_MTime,9,2) & StringMid($SI_MTime,7,2) & StringMid($SI_MTime,5,2) & StringMid($SI_MTime,3,2) & StringMid($SI_MTime,1,2))
;ConsoleWrite("$SI_MTime = " & $SI_MTime & @crlf)
$SI_MTime_tmp = _WinTime_UTCFileTimeToLocalFileTime("0x" & $SI_MTime)
;ConsoleWrite("$SI_MTime_tmp = " & $SI_MTime_tmp & @crlf)
$SI_MTime = _WinTime_UTCFileTimeFormat(Dec($SI_MTime)-$tDelta,$DateTimeFormat,2)
$SI_MTime = $SI_MTime & ":" & _FillZero(StringRight($SI_MTime_tmp,4))
;ConsoleWrite("$SI_MTime = " & $SI_MTime & @crlf)
;
$SI_RTime = StringMid($MFTEntry,$SI_Offset+96,16)
;ConsoleWrite("$SI_RTime = " & $SI_RTime & @crlf)
$SI_RTime = StringMid($SI_RTime,15,2) & StringMid($SI_RTime,13,2) & StringMid($SI_RTime,11,2) & StringMid($SI_RTime,9,2) & StringMid($SI_RTime,7,2) & StringMid($SI_RTime,5,2) & StringMid($SI_RTime,3,2) & StringMid($SI_RTime,1,2)
;$SI_RTime = Dec(StringMid($SI_RTime,15,2) & StringMid($SI_RTime,13,2) & StringMid($SI_RTime,11,2) & StringMid($SI_RTime,9,2) & StringMid($SI_RTime,7,2) & StringMid($SI_RTime,5,2) & StringMid($SI_RTime,3,2) & StringMid($SI_RTime,1,2))
;ConsoleWrite("$SI_RTime = " & $SI_RTime & @crlf)
$SI_RTime_tmp = _WinTime_UTCFileTimeToLocalFileTime("0x" & $SI_RTime)
;ConsoleWrite("$SI_RTime_tmp = " & $SI_RTime_tmp & @crlf)
$SI_RTime = _WinTime_UTCFileTimeFormat(Dec($SI_RTime)-$tDelta,$DateTimeFormat,2)
$SI_RTime = $SI_RTime & ":" & _FillZero(StringRight($SI_RTime_tmp,4))
;ConsoleWrite("$SI_RTime = " & $SI_RTime & @crlf)
;
$SI_FilePermission = StringMid($MFTEntry,$SI_Offset+112,8)
$SI_FilePermission = StringMid($SI_FilePermission,7,2) & StringMid($SI_FilePermission,5,2) & StringMid($SI_FilePermission,3,2) & StringMid($SI_FilePermission,1,2)
;ConsoleWrite("$SI_FilePermission = " & $SI_FilePermission & @crlf)
$SI_FilePermission = _File_Permissions("0x" & $SI_FilePermission)
;ConsoleWrite("$SI_FilePermission = " & $SI_FilePermission & @crlf)
$SI_MaxVersions = StringMid($MFTEntry,$SI_Offset+120,8)
$SI_MaxVersions = Dec(StringMid($SI_MaxVersions,7,2) & StringMid($SI_MaxVersions,5,2) & StringMid($SI_MaxVersions,3,2) & StringMid($SI_MaxVersions,1,2))
;$SI_MaxVersions = Dec($SI_MaxVersions)
$SI_VersionNumber = StringMid($MFTEntry,$SI_Offset+128,8)
$SI_VersionNumber = Dec(StringMid($SI_VersionNumber,7,2) & StringMid($SI_VersionNumber,5,2) & StringMid($SI_VersionNumber,3,2) & StringMid($SI_VersionNumber,1,2))
;$SI_VersionNumber = Dec($SI_VersionNumber)
$SI_ClassID = StringMid($MFTEntry,$SI_Offset+136,8)
$SI_ClassID = Dec(StringMid($SI_ClassID,7,2) & StringMid($SI_ClassID,5,2) & StringMid($SI_ClassID,3,2) & StringMid($SI_ClassID,1,2))
;$SI_ClassID = Dec($SI_ClassID)
$SI_OwnerID = StringMid($MFTEntry,$SI_Offset+144,8)
$SI_OwnerID = Dec(StringMid($SI_OwnerID,7,2) & StringMid($SI_OwnerID,5,2) & StringMid($SI_OwnerID,3,2) & StringMid($SI_OwnerID,1,2))
;$SI_OwnerID = Dec($SI_OwnerID)
$SI_SecurityID = StringMid($MFTEntry,$SI_Offset+152,8)
$SI_SecurityID = Dec(StringMid($SI_SecurityID,7,2) & StringMid($SI_SecurityID,5,2) & StringMid($SI_SecurityID,3,2) & StringMid($SI_SecurityID,1,2))
;$SI_SecurityID = Dec($SI_SecurityID)
$SI_USN = StringMid($MFTEntry,$SI_Offset+176,16)
$SI_USN = StringMid($SI_USN,15,2) & StringMid($SI_USN,13,2) & StringMid($SI_USN,11,2) & StringMid($SI_USN,9,2) & StringMid($SI_USN,7,2) & StringMid($SI_USN,5,2) & StringMid($SI_USN,3,2) & StringMid($SI_USN,1,2)
;$SI_USN = Dec($SI_USN)
;ConsoleWrite("$SI_USN = " & $SI_USN & @crlf)
If $MFTMode = 1 Then
	$SIArr[1][1] = $SI_HEADER_Flags
	$SIArr[2][1] = $SI_CTime
	$SIArr[3][1] = $SI_ATime
	$SIArr[4][1] = $SI_MTime
	$SIArr[5][1] = $SI_RTime
	$SIArr[6][1] = $SI_FilePermission
	$SIArr[7][1] = $SI_MaxVersions
	$SIArr[8][1] = $SI_VersionNumber
	$SIArr[9][1] = $SI_ClassID
	$SIArr[10][1] = $SI_OwnerID
	$SIArr[11][1] = $SI_SecurityID
	$SIArr[12][1] = $SI_USN
;
	$SIArr[1][2] = $SI_Offset+24
	$SIArr[2][2] = $SI_Offset+48
	$SIArr[3][2] = $SI_Offset+64
	$SIArr[4][2] = $SI_Offset+80
	$SIArr[5][2] = $SI_Offset+96
	$SIArr[6][2] = $SI_Offset+112
	$SIArr[7][2] = $SI_Offset+120
	$SIArr[8][2] = $SI_Offset+128
	$SIArr[9][2] = $SI_Offset+136
	$SIArr[10][2] = $SI_Offset+144
	$SIArr[11][2] = $SI_Offset+152
	$SIArr[12][2] = $SI_Offset+176
;
	$SIArr[1][3] = 2
	$SIArr[2][3] = 8
	$SIArr[3][3] = 8
	$SIArr[4][3] = 8
	$SIArr[5][3] = 8
	$SIArr[6][3] = 4
	$SIArr[7][3] = 4
	$SIArr[8][3] = 4
	$SIArr[9][3] = 4
	$SIArr[10][3] = 4
	$SIArr[11][3] = 4
	$SIArr[12][3] = 8
EndIf
EndFunc

Func _Get_FileName($MFTEntry,$FN_Offset,$FN_Size,$FN_Number,$MFTMode)
If $FN_Number = 1 Then
$FN_ParentReferenceNo = StringMid($MFTEntry,$FN_Offset+48,12)
;ConsoleWrite("$FN_ParentReferenceNo = " & $FN_ParentReferenceNo & @crlf)
$FN_ParentReferenceNo = Dec(StringMid($FN_ParentReferenceNo,11,2) & StringMid($FN_ParentReferenceNo,9,2) & StringMid($FN_ParentReferenceNo,7,2) & StringMid($FN_ParentReferenceNo,5,2) & StringMid($FN_ParentReferenceNo,3,2) & StringMid($FN_ParentReferenceNo,1,2))
;$FN_ParentReferenceNo = Dec($FN_ParentReferenceNo)
;ConsoleWrite("$FN_ParentReferenceNo = " & $FN_ParentReferenceNo & @crlf)
$FN_ParentSequenceNo = StringMid($MFTEntry,$FN_Offset+60,4)
;ConsoleWrite("$FN_ParentSequenceNo = " & $FN_ParentSequenceNo & @crlf)
$FN_ParentSequenceNo = Dec(StringMid($FN_ParentSequenceNo,3,2) & StringMid($FN_ParentSequenceNo,1,2))
;$FN_ParentSequenceNo = Dec($FN_ParentSequenceNo)
;ConsoleWrite("$FN_ParentSequenceNo = " & $FN_ParentSequenceNo & @crlf)
;ConsoleWrite("$FN_Size = " & $FN_Size & @crlf)
;
$FN_CTime = StringMid($MFTEntry,$FN_Offset+64,16)
;ConsoleWrite("$FN_CTime = " & $FN_CTime & @crlf)
$FN_CTime = StringMid($FN_CTime,15,2) & StringMid($FN_CTime,13,2) & StringMid($FN_CTime,11,2) & StringMid($FN_CTime,9,2) & StringMid($FN_CTime,7,2) & StringMid($FN_CTime,5,2) & StringMid($FN_CTime,3,2) & StringMid($FN_CTime,1,2)
;$FN_CTime = Dec(StringMid($FN_CTime,15,2) & StringMid($FN_CTime,13,2) & StringMid($FN_CTime,11,2) & StringMid($FN_CTime,9,2) & StringMid($FN_CTime,7,2) & StringMid($FN_CTime,5,2) & StringMid($FN_CTime,3,2) & StringMid($FN_CTime,1,2))
;ConsoleWrite("$FN_CTime = " & $FN_CTime & @crlf)
$FN_CTime_tmp = _WinTime_UTCFileTimeToLocalFileTime("0x" & $FN_CTime)
;ConsoleWrite("$FN_CTime_tmp = " & $FN_CTime_tmp & @crlf)
$FN_CTime = _WinTime_UTCFileTimeFormat(Dec($FN_CTime)-$tDelta,$DateTimeFormat,2)
$FN_CTime = $FN_CTime & ":" & _FillZero(StringRight($FN_CTime_tmp,4))
;ConsoleWrite("$FN_CTime = " & $FN_CTime & @crlf)
;
$FN_ATime = StringMid($MFTEntry,$FN_Offset+80,16)
;ConsoleWrite("$FN_ATime = " & $FN_ATime & @crlf)
$FN_ATime = StringMid($FN_ATime,15,2) & StringMid($FN_ATime,13,2) & StringMid($FN_ATime,11,2) & StringMid($FN_ATime,9,2) & StringMid($FN_ATime,7,2) & StringMid($FN_ATime,5,2) & StringMid($FN_ATime,3,2) & StringMid($FN_ATime,1,2)
;$FN_ATime = Dec(StringMid($FN_ATime,15,2) & StringMid($FN_ATime,13,2) & StringMid($FN_ATime,11,2) & StringMid($FN_ATime,9,2) & StringMid($FN_ATime,7,2) & StringMid($FN_ATime,5,2) & StringMid($FN_ATime,3,2) & StringMid($FN_ATime,1,2))
;ConsoleWrite("$FN_ATime = " & $FN_ATime & @crlf)
$FN_ATime_tmp = _WinTime_UTCFileTimeToLocalFileTime("0x" & $FN_ATime)
;ConsoleWrite("$FN_ATime_tmp = " & $FN_ATime_tmp & @crlf)
$FN_ATime = _WinTime_UTCFileTimeFormat(Dec($FN_ATime)-$tDelta,$DateTimeFormat,2)
$FN_ATime = $FN_ATime & ":" & _FillZero(StringRight($FN_ATime_tmp,4))
;ConsoleWrite("$FN_ATime = " & $FN_ATime & @crlf)
;
$FN_MTime = StringMid($MFTEntry,$FN_Offset+96,16)
;ConsoleWrite("$FN_MTime = " & $FN_MTime & @crlf)
$FN_MTime = StringMid($FN_MTime,15,2) & StringMid($FN_MTime,13,2) & StringMid($FN_MTime,11,2) & StringMid($FN_MTime,9,2) & StringMid($FN_MTime,7,2) & StringMid($FN_MTime,5,2) & StringMid($FN_MTime,3,2) & StringMid($FN_MTime,1,2)
;$FN_MTime = Dec(StringMid($FN_MTime,15,2) & StringMid($FN_MTime,13,2) & StringMid($FN_MTime,11,2) & StringMid($FN_MTime,9,2) & StringMid($FN_MTime,7,2) & StringMid($FN_MTime,5,2) & StringMid($FN_MTime,3,2) & StringMid($FN_MTime,1,2))
;ConsoleWrite("$FN_MTime = " & $FN_MTime & @crlf)
$FN_MTime_tmp = _WinTime_UTCFileTimeToLocalFileTime("0x" & $FN_MTime)
;ConsoleWrite("$FN_MTime_tmp = " & $FN_MTime_tmp & @crlf)
$FN_MTime = _WinTime_UTCFileTimeFormat(Dec($FN_MTime)-$tDelta,$DateTimeFormat,2)
$FN_MTime = $FN_MTime & ":" & _FillZero(StringRight($FN_MTime_tmp,4))
;ConsoleWrite("$FN_MTime = " & $FN_MTime & @crlf)
;
$FN_RTime = StringMid($MFTEntry,$FN_Offset+112,16)
;ConsoleWrite("$FN_RTime = " & $FN_RTime & @crlf)
$FN_RTime = StringMid($FN_RTime,15,2) & StringMid($FN_RTime,13,2) & StringMid($FN_RTime,11,2) & StringMid($FN_RTime,9,2) & StringMid($FN_RTime,7,2) & StringMid($FN_RTime,5,2) & StringMid($FN_RTime,3,2) & StringMid($FN_RTime,1,2)
;$FN_RTime = Dec(StringMid($FN_RTime,15,2) & StringMid($FN_RTime,13,2) & StringMid($FN_RTime,11,2) & StringMid($FN_RTime,9,2) & StringMid($FN_RTime,7,2) & StringMid($FN_RTime,5,2) & StringMid($FN_RTime,3,2) & StringMid($FN_RTime,1,2))
;ConsoleWrite("$FN_RTime = " & $FN_RTime & @crlf)
$FN_RTime_tmp = _WinTime_UTCFileTimeToLocalFileTime("0x" & $FN_RTime)
;ConsoleWrite("$FN_RTime_tmp = " & $FN_RTime_tmp & @crlf)
$FN_RTime = _WinTime_UTCFileTimeFormat(Dec($FN_RTime)-$tDelta,$DateTimeFormat,2)
$FN_RTime = $FN_RTime & ":" & _FillZero(StringRight($FN_RTime_tmp,4))
;ConsoleWrite("$FN_RTime = " & $FN_RTime & @crlf)
;
$FN_AllocSize = StringMid($MFTEntry,$FN_Offset+128,16)
$FN_AllocSize = Dec(StringMid($FN_AllocSize,15,2) & StringMid($FN_AllocSize,13,2) & StringMid($FN_AllocSize,11,2) & StringMid($FN_AllocSize,9,2) & StringMid($FN_AllocSize,7,2) & StringMid($FN_AllocSize,5,2) & StringMid($FN_AllocSize,3,2) & StringMid($FN_AllocSize,1,2))
;$FN_AllocSize = Dec($FN_AllocSize)
;ConsoleWrite("$FN_AllocSize = " & $FN_AllocSize & @crlf)
$FN_RealSize = StringMid($MFTEntry,$FN_Offset+144,16)
$FN_RealSize = Dec(StringMid($FN_RealSize,15,2) & StringMid($FN_RealSize,13,2) & StringMid($FN_RealSize,11,2) & StringMid($FN_RealSize,9,2) & StringMid($FN_RealSize,7,2) & StringMid($FN_RealSize,5,2) & StringMid($FN_RealSize,3,2) & StringMid($FN_RealSize,1,2))
;$FN_RealSize = Dec($FN_RealSize)
;ConsoleWrite("$FN_RealSize = " & $FN_RealSize & @crlf)
$FN_Flags = StringMid($MFTEntry,$FN_Offset+160,8)
;ConsoleWrite("$FN_Flags = " & $FN_Flags & @crlf)
$FN_Flags = StringMid($FN_Flags,7,2) & StringMid($FN_Flags,5,2) & StringMid($FN_Flags,3,2) & StringMid($FN_Flags,1,2)
;ConsoleWrite("$FN_Flags = " & $FN_Flags & @crlf)
$FN_Flags = _File_Permissions("0x" & $FN_Flags)
;ConsoleWrite("$FN_Flags = " & $FN_Flags & @crlf)
$FN_NameLength = StringMid($MFTEntry,$FN_Offset+176,2)
$FN_NameLength = Dec($FN_NameLength)
;ConsoleWrite("$FN_NameLength = " & $FN_NameLength & @crlf)
$FN_NameType = StringMid($MFTEntry,$FN_Offset+178,2)
Select
	Case $FN_NameType = '00'
		$FN_NameType = 'POSIX'
	Case $FN_NameType = '01'
		$FN_NameType = 'WIN32'
	Case $FN_NameType = '02'
		$FN_NameType = 'DOS'
	Case $FN_NameType = '03'
		$FN_NameType = 'DOS+WIN32'
	Case $FN_NameType <> '00' AND $FN_NameType <> '01' AND $FN_NameType <> '02' AND $FN_NameType <> '03'
		$FN_NameType = 'UNKNOWN'
EndSelect
;ConsoleWrite("$FN_NameType = " & $FN_NameType & @crlf)
$FN_NameSpace = $FN_NameLength-1 ;Not really
;ConsoleWrite("$FN_NameSpace = " & $FN_NameSpace & @crlf)
$FN_FileName = StringMid($MFTEntry,$FN_Offset+180,($FN_NameLength+$FN_NameSpace)*2)
;ConsoleWrite("$FN_FileName = " & $FN_FileName & @crlf)
$FN_FileName = _UnicodeHexToStr($FN_FileName)
;ConsoleWrite("$FN_FileName = " & $FN_FileName & @crlf)
If StringLen($FN_FileName) <> $FN_NameLength Then $INVALID_FILENAME = 1
If $MFTMode = 1 Then
	$FNArr[0][$FN_Number] = "FN Number " & $FN_Number
	$FNArr[13][$FN_Number] = $FN_ParentReferenceNo
	$FNArr[1][$FN_Number] = $FN_ParentSequenceNo
	$FNArr[2][$FN_Number] = $FN_CTime
	$FNArr[3][$FN_Number] = $FN_ATime
	$FNArr[4][$FN_Number] = $FN_MTime
	$FNArr[5][$FN_Number] = $FN_RTime
	$FNArr[6][$FN_Number] = $FN_AllocSize
	$FNArr[7][$FN_Number] = $FN_RealSize
	$FNArr[8][$FN_Number] = $FN_Flags
	$FNArr[9][$FN_Number] = $FN_NameLength
	$FNArr[10][$FN_Number] = $FN_NameType
	$FNArr[11][$FN_Number] = $FN_NameSpace
	$FNArr[12][$FN_Number] = $FN_FileName
	$FNArr[0][$FN_Number+1] = "Internal offset"
	$FNArr[13][$FN_Number+1] = $FN_Offset+48
	$FNArr[1][$FN_Number+1] = $FN_Offset+60
	$FNArr[2][$FN_Number+1] = $FN_Offset+64
	$FNArr[3][$FN_Number+1] = $FN_Offset+80
	$FNArr[4][$FN_Number+1] = $FN_Offset+96
	$FNArr[5][$FN_Number+1] = $FN_Offset+112
	$FNArr[6][$FN_Number+1] = $FN_Offset+128
	$FNArr[7][$FN_Number+1] = $FN_Offset+144
	$FNArr[8][$FN_Number+1] = $FN_Offset+160
	$FNArr[9][$FN_Number+1] = $FN_Offset+176
	$FNArr[10][$FN_Number+1] = $FN_Offset+178
	$FNArr[11][$FN_Number+1] = ""
	$FNArr[12][$FN_Number+1] = $FN_Offset+180
EndIf
EndIf
If $FN_Number = 2 Then
$FN_ParentReferenceNo_2 = StringMid($MFTEntry,$FN_Offset+48,12)
;ConsoleWrite("$FN_ParentReferenceNo_2 = " & $FN_ParentReferenceNo_2 & @crlf)
$FN_ParentReferenceNo_2 = Dec(StringMid($FN_ParentReferenceNo_2,11,2) & StringMid($FN_ParentReferenceNo_2,9,2) & StringMid($FN_ParentReferenceNo_2,7,2) & StringMid($FN_ParentReferenceNo_2,5,2) & StringMid($FN_ParentReferenceNo_2,3,2) & StringMid($FN_ParentReferenceNo_2,1,2))
;$FN_ParentReferenceNo_2 = Dec($FN_ParentReferenceNo_2)
;ConsoleWrite("$FN_ParentReferenceNo_2 = " & $FN_ParentReferenceNo_2 & @crlf)
$FN_ParentSequenceNo_2 = StringMid($MFTEntry,$FN_Offset+60,4)
;ConsoleWrite("$FN_ParentSequenceNo_2 = " & $FN_ParentSequenceNo_2 & @crlf)
$FN_ParentSequenceNo_2 = Dec(StringMid($FN_ParentSequenceNo_2,3,2) & StringMid($FN_ParentSequenceNo_2,1,2))
;$FN_ParentSequenceNo_2 = Dec($FN_ParentSequenceNo_2)
;ConsoleWrite("$FN_ParentSequenceNo_2 = " & $FN_ParentSequenceNo_2 & @crlf)
$FN_CTime_2 = StringMid($MFTEntry,$FN_Offset+64,16)
$FN_CTime_2 = StringMid($FN_CTime_2,15,2) & StringMid($FN_CTime_2,13,2) & StringMid($FN_CTime_2,11,2) & StringMid($FN_CTime_2,9,2) & StringMid($FN_CTime_2,7,2) & StringMid($FN_CTime_2,5,2) & StringMid($FN_CTime_2,3,2) & StringMid($FN_CTime_2,1,2)
;$FN_CTime_2 = Dec(StringMid($FN_CTime_2,15,2) & StringMid($FN_CTime_2,13,2) & StringMid($FN_CTime_2,11,2) & StringMid($FN_CTime_2,9,2) & StringMid($FN_CTime_2,7,2) & StringMid($FN_CTime_2,5,2) & StringMid($FN_CTime_2,3,2) & StringMid($FN_CTime_2,1,2))
$FN_CTime_2_tmp = _WinTime_UTCFileTimeToLocalFileTime("0x" & $FN_CTime_2)
$FN_CTime_2 = _WinTime_UTCFileTimeFormat(Dec($FN_CTime_2)-$tDelta,$DateTimeFormat,2)
$FN_CTime_2 = $FN_CTime_2 & ":" & _FillZero(StringRight($FN_CTime_2_tmp,4))
;
$FN_ATime_2 = StringMid($MFTEntry,$FN_Offset+80,16)
$FN_ATime_2 = StringMid($FN_ATime_2,15,2) & StringMid($FN_ATime_2,13,2) & StringMid($FN_ATime_2,11,2) & StringMid($FN_ATime_2,9,2) & StringMid($FN_ATime_2,7,2) & StringMid($FN_ATime_2,5,2) & StringMid($FN_ATime_2,3,2) & StringMid($FN_ATime_2,1,2)
;$FN_ATime_2 = Dec(StringMid($FN_ATime_2,15,2) & StringMid($FN_ATime_2,13,2) & StringMid($FN_ATime_2,11,2) & StringMid($FN_ATime_2,9,2) & StringMid($FN_ATime_2,7,2) & StringMid($FN_ATime_2,5,2) & StringMid($FN_ATime_2,3,2) & StringMid($FN_ATime_2,1,2))
$FN_ATime_2_tmp = _WinTime_UTCFileTimeToLocalFileTime("0x" & $FN_ATime_2)
$FN_ATime_2 = _WinTime_UTCFileTimeFormat(Dec($FN_ATime_2)-$tDelta,$DateTimeFormat,2)
$FN_ATime_2 = $FN_ATime_2 & ":" & _FillZero(StringRight($FN_ATime_2_tmp,4))
;
$FN_MTime_2 = StringMid($MFTEntry,$FN_Offset+96,16)
$FN_MTime_2 = StringMid($FN_MTime_2,15,2) & StringMid($FN_MTime_2,13,2) & StringMid($FN_MTime_2,11,2) & StringMid($FN_MTime_2,9,2) & StringMid($FN_MTime_2,7,2) & StringMid($FN_MTime_2,5,2) & StringMid($FN_MTime_2,3,2) & StringMid($FN_MTime_2,1,2)
;$FN_MTime_2 = Dec(StringMid($FN_MTime_2,15,2) & StringMid($FN_MTime_2,13,2) & StringMid($FN_MTime_2,11,2) & StringMid($FN_MTime_2,9,2) & StringMid($FN_MTime_2,7,2) & StringMid($FN_MTime_2,5,2) & StringMid($FN_MTime_2,3,2) & StringMid($FN_MTime_2,1,2))
$FN_MTime_2_tmp = _WinTime_UTCFileTimeToLocalFileTime("0x" & $FN_MTime_2)
$FN_MTime_2 = _WinTime_UTCFileTimeFormat(Dec($FN_MTime_2)-$tDelta,$DateTimeFormat,2)
$FN_MTime_2 = $FN_MTime_2 & ":" & _FillZero(StringRight($FN_MTime_2_tmp,4))
;
$FN_RTime_2 = StringMid($MFTEntry,$FN_Offset+112,16)
$FN_RTime_2 = StringMid($FN_RTime_2,15,2) & StringMid($FN_RTime_2,13,2) & StringMid($FN_RTime_2,11,2) & StringMid($FN_RTime_2,9,2) & StringMid($FN_RTime_2,7,2) & StringMid($FN_RTime_2,5,2) & StringMid($FN_RTime_2,3,2) & StringMid($FN_RTime_2,1,2)
;$FN_RTime_2 = Dec(StringMid($FN_RTime_2,15,2) & StringMid($FN_RTime_2,13,2) & StringMid($FN_RTime_2,11,2) & StringMid($FN_RTime_2,9,2) & StringMid($FN_RTime_2,7,2) & StringMid($FN_RTime_2,5,2) & StringMid($FN_RTime_2,3,2) & StringMid($FN_RTime_2,1,2))
$FN_RTime_2_tmp = _WinTime_UTCFileTimeToLocalFileTime("0x" & $FN_RTime_2)
$FN_RTime_2 = _WinTime_UTCFileTimeFormat(Dec($FN_RTime_2)-$tDelta,$DateTimeFormat,2)
$FN_RTime_2 = $FN_RTime_2 & ":" & _FillZero(StringRight($FN_RTime_2_tmp,4))
;
$FN_AllocSize_2 = StringMid($MFTEntry,$FN_Offset+128,16)
$FN_AllocSize_2 = Dec(StringMid($FN_AllocSize_2,15,2) & StringMid($FN_AllocSize_2,13,2) & StringMid($FN_AllocSize_2,11,2) & StringMid($FN_AllocSize_2,9,2) & StringMid($FN_AllocSize_2,7,2) & StringMid($FN_AllocSize_2,5,2) & StringMid($FN_AllocSize_2,3,2) & StringMid($FN_AllocSize_2,1,2))
;$FN_AllocSize_2 = Dec($FN_AllocSize_2)
;ConsoleWrite("$FN_AllocSize_2 = " & $FN_AllocSize_2 & @crlf)
$FN_RealSize_2 = StringMid($MFTEntry,$FN_Offset+144,16)
$FN_RealSize_2 = Dec(StringMid($FN_RealSize_2,15,2) & StringMid($FN_RealSize_2,13,2) & StringMid($FN_RealSize_2,11,2) & StringMid($FN_RealSize_2,9,2) & StringMid($FN_RealSize_2,7,2) & StringMid($FN_RealSize_2,5,2) & StringMid($FN_RealSize_2,3,2) & StringMid($FN_RealSize_2,1,2))
;$FN_RealSize_2 = Dec($FN_RealSize_2)
;ConsoleWrite("$FN_RealSize_2 = " & $FN_RealSize_2 & @crlf)
$FN_Flags_2 = StringMid($MFTEntry,$FN_Offset+160,8)
;ConsoleWrite("$FN_Flags_2 = " & $FN_Flags_2 & @crlf)
$FN_Flags_2 = _File_Permissions("0x" & $FN_Flags_2)
;ConsoleWrite("$FN_Flags_2 = " & $FN_Flags_2 & @crlf)
$FN_NameLength_2 = StringMid($MFTEntry,$FN_Offset+176,2)
$FN_NameLength_2 = Dec($FN_NameLength_2)
;ConsoleWrite("$FN_NameLength_2 = " & $FN_NameLength_2 & @crlf)
$FN_NameType_2 = StringMid($MFTEntry,$FN_Offset+178,2)
Select
	Case $FN_NameType_2 = '01'
		$FN_NameType_2 = 'UNICODE'
	Case $FN_NameType_2 = '02'
		$FN_NameType_2 = 'DOS'
	Case $FN_NameType_2 = '03'
		$FN_NameType_2 = 'POSIX'
	Case $FN_NameType_2 <> '01' AND $FN_NameType_2 <> '02' AND $FN_NameType_2 <> '03'
		$FN_NameType_2 = 'UNKNOWN'
EndSelect
$FN_NameSpace_2 = $FN_NameLength_2-1 ;Not really
;ConsoleWrite("$FN_NameSpace_2 = " & $FN_NameSpace_2 & @crlf)
$FN_FileName_2 = StringMid($MFTEntry,$FN_Offset+180,($FN_NameLength_2+$FN_NameSpace_2)*2)
;ConsoleWrite("$FN_FileName_2 = " & $FN_FileName_2 & @crlf)
$FN_FileName_2 = _UnicodeHexToStr($FN_FileName_2)
;ConsoleWrite("$FN_FileName_2 = " & $FN_FileName_2 & @crlf)
If StringLen($FN_FileName_2) <> $FN_NameLength_2 Then $INVALID_FILENAME_2 = 1
If $MFTMode = 1 Then
	$FNArr[0][$FN_Number+1] = "FN Number " & $FN_Number
	$FNArr[13][$FN_Number+1] = $FN_ParentReferenceNo_2
	$FNArr[1][$FN_Number+1] = $FN_ParentSequenceNo_2
	$FNArr[2][$FN_Number+1] = $FN_CTime_2
	$FNArr[3][$FN_Number+1] = $FN_ATime_2
	$FNArr[4][$FN_Number+1] = $FN_MTime_2
	$FNArr[5][$FN_Number+1] = $FN_RTime_2
	$FNArr[6][$FN_Number+1] = $FN_AllocSize_2
	$FNArr[7][$FN_Number+1] = $FN_RealSize_2
	$FNArr[8][$FN_Number+1] = $FN_Flags_2
	$FNArr[9][$FN_Number+1] = $FN_NameLength_2
	$FNArr[10][$FN_Number+1] = $FN_NameType_2
	$FNArr[11][$FN_Number+1] = $FN_NameSpace_2
	$FNArr[12][$FN_Number+1] = $FN_FileName_2
;#cs
	$FNArr[0][$FN_Number+2] = "Internal offset"
	$FNArr[13][$FN_Number+2] = $FN_Offset+48
	$FNArr[1][$FN_Number+2] = $FN_Offset+60
	$FNArr[2][$FN_Number+2] = $FN_Offset+64
	$FNArr[3][$FN_Number+2] = $FN_Offset+80
	$FNArr[4][$FN_Number+2] = $FN_Offset+96
	$FNArr[5][$FN_Number+2] = $FN_Offset+112
	$FNArr[6][$FN_Number+2] = $FN_Offset+128
	$FNArr[7][$FN_Number+2] = $FN_Offset+144
	$FNArr[8][$FN_Number+2] = $FN_Offset+160
	$FNArr[9][$FN_Number+2] = $FN_Offset+176
	$FNArr[10][$FN_Number+2] = $FN_Offset+178
	$FNArr[11][$FN_Number+2] = ""
	$FNArr[12][$FN_Number+2] = $FN_Offset+180
;#ce
EndIf
EndIf
If $FN_Number = 3 Then
$FN_ParentReferenceNo_3 = StringMid($MFTEntry,$FN_Offset+48,12)
$FN_ParentReferenceNo_3 = StringMid($FN_ParentReferenceNo_3,11,2) & StringMid($FN_ParentReferenceNo_3,9,2) & StringMid($FN_ParentReferenceNo_3,7,2) & StringMid($FN_ParentReferenceNo_3,5,2) & StringMid($FN_ParentReferenceNo_3,3,2) & StringMid($FN_ParentReferenceNo_3,1,2)
$FN_ParentReferenceNo_3 = Dec($FN_ParentReferenceNo_3)
$FN_ParentSequenceNo_3 = StringMid($MFTEntry,$FN_Offset+60,4)
$FN_ParentSequenceNo_3 = StringMid($FN_ParentSequenceNo_3,3,2) & StringMid($FN_ParentSequenceNo_3,1,2)
$FN_ParentSequenceNo_3 = Dec($FN_ParentSequenceNo_3)
$FN_CTime_3 = StringMid($MFTEntry,$FN_Offset+64,16)
$FN_CTime_3 = StringMid($FN_CTime_3,15,2) & StringMid($FN_CTime_3,13,2) & StringMid($FN_CTime_3,11,2) & StringMid($FN_CTime_3,9,2) & StringMid($FN_CTime_3,7,2) & StringMid($FN_CTime_3,5,2) & StringMid($FN_CTime_3,3,2) & StringMid($FN_CTime_3,1,2)
$FN_CTime_3 = Dec($FN_CTime_3)
$FN_CTime_3 = _WinTime_UTCFileTimeFormat($FN_CTime_3-$tDelta,$DateTimeFormat,2)
$FN_ATime_3 = StringMid($MFTEntry,$FN_Offset+80,16)
$FN_ATime_3 = StringMid($FN_ATime_3,15,2) & StringMid($FN_ATime_3,13,2) & StringMid($FN_ATime_3,11,2) & StringMid($FN_ATime_3,9,2) & StringMid($FN_ATime_3,7,2) & StringMid($FN_ATime_3,5,2) & StringMid($FN_ATime_3,3,2) & StringMid($FN_ATime_3,1,2)
$FN_ATime_3 = Dec($FN_ATime_3)
$FN_ATime_3 = _WinTime_UTCFileTimeFormat($FN_ATime_3-$tDelta,$DateTimeFormat,2)
$FN_MTime_3 = StringMid($MFTEntry,$FN_Offset+96,16)
$FN_MTime_3 = StringMid($FN_MTime_3,15,2) & StringMid($FN_MTime_3,13,2) & StringMid($FN_MTime_3,11,2) & StringMid($FN_MTime_3,9,2) & StringMid($FN_MTime_3,7,2) & StringMid($FN_MTime_3,5,2) & StringMid($FN_MTime_3,3,2) & StringMid($FN_MTime_3,1,2)
$FN_MTime_3 = Dec($FN_MTime_3)
$FN_MTime_3 = _WinTime_UTCFileTimeFormat($FN_MTime_3-$tDelta,$DateTimeFormat,2)
$FN_RTime_3 = StringMid($MFTEntry,$FN_Offset+112,16)
$FN_RTime_3 = StringMid($FN_RTime_3,15,2) & StringMid($FN_RTime_3,13,2) & StringMid($FN_RTime_3,11,2) & StringMid($FN_RTime_3,9,2) & StringMid($FN_RTime_3,7,2) & StringMid($FN_RTime_3,5,2) & StringMid($FN_RTime_3,3,2) & StringMid($FN_RTime_3,1,2)
$FN_RTime_3 = Dec($FN_RTime_3)
$FN_RTime_3 = _WinTime_UTCFileTimeFormat($FN_RTime_3-$tDelta,$DateTimeFormat,2)
$FN_AllocSize_3 = StringMid($MFTEntry,$FN_Offset+128,16)
$FN_AllocSize_3 = StringMid($FN_AllocSize_3,15,2) & StringMid($FN_AllocSize_3,13,2) & StringMid($FN_AllocSize_3,11,2) & StringMid($FN_AllocSize_3,9,2) & StringMid($FN_AllocSize_3,7,2) & StringMid($FN_AllocSize_3,5,2) & StringMid($FN_AllocSize_3,3,2) & StringMid($FN_AllocSize_3,1,2)
$FN_AllocSize_3 = Dec($FN_AllocSize_3)
$FN_RealSize_3 = StringMid($MFTEntry,$FN_Offset+144,16)
$FN_RealSize_3 = StringMid($FN_RealSize_3,15,2) & StringMid($FN_RealSize_3,13,2) & StringMid($FN_RealSize_3,11,2) & StringMid($FN_RealSize_3,9,2) & StringMid($FN_RealSize_3,7,2) & StringMid($FN_RealSize_3,5,2) & StringMid($FN_RealSize_3,3,2) & StringMid($FN_RealSize_3,1,2)
$FN_RealSize_3 = Dec($FN_RealSize_3)
$FN_Flags_3 = StringMid($MFTEntry,$FN_Offset+160,8)
$FN_Flags_3 = _File_Permissions("0x" & $FN_Flags_3)
$FN_NameLength_3 = Dec(StringMid($MFTEntry,$FN_Offset+176,2))
;$FN_NameLength_3 = Dec($FN_NameLength_3)
$FN_NameType_3 = StringMid($MFTEntry,$FN_Offset+178,2)
Select
	Case $FN_NameType_3 = '01'
		$FN_NameType_3 = 'UNICODE'
	Case $FN_NameType_3 = '02'
		$FN_NameType_3 = 'DOS'
	Case $FN_NameType_3 = '03'
		$FN_NameType_3 = 'POSIX'
	Case $FN_NameType_3 <> '01' AND $FN_NameType_3 <> '02' AND $FN_NameType_3 <> '03'
		$FN_NameType_3 = 'UNKNOWN'
EndSelect
$FN_NameSpace_3 = $FN_NameLength_3-1 ;Not really
$FN_FileName_3 = StringMid($MFTEntry,$FN_Offset+180,($FN_NameLength_3+$FN_NameSpace_3)*2)
$FN_FileName_3 = _UnicodeHexToStr($FN_FileName_3)
If StringLen($FN_FileName_3) <> $FN_NameLength_3 Then $INVALID_FILENAME_3 = 1
If $MFTMode = 1 Then
	$FNArr[0][$FN_Number+2] = "FN Number " & $FN_Number
	$FNArr[13][$FN_Number+2] = $FN_ParentReferenceNo_3
	$FNArr[1][$FN_Number+2] = $FN_ParentSequenceNo_3
	$FNArr[2][$FN_Number+2] = $FN_CTime_3
	$FNArr[3][$FN_Number+2] = $FN_ATime_3
	$FNArr[4][$FN_Number+2] = $FN_MTime_3
	$FNArr[5][$FN_Number+2] = $FN_RTime_3
	$FNArr[6][$FN_Number+2] = $FN_AllocSize_3
	$FNArr[7][$FN_Number+2] = $FN_RealSize_3
	$FNArr[8][$FN_Number+2] = $FN_Flags_3
	$FNArr[9][$FN_Number+2] = $FN_NameLength_3
	$FNArr[10][$FN_Number+2] = $FN_NameType_3
	$FNArr[11][$FN_Number+2] = $FN_NameSpace_3
	$FNArr[12][$FN_Number+2] = $FN_FileName_3
	$FNArr[0][$FN_Number+3] = "Internal offset"
	$FNArr[13][$FN_Number+3] = $FN_Offset+48
	$FNArr[1][$FN_Number+3] = $FN_Offset+60
	$FNArr[2][$FN_Number+3] = $FN_Offset+64
	$FNArr[3][$FN_Number+3] = $FN_Offset+80
	$FNArr[4][$FN_Number+3] = $FN_Offset+96
	$FNArr[5][$FN_Number+3] = $FN_Offset+112
	$FNArr[6][$FN_Number+3] = $FN_Offset+128
	$FNArr[7][$FN_Number+3] = $FN_Offset+144
	$FNArr[8][$FN_Number+3] = $FN_Offset+160
	$FNArr[9][$FN_Number+3] = $FN_Offset+176
	$FNArr[10][$FN_Number+3] = $FN_Offset+178
	$FNArr[11][$FN_Number+3] = ""
	$FNArr[12][$FN_Number+3] = $FN_Offset+180
EndIf
EndIf
If $FN_Number = 4 Then
$FN_ParentReferenceNo_4 = StringMid($MFTEntry,$FN_Offset+48,12)
$FN_ParentReferenceNo_4 = StringMid($FN_ParentReferenceNo_4,11,2) & StringMid($FN_ParentReferenceNo_4,9,2) & StringMid($FN_ParentReferenceNo_4,7,2) & StringMid($FN_ParentReferenceNo_4,5,2) & StringMid($FN_ParentReferenceNo_4,3,2) & StringMid($FN_ParentReferenceNo_4,1,2)
$FN_ParentReferenceNo_4 = Dec($FN_ParentReferenceNo_4)
$FN_ParentSequenceNo_4 = StringMid($MFTEntry,$FN_Offset+60,4)
$FN_ParentSequenceNo_4 = Dec(StringMid($FN_ParentSequenceNo_4,3,2) & StringMid($FN_ParentSequenceNo_4,1,2))
;$FN_ParentSequenceNo_4 = Dec($FN_ParentSequenceNo_4)
$FN_CTime_4 = StringMid($MFTEntry,$FN_Offset+64,16)
$FN_CTime_4 = StringMid($FN_CTime_4,15,2) & StringMid($FN_CTime_4,13,2) & StringMid($FN_CTime_4,11,2) & StringMid($FN_CTime_4,9,2) & StringMid($FN_CTime_4,7,2) & StringMid($FN_CTime_4,5,2) & StringMid($FN_CTime_4,3,2) & StringMid($FN_CTime_4,1,2)
$FN_CTime_4 = Dec($FN_CTime_4)
$FN_CTime_4 = _WinTime_UTCFileTimeFormat($FN_CTime_4-$tDelta,$DateTimeFormat,2)
$FN_ATime_4 = StringMid($MFTEntry,$FN_Offset+80,16)
$FN_ATime_4 = StringMid($FN_ATime_4,15,2) & StringMid($FN_ATime_4,13,2) & StringMid($FN_ATime_4,11,2) & StringMid($FN_ATime_4,9,2) & StringMid($FN_ATime_4,7,2) & StringMid($FN_ATime_4,5,2) & StringMid($FN_ATime_4,3,2) & StringMid($FN_ATime_4,1,2)
$FN_ATime_4 = Dec($FN_ATime_4)
$FN_ATime_4 = _WinTime_UTCFileTimeFormat($FN_ATime_4-$tDelta,$DateTimeFormat,2)
$FN_MTime_4 = StringMid($MFTEntry,$FN_Offset+96,16)
$FN_MTime_4 = StringMid($FN_MTime_4,15,2) & StringMid($FN_MTime_4,13,2) & StringMid($FN_MTime_4,11,2) & StringMid($FN_MTime_4,9,2) & StringMid($FN_MTime_4,7,2) & StringMid($FN_MTime_4,5,2) & StringMid($FN_MTime_4,3,2) & StringMid($FN_MTime_4,1,2)
$FN_MTime_4 = Dec($FN_MTime_4)
$FN_MTime_4 = _WinTime_UTCFileTimeFormat($FN_MTime_4-$tDelta,$DateTimeFormat,2)
$FN_RTime_4 = StringMid($MFTEntry,$FN_Offset+112,16)
$FN_RTime_4 = StringMid($FN_RTime_4,15,2) & StringMid($FN_RTime_4,13,2) & StringMid($FN_RTime_4,11,2) & StringMid($FN_RTime_4,9,2) & StringMid($FN_RTime_4,7,2) & StringMid($FN_RTime_4,5,2) & StringMid($FN_RTime_4,3,2) & StringMid($FN_RTime_4,1,2)
$FN_RTime_4 = Dec($FN_RTime_4)
$FN_RTime_4 = _WinTime_UTCFileTimeFormat($FN_RTime_4-$tDelta,$DateTimeFormat,2)
$FN_AllocSize_4 = StringMid($MFTEntry,$FN_Offset+128,16)
$FN_AllocSize_4 = StringMid($FN_AllocSize_4,15,2) & StringMid($FN_AllocSize_4,13,2) & StringMid($FN_AllocSize_4,11,2) & StringMid($FN_AllocSize_4,9,2) & StringMid($FN_AllocSize_4,7,2) & StringMid($FN_AllocSize_4,5,2) & StringMid($FN_AllocSize_4,3,2) & StringMid($FN_AllocSize_4,1,2)
$FN_AllocSize_4 = Dec($FN_AllocSize_4)
$FN_RealSize_4 = StringMid($MFTEntry,$FN_Offset+144,16)
$FN_RealSize_4 = StringMid($FN_RealSize_4,15,2) & StringMid($FN_RealSize_4,13,2) & StringMid($FN_RealSize_4,11,2) & StringMid($FN_RealSize_4,9,2) & StringMid($FN_RealSize_4,7,2) & StringMid($FN_RealSize_4,5,2) & StringMid($FN_RealSize_4,3,2) & StringMid($FN_RealSize_4,1,2)
$FN_RealSize_4 = Dec($FN_RealSize_4)
$FN_Flags_4 = StringMid($MFTEntry,$FN_Offset+160,8)
$FN_Flags_4 = _File_Permissions("0x" & $FN_Flags_4)
$FN_NameLength_4 = Dec(StringMid($MFTEntry,$FN_Offset+176,2))
;$FN_NameLength_4 = Dec($FN_NameLength_4)
$FN_NameType_4 = StringMid($MFTEntry,$FN_Offset+178,2)
Select
	Case $FN_NameType_4 = '01'
		$FN_NameType_4 = 'UNICODE'
	Case $FN_NameType_4 = '02'
		$FN_NameType_4 = 'DOS'
	Case $FN_NameType_4 = '03'
		$FN_NameType_4 = 'POSIX'
	Case $FN_NameType_4 <> '01' AND $FN_NameType_4 <> '02' AND $FN_NameType_4 <> '03'
		$FN_NameType_4 = 'UNKNOWN'
EndSelect
$FN_NameSpace_4 = $FN_NameLength_4-1 ;Not really
$FN_FileName_4 = StringMid($MFTEntry,$FN_Offset+180,($FN_NameLength_4+$FN_NameSpace_4)*2)
$FN_FileName_4 = _UnicodeHexToStr($FN_FileName_4)
If $MFTMode = 1 Then
	$FNArr[0][$FN_Number+3] = "FN Number " & $FN_Number
	$FNArr[13][$FN_Number+3] = $FN_ParentReferenceNo_4
	$FNArr[1][$FN_Number+3] = $FN_ParentSequenceNo_4
	$FNArr[2][$FN_Number+3] = $FN_CTime_4
	$FNArr[3][$FN_Number+3] = $FN_ATime_4
	$FNArr[4][$FN_Number+3] = $FN_MTime_4
	$FNArr[5][$FN_Number+3] = $FN_RTime_4
	$FNArr[6][$FN_Number+3] = $FN_AllocSize_4
	$FNArr[7][$FN_Number+3] = $FN_RealSize_4
	$FNArr[8][$FN_Number+3] = $FN_Flags_4
	$FNArr[9][$FN_Number+3] = $FN_NameLength_4
	$FNArr[10][$FN_Number+3] = $FN_NameType_4
	$FNArr[11][$FN_Number+3] = $FN_NameSpace_4
	$FNArr[12][$FN_Number+3] = $FN_FileName_4
	$FNArr[0][$FN_Number+4] = "Internal offset"
	$FNArr[13][$FN_Number+4] = $FN_Offset+48
	$FNArr[1][$FN_Number+4] = $FN_Offset+60
	$FNArr[2][$FN_Number+4] = $FN_Offset+64
	$FNArr[3][$FN_Number+4] = $FN_Offset+80
	$FNArr[4][$FN_Number+4] = $FN_Offset+96
	$FNArr[5][$FN_Number+4] = $FN_Offset+112
	$FNArr[6][$FN_Number+4] = $FN_Offset+128
	$FNArr[7][$FN_Number+4] = $FN_Offset+144
	$FNArr[8][$FN_Number+4] = $FN_Offset+160
	$FNArr[9][$FN_Number+4] = $FN_Offset+176
	$FNArr[10][$FN_Number+4] = $FN_Offset+178
	$FNArr[11][$FN_Number+4] = ""
	$FNArr[12][$FN_Number+4] = $FN_Offset+180
EndIf
EndIf
Return
EndFunc

Func _Get_ObjectID($MFTEntry,$OBJECTID_Offset,$OBJECTID_Size)
$GUID_ObjectID = StringMid($MFTEntry,$OBJECTID_Offset+48,32)
;ConsoleWrite("$GUID_ObjectID = " & $GUID_ObjectID & @crlf)
$GUID_ObjectID = StringMid($GUID_ObjectID,1,8) & "-" & StringMid($GUID_ObjectID,9,4) & "-" & StringMid($GUID_ObjectID,13,4) & "-" & StringMid($GUID_ObjectID,17,4) & "-" & StringMid($GUID_ObjectID,21,12)
If $OBJECTID_Size - 24 = 32 Then
	$GUID_BirthVolumeID = StringMid($MFTEntry,$OBJECTID_Offset+80,32)
;	ConsoleWrite("$GUID_BirthVolumeID = " & $GUID_BirthVolumeID & @crlf)
	$GUID_BirthVolumeID = StringMid($GUID_BirthVolumeID,1,8) & "-" & StringMid($GUID_BirthVolumeID,9,4) & "-" & StringMid($GUID_BirthVolumeID,13,4) & "-" & StringMid($GUID_BirthVolumeID,17,4) & "-" & StringMid($GUID_BirthVolumeID,21,12)
	$GUID_BirthObjectID = "NOT PRESENT"
	$GUID_BirthDomainID = "NOT PRESENT"
Return
EndIf
If $OBJECTID_Size - 24 = 48 Then
	$GUID_BirthVolumeID = StringMid($MFTEntry,$OBJECTID_Offset+80,32)
;	ConsoleWrite("$GUID_BirthVolumeID = " & $GUID_BirthVolumeID & @crlf)
	$GUID_BirthVolumeID = StringMid($GUID_BirthVolumeID,1,8) & "-" & StringMid($GUID_BirthVolumeID,9,4) & "-" & StringMid($GUID_BirthVolumeID,13,4) & "-" & StringMid($GUID_BirthVolumeID,17,4) & "-" & StringMid($GUID_BirthVolumeID,21,12)
	$GUID_BirthObjectID = StringMid($MFTEntry,$OBJECTID_Offset+112,32)
;	ConsoleWrite("$GUID_BirthObjectID = " & $GUID_BirthObjectID & @crlf)
	$GUID_BirthObjectID = StringMid($GUID_BirthObjectID,1,8) & "-" & StringMid($GUID_BirthObjectID,9,4) & "-" & StringMid($GUID_BirthObjectID,13,4) & "-" & StringMid($GUID_BirthObjectID,17,4) & "-" & StringMid($GUID_BirthObjectID,21,12)
	$GUID_BirthDomainID = "NOT PRESENT"
	Return
EndIf
If $OBJECTID_Size - 24 = 64 Then
	$GUID_BirthVolumeID = StringMid($MFTEntry,$OBJECTID_Offset+80,32)
;	ConsoleWrite("$GUID_BirthVolumeID = " & $GUID_BirthVolumeID & @crlf)
	$GUID_BirthVolumeID = StringMid($GUID_BirthVolumeID,1,8) & "-" & StringMid($GUID_BirthVolumeID,9,4) & "-" & StringMid($GUID_BirthVolumeID,13,4) & "-" & StringMid($GUID_BirthVolumeID,17,4) & "-" & StringMid($GUID_BirthVolumeID,21,12)
	$GUID_BirthObjectID = StringMid($MFTEntry,$OBJECTID_Offset+112,32)
;	ConsoleWrite("$GUID_BirthObjectID = " & $GUID_BirthObjectID & @crlf)
	$GUID_BirthObjectID = StringMid($GUID_BirthObjectID,1,8) & "-" & StringMid($GUID_BirthObjectID,9,4) & "-" & StringMid($GUID_BirthObjectID,13,4) & "-" & StringMid($GUID_BirthObjectID,17,4) & "-" & StringMid($GUID_BirthObjectID,21,12)
	$GUID_BirthDomainID = StringMid($MFTEntry,$OBJECTID_Offset+144,32)
;	ConsoleWrite("$GUID_BirthDomainID = " & $GUID_BirthDomainID & @crlf)
	$GUID_BirthDomainID = StringMid($GUID_BirthDomainID,1,8) & "-" & StringMid($GUID_BirthDomainID,9,4) & "-" & StringMid($GUID_BirthDomainID,13,4) & "-" & StringMid($GUID_BirthDomainID,17,4) & "-" & StringMid($GUID_BirthDomainID,21,12)
	Return
EndIf
$GUID_BirthVolumeID = "NOT PRESENT"
$GUID_BirthObjectID = "NOT PRESENT"
$GUID_BirthDomainID = "NOT PRESENT"
Return
EndFunc

Func _Get_SecurityDescriptor()
ConsoleWrite("Get_SecurityDescriptor Function not implemented yet." & @CRLF)
Return
EndFunc

Func _Get_VolumeName($MFTEntry,$VOLUME_NAME_Offset,$VOLUME_NAME_Size)
If $VOLUME_NAME_Size - 24 > 0 Then
	$VOLUME_NAME_NAME = StringMid($MFTEntry,$VOLUME_NAME_Offset+48,($VOLUME_NAME_Size-24)*2)
	$VOLUME_NAME_NAME = _UnicodeHexToStr($VOLUME_NAME_NAME)
;	$VOLUME_NAME_NAME = _HexToString($VOLUME_NAME_NAME)
;	ConsoleWrite("$VOLUME_NAME_NAME = " & $VOLUME_NAME_NAME & @crlf)
	Return
EndIf
$VOLUME_NAME_NAME = "EMPTY"
Return
EndFunc

Func _Get_VolumeInformation($MFTEntry,$VOLUME_INFO_Offset,$VOLUME_INFO_Size)
$VOL_INFO_NTFS_VERSION = Dec(StringMid($MFTEntry,$VOLUME_INFO_Offset+64,2)) & "," & Dec(StringMid($MFTEntry,$VOLUME_INFO_Offset+66,2))
;ConsoleWrite("$VOL_INFO_NTFS_VERSION = " & $VOL_INFO_NTFS_VERSION & @crlf)
$VOL_INFO_FLAGS = StringMid($MFTEntry,$VOLUME_INFO_Offset+68,4)
$VOL_INFO_FLAGS = StringMid($VOL_INFO_FLAGS,3,2) & StringMid($VOL_INFO_FLAGS,1,2)
$VOL_INFO_FLAGS = _VolInfoFlag("0x" & $VOL_INFO_FLAGS)
;ConsoleWrite("$VOL_INFO_FLAGS = " & $VOL_INFO_FLAGS & @crlf)
Return
EndFunc

Func _VolInfoFlag($VIFinput)
Local $VIFoutput = ""
If BitAND($VIFinput,0x0001) Then $VIFoutput &= 'Dirty+'
If BitAND($VIFinput,0x0002) Then $VIFoutput &= 'Resize_LogFile+'
If BitAND($VIFinput,0x0004) Then $VIFoutput &= 'Upgrade_On_Mount+'
If BitAND($VIFinput,0x0008) Then $VIFoutput &= 'Mounted_On_NT4+'
If BitAND($VIFinput,0x0010) Then $VIFoutput &= 'Deleted_USN_Underway+'
If BitAND($VIFinput,0x0020) Then $VIFoutput &= 'Repair_ObjectIDs+'
If BitAND($VIFinput,0x8000) Then $VIFoutput &= 'Modified_By_CHKDSK+'
;$FRFoutput = StringMid($FRFoutput,1,StringLen($FRFoutput)-1)
$VIFoutput = StringTrimRight($VIFoutput,1)
;ConsoleWrite("$FRFoutput = " & $FRFoutput & @crlf)
Return $VIFoutput
EndFunc

Func _File_Permissions($FPinput)
Local $FPoutput = ""
If BitAND($FPinput,0x0001) Then $FPoutput &= 'read_only+'
If BitAND($FPinput,0x0002) Then $FPoutput &= 'hidden+'
If BitAND($FPinput,0x0004) Then $FPoutput &= 'system+'
If BitAND($FPinput,0x0020) Then $FPoutput &= 'archive+'
If BitAND($FPinput,0x0040) Then $FPoutput &= 'device+'
If BitAND($FPinput,0x0080) Then $FPoutput &= 'normal+'
If BitAND($FPinput,0x0100) Then $FPoutput &= 'temporary+'
If BitAND($FPinput,0x0200) Then $FPoutput &= 'sparse_file+'
If BitAND($FPinput,0x0400) Then $FPoutput &= 'reparse_point+'
If BitAND($FPinput,0x0800) Then $FPoutput &= 'compressed+'
If BitAND($FPinput,0x1000) Then $FPoutput &= 'offline+'
If BitAND($FPinput,0x2000) Then $FPoutput &= 'not_indexed+'
If BitAND($FPinput,0x4000) Then $FPoutput &= 'encrypted+'
If BitAND($FPinput,0x10000000) Then $FPoutput &= 'directory+'
If BitAND($FPinput,0x20000000) Then $FPoutput &= 'index_view+'
;$FPoutput = StringMid($FPoutput,1,StringLen($FPoutput)-1)
$FPoutput = StringTrimRight($FPoutput,1)
;ConsoleWrite("$FPoutput = " & $FPoutput & @crlf)
Return $FPoutput
EndFunc

Func _AttribHeaderFlags($AHinput)
Local $AHoutput = ""
If BitAND($AHinput,0x0001) Then $AHoutput &= 'COMPRESSED+'
If BitAND($AHinput,0x4000) Then $AHoutput &= 'ENCRYPTED+'
If BitAND($AHinput,0x8000) Then $AHoutput &= 'SPARSE+'
;$AHoutput = StringMid($AHoutput,1,StringLen($AHoutput)-1)
$AHoutput = StringTrimRight($AHoutput,1)
;ConsoleWrite("$AHoutput = " & $AHoutput & @crlf)
Return $AHoutput
EndFunc

Func _FileRecordFlag($FRFinput) ;Turns out to be problematic to use BitAND with these values
Local $FRFoutput = ""
If BitAND($FRFinput,0x0000) Then $FRFoutput &= 'FILE_DELETE+'
If BitAND($FRFinput,0x0001) Then $FRFoutput &= 'FILE+'
If BitAND($FRFinput,0x0003) Then $FRFoutput &= 'DIRECTORY+'
If BitAND($FRFinput,0x0002) Then $FRFoutput &= 'DIRECTORY_DELETE+'
If BitAND($FRFinput,0x0004) Then $FRFoutput &= 'UNKNOWN1+'
If BitAND($FRFinput,0x0008) Then $FRFoutput &= 'UNKNOWN2+'
;$FRFoutput = StringMid($FRFoutput,1,StringLen($FRFoutput)-1)
$FRFoutput = StringTrimRight($FRFoutput,1)
;ConsoleWrite("$FRFoutput = " & $FRFoutput & @crlf)
Return $FRFoutput
EndFunc

Func _SwapEndian($iHex)
Local $iH, $iHexLen, $iHexTmp = "", $iHexTmp1 = ""
If NOT IsInt((StringLen($iHex))/2) Then
	$iHex = $iHex & '0'
EndIf
;ConsoleWrite("$iHex: " & $iHex & @CRLF)
$iHexLen = StringLen($iHex)
For $iH = 0 To $iHexLen step 2
	$iHexTmp = StringMid($iHex,$iHexLen-($iH+1),2)
	$iHexTmp1 &= $iHexTmp
Next
Return $iHexTmp1
EndFunc

Func _HexEncode($bInput)
    Local $tInput = DllStructCreate("byte[" & BinaryLen($bInput) & "]")
    DllStructSetData($tInput, 1, $bInput)
    Local $a_iCall = DllCall("crypt32.dll", "int", "CryptBinaryToString", _
            "ptr", DllStructGetPtr($tInput), _
            "dword", DllStructGetSize($tInput), _
            "dword", 11, _
            "ptr", 0, _
            "dword*", 0)

    If @error Or Not $a_iCall[0] Then
        Return SetError(1, 0, "")
    EndIf

    Local $iSize = $a_iCall[5]
    Local $tOut = DllStructCreate("char[" & $iSize & "]")

    $a_iCall = DllCall("crypt32.dll", "int", "CryptBinaryToString", _
            "ptr", DllStructGetPtr($tInput), _
            "dword", DllStructGetSize($tInput), _
            "dword", 11, _
            "ptr", DllStructGetPtr($tOut), _
            "dword*", $iSize)

    If @error Or Not $a_iCall[0] Then
        Return SetError(2, 0, "")
    EndIf

    Return SetError(0, 0, DllStructGetData($tOut, 1))

EndFunc  ;==>_HexEncode

Func _UnicodeHexToStr($UnicodeHex)
Local $UniConv
;Local $UnicodeHexLength = StringLen($UnicodeHex)
;For $space = 1 To $UnicodeHexLength
For $space = 1 To StringLen($UnicodeHex)
;	If Dec(StringMid($UnicodeHex,$space,2)) < 32 OR Dec(StringMid($UnicodeHex,$space,2)) > 127 Then
	If Dec(StringMid($UnicodeHex,$space,2)) < 32 Then ; Faster and prevents messed up csv when value=0A etc
		$space += 3
;		$INVALID_NAME = 1 ; Problem since function is used 3 different places for each record
		ContinueLoop
	EndIf
	$tmp = StringMid($UnicodeHex,$space,2)
	$space += 3
	$UniConv &= $tmp
Next
$UniConv = _HexToString($UniConv)
;ConsoleWrite("$UniConv = " & $UniConv & @CRLF)
Return $UniConv
EndFunc

Func _ClearVar()
	$STANDARD_INFORMATION_ON = "FALSE"
	$ATTRIBUTE_LIST_ON = "FALSE"
	$FILE_NAME_ON = "FALSE"
	$OBJECT_ID_ON = "FALSE"
	$SECURITY_DESCRIPTOR_ON = "FALSE"
	$VOLUME_NAME_ON = "FALSE"
	$VOLUME_INFORMATION_ON = "FALSE"
	$DATA_ON = "FALSE"
	$INDEX_ROOT_ON = "FALSE"
	$INDEX_ALLOCATION_ON = "FALSE"
	$BITMAP_ON = "FALSE"
	$REPARSE_POINT_ON = "FALSE"
	$EA_INFORMATION_ON = "FALSE"
	$EA_ON = "FALSE"
	$PROPERTY_SET_ON = "FALSE"
	$LOGGED_UTILITY_STREAM_ON = "FALSE"
	$ATTRIBUTE_END_MARKER_ON = "FALSE"
	$SI_CTime = ""
	$SI_ATime = ""
	$SI_MTime = ""
	$SI_RTime = ""
	$SI_FilePermission = ""
	$SI_USN = ""
	$FN_CTime = ""
	$FN_ATime = ""
	$FN_MTime = ""
	$FN_RTime = ""
	$FN_AllocSize = ""
	$FN_RealSize = ""
	$FN_Flags = ""
	$FN_FileName = ""
	$DATA_NameLength = ""
	$DATA_NameRelativeOffset = ""
	$DATA_Flags = ""
	$DATA_NameSpace = ""
	$DATA_Name = ""
	$DATA_VCNs = ""
	$DATA_NonResidentFlag = ""
	$DATA_AllocatedSize = ""
	$DATA_RealSize = ""
	$DATA_InitializedStreamSize = ""
	$DATA_NonResidentFlag_2 = ""
	$DATA_NameLength_2 = ""
	$DATA_NameRelativeOffset_2 = ""
	$DATA_Flags_2 = ""
	$DATA_NameSpace_2 = ""
	$DATA_Name_2 = ""
	$DATA_StartVCN_2 = ""
	$DATA_LastVCN_2 = ""
	$DATA_VCNs_2 = ""
	$DATA_AllocatedSize_2 = ""
	$DATA_RealSize_2 = ""
	$DATA_InitializedStreamSize_2 = ""
	$DATA_NonResidentFlag_3 = ""
	$DATA_NameLength_3 = ""
	$DATA_NameRelativeOffset_3 = ""
	$DATA_Flags_3 = ""
	$DATA_NameSpace_3 = ""
	$DATA_Name_3 = ""
	$DATA_StartVCN_3 = ""
	$DATA_LastVCN_3 = ""
	$DATA_VCNs_3 = ""
	$DATA_AllocatedSize_3 = ""
	$DATA_RealSize_3 = ""
	$DATA_InitializedStreamSize_3 = ""
	$RecordSlackSpace = ""
	$FN_NameType = ""
	$FN_CTime_2 = ""
	$FN_ATime_2 = ""
	$FN_MTime_2 = ""
	$FN_RTime_2 = ""
	$FN_AllocSize_2 = ""
	$FN_RealSize_2 = ""
	$FN_Flags_2 = ""
	$FN_NameLength_2 = ""
	$FN_NameSpace_2 = ""
	$FN_FileName_2 = ""
	$FN_NameType_2 = ""
	$FN_CTime_3 = ""
	$FN_ATime_3 = ""
	$FN_MTime_3 = ""
	$FN_RTime_3 = ""
	$FN_AllocSize_3 = ""
	$FN_RealSize_3 = ""
	$FN_Flags_3 = ""
	$FN_NameLength_3 = ""
	$FN_NameSpace_3 = ""
	$FN_FileName_3 = ""
	$FN_NameType_3 = ""
	$FN_CTime_4 = ""
	$FN_ATime_4 = ""
	$FN_MTime_4 = ""
	$FN_RTime_4 = ""
	$FN_AllocSize_4 = ""
	$FN_RealSize_4 = ""
	$FN_Flags_4 = ""
	$FN_NameLength_4 = ""
	$FN_NameSpace_4 = ""
	$FN_FileName_4 = ""
	$FN_NameType_4 = ""
	$FN_ParentReferenceNo = ""
	$FN_ParentSequenceNo = ""
	$FN_ParentReferenceNo_2 = ""
	$FN_ParentSequenceNo_2 = ""
	$FN_ParentReferenceNo_3 = ""
	$FN_ParentSequenceNo_3 = ""
	$FN_ParentReferenceNo_4 = ""
	$FN_ParentSequenceNo_4 = ""
	$DATA_LengthOfAttribute = ""
	$DATA_OffsetToAttribute = ""
	$DATA_IndexedFlag = ""
	$DATA_LengthOfAttribute_2 = ""
	$DATA_OffsetToAttribute_2 = ""
	$DATA_IndexedFlag_2 = ""
	$DATA_LengthOfAttribute_3 = ""
	$DATA_OffsetToAttribute_3 = ""
	$DATA_IndexedFlag_3 = ""
	$DATA_CompressionUnitSize = ""
	$DATA_CompressionUnitSize_2 = ""
	$DATA_CompressionUnitSize_3 = ""
	$MSecTest = ""
	$CTimeTest = ""
	$SI_MaxVersions = ""
	$SI_VersionNumber = ""
	$SI_ClassID = ""
	$SI_OwnerID = ""
	$SI_SecurityID = ""
	$SI_HEADER_Flags = ""
	$GUID_ObjectID = ""
	$GUID_BirthVolumeID = ""
	$GUID_BirthObjectID = ""
	$GUID_BirthDomainID = ""
	$VOLUME_NAME_NAME = ""
	$VOL_INFO_NTFS_VERSION = ""
	$VOL_INFO_FLAGS = ""
	$INVALID_FILENAME = 0
	$INVALID_FILENAME_2 = 0
	$INVALID_FILENAME_3 = 0
	$DATA_Number = ""
	$Alternate_Data_Stream = ""
	$FileSizeBytes = ""
	$SI_CTime_tmp = ""
	$SI_ATime_tmp = ""
	$SI_MTime_tmp = ""
	$SI_RTime_tmp = ""
	$FN_CTime_tmp = ""
	$FN_ATime_tmp = ""
	$FN_MTime_tmp = ""
	$FN_RTime_tmp = ""
	$FN_CTime_2_tmp = ""
	$FN_ATime_2_tmp = ""
	$FN_MTime_2_tmp = ""
	$FN_RTime_2_tmp = ""
	$IntegrityCheck = ""
	$DATA_Length = ""
	$DATA_AttributeID = ""
	$DATA_OffsetToDataRuns = ""
	$DATA_Padding = ""
	$DATA_Length_2 = ""
	$DATA_AttributeID_2 = ""
	$DATA_OffsetToDataRuns_2 = ""
	$DATA_Padding_2 = ""
EndFunc

Func _DecToLittleEndian($DecimalInput)
Local $dec = Hex($DecimalInput,8)
$dec = StringMid($dec,7,2) & StringMid($dec,5,2) & StringMid($dec,3,2) & StringMid($dec,1,2)
Return $dec
EndFunc

Func _WinAPI_LockVolume($iVolume)
	$hFile = _WinAPI_CreateFileEx('\\.\' & $iVolume, 3, BitOR($GENERIC_READ,$GENERIC_WRITE), 0x7)
	If Not $hFile Then
		Return SetError(1, 0, 0)
	EndIf
	Local $Ret = DllCall('kernel32.dll', 'int', 'DeviceIoControl', 'ptr', $hFile, 'dword', $FSCTL_LOCK_VOLUME, 'ptr', 0, 'dword', 0, 'ptr', 0, 'dword', 0, 'dword*', 0, 'ptr', 0)
	If (@error) Or (Not $Ret[0]) Then
		$Ret = 0
	EndIf
	If Not IsArray($Ret) Then
		Return SetError(2, 0, 0)
	EndIf
;	Return $Ret[0]
;	Return $Ret
	Return $hFile
EndFunc   ;==>_WinAPI_LockVolume

Func _WinAPI_UnLockVolume($hFile)
	If Not $hFile Then
		ConsoleWrite("Error in _WinAPI_CreateFileEx when unlocking." & @CRLF)
		Return SetError(1, 0, 0)
	EndIf
	Local $Ret = DllCall('kernel32.dll', 'int', 'DeviceIoControl', 'ptr', $hFile, 'dword', $FSCTL_UNLOCK_VOLUME, 'ptr', 0, 'dword', 0, 'ptr', 0, 'dword', 0, 'dword*', 0, 'ptr', 0)
	If (@error) Or (Not $Ret[0]) Then
		$Ret = 0
	EndIf
	If Not IsArray($Ret) Then
		Return SetError(2, 0, 0)
	EndIf
	Return $Ret[0]
EndFunc   ;==>_WinAPI_UnLockVolume

Func _WinAPI_DismountVolume($hFile)
	If Not $hFile Then
		ConsoleWrite("Error in _WinAPI_CreateFileEx when dismounting." & @CRLF)
		Return SetError(1, 0, 0)
	EndIf
	Local $Ret = DllCall('kernel32.dll', 'int', 'DeviceIoControl', 'ptr', $hFile, 'dword', $FSCTL_DISMOUNT_VOLUME, 'ptr', 0, 'dword', 0, 'ptr', 0, 'dword', 0, 'dword*', 0, 'ptr', 0)
	If (@error) Or (Not $Ret[0]) Then
		$Ret = 0
	EndIf
	If Not IsArray($Ret) Then
		Return SetError(2, 0, 0)
	EndIf
	Return $Ret[0]
EndFunc   ;==>_WinAPI_DismountVolume

Func _WinAPI_DismountVolumeMod($iVolume)
	$hFile = _WinAPI_CreateFileEx('\\.\' & $iVolume, 3, BitOR($GENERIC_READ,$GENERIC_WRITE), 0x7)
	If Not $hFile Then
		ConsoleWrite("Error in _WinAPI_CreateFileEx when dismounting." & @CRLF)
		Return SetError(1, 0, 0)
	EndIf
	Local $Ret = DllCall('kernel32.dll', 'int', 'DeviceIoControl', 'ptr', $hFile, 'dword', $FSCTL_DISMOUNT_VOLUME, 'ptr', 0, 'dword', 0, 'ptr', 0, 'dword', 0, 'dword*', 0, 'ptr', 0)
	If (@error) Or (Not $Ret[0]) Then
		Return SetError(3, 0, 0)
;		$Ret = 0
	EndIf
	If Not IsArray($Ret) Then
		Return SetError(2, 0, 0)
	EndIf
;	Return $Ret[0]
	Return $hFile
EndFunc   ;==>_WinAPI_DismountVolumeMod

Func _ShiftEndian($aa)
Local $ab, $ac
$abc = StringLen($aa)
If NOT IsInt($abc/2) Then
	$aa = '0' & $aa
EndIf
For $i = 1 To $abc Step 2
	$ab = StringMid($aa,$abc-$i,2)
	$ac &= $ab
Next
Return $ac
EndFunc

Func _DumpInfo()
Local $NextSector
$p = 1
ConsoleWrite(@CRLF)
ConsoleWrite("Found attributes: " & @CRLF)
For $p = 1 To Ubound($AttributesArr)-1
	If $AttributesArr[$p][2] = 'TRUE' Then
		ConsoleWrite("$" & $AttributesArr[$p][0] & " (" & $AttributesArr[$p][3] & ")" & @CRLF)
	EndIf
Next
ConsoleWrite(@CRLF)
ConsoleWrite("Record header info: " & @CRLF)
$p = 1
For $p = 1 To Ubound($RecordHdrArr)-1
	ConsoleWrite($RecordHdrArr[$p][0] & ": " & $RecordHdrArr[$p][1] & @CRLF)
Next
ConsoleWrite(@CRLF)
ConsoleWrite("$STANDARD_INFORMATION:" & @CRLF)
$p = 1
If $AttributesArr[1][2] = "TRUE" Then
	For $p = 1 To Ubound($SIArr)-1
		ConsoleWrite($SIArr[$p][0] & ": " & $SIArr[$p][1] & @CRLF)
	Next
EndIf
If $AttributesArr[3][2] = "TRUE" Then
	$p = 1
	If $FNArr[2][1] <> "" Then
		ConsoleWrite(@CRLF)
		ConsoleWrite("$FILE_NAME 1:" & @CRLF)
		For $p = 1 To Ubound($FNArr)-1
			ConsoleWrite($FNArr[$p][0] & ": " & $FNArr[$p][1] & @CRLF)
		Next
	EndIf
	$p = 1
	If $FNArr[2][3] <> "" Then
		ConsoleWrite(@CRLF)
		ConsoleWrite("$FILE_NAME 2: " & @CRLF)
		For $p = 1 To Ubound($FNArr)-1
			ConsoleWrite($FNArr[$p][0] & ": " & $FNArr[$p][3] & @CRLF)
		Next
	EndIf
EndIf
If $AttributesArr[4][2] = "TRUE" Then
	$p = 1
	ConsoleWrite(@CRLF)
	ConsoleWrite("$OBJECT_ID:" & @CRLF)
	For $p = 1 To Ubound($ObjectIDArr)-1
		ConsoleWrite($ObjectIDArr[$p][0] & ": " & $ObjectIDArr[$p][1] & @CRLF)
	Next
EndIf
If $AttributesArr[6][2] = "TRUE" Then
	ConsoleWrite(@CRLF)
	ConsoleWrite("$VOLUME_NAME:" & @CRLF)
	ConsoleWrite("NAME: " & $VOLUME_NAME_NAME & @CRLF)
EndIf
If $AttributesArr[7][2] = "TRUE" Then
	ConsoleWrite(@CRLF)
	ConsoleWrite("$VOLUME_INFORMATION:" & @CRLF)
	ConsoleWrite("NTFS_VERSION: " & $VOL_INFO_NTFS_VERSION & @CRLF)
	ConsoleWrite("FLAGS: " & $VOL_INFO_FLAGS & @CRLF)
EndIf
If $AttributesArr[8][2] = "TRUE" Then
	Redim $MFT_RUN_Complete[Ubound($MFT_RUN_Cluster)+1][4]
	Redim $RUN_Complete[Ubound($RUN_Cluster)+1][4]
	$RUN_Complete[0][0] = "Sectors"
	$RUN_Complete[0][1] = "Cluster No"
	$RUN_Complete[0][2] = "Sector No"
	$RUN_Complete[0][3] = "Sparse sectors"
	$MFT_RUN_Complete[0][0] = "Sectors"
	$MFT_RUN_Complete[0][1] = "Cluster No"
	$MFT_RUN_Complete[0][2] = "Sector No"
	$MFT_RUN_Complete[0][3] = "Sparse sectors"
	For $MFTTotalRuns = 1 To Ubound($MFT_RUN_Cluster)
		$MFT_RUN_Complete[$MFTTotalRuns][0] = $MFT_RUN_Sectors[$MFTTotalRuns-1]*$SectorsPerCluster
		$MFT_RUN_Complete[$MFTTotalRuns][1] = $MFT_RUN_Cluster[$MFTTotalRuns-1]
		$MFT_RUN_Complete[$MFTTotalRuns][2] = $MFT_RUN_Cluster[$MFTTotalRuns-1]*$SectorsPerCluster*512
		$MFT_RUN_Complete[$MFTTotalRuns][3] = $MFT_RUN_Sparse[$MFTTotalRuns-1]
	Next
	For $TotalRuns = 1 To Ubound($RUN_Cluster)
		$RUN_Complete[$TotalRuns][0] = $RUN_Sectors[$TotalRuns-1]*$SectorsPerCluster
		$RUN_Complete[$TotalRuns][1] = $RUN_Cluster[$TotalRuns-1]
		$RUN_Complete[$TotalRuns][2] = $RUN_Cluster[$TotalRuns-1]*$SectorsPerCluster*512
		$RUN_Complete[$TotalRuns][3] = $RUN_Sparse[$TotalRuns-1]
	Next
	_ArrayDelete($MFT_RUN_Complete,1) ;Deleting left over
;	_ArrayDisplay($MFT_RUN_Complete,"MFT_RUN_Complete")
	_ArrayDelete($RUN_Complete,1) ;Deleting left over
;	_ArrayDisplay($RUN_Complete,"RUN_Complete")
	$p = 1
	If $DataArr[1][1] <> "" Then
		ConsoleWrite(@CRLF)
		ConsoleWrite("$DATA 1:" & @CRLF)
		For $p = 1 To Ubound($DataArr)-1
			ConsoleWrite($DataArr[$p][0] & ": " & $DataArr[$p][1] & @CRLF)
		Next
	EndIf
	$p = 1
	If $DataArr[2][1] = "01" Then
		ConsoleWrite(@CRLF)
		ConsoleWrite("Interpretation of runs for $DATA 1:" & @CRLF)
;		For $p = 1 To UBound($RUN_Cluster)-1
;			$NextSector += $RUN_Sectors[$p]
;			ConsoleWrite("Run " & $p & ": " & $RUN_Sectors[$p]*$SectorsPerCluster & " sectors found at cluster number " & $RUN_Cluster[$p] & " (sector number " & $RUN_Cluster[$p]*$SectorsPerCluster*512 & ") sparse sectors: " & @CRLF)
;		Next
		For $p = 1 To UBound($RUN_Cluster)-1
			$NextSector += $RUN_Sectors[$p]
			ConsoleWrite("Run " & $p & ": " & $RUN_Complete[$p][0] & " sectors found at cluster number " & $RUN_Complete[$p][1] & " (sector number " & $RUN_Complete[$p][2] & ") sparse sectors: " & $RUN_Complete[$p][3] & @CRLF)
		Next
	EndIf
	$p = 1
	If $DATA_NonResidentFlag_2 <> "" Then
		If $DataArr[1][2] <> "" Then
			ConsoleWrite(@CRLF)
			ConsoleWrite("$DATA 2: " & @CRLF)
			For $p = 1 To Ubound($DataArr)-1
				ConsoleWrite($DataArr[$p][0] & ": " & $DataArr[$p][2] & @CRLF)
			Next
		EndIf
	EndIf
EndIf

EndFunc

