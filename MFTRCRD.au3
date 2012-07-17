#RequireAdmin
#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_UseX64=y
#AutoIt3Wrapper_Change2CUI=y
#AutoIt3Wrapper_Res_Comment=Quick $MFT record dump
#AutoIt3Wrapper_Res_Description=Decode a file's attributes from $MFT
#AutoIt3Wrapper_Res_Fileversion=1.0.0.8
#AutoIt3Wrapper_Res_LegalCopyright=Joakim Schicht
#AutoIt3Wrapper_Res_requestedExecutionLevel=asInvoker
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
#include "_WinTimeFunctions2.au3"
#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#include <StaticConstants.au3>
#include <EditConstants.au3>
#include <GuiEdit.au3>
#Include <WinAPIEx.au3>
#Include <APIConstants.au3>
#Include <Date.au3>
#include <Array.au3>
#Include <String.au3>
;
; http://code.google.com/p/mft2csv/
;
Global $BrowsedFile,$TargetDrive = "", $ALInnerCouner, $MFTSize, $MFTRecordsArr[1][1]
Global $SectorsPerCluster,$MFT_Record_Size,$BytesPerCluster,$BytesPerSector,$MFT_Offset
Global $HEADER_LSN,$HEADER_SequenceNo,$HEADER_Flags,$HEADER_RecordRealSize,$HEADER_RecordAllocSize,$HEADER_FileRef
Global $HEADER_NextAttribID,$HEADER_MFTREcordNumber
Global $IsolatedAttributeList, $AttribListNonResident=0
Global $FN_CTime,$FN_ATime,$FN_MTime,$FN_RTime,$FN_AllocSize,$FN_RealSize,$FN_Flags,$FN_FileName,$FN_NameType
Global $DATA_NameLength,$DATA_NameRelativeOffset,$DATA_Flags,$DATA_NameSpace,$DATA_Name,$RecordActive,$DATA_CompressionUnitSize,$DATA_Length,$DATA_AttributeID,$DATA_OffsetToDataRuns,$DATA_Padding,$DATA_OffsetToAttribute,$DATA_IndexedFlag,$DATA_Name_Core
Global $DATA_NonResidentFlag,$DATA_NameLength,$DATA_NameRelativeOffset,$DATA_Flags,$DATA_Name,$RecordActive
Global $DATA_CompressionUnitSize,$DATA_ON,$DATA_CompressedSize,$DATA_LengthOfAttribute,$DATA_StartVCN,$DATA_LastVCN
Global $DATA_AllocatedSize,$DATA_RealSize,$DATA_InitializedStreamSize,$RunListOffset,$DataRun,$IsCompressed
Global $RUN_VCN[1],$RUN_Clusters[1],$MFT_RUN_Clusters[1],$MFT_RUN_VCN[1],$NameQ[5],$DataQ[1],$sBuffer,$AttrQ[1], $RUN_Sparse[1], $MFT_RUN_Sparse[1], $RUN_Complete[1][4], $MFT_RUN_Complete[1][4], $RUN_Sectors, $MFT_RUN_Sectors
Global $SI_CTime,$SI_ATime,$SI_MTime,$SI_RTime,$SI_FilePermission,$SI_USN,$Errors,$RecordSlackSpace
Global $IsDirectory = 0, $AttributesArr[18][4], $SIArr[13][2], $FNArr[14][1], $RecordHdrArr[15][2], $ObjectIDArr[5][2], $DataArr[20][2], $AttribListArr[9][2],$VolumeNameArr[2][2],$VolumeInformationArr[3][2]
Global $HexDumpRecordSlack[1],$HexDumpRecord[1],$HexDumpHeader[1],$HexDumpStandardInformation[1],$HexDumpAttributeList[1],$HexDumpFileName[1],$HexDumpObjectId[1],$HexDumpSecurityDescriptor[1],$HexDumpVolumeName[1],$HexDumpVolumeInformation[1],$HexDumpData[1],$HexDumpIndexRoot[1],$HexDumpIndexAllocation[1],$HexDumpBitmap[1],$HexDumpReparsePoint[1],$HexDumpEaInformation[1],$HexDumpEa[1],$HexDumpPropertySet[1],$HexDumpLoggedUtilityStream[1]
Global $FN_Number,$DATA_Number,$SI_Number,$ATTRIBLIST_Number,$OBJID_Number,$SECURITY_Number,$VOLNAME_Number,$VOLINFO_Number,$INDEXROOT_Number,$INDEXALLOC_Number,$BITMAP_Number,$REPARSEPOINT_Number,$EAINFO_Number,$EA_Number,$PROPERTYSET_Number,$LOGGEDUTILSTREAM_Number
Global $STANDARD_INFORMATION_ON,$ATTRIBUTE_LIST_ON,$FILE_NAME_ON,$OBJECT_ID_ON,$SECURITY_DESCRIPTOR_ON,$VOLUME_NAME_ON,$VOLUME_INFORMATION_ON,$DATA_ON,$INDEX_ROOT_ON,$INDEX_ALLOCATION_ON,$BITMAP_ON,$REPARSE_POINT_ON,$EA_INFORMATION_ON,$EA_ON,$PROPERTY_SET_ON,$LOGGED_UTILITY_STREAM_ON,$ATTRIBUTE_END_MARKER_ON
Global $GUID_ObjectID,$GUID_BirthVolumeID,$GUID_BirthObjectID,$GUID_BirthDomainID,$VOLUME_NAME_NAME,$VOL_INFO_NTFS_VERSION,$VOL_INFO_FLAGS,$INVALID_FILENAME
Global $MFTRecordsArr1[65530][2],$MFTRecordsArr2[65530][2],$MFTRecordsArr3[65530][2],$MFTRecordsArr4[65530][2],$MFTRecordsArr5[65530][2],$MFTRecordsArr6[65530][2],$MFTRecordsArr7[65530][2],$MFTRecordsArr8[65530][2],$MFTRecordsArr9[65530][2],$MFTRecordsArr10[65530][2],$MFTRecordsArr11[65530][2],$MFTRecordsArr12[65530][2],$MFTRecordsArr13[65530][2],$MFTRecordsArr14[65530][2],$MFTRecordsArr15[65530][2],$MFTRecordsArr16[65530][2],$MFTRecordsArr17[65530][2],$MFTRecordsArr18[65530][2],$MFTRecordsArr19[65530][2],$MFTRecordsArr20[65530][2]
Global $DateTimeFormat = 6 ; YYYY-MM-DD HH:MM:SS:MSMSMS:NSNSNSNS = 2007-08-18 08:15:37:733:1234
Global $tDelta = _WinTime_GetUTCToLocalFileTimeDelta()
Global Const $RecordSignature = '46494C45' ; FILE signature
Global Const $RecordSignatureBad = '44414142' ; BAAD signature
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
Global Const $FileBasicInformation = 4
Global Const $FileInternalInformation = 6
Global Const $OBJ_CASE_INSENSITIVE = 0x00000040
Global Const $FILE_DIRECTORY_FILE = 0x00000002
Global Const $FILE_NON_DIRECTORY_FILE = 0x00000040
Global Const $FILE_RANDOM_ACCESS = 0x00000800
Global Const $tagIOSTATUSBLOCK = "dword Status;ptr Information"
Global Const $tagOBJECTATTRIBUTES = "ulong Length;hwnd RootDirectory;ptr ObjectName;ulong Attributes;ptr SecurityDescriptor;ptr SecurityQualityOfService"
Global Const $tagUNICODESTRING = "ushort Length;ushort MaximumLength;ptr Buffer"
Global Const $tagFILEINTERNALINFORMATION = "int IndexNumber;"
Global $NeedLock = 0
Dim $FormattedTimestamp

ConsoleWrite("" & @CRLF)
ConsoleWrite("Starting MFTRCRD by Joakim Schicht" & @CRLF)
ConsoleWrite("Version 1.0.0.8" & @CRLF)
ConsoleWrite("" & @CRLF)
_validate_parameters()
If StringIsDigit(StringMid($cmdline[1],3)) Then
	$TargetDrive = StringMid($cmdline[1],1,2);&"\"
Else
;	$TargetDrive = StringMid($cmdline[1],1,3)
	$TargetDrive = StringMid($cmdline[1],1,2)
EndIf
$filesystem = DriveGetFileSystem($TargetDrive&"\")
If $filesystem = "NTFS" Then
	ConsoleWrite("Filesystem on " & $TargetDrive & " is " & $filesystem & @CRLF)
Else
	ConsoleWrite("Error: filesystem on " & $TargetDrive & " is " & $filesystem & @CRLF)
	Exit
EndIf
If StringIsDigit(StringMid($cmdline[1],3)) Then
	ConsoleWrite("File IndexNumber: " & StringMid($cmdline[1],3) & @CRLF)
Else
	ConsoleWrite("File IndexNumber: " & _GetIndexNumber($cmdline[1], $IsDirectory) & @CRLF)
EndIf
If $cmdline[2] = "-d" OR $cmdline[2] = "-a" Then
	_SetIndexNumber()
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
	ConsoleWrite("" & @CRLF)
	ConsoleWrite('Usage: "MFTRCRD param1 param2"' & @CRLF)
	ConsoleWrite("" & @CRLF)
	ConsoleWrite("param1 can be a valid file path or an IndexNumber ($MFT record number)" & @CRLF)
	ConsoleWrite("param2 can be -d or -a: " & @CRLF)
	ConsoleWrite("	-d means decode $MFT entry " & @CRLF)
	ConsoleWrite("	-a same as -d but also display formatted hexdump of $MFT record and individual attributes " & @CRLF)
	ConsoleWrite("" & @CRLF)
	ConsoleWrite("Example for dumping an $MFT decode for boot.ini:" & @CRLF)
	ConsoleWrite("MFTRCRD C:\boot.ini -d" & @CRLF)
	ConsoleWrite("" & @CRLF)
	ConsoleWrite("Example for dumping an $MFT decode + the $MFT record and individual attributes for $MFT itself from the C: drive:" & @CRLF)
	ConsoleWrite("MFTRCRD C:0 -a" & @CRLF)
	ConsoleWrite("" & @CRLF)
	ConsoleWrite("Example for dumping an $MFT decode for $LogFile from the D: drive:" & @CRLF)
	ConsoleWrite("MFTRCRD D:2 -d" & @CRLF)
	Exit
EndIf
If $cmdline[2] <> "-d" AND $cmdline[2] <> "-a" Then
	ConsoleWrite("Error: Wrong parameter 2 supplied: " & $cmdline[2] & @CRLF)
EndIf
If FileExists($cmdline[1]) <> 1 OR StringMid($cmdline[1],2,1) <> ":" Then
	If StringIsDigit(StringMid($cmdline[1],3)) <> 1 Then
		ConsoleWrite("Error: Param1 is not valid: " & $cmdline[1] & @CRLF)
		Exit
	EndIf
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

Func _SetIndexNumber()
If StringIsDigit(StringMid($cmdline[1],3)) Then
	$bIndexNumber = StringMid($cmdline[1],3)
Else
	$bIndexNumber = _GetIndexNumber($cmdline[1], $IsDirectory)
EndIf
If $bIndexNumber = 0 Then
	$IsMFT = 1
	_ExtractSystemfile("$MFT")
Else
;	_ExtractSystemfile(_DecToLittleEndian($bIndexNumber))
	_ExtractSystemfile($bIndexNumber)
EndIf
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

Func _ExtractSystemfile($TargetFile)
		Global $DataQ[1], $RUN_VCN[1], $RUN_Clusters[1]
		_ReadBootSector($TargetDrive)
		$BytesPerCluster = $SectorsPerCluster*$BytesPerSector
		$MFTEntry = _FindMFT(0)
		_DecodeMFTRecord($MFTEntry)
		_DecodeDataQEntry($DataQ[1])
		$MFTSize = $DATA_RealSize
		_SetDataInfo(1)
		_ExtractDataRuns()
		$MFT_RUN_VCN = $RUN_VCN
		$MFT_RUN_Clusters = $RUN_Clusters
	If $TargetFile = "$MFT" Then
		ConsoleWrite("TargetFile is $MFT" & @CRLF)
		_ExtractSingleFile(0)
	ElseIf $TargetFile = "ALL" Then
		ConsoleWrite("TargetFiles are ALL meta files" & @CRLF)
		For $i = 0 To 26
			If ($i > 15 AND $i < 24) Or ($i = 8) Then ContinueLoop		;exclude $BadClus (has volume size ADS)
			_ExtractSingleFile($i)
		Next
	Else
;		ConsoleWrite("TargetFile is " & $TargetFile & @CRLF)
		If $TargetFile > 24 Then _InitiateMftArray()
		If @error Then
			ConsoleWrite("Error when creating the MFT arrays" & @crlf)
			Exit
		EndIf
		_ExtractSingleFile(Int($TargetFile,2))
	EndIf
;	ConsoleWrite("Finished extraction of files." & @crlf)
EndFunc

Func _ExtractSingleFile($MFTReferenceNumber)
	Global $DataQ[1]				;clear array
	_ClearVar()
	If $MFTReferenceNumber > 24 Then
		$MFTRecord = _ProcessMftArray($MFTReferenceNumber)
	Else
		$MFTRecord = _FindFileMFTRecord($MFTReferenceNumber)
	EndIf
	If $MFTRecord = "" Then
		ConsoleWrite("Target " & $MFTReferenceNumber & " not found" & @CRLF)
		Return
	EndIf
	_DecodeMFTRecord($MFTRecord)
	_DecodeNameQ($NameQ)
	If $DATA_ON = "FALSE" Then
;		ConsoleWrite("No $DATA attribute present for the file: " & $FN_FileName & @crlf)
		Return
	EndIf
	For $i = 1 To UBound($DataQ) - 1
		_DecodeDataQEntry($DataQ[$i])
		_SetDataInfo($i)
		If $DATA_NonResidentFlag = '00' Then
;			_ExtractResidentFile($DATA_Name, $DATA_LengthOfAttribute)
		Else
			Global $RUN_VCN[1], $RUN_Clusters[1]
			$TotalClusters = $DATA_LastVCN - $DATA_StartVCN + 1
			$Size = $DATA_RealSize
			_ExtractDataRuns()
			If $TotalClusters * $BytesPerCluster >= $Size Then
;				ConsoleWrite(_ArrayToString($RUN_VCN) & @CRLF)
;				ConsoleWrite(_ArrayToString($RUN_Clusters) & @CRLF)
;				_ExtractFile()
			Else 		 ;code to handle attribute list
				$Flag = $IsCompressed		;preserve compression state
				For $j =$i + 1 To UBound($DataQ) - 1
					_DecodeDataQEntry($DataQ[$j])
					$TotalClusters += $DATA_LastVCN - $DATA_StartVCN + 1
					_ExtractDataRuns()
					If $TotalClusters * $BytesPerCluster >= $Size Then
						$DATA_RealSize = $Size
						$IsCompressed = $Flag
;						ConsoleWrite(_ArrayToString($RUN_VCN) & @CRLF)
;						ConsoleWrite(_ArrayToString($RUN_Clusters) & @CRLF)
;						_ExtractFile()
						ExitLoop
					EndIf
				Next
				$i=$j
			EndIf
		EndIf
	Next
Return
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
	$RecordSlackSpace = ""
	$FN_NameType = ""
	$FN_ParentReferenceNo = ""
	$FN_ParentSequenceNo = ""
	$DATA_LengthOfAttribute = ""
	$DATA_OffsetToAttribute = ""
	$DATA_IndexedFlag = ""
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
	$IntegrityCheck = ""
	$DATA_Length = ""
	$DATA_AttributeID = ""
	$DATA_OffsetToDataRuns = ""
	$DATA_Padding = ""
	$DATA_Name_Core = ""
	$ATTRIBLIST_Number = ""
	$FN_Number=""
	$DATA_Number=""
	$SI_Number=""
	$ATTRIBLIST_Number=""
	$OBJID_Number=""
	$SECURITY_Number=""
	$VOLNAME_Number=""
	$VOLINFO_Number=""
	$INDEXROOT_Number=""
	$INDEXALLOC_Number=""
	$BITMAP_Number=""
	$REPARSEPOINT_Number=""
	$EAINFO_Number=""
	$EA_Number=""
	$PROPERTYSET_Number=""
	$LOGGEDUTILSTREAM_Number=""
EndFunc

Func _AttribHeaderFlags($AHinput)
Local $AHoutput = ""
If BitAND($AHinput,0x0001) Then $AHoutput &= 'COMPRESSED+'
If BitAND($AHinput,0x4000) Then $AHoutput &= 'ENCRYPTED+'
If BitAND($AHinput,0x8000) Then $AHoutput &= 'SPARSE+'
$AHoutput = StringTrimRight($AHoutput,1)
Return $AHoutput
EndFunc

Func _DecodeAttrList($TargetFile, $AttrList)
	Local $offset, $length, $nBytes, $hFile, $LocalAttribID, $LocalName, $ALRecordLength, $ALNameLength, $ALNameOffset
	If StringMid($AttrList, 17, 2) = "00" Then		;attribute list is in $AttrList
		$offset = Dec(_SwapEndian(StringMid($AttrList, 41, 4)))
		$List = StringMid($AttrList, $offset*2+1)
;		$IsolatedAttributeList = $list
	Else			;attribute list is found from data run in $AttrList
		$size = Dec(_SwapEndian(StringMid($AttrList, $offset*2 + 97, 16)))
		$offset = ($offset + Dec(_SwapEndian(StringMid($AttrList, $offset*2 + 65, 4))))*2
		$DataRun = StringMid($AttrList, $offset+1, StringLen($AttrList)-$offset)
		ConsoleWrite("Attribute_List DataRun is " & $DataRun & @CRLF)
		Global $RUN_VCN[1], $RUN_Clusters[1]
		_ExtractDataRuns()
		$tBuffer = DllStructCreate("byte[" & $BytesPerCluster & "]")
		$hFile = _WinAPI_CreateFile("\\.\" & $TargetDrive, 2, 6, 6)
		If $hFile = 0 Then
			ConsoleWrite("Error in function _WinAPI_CreateFile when trying to locate Attribute List." & @CRLF)
			_WinAPI_CloseHandle($hFile)
			Return
		EndIf
		$List = ""
		For $r = 1 To Ubound($RUN_VCN)-1
			_WinAPI_SetFilePointerEx($hFile, $RUN_VCN[$r]*$BytesPerCluster, $FILE_BEGIN)
			For $i = 1 To $RUN_Clusters[$r]
				_WinAPI_ReadFile($hFile, DllStructGetPtr($tBuffer), $BytesPerCluster, $nBytes)
				$List &= StringTrimLeft(DllStructGetData($tBuffer, 1),2)
			Next
		Next
		_WinAPI_CloseHandle($hFile)
		$List = StringMid($List, 1, $size*2)
	EndIf
;	_DebugOut("$List", $List & @CRLF)
	$IsolatedAttributeList = $list
	$offset=0
	$str=""
	While StringLen($list) > $offset*2
		$type=StringMid($List, ($offset*2)+1, 8)
		$ALRecordLength = Dec(_SwapEndian(StringMid($List, $offset*2 + 9, 4)))
		$ALNameLength = Dec(_SwapEndian(StringMid($List, $offset*2 + 13, 2)))
		$ALNameOffset = Dec(_SwapEndian(StringMid($List, $offset*2 + 15, 2)))
		$TestVCN = Dec(_SwapEndian(StringMid($List, $offset*2 + 17, 16)))
		$ref=Dec(_SwapEndian(StringMid($List, $offset*2 + 33, 8)))
		$LocalAttribID = "0x" & StringMid($List, $offset*2 + 49, 2) & StringMid($List, $offset*2 + 51, 2)
		If $ALRecordLength > 0 Then
			$LocalName = StringMid($List, $offset*2 + 53, $ALNameLength*2*2)
			$LocalName = _UnicodeHexToStr($LocalName)
		EndIf
		If $ref <> $TargetFile Then		;new attribute
			If Not StringInStr($str, $ref) Then $str &= $ref & "-"
			$ALInnerCouner += 1
			ReDim $AttribListArr[9][$ALInnerCouner+1]
			$AttribListArr[0][$ALInnerCouner] = "Number " & $ALInnerCouner
			$AttribListArr[1][$ALInnerCouner] = $type
			$AttribListArr[2][$ALInnerCouner] = $ALRecordLength
			$AttribListArr[3][$ALInnerCouner] = $ALNameLength
			$AttribListArr[4][$ALInnerCouner] = $ALNameOffset
			$AttribListArr[5][$ALInnerCouner] = $TestVCN
			$AttribListArr[6][$ALInnerCouner] = $ref
			$AttribListArr[7][$ALInnerCouner] = $LocalName
			$AttribListArr[8][$ALInnerCouner] = $LocalAttribID
		EndIf
		If $type=$DATA Then
			$DataInAttrlist=1
			$IsolatedData=StringMid($List, ($offset*2)+1, $ALRecordLength*2)
			If $TestVCN=0 Then $DataIsResident=1
		EndIf
		$offset += Dec(_SwapEndian(StringMid($List, $offset*2 + 9, 4)))
	WEnd
	If $str = "" Then
		ConsoleWrite("No extra MFT records found" & @CRLF)
	Else
		$AttrQ = StringSplit(StringTrimRight($str,1), "-")
		ConsoleWrite("Decode of $ATTRIBUTE_LIST reveiled extra MFT Records to be examined = " & _ArrayToString($AttrQ, @CRLF) & @CRLF)
	EndIf
EndFunc

Func _StripMftRecord($MFTEntry)
	$UpdSeqArrOffset = Dec(_SwapEndian(StringMid($MFTEntry,11,4)))
	$UpdSeqArrSize = Dec(_SwapEndian(StringMid($MFTEntry,15,4)))
	$UpdSeqArr = StringMid($MFTEntry,3+($UpdSeqArrOffset*2),$UpdSeqArrSize*2*2)
	$UpdSeqArrPart0 = StringMid($UpdSeqArr,1,4)
	$UpdSeqArrPart1 = StringMid($UpdSeqArr,5,4)
	$UpdSeqArrPart2 = StringMid($UpdSeqArr,9,4)
	$RecordEnd1 = StringMid($MFTEntry,1023,4)
	$RecordEnd2 = StringMid($MFTEntry,2047,4)
	If $UpdSeqArrPart0 <> $RecordEnd1 OR $UpdSeqArrPart0 <> $RecordEnd2 Then
		ConsoleWrite("Error the $MFT record is corrupt" & @CRLF)
		Return ""
	Else
		$MFTEntry = StringMid($MFTEntry,1,1022) & $UpdSeqArrPart1 & StringMid($MFTEntry,1027,1020) & $UpdSeqArrPart2
	EndIf
	$RecordSize = Dec(_SwapEndian(StringMid($MFTEntry,51,8)),2)
	$HeaderSize = Dec(_SwapEndian(StringMid($MFTEntry,43,4)),2)
	$MFTEntry = StringMid($MFTEntry,$HeaderSize*2+3,($RecordSize-$HeaderSize-8)*2)        ;strip "0x..." and "FFFFFFFF..."
;	_DebugOut("Stripped Record", $MFTEntry)
	Return $MFTEntry
EndFunc

Func _DecodeDataQEntry($Entry)
	$DATA_Length = StringMid($Entry,9,8)
	$DATA_Length = Dec(StringMid($DATA_Length,7,2) & StringMid($DATA_Length,5,2) & StringMid($DATA_Length,3,2) & StringMid($DATA_Length,1,2))
	$DATA_NonResidentFlag = StringMid($Entry,17,2)
;	ConsoleWrite("$DATA_NonResidentFlag = " & $DATA_NonResidentFlag & @crlf)
	$DATA_NameLength = Dec(StringMid($Entry,19,2))
;	ConsoleWrite("$DATA_NameLength = " & $DATA_NameLength & @crlf)
	$DATA_NameRelativeOffset = StringMid($Entry,21,4)
;	ConsoleWrite("$DATA_NameRelativeOffset = " & $DATA_NameRelativeOffset & @crlf)
	$DATA_NameRelativeOffset = Dec(_SwapEndian($DATA_NameRelativeOffset))
;	ConsoleWrite("$DATA_NameRelativeOffset = " & $DATA_NameRelativeOffset & @crlf)
	If $DATA_NameLength > 0 Then
		$DATA_Name = _UnicodeHexToStr(StringMid($Entry,$DATA_NameRelativeOffset*2 + 1,$DATA_NameLength*4))
		$DATA_Name_Core = $DATA_Name
		$DATA_Name = $FN_FileName & "[" & $DATA_Name & "]"		;must be ADS
;		ConsoleWrite("$DATA_Name = " & $DATA_Name & @crlf)
	Else
		$DATA_Name = $FN_FileName
	EndIf
	$DATA_Flags = _SwapEndian(StringMid($Entry,25,4))
;	ConsoleWrite("$DATA_Flags = " & $DATA_Flags & @crlf)
	$Flags = ""
	If $DATA_Flags = "0000" Then
		$Flags = "NORMAL"
	Else
		If BitAND($DATA_Flags,"0001") Then
			$IsCompressed = 1
			$Flags &= "COMPRESSED+"
		EndIf
		If BitAND($DATA_Flags,"4000") Then
			$IsEncrypted = 1
			$Flags &= "ENCRYPTED+"
		EndIf
		If BitAND($DATA_Flags,"8000") Then
			$IsSparse = 1
			$Flags &= "SPARSE+"
		EndIf
		$Flags = StringTrimRight($Flags,1)
	EndIf
;	ConsoleWrite("File is " & $Flags & @CRLF)
	$DATA_AttributeID = StringMid($Entry,29,4)
	$DATA_AttributeID = StringMid($DATA_AttributeID,3,2) & StringMid($DATA_AttributeID,1,2)
	If $DATA_NonResidentFlag = '01' Then
		$DATA_StartVCN = StringMid($Entry,33,16)
;		ConsoleWrite("$DATA_StartVCN = " & $DATA_StartVCN & @crlf)
		$DATA_StartVCN = Dec(_SwapEndian($DATA_StartVCN),2)
;		ConsoleWrite("$DATA_StartVCN = " & $DATA_StartVCN & @crlf)
		$DATA_LastVCN = StringMid($Entry,49,16)
;		ConsoleWrite("$DATA_LastVCN = " & $DATA_LastVCN & @crlf)
		$DATA_LastVCN = Dec(_SwapEndian($DATA_LastVCN),2)
;		ConsoleWrite("$DATA_LastVCN = " & $DATA_LastVCN & @crlf)
		$DATA_VCNs = $DATA_LastVCN - $DATA_StartVCN
;		ConsoleWrite("$DATA_VCNs = " & $DATA_VCNs & @crlf)
		$DATA_OffsetToDataRuns = StringMid($Entry,65,4)
		$DATA_OffsetToDataRuns = Dec(StringMid($DATA_OffsetToDataRuns,3,1) & StringMid($DATA_OffsetToDataRuns,3,1))
		$DATA_CompressionUnitSize = Dec(_SwapEndian(StringMid($Entry,69,4)))
;		ConsoleWrite("$DATA_CompressionUnitSize = " & $DATA_CompressionUnitSize & @crlf)
		$IsCompressed = 0
		If $DATA_CompressionUnitSize = 4 Then $IsCompressed = 1
		$DATA_Padding = StringMid($Entry,73,8)
		$DATA_Padding = StringMid($DATA_Padding,7,2) & StringMid($DATA_Padding,5,2) & StringMid($DATA_Padding,3,2) & StringMid($DATA_Padding,1,2)
		$DATA_AllocatedSize = StringMid($Entry,81,16)
;		ConsoleWrite("$DATA_AllocatedSize = " & $DATA_AllocatedSize & @crlf)
		$DATA_AllocatedSize = Dec(_SwapEndian($DATA_AllocatedSize),2)
;		ConsoleWrite("$DATA_AllocatedSize = " & $DATA_AllocatedSize & @crlf)
		$DATA_RealSize = StringMid($Entry,97,16)
;		ConsoleWrite("$DATA_RealSize = " & $DATA_RealSize & @crlf)
		$DATA_RealSize = Dec(_SwapEndian($DATA_RealSize),2)
;		ConsoleWrite("$DATA_RealSize = " & $DATA_RealSize & @crlf)
		$DATA_InitializedStreamSize = StringMid($Entry,113,16)
;		ConsoleWrite("$DATA_InitializedStreamSize = " & $DATA_InitializedStreamSize & @crlf)
		$DATA_InitializedStreamSize = Dec(_SwapEndian($DATA_InitializedStreamSize),2)
;		ConsoleWrite("$DATA_InitializedStreamSize = " & $DATA_InitializedStreamSize & @crlf)
		$RunListOffset = StringMid($Entry,65,4)
;		ConsoleWrite("$RunListOffset = " & $RunListOffset & @crlf)
		$RunListOffset = Dec(_SwapEndian($RunListOffset))
;		ConsoleWrite("$RunListOffset = " & $RunListOffset & @crlf)
		If $IsCompressed AND $RunListOffset = 72 Then
			$DATA_CompressedSize = StringMid($Entry,129,16)
			$DATA_CompressedSize = Dec(_SwapEndian($DATA_CompressedSize),2)
		EndIf
		$DataRun = StringMid($Entry,$RunListOffset*2+1,(StringLen($Entry)-$RunListOffset)*2)
;		ConsoleWrite("$DataRun = " & $DataRun & @crlf)
	ElseIf $DATA_NonResidentFlag = '00' Then
		$DATA_LengthOfAttribute = StringMid($Entry,33,8)
;		ConsoleWrite("$DATA_LengthOfAttribute = " & $DATA_LengthOfAttribute & @crlf)
		$DATA_LengthOfAttribute = Dec(_SwapEndian($DATA_LengthOfAttribute),2)
;		ConsoleWrite("$DATA_LengthOfAttribute = " & $DATA_LengthOfAttribute & @crlf)
;		$DATA_OffsetToAttribute = StringMid($Entry,41,4)
;		$DATA_OffsetToAttribute = Dec(StringMid($DATA_OffsetToAttribute,3,2) & StringMid($DATA_OffsetToAttribute,1,2))
		$DATA_OffsetToAttribute = Dec(_SwapEndian(StringMid($Entry,41,4)))
;		ConsoleWrite("$DATA_OffsetToAttribute = " & $DATA_OffsetToAttribute & @crlf)
		$DATA_IndexedFlag = Dec(StringMid($Entry,45,2))
		$DATA_Padding = StringMid($Entry,47,2)
		$DataRun = StringMid($Entry,$DATA_OffsetToAttribute*2+1,$DATA_LengthOfAttribute*2)
;		ConsoleWrite("$DataRun = " & $DataRun & @crlf)
	EndIf
EndFunc

Func _DecodeMFTRecord($MFTEntry)
Local $MFTEntryOrig
Global $HexDumpRecordSlack[1],$HexDumpRecord[1],$HexDumpHeader[1],$HexDumpStandardInformation[1],$HexDumpAttributeList[1],$HexDumpFileName[1],$HexDumpObjectId[1],$HexDumpSecurityDescriptor[1],$HexDumpVolumeName[1],$HexDumpVolumeInformation[1],$HexDumpData[1],$HexDumpIndexRoot[1],$HexDumpIndexAllocation[1],$HexDumpBitmap[1],$HexDumpReparsePoint[1],$HexDumpEaInformation[1],$HexDumpEa[1],$HexDumpPropertySet[1],$HexDumpLoggedUtilityStream[1]
Global $NameQ[5]		;clear name array
_Arrayadd($HexDumpRecord,StringMid($MFTEntry,3))
_SetArrays()
$HEADER_LSN = ""
$HEADER_SequenceNo = ""
$HEADER_Flags = ""
$HEADER_RecordRealSize = ""
$HEADER_RecordAllocSize = ""
$HEADER_FileRef = ""
$HEADER_NextAttribID = ""
$HEADER_MFTREcordNumber = ""
$UpdSeqArrOffset = Dec(_SwapEndian(StringMid($MFTEntry,11,4)))
$UpdSeqArrSize = Dec(_SwapEndian(StringMid($MFTEntry,15,4)))
$UpdSeqArr = StringMid($MFTEntry,3+($UpdSeqArrOffset*2),$UpdSeqArrSize*2*2)
$UpdSeqArrPart0 = StringMid($UpdSeqArr,1,4)
$UpdSeqArrPart1 = StringMid($UpdSeqArr,5,4)
$UpdSeqArrPart2 = StringMid($UpdSeqArr,9,4)
$RecordEnd1 = StringMid($MFTEntry,1023,4)
$RecordEnd2 = StringMid($MFTEntry,2047,4)
If $UpdSeqArrPart0 <> $RecordEnd1 OR $UpdSeqArrPart0 <> $RecordEnd2 Then
	ConsoleWrite("Error the $MFT record is corrupt" & @CRLF)
	Return
 Else
	$MFTEntry = StringMid($MFTEntry,1,1022) & $UpdSeqArrPart1 & StringMid($MFTEntry,1027,1020) & $UpdSeqArrPart2
EndIf
Local $MFTHeader = StringMid($MFTEntry,1,2+32)
;ConsoleWrite("$MFTHeader = " & $MFTHeader & @crlf)
$HEADER_LSN = StringMid($MFTEntry,19,16)
;ConsoleWrite("$HEADER_LSN = " & $HEADER_LSN & @crlf)
$HEADER_LSN = _SwapEndian($HEADER_LSN)
;ConsoleWrite("$HEADER_LSN = " & $HEADER_LSN & @crlf)
$HEADER_SequenceNo = Dec(_SwapEndian(StringMid($MFTEntry,35,4)))
;ConsoleWrite("$HEADER_SequenceNo = " & $HEADER_SequenceNo & @crlf)
$Header_HardLinkCount = StringMid($MFTEntry,39,4)
$Header_HardLinkCount = Dec(StringMid($Header_HardLinkCount,3,2) & StringMid($Header_HardLinkCount,1,2))
$HEADER_Flags = StringMid($MFTEntry,47,4)
$RecordActive = "DELETED"
If BitAND(Dec($HEADER_Flags),Dec('0100')) Then $RecordActive = "ALLOCATED"
Select
	Case $HEADER_Flags = '0000'
		$HEADER_Flags = 'FILE'
	Case $HEADER_Flags = '0100'
		$HEADER_Flags = 'FILE'
	Case $HEADER_Flags = '0200'
		$HEADER_Flags = 'FOLDER'
	Case $HEADER_Flags = '0300'
		$HEADER_Flags = 'FOLDER'
	Case Else
		$HEADER_Flags = 'UNKNOWN'
EndSelect
;ConsoleWrite("$HEADER_Flags = " & $HEADER_Flags & @crlf)
$HEADER_RecordRealSize = Dec(_SwapEndian(StringMid($MFTEntry,51,8)),2)
;ConsoleWrite("$HEADER_RecordRealSize = " & $HEADER_RecordRealSize & " -> 0x" & Hex($HEADER_RecordRealSize,8) & @crlf)
$HEADER_RecordAllocSize = Dec(_SwapEndian(StringMid($MFTEntry,59,8)),2)
;ConsoleWrite("$HEADER_RecordAllocSize = " & $HEADER_RecordAllocSize & @crlf)
$HEADER_FileRef = StringMid($MFTEntry,67,16)
;ConsoleWrite("$HEADER_FileRef = " & $HEADER_FileRef & @crlf)
$HEADER_NextAttribID = StringMid($MFTEntry,83,4)
;ConsoleWrite("$HEADER_NextAttribID = " & $HEADER_NextAttribID & @crlf)
$HEADER_NextAttribID = _SwapEndian($HEADER_NextAttribID)
$HEADER_MFTRecordNumber = Dec(_SwapEndian(StringMid($MFTEntry,91,8)),2)
;ConsoleWrite("$HEADER_MFTRecordNumber = " & $HEADER_MFTRecordNumber & @crlf)
$AttributeOffset = (Dec(StringMid($MFTEntry,43,2))*2)+3
$RecordHdrArr[0][1] = "Field value"
$RecordHdrArr[1][1] = $UpdSeqArrOffset
$RecordHdrArr[2][1] = $UpdSeqArrSize
$RecordHdrArr[3][1] = $HEADER_LSN
$RecordHdrArr[4][1] = $HEADER_SequenceNo
$RecordHdrArr[5][1] = $Header_HardLinkCount
$RecordHdrArr[6][1] = $AttributeOffset
$RecordHdrArr[7][1] = $HEADER_Flags
$RecordHdrArr[8][1] = $HEADER_RecordRealSize
$RecordHdrArr[9][1] = $HEADER_RecordAllocSize
$RecordHdrArr[10][1] = $HEADER_FileRef
$RecordHdrArr[11][1] = $HEADER_NextAttribID
$RecordHdrArr[12][1] = $HEADER_MFTREcordNumber
$RecordHdrArr[13][1] = $UpdSeqArrPart0
$RecordHdrArr[14][1] = $UpdSeqArrPart1&$UpdSeqArrPart2
_Arrayadd($HexDumpHeader,StringMid($MFTEntry,3,$AttributeOffset-3))
While 1
	$AttributeType = StringMid($MFTEntry,$AttributeOffset,8)
;	ConsoleWrite("$AttributeType = " & $AttributeType & @crlf)
;	If $AttributeType = $ATTRIBUTE_END_MARKER Then ExitLoop
	$AttributeSize = StringMid($MFTEntry,$AttributeOffset+8,8)
;	ConsoleWrite("$AttributeSize = " & $AttributeSize & @crlf)
	$AttributeSize = Dec(_SwapEndian($AttributeSize),2)
;	ConsoleWrite("$AttributeSize = " & $AttributeSize & @crlf)
;	ConsoleWrite("$AttributeOffset Dec = " & $AttributeOffset & @crlf)
;	ConsoleWrite("$AttributeOffset Hex = 0x" & Hex(Int(($AttributeOffset-3)/2),4) & @crlf)
	Select
		Case $AttributeType = $STANDARD_INFORMATION
			$STANDARD_INFORMATION_ON = "TRUE"
			$SI_Number += 1
			ReDim $SIArr[13][$SI_Number+1]
			_Get_StandardInformation($MFTEntry,$AttributeOffset,$AttributeSize,$SI_Number)
			ReDim $HexDumpStandardInformation[$SI_Number]
			_Arrayadd($HexDumpStandardInformation,StringMid($MFTEntry,$AttributeOffset,$AttributeSize*2))
		Case $AttributeType = $ATTRIBUTE_LIST
			$ATTRIBUTE_LIST_ON = "TRUE"
			$ATTRIBLIST_Number += 1
			$MFTEntryOrig = $MFTEntry
			$AttrList = StringMid($MFTEntry,$AttributeOffset,$AttributeSize*2)
			_DecodeAttrList($HEADER_MFTRecordNumber, $AttrList)		;produces $AttrQ - extra record list
			$str = ""
			For $i = 1 To $AttrQ[0]
;			   $record = _FindFileMFTRecord($AttrQ[$i])
			   $record = _ProcessMftArray($AttrQ[$i])
			   $str &= _StripMftRecord($record)		;no header or end marker
			Next
			$str &= "FFFFFFFF"		;add end marker
			$MFTEntry = StringMid($MFTEntry,1,($HEADER_RecordRealSize-8)*2+2) & $str       ;strip "FFFFFFFF..." first
			ReDim $HexDumpAttributeList[$ATTRIBLIST_Number]
			_Arrayadd($HexDumpAttributeList,StringMid($MFTEntry,$AttributeOffset,$AttributeSize*2))
   		Case $AttributeType = $FILE_NAME
			$FILE_NAME_ON = "TRUE"
			$FN_Number += 1
			$attr = StringMid($MFTEntry,$AttributeOffset,$AttributeSize*2)
			$NameSpace = StringMid($attr,179,2)
			Select
				Case $NameSpace = "00"	;POSIX
					$NameQ[1] = $attr
				Case $NameSpace = "01"	;WIN32
					$NameQ[4] = $attr
				Case $NameSpace = "02"	;DOS
					$NameQ[2] = $attr
				Case $NameSpace = "03"	;DOS+WIN32
					$NameQ[3] = $attr
			EndSelect
			ReDim $FNArr[14][$FN_Number+1]
			_Get_FileName($MFTEntry,$AttributeOffset,$AttributeSize,$FN_Number)
			ReDim $HexDumpFileName[$FN_Number]
			_Arrayadd($HexDumpFileName,StringMid($MFTEntry,$AttributeOffset,$AttributeSize*2))
		Case $AttributeType = $OBJECT_ID
			$OBJECT_ID_ON = "TRUE"
			$OBJID_Number += 1
			ReDim $ObjectIDArr[5][$OBJID_Number+1]
			_Get_ObjectID($MFTEntry,$AttributeOffset,$AttributeSize)
			_Set_ObjectID()
			ReDim $HexDumpObjectId[$OBJID_Number]
			_Arrayadd($HexDumpObjectId,StringMid($MFTEntry,$AttributeOffset,$AttributeSize*2))
		Case $AttributeType = $SECURITY_DESCRIPTOR
			$SECURITY_DESCRIPTOR_ON = "TRUE"
			$SECURITY_Number += 1
;			_Get_SecurityDescriptor()
			ReDim $HexDumpSecurityDescriptor[$SECURITY_Number]
			_Arrayadd($HexDumpSecurityDescriptor,StringMid($MFTEntry,$AttributeOffset,$AttributeSize*2))
		Case $AttributeType = $VOLUME_NAME
			$VOLUME_NAME_ON = "TRUE"
			$VOLNAME_Number += 1
			ReDim $VolumeNameArr[2][$VOLNAME_Number+1]
			_Get_VolumeName($MFTEntry,$AttributeOffset,$AttributeSize,$VOLNAME_Number)
			ReDim $HexDumpVolumeName[$VOLNAME_Number]
			_Arrayadd($HexDumpVolumeName,StringMid($MFTEntry,$AttributeOffset,$AttributeSize*2))
		Case $AttributeType = $VOLUME_INFORMATION
			$VOLUME_INFORMATION_ON = "TRUE"
			$VOLINFO_Number += 1
			ReDim $VolumeInformationArr[3][$VOLINFO_Number+1]
			_Get_VolumeInformation($MFTEntry,$AttributeOffset,$AttributeSize,$VOLINFO_Number)
			ReDim $HexDumpVolumeInformation[$VOLINFO_Number]
			_Arrayadd($HexDumpVolumeInformation,StringMid($MFTEntry,$AttributeOffset,$AttributeSize*2))
		Case $AttributeType = $DATA
			$DATA_ON = "TRUE"
			$DATA_Number += 1
			ReDim $DataArr[20][$DATA_Number+1]
			_ArrayAdd($DataQ, StringMid($MFTEntry,$AttributeOffset,$AttributeSize*2))
			ReDim $HexDumpData[$DATA_Number]
			_Arrayadd($HexDumpData,StringMid($MFTEntry,$AttributeOffset,$AttributeSize*2))
		Case $AttributeType = $INDEX_ROOT
			$INDEX_ROOT_ON = "TRUE"
			$INDEXROOT_Number += 1
;			_Get_IndexRoot()
			ReDim $HexDumpIndexRoot[$INDEXROOT_Number]
			_Arrayadd($HexDumpIndexRoot,StringMid($MFTEntry,$AttributeOffset,$AttributeSize*2))
		Case $AttributeType = $INDEX_ALLOCATION
			$INDEX_ALLOCATION_ON = "TRUE"
			$INDEXALLOC_Number += 1
;			_Get_IndexAllocation()
			ReDim $HexDumpIndexAllocation[$INDEXALLOC_Number]
			_Arrayadd($HexDumpIndexAllocation,StringMid($MFTEntry,$AttributeOffset,$AttributeSize*2))
		Case $AttributeType = $BITMAP
			$BITMAP_ON = "TRUE"
			$BITMAP_Number += 1
;			_Get_Bitmap()
			ReDim $HexDumpBitmap[$BITMAP_Number]
			_Arrayadd($HexDumpBitmap,StringMid($MFTEntry,$AttributeOffset,$AttributeSize*2))
		Case $AttributeType = $REPARSE_POINT
			$REPARSE_POINT_ON = "TRUE"
			$REPARSEPOINT_Number += 1
;			_Get_ReparsePoint()
			ReDim $HexDumpReparsePoint[$REPARSEPOINT_Number]
			_Arrayadd($HexDumpReparsePoint,StringMid($MFTEntry,$AttributeOffset,$AttributeSize*2))
		Case $AttributeType = $EA_INFORMATION
			$EA_INFORMATION_ON = "TRUE"
			$EAINFO_Number += 1
;			_Get_EaInformation()
			ReDim $HexDumpEaInformation[$EAINFO_Number]
			_Arrayadd($HexDumpEaInformation,StringMid($MFTEntry,$AttributeOffset,$AttributeSize*2))
		Case $AttributeType = $EA
			$EA_ON = "TRUE"
			$EA_Number += 1
;			_Get_Ea()
			ReDim $HexDumpEa[$EA_Number]
			_Arrayadd($HexDumpEa,StringMid($MFTEntry,$AttributeOffset,$AttributeSize*2))
		Case $AttributeType = $PROPERTY_SET
			$PROPERTY_SET_ON = "TRUE"
			$PROPERTYSET_Number += 1
;			_Get_PropertySet()
			ReDim $HexDumpPropertySet[$PROPERTYSET_Number]
			_Arrayadd($HexDumpPropertySet,StringMid($MFTEntry,$AttributeOffset,$AttributeSize*2))
		Case $AttributeType = $LOGGED_UTILITY_STREAM
			$LOGGED_UTILITY_STREAM_ON = "TRUE"
			$LOGGEDUTILSTREAM_Number += 1
;			_Get_LoggedUtilityStream()
			ReDim $HexDumpLoggedUtilityStream[$LOGGEDUTILSTREAM_Number]
			_Arrayadd($HexDumpLoggedUtilityStream,StringMid($MFTEntry,$AttributeOffset,$AttributeSize*2))
		Case $AttributeType = $ATTRIBUTE_END_MARKER
			If $ATTRIBUTE_LIST_ON = "TRUE" Then
				_Arrayadd($HexDumpRecordSlack,StringMid($MFTEntryOrig,($HEADER_RecordRealSize*2)+3))
			Else
				_Arrayadd($HexDumpRecordSlack,StringMid($MFTEntry,($HEADER_RecordRealSize*2)+3))
			EndIf
			ExitLoop
	EndSelect
	$AttributeOffset += $AttributeSize*2
WEnd
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
EndFunc

Func _DecodeNameQ($NameQ)
	For $name = 1 To UBound($NameQ) - 1
		$NameString = $NameQ[$name]
		If $NameString = "" Then ContinueLoop
		$FN_AllocSize = Dec(_SwapEndian(StringMid($NameString,129,16)),2)
;		ConsoleWrite("$FN_AllocSize = " & $FN_AllocSize & @crlf)
		$FN_RealSize = Dec(_SwapEndian(StringMid($NameString,145,16)),2)
;		ConsoleWrite("$FN_RealSize = " & $FN_RealSize & @crlf)
		$FN_NameLength = Dec(StringMid($NameString,177,2))
;		ConsoleWrite("$FN_NameLength = " & $FN_NameLength & @crlf)
		$FN_NameSpace = StringMid($NameString,179,2)
		Select
			Case $FN_NameSpace = '00'
				$FN_NameSpace = 'POSIX'
			Case $FN_NameSpace = '01'
				$FN_NameSpace = 'WIN32'
			Case $FN_NameSpace = '02'
				$FN_NameSpace = 'DOS'
			Case $FN_NameSpace = '03'
				$FN_NameSpace = 'DOS+WIN32'
			Case Else
				$FN_NameSpace = 'UNKNOWN'
		EndSelect
;		ConsoleWrite("$FN_NameSpace = " & $FN_NameSpace & @crlf)
		$FN_FileName = StringMid($NameString,181,$FN_NameLength*4)
;		ConsoleWrite("$FN_FileName = " & $FN_FileName & @crlf)
		$FN_FileName = _UnicodeHexToStr($FN_FileName)
;		ConsoleWrite("$FN_FileName = " & $FN_FileName & @crlf)
		If StringLen($FN_FileName) <> $FN_NameLength Then $INVALID_FILENAME = 1
	Next
	Return
EndFunc

Func _ExtractDataRuns()
	$r=UBound($RUN_Clusters)
	$i=1
	$RUN_VCN[0] = 0
	$BaseVCN = $RUN_VCN[0]
	If $DataRun = "" Then $DataRun = "00"
	Do
		$RunListID = StringMid($DataRun,$i,2)
		If $RunListID = "00" Then ExitLoop
;		ConsoleWrite("$RunListID = " & $RunListID & @crlf)
		$i += 2
		$RunListClustersLength = Dec(StringMid($RunListID,2,1))
;		ConsoleWrite("$RunListClustersLength = " & $RunListClustersLength & @crlf)
		$RunListVCNLength = Dec(StringMid($RunListID,1,1))
;		ConsoleWrite("$RunListVCNLength = " & $RunListVCNLength & @crlf)
		$RunListClusters = Dec(_SwapEndian(StringMid($DataRun,$i,$RunListClustersLength*2)),2)
;		ConsoleWrite("$RunListClusters = " & $RunListClusters & @crlf)
		$i += $RunListClustersLength*2
		$RunListVCN = _SwapEndian(StringMid($DataRun, $i, $RunListVCNLength*2))
		;next line handles positive or negative move
		$BaseVCN += Dec($RunListVCN,2)-(($r>1) And (Dec(StringMid($RunListVCN,1,1))>7))*Dec(StringMid("10000000000000000",1,$RunListVCNLength*2+1),2)
		If $RunListVCN <> "" Then
			$RunListVCN = $BaseVCN
		Else
			$RunListVCN = 0			;$RUN_VCN[$r-1]		;0
		EndIf
;		ConsoleWrite("$RunListVCN = " & $RunListVCN & @crlf)
		If (($RunListVCN=0) And ($RunListClusters>16) And (Mod($RunListClusters,16)>0)) Then
		;If (($RunListVCN=$RUN_VCN[$r-1]) And ($RunListClusters>16) And (Mod($RunListClusters,16)>0)) Then
		 ;may be sparse section at end of Compression Signature
			_ArrayAdd($RUN_Clusters,Mod($RunListClusters,16))
			_ArrayAdd($RUN_VCN,$RunListVCN)
			$RunListClusters -= Mod($RunListClusters,16)
			$r += 1
		ElseIf (($RunListClusters>16) And (Mod($RunListClusters,16)>0)) Then
		 ;may be compressed data section at start of Compression Signature
			_ArrayAdd($RUN_Clusters,$RunListClusters-Mod($RunListClusters,16))
			_ArrayAdd($RUN_VCN,$RunListVCN)
			$RunListVCN += $RUN_Clusters[$r]
			$RunListClusters = Mod($RunListClusters,16)
			$r += 1
		EndIf
	  ;just normal or sparse data
		_ArrayAdd($RUN_Clusters,$RunListClusters)
		_ArrayAdd($RUN_VCN,$RunListVCN)
		$r += 1
		$i += $RunListVCNLength*2
	Until $i > StringLen($DataRun)
EndFunc
#cs
Func _ExtractFile()
	Local $nBytes,$outputpath=""
	$hFile = _WinAPI_CreateFile("\\.\" & $TargetDrive, 2, 6, 6)
	If $hFile = 0 Then
		ConsoleWrite("Error in function _WinAPI_CreateFile when trying to open target drive." & @CRLF)
		_WinAPI_CloseHandle($hFile)
		Return
	EndIf
	If $DATA_Name ="" Then
		$DATA_Name = $FN_Filename
		$DATA_RealSize = $FN_RealSize
	EndIf
	$htest = _WinAPI_CreateFile($outputpath & "\" & $DATA_Name,3,6,7)
	If $htest = 0 Then
		ConsoleWrite("Error in function _WinAPI_CreateFile for: " & $outputpath & "\" & $DATA_Name & @crlf)
		Return
	EndIf
	ConsoleWrite("$htest = " & $htest & @crlf)
	$tBuffer = DllStructCreate("byte[" & $BytesPerCluster * 16 & "]")
	Select
		Case UBound($RUN_VCN) = 1		;no data, do nothing
		Case (UBound($RUN_VCN) = 2) Or (Not $IsCompressed)	;may be normal or sparse
			If $RUN_VCN[1] = $RUN_VCN[0] And $DATA_Name <> "$Boot" Then		;sparse, unless $Boot
				_DoSparse($htest)
			Else								;normal
				_DoNormal($hFile, $htest, $tBuffer)
			EndIf
		Case Else					;may be compressed
			_DoCompressed($hFile, $htest, $tBuffer)
	EndSelect
   ConsoleWrite("Successfully extracted target file: " & $DATA_Name & " to " & $outputpath & "\" & $DATA_Name  & @CRLF)
   _WinAPI_CloseHandle($hFile)
   _WinAPI_CloseHandle($htest)
EndFunc

Func _DoCompressed($hFile, $htest, $tBuffer)
	Local $nBytes
	$r=1
	$FileSize = $DATA_RealSize
	Do
		_WinAPI_SetFilePointerEx($hFile, $RUN_VCN[$r]*$BytesPerCluster, $FILE_BEGIN)
		$i = $RUN_Clusters[$r]
		If (($RUN_VCN[$r+1]=0) And ($i+$RUN_Clusters[$r+1]=16)) Then
			_WinAPI_ReadFile($hFile, DllStructGetPtr($tBuffer), $BytesPerCluster * $i, $nBytes)
			$Decompressed = _LZNTDecompress($tBuffer, $BytesPerCluster * $i)
			If IsString($Decompressed) Then
				ConsoleWrite("Decompression error" & @CRLF)
				Return
			Else		;$Decompressed is an array
				Local $DecompBuffer = DllStructCreate("byte[" & $Decompressed[1] & "]")
				DllStructSetData($DecompBuffer, 1, $Decompressed[0])
			EndIf
			If $FileSize > $Decompressed[1] Then
				_WinAPI_WriteFile($htest, DllStructGetPtr($DecompBuffer), $Decompressed[1], $nBytes)
				$FileSize -= $Decompressed[1]
			Else
				_WinAPI_WriteFile($htest, DllStructGetPtr($DecompBuffer), $FileSize, $nBytes)
			EndIf
			$r += 1
		ElseIf $RUN_VCN[$r]=0 Then
			If Not IsDllStruct($sBuffer) Then _CreateSparseBuffer()
			While $i > 16 And $FileSize > $BytesPerCluster * 16
				_WinAPI_WriteFile($htest, DllStructGetPtr($sBuffer), $BytesPerCluster * 16, $nBytes)
				$i -= 16
				$FileSize -= $BytesPerCluster * 16
			WEnd
			If $i <> 0 Then
				If $FileSize > $BytesPerCluster * $i Then
					_WinAPI_WriteFile($htest, DllStructGetPtr($sBuffer), $BytesPerCluster * $i, $nBytes)
					$FileSize -= $BytesPerCluster * $i
				Else
					_WinAPI_WriteFile($htest, DllStructGetPtr($sBuffer), $FileSize, $nBytes)
				EndIf
			EndIf
		Else
			While $i > 16 And $FileSize > $BytesPerCluster * 16
				_WinAPI_ReadFile($hFile, DllStructGetPtr($tBuffer), $BytesPerCluster * 16, $nBytes)
				_WinAPI_WriteFile($htest, DllStructGetPtr($tBuffer), $BytesPerCluster * 16, $nBytes)
				$i -= 16
				$FileSize -= $BytesPerCluster * 16
			WEnd
			If $i <> 0 Then
				_WinAPI_ReadFile($hFile, DllStructGetPtr($tBuffer), $BytesPerCluster * $i, $nBytes)
				If $FileSize > $BytesPerCluster * $i Then
					_WinAPI_WriteFile($htest, DllStructGetPtr($tBuffer), $BytesPerCluster * $i, $nBytes)
					$FileSize -= $BytesPerCluster * $i
				Else
					_WinAPI_WriteFile($htest, DllStructGetPtr($tBuffer), $FileSize, $nBytes)
				EndIf
			EndIf
		EndIf
		$r += 1
	Until $r > UBound($RUN_VCN)-2
	If $r = UBound($RUN_VCN)-1 Then
		$i = $RUN_Clusters[$r]
		If $RUN_VCN[$r]=0 Then
			If Not IsDllStruct($sBuffer) Then _CreateSparseBuffer()
			While $i > 16 And $FileSize > $BytesPerCluster * 16
				_WinAPI_WriteFile($htest, DllStructGetPtr($sBuffer), $BytesPerCluster * 16, $nBytes)
				$i -= 16
				$FileSize -= $BytesPerCluster * 16
			WEnd
			If $i <> 0 Then
				If $FileSize > $BytesPerCluster * $i Then
					_WinAPI_WriteFile($htest, DllStructGetPtr($sBuffer), $BytesPerCluster * $i, $nBytes)
					$FileSize -= $BytesPerCluster * $i
				Else
					_WinAPI_WriteFile($htest, DllStructGetPtr($sBuffer), $FileSize, $nBytes)
				EndIf
			EndIf
		Else
			While $i > 16 And $FileSize > $BytesPerCluster * 16
				_WinAPI_ReadFile($hFile, DllStructGetPtr($tBuffer), $BytesPerCluster * 16, $nBytes)
				_WinAPI_WriteFile($htest, DllStructGetPtr($tBuffer), $BytesPerCluster * 16, $nBytes)
				$i -= 16
				$FileSize -= $BytesPerCluster * 16
			WEnd
			If $i <> 0 Then
				_WinAPI_ReadFile($hFile, DllStructGetPtr($tBuffer), $BytesPerCluster * $i, $nBytes)
				If $FileSize > $BytesPerCluster * $i Then
					_WinAPI_WriteFile($htest, DllStructGetPtr($tBuffer), $BytesPerCluster * $i, $nBytes)
					$FileSize -= $BytesPerCluster * $i
				Else
					_WinAPI_WriteFile($htest, DllStructGetPtr($tBuffer), $FileSize, $nBytes)
				EndIf
			EndIf
		EndIf
	EndIf
EndFunc

Func _DoNormal($hFile, $htest, $tBuffer)
	Local $nBytes
	$FileSize = $DATA_RealSize
	For $r = 1 To UBound($RUN_VCN)-1
		_WinAPI_SetFilePointerEx($hFile, $RUN_VCN[$r]*$BytesPerCluster, $FILE_BEGIN)
		$i = $RUN_Clusters[$r]
		While $i > 16 And $FileSize > $BytesPerCluster * 16
			_WinAPI_ReadFile($hFile, DllStructGetPtr($tBuffer), $BytesPerCluster * 16, $nBytes)
			_WinAPI_WriteFile($htest, DllStructGetPtr($tBuffer), $BytesPerCluster * 16, $nBytes)
			$i -= 16
			$FileSize -= $BytesPerCluster * 16
		WEnd
		If $i <> 0 Then
			_WinAPI_ReadFile($hFile, DllStructGetPtr($tBuffer), $BytesPerCluster * $i, $nBytes)
			If $FileSize > $BytesPerCluster * $i Then
				_WinAPI_WriteFile($htest, DllStructGetPtr($tBuffer), $BytesPerCluster * $i, $nBytes)
				$FileSize -= $BytesPerCluster * $i
			Else
				_WinAPI_WriteFile($htest, DllStructGetPtr($tBuffer), $FileSize, $nBytes)
				Return
			EndIf
		EndIf
	Next
EndFunc

Func _DoSparse($htest)
	Local $nBytes
	If Not IsDllStruct($sBuffer) Then _CreateSparseBuffer()
	$FileSize = $DATA_RealSize
	For $r = 1 To UBound($RUN_VCN)-1
		$i = $RUN_Clusters[$r]
		While $i > 16 And $FileSize > $BytesPerCluster * 16
			_WinAPI_WriteFile($htest, DllStructGetPtr($sBuffer), $BytesPerCluster * 16, $nBytes)
			$i -= 16
			$FileSize -= $BytesPerCluster * 16
		WEnd
		If $i <> 0 Then
			If $FileSize > $BytesPerCluster * $i Then
				_WinAPI_WriteFile($htest, DllStructGetPtr($sBuffer), $BytesPerCluster * $i, $nBytes)
				$FileSize -= $BytesPerCluster * $i
			Else
				_WinAPI_WriteFile($htest, DllStructGetPtr($sBuffer), $FileSize, $nBytes)
				Return
			EndIf
		EndIf
	Next
EndFunc

Func _CreateSparseBuffer()
	Global $sBuffer = DllStructCreate("byte[" & $BytesPerCluster * 16 & "]")
	For $i = 1 To $BytesPerCluster * 16
		DllStructSetData ($sBuffer, $i, 0)
	Next
EndFunc

Func _LZNTDecompress($tInput, $Size)	;note function returns a null string if error, or an array if no error
	Local $tOutput[2]
	Local $tBuffer = DllStructCreate("byte[" & $BytesPerCluster*16 & "]")
    Local $a_Call = DllCall("ntdll.dll", "int", "RtlDecompressBuffer", _
			"ushort", 2, _
            "ptr", DllStructGetPtr($tBuffer), _
            "dword", DllStructGetSize($tBuffer), _
            "ptr", DllStructGetPtr($tInput), _
            "dword", $Size, _
            "dword*", 0)

    If @error Or $a_Call[0] Then	;if $a_Call[0]=0 then output size is in $a_Call[6], otherwise $a_Call[6] is invalid
        Return SetError(1, 0, "") ; error decompressing
    EndIf
    Local $Decompressed = DllStructCreate("byte[" & $a_Call[6] & "]", DllStructGetPtr($tBuffer))
	$tOutput[0] = DllStructGetData($Decompressed, 1)
	$tOutput[1] = $a_Call[6]
    Return SetError(0, 0, $tOutput)
EndFunc

Func _ExtractResidentFile($Name, $Size)
	Local $nBytes, $outputpath=""
	$hTest = _WinAPI_CreateFile($outputpath & "\" & $Name,3,6,7)
	If $hTest = 0 Then
		ConsoleWrite("Error in function _WinAPI_CreateFile for: " & $outputpath & "\" & $Name & @crlf)
		Return
	EndIf
;	ConsoleWrite("$hTest = " & $hTest & @crlf)
	_WinAPI_SetFilePointer($hTest, 0,$FILE_BEGIN)
	$tBuffer = DllStructCreate("byte[" & $Size & "]")
	DllStructSetData($tBuffer, 1, '0x' & $DataRun)
;	ConsoleWrite("Size of buffer = " & $Size & @crlf)
	_WinAPI_WriteFile($hTest, DllStructGetPtr($tBuffer), $Size, $nBytes)
	_WinAPI_CloseHandle($hTest)
	ConsoleWrite("Successfully extracted target file: " & $Name & " to " & $outputpath & "\" & $Name  & @CRLF)
	ConsoleWrite("Size of extracted " & $Name & " is " & $Size & " bytes" & @CRLF)
EndFunc
#ce
Func _FindFileMFTRecord($TargetFile)
	Local $nBytes, $LocalCounter, $TmpOffset, $Timer, $aa
	$tBuffer = DllStructCreate("byte[" & $MFT_Record_Size & "]")
	$hFile = _WinAPI_CreateFile("\\.\" & $TargetDrive, 2, 6, 6)
	If $hFile = 0 Then
		ConsoleWrite("Error in function _WinAPI_CreateFile when trying to locate target file." & @CRLF)
		_WinAPI_CloseHandle($hFile)
		Return ""
	EndIf
;	ConsoleWrite("Started searching through $MFT for the selected record number " & $TargetFile & " -> " & _DecToLittleEndian($TargetFile) & @CRLF)
	$TargetFile = _DecToLittleEndian($TargetFile)
	For $r = 1 To Ubound($MFT_RUN_VCN)-1
		_WinAPI_SetFilePointerEx($hFile, $MFT_RUN_VCN[$r]*$BytesPerCluster, $FILE_BEGIN)
		For $i = 0 To $MFT_RUN_Clusters[$r]*$BytesPerCluster Step $MFT_Record_Size
			_WinAPI_ReadFile($hFile, DllStructGetPtr($tBuffer), $MFT_Record_Size, $nBytes)
			$record = DllStructGetData($tBuffer, 1)
			If BitAND(Dec(StringMid($record,47,4)),Dec("0100")) AND StringMid($record,91,8) = $TargetFile Then
				ConsoleWrite("Target " & $TargetFile & " found" & @CRLF)
;				$TmpOffset = DllCall('kernel32.dll', 'int', 'SetFilePointerEx', 'ptr', $hFile, 'int64', 0, 'int64*', 0, 'dword', 1)
;				ConsoleWrite("$TmpOffset: " & $TmpOffset & @CRLF)
				_WinAPI_CloseHandle($hFile)
				Return $record		;returns MFT record for file
			EndIf
		Next
	Next
	_WinAPI_CloseHandle($hFile)
	Return ""
EndFunc

Func _FindMFT($TargetFile)
	Local $nBytes
	$tBuffer = DllStructCreate("byte[" & $MFT_Record_Size & "]")
	$hFile = _WinAPI_CreateFile("\\.\" & $TargetDrive, 2, 6, 6)
	If $hFile = 0 Then
		ConsoleWrite("Error in function _WinAPI_CreateFile when trying to locate MFT." & @CRLF)
		Return ""
	EndIf
	_WinAPI_SetFilePointerEx($hFile, $MFT_Offset)
	_WinAPI_ReadFile($hFile, DllStructGetPtr($tBuffer), $MFT_Record_Size, $nBytes)
	_WinAPI_CloseHandle($hFile)
	$record = DllStructGetData($tBuffer, 1)
	If NOT StringMid($record,1,8) = '46494C45' Then
		ConsoleWrite("MFT record signature not found. "& @crlf)
		Return ""
	EndIf
	If StringMid($record,47,4) = "0100" AND Dec(_SwapEndian(StringMid($record,91,8))) = $TargetFile Then
;		ConsoleWrite("MFT record found" & @CRLF)
		Return $record		;returns record for MFT
	EndIf
	ConsoleWrite("MFT record not found" & @CRLF)
	Return ""
EndFunc

Func _DecToLittleEndian($DecimalInput)
	Return _SwapEndian(Hex($DecimalInput,8))
EndFunc

Func _SwapEndian($iHex)
	Return StringMid(Binary(Dec($iHex,2)),3, StringLen($iHex))
EndFunc

Func _UnicodeHexToStr($FileName)
	$str = ""
	For $i = 1 To StringLen($FileName) Step 4
		$str &= ChrW(Dec(_SwapEndian(StringMid($FileName, $i, 4))))
	Next
	Return $str
EndFunc

Func _DebugOut($text, $var)
	ConsoleWrite("Debug output for " & $text & @CRLF)
	For $i=1 To StringLen($var) Step 32
		$str=""
		For $n=0 To 15
			$str &= StringMid($var, $i+$n*2, 2) & " "
			if $n=7 then $str &= "- "
		Next
		ConsoleWrite($str & @CRLF)
	Next
EndFunc

Func _ReadBootSector($TargetDrive)
	Local $nbytes
	$tBuffer=DllStructCreate("byte[512]")
	$hFile = _WinAPI_CreateFile("\\.\" & $TargetDrive,2,2,7)
	If $hFile = 0 then
		ConsoleWrite("Error in function _WinAPI_CreateFile for: " & "\\.\" & $TargetDrive & @crlf)
		Return
	EndIf
	$read = _WinAPI_ReadFile($hFile, DllStructGetPtr($tBuffer), 512, $nBytes)
	If $read = 0 then
		ConsoleWrite("Error in function _WinAPI_ReadFile for: " & "\\.\" & $TargetDrive & @crlf)
		Return
	EndIf
	_WinAPI_CloseHandle($hFile)
   ; Good starting point from KaFu & tranexx at the AutoIt forum
	$tBootSectorSections = DllStructCreate("align 1;" & _
								"byte Jump[3];" & _
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
								"dword Checksum", DllStructGetPtr($tBuffer))

	$BytesPerSector = DllStructGetData($tBootSectorSections, "BytesPerSector")
	$SectorsPerCluster = DllStructGetData($tBootSectorSections, "SectorsPerCluster")
	$BytesPerCluster = $BytesPerSector * $SectorsPerCluster
	$ClustersPerFileRecordSegment = DllStructGetData($tBootSectorSections, "ClustersPerFileRecordSegment")
	$LogicalClusterNumberforthefileMFT = DllStructGetData($tBootSectorSections, "LogicalClusterNumberforthefileMFT")

;	ConsoleWrite("Jump:  " & DllStructGetData($tBootSectorSections, "Jump") & @CRLF)
;	ConsoleWrite("SystemName:  " & DllStructGetData($tBootSectorSections, "SystemName") & @CRLF)
	ConsoleWrite("BytesPerSector:  " & $BytesPerSector & @CRLF)
	ConsoleWrite("SectorsPerCluster:  " & $SectorsPerCluster & @CRLF)
	ConsoleWrite("ReservedSectors:  " & DllStructGetData($tBootSectorSections, "ReservedSectors") & @CRLF)
;	ConsoleWrite("MediaDescriptor:  " & DllStructGetData($tBootSectorSections, "MediaDescriptor") & @CRLF)
	ConsoleWrite("SectorsPerTrack:  " & DllStructGetData($tBootSectorSections, "SectorsPerTrack") & @CRLF)
	ConsoleWrite("NumberOfHeads:  " & DllStructGetData($tBootSectorSections, "NumberOfHeads") & @CRLF)
	ConsoleWrite("HiddenSectors:  " & DllStructGetData($tBootSectorSections, "HiddenSectors") & @CRLF)
	ConsoleWrite("TotalSectors:  " & DllStructGetData($tBootSectorSections, "TotalSectors") & @CRLF)
	ConsoleWrite("LogicalClusterNumberforthefileMFT:  " & $LogicalClusterNumberforthefileMFT & @CRLF)
	ConsoleWrite("LogicalClusterNumberforthefileMFTMirr:  " & DllStructGetData($tBootSectorSections, "LogicalClusterNumberforthefileMFTMirr") & @CRLF)
;	ConsoleWrite("ClustersPerFileRecordSegment:  " & $ClustersPerFileRecordSegment & @CRLF)
;	ConsoleWrite("ClustersPerIndexBlock:  " & DllStructGetData($tBootSectorSections, "ClustersPerIndexBlock") & @CRLF)
;	ConsoleWrite("VolumeSerialNumber:  " & Ptr(DllStructGetData($tBootSectorSections, "NTFSVolumeSerialNumber")) & @CRLF)
;	ConsoleWrite("NTFSVolumeSerialNumber:  " & DllStructGetData($tBootSectorSections, "NTFSVolumeSerialNumber") & @CRLF)
;	ConsoleWrite("Checksum:  " & DllStructGetData($tBootSectorSections, "Checksum") & @CRLF)

	$MFT_Offset = $BytesPerCluster * $LogicalClusterNumberforthefileMFT
;	ConsoleWrite("$MFT_Offset: " & $MFT_Offset & @CRLF)
	If $ClustersPerFileRecordSegment > 127 Then
		$MFT_Record_Size = 2 ^ (256 - $ClustersPerFileRecordSegment)
	Else
		$MFT_Record_Size = $BytesPerCluster * $ClustersPerFileRecordSegment
	EndIf
;	ConsoleWrite("$MFT_Record_Size: " & $MFT_Record_Size & @crlf)
	ConsoleWrite(@CRLF)
EndFunc

Func _SetArrays()
Global $AttributesArr[18][4], $SIArr[13][4], $FNArr[14][1], $RecordHdrArr[15][2], $ObjectIDArr[5][2], $DataArr[20][2], $AttribListArr[9][2], $VolumeNameArr[2][2], $VolumeInformationArr[3][2]
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
$AttribListArr[0][0] = "Description:"
$AttribListArr[1][0] = "Type"
$AttribListArr[2][0] = "Record Lenght"
$AttribListArr[3][0] = "Name Length"
$AttribListArr[4][0] = "Offset to name"
$AttribListArr[5][0] = "Starting VCN"
$AttribListArr[6][0] = "Base file reference"
$AttribListArr[7][0] = "Name"
$AttribListArr[8][0] = "Attribute ID"
$VolumeNameArr[0][0] = "Description:"
$VolumeNameArr[1][0] = "Volume Name"
$VolumeInformationArr[0][0] = "Description:"
$VolumeInformationArr[1][0] = "NTFS Version"
$VolumeInformationArr[2][0] = "Flags"
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

Func _Get_StandardInformation($MFTEntry,$SI_Offset,$SI_Size,$Current_SI_Number)
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

$SIArr[1][$Current_SI_Number] = $SI_HEADER_Flags
$SIArr[2][$Current_SI_Number] = $SI_CTime
$SIArr[3][$Current_SI_Number] = $SI_ATime
$SIArr[4][$Current_SI_Number] = $SI_MTime
$SIArr[5][$Current_SI_Number] = $SI_RTime
$SIArr[6][$Current_SI_Number] = $SI_FilePermission
$SIArr[7][$Current_SI_Number] = $SI_MaxVersions
$SIArr[8][$Current_SI_Number] = $SI_VersionNumber
$SIArr[9][$Current_SI_Number] = $SI_ClassID
$SIArr[10][$Current_SI_Number] = $SI_OwnerID
$SIArr[11][$Current_SI_Number] = $SI_SecurityID
$SIArr[12][$Current_SI_Number] = $SI_USN

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

Func _Set_ObjectID()
$ObjectIDArr[0][1] = "Field value"
$ObjectIDArr[1][1] = $GUID_ObjectID
$ObjectIDArr[2][1] = $GUID_BirthVolumeID
$ObjectIDArr[3][1] = $GUID_BirthObjectID
$ObjectIDArr[4][1] = $GUID_BirthDomainID
EndFunc

Func _Get_VolumeName($MFTEntry,$VOLUME_NAME_Offset,$VOLUME_NAME_Size,$Current_VN_Number)
If $VOLUME_NAME_Size - 24 > 0 Then
	$VOLUME_NAME_NAME = StringMid($MFTEntry,$VOLUME_NAME_Offset+48,($VOLUME_NAME_Size-24)*2)
	$VOLUME_NAME_NAME = _UnicodeHexToStr($VOLUME_NAME_NAME)
;	$VOLUME_NAME_NAME = _HexToString($VOLUME_NAME_NAME)
;	ConsoleWrite("$VOLUME_NAME_NAME = " & $VOLUME_NAME_NAME & @crlf)
	$VolumeNameArr[1][$Current_VN_Number] = $VOLUME_NAME_NAME
	Return
EndIf
$VOLUME_NAME_NAME = "EMPTY"
$VolumeNameArr[1][$Current_VN_Number] = $VOLUME_NAME_NAME
Return
EndFunc

Func _Get_VolumeInformation($MFTEntry,$VOLUME_INFO_Offset,$VOLUME_INFO_Size,$Current_VI_Number)
$VOL_INFO_NTFS_VERSION = Dec(StringMid($MFTEntry,$VOLUME_INFO_Offset+64,2)) & "," & Dec(StringMid($MFTEntry,$VOLUME_INFO_Offset+66,2))
;ConsoleWrite("$VOL_INFO_NTFS_VERSION = " & $VOL_INFO_NTFS_VERSION & @crlf)
$VOL_INFO_FLAGS = StringMid($MFTEntry,$VOLUME_INFO_Offset+68,4)
$VOL_INFO_FLAGS = StringMid($VOL_INFO_FLAGS,3,2) & StringMid($VOL_INFO_FLAGS,1,2)
$VOL_INFO_FLAGS = _VolInfoFlag("0x" & $VOL_INFO_FLAGS)
;ConsoleWrite("$VOL_INFO_FLAGS = " & $VOL_INFO_FLAGS & @crlf)
$VolumeInformationArr[1][$Current_VI_Number] = $VOL_INFO_NTFS_VERSION
$VolumeInformationArr[2][$Current_VI_Number] = $VOL_INFO_FLAGS
Return
EndFunc

Func _SetDataInfo($Current_DATA_Number)
If $DATA_NonResidentFlag = '01' Then
	$DataArr[0][$Current_DATA_Number] = "Data value " & $Current_DATA_Number
	$DataArr[1][$Current_DATA_Number] = $DATA_Length
	$DataArr[2][$Current_DATA_Number] = $DATA_NonResidentFlag
	$DataArr[3][$Current_DATA_Number] = $DATA_NameLength
	$DataArr[4][$Current_DATA_Number] = $DATA_NameRelativeOffset
	$DataArr[5][$Current_DATA_Number] = $DATA_Flags
	$DataArr[6][$Current_DATA_Number] = $DATA_AttributeID
	$DataArr[7][$Current_DATA_Number] = ""
	$DataArr[8][$Current_DATA_Number] = ""
	$DataArr[9][$Current_DATA_Number] = ""
	$DataArr[10][$Current_DATA_Number] = ""
	$DataArr[11][$Current_DATA_Number] = $DATA_StartVCN
	$DataArr[12][$Current_DATA_Number] = $DATA_LastVCN
	$DataArr[13][$Current_DATA_Number] = $DATA_OffsetToDataRuns
	$DataArr[14][$Current_DATA_Number] = $DATA_CompressionUnitSize
	$DataArr[15][$Current_DATA_Number] = $DATA_Padding
	$DataArr[16][$Current_DATA_Number] = $DATA_AllocatedSize
	$DataArr[17][$Current_DATA_Number] = $DATA_RealSize
	$DataArr[18][$Current_DATA_Number] = $DATA_InitializedStreamSize
	$DataArr[19][$Current_DATA_Number] = $DATA_Name_Core
ElseIf $DATA_NonResidentFlag = '00' Then
	$DataArr[0][$Current_DATA_Number] = "Data value " & $Current_DATA_Number
	$DataArr[1][$Current_DATA_Number] = $DATA_Length
	$DataArr[2][$Current_DATA_Number] = $DATA_NonResidentFlag
	$DataArr[3][$Current_DATA_Number] = $DATA_NameLength
	$DataArr[4][$Current_DATA_Number] = $DATA_NameRelativeOffset
	$DataArr[5][$Current_DATA_Number] = $DATA_Flags
	$DataArr[6][$Current_DATA_Number] = $DATA_AttributeID
	$DataArr[7][$Current_DATA_Number] = $DATA_LengthOfAttribute
	$DataArr[8][$Current_DATA_Number] = $DATA_OffsetToAttribute
	$DataArr[9][$Current_DATA_Number] = $DATA_IndexedFlag
	$DataArr[10][$Current_DATA_Number] = $DATA_Padding
	$DataArr[11][$Current_DATA_Number] = ""
	$DataArr[12][$Current_DATA_Number] = ""
	$DataArr[13][$Current_DATA_Number] = ""
	$DataArr[14][$Current_DATA_Number] = ""
	$DataArr[15][$Current_DATA_Number] = ""
	$DataArr[16][$Current_DATA_Number] = ""
	$DataArr[17][$Current_DATA_Number] = ""
	$DataArr[18][$Current_DATA_Number] = ""
	$DataArr[19][$Current_DATA_Number] = $DATA_Name_Core
EndIf
EndFunc

Func _Get_FileName($MFTEntry,$FN_Offset,$FN_Size,$FN_Number)

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

Func _DumpInfo()
Local $NextSector, $TotalSectors
If $cmdline[2] = "-a" Then
	ConsoleWrite(@CRLF)
	ConsoleWrite("Dump of full Record" & @crlf)
	ConsoleWrite(_HexEncode("0x"&$HexDumpRecord[1]) & @crlf)
EndIf
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
If $cmdline[2] = "-a" Then
	ConsoleWrite(@CRLF)
	ConsoleWrite("Dump of Record Header" & @crlf)
	ConsoleWrite(_HexEncode("0x"&$HexDumpHeader[1]) & @crlf)
EndIf
;_ArrayDisplay($HexDumpHeader,"$HexDumpHeader")
$p = 1
If $AttributesArr[1][2] = "TRUE" Then; $STANDARD_INFORMATION
	For $p = 1 To $SI_Number
		ConsoleWrite(@CRLF)
		ConsoleWrite("$STANDARD_INFORMATION " & $p & ":" & @CRLF)
		For $j = 1 To 12
			ConsoleWrite($SIArr[$j][0] & ": " & $SIArr[$j][$p] & @CRLF)
		Next
		If $cmdline[2] = "-a" Then
			ConsoleWrite(@CRLF)
			ConsoleWrite("Dump of $STANDARD_INFORMATION (" & $p & ")" & @crlf)
			ConsoleWrite(_HexEncode("0x"&$HexDumpStandardInformation[$p]) & @crlf)
		EndIf
	Next
;	_ArrayDisplay($HexDumpStandardInformation,"$HexDumpStandardInformation")
EndIf

If $AttributesArr[2][2] = "TRUE"  Then; $ATTRIBUTE_LIST
	ConsoleWrite(@CRLF)
	ConsoleWrite("$ATTRIBUTE_LIST:" & @CRLF)
	If $ALInnerCouner > 0 Then
		For $ALC = 1 To $ALInnerCouner
			ConsoleWrite("Base record: " & $AttribListArr[6][$ALC] & ", Start VCN: " & $AttribListArr[5][$ALC] & ", Type: " & $AttribListArr[1][$ALC] & ", AL Record length: " & $AttribListArr[2][$ALC] & ", Name: " & $AttribListArr[7][$ALC] & ", Attrib ID: " & $AttribListArr[8][$ALC] & @CRLF)
		Next
		ConsoleWrite("" & @crlf)
		ConsoleWrite("Isolated attribute list:" & @crlf)
		ConsoleWrite(_HexEncode("0x"&$IsolatedAttributeList) & @crlf)
	ElseIf $AttribListNonResident = 1 Then
		ConsoleWrite("Sorry, non-resident $ATTRIBUTE_LIST not yet supported in this application" & @crlf)
	Else
		ConsoleWrite("No extra records to inspect.." & @crlf)
	EndIf
;	_ArrayDisplay($HexDumpAttributeList,"$HexDumpAttributeList")
EndIf

If $AttributesArr[3][2] = "TRUE" Then ;$FILE_NAME
	$p = 1
	For $p = 1 To $FN_Number
		ConsoleWrite(@CRLF)
		ConsoleWrite("$FILE_NAME " & $p & ":" & @CRLF)
		For $j = 1 To 13
			ConsoleWrite($FNArr[$j][0] & ": " & $FNArr[$j][$p] & @CRLF)
		Next
		If $cmdline[2] = "-a" Then
			ConsoleWrite(@CRLF)
			ConsoleWrite("Dump of $FILE_NAME (" & $p & ")" & @crlf)
			ConsoleWrite(_HexEncode("0x"&$HexDumpFileName[$p]) & @crlf)
		EndIf
	Next
;	_ArrayDisplay($HexDumpFileName,"$HexDumpFileName")
EndIf

If $AttributesArr[4][2] = "TRUE" Then; $OBJECT_ID
	$p = 1
	For $p = 1 To $OBJID_Number
		ConsoleWrite(@CRLF)
		ConsoleWrite("$OBJECT_ID " & $p & ":" & @CRLF)
		For $j = 1 To 4
			ConsoleWrite($ObjectIDArr[$j][0] & ": " & $ObjectIDArr[$j][$p] & @CRLF)
		Next
		If $cmdline[2] = "-a" Then
			ConsoleWrite(@CRLF)
			ConsoleWrite("Dump of $OBJECT_ID (" & $p & ")" & @crlf)
			ConsoleWrite(_HexEncode("0x"&$HexDumpObjectId[$p]) & @crlf)
		EndIf
	Next
EndIf

If $AttributesArr[5][2] = "TRUE" Then; $SECURITY_DESCRIPTOR
	$p = 1
	For $p = 1 To $SECURITY_Number
		If $cmdline[2] = "-a" Then
			ConsoleWrite(@CRLF)
			ConsoleWrite("Dump of $SECURITY_DESCRIPTOR (" & $p & ")" & @crlf)
			ConsoleWrite(_HexEncode("0x"&$HexDumpSecurityDescriptor[$p]) & @crlf)
		EndIf
	Next
EndIf

If $AttributesArr[6][2] = "TRUE" Then; $VOLUME_NAME
	$p = 1
	For $p = 1 To $VOLNAME_Number
		ConsoleWrite(@CRLF)
		ConsoleWrite("$VOLUME_NAME " & $p & ":" & @CRLF)
		ConsoleWrite($VolumeNameArr[1][0] & ": " & $VolumeNameArr[1][$p] & @CRLF)
		If $cmdline[2] = "-a" Then
			ConsoleWrite(@CRLF)
			ConsoleWrite("Dump of $VOLUME_NAME (" & $p & ")" & @crlf)
			ConsoleWrite(_HexEncode("0x"&$HexDumpVolumeName[$p]) & @crlf)
		EndIf
	Next
EndIf

If $AttributesArr[7][2] = "TRUE" Then; $VOLUME_INFORMATION
	$p = 1
	For $p = 1 To $VOLINFO_Number
		ConsoleWrite(@CRLF)
		ConsoleWrite("$VOLUME_INFORMATION " & $p & ":" & @CRLF)
		For $j = 1 To 2
			ConsoleWrite($VolumeInformationArr[$j][0] & ": " & $VolumeInformationArr[$j][$p] & @CRLF)
		Next
		If $cmdline[2] = "-a" Then
			ConsoleWrite(@CRLF)
			ConsoleWrite("Dump of $VOLUME_INFORMATION (" & $p & ")" & @crlf)
			ConsoleWrite(_HexEncode("0x"&$HexDumpVolumeInformation[$p]) & @crlf)
		EndIf
	Next
EndIf

If $AttributesArr[8][2] = "TRUE" Then; $DATA
	$p = 1
	For $p = 1 To $DATA_Number
		ConsoleWrite(@CRLF)
		ConsoleWrite("$DATA " & $p & ":" & @CRLF)
		For $j = 1 To 19
			ConsoleWrite($DataArr[$j][0] & ": " & $DataArr[$j][$p] & @CRLF)
		Next
		If $cmdline[2] = "-a" Then
			ConsoleWrite(@CRLF)
			ConsoleWrite("Dump of $DATA (" & $p & ")" & @crlf)
			ConsoleWrite(_HexEncode("0x"&$HexDumpData[$p]) & @crlf)
		EndIf
	Next
;	_ArrayDisplay($HexDumpData,"$HexDumpData")
EndIf

If $AttributesArr[9][2] = "TRUE" Then; $INDEX_ROOT
	$p = 1
	For $p = 1 To $INDEXROOT_Number
		If $cmdline[2] = "-a" Then
			ConsoleWrite(@CRLF)
			ConsoleWrite("Dump of $INDEX_ROOT (" & $p & ")" & @crlf)
			ConsoleWrite(_HexEncode("0x"&$HexDumpIndexRoot[$p]) & @crlf)
		EndIf
	Next
EndIf

If $AttributesArr[10][2] = "TRUE" Then; $INDEX_ALLOCATION
	$p = 1
	For $p = 1 To $INDEXALLOC_Number
		If $cmdline[2] = "-a" Then
			ConsoleWrite(@CRLF)
			ConsoleWrite("Dump of $INDEX_ALLOCATION (" & $p & ")" & @crlf)
			ConsoleWrite(_HexEncode("0x"&$HexDumpIndexAllocation[$p]) & @crlf)
		EndIf
	Next
EndIf

If $AttributesArr[11][2] = "TRUE" Then; $BITMAP
	$p = 1
	For $p = 1 To $BITMAP_Number
		If $cmdline[2] = "-a" Then
			ConsoleWrite(@CRLF)
			ConsoleWrite("Dump of $BITMAP (" & $p & ")" & @crlf)
			ConsoleWrite(_HexEncode("0x"&$HexDumpBitmap[$p]) & @crlf)
		EndIf
	Next
EndIf

If $AttributesArr[12][2] = "TRUE" Then; $REPARSE_POINT
	$p = 1
	For $p = 1 To $REPARSEPOINT_Number
		If $cmdline[2] = "-a" Then
			ConsoleWrite(@CRLF)
			ConsoleWrite("Dump of $REPARSE_POINT (" & $p & ")" & @crlf)
			ConsoleWrite(_HexEncode("0x"&$HexDumpReparsePoint[$p]) & @crlf)
		EndIf
	Next
EndIf

If $AttributesArr[13][2] = "TRUE" Then; $EA_INFORMATION
	$p = 1
	For $p = 1 To $EAINFO_Number
		If $cmdline[2] = "-a" Then
			ConsoleWrite(@CRLF)
			ConsoleWrite("Dump of $EA_INFORMATION (" & $p & ")" & @crlf)
			ConsoleWrite(_HexEncode("0x"&$HexDumpEaInformation[$p]) & @crlf)
		EndIf
	Next
EndIf

If $AttributesArr[14][2] = "TRUE" Then; $EA
	$p = 1
	For $p = 1 To $EA_Number
		If $cmdline[2] = "-a" Then
			ConsoleWrite(@CRLF)
			ConsoleWrite("Dump of $EA (" & $p & ")" & @crlf)
			ConsoleWrite(_HexEncode("0x"&$HexDumpEaInformation[$p]) & @crlf)
		EndIf
	Next
EndIf

If $AttributesArr[15][2] = "TRUE" Then; $PROPERTY_SET
	$p = 1
	For $p = 1 To $PROPERTYSET_Number
		If $cmdline[2] = "-a" Then
			ConsoleWrite(@CRLF)
			ConsoleWrite("Dump of $PROPERTY_SET (" & $p & ")" & @crlf)
			ConsoleWrite(_HexEncode("0x"&$HexDumpPropertySet[$p]) & @crlf)
		EndIf
	Next
EndIf

If $AttributesArr[16][2] = "TRUE" Then; $LOGGED_UTILITY_STREAM
	$p = 1
	For $p = 1 To $LOGGEDUTILSTREAM_Number
		If $cmdline[2] = "-a" Then
			ConsoleWrite(@CRLF)
			ConsoleWrite("Dump of $LOGGED_UTILITY_STREAM (" & $p & ")" & @crlf)
			ConsoleWrite(_HexEncode("0x"&$HexDumpLoggedUtilityStream[$p]) & @crlf)
		EndIf
	Next
EndIf

; Record slack data
;_ArrayDisplay($HexDumpRecordSlack,"$HexDumpRecordSlack")
If $cmdline[2] = "-a" Then
	ConsoleWrite(@CRLF)
	ConsoleWrite("Dump of Record slack for base record" & @crlf)
	ConsoleWrite(_HexEncode("0x"&$HexDumpRecordSlack[1]) & @crlf)
EndIf
EndFunc

Func _GenMftArray($DiskHandle,$TheCounter,$RecNumber)
If $TheCounter < 65530 Then
	$TmpOffset = DllCall('kernel32.dll', 'int', 'SetFilePointerEx', 'ptr', $DiskHandle, 'int64', 0, 'int64*', 0, 'dword', 1)
	$MFTRecordsArr1[$TheCounter][0] = $RecNumber
	$MFTRecordsArr1[$TheCounter][1] = $TmpOffset[3]
EndIf
If $TheCounter > 65530 and $TheCounter < 131060 Then
	$ArrOffset = $TheCounter-65530
	$TmpOffset = DllCall('kernel32.dll', 'int', 'SetFilePointerEx', 'ptr', $DiskHandle, 'int64', 0, 'int64*', 0, 'dword', 1)
	$MFTRecordsArr2[$ArrOffset][0] = $RecNumber;StringMid($record,91,8)
	$MFTRecordsArr2[$ArrOffset][1] = $TmpOffset[3]
EndIf
If $TheCounter > 131060 and $TheCounter < 196590 Then
	$ArrOffset = $TheCounter-131060
	$TmpOffset = DllCall('kernel32.dll', 'int', 'SetFilePointerEx', 'ptr', $DiskHandle, 'int64', 0, 'int64*', 0, 'dword', 1)
	$MFTRecordsArr3[$ArrOffset][0] = $RecNumber;StringMid($record,91,8)
	$MFTRecordsArr3[$ArrOffset][1] = $TmpOffset[3]
EndIf
If $TheCounter > 196590 and $TheCounter < 262120 Then
	$ArrOffset = $TheCounter-196590
	$TmpOffset = DllCall('kernel32.dll', 'int', 'SetFilePointerEx', 'ptr', $DiskHandle, 'int64', 0, 'int64*', 0, 'dword', 1)
	$MFTRecordsArr4[$ArrOffset][0] = $RecNumber;StringMid($record,91,8)
	$MFTRecordsArr4[$ArrOffset][1] = $TmpOffset[3]
EndIf
If $TheCounter > 262120 and $TheCounter < 327650 Then
	$ArrOffset = $TheCounter-262120
	$TmpOffset = DllCall('kernel32.dll', 'int', 'SetFilePointerEx', 'ptr', $DiskHandle, 'int64', 0, 'int64*', 0, 'dword', 1)
	$MFTRecordsArr5[$ArrOffset][0] = $RecNumber;StringMid($record,91,8)
	$MFTRecordsArr5[$ArrOffset][1] = $TmpOffset[3]
EndIf
If $TheCounter > 327650 and $TheCounter < 393180 Then
	$ArrOffset = $TheCounter-327650
	$TmpOffset = DllCall('kernel32.dll', 'int', 'SetFilePointerEx', 'ptr', $DiskHandle, 'int64', 0, 'int64*', 0, 'dword', 1)
	$MFTRecordsArr6[$ArrOffset][0] = $RecNumber;StringMid($record,91,8)
	$MFTRecordsArr6[$ArrOffset][1] = $TmpOffset[3]
EndIf
If $TheCounter > 393180 and $TheCounter < 458710 Then
	$ArrOffset = $TheCounter-393180
	$TmpOffset = DllCall('kernel32.dll', 'int', 'SetFilePointerEx', 'ptr', $DiskHandle, 'int64', 0, 'int64*', 0, 'dword', 1)
	$MFTRecordsArr7[$ArrOffset][0] = $RecNumber;StringMid($record,91,8)
	$MFTRecordsArr7[$ArrOffset][1] = $TmpOffset[3]
EndIf
If $TheCounter > 458710 and $TheCounter < 524240 Then
	$ArrOffset = $TheCounter-458710
	$TmpOffset = DllCall('kernel32.dll', 'int', 'SetFilePointerEx', 'ptr', $DiskHandle, 'int64', 0, 'int64*', 0, 'dword', 1)
	$MFTRecordsArr8[$ArrOffset][0] = $RecNumber;StringMid($record,91,8)
	$MFTRecordsArr8[$ArrOffset][1] = $TmpOffset[3]
EndIf
If $TheCounter > 524240 and $TheCounter < 589770 Then
	$ArrOffset = $TheCounter-524240
	$TmpOffset = DllCall('kernel32.dll', 'int', 'SetFilePointerEx', 'ptr', $DiskHandle, 'int64', 0, 'int64*', 0, 'dword', 1)
	$MFTRecordsArr9[$ArrOffset][0] = $RecNumber;StringMid($record,91,8)
	$MFTRecordsArr9[$ArrOffset][1] = $TmpOffset[3]
EndIf
If $TheCounter > 589770 and $TheCounter < 655300 Then
	$ArrOffset = $TheCounter-589770
	$TmpOffset = DllCall('kernel32.dll', 'int', 'SetFilePointerEx', 'ptr', $DiskHandle, 'int64', 0, 'int64*', 0, 'dword', 1)
	$MFTRecordsArr10[$ArrOffset][0] = $RecNumber;StringMid($record,91,8)
	$MFTRecordsArr10[$ArrOffset][1] = $TmpOffset[3]
EndIf
If $TheCounter > 655300 and $TheCounter < 720830 Then
	$ArrOffset = $TheCounter-655300
	$TmpOffset = DllCall('kernel32.dll', 'int', 'SetFilePointerEx', 'ptr', $DiskHandle, 'int64', 0, 'int64*', 0, 'dword', 1)
	$MFTRecordsArr11[$ArrOffset][0] = $RecNumber;StringMid($record,91,8)
	$MFTRecordsArr11[$ArrOffset][1] = $TmpOffset[3]
EndIf
If $TheCounter > 720830 and $TheCounter < 786360 Then
	$ArrOffset = $TheCounter-720830
	$TmpOffset = DllCall('kernel32.dll', 'int', 'SetFilePointerEx', 'ptr', $DiskHandle, 'int64', 0, 'int64*', 0, 'dword', 1)
	$MFTRecordsArr12[$ArrOffset][0] = $RecNumber;StringMid($record,91,8)
	$MFTRecordsArr12[$ArrOffset][1] = $TmpOffset[3]
EndIf
If $TheCounter > 786360 and $TheCounter < 851890 Then
	$ArrOffset = $TheCounter-786360
	$TmpOffset = DllCall('kernel32.dll', 'int', 'SetFilePointerEx', 'ptr', $DiskHandle, 'int64', 0, 'int64*', 0, 'dword', 1)
	$MFTRecordsArr13[$ArrOffset][0] = $RecNumber;StringMid($record,91,8)
	$MFTRecordsArr13[$ArrOffset][1] = $TmpOffset[3]
EndIf
If $TheCounter > 851890 and $TheCounter < 917420 Then
	$ArrOffset = $TheCounter-851890
	$TmpOffset = DllCall('kernel32.dll', 'int', 'SetFilePointerEx', 'ptr', $DiskHandle, 'int64', 0, 'int64*', 0, 'dword', 1)
	$MFTRecordsArr14[$ArrOffset][0] = $RecNumber;StringMid($record,91,8)
	$MFTRecordsArr14[$ArrOffset][1] = $TmpOffset[3]
EndIf
If $TheCounter > 917420 and $TheCounter < 982950 Then
	$ArrOffset = $TheCounter-917420
	$TmpOffset = DllCall('kernel32.dll', 'int', 'SetFilePointerEx', 'ptr', $DiskHandle, 'int64', 0, 'int64*', 0, 'dword', 1)
	$MFTRecordsArr15[$ArrOffset][0] = $RecNumber;StringMid($record,91,8)
	$MFTRecordsArr15[$ArrOffset][1] = $TmpOffset[3]
EndIf
If $TheCounter > 982950 and $TheCounter < 1048480 Then
	$ArrOffset = $TheCounter-982950
	$TmpOffset = DllCall('kernel32.dll', 'int', 'SetFilePointerEx', 'ptr', $DiskHandle, 'int64', 0, 'int64*', 0, 'dword', 1)
	$MFTRecordsArr16[$ArrOffset][0] = $RecNumber;StringMid($record,91,8)
	$MFTRecordsArr16[$ArrOffset][1] = $TmpOffset[3]
EndIf
If $TheCounter > 1048480 and $TheCounter < 1114010 Then
	$ArrOffset = $TheCounter-1048480
	$TmpOffset = DllCall('kernel32.dll', 'int', 'SetFilePointerEx', 'ptr', $DiskHandle, 'int64', 0, 'int64*', 0, 'dword', 1)
	$MFTRecordsArr17[$ArrOffset][0] = $RecNumber;StringMid($record,91,8)
	$MFTRecordsArr17[$ArrOffset][1] = $TmpOffset[3]
EndIf
If $TheCounter > 1114010 and $TheCounter < 1179540 Then
	$ArrOffset = $TheCounter-1114010
	$TmpOffset = DllCall('kernel32.dll', 'int', 'SetFilePointerEx', 'ptr', $DiskHandle, 'int64', 0, 'int64*', 0, 'dword', 1)
	$MFTRecordsArr18[$ArrOffset][0] = $RecNumber;StringMid($record,91,8)
	$MFTRecordsArr18[$ArrOffset][1] = $TmpOffset[3]
EndIf
If $TheCounter > 1179540 and $TheCounter < 1245070 Then
	$ArrOffset = $TheCounter-1179540
	$TmpOffset = DllCall('kernel32.dll', 'int', 'SetFilePointerEx', 'ptr', $DiskHandle, 'int64', 0, 'int64*', 0, 'dword', 1)
	$MFTRecordsArr19[$ArrOffset][0] = $RecNumber;StringMid($record,91,8)
	$MFTRecordsArr19[$ArrOffset][1] = $TmpOffset[3]
EndIf
If $TheCounter > 1245070 and $TheCounter < 1310600 Then
	$ArrOffset = $TheCounter-1245070
	$TmpOffset = DllCall('kernel32.dll', 'int', 'SetFilePointerEx', 'ptr', $DiskHandle, 'int64', 0, 'int64*', 0, 'dword', 1)
	$MFTRecordsArr20[$ArrOffset][0] = $RecNumber;StringMid($record,91,8)
	$MFTRecordsArr20[$ArrOffset][1] = $TmpOffset[3]
EndIf
EndFunc

Func _SearchMftArray($TargetMftRecord)
	$SearchResult = _ArraySearch($MFTRecordsArr1, $TargetMftRecord)
;	ConsoleWrite("Index: " & $SearchResult & @crlf)
	If $SearchResult <> -1 Then
		Return $MFTRecordsArr1[$SearchResult][1]
	EndIf
	$SearchResult = _ArraySearch($MFTRecordsArr2, $TargetMftRecord)
;	ConsoleWrite("Index: " & $SearchResult & @crlf)
	If $SearchResult <> -1 Then
		Return $MFTRecordsArr2[$SearchResult][1]
	EndIf
	$SearchResult = _ArraySearch($MFTRecordsArr3, $TargetMftRecord)
;	ConsoleWrite("Index: " & $SearchResult & @crlf)
	If $SearchResult <> -1 Then
		Return $MFTRecordsArr3[$SearchResult][1]
	EndIf
	$SearchResult = _ArraySearch($MFTRecordsArr4, $TargetMftRecord)
;	ConsoleWrite("Index: " & $SearchResult & @crlf)
	If $SearchResult <> -1 Then
		Return $MFTRecordsArr4[$SearchResult][1]
	EndIf
	$SearchResult = _ArraySearch($MFTRecordsArr5, $TargetMftRecord)
;	ConsoleWrite("Index: " & $SearchResult & @crlf)
	If $SearchResult <> -1 Then
		Return $MFTRecordsArr5[$SearchResult][1]
	EndIf
	$SearchResult = _ArraySearch($MFTRecordsArr6, $TargetMftRecord)
;	ConsoleWrite("Index: " & $SearchResult & @crlf)
	If $SearchResult <> -1 Then
		Return $MFTRecordsArr6[$SearchResult][1]
	EndIf
	$SearchResult = _ArraySearch($MFTRecordsArr7, $TargetMftRecord)
;	ConsoleWrite("Index: " & $SearchResult & @crlf)
	If $SearchResult <> -1 Then
		Return $MFTRecordsArr7[$SearchResult][1]
	EndIf
	$SearchResult = _ArraySearch($MFTRecordsArr8, $TargetMftRecord)
;	ConsoleWrite("Index: " & $SearchResult & @crlf)
	If $SearchResult <> -1 Then
		Return $MFTRecordsArr8[$SearchResult][1]
	EndIf
	$SearchResult = _ArraySearch($MFTRecordsArr9, $TargetMftRecord)
;	ConsoleWrite("Index: " & $SearchResult & @crlf)
	If $SearchResult <> -1 Then
		Return $MFTRecordsArr9[$SearchResult][1]
	EndIf
	$SearchResult = _ArraySearch($MFTRecordsArr10, $TargetMftRecord)
;	ConsoleWrite("Index: " & $SearchResult & @crlf)
	If $SearchResult <> -1 Then
		Return $MFTRecordsArr10[$SearchResult][1]
	EndIf
	$SearchResult = _ArraySearch($MFTRecordsArr11, $TargetMftRecord)
;	ConsoleWrite("Index: " & $SearchResult & @crlf)
	If $SearchResult <> -1 Then
		Return $MFTRecordsArr11[$SearchResult][1]
	EndIf
	$SearchResult = _ArraySearch($MFTRecordsArr12, $TargetMftRecord)
;	ConsoleWrite("Index: " & $SearchResult & @crlf)
	If $SearchResult <> -1 Then
		Return $MFTRecordsArr12[$SearchResult][1]
	EndIf
	$SearchResult = _ArraySearch($MFTRecordsArr13, $TargetMftRecord)
;	ConsoleWrite("Index: " & $SearchResult & @crlf)
	If $SearchResult <> -1 Then
		Return $MFTRecordsArr13[$SearchResult][1]
	EndIf
	$SearchResult = _ArraySearch($MFTRecordsArr14, $TargetMftRecord)
;	ConsoleWrite("Index: " & $SearchResult & @crlf)
	If $SearchResult <> -1 Then
		Return $MFTRecordsArr14[$SearchResult][1]
	EndIf
	$SearchResult = _ArraySearch($MFTRecordsArr15, $TargetMftRecord)
;	ConsoleWrite("Index: " & $SearchResult & @crlf)
	If $SearchResult <> -1 Then
		Return $MFTRecordsArr15[$SearchResult][1]
	EndIf
	$SearchResult = _ArraySearch($MFTRecordsArr16, $TargetMftRecord)
;	ConsoleWrite("Index: " & $SearchResult & @crlf)
	If $SearchResult <> -1 Then
		Return $MFTRecordsArr16[$SearchResult][1]
	EndIf
	$SearchResult = _ArraySearch($MFTRecordsArr17, $TargetMftRecord)
;	ConsoleWrite("Index: " & $SearchResult & @crlf)
	If $SearchResult <> -1 Then
		Return $MFTRecordsArr17[$SearchResult][1]
	EndIf
	$SearchResult = _ArraySearch($MFTRecordsArr18, $TargetMftRecord)
;	ConsoleWrite("Index: " & $SearchResult & @crlf)
	If $SearchResult <> -1 Then
		Return $MFTRecordsArr18[$SearchResult][1]
	EndIf
	$SearchResult = _ArraySearch($MFTRecordsArr19, $TargetMftRecord)
;	ConsoleWrite("Index: " & $SearchResult & @crlf)
	If $SearchResult <> -1 Then
		Return $MFTRecordsArr19[$SearchResult][1]
	EndIf
	$SearchResult = _ArraySearch($MFTRecordsArr20, $TargetMftRecord)
;	ConsoleWrite("Index: " & $SearchResult & @crlf)
	If $SearchResult <> -1 Then
		Return $MFTRecordsArr20[$SearchResult][1]
	EndIf
	Return SetError(1, 0, 0)
EndFunc

Func _InitiateMftArray()
	Local $nBytes, $LocalCounter
	ConsoleWrite("Processing $MFT..." & @CRLF)
	$tBuffer = DllStructCreate("byte[" & $MFT_Record_Size & "]")
	$hFile = _WinAPI_CreateFile("\\.\" & $TargetDrive, 2, 6, 6)
	If $hFile = 0 Then
		ConsoleWrite("Error in function _WinAPI_CreateFile when building MFT array." & @CRLF)
		_WinAPI_CloseHandle($hFile)
		Return SetError(1, 0, 0)
	EndIf
	If $MFTSize > 1342054400 Then
		ConsoleWrite("Warning: $MFT is too large to fit in the arrays" & @CRLF)
		Return SetError(1, 0, 0)
	EndIf
	$LocalCounter = 0
	For $r = 1 To Ubound($MFT_RUN_VCN)-1
		_WinAPI_SetFilePointerEx($hFile, $MFT_RUN_VCN[$r]*$BytesPerCluster, $FILE_BEGIN)
		For $i = 0 To $MFT_RUN_Clusters[$r]*$BytesPerCluster Step $MFT_Record_Size
			_WinAPI_ReadFile($hFile, DllStructGetPtr($tBuffer), $MFT_Record_Size, $nBytes)
			$record = DllStructGetData($tBuffer, 1)
			_GenMftArray($hFile,$LocalCounter,StringMid($record,91,8))
			$LocalCounter += 1
		Next
	Next
	_WinAPI_CloseHandle($hFile)
EndFunc

Func _ProcessMftArray($TargetFile)
	Local $nBytes
	$tBuffer = DllStructCreate("byte[" & $MFT_Record_Size & "]")
	$hFile = _WinAPI_CreateFile("\\.\" & $TargetDrive, 2, 6, 6)
	If $hFile = 0 Then
		ConsoleWrite("Error in function _WinAPI_CreateFile when trying to locate target file." & @CRLF)
		_WinAPI_CloseHandle($hFile)
		Return ""
	EndIf
	ConsoleWrite("Searching through the $MFT arrays for the selected record number " & $TargetFile & " -> " & _DecToLittleEndian($TargetFile) & @CRLF)
	$TargetFile = _DecToLittleEndian($TargetFile)
	$LocalMftSearch = _SearchMftArray($TargetFile)
	If @error Then
		ConsoleWrite("Error: could not find target file in the MFT arrays" & @CRLF)
		Return ""
	EndIf
	_WinAPI_SetFilePointerEx($hFile, $LocalMftSearch-1024, $FILE_BEGIN)
	_WinAPI_ReadFile($hFile, DllStructGetPtr($tBuffer), $MFT_Record_Size, $nBytes)
	$record = DllStructGetData($tBuffer, 1)
;	ConsoleWrite(_HexEncode($record) & @crlf)
;	$TmpOffset = DllCall('kernel32.dll', 'int', 'SetFilePointerEx', 'ptr', $hFile, 'int64', 0, 'int64*', 0, 'dword', 1)
;	ConsoleWrite("$TmpOffset: " & $TmpOffset[3] & @CRLF)
	If BitAND(Dec(StringMid($record,47,4)),Dec("0100")) AND StringMid($record,91,8) = $TargetFile Then
		ConsoleWrite("Target " & $TargetFile & " found" & @CRLF)
		_WinAPI_CloseHandle($hFile)
		Return $record		;returns MFT record for file
	EndIf
	_WinAPI_CloseHandle($hFile)
	Return ""
EndFunc