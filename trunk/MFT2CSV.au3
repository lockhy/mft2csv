#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_UseX64=y
#AutoIt3Wrapper_Res_Description=Decode $MFT and write to CSV
#AutoIt3Wrapper_Res_Fileversion=1.0.0.7
#AutoIt3Wrapper_Res_requestedExecutionLevel=asInvoker
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
#include <winapi.au3>
#include <String.au3>
#include "_WinTimeFunctions2.au3";Ascend4nt
#include <Date.au3>
; http://code.google.com/p/mft2csv/
; by Joakim Schicht
Global $HEADER_LSN, $HEADER_SequenceNo, $HEADER_Flags, $HEADER_RecordRealSize, $HEADER_RecordAllocSize, $HEADER_FileRef, $HEADER_NextAttribID, $HEADER_MFTREcordNumber
Global $SI_CTime, $SI_ATime, $SI_MTime, $SI_RTime, $SI_FilePermission, $SI_USN, $Errors, $DATA_AllocatedSize, $DATA_RealSize, $DATA_InitializedStreamSize, $RecordSlackSpace
Global $FN_CTime, $FN_ATime, $FN_MTime, $FN_RTime, $FN_AllocSize, $FN_RealSize, $FN_Flags, $FN_FileName, $DATA_VCNs, $DATA_NonResidentFlag, $FN_NameType
Global $FN_CTime_2, $FN_ATime_2, $FN_MTime_2, $FN_RTime_2, $FN_AllocSize_2, $FN_RealSize_2, $FN_Flags_2, $FN_NameLength_2, $FN_NameSpace_2, $FN_FileName_2, $FN_NameType_2
Global $FN_CTime_3, $FN_ATime_3, $FN_MTime_3, $FN_RTime_3, $FN_AllocSize_3, $FN_RealSize_3, $FN_Flags_3, $FN_NameLength_3, $FN_NameSpace_3, $FN_FileName_3, $FN_NameType_3
Global $FN_CTime_4, $FN_ATime_4, $FN_MTime_4, $FN_RTime_4, $FN_AllocSize_4, $FN_RealSize_4, $FN_Flags_4, $FN_NameLength_4, $FN_NameSpace_4, $FN_FileName_4, $FN_NameType_4
Global $DATA_NameLength, $DATA_NameRelativeOffset, $DATA_Flags, $DATA_NameSpace, $DATA_Name, $RecordActive, $DATA_CompressionUnitSize, $DATA_CompressionUnitSize_2, $DATA_CompressionUnitSize_3
Global $DATA_NonResidentFlag_2, $DATA_NameLength_2, $DATA_NameRelativeOffset_2, $DATA_Flags_2, $DATA_NameSpace_2, $DATA_Name_2, $DATA_StartVCN_2, $DATA_LastVCN_2, $DATA_VCNs_2, $DATA_AllocatedSize_2, $DATA_RealSize_2, $DATA_InitializedStreamSize_2
Global $DATA_NonResidentFlag_3, $DATA_NameLength_3, $DATA_NameRelativeOffset_3, $DATA_Flags_3, $DATA_NameSpace_3, $DATA_Name_3, $DATA_StartVCN_3, $DATA_LastVCN_3, $DATA_VCNs_3, $DATA_AllocatedSize_3, $DATA_RealSize_3, $DATA_InitializedStreamSize_3
Global $FN_ParentReferenceNo, $FN_ParentSequenceNo, $FN_ParentReferenceNo_2, $FN_ParentSequenceNo_2, $FN_ParentReferenceNo_3, $FN_ParentSequenceNo_3, $FN_ParentReferenceNo_4, $FN_ParentSequenceNo_4, $RecordHealth
Global $DATA_LengthOfAttribute, $DATA_OffsetToAttribute, $DATA_IndexedFlag, $DATA_LengthOfAttribute_2, $DATA_OffsetToAttribute_2, $DATA_IndexedFlag_2, $DATA_LengthOfAttribute_3, $DATA_OffsetToAttribute_3, $DATA_IndexedFlag_3
Global $hFile, $nBytes, $MSecTest, $CTimeTest, $SI_MaxVersions, $SI_VersionNumber, $SI_ClassID, $SI_OwnerID, $SI_SecurityID, $SI_HEADER_Flags, $STANDARD_INFORMATION_ON, $ATTRIBUTE_LIST_ON, $FILE_NAME_ON, $OBJECT_ID_ON, $SECURITY_DESCRIPTOR_ON, $VOLUME_NAME_ON, $VOLUME_INFORMATION_ON, $DATA_ON, $INDEX_ROOT_ON, $INDEX_ALLOCATION_ON, $BITMAP_ON, $REPARSE_POINT_ON, $EA_INFORMATION_ON, $EA_ON, $PROPERTY_SET_ON, $LOGGED_UTILITY_STREAM_ON
Global $GUID_ObjectID, $GUID_BirthVolumeID, $GUID_BirthObjectID, $GUID_BirthDomainID, $VOLUME_NAME_NAME, $VOL_INFO_NTFS_VERSION, $VOL_INFO_FLAGS, $INVALID_FILENAME, $INVALID_FILENAME_2, $INVALID_FILENAME_3, $DATA_Number
Global $FileSizeBytes, $IntegrityCheck
Global Const $HX_REF = "0123456789ABCDEF"
Global Const $RecordSignature = '46494C45' ; FILE signature
Global Const $RecordSignatureBad = '44414142' ; BAAD signature
Global Const $MFT_Record_Size = 1024
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
Global Const $FILE_RECORD_FLAG_FILE_DELETE = 0x0000
Global Const $FILE_RECORD_FLAG_FILE = 0x0001
Global Const $FILE_RECORD_FLAG_DIRECTORY = 0x0003
Global Const $FILE_RECORD_FLAG_DIRECTORY_DELETE = 0x0002
Global Const $FILE_RECORD_FLAG_UNKNOWN1 = 0x0004
Global Const $FILE_RECORD_FLAG_UNKNOWN2 = 0x0008
Global $DateTimeFormat = 6 ; YYYY-MM-DD HH:MM:SS:MSMSMS:NSNSNSNS = 2007-08-18 08:15:37:733:1234
; time + $tDelta (bias) = UTC
;Global $tDelta = _WinTime_GetLocalToUTCFileTimeDelta()
Global $tDelta = _WinTime_GetUTCToLocalFileTimeDelta() ; in offline mode we must read the values off the registry..
$tBuffer = DllStructCreate("byte[" & $MFT_Record_Size & "]")
$inFile = FileOpenDialog("Select your $MFT", @ScriptDir, "All (*.*)")
If @error Then Exit
$csv = FileSaveDialog("Choose a csv name.", @ScriptDir, "All (*.csv)", 2, "MFTdump.csv")
If @error Then Exit
$csv = FileOpen($csv, 1)
If @error Then Exit
$UTCBox = MsgBox(3, "Timestamp Configuration", "Set timestamps in UTC 00:00? (recommended)")
If @error Then Exit
If $UTCBox = 6 Then $UTCconfig = "UTC 00:00"
If $UTCBox = 7 Then $UTCconfig = "Local time"

FileWriteLine($csv, "#	Timestamps presented in " & $UTCconfig & @CRLF)
FileWriteLine($csv, "#	Current timezone configuration (bias) including adjustment for any laylight saving = " & $tDelta / 36000000000 & " hours" & @CRLF)
$csv_header = 'RecordOffset,Signature,IntegrityCheck,HEADER_MFTREcordNumber,HEADER_SequenceNo,FN_ParentReferenceNo,FN_ParentSequenceNo,FN_FileName,HEADER_Flags,RecordActive,FileSizeBytes,INVALID_FILENAME,SI_FilePermission,FN_Flags,FN_NameType,ADS,SI_CTime,SI_ATime,SI_MTime,SI_RTime,MSecTest,'
$csv_header &= 'FN_CTime,FN_ATime,FN_MTime,FN_RTime,CTimeTest,FN_AllocSize,FN_RealSize,SI_USN,DATA_Name,DATA_Flags,DATA_LengthOfAttribute,DATA_IndexedFlag,DATA_VCNs,DATA_NonResidentFlag,DATA_CompressionUnitSize,HEADER_LSN,HEADER_RecordRealSize,'
$csv_header &= 'HEADER_RecordAllocSize,HEADER_FileRef,HEADER_NextAttribID,DATA_AllocatedSize,DATA_RealSize,DATA_InitializedStreamSize,SI_HEADER_Flags,SI_MaxVersions,SI_VersionNumber,SI_ClassID,SI_OwnerID,SI_SecurityID,FN_CTime_2,FN_ATime_2,FN_MTime_2,'
$csv_header &= 'FN_RTime_2,FN_AllocSize_2,FN_RealSize_2,FN_Flags_2,FN_NameLength_2,FN_NameType_2,FN_FileName_2,INVALID_FILENAME_2,GUID_ObjectID,GUID_BirthVolumeID,GUID_BirthObjectID,GUID_BirthDomainID,VOLUME_NAME_NAME,VOL_INFO_NTFS_VERSION,VOL_INFO_FLAGS,FN_CTime_3,FN_ATime_3,FN_MTime_3,FN_RTime_3,FN_AllocSize_3,FN_RealSize_3,FN_Flags_3,FN_NameLength_3,FN_NameType_3,FN_FileName_3,INVALID_FILENAME_3,FN_CTime_4,'
$csv_header &= 'FN_ATime_4,FN_MTime_4,FN_RTime_4,FN_AllocSize_4,FN_RealSize_4,FN_Flags_4,FN_NameLength_4,FN_NameType_4,FN_FileName_4,DATA_Name_2,DATA_NonResidentFlag_2,DATA_Flags_2,DATA_LengthOfAttribute_2,DATA_IndexedFlag_2,DATA_StartVCN_2,DATA_LastVCN_2,'
$csv_header &= 'DATA_VCNs_2,DATA_CompressionUnitSize_2,DATA_AllocatedSize_2,DATA_RealSize_2,DATA_InitializedStreamSize_2,DATA_Name_3,DATA_NonResidentFlag_3,DATA_Flags_3,DATA_LengthOfAttribute_3,DATA_IndexedFlag_3,DATA_StartVCN_3,DATA_LastVCN_3,DATA_VCNs_3,'
$csv_header &= 'DATA_CompressionUnitSize_3,DATA_AllocatedSize_3,DATA_RealSize_3,DATA_InitializedStreamSize_3,STANDARD_INFORMATION_ON,ATTRIBUTE_LIST_ON,FILE_NAME_ON,OBJECT_ID_ON,SECURITY_DESCRIPTOR_ON,VOLUME_NAME_ON,VOLUME_INFORMATION_ON,DATA_ON,INDEX_ROOT_ON,INDEX_ALLOCATION_ON,BITMAP_ON,REPARSE_POINT_ON,EA_INFORMATION_ON,EA_ON,PROPERTY_SET_ON,LOGGED_UTILITY_STREAM_ON'
FileWriteLine($csv, $csv_header & @CRLF)
If $UTCBox = 7 Then $tDelta = 0
ProgressOn("$MFT parser in progress", "Opening file.", "", -1, -1, 16)
$begin = TimerInit()
ConsoleWrite("$inFile = " & $inFile & @CRLF)
$hFile = _WinAPI_CreateFile($inFile, 2, 6, 6)
ConsoleWrite("$hFile " & $hFile & @CRLF)
$MFTSize = FileGetSize($inFile)
ConsoleWrite("$MFTSize = " & $MFTSize & @CRLF)
$ExpectedRecords = $MFTSize / $MFT_Record_Size
ConsoleWrite("$ExpectedRecords = " & $ExpectedRecords & @CRLF)

AdlibRegister("_DisplayProgress")

For $i = 0 To $ExpectedRecords
	$RecordOffsetDec = $MFT_Record_Size * $i
;~ 	ProgressSet(Round((($i/$ExpectedRecords)*100), 2),Round(($i/$ExpectedRecords)*100, 2) & "  % finished with exporting $MFT data to csv", Round($i/(TimerDiff($begin)/1000),1) & " Records per second.")
	;	ConsoleWrite("MFT Table Record "& $i & @crlf)
	_WinAPI_SetFilePointerEx($hFile, $RecordOffsetDec)
	_WinAPI_ReadFile($hFile, DllStructGetPtr($tBuffer), $MFT_Record_Size, $nBytes)
	$MFTEntry = DllStructGetData($tBuffer, 1)
	If (StringMid($MFTEntry, 3, 8) = '46494C45') Then
		$Signature = "GOOD"
		;		ConsoleWrite("Signature not found here.. "& @crlf)
	ElseIf (StringMid($MFTEntry, 3, 8) = '44414142') Then
		$Signature = "BAAD"
	ElseIf (StringMid($MFTEntry, 3, 8) = '00000000') Then
		_ClearVar()
		$Signature = "ZERO"
		$RecordOffset = "0x" & Hex($RecordOffsetDec)
		_WriteCSV()
		$Signature = ""
		ContinueLoop
	Else
		_ClearVar()
		$Signature = "UNKNOWN"
		$RecordOffset = "0x" & Hex($RecordOffsetDec)
		_WriteCSV()
		$Signature = ""
		ContinueLoop
	EndIf
	_ClearVar()
	_DecodeMFTRecord($MFTEntry)
	If $DATA_Number > 0 Then $Alternate_Data_Stream = $DATA_Number - 1
	;	Alternatively;
	;	If $DATA_Name_2 <> "" Then $Alternate_Data_Stream = 1
	$RecordOffset = "0x" & Hex($RecordOffsetDec)
	$CTimeTest = _Test_SI2FN_CTime($SI_CTime, $FN_CTime)
	_WriteCSV()
	$Signature = ""
Next
_WinAPI_CloseHandle($hFile)
FileClose($csv)
ProgressOff()
$timerdiff = TimerDiff($begin)
$timerdiff = Round(($timerdiff / 1000), 2)
$RecordsPerSec = Round(($i / $timerdiff), 0)
MsgBox(0, "Finished parsing $MFT", "Job took: " & $timerdiff & " seconds" & @CRLF _
		 & "Performed " & $RecordsPerSec & " records per second.")
Exit


Func _DisplayProgress()
	ProgressSet(Round((($i / $ExpectedRecords) * 100), 2), Round(($i / $ExpectedRecords) * 100, 2) & "  % finished with exporting $MFT data to csv", Round($i / (TimerDiff($begin) / 1000), 1) & " Records per second.")
EndFunc   ;==>_DisplayProgress

Func _DecodeMFTRecord($MFTEntry)
	$RecordActive = ""
	$HEADER_Flags = ""
	$FN_Number = 0
	$DATA_Number = 0
	$HEADER_LSN = ""
	$HEADER_SequenceNo = ""
	$HEADER_RecordRealSize = ""
	$HEADER_RecordAllocSize = ""
	$HEADER_FileRef = ""
	$HEADER_NextAttribID = ""
	$HEADER_MFTREcordNumber = ""
	$UpdSeqArrOffset = ""
	$UpdSeqArrSize = ""
	$UpdSeqArrOffset = StringMid($MFTEntry, 11, 4)
	$UpdSeqArrOffset = Dec(StringMid($UpdSeqArrOffset, 3, 2) & StringMid($UpdSeqArrOffset, 1, 2))
	$UpdSeqArrSize = StringMid($MFTEntry, 15, 4)
	$UpdSeqArrSize = Dec(StringMid($UpdSeqArrSize, 3, 2) & StringMid($UpdSeqArrSize, 1, 2))
	$UpdSeqArr = StringMid($MFTEntry, 3 + ($UpdSeqArrOffset * 2), $UpdSeqArrSize * 2 * 2)
	$UpdSeqArrPart0 = StringMid($UpdSeqArr, 1, 4)
	$UpdSeqArrPart1 = StringMid($UpdSeqArr, 5, 4)
	$UpdSeqArrPart2 = StringMid($UpdSeqArr, 9, 4)
	$RecordEnd1 = StringMid($MFTEntry, 1023, 4)
	$RecordEnd2 = StringMid($MFTEntry, 2047, 4)
	If $RecordEnd1 <> $RecordEnd2 Or $UpdSeqArrPart0 <> $RecordEnd1 Then
		$IntegrityCheck = "BAD"
	Else
		$IntegrityCheck = "OK"
	EndIf
	$MFTEntry = StringMid($MFTEntry, 1, 1022) & $UpdSeqArrPart1 & StringMid($MFTEntry, 1027, 1020) & $UpdSeqArrPart2 ; Stupid fixup to not corrupt decoding of attributes that are located past 0x1fd within record
	;ConsoleWrite("$UpdSeqArrOffset = " & $UpdSeqArrOffset & @crlf)
	;ConsoleWrite("$UpdSeqArrSize = " & $UpdSeqArrSize & @crlf)
	;ConsoleWrite("$UpdSeqArr = " & $UpdSeqArr & @crlf)
	;ConsoleWrite("$UpdSeqArrPart1 = " & $UpdSeqArrPart1 & @crlf)
	;ConsoleWrite("$RecordEnd1 = " & $RecordEnd1 & @crlf)
	;ConsoleWrite("$RecordEnd2 = " & $RecordEnd2 & @crlf)
	;ConsoleWrite("$IntegrityCheck = " & $IntegrityCheck & @crlf)
	$HEADER_LSN = StringMid($MFTEntry, 19, 16)
	;ConsoleWrite("$HEADER_LSN = " & $HEADER_LSN & @crlf)
	$HEADER_LSN = StringMid($HEADER_LSN, 15, 2) & StringMid($HEADER_LSN, 13, 2) & StringMid($HEADER_LSN, 11, 2) & StringMid($HEADER_LSN, 9, 2) & StringMid($HEADER_LSN, 7, 2) & StringMid($HEADER_LSN, 5, 2) & StringMid($HEADER_LSN, 3, 2) & StringMid($HEADER_LSN, 1, 2)
	;ConsoleWrite("$HEADER_LSN = " & $HEADER_LSN & @crlf)
	$HEADER_SequenceNo = StringMid($MFTEntry, 35, 4)
	$HEADER_SequenceNo = Dec(StringMid($HEADER_SequenceNo, 3, 2) & StringMid($HEADER_SequenceNo, 1, 2))
	;$HEADER_SequenceNo = Dec($HEADER_SequenceNo)
	;ConsoleWrite("$HEADER_SequenceNo = " & $HEADER_SequenceNo & @crlf)
	$HEADER_Flags = StringMid($MFTEntry, 47, 4);00=deleted file,01=file,02=deleted folder,03=folder
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
		Case $HEADER_Flags = '0900'
			$HEADER_Flags = 'FILE+INDEX_SECURITY'
			$RecordActive = 'ALLOCATED'
		Case $HEADER_Flags = '0D00'
			$HEADER_Flags = 'FILE+INDEX_OTHER'
			$RecordActive = 'ALLOCATED'
		Case Else
			$HEADER_Flags = 'UNKNOWN'
			$RecordActive = 'UNKNOWN'
	EndSelect
	;#ce
	;ConsoleWrite("$HEADER_Flags = " & $HEADER_Flags & @crlf)
	$HEADER_RecordRealSize = StringMid($MFTEntry, 51, 8)
	$HEADER_RecordRealSize = Dec(StringMid($HEADER_RecordRealSize, 7, 2) & StringMid($HEADER_RecordRealSize, 5, 2) & StringMid($HEADER_RecordRealSize, 3, 2) & StringMid($HEADER_RecordRealSize, 1, 2))
	;$HEADER_RecordRealSize = Dec($HEADER_RecordRealSize)
	;ConsoleWrite("$HEADER_RecordRealSize = " & $HEADER_RecordRealSize & @crlf)
	$HEADER_RecordAllocSize = StringMid($MFTEntry, 59, 8)
	$HEADER_RecordAllocSize = Dec(StringMid($HEADER_RecordAllocSize, 7, 2) & StringMid($HEADER_RecordAllocSize, 5, 2) & StringMid($HEADER_RecordAllocSize, 3, 2) & StringMid($HEADER_RecordAllocSize, 1, 2))
	;$HEADER_RecordAllocSize = Dec($HEADER_RecordAllocSize)
	;ConsoleWrite("$HEADER_RecordAllocSize = " & $HEADER_RecordAllocSize & @crlf)
	$HEADER_FileRef = StringMid($MFTEntry, 67, 16)
	;ConsoleWrite("$HEADER_FileRef = " & $HEADER_FileRef & @crlf)
	$HEADER_NextAttribID = StringMid($MFTEntry, 83, 4)
	;ConsoleWrite("$HEADER_NextAttribID = " & $HEADER_NextAttribID & @crlf)
	$HEADER_NextAttribID = StringMid($HEADER_NextAttribID, 3, 2) & StringMid($HEADER_NextAttribID, 1, 2)
	$HEADER_MFTREcordNumber = StringMid($MFTEntry, 91, 8)
	$HEADER_MFTREcordNumber = Dec(StringMid($HEADER_MFTREcordNumber, 7, 2) & StringMid($HEADER_MFTREcordNumber, 5, 2) & StringMid($HEADER_MFTREcordNumber, 3, 2) & StringMid($HEADER_MFTREcordNumber, 1, 2))
	;$HEADER_MFTREcordNumber = Dec($HEADER_MFTREcordNumber)
	;ConsoleWrite("$HEADER_MFTREcordNumber = " & $HEADER_MFTREcordNumber & @crlf)
	$NextAttributeOffset = (Dec(StringMid($MFTEntry, 43, 2)) * 2) + 3
	;ConsoleWrite("$NextAttributeOffset = " & $NextAttributeOffset & @crlf)
	;ConsoleWrite("$NextAttributeOffset Hex = 0x" & Hex((($NextAttributeOffset-3)/2)) & @crlf)
	$AttributeType = StringMid($MFTEntry, $NextAttributeOffset, 8)
	;ConsoleWrite("$AttributeType = " & $AttributeType & @crlf)
	$AttributeSize = StringMid($MFTEntry, $NextAttributeOffset + 8, 8)
	;ConsoleWrite("$AttributeSize = " & $AttributeSize & @crlf)
	$AttributeSize = Dec(StringMid($AttributeSize, 7, 2) & StringMid($AttributeSize, 5, 2) & StringMid($AttributeSize, 3, 2) & StringMid($AttributeSize, 1, 2))
	;$AttributeSize = Dec($AttributeSize)
	;ConsoleWrite("$AttributeSize = " & $AttributeSize & @crlf)
	$AttributeKnown = 1
	While $AttributeKnown = 1
		;While $AttributeType <> $ATTRIBUTE_UNKNOWN
		;While $NextAttributeOffset < 2048
		$NextAttributeType = StringMid($MFTEntry, $NextAttributeOffset, 8)
		ConsoleWrite("$NextAttributeType = " & $NextAttributeType & @CRLF)
		$AttributeType = $NextAttributeType
		$AttributeSize = StringMid($MFTEntry, $NextAttributeOffset + 8, 8)
		$AttributeSize = Dec(StringMid($AttributeSize, 7, 2) & StringMid($AttributeSize, 5, 2) & StringMid($AttributeSize, 3, 2) & StringMid($AttributeSize, 1, 2))
		;	$AttributeSize = Dec($AttributeSize)
		ConsoleWrite("$AttributeSize = " & $AttributeSize & @CRLF)
		ConsoleWrite("$NextAttributeOffset Dec = " & $NextAttributeOffset & @CRLF)
		ConsoleWrite("$NextAttributeOffset Hex = 0x" & Hex((($NextAttributeOffset - 3) / 2)) & @CRLF)
		Select
			Case $AttributeType = $STANDARD_INFORMATION
				$AttributeKnown = 1
				$STANDARD_INFORMATION_ON = "TRUE"
				_Get_StandardInformation($MFTEntry, $NextAttributeOffset, $AttributeSize)

			Case $AttributeType = $ATTRIBUTE_LIST
				$AttributeKnown = 1
				$ATTRIBUTE_LIST_ON = "TRUE"
				;			_Get_AttributeList()

			Case $AttributeType = $FILE_NAME
				$AttributeKnown = 1
				$FILE_NAME_ON = "TRUE"
				$FN_Number += 1 ; Need to come up with something smarter than this
				If $FN_Number > 4 Then ContinueCase
				_Get_FileName($MFTEntry, $NextAttributeOffset, $AttributeSize, $FN_Number)

			Case $AttributeType = $OBJECT_ID
				$AttributeKnown = 1
				$OBJECT_ID_ON = "TRUE"
				_Get_ObjectID($MFTEntry, $NextAttributeOffset, $AttributeSize)

			Case $AttributeType = $SECURITY_DESCRIPTOR
				$AttributeKnown = 1
				$SECURITY_DESCRIPTOR_ON = "TRUE"
				;			_Get_SecurityDescriptor()

			Case $AttributeType = $VOLUME_NAME
				$AttributeKnown = 1
				$VOLUME_NAME_ON = "TRUE"
				_Get_VolumeName($MFTEntry, $NextAttributeOffset, $AttributeSize)

			Case $AttributeType = $VOLUME_INFORMATION
				$AttributeKnown = 1
				$VOLUME_INFORMATION_ON = "TRUE"
				_Get_VolumeInformation($MFTEntry, $NextAttributeOffset, $AttributeSize)

			Case $AttributeType = $DATA
				$AttributeKnown = 1
				$DATA_ON = "TRUE"
				$DATA_Number += 1
				If $DATA_Number > 3 Then ContinueCase
				_Get_Data($MFTEntry, $NextAttributeOffset, $AttributeSize, $DATA_Number)

			Case $AttributeType = $INDEX_ROOT
				$AttributeKnown = 1
				$INDEX_ROOT_ON = "TRUE"
				;			_Get_IndexRoot()

			Case $AttributeType = $INDEX_ALLOCATION
				$AttributeKnown = 1
				$INDEX_ALLOCATION_ON = "TRUE"
				;			_Get_IndexAllocation()

			Case $AttributeType = $BITMAP
				$AttributeKnown = 1
				$BITMAP_ON = "TRUE"
				;			_Get_Bitmap()

			Case $AttributeType = $REPARSE_POINT
				$AttributeKnown = 1
				$REPARSE_POINT_ON = "TRUE"
				;			_Get_ReparsePoint()

			Case $AttributeType = $EA_INFORMATION
				$AttributeKnown = 1
				$EA_INFORMATION_ON = "TRUE"
				;			_Get_EaInformation()

			Case $AttributeType = $EA
				$AttributeKnown = 1
				$EA_ON = "TRUE"
				;			_Get_Ea()

			Case $AttributeType = $PROPERTY_SET
				$AttributeKnown = 1
				$PROPERTY_SET_ON = "TRUE"
				;			_Get_PropertySet()

			Case $AttributeType = $LOGGED_UTILITY_STREAM
				$AttributeKnown = 1
				$LOGGED_UTILITY_STREAM_ON = "TRUE"
				;			_Get_LoggedUtilityStream()

			Case $AttributeType = $ATTRIBUTE_END_MARKER
				$AttributeKnown = 0
				ConsoleWrite("No more attributes in this record." & @CRLF)

			Case $AttributeType <> $LOGGED_UTILITY_STREAM And $AttributeType <> $EA And $AttributeType <> $EA_INFORMATION And $AttributeType <> $REPARSE_POINT And $AttributeType <> $BITMAP And $AttributeType <> $INDEX_ALLOCATION And $AttributeType <> $INDEX_ROOT And $AttributeType <> $DATA And $AttributeType <> $VOLUME_INFORMATION And $AttributeType <> $VOLUME_NAME And $AttributeType <> $SECURITY_DESCRIPTOR And $AttributeType <> $OBJECT_ID And $AttributeType <> $FILE_NAME And $AttributeType <> $ATTRIBUTE_LIST And $AttributeType <> $STANDARD_INFORMATION And $AttributeType <> $PROPERTY_SET And $AttributeType <> $ATTRIBUTE_END_MARKER
				$AttributeKnown = 0
				ConsoleWrite("Unknown attribute found in this record." & @CRLF)

		EndSelect

		$NextAttributeOffset = $NextAttributeOffset + ($AttributeSize * 2)
	WEnd
EndFunc   ;==>_DecodeMFTRecord

Func _WinAPI_SetFilePointerEx($hFile, $iPos, $iMethod = 0)

	Local $Ret = DllCall('kernel32.dll', 'int', 'SetFilePointerEx', 'ptr', $hFile, 'int64', $iPos, 'int64*', 0, 'dword', $iMethod)

	If (@error) Or (Not $Ret[0]) Then
		Return SetError(1, 0, 0)
	EndIf
	Return 1
EndFunc   ;==>_WinAPI_SetFilePointerEx

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

EndFunc   ;==>_HexEncode

; #FUNCTION# ==============================================================
; Function Name..: _HexToDec ( "expression" )
; Description ...: Returns decimal expression of a hexadecimal string.
; Parameters ....: expression   - String representation of a hexadecimal expression to be converted to decimal.
; Return values .: Success      - Returns decimal expression of a hexadecimal string.
;                  Failure      - Returns "" (blank string) and sets @error to 1 if string is not hexadecimal type.
; Author ........: jennico (jennicoattminusonlinedotde)
; Remarks .......: working input format: "FFFF" or "0xFFFF" (string format), do NOT pass 0xFFFF without quotation marks (number format).
;                  current AutoIt Dec() limitation: 0x7FFFFFFF (2147483647).
; Related .......: Hex(), Dec(), _DecToHex()
; =======================================================================
Func _HexToDec($hx_hex)
	If StringLeft($hx_hex, 2) = "0x" Then $hx_hex = StringMid($hx_hex, 3)
	If StringIsXDigit($hx_hex) = 0 Then
		SetError(1)
		Return ""
	EndIf
	Local $Ret = "", $hx_count = 0, $hx_array = StringSplit($hx_hex, ""), $Ii, $hx_tmp
	For $Ii = $hx_array[0] To 1 Step -1
		$hx_tmp = StringInStr($HX_REF, $hx_array[$Ii]) - 1
		$Ret += $hx_tmp * 16 ^ $hx_count
		$hx_count += 1
	Next
	Return $Ret
EndFunc   ;==>_HexToDec

; #FUNCTION# ==============================================================
; Function Name..: _DecToHex ( expression [, length] )
; Description ...: Returns a string representation of an integer converted to hexadecimal.
; Parameters ....: expression   - The integer to be converted to hexadecimal.
;                  length       - [optional] Number of characters to be returned (no limit).
;                                 If no length specified, leading zeros will be stripped from result.
; Return values .: Success      - Returns a string of length characters representing a hexadecimal expression, zero-padded if necessary.
;                  Failure      - Returns "" (blank string) and sets @error to 1 if expression is not an integer.
; Author ........: jennico (jennicoattminusonlinedotde)
; Remarks .......: Output format "FFFF".
;                  The function will also set @error to 1 if requested length is not sufficient - the returned string will be left truncated.
;                  Be free to modify the function to be working with binary type input - I did not try it though.
;                  current AutoIt Hex() limitation: 0xFFFFFFFF (4294967295).
; Related .......: Hex(), Dec(), _HexToDec()
; =======================================================================
Func _DecToHex($hx_dec, $hx_length = 21)
	If IsInt($hx_dec) = 0 Then
		SetError(1)
		Return ""
	EndIf
	Local $Ret = "", $Ii, $hx_tmp, $hx_max
	If $hx_dec < 4294967296 Then
		If $hx_length < 9 Then Return Hex($hx_dec, $hx_length)
		If $hx_length = 21 Then
			$Ret = Hex($hx_dec)
			While StringLeft($Ret, 1) = "0"
				$Ret = StringMid($Ret, 2)
			WEnd
			Return $Ret
		EndIf
	EndIf
	For $Ii = $hx_length - 1 To 0 Step -1
		$hx_max = 16 ^ $Ii - 1
		If $Ret = "" And $hx_length = 21 And $hx_max > $hx_dec Then ContinueLoop
		$hx_tmp = Int($hx_dec / ($hx_max + 1))
		If $Ret = "" And $hx_length = 21 And $Ii > 0 And $hx_tmp = 0 Then ContinueLoop
		$Ret &= StringMid($HX_REF, $hx_tmp + 1, 1)
		$hx_dec -= $hx_tmp * ($hx_max + 1)
	Next
	$Ret = String($Ret)
	If $hx_length < 21 And StringLen($Ret) < $hx_length Then SetError(1)
	Return $Ret
EndFunc   ;==>_DecToHex

Func _Get_StandardInformation($MFTEntry, $SI_Offset, $SI_Size)
	ConsoleWrite("$SI_Size = " & $SI_Size & @CRLF)
	$SI_HEADER_Flags = StringMid($MFTEntry, $SI_Offset + 24, 4)
	$SI_HEADER_Flags = StringMid($SI_HEADER_Flags, 3, 2) & StringMid($SI_HEADER_Flags, 1, 2)
	ConsoleWrite("$SI_HEADER_Flags = " & $SI_HEADER_Flags & @CRLF)
	$SI_HEADER_Flags = _AttribHeaderFlags("0x" & $SI_HEADER_Flags)
	ConsoleWrite("$SI_HEADER_Flags = " & $SI_HEADER_Flags & @CRLF)
	;
	$SI_CTime = StringMid($MFTEntry, $SI_Offset + 48, 16)
	ConsoleWrite("$SI_CTime = " & $SI_CTime & @CRLF)
	$SI_CTime = StringMid($SI_CTime, 15, 2) & StringMid($SI_CTime, 13, 2) & StringMid($SI_CTime, 11, 2) & StringMid($SI_CTime, 9, 2) & StringMid($SI_CTime, 7, 2) & StringMid($SI_CTime, 5, 2) & StringMid($SI_CTime, 3, 2) & StringMid($SI_CTime, 1, 2)
	;$SI_CTime = _HexToDec(StringMid($SI_CTime,15,2) & StringMid($SI_CTime,13,2) & StringMid($SI_CTime,11,2) & StringMid($SI_CTime,9,2) & StringMid($SI_CTime,7,2) & StringMid($SI_CTime,5,2) & StringMid($SI_CTime,3,2) & StringMid($SI_CTime,1,2))
	ConsoleWrite("$SI_CTime = " & $SI_CTime & @CRLF)
	$SI_CTime_tmp = _WinTime_UTCFileTimeToLocalFileTime("0x" & $SI_CTime)
	ConsoleWrite("$SI_CTime_tmp = " & $SI_CTime_tmp & @CRLF)
	$SI_CTime = _WinTime_UTCFileTimeFormat(_HexToDec($SI_CTime) - $tDelta, $DateTimeFormat, 2)
	$SI_CTime = $SI_CTime & ":" & _FillZero(StringRight($SI_CTime_tmp, 4))
	ConsoleWrite("$SI_CTime = " & $SI_CTime & @CRLF)
	$MSecTest = _Test_MilliSec($SI_CTime)
	;
	$SI_ATime = StringMid($MFTEntry, $SI_Offset + 64, 16)
	ConsoleWrite("$SI_ATime = " & $SI_ATime & @CRLF)
	$SI_ATime = StringMid($SI_ATime, 15, 2) & StringMid($SI_ATime, 13, 2) & StringMid($SI_ATime, 11, 2) & StringMid($SI_ATime, 9, 2) & StringMid($SI_ATime, 7, 2) & StringMid($SI_ATime, 5, 2) & StringMid($SI_ATime, 3, 2) & StringMid($SI_ATime, 1, 2)
	;$SI_ATime = _HexToDec(StringMid($SI_ATime,15,2) & StringMid($SI_ATime,13,2) & StringMid($SI_ATime,11,2) & StringMid($SI_ATime,9,2) & StringMid($SI_ATime,7,2) & StringMid($SI_ATime,5,2) & StringMid($SI_ATime,3,2) & StringMid($SI_ATime,1,2))
	ConsoleWrite("$SI_ATime = " & $SI_ATime & @CRLF)
	$SI_ATime_tmp = _WinTime_UTCFileTimeToLocalFileTime("0x" & $SI_ATime)
	ConsoleWrite("$SI_ATime_tmp = " & $SI_ATime_tmp & @CRLF)
	$SI_ATime = _WinTime_UTCFileTimeFormat(_HexToDec($SI_ATime) - $tDelta, $DateTimeFormat, 2)
	$SI_ATime = $SI_ATime & ":" & _FillZero(StringRight($SI_ATime_tmp, 4))
	ConsoleWrite("$SI_ATime = " & $SI_ATime & @CRLF)
	;
	$SI_MTime = StringMid($MFTEntry, $SI_Offset + 80, 16)
	ConsoleWrite("$SI_MTime = " & $SI_MTime & @CRLF)
	$SI_MTime = StringMid($SI_MTime, 15, 2) & StringMid($SI_MTime, 13, 2) & StringMid($SI_MTime, 11, 2) & StringMid($SI_MTime, 9, 2) & StringMid($SI_MTime, 7, 2) & StringMid($SI_MTime, 5, 2) & StringMid($SI_MTime, 3, 2) & StringMid($SI_MTime, 1, 2)
	;$SI_MTime = _HexToDec(StringMid($SI_MTime,15,2) & StringMid($SI_MTime,13,2) & StringMid($SI_MTime,11,2) & StringMid($SI_MTime,9,2) & StringMid($SI_MTime,7,2) & StringMid($SI_MTime,5,2) & StringMid($SI_MTime,3,2) & StringMid($SI_MTime,1,2))
	ConsoleWrite("$SI_MTime = " & $SI_MTime & @CRLF)
	$SI_MTime_tmp = _WinTime_UTCFileTimeToLocalFileTime("0x" & $SI_MTime)
	ConsoleWrite("$SI_MTime_tmp = " & $SI_MTime_tmp & @CRLF)
	$SI_MTime = _WinTime_UTCFileTimeFormat(_HexToDec($SI_MTime) - $tDelta, $DateTimeFormat, 2)
	$SI_MTime = $SI_MTime & ":" & _FillZero(StringRight($SI_MTime_tmp, 4))
	ConsoleWrite("$SI_MTime = " & $SI_MTime & @CRLF)
	;
	$SI_RTime = StringMid($MFTEntry, $SI_Offset + 96, 16)
	ConsoleWrite("$SI_RTime = " & $SI_RTime & @CRLF)
	$SI_RTime = StringMid($SI_RTime, 15, 2) & StringMid($SI_RTime, 13, 2) & StringMid($SI_RTime, 11, 2) & StringMid($SI_RTime, 9, 2) & StringMid($SI_RTime, 7, 2) & StringMid($SI_RTime, 5, 2) & StringMid($SI_RTime, 3, 2) & StringMid($SI_RTime, 1, 2)
	;$SI_RTime = _HexToDec(StringMid($SI_RTime,15,2) & StringMid($SI_RTime,13,2) & StringMid($SI_RTime,11,2) & StringMid($SI_RTime,9,2) & StringMid($SI_RTime,7,2) & StringMid($SI_RTime,5,2) & StringMid($SI_RTime,3,2) & StringMid($SI_RTime,1,2))
	ConsoleWrite("$SI_RTime = " & $SI_RTime & @CRLF)
	$SI_RTime_tmp = _WinTime_UTCFileTimeToLocalFileTime("0x" & $SI_RTime)
	ConsoleWrite("$SI_RTime_tmp = " & $SI_RTime_tmp & @CRLF)
	$SI_RTime = _WinTime_UTCFileTimeFormat(_HexToDec($SI_RTime) - $tDelta, $DateTimeFormat, 2)
	$SI_RTime = $SI_RTime & ":" & _FillZero(StringRight($SI_RTime_tmp, 4))
	ConsoleWrite("$SI_RTime = " & $SI_RTime & @CRLF)
	;
	$SI_FilePermission = StringMid($MFTEntry, $SI_Offset + 112, 8)
	$SI_FilePermission = StringMid($SI_FilePermission, 7, 2) & StringMid($SI_FilePermission, 5, 2) & StringMid($SI_FilePermission, 3, 2) & StringMid($SI_FilePermission, 1, 2)
	ConsoleWrite("$SI_FilePermission = " & $SI_FilePermission & @CRLF)
	$SI_FilePermission = _File_Permissions("0x" & $SI_FilePermission)
	ConsoleWrite("$SI_FilePermission = " & $SI_FilePermission & @CRLF)
	$SI_MaxVersions = StringMid($MFTEntry, $SI_Offset + 120, 8)
	$SI_MaxVersions = Dec(StringMid($SI_MaxVersions, 7, 2) & StringMid($SI_MaxVersions, 5, 2) & StringMid($SI_MaxVersions, 3, 2) & StringMid($SI_MaxVersions, 1, 2))
	;$SI_MaxVersions = Dec($SI_MaxVersions)
	$SI_VersionNumber = StringMid($MFTEntry, $SI_Offset + 128, 8)
	$SI_VersionNumber = Dec(StringMid($SI_VersionNumber, 7, 2) & StringMid($SI_VersionNumber, 5, 2) & StringMid($SI_VersionNumber, 3, 2) & StringMid($SI_VersionNumber, 1, 2))
	;$SI_VersionNumber = Dec($SI_VersionNumber)
	$SI_ClassID = StringMid($MFTEntry, $SI_Offset + 136, 8)
	$SI_ClassID = Dec(StringMid($SI_ClassID, 7, 2) & StringMid($SI_ClassID, 5, 2) & StringMid($SI_ClassID, 3, 2) & StringMid($SI_ClassID, 1, 2))
	;$SI_ClassID = Dec($SI_ClassID)
	$SI_OwnerID = StringMid($MFTEntry, $SI_Offset + 144, 8)
	$SI_OwnerID = Dec(StringMid($SI_OwnerID, 7, 2) & StringMid($SI_OwnerID, 5, 2) & StringMid($SI_OwnerID, 3, 2) & StringMid($SI_OwnerID, 1, 2))
	;$SI_OwnerID = Dec($SI_OwnerID)
	$SI_SecurityID = StringMid($MFTEntry, $SI_Offset + 152, 8)
	$SI_SecurityID = Dec(StringMid($SI_SecurityID, 7, 2) & StringMid($SI_SecurityID, 5, 2) & StringMid($SI_SecurityID, 3, 2) & StringMid($SI_SecurityID, 1, 2))
	;$SI_SecurityID = Dec($SI_SecurityID)
	$SI_USN = StringMid($MFTEntry, $SI_Offset + 176, 16)
	$SI_USN = StringMid($SI_USN, 15, 2) & StringMid($SI_USN, 13, 2) & StringMid($SI_USN, 11, 2) & StringMid($SI_USN, 9, 2) & StringMid($SI_USN, 7, 2) & StringMid($SI_USN, 5, 2) & StringMid($SI_USN, 3, 2) & StringMid($SI_USN, 1, 2)
	;$SI_USN = _HexToDec($SI_USN)
	ConsoleWrite("$SI_USN = " & $SI_USN & @CRLF)
EndFunc   ;==>_Get_StandardInformation

Func _Get_AttributeList()
	ConsoleWrite("Get_AttributeList Function not implemented yet." & @CRLF)
	Return
EndFunc   ;==>_Get_AttributeList

Func _Get_FileName($MFTEntry, $FN_Offset, $FN_Size, $FN_Number)
	If $FN_Number = 1 Then
		$FN_ParentReferenceNo = StringMid($MFTEntry, $FN_Offset + 48, 12)
		ConsoleWrite("$FN_ParentReferenceNo = " & $FN_ParentReferenceNo & @CRLF)
		$FN_ParentReferenceNo = _HexToDec(StringMid($FN_ParentReferenceNo, 11, 2) & StringMid($FN_ParentReferenceNo, 9, 2) & StringMid($FN_ParentReferenceNo, 7, 2) & StringMid($FN_ParentReferenceNo, 5, 2) & StringMid($FN_ParentReferenceNo, 3, 2) & StringMid($FN_ParentReferenceNo, 1, 2))
		;$FN_ParentReferenceNo = _HexToDec($FN_ParentReferenceNo)
		ConsoleWrite("$FN_ParentReferenceNo = " & $FN_ParentReferenceNo & @CRLF)
		$FN_ParentSequenceNo = StringMid($MFTEntry, $FN_Offset + 60, 4)
		ConsoleWrite("$FN_ParentSequenceNo = " & $FN_ParentSequenceNo & @CRLF)
		$FN_ParentSequenceNo = Dec(StringMid($FN_ParentSequenceNo, 3, 2) & StringMid($FN_ParentSequenceNo, 1, 2))
		;$FN_ParentSequenceNo = Dec($FN_ParentSequenceNo)
		ConsoleWrite("$FN_ParentSequenceNo = " & $FN_ParentSequenceNo & @CRLF)
		;ConsoleWrite("$FN_Size = " & $FN_Size & @crlf)
		;
		$FN_CTime = StringMid($MFTEntry, $FN_Offset + 64, 16)
		ConsoleWrite("$FN_CTime = " & $FN_CTime & @CRLF)
		$FN_CTime = StringMid($FN_CTime, 15, 2) & StringMid($FN_CTime, 13, 2) & StringMid($FN_CTime, 11, 2) & StringMid($FN_CTime, 9, 2) & StringMid($FN_CTime, 7, 2) & StringMid($FN_CTime, 5, 2) & StringMid($FN_CTime, 3, 2) & StringMid($FN_CTime, 1, 2)
		;$FN_CTime = _HexToDec(StringMid($FN_CTime,15,2) & StringMid($FN_CTime,13,2) & StringMid($FN_CTime,11,2) & StringMid($FN_CTime,9,2) & StringMid($FN_CTime,7,2) & StringMid($FN_CTime,5,2) & StringMid($FN_CTime,3,2) & StringMid($FN_CTime,1,2))
		ConsoleWrite("$FN_CTime = " & $FN_CTime & @CRLF)
		$FN_CTime_tmp = _WinTime_UTCFileTimeToLocalFileTime("0x" & $FN_CTime)
		ConsoleWrite("$FN_CTime_tmp = " & $FN_CTime_tmp & @CRLF)
		$FN_CTime = _WinTime_UTCFileTimeFormat(_HexToDec($FN_CTime) - $tDelta, $DateTimeFormat, 2)
		$FN_CTime = $FN_CTime & ":" & _FillZero(StringRight($FN_CTime_tmp, 4))
		ConsoleWrite("$FN_CTime = " & $FN_CTime & @CRLF)
		;
		$FN_ATime = StringMid($MFTEntry, $FN_Offset + 80, 16)
		ConsoleWrite("$FN_ATime = " & $FN_ATime & @CRLF)
		$FN_ATime = StringMid($FN_ATime, 15, 2) & StringMid($FN_ATime, 13, 2) & StringMid($FN_ATime, 11, 2) & StringMid($FN_ATime, 9, 2) & StringMid($FN_ATime, 7, 2) & StringMid($FN_ATime, 5, 2) & StringMid($FN_ATime, 3, 2) & StringMid($FN_ATime, 1, 2)
		;$FN_ATime = _HexToDec(StringMid($FN_ATime,15,2) & StringMid($FN_ATime,13,2) & StringMid($FN_ATime,11,2) & StringMid($FN_ATime,9,2) & StringMid($FN_ATime,7,2) & StringMid($FN_ATime,5,2) & StringMid($FN_ATime,3,2) & StringMid($FN_ATime,1,2))
		ConsoleWrite("$FN_ATime = " & $FN_ATime & @CRLF)
		$FN_ATime_tmp = _WinTime_UTCFileTimeToLocalFileTime("0x" & $FN_ATime)
		ConsoleWrite("$FN_ATime_tmp = " & $FN_ATime_tmp & @CRLF)
		$FN_ATime = _WinTime_UTCFileTimeFormat(_HexToDec($FN_ATime) - $tDelta, $DateTimeFormat, 2)
		$FN_ATime = $FN_ATime & ":" & _FillZero(StringRight($FN_ATime_tmp, 4))
		ConsoleWrite("$FN_ATime = " & $FN_ATime & @CRLF)
		;
		$FN_MTime = StringMid($MFTEntry, $FN_Offset + 96, 16)
		ConsoleWrite("$FN_MTime = " & $FN_MTime & @CRLF)
		$FN_MTime = StringMid($FN_MTime, 15, 2) & StringMid($FN_MTime, 13, 2) & StringMid($FN_MTime, 11, 2) & StringMid($FN_MTime, 9, 2) & StringMid($FN_MTime, 7, 2) & StringMid($FN_MTime, 5, 2) & StringMid($FN_MTime, 3, 2) & StringMid($FN_MTime, 1, 2)
		;$FN_MTime = _HexToDec(StringMid($FN_MTime,15,2) & StringMid($FN_MTime,13,2) & StringMid($FN_MTime,11,2) & StringMid($FN_MTime,9,2) & StringMid($FN_MTime,7,2) & StringMid($FN_MTime,5,2) & StringMid($FN_MTime,3,2) & StringMid($FN_MTime,1,2))
		ConsoleWrite("$FN_MTime = " & $FN_MTime & @CRLF)
		$FN_MTime_tmp = _WinTime_UTCFileTimeToLocalFileTime("0x" & $FN_MTime)
		ConsoleWrite("$FN_MTime_tmp = " & $FN_MTime_tmp & @CRLF)
		$FN_MTime = _WinTime_UTCFileTimeFormat(_HexToDec($FN_MTime) - $tDelta, $DateTimeFormat, 2)
		$FN_MTime = $FN_MTime & ":" & _FillZero(StringRight($FN_MTime_tmp, 4))
		ConsoleWrite("$FN_MTime = " & $FN_MTime & @CRLF)
		;
		$FN_RTime = StringMid($MFTEntry, $FN_Offset + 112, 16)
		ConsoleWrite("$FN_RTime = " & $FN_RTime & @CRLF)
		$FN_RTime = StringMid($FN_RTime, 15, 2) & StringMid($FN_RTime, 13, 2) & StringMid($FN_RTime, 11, 2) & StringMid($FN_RTime, 9, 2) & StringMid($FN_RTime, 7, 2) & StringMid($FN_RTime, 5, 2) & StringMid($FN_RTime, 3, 2) & StringMid($FN_RTime, 1, 2)
		;$FN_RTime = _HexToDec(StringMid($FN_RTime,15,2) & StringMid($FN_RTime,13,2) & StringMid($FN_RTime,11,2) & StringMid($FN_RTime,9,2) & StringMid($FN_RTime,7,2) & StringMid($FN_RTime,5,2) & StringMid($FN_RTime,3,2) & StringMid($FN_RTime,1,2))
		ConsoleWrite("$FN_RTime = " & $FN_RTime & @CRLF)
		$FN_RTime_tmp = _WinTime_UTCFileTimeToLocalFileTime("0x" & $FN_RTime)
		ConsoleWrite("$FN_RTime_tmp = " & $FN_RTime_tmp & @CRLF)
		$FN_RTime = _WinTime_UTCFileTimeFormat(_HexToDec($FN_RTime) - $tDelta, $DateTimeFormat, 2)
		$FN_RTime = $FN_RTime & ":" & _FillZero(StringRight($FN_RTime_tmp, 4))
		ConsoleWrite("$FN_RTime = " & $FN_RTime & @CRLF)
		;
		$FN_AllocSize = StringMid($MFTEntry, $FN_Offset + 128, 16)
		$FN_AllocSize = _HexToDec(StringMid($FN_AllocSize, 15, 2) & StringMid($FN_AllocSize, 13, 2) & StringMid($FN_AllocSize, 11, 2) & StringMid($FN_AllocSize, 9, 2) & StringMid($FN_AllocSize, 7, 2) & StringMid($FN_AllocSize, 5, 2) & StringMid($FN_AllocSize, 3, 2) & StringMid($FN_AllocSize, 1, 2))
		;$FN_AllocSize = _HexToDec($FN_AllocSize)
		ConsoleWrite("$FN_AllocSize = " & $FN_AllocSize & @CRLF)
		$FN_RealSize = StringMid($MFTEntry, $FN_Offset + 144, 16)
		$FN_RealSize = _HexToDec(StringMid($FN_RealSize, 15, 2) & StringMid($FN_RealSize, 13, 2) & StringMid($FN_RealSize, 11, 2) & StringMid($FN_RealSize, 9, 2) & StringMid($FN_RealSize, 7, 2) & StringMid($FN_RealSize, 5, 2) & StringMid($FN_RealSize, 3, 2) & StringMid($FN_RealSize, 1, 2))
		;$FN_RealSize = _HexToDec($FN_RealSize)
		ConsoleWrite("$FN_RealSize = " & $FN_RealSize & @CRLF)
		$FN_Flags = StringMid($MFTEntry, $FN_Offset + 160, 8)
		ConsoleWrite("$FN_Flags = " & $FN_Flags & @CRLF)
		$FN_Flags = StringMid($FN_Flags, 7, 2) & StringMid($FN_Flags, 5, 2) & StringMid($FN_Flags, 3, 2) & StringMid($FN_Flags, 1, 2)
		ConsoleWrite("$FN_Flags = " & $FN_Flags & @CRLF)
		$FN_Flags = _File_Permissions("0x" & $FN_Flags)
		ConsoleWrite("$FN_Flags = " & $FN_Flags & @CRLF)
		$FN_NameLength = StringMid($MFTEntry, $FN_Offset + 176, 2)
		$FN_NameLength = Dec($FN_NameLength)
		ConsoleWrite("$FN_NameLength = " & $FN_NameLength & @CRLF)
		$FN_NameType = StringMid($MFTEntry, $FN_Offset + 178, 2)
		Select
			Case $FN_NameType = '00'
				$FN_NameType = 'POSIX'
			Case $FN_NameType = '01'
				$FN_NameType = 'WIN32'
			Case $FN_NameType = '02'
				$FN_NameType = 'DOS'
			Case $FN_NameType = '03'
				$FN_NameType = 'DOS+WIN32'
			Case $FN_NameType <> '00' And $FN_NameType <> '01' And $FN_NameType <> '02' And $FN_NameType <> '03'
				$FN_NameType = 'UNKNOWN'
		EndSelect
		ConsoleWrite("$FN_NameType = " & $FN_NameType & @CRLF)
		$FN_NameSpace = $FN_NameLength - 1 ;Not really
		ConsoleWrite("$FN_NameSpace = " & $FN_NameSpace & @CRLF)
		$FN_FileName = StringMid($MFTEntry, $FN_Offset + 180, ($FN_NameLength + $FN_NameSpace) * 2)
		ConsoleWrite("$FN_FileName = " & $FN_FileName & @CRLF)
		$FN_FileName = _UnicodeHexToStr($FN_FileName)
		ConsoleWrite("$FN_FileName = " & $FN_FileName & @CRLF)
		If StringLen($FN_FileName) <> $FN_NameLength Then $INVALID_FILENAME = 1
	EndIf
	If $FN_Number = 2 Then
		$FN_ParentReferenceNo_2 = StringMid($MFTEntry, $FN_Offset + 48, 12)
		;ConsoleWrite("$FN_ParentReferenceNo_2 = " & $FN_ParentReferenceNo_2 & @crlf)
		$FN_ParentReferenceNo_2 = _HexToDec(StringMid($FN_ParentReferenceNo_2, 11, 2) & StringMid($FN_ParentReferenceNo_2, 9, 2) & StringMid($FN_ParentReferenceNo_2, 7, 2) & StringMid($FN_ParentReferenceNo_2, 5, 2) & StringMid($FN_ParentReferenceNo_2, 3, 2) & StringMid($FN_ParentReferenceNo_2, 1, 2))
		;$FN_ParentReferenceNo_2 = _HexToDec($FN_ParentReferenceNo_2)
		;ConsoleWrite("$FN_ParentReferenceNo_2 = " & $FN_ParentReferenceNo_2 & @crlf)
		$FN_ParentSequenceNo_2 = StringMid($MFTEntry, $FN_Offset + 60, 4)
		;ConsoleWrite("$FN_ParentSequenceNo_2 = " & $FN_ParentSequenceNo_2 & @crlf)
		$FN_ParentSequenceNo_2 = Dec(StringMid($FN_ParentSequenceNo_2, 3, 2) & StringMid($FN_ParentSequenceNo_2, 1, 2))
		;$FN_ParentSequenceNo_2 = Dec($FN_ParentSequenceNo_2)
		;ConsoleWrite("$FN_ParentSequenceNo_2 = " & $FN_ParentSequenceNo_2 & @crlf)
		$FN_CTime_2 = StringMid($MFTEntry, $FN_Offset + 64, 16)
		$FN_CTime_2 = StringMid($FN_CTime_2, 15, 2) & StringMid($FN_CTime_2, 13, 2) & StringMid($FN_CTime_2, 11, 2) & StringMid($FN_CTime_2, 9, 2) & StringMid($FN_CTime_2, 7, 2) & StringMid($FN_CTime_2, 5, 2) & StringMid($FN_CTime_2, 3, 2) & StringMid($FN_CTime_2, 1, 2)
		;$FN_CTime_2 = _HexToDec(StringMid($FN_CTime_2,15,2) & StringMid($FN_CTime_2,13,2) & StringMid($FN_CTime_2,11,2) & StringMid($FN_CTime_2,9,2) & StringMid($FN_CTime_2,7,2) & StringMid($FN_CTime_2,5,2) & StringMid($FN_CTime_2,3,2) & StringMid($FN_CTime_2,1,2))
		$FN_CTime_2_tmp = _WinTime_UTCFileTimeToLocalFileTime("0x" & $FN_CTime_2)
		$FN_CTime_2 = _WinTime_UTCFileTimeFormat(_HexToDec($FN_CTime_2) - $tDelta, $DateTimeFormat, 2)
		$FN_CTime_2 = $FN_CTime_2 & ":" & _FillZero(StringRight($FN_CTime_2_tmp, 4))
		;
		$FN_ATime_2 = StringMid($MFTEntry, $FN_Offset + 80, 16)
		$FN_ATime_2 = StringMid($FN_ATime_2, 15, 2) & StringMid($FN_ATime_2, 13, 2) & StringMid($FN_ATime_2, 11, 2) & StringMid($FN_ATime_2, 9, 2) & StringMid($FN_ATime_2, 7, 2) & StringMid($FN_ATime_2, 5, 2) & StringMid($FN_ATime_2, 3, 2) & StringMid($FN_ATime_2, 1, 2)
		;$FN_ATime_2 = _HexToDec(StringMid($FN_ATime_2,15,2) & StringMid($FN_ATime_2,13,2) & StringMid($FN_ATime_2,11,2) & StringMid($FN_ATime_2,9,2) & StringMid($FN_ATime_2,7,2) & StringMid($FN_ATime_2,5,2) & StringMid($FN_ATime_2,3,2) & StringMid($FN_ATime_2,1,2))
		$FN_ATime_2_tmp = _WinTime_UTCFileTimeToLocalFileTime("0x" & $FN_ATime_2)
		$FN_ATime_2 = _WinTime_UTCFileTimeFormat(_HexToDec($FN_ATime_2) - $tDelta, $DateTimeFormat, 2)
		$FN_ATime_2 = $FN_ATime_2 & ":" & _FillZero(StringRight($FN_ATime_2_tmp, 4))
		;
		$FN_MTime_2 = StringMid($MFTEntry, $FN_Offset + 96, 16)
		$FN_MTime_2 = StringMid($FN_MTime_2, 15, 2) & StringMid($FN_MTime_2, 13, 2) & StringMid($FN_MTime_2, 11, 2) & StringMid($FN_MTime_2, 9, 2) & StringMid($FN_MTime_2, 7, 2) & StringMid($FN_MTime_2, 5, 2) & StringMid($FN_MTime_2, 3, 2) & StringMid($FN_MTime_2, 1, 2)
		;$FN_MTime_2 = _HexToDec(StringMid($FN_MTime_2,15,2) & StringMid($FN_MTime_2,13,2) & StringMid($FN_MTime_2,11,2) & StringMid($FN_MTime_2,9,2) & StringMid($FN_MTime_2,7,2) & StringMid($FN_MTime_2,5,2) & StringMid($FN_MTime_2,3,2) & StringMid($FN_MTime_2,1,2))
		$FN_MTime_2_tmp = _WinTime_UTCFileTimeToLocalFileTime("0x" & $FN_MTime_2)
		$FN_MTime_2 = _WinTime_UTCFileTimeFormat(_HexToDec($FN_MTime_2) - $tDelta, $DateTimeFormat, 2)
		$FN_MTime_2 = $FN_MTime_2 & ":" & _FillZero(StringRight($FN_MTime_2_tmp, 4))
		;
		$FN_RTime_2 = StringMid($MFTEntry, $FN_Offset + 112, 16)
		$FN_RTime_2 = StringMid($FN_RTime_2, 15, 2) & StringMid($FN_RTime_2, 13, 2) & StringMid($FN_RTime_2, 11, 2) & StringMid($FN_RTime_2, 9, 2) & StringMid($FN_RTime_2, 7, 2) & StringMid($FN_RTime_2, 5, 2) & StringMid($FN_RTime_2, 3, 2) & StringMid($FN_RTime_2, 1, 2)
		;$FN_RTime_2 = _HexToDec(StringMid($FN_RTime_2,15,2) & StringMid($FN_RTime_2,13,2) & StringMid($FN_RTime_2,11,2) & StringMid($FN_RTime_2,9,2) & StringMid($FN_RTime_2,7,2) & StringMid($FN_RTime_2,5,2) & StringMid($FN_RTime_2,3,2) & StringMid($FN_RTime_2,1,2))
		$FN_RTime_2_tmp = _WinTime_UTCFileTimeToLocalFileTime("0x" & $FN_RTime_2)
		$FN_RTime_2 = _WinTime_UTCFileTimeFormat(_HexToDec($FN_RTime_2) - $tDelta, $DateTimeFormat, 2)
		$FN_RTime_2 = $FN_RTime_2 & ":" & _FillZero(StringRight($FN_RTime_2_tmp, 4))
		;
		$FN_AllocSize_2 = StringMid($MFTEntry, $FN_Offset + 128, 16)
		$FN_AllocSize_2 = _HexToDec(StringMid($FN_AllocSize_2, 15, 2) & StringMid($FN_AllocSize_2, 13, 2) & StringMid($FN_AllocSize_2, 11, 2) & StringMid($FN_AllocSize_2, 9, 2) & StringMid($FN_AllocSize_2, 7, 2) & StringMid($FN_AllocSize_2, 5, 2) & StringMid($FN_AllocSize_2, 3, 2) & StringMid($FN_AllocSize_2, 1, 2))
		;$FN_AllocSize_2 = _HexToDec($FN_AllocSize_2)
		;ConsoleWrite("$FN_AllocSize_2 = " & $FN_AllocSize_2 & @crlf)
		$FN_RealSize_2 = StringMid($MFTEntry, $FN_Offset + 144, 16)
		$FN_RealSize_2 = _HexToDec(StringMid($FN_RealSize_2, 15, 2) & StringMid($FN_RealSize_2, 13, 2) & StringMid($FN_RealSize_2, 11, 2) & StringMid($FN_RealSize_2, 9, 2) & StringMid($FN_RealSize_2, 7, 2) & StringMid($FN_RealSize_2, 5, 2) & StringMid($FN_RealSize_2, 3, 2) & StringMid($FN_RealSize_2, 1, 2))
		;$FN_RealSize_2 = _HexToDec($FN_RealSize_2)
		;ConsoleWrite("$FN_RealSize_2 = " & $FN_RealSize_2 & @crlf)
		$FN_Flags_2 = StringMid($MFTEntry, $FN_Offset + 160, 8)
		;ConsoleWrite("$FN_Flags_2 = " & $FN_Flags_2 & @crlf)
		$FN_Flags_2 = _File_Permissions("0x" & $FN_Flags_2)
		;ConsoleWrite("$FN_Flags_2 = " & $FN_Flags_2 & @crlf)
		$FN_NameLength_2 = StringMid($MFTEntry, $FN_Offset + 176, 2)
		$FN_NameLength_2 = Dec($FN_NameLength_2)
		;ConsoleWrite("$FN_NameLength_2 = " & $FN_NameLength_2 & @crlf)
		$FN_NameType_2 = StringMid($MFTEntry, $FN_Offset + 178, 2)
		Select
			Case $FN_NameType_2 = '01'
				$FN_NameType_2 = 'UNICODE'
			Case $FN_NameType_2 = '02'
				$FN_NameType_2 = 'DOS'
			Case $FN_NameType_2 = '03'
				$FN_NameType_2 = 'POSIX'
			Case $FN_NameType_2 <> '01' And $FN_NameType_2 <> '02' And $FN_NameType_2 <> '03'
				$FN_NameType_2 = 'UNKNOWN'
		EndSelect
		$FN_NameSpace_2 = $FN_NameLength_2 - 1 ;Not really
		;ConsoleWrite("$FN_NameSpace_2 = " & $FN_NameSpace_2 & @crlf)
		$FN_FileName_2 = StringMid($MFTEntry, $FN_Offset + 180, ($FN_NameLength_2 + $FN_NameSpace_2) * 2)
		;ConsoleWrite("$FN_FileName_2 = " & $FN_FileName_2 & @crlf)
		$FN_FileName_2 = _UnicodeHexToStr($FN_FileName_2)
		;ConsoleWrite("$FN_FileName_2 = " & $FN_FileName_2 & @crlf)
		If StringLen($FN_FileName_2) <> $FN_NameLength_2 Then $INVALID_FILENAME_2 = 1
	EndIf
	If $FN_Number = 3 Then
		$FN_ParentReferenceNo_3 = StringMid($MFTEntry, $FN_Offset + 48, 12)
		$FN_ParentReferenceNo_3 = StringMid($FN_ParentReferenceNo_3, 11, 2) & StringMid($FN_ParentReferenceNo_3, 9, 2) & StringMid($FN_ParentReferenceNo_3, 7, 2) & StringMid($FN_ParentReferenceNo_3, 5, 2) & StringMid($FN_ParentReferenceNo_3, 3, 2) & StringMid($FN_ParentReferenceNo_3, 1, 2)
		$FN_ParentReferenceNo_3 = _HexToDec($FN_ParentReferenceNo_3)
		$FN_ParentSequenceNo_3 = StringMid($MFTEntry, $FN_Offset + 60, 4)
		$FN_ParentSequenceNo_3 = StringMid($FN_ParentSequenceNo_3, 3, 2) & StringMid($FN_ParentSequenceNo_3, 1, 2)
		$FN_ParentSequenceNo_3 = Dec($FN_ParentSequenceNo_3)
		$FN_CTime_3 = StringMid($MFTEntry, $FN_Offset + 64, 16)
		$FN_CTime_3 = StringMid($FN_CTime_3, 15, 2) & StringMid($FN_CTime_3, 13, 2) & StringMid($FN_CTime_3, 11, 2) & StringMid($FN_CTime_3, 9, 2) & StringMid($FN_CTime_3, 7, 2) & StringMid($FN_CTime_3, 5, 2) & StringMid($FN_CTime_3, 3, 2) & StringMid($FN_CTime_3, 1, 2)
		$FN_CTime_3 = _HexToDec($FN_CTime_3)
		$FN_CTime_3 = _WinTime_UTCFileTimeFormat($FN_CTime_3 - $tDelta, $DateTimeFormat, 2)
		$FN_ATime_3 = StringMid($MFTEntry, $FN_Offset + 80, 16)
		$FN_ATime_3 = StringMid($FN_ATime_3, 15, 2) & StringMid($FN_ATime_3, 13, 2) & StringMid($FN_ATime_3, 11, 2) & StringMid($FN_ATime_3, 9, 2) & StringMid($FN_ATime_3, 7, 2) & StringMid($FN_ATime_3, 5, 2) & StringMid($FN_ATime_3, 3, 2) & StringMid($FN_ATime_3, 1, 2)
		$FN_ATime_3 = _HexToDec($FN_ATime_3)
		$FN_ATime_3 = _WinTime_UTCFileTimeFormat($FN_ATime_3 - $tDelta, $DateTimeFormat, 2)
		$FN_MTime_3 = StringMid($MFTEntry, $FN_Offset + 96, 16)
		$FN_MTime_3 = StringMid($FN_MTime_3, 15, 2) & StringMid($FN_MTime_3, 13, 2) & StringMid($FN_MTime_3, 11, 2) & StringMid($FN_MTime_3, 9, 2) & StringMid($FN_MTime_3, 7, 2) & StringMid($FN_MTime_3, 5, 2) & StringMid($FN_MTime_3, 3, 2) & StringMid($FN_MTime_3, 1, 2)
		$FN_MTime_3 = _HexToDec($FN_MTime_3)
		$FN_MTime_3 = _WinTime_UTCFileTimeFormat($FN_MTime_3 - $tDelta, $DateTimeFormat, 2)
		$FN_RTime_3 = StringMid($MFTEntry, $FN_Offset + 112, 16)
		$FN_RTime_3 = StringMid($FN_RTime_3, 15, 2) & StringMid($FN_RTime_3, 13, 2) & StringMid($FN_RTime_3, 11, 2) & StringMid($FN_RTime_3, 9, 2) & StringMid($FN_RTime_3, 7, 2) & StringMid($FN_RTime_3, 5, 2) & StringMid($FN_RTime_3, 3, 2) & StringMid($FN_RTime_3, 1, 2)
		$FN_RTime_3 = _HexToDec($FN_RTime_3)
		$FN_RTime_3 = _WinTime_UTCFileTimeFormat($FN_RTime_3 - $tDelta, $DateTimeFormat, 2)
		$FN_AllocSize_3 = StringMid($MFTEntry, $FN_Offset + 128, 16)
		$FN_AllocSize_3 = StringMid($FN_AllocSize_3, 15, 2) & StringMid($FN_AllocSize_3, 13, 2) & StringMid($FN_AllocSize_3, 11, 2) & StringMid($FN_AllocSize_3, 9, 2) & StringMid($FN_AllocSize_3, 7, 2) & StringMid($FN_AllocSize_3, 5, 2) & StringMid($FN_AllocSize_3, 3, 2) & StringMid($FN_AllocSize_3, 1, 2)
		$FN_AllocSize_3 = _HexToDec($FN_AllocSize_3)
		$FN_RealSize_3 = StringMid($MFTEntry, $FN_Offset + 144, 16)
		$FN_RealSize_3 = StringMid($FN_RealSize_3, 15, 2) & StringMid($FN_RealSize_3, 13, 2) & StringMid($FN_RealSize_3, 11, 2) & StringMid($FN_RealSize_3, 9, 2) & StringMid($FN_RealSize_3, 7, 2) & StringMid($FN_RealSize_3, 5, 2) & StringMid($FN_RealSize_3, 3, 2) & StringMid($FN_RealSize_3, 1, 2)
		$FN_RealSize_3 = _HexToDec($FN_RealSize_3)
		$FN_Flags_3 = StringMid($MFTEntry, $FN_Offset + 160, 8)
		$FN_Flags_3 = _File_Permissions("0x" & $FN_Flags_3)
		$FN_NameLength_3 = Dec(StringMid($MFTEntry, $FN_Offset + 176, 2))
		;$FN_NameLength_3 = Dec($FN_NameLength_3)
		$FN_NameType_3 = StringMid($MFTEntry, $FN_Offset + 178, 2)
		Select
			Case $FN_NameType_3 = '01'
				$FN_NameType_3 = 'UNICODE'
			Case $FN_NameType_3 = '02'
				$FN_NameType_3 = 'DOS'
			Case $FN_NameType_3 = '03'
				$FN_NameType_3 = 'POSIX'
			Case $FN_NameType_3 <> '01' And $FN_NameType_3 <> '02' And $FN_NameType_3 <> '03'
				$FN_NameType_3 = 'UNKNOWN'
		EndSelect
		$FN_NameSpace_3 = $FN_NameLength_3 - 1 ;Not really
		$FN_FileName_3 = StringMid($MFTEntry, $FN_Offset + 180, ($FN_NameLength_3 + $FN_NameSpace_3) * 2)
		$FN_FileName_3 = _UnicodeHexToStr($FN_FileName_3)
		If StringLen($FN_FileName_3) <> $FN_NameLength_3 Then $INVALID_FILENAME_3 = 1
	EndIf
	If $FN_Number = 4 Then
		$FN_ParentReferenceNo_4 = StringMid($MFTEntry, $FN_Offset + 48, 12)
		$FN_ParentReferenceNo_4 = StringMid($FN_ParentReferenceNo_4, 11, 2) & StringMid($FN_ParentReferenceNo_4, 9, 2) & StringMid($FN_ParentReferenceNo_4, 7, 2) & StringMid($FN_ParentReferenceNo_4, 5, 2) & StringMid($FN_ParentReferenceNo_4, 3, 2) & StringMid($FN_ParentReferenceNo_4, 1, 2)
		$FN_ParentReferenceNo_4 = _HexToDec($FN_ParentReferenceNo_4)
		$FN_ParentSequenceNo_4 = StringMid($MFTEntry, $FN_Offset + 60, 4)
		$FN_ParentSequenceNo_4 = Dec(StringMid($FN_ParentSequenceNo_4, 3, 2) & StringMid($FN_ParentSequenceNo_4, 1, 2))
		;$FN_ParentSequenceNo_4 = Dec($FN_ParentSequenceNo_4)
		$FN_CTime_4 = StringMid($MFTEntry, $FN_Offset + 64, 16)
		$FN_CTime_4 = StringMid($FN_CTime_4, 15, 2) & StringMid($FN_CTime_4, 13, 2) & StringMid($FN_CTime_4, 11, 2) & StringMid($FN_CTime_4, 9, 2) & StringMid($FN_CTime_4, 7, 2) & StringMid($FN_CTime_4, 5, 2) & StringMid($FN_CTime_4, 3, 2) & StringMid($FN_CTime_4, 1, 2)
		$FN_CTime_4 = _HexToDec($FN_CTime_4)
		$FN_CTime_4 = _WinTime_UTCFileTimeFormat($FN_CTime_4 - $tDelta, $DateTimeFormat, 2)
		$FN_ATime_4 = StringMid($MFTEntry, $FN_Offset + 80, 16)
		$FN_ATime_4 = StringMid($FN_ATime_4, 15, 2) & StringMid($FN_ATime_4, 13, 2) & StringMid($FN_ATime_4, 11, 2) & StringMid($FN_ATime_4, 9, 2) & StringMid($FN_ATime_4, 7, 2) & StringMid($FN_ATime_4, 5, 2) & StringMid($FN_ATime_4, 3, 2) & StringMid($FN_ATime_4, 1, 2)
		$FN_ATime_4 = _HexToDec($FN_ATime_4)
		$FN_ATime_4 = _WinTime_UTCFileTimeFormat($FN_ATime_4 - $tDelta, $DateTimeFormat, 2)
		$FN_MTime_4 = StringMid($MFTEntry, $FN_Offset + 96, 16)
		$FN_MTime_4 = StringMid($FN_MTime_4, 15, 2) & StringMid($FN_MTime_4, 13, 2) & StringMid($FN_MTime_4, 11, 2) & StringMid($FN_MTime_4, 9, 2) & StringMid($FN_MTime_4, 7, 2) & StringMid($FN_MTime_4, 5, 2) & StringMid($FN_MTime_4, 3, 2) & StringMid($FN_MTime_4, 1, 2)
		$FN_MTime_4 = _HexToDec($FN_MTime_4)
		$FN_MTime_4 = _WinTime_UTCFileTimeFormat($FN_MTime_4 - $tDelta, $DateTimeFormat, 2)
		$FN_RTime_4 = StringMid($MFTEntry, $FN_Offset + 112, 16)
		$FN_RTime_4 = StringMid($FN_RTime_4, 15, 2) & StringMid($FN_RTime_4, 13, 2) & StringMid($FN_RTime_4, 11, 2) & StringMid($FN_RTime_4, 9, 2) & StringMid($FN_RTime_4, 7, 2) & StringMid($FN_RTime_4, 5, 2) & StringMid($FN_RTime_4, 3, 2) & StringMid($FN_RTime_4, 1, 2)
		$FN_RTime_4 = _HexToDec($FN_RTime_4)
		$FN_RTime_4 = _WinTime_UTCFileTimeFormat($FN_RTime_4 - $tDelta, $DateTimeFormat, 2)
		$FN_AllocSize_4 = StringMid($MFTEntry, $FN_Offset + 128, 16)
		$FN_AllocSize_4 = StringMid($FN_AllocSize_4, 15, 2) & StringMid($FN_AllocSize_4, 13, 2) & StringMid($FN_AllocSize_4, 11, 2) & StringMid($FN_AllocSize_4, 9, 2) & StringMid($FN_AllocSize_4, 7, 2) & StringMid($FN_AllocSize_4, 5, 2) & StringMid($FN_AllocSize_4, 3, 2) & StringMid($FN_AllocSize_4, 1, 2)
		$FN_AllocSize_4 = _HexToDec($FN_AllocSize_4)
		$FN_RealSize_4 = StringMid($MFTEntry, $FN_Offset + 144, 16)
		$FN_RealSize_4 = StringMid($FN_RealSize_4, 15, 2) & StringMid($FN_RealSize_4, 13, 2) & StringMid($FN_RealSize_4, 11, 2) & StringMid($FN_RealSize_4, 9, 2) & StringMid($FN_RealSize_4, 7, 2) & StringMid($FN_RealSize_4, 5, 2) & StringMid($FN_RealSize_4, 3, 2) & StringMid($FN_RealSize_4, 1, 2)
		$FN_RealSize_4 = _HexToDec($FN_RealSize_4)
		$FN_Flags_4 = StringMid($MFTEntry, $FN_Offset + 160, 8)
		$FN_Flags_4 = _File_Permissions("0x" & $FN_Flags_4)
		$FN_NameLength_4 = Dec(StringMid($MFTEntry, $FN_Offset + 176, 2))
		;$FN_NameLength_4 = Dec($FN_NameLength_4)
		$FN_NameType_4 = StringMid($MFTEntry, $FN_Offset + 178, 2)
		Select
			Case $FN_NameType_4 = '01'
				$FN_NameType_4 = 'UNICODE'
			Case $FN_NameType_4 = '02'
				$FN_NameType_4 = 'DOS'
			Case $FN_NameType_4 = '03'
				$FN_NameType_4 = 'POSIX'
			Case $FN_NameType_4 <> '01' And $FN_NameType_4 <> '02' And $FN_NameType_4 <> '03'
				$FN_NameType_4 = 'UNKNOWN'
		EndSelect
		$FN_NameSpace_4 = $FN_NameLength_4 - 1 ;Not really
		$FN_FileName_4 = StringMid($MFTEntry, $FN_Offset + 180, ($FN_NameLength_4 + $FN_NameSpace_4) * 2)
		$FN_FileName_4 = _UnicodeHexToStr($FN_FileName_4)
	EndIf
	Return
EndFunc   ;==>_Get_FileName

Func _Get_ObjectID($MFTEntry, $OBJECTID_Offset, $OBJECTID_Size)
	$GUID_ObjectID = StringMid($MFTEntry, $OBJECTID_Offset + 48, 32)
	ConsoleWrite("$GUID_ObjectID = " & $GUID_ObjectID & @CRLF)
	$GUID_ObjectID = StringMid($GUID_ObjectID, 1, 8) & "-" & StringMid($GUID_ObjectID, 9, 4) & "-" & StringMid($GUID_ObjectID, 13, 4) & "-" & StringMid($GUID_ObjectID, 17, 4) & "-" & StringMid($GUID_ObjectID, 21, 12)
	If $OBJECTID_Size - 24 = 32 Then
		$GUID_BirthVolumeID = StringMid($MFTEntry, $OBJECTID_Offset + 80, 32)
		ConsoleWrite("$GUID_BirthVolumeID = " & $GUID_BirthVolumeID & @CRLF)
		$GUID_BirthVolumeID = StringMid($GUID_BirthVolumeID, 1, 8) & "-" & StringMid($GUID_BirthVolumeID, 9, 4) & "-" & StringMid($GUID_BirthVolumeID, 13, 4) & "-" & StringMid($GUID_BirthVolumeID, 17, 4) & "-" & StringMid($GUID_BirthVolumeID, 21, 12)
		$GUID_BirthObjectID = "NOT PRESENT"
		$GUID_BirthDomainID = "NOT PRESENT"
		Return
	EndIf
	If $OBJECTID_Size - 24 = 48 Then
		$GUID_BirthVolumeID = StringMid($MFTEntry, $OBJECTID_Offset + 80, 32)
		ConsoleWrite("$GUID_BirthVolumeID = " & $GUID_BirthVolumeID & @CRLF)
		$GUID_BirthVolumeID = StringMid($GUID_BirthVolumeID, 1, 8) & "-" & StringMid($GUID_BirthVolumeID, 9, 4) & "-" & StringMid($GUID_BirthVolumeID, 13, 4) & "-" & StringMid($GUID_BirthVolumeID, 17, 4) & "-" & StringMid($GUID_BirthVolumeID, 21, 12)
		$GUID_BirthObjectID = StringMid($MFTEntry, $OBJECTID_Offset + 112, 32)
		ConsoleWrite("$GUID_BirthObjectID = " & $GUID_BirthObjectID & @CRLF)
		$GUID_BirthObjectID = StringMid($GUID_BirthObjectID, 1, 8) & "-" & StringMid($GUID_BirthObjectID, 9, 4) & "-" & StringMid($GUID_BirthObjectID, 13, 4) & "-" & StringMid($GUID_BirthObjectID, 17, 4) & "-" & StringMid($GUID_BirthObjectID, 21, 12)
		$GUID_BirthDomainID = "NOT PRESENT"
		Return
	EndIf
	If $OBJECTID_Size - 24 = 64 Then
		$GUID_BirthVolumeID = StringMid($MFTEntry, $OBJECTID_Offset + 80, 32)
		ConsoleWrite("$GUID_BirthVolumeID = " & $GUID_BirthVolumeID & @CRLF)
		$GUID_BirthVolumeID = StringMid($GUID_BirthVolumeID, 1, 8) & "-" & StringMid($GUID_BirthVolumeID, 9, 4) & "-" & StringMid($GUID_BirthVolumeID, 13, 4) & "-" & StringMid($GUID_BirthVolumeID, 17, 4) & "-" & StringMid($GUID_BirthVolumeID, 21, 12)
		$GUID_BirthObjectID = StringMid($MFTEntry, $OBJECTID_Offset + 112, 32)
		ConsoleWrite("$GUID_BirthObjectID = " & $GUID_BirthObjectID & @CRLF)
		$GUID_BirthObjectID = StringMid($GUID_BirthObjectID, 1, 8) & "-" & StringMid($GUID_BirthObjectID, 9, 4) & "-" & StringMid($GUID_BirthObjectID, 13, 4) & "-" & StringMid($GUID_BirthObjectID, 17, 4) & "-" & StringMid($GUID_BirthObjectID, 21, 12)
		$GUID_BirthDomainID = StringMid($MFTEntry, $OBJECTID_Offset + 144, 32)
		ConsoleWrite("$GUID_BirthDomainID = " & $GUID_BirthDomainID & @CRLF)
		$GUID_BirthDomainID = StringMid($GUID_BirthDomainID, 1, 8) & "-" & StringMid($GUID_BirthDomainID, 9, 4) & "-" & StringMid($GUID_BirthDomainID, 13, 4) & "-" & StringMid($GUID_BirthDomainID, 17, 4) & "-" & StringMid($GUID_BirthDomainID, 21, 12)
		Return
	EndIf
	$GUID_BirthVolumeID = "NOT PRESENT"
	$GUID_BirthObjectID = "NOT PRESENT"
	$GUID_BirthDomainID = "NOT PRESENT"
	Return
EndFunc   ;==>_Get_ObjectID

Func _Get_SecurityDescriptor()
	ConsoleWrite("Get_SecurityDescriptor Function not implemented yet." & @CRLF)
	Return
EndFunc   ;==>_Get_SecurityDescriptor

Func _Get_VolumeName($MFTEntry, $VOLUME_NAME_Offset, $VOLUME_NAME_Size)
	If $VOLUME_NAME_Size - 24 > 0 Then
		$VOLUME_NAME_NAME = StringMid($MFTEntry, $VOLUME_NAME_Offset + 48, ($VOLUME_NAME_Size - 24) * 2)
		$VOLUME_NAME_NAME = _UnicodeHexToStr($VOLUME_NAME_NAME)
		;	$VOLUME_NAME_NAME = _HexToString($VOLUME_NAME_NAME)
		ConsoleWrite("$VOLUME_NAME_NAME = " & $VOLUME_NAME_NAME & @CRLF)
		Return
	EndIf
	$VOLUME_NAME_NAME = "EMPTY"
	Return
EndFunc   ;==>_Get_VolumeName

Func _Get_VolumeInformation($MFTEntry, $VOLUME_INFO_Offset, $VOLUME_INFO_Size)
	$VOL_INFO_NTFS_VERSION = Dec(StringMid($MFTEntry, $VOLUME_INFO_Offset + 64, 2)) & "," & Dec(StringMid($MFTEntry, $VOLUME_INFO_Offset + 66, 2))
	ConsoleWrite("$VOL_INFO_NTFS_VERSION = " & $VOL_INFO_NTFS_VERSION & @CRLF)
	$VOL_INFO_FLAGS = StringMid($MFTEntry, $VOLUME_INFO_Offset + 68, 4)
	$VOL_INFO_FLAGS = StringMid($VOL_INFO_FLAGS, 3, 2) & StringMid($VOL_INFO_FLAGS, 1, 2)
	$VOL_INFO_FLAGS = _VolInfoFlag("0x" & $VOL_INFO_FLAGS)
	ConsoleWrite("$VOL_INFO_FLAGS = " & $VOL_INFO_FLAGS & @CRLF)
	Return
EndFunc   ;==>_Get_VolumeInformation

Func _Get_Data($MFTEntry, $DATA_Offset, $DATA_Size, $DATA_Number)
	If $DATA_Number = 1 Then
		;ConsoleWrite("$DATA_Size = " & $DATA_Size & @crlf)
		$DATA_NonResidentFlag = StringMid($MFTEntry, $DATA_Offset + 16, 2)
		ConsoleWrite("$DATA_NonResidentFlag = " & $DATA_NonResidentFlag & @CRLF)
		$DATA_NameLength = Dec(StringMid($MFTEntry, $DATA_Offset + 18, 2))
		;$DATA_NameLength = Dec($DATA_NameLength)
		ConsoleWrite("$DATA_NameLength = " & $DATA_NameLength & @CRLF)
		$DATA_NameRelativeOffset = StringMid($MFTEntry, $DATA_Offset + 20, 4)
		ConsoleWrite("$DATA_NameRelativeOffset = " & $DATA_NameRelativeOffset & @CRLF)
		$DATA_NameRelativeOffset = Dec(StringMid($DATA_NameRelativeOffset, 3, 2) & StringMid($DATA_NameRelativeOffset, 1, 2))
		;$DATA_NameRelativeOffset = Dec($DATA_NameRelativeOffset)
		ConsoleWrite("$DATA_NameRelativeOffset = " & $DATA_NameRelativeOffset & @CRLF)
		$DATA_Flags = StringMid($MFTEntry, $DATA_Offset + 24, 4)
		$DATA_Flags = StringMid($DATA_Flags, 3, 2) & StringMid($DATA_Flags, 1, 2)
		ConsoleWrite("$DATA_Flags = " & $DATA_Flags & @CRLF)
		$DATA_Flags = _AttribHeaderFlags("0x" & $DATA_Flags)
		ConsoleWrite("$DATA_Flags = " & $DATA_Flags & @CRLF)
		#cs
			Select
			Case $DATA_Flags = '0000'
			$DATA_Flags = 'NOT SET'
			Case $DATA_Flags = '0001'
			$DATA_Flags = 'COMPRESSED'
			Case $DATA_Flags = '4000'
			$DATA_Flags = 'ENCRYPTED'
			Case $DATA_Flags = '8000'
			$DATA_Flags = 'SPARSE'
			Case $DATA_Flags <> '0001' AND $DATA_Flags <> '4000' AND $DATA_Flags <> '8000' AND $DATA_Flags <> '0000'
			$DATA_Flags = 'UNKNOWN'
			EndSelect
		#ce
		If $DATA_NameLength > 0 Then
			$DATA_NameSpace = $DATA_NameLength - 1
			$DATA_Name = StringMid($MFTEntry, $DATA_Offset + ($DATA_NameRelativeOffset * 2), ($DATA_NameLength + $DATA_NameSpace) * 2)
			$DATA_Name = _UnicodeHexToStr($DATA_Name)
		EndIf
		ConsoleWrite("$DATA_Name = " & $DATA_Name & @CRLF)
		If $DATA_NonResidentFlag = '01' Then
			$DATA_StartVCN = StringMid($MFTEntry, $DATA_Offset + 32, 16)
			ConsoleWrite("$DATA_StartVCN = " & $DATA_StartVCN & @CRLF)
			$DATA_StartVCN = _HexToDec(StringMid($DATA_StartVCN, 15, 2) & StringMid($DATA_StartVCN, 13, 2) & StringMid($DATA_StartVCN, 11, 2) & StringMid($DATA_StartVCN, 9, 2) & StringMid($DATA_StartVCN, 7, 2) & StringMid($DATA_StartVCN, 5, 2) & StringMid($DATA_StartVCN, 3, 2) & StringMid($DATA_StartVCN, 1, 2))
			ConsoleWrite("$DATA_StartVCN = " & $DATA_StartVCN & @CRLF)
			;	$DATA_StartVCN = _HexToDec($DATA_StartVCN)
			;	ConsoleWrite("$DATA_StartVCN = " & $DATA_StartVCN & @crlf)
			$DATA_LastVCN = StringMid($MFTEntry, $DATA_Offset + 48, 16)
			ConsoleWrite("$DATA_LastVCN = " & $DATA_LastVCN & @CRLF)
			$DATA_LastVCN = _HexToDec(StringMid($DATA_LastVCN, 15, 2) & StringMid($DATA_LastVCN, 13, 2) & StringMid($DATA_LastVCN, 11, 2) & StringMid($DATA_LastVCN, 9, 2) & StringMid($DATA_LastVCN, 7, 2) & StringMid($DATA_LastVCN, 5, 2) & StringMid($DATA_LastVCN, 3, 2) & StringMid($DATA_LastVCN, 1, 2))
			ConsoleWrite("$DATA_LastVCN = " & $DATA_LastVCN & @CRLF)
			;	$DATA_LastVCN = _HexToDec($DATA_LastVCN)
			;	ConsoleWrite("$DATA_LastVCN = " & $DATA_LastVCN & @crlf)
			$DATA_VCNs = $DATA_LastVCN - $DATA_StartVCN
			ConsoleWrite("$DATA_VCNs = " & $DATA_VCNs & @CRLF)
			$DATA_CompressionUnitSize = StringMid($MFTEntry, $DATA_Offset + 68, 4)
			$DATA_CompressionUnitSize = Dec(StringMid($DATA_CompressionUnitSize, 3, 2) & StringMid($DATA_CompressionUnitSize, 1, 2))
			;	$DATA_CompressionUnitSize = Dec($DATA_CompressionUnitSize)
			ConsoleWrite("$DATA_CompressionUnitSize = " & $DATA_CompressionUnitSize & @CRLF)
			$DATA_AllocatedSize = StringMid($MFTEntry, $DATA_Offset + 80, 16)
			ConsoleWrite("$DATA_AllocatedSize = " & $DATA_AllocatedSize & @CRLF)
			$DATA_AllocatedSize = _HexToDec(StringMid($DATA_AllocatedSize, 15, 2) & StringMid($DATA_AllocatedSize, 13, 2) & StringMid($DATA_AllocatedSize, 11, 2) & StringMid($DATA_AllocatedSize, 9, 2) & StringMid($DATA_AllocatedSize, 7, 2) & StringMid($DATA_AllocatedSize, 5, 2) & StringMid($DATA_AllocatedSize, 3, 2) & StringMid($DATA_AllocatedSize, 1, 2))
			ConsoleWrite("$DATA_AllocatedSize = " & $DATA_AllocatedSize & @CRLF)
			;	$DATA_AllocatedSize = _HexToDec($DATA_AllocatedSize)
			;	ConsoleWrite("$DATA_AllocatedSize = " & $DATA_AllocatedSize & @crlf)
			$DATA_RealSize = StringMid($MFTEntry, $DATA_Offset + 96, 16)
			ConsoleWrite("$DATA_RealSize = " & $DATA_RealSize & @CRLF)
			$DATA_RealSize = _HexToDec(StringMid($DATA_RealSize, 15, 2) & StringMid($DATA_RealSize, 13, 2) & StringMid($DATA_RealSize, 11, 2) & StringMid($DATA_RealSize, 9, 2) & StringMid($DATA_RealSize, 7, 2) & StringMid($DATA_RealSize, 5, 2) & StringMid($DATA_RealSize, 3, 2) & StringMid($DATA_RealSize, 1, 2))
			ConsoleWrite("$DATA_RealSize = " & $DATA_RealSize & @CRLF)
			$FileSizeBytes = $DATA_RealSize
			;	$DATA_RealSize = _HexToDec($DATA_RealSize)
			;	ConsoleWrite("$DATA_RealSize = " & $DATA_RealSize & @crlf)
			$DATA_InitializedStreamSize = StringMid($MFTEntry, $DATA_Offset + 112, 16)
			ConsoleWrite("$DATA_InitializedStreamSize = " & $DATA_InitializedStreamSize & @CRLF)
			$DATA_InitializedStreamSize = _HexToDec(StringMid($DATA_InitializedStreamSize, 15, 2) & StringMid($DATA_InitializedStreamSize, 13, 2) & StringMid($DATA_InitializedStreamSize, 11, 2) & StringMid($DATA_InitializedStreamSize, 9, 2) & StringMid($DATA_InitializedStreamSize, 7, 2) & StringMid($DATA_InitializedStreamSize, 5, 2) & StringMid($DATA_InitializedStreamSize, 3, 2) & StringMid($DATA_InitializedStreamSize, 1, 2))
			ConsoleWrite("$DATA_InitializedStreamSize = " & $DATA_InitializedStreamSize & @CRLF)
			;	$DATA_InitializedStreamSize = _HexToDec($DATA_InitializedStreamSize)
			;	ConsoleWrite("$DATA_InitializedStreamSize = " & $DATA_InitializedStreamSize & @crlf)
			#cs
				$RunListOffset = StringMid($MFTEntry,$DATA_Offset+64,4)
				ConsoleWrite("$RunListOffset = " & $RunListOffset & @crlf)
				$RunListOffset = StringMid($RunListOffset,3,2) & StringMid($RunListOffset,1,2)
				$RunListOffset = Dec($RunListOffset)
				ConsoleWrite("$RunListOffset = " & $RunListOffset & @crlf)
				$RunListID = StringMid($MFTEntry,$DATA_Offset+($RunListOffset*2),2)
				ConsoleWrite("$RunListID = " & $RunListID & @crlf)
				$RunListSectorsLenght = Dec(StringMid($RunListID,2,1))
				ConsoleWrite("$RunListSectorsLenght = " & $RunListSectorsLenght & @crlf)
				$RunListClusterLenght = Dec(StringMid($RunListID,1,1))
				ConsoleWrite("$RunListClusterLenght = " & $RunListClusterLenght & @crlf)
				$RunListSectors = StringMid($MFTEntry,$DATA_Offset+($RunListOffset*2)+2,$RunListSectorsLenght*2)
				ConsoleWrite("$RunListSectors = " & $RunListSectors & @crlf)
				$r = 1
				$entry = ''
				For $u = 0 To $RunListSectorsLenght-1
				$mod = StringMid($RunListSectors,($RunListSectorsLenght*2)-(($u*2)+1),2)
				;			ConsoleWrite($mod & @crlf)
				$entry &= $mod
				Next
				$RunListSectors = Dec($entry)
				;	_ArrayInsert($RUN_Sectors,1,$RunListSectors)
				ConsoleWrite("$RunListSectors = " & $RunListSectors & @crlf)
				$RunListCluster = StringMid($MFTEntry,$DATA_Offset+($RunListOffset*2)+2+($RunListSectorsLenght*2),$RunListClusterLenght*2)
				ConsoleWrite("$RunListCluster = " & $RunListCluster & @crlf)
				$entry = ''
				For $u = 0 To $RunListClusterLenght-1
				$mod = StringMid($RunListCluster,($RunListClusterLenght*2)-(($u*2)+1),2)
				;			ConsoleWrite($mod & @crlf)
				$entry &= $mod
				Next
				$RunListCluster = Dec($entry)
				;	_ArrayInsert($RUN_Cluster,1,$RunListCluster)
				ConsoleWrite("$RunListCluster = " & $RunListCluster & @crlf)
				If $RunListSectors = $DATA_VCNs+1 Then
				ConsoleWrite("No more data runs." & @crlf)
				Else
				ConsoleWrite("More data runs exist." & @crlf)
				$NewRunOffsetBase = $DATA_Offset+($RunListOffset*2)+2+($RunListSectorsLenght+$RunListClusterLenght)*2
				;		_GetAllRuns($MFTEntry,$DATA_Offset,$DATA_Size,$DATA_VCNs,$NewRunOffsetBase)
				EndIf
				;	_ReassembleDataRuns()
			#ce
		ElseIf $DATA_NonResidentFlag = '00' Then
			$DATA_LengthOfAttribute = StringMid($MFTEntry, $DATA_Offset + 32, 8)
			$DATA_LengthOfAttribute = Dec(StringMid($DATA_LengthOfAttribute, 7, 2) & StringMid($DATA_LengthOfAttribute, 5, 2) & StringMid($DATA_LengthOfAttribute, 3, 2) & StringMid($DATA_LengthOfAttribute, 1, 2))
			$FileSizeBytes = $DATA_LengthOfAttribute
			;	$DATA_LengthOfAttribute = Dec($DATA_LengthOfAttribute)
			$DATA_OffsetToAttribute = StringMid($MFTEntry, $DATA_Offset + 40, 4)
			$DATA_OffsetToAttribute = Dec(StringMid($DATA_OffsetToAttribute, 3, 2) & StringMid($DATA_OffsetToAttribute, 1, 2))
			;	$DATA_OffsetToAttribute = Dec($DATA_OffsetToAttribute)
			$DATA_IndexedFlag = Dec(StringMid($MFTEntry, $DATA_Offset + 44, 2))
			;	$DATA_IndexedFlag = Dec($DATA_IndexedFlag)
		EndIf
	EndIf
	If $DATA_Number = 2 Then
		$DATA_NonResidentFlag_2 = StringMid($MFTEntry, $DATA_Offset + 16, 2)
		ConsoleWrite("$DATA_NonResidentFlag_2 = " & $DATA_NonResidentFlag_2 & @CRLF)
		$DATA_NameLength_2 = Dec(StringMid($MFTEntry, $DATA_Offset + 18, 2))
		;$DATA_NameLength_2 = Dec($DATA_NameLength_2)
		ConsoleWrite("$DATA_NameLength_2 = " & $DATA_NameLength_2 & @CRLF)
		$DATA_NameRelativeOffset_2 = StringMid($MFTEntry, $DATA_Offset + 20, 4)
		ConsoleWrite("$DATA_NameRelativeOffset_2 = " & $DATA_NameRelativeOffset_2 & @CRLF)
		$DATA_NameRelativeOffset_2 = Dec(StringMid($DATA_NameRelativeOffset_2, 3, 2) & StringMid($DATA_NameRelativeOffset_2, 1, 2))
		;$DATA_NameRelativeOffset_2 = Dec($DATA_NameRelativeOffset_2)
		ConsoleWrite("$DATA_NameRelativeOffset_2 = " & $DATA_NameRelativeOffset_2 & @CRLF)
		$DATA_Flags_2 = StringMid($MFTEntry, $DATA_Offset + 24, 4)
		$DATA_Flags_2 = StringMid($DATA_Flags_2, 3, 2) & StringMid($DATA_Flags_2, 1, 2)
		ConsoleWrite("$DATA_Flags_2 = " & $DATA_Flags_2 & @CRLF)
		$DATA_Flags_2 = _AttribHeaderFlags("0x" & $DATA_Flags_2)
		ConsoleWrite("$DATA_Flags_2 = " & $DATA_Flags_2 & @CRLF)
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
			$DATA_NameSpace_2 = $DATA_NameLength_2 - 1
			$DATA_Name_2 = StringMid($MFTEntry, $DATA_Offset + ($DATA_NameRelativeOffset_2 * 2), ($DATA_NameLength_2 + $DATA_NameSpace_2) * 2)
			$DATA_Name_2 = _UnicodeHexToStr($DATA_Name_2)
		EndIf
		ConsoleWrite("$DATA_Name_2 = " & $DATA_Name_2 & @CRLF)
		If $DATA_NonResidentFlag_2 = '01' Then
			$DATA_StartVCN_2 = StringMid($MFTEntry, $DATA_Offset + 32, 16)
			ConsoleWrite("$DATA_StartVCN_2 = " & $DATA_StartVCN_2 & @CRLF)
			$DATA_StartVCN_2 = StringMid($DATA_StartVCN_2, 15, 2) & StringMid($DATA_StartVCN_2, 13, 2) & StringMid($DATA_StartVCN_2, 11, 2) & StringMid($DATA_StartVCN_2, 9, 2) & StringMid($DATA_StartVCN_2, 7, 2) & StringMid($DATA_StartVCN_2, 5, 2) & StringMid($DATA_StartVCN_2, 3, 2) & StringMid($DATA_StartVCN_2, 1, 2)
			ConsoleWrite("$DATA_StartVCN_2 = " & $DATA_StartVCN_2 & @CRLF)
			$DATA_StartVCN_2 = _HexToDec($DATA_StartVCN_2)
			ConsoleWrite("$DATA_StartVCN_2 = " & $DATA_StartVCN_2 & @CRLF)
			$DATA_LastVCN_2 = StringMid($MFTEntry, $DATA_Offset + 48, 16)
			ConsoleWrite("$DATA_LastVCN_2 = " & $DATA_LastVCN_2 & @CRLF)
			$DATA_LastVCN_2 = StringMid($DATA_LastVCN_2, 15, 2) & StringMid($DATA_LastVCN_2, 13, 2) & StringMid($DATA_LastVCN_2, 11, 2) & StringMid($DATA_LastVCN_2, 9, 2) & StringMid($DATA_LastVCN_2, 7, 2) & StringMid($DATA_LastVCN_2, 5, 2) & StringMid($DATA_LastVCN_2, 3, 2) & StringMid($DATA_LastVCN_2, 1, 2)
			ConsoleWrite("$DATA_LastVCN_2 = " & $DATA_LastVCN_2 & @CRLF)
			$DATA_LastVCN_2 = _HexToDec($DATA_LastVCN_2)
			ConsoleWrite("$DATA_LastVCN_2 = " & $DATA_LastVCN_2 & @CRLF)
			$DATA_VCNs_2 = $DATA_LastVCN_2 - $DATA_StartVCN_2
			ConsoleWrite("$DATA_VCNs_2 = " & $DATA_VCNs_2 & @CRLF)
			$DATA_CompressionUnitSize_2 = StringMid($MFTEntry, $DATA_Offset + 68, 4)
			$DATA_CompressionUnitSize_2 = StringMid($DATA_CompressionUnitSize_2, 3, 2) & StringMid($DATA_CompressionUnitSize_2, 1, 2)
			$DATA_CompressionUnitSize_2 = Dec($DATA_CompressionUnitSize_2)
			$DATA_AllocatedSize_2 = StringMid($MFTEntry, $DATA_Offset + 80, 16)
			ConsoleWrite("$DATA_AllocatedSize_2 = " & $DATA_AllocatedSize_2 & @CRLF)
			$DATA_AllocatedSize_2 = StringMid($DATA_AllocatedSize_2, 15, 2) & StringMid($DATA_AllocatedSize_2, 13, 2) & StringMid($DATA_AllocatedSize_2, 11, 2) & StringMid($DATA_AllocatedSize_2, 9, 2) & StringMid($DATA_AllocatedSize_2, 7, 2) & StringMid($DATA_AllocatedSize_2, 5, 2) & StringMid($DATA_AllocatedSize_2, 3, 2) & StringMid($DATA_AllocatedSize_2, 1, 2)
			ConsoleWrite("$DATA_AllocatedSize_2 = " & $DATA_AllocatedSize_2 & @CRLF)
			$DATA_AllocatedSize_2 = _HexToDec($DATA_AllocatedSize_2)
			ConsoleWrite("$DATA_AllocatedSize_2 = " & $DATA_AllocatedSize_2 & @CRLF)
			$DATA_RealSize_2 = StringMid($MFTEntry, $DATA_Offset + 96, 16)
			ConsoleWrite("$DATA_RealSize_2 = " & $DATA_RealSize_2 & @CRLF)
			$DATA_RealSize_2 = StringMid($DATA_RealSize_2, 15, 2) & StringMid($DATA_RealSize_2, 13, 2) & StringMid($DATA_RealSize_2, 11, 2) & StringMid($DATA_RealSize_2, 9, 2) & StringMid($DATA_RealSize_2, 7, 2) & StringMid($DATA_RealSize_2, 5, 2) & StringMid($DATA_RealSize_2, 3, 2) & StringMid($DATA_RealSize_2, 1, 2)
			ConsoleWrite("$DATA_RealSize_2 = " & $DATA_RealSize_2 & @CRLF)
			$DATA_RealSize_2 = _HexToDec($DATA_RealSize_2)
			ConsoleWrite("$DATA_RealSize_2 = " & $DATA_RealSize_2 & @CRLF)
			$DATA_InitializedStreamSize_2 = StringMid($MFTEntry, $DATA_Offset + 112, 16)
			ConsoleWrite("$DATA_InitializedStreamSize_2 = " & $DATA_InitializedStreamSize_2 & @CRLF)
			$DATA_InitializedStreamSize_2 = StringMid($DATA_InitializedStreamSize_2, 15, 2) & StringMid($DATA_InitializedStreamSize_2, 13, 2) & StringMid($DATA_InitializedStreamSize_2, 11, 2) & StringMid($DATA_InitializedStreamSize_2, 9, 2) & StringMid($DATA_InitializedStreamSize_2, 7, 2) & StringMid($DATA_InitializedStreamSize_2, 5, 2) & StringMid($DATA_InitializedStreamSize_2, 3, 2) & StringMid($DATA_InitializedStreamSize_2, 1, 2)
			ConsoleWrite("$DATA_InitializedStreamSize_2 = " & $DATA_InitializedStreamSize_2 & @CRLF)
			$DATA_InitializedStreamSize_2 = _HexToDec($DATA_InitializedStreamSize_2)
			ConsoleWrite("$DATA_InitializedStreamSize_2 = " & $DATA_InitializedStreamSize_2 & @CRLF)
		ElseIf $DATA_NonResidentFlag_2 = '00' Then
			$DATA_LengthOfAttribute_2 = StringMid($MFTEntry, $DATA_Offset + 32, 8)
			$DATA_LengthOfAttribute_2 = Dec(StringMid($DATA_LengthOfAttribute_2, 7, 2) & StringMid($DATA_LengthOfAttribute_2, 5, 2) & StringMid($DATA_LengthOfAttribute_2, 3, 2) & StringMid($DATA_LengthOfAttribute_2, 1, 2))
			;	$DATA_LengthOfAttribute_2 = Dec($DATA_LengthOfAttribute_2)
			$DATA_OffsetToAttribute_2 = StringMid($MFTEntry, $DATA_Offset + 40, 4)
			$DATA_OffsetToAttribute_2 = Dec(StringMid($DATA_OffsetToAttribute_2, 3, 2) & StringMid($DATA_OffsetToAttribute_2, 1, 2))
			;	$DATA_OffsetToAttribute_2 = Dec($DATA_OffsetToAttribute_2)
			$DATA_IndexedFlag_2 = Dec(StringMid($MFTEntry, $DATA_Offset + 44, 2))
			;	$DATA_IndexedFlag_2 = Dec($DATA_IndexedFlag_2)
		EndIf
	EndIf
	If $DATA_Number = 3 Then
		$DATA_NonResidentFlag_3 = StringMid($MFTEntry, $DATA_Offset + 16, 2)
		ConsoleWrite("$DATA_NonResidentFlag_3 = " & $DATA_NonResidentFlag_3 & @CRLF)
		$DATA_NameLength_3 = Dec(StringMid($MFTEntry, $DATA_Offset + 18, 2))
		;$DATA_NameLength_3 = Dec($DATA_NameLength_3)
		ConsoleWrite("$DATA_NameLength_3 = " & $DATA_NameLength_3 & @CRLF)
		$DATA_NameRelativeOffset_3 = StringMid($MFTEntry, $DATA_Offset + 20, 4)
		ConsoleWrite("$DATA_NameRelativeOffset_3 = " & $DATA_NameRelativeOffset_3 & @CRLF)
		$DATA_NameRelativeOffset_3 = Dec(StringMid($DATA_NameRelativeOffset_3, 3, 2) & StringMid($DATA_NameRelativeOffset_3, 1, 2))
		;$DATA_NameRelativeOffset_3 = Dec($DATA_NameRelativeOffset_3)
		ConsoleWrite("$DATA_NameRelativeOffset_3 = " & $DATA_NameRelativeOffset_3 & @CRLF)
		$DATA_Flags_3 = StringMid($MFTEntry, $DATA_Offset + 24, 4)
		$DATA_Flags_3 = StringMid($DATA_Flags_3, 3, 2) & StringMid($DATA_Flags_3, 1, 2)
		ConsoleWrite("$DATA_Flags_3 = " & $DATA_Flags_3 & @CRLF)
		$DATA_Flags_3 = _AttribHeaderFlags("0x" & $DATA_Flags_3)
		ConsoleWrite("$DATA_Flags_3 = " & $DATA_Flags_3 & @CRLF)
		#cs
			Select
			Case $DATA_Flags_3 = '0001'
			$DATA_Flags_3 = 'COMPRESSED'
			Case $DATA_Flags_3 = '4000'
			$DATA_Flags_3 = 'ENCRYPTED'
			Case $DATA_Flags_3 = '8000'
			$DATA_Flags_3 = 'SPARSE'
			Case $DATA_Flags_3 <> '0001' AND $DATA_Flags_3 <> '4000' AND $DATA_Flags_3 <> '8000'
			$DATA_Flags_3 = 'UNKNOWN'
			EndSelect
		#ce
		If $DATA_NameLength_3 > 0 Then
			$DATA_NameSpace_3 = $DATA_NameLength_3 - 1
			$DATA_Name_3 = StringMid($MFTEntry, $DATA_Offset + ($DATA_NameRelativeOffset_3 * 2), ($DATA_NameLength_3 + $DATA_NameSpace_3) * 2)
			$DATA_Name_3 = _UnicodeHexToStr($DATA_Name_3)
		EndIf
		ConsoleWrite("$DATA_Name_3 = " & $DATA_Name_3 & @CRLF)
		If $DATA_NonResidentFlag_3 = '01' Then
			$DATA_StartVCN_3 = StringMid($MFTEntry, $DATA_Offset + 32, 16)
			ConsoleWrite("$DATA_StartVCN_3 = " & $DATA_StartVCN_3 & @CRLF)
			$DATA_StartVCN_3 = StringMid($DATA_StartVCN_3, 15, 2) & StringMid($DATA_StartVCN_3, 13, 2) & StringMid($DATA_StartVCN_3, 11, 2) & StringMid($DATA_StartVCN_3, 9, 2) & StringMid($DATA_StartVCN_3, 7, 2) & StringMid($DATA_StartVCN_3, 5, 2) & StringMid($DATA_StartVCN_3, 3, 2) & StringMid($DATA_StartVCN_3, 1, 2)
			ConsoleWrite("$DATA_StartVCN_3 = " & $DATA_StartVCN_3 & @CRLF)
			$DATA_StartVCN_3 = _HexToDec($DATA_StartVCN_3)
			ConsoleWrite("$DATA_StartVCN_3 = " & $DATA_StartVCN_3 & @CRLF)
			$DATA_LastVCN_3 = StringMid($MFTEntry, $DATA_Offset + 48, 16)
			ConsoleWrite("$DATA_LastVCN_3 = " & $DATA_LastVCN_3 & @CRLF)
			$DATA_LastVCN_3 = StringMid($DATA_LastVCN_3, 15, 2) & StringMid($DATA_LastVCN_3, 13, 2) & StringMid($DATA_LastVCN_3, 11, 2) & StringMid($DATA_LastVCN_3, 9, 2) & StringMid($DATA_LastVCN_3, 7, 2) & StringMid($DATA_LastVCN_3, 5, 2) & StringMid($DATA_LastVCN_3, 3, 2) & StringMid($DATA_LastVCN_3, 1, 2)
			ConsoleWrite("$DATA_LastVCN_3 = " & $DATA_LastVCN_3 & @CRLF)
			$DATA_LastVCN_3 = _HexToDec($DATA_LastVCN_3)
			ConsoleWrite("$DATA_LastVCN_3 = " & $DATA_LastVCN_3 & @CRLF)
			$DATA_VCNs_3 = $DATA_LastVCN_3 - $DATA_StartVCN_3
			ConsoleWrite("$DATA_VCNs_3 = " & $DATA_VCNs_3 & @CRLF)
			$DATA_CompressionUnitSize_3 = StringMid($MFTEntry, $DATA_Offset + 68, 4)
			$DATA_CompressionUnitSize_3 = StringMid($DATA_CompressionUnitSize_3, 3, 2) & StringMid($DATA_CompressionUnitSize_3, 1, 2)
			$DATA_CompressionUnitSize_3 = Dec($DATA_CompressionUnitSize_3)
			$DATA_AllocatedSize_3 = StringMid($MFTEntry, $DATA_Offset + 80, 16)
			ConsoleWrite("$DATA_AllocatedSize_3 = " & $DATA_AllocatedSize_3 & @CRLF)
			$DATA_AllocatedSize_3 = StringMid($DATA_AllocatedSize_3, 15, 2) & StringMid($DATA_AllocatedSize_3, 13, 2) & StringMid($DATA_AllocatedSize_3, 11, 2) & StringMid($DATA_AllocatedSize_3, 9, 2) & StringMid($DATA_AllocatedSize_3, 7, 2) & StringMid($DATA_AllocatedSize_3, 5, 2) & StringMid($DATA_AllocatedSize_3, 3, 2) & StringMid($DATA_AllocatedSize_3, 1, 2)
			ConsoleWrite("$DATA_AllocatedSize_3 = " & $DATA_AllocatedSize_3 & @CRLF)
			$DATA_AllocatedSize_3 = _HexToDec($DATA_AllocatedSize_3)
			ConsoleWrite("$DATA_AllocatedSize_3 = " & $DATA_AllocatedSize_3 & @CRLF)
			$DATA_RealSize_3 = StringMid($MFTEntry, $DATA_Offset + 96, 16)
			ConsoleWrite("$DATA_RealSize_3 = " & $DATA_RealSize_3 & @CRLF)
			$DATA_RealSize_3 = StringMid($DATA_RealSize_3, 15, 2) & StringMid($DATA_RealSize_3, 13, 2) & StringMid($DATA_RealSize_3, 11, 2) & StringMid($DATA_RealSize_3, 9, 2) & StringMid($DATA_RealSize_3, 7, 2) & StringMid($DATA_RealSize_3, 5, 2) & StringMid($DATA_RealSize_3, 3, 2) & StringMid($DATA_RealSize_3, 1, 2)
			ConsoleWrite("$DATA_RealSize_3 = " & $DATA_RealSize_3 & @CRLF)
			$DATA_RealSize_3 = _HexToDec($DATA_RealSize_3)
			ConsoleWrite("$DATA_RealSize_3 = " & $DATA_RealSize_3 & @CRLF)
			$DATA_InitializedStreamSize_3 = StringMid($MFTEntry, $DATA_Offset + 112, 16)
			ConsoleWrite("$DATA_InitializedStreamSize_3 = " & $DATA_InitializedStreamSize_3 & @CRLF)
			$DATA_InitializedStreamSize_3 = StringMid($DATA_InitializedStreamSize_3, 15, 2) & StringMid($DATA_InitializedStreamSize_3, 13, 2) & StringMid($DATA_InitializedStreamSize_3, 11, 2) & StringMid($DATA_InitializedStreamSize_3, 9, 2) & StringMid($DATA_InitializedStreamSize_3, 7, 2) & StringMid($DATA_InitializedStreamSize_3, 5, 2) & StringMid($DATA_InitializedStreamSize_3, 3, 2) & StringMid($DATA_InitializedStreamSize_3, 1, 2)
			ConsoleWrite("$DATA_InitializedStreamSize_3 = " & $DATA_InitializedStreamSize_3 & @CRLF)
			$DATA_InitializedStreamSize_3 = _HexToDec($DATA_InitializedStreamSize_3)
			ConsoleWrite("$DATA_InitializedStreamSize_3 = " & $DATA_InitializedStreamSize_3 & @CRLF)
		ElseIf $DATA_NonResidentFlag_3 = '00' Then
			$DATA_LengthOfAttribute_3 = StringMid($MFTEntry, $DATA_Offset + 32, 8)
			$DATA_LengthOfAttribute_3 = Dec(StringMid($DATA_LengthOfAttribute_3, 7, 2) & StringMid($DATA_LengthOfAttribute_3, 5, 2) & StringMid($DATA_LengthOfAttribute_3, 3, 2) & StringMid($DATA_LengthOfAttribute_3, 1, 2))
			;	$DATA_LengthOfAttribute_3 = Dec($DATA_LengthOfAttribute_3)
			$DATA_OffsetToAttribute_3 = StringMid($MFTEntry, $DATA_Offset + 40, 4)
			$DATA_OffsetToAttribute_3 = Dec(StringMid($DATA_OffsetToAttribute_3, 3, 2) & StringMid($DATA_OffsetToAttribute_3, 1, 2))
			;	$DATA_OffsetToAttribute_3 = Dec($DATA_OffsetToAttribute_3)
			$DATA_IndexedFlag_3 = Dec(StringMid($MFTEntry, $DATA_Offset + 44, 2))
			;	$DATA_IndexedFlag_3 = Dec($DATA_IndexedFlag_3)
		EndIf
	EndIf
EndFunc   ;==>_Get_Data

Func _Get_IndexRoot()
	ConsoleWrite("Get_IndexRoot Function not implemented yet." & @CRLF)
	Return
EndFunc   ;==>_Get_IndexRoot

Func _Get_IndexAllocation()
	ConsoleWrite("Get_IndexAllocation Function not implemented yet." & @CRLF)
	Return
EndFunc   ;==>_Get_IndexAllocation

Func _Get_Bitmap()
	ConsoleWrite("Get_Bitmap Function not implemented yet." & @CRLF)
	Return
EndFunc   ;==>_Get_Bitmap

Func _Get_ReparsePoint()
	ConsoleWrite("Get_ReparsePoint Function not implemented yet." & @CRLF)
	Return
EndFunc   ;==>_Get_ReparsePoint

Func _Get_EaInformation()
	ConsoleWrite("Get_EaInformation Function not implemented yet." & @CRLF)
	Return
EndFunc   ;==>_Get_EaInformation

Func _Get_Ea()
	ConsoleWrite("Get_Ea Function not implemented yet." & @CRLF)
	Return
EndFunc   ;==>_Get_Ea

Func _Get_PropertySet()
	ConsoleWrite("Get_PropertySet Function not implemented yet." & @CRLF)
	Return
EndFunc   ;==>_Get_PropertySet

Func _Get_LoggedUtilityStream()
	ConsoleWrite("Get_LoggedUtilityStream Function not implemented yet." & @CRLF)
	Return
EndFunc   ;==>_Get_LoggedUtilityStream

Func _UnicodeHexToStr($UnicodeHex)
	Local $UniConv
	;Local $UnicodeHexLength = StringLen($UnicodeHex)
	;For $space = 1 To $UnicodeHexLength
	For $space = 1 To StringLen($UnicodeHex)
		;	If Dec(StringMid($UnicodeHex,$space,2)) < 32 OR Dec(StringMid($UnicodeHex,$space,2)) > 127 Then
		If Dec(StringMid($UnicodeHex, $space, 2)) < 32 Then ; Faster and prevents messed up csv when value=0A etc
			$space += 3
			;		$INVALID_NAME = 1 ; Problem since function is used 3 different places for each record
			ContinueLoop
		EndIf
		$tmp = StringMid($UnicodeHex, $space, 2)
		$space += 3
		$UniConv &= $tmp
	Next
	$UniConv = _HexToString($UniConv)
	;ConsoleWrite("$UniConv = " & $UniConv & @CRLF)
	Return $UniConv
EndFunc   ;==>_UnicodeHexToStr

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
EndFunc   ;==>_ClearVar

Func _Test_MilliSec($timestamp)
	If StringRight($timestamp, 8) = '000:0000' Then
		;If StringRight($timestamp,4) = '000' Then
		$MSecTest = 'YES'
	Else
		$MSecTest = 'NO'
	EndIf
	Return $MSecTest
EndFunc   ;==>_Test_MilliSec

Func _Test_SI2FN_CTime($SI_CTime, $FN_CTime)
	If $SI_CTime < $FN_CTime Then
		$CTimeTest = 'YES'
	Else
		$CTimeTest = 'NO'
	EndIf
	Return $CTimeTest
EndFunc   ;==>_Test_SI2FN_CTime

Func _File_Permissions($FPinput)
	Local $FPoutput = ""
	If BitAND($FPinput, 0x0001) Then $FPoutput &= 'read_only+'
	If BitAND($FPinput, 0x0002) Then $FPoutput &= 'hidden+'
	If BitAND($FPinput, 0x0004) Then $FPoutput &= 'system+'
	If BitAND($FPinput, 0x0020) Then $FPoutput &= 'archive+'
	If BitAND($FPinput, 0x0040) Then $FPoutput &= 'device+'
	If BitAND($FPinput, 0x0080) Then $FPoutput &= 'normal+'
	If BitAND($FPinput, 0x0100) Then $FPoutput &= 'temporary+'
	If BitAND($FPinput, 0x0200) Then $FPoutput &= 'sparse_file+'
	If BitAND($FPinput, 0x0400) Then $FPoutput &= 'reparse_point+'
	If BitAND($FPinput, 0x0800) Then $FPoutput &= 'compressed+'
	If BitAND($FPinput, 0x1000) Then $FPoutput &= 'offline+'
	If BitAND($FPinput, 0x2000) Then $FPoutput &= 'not_indexed+'
	If BitAND($FPinput, 0x4000) Then $FPoutput &= 'encrypted+'
	If BitAND($FPinput, 0x10000000) Then $FPoutput &= 'directory+'
	If BitAND($FPinput, 0x20000000) Then $FPoutput &= 'index_view+'
	;$FPoutput = StringMid($FPoutput,1,StringLen($FPoutput)-1)
	$FPoutput = StringTrimRight($FPoutput, 1)
	;ConsoleWrite("$FPoutput = " & $FPoutput & @crlf)
	Return $FPoutput
EndFunc   ;==>_File_Permissions

Func _AttribHeaderFlags($AHinput)
	Local $AHoutput = ""
	If BitAND($AHinput, 0x0001) Then $AHoutput &= 'COMPRESSED+'
	If BitAND($AHinput, 0x4000) Then $AHoutput &= 'ENCRYPTED+'
	If BitAND($AHinput, 0x8000) Then $AHoutput &= 'SPARSE+'
	;$AHoutput = StringMid($AHoutput,1,StringLen($AHoutput)-1)
	$AHoutput = StringTrimRight($AHoutput, 1)
	;ConsoleWrite("$AHoutput = " & $AHoutput & @crlf)
	Return $AHoutput
EndFunc   ;==>_AttribHeaderFlags

Func _FileRecordFlag($FRFinput) ;Turns out to be problematic to use BitAND with these values
	Local $FRFoutput = ""
	If BitAND($FRFinput, 0x0000) Then $FRFoutput &= 'FILE_DELETE+'
	If BitAND($FRFinput, 0x0001) Then $FRFoutput &= 'FILE+'
	If BitAND($FRFinput, 0x0003) Then $FRFoutput &= 'DIRECTORY+'
	If BitAND($FRFinput, 0x0002) Then $FRFoutput &= 'DIRECTORY_DELETE+'
	If BitAND($FRFinput, 0x0004) Then $FRFoutput &= 'UNKNOWN1+'
	If BitAND($FRFinput, 0x0008) Then $FRFoutput &= 'UNKNOWN2+'
	;$FRFoutput = StringMid($FRFoutput,1,StringLen($FRFoutput)-1)
	$FRFoutput = StringTrimRight($FRFoutput, 1)
	;ConsoleWrite("$FRFoutput = " & $FRFoutput & @crlf)
	Return $FRFoutput
EndFunc   ;==>_FileRecordFlag

Func _VolInfoFlag($VIFinput)
	Local $VIFoutput = ""
	If BitAND($VIFinput, 0x0001) Then $VIFoutput &= 'Dirty+'
	If BitAND($VIFinput, 0x0002) Then $VIFoutput &= 'Resize_LogFile+'
	If BitAND($VIFinput, 0x0004) Then $VIFoutput &= 'Upgrade_On_Mount+'
	If BitAND($VIFinput, 0x0008) Then $VIFoutput &= 'Mounted_On_NT4+'
	If BitAND($VIFinput, 0x0010) Then $VIFoutput &= 'Deleted_USN_Underway+'
	If BitAND($VIFinput, 0x0020) Then $VIFoutput &= 'Repair_ObjectIDs+'
	If BitAND($VIFinput, 0x8000) Then $VIFoutput &= 'Modified_By_CHKDSK+'
	;$FRFoutput = StringMid($FRFoutput,1,StringLen($FRFoutput)-1)
	$VIFoutput = StringTrimRight($VIFoutput, 1)
	;ConsoleWrite("$FRFoutput = " & $FRFoutput & @crlf)
	Return $VIFoutput
EndFunc   ;==>_VolInfoFlag

Func _FillZero($inp)
	Local $inplen, $out, $tmp = ""
	$inplen = StringLen($inp)
	For $i = 1 To 4 - $inplen
		$tmp &= "0"
	Next
	$out = $tmp & $inp
	Return $out
EndFunc   ;==>_FillZero

Func _WriteCSV()
	FileWriteLine($csv, $RecordOffset & ',' & $Signature & ',' & $IntegrityCheck & ',' & $HEADER_MFTREcordNumber & ',' & $HEADER_SequenceNo & ',' & $FN_ParentReferenceNo & ',' & $FN_ParentSequenceNo & ',' & $FN_FileName & ',' & $HEADER_Flags & ',' & $RecordActive & ',' & $FileSizeBytes & ',' & $INVALID_FILENAME & ',' & $SI_FilePermission & ',' & $FN_Flags & ',' & $FN_NameType & ',' & $Alternate_Data_Stream & ',' & $SI_CTime & ',' & $SI_ATime & ',' & $SI_MTime & ',' & $SI_RTime & ',' & _
			$MSecTest & ',' & $FN_CTime & ',' & $FN_ATime & ',' & $FN_MTime & ',' & $FN_RTime & ',' & $CTimeTest & ',' & $FN_AllocSize & ',' & $FN_RealSize & ',' & $SI_USN & ',' & $DATA_Name & ',' & $DATA_Flags & ',' & $DATA_LengthOfAttribute & ',' & $DATA_IndexedFlag & ',' & $DATA_VCNs & ',' & $DATA_NonResidentFlag & ',' & $DATA_CompressionUnitSize & ',' & $HEADER_LSN & ',' & _
			$HEADER_RecordRealSize & ',' & $HEADER_RecordAllocSize & ',' & $HEADER_FileRef & ',' & $HEADER_NextAttribID & ',' & $DATA_AllocatedSize & ',' & $DATA_RealSize & ',' & $DATA_InitializedStreamSize & ',' & $SI_HEADER_Flags & ',' & $SI_MaxVersions & ',' & $SI_VersionNumber & ',' & $SI_ClassID & ',' & $SI_OwnerID & ',' & $SI_SecurityID & ',' & $FN_CTime_2 & ',' & $FN_ATime_2 & ',' & _
			$FN_MTime_2 & ',' & $FN_RTime_2 & ',' & $FN_AllocSize_2 & ',' & $FN_RealSize_2 & ',' & $FN_Flags_2 & ',' & $FN_NameLength_2 & ',' & $FN_NameType_2 & ',' & $FN_FileName_2 & ',' & $INVALID_FILENAME_2 & ',' & $GUID_ObjectID & ',' & $GUID_BirthVolumeID & ',' & $GUID_BirthObjectID & ',' & $GUID_BirthDomainID & ',' & $VOLUME_NAME_NAME & ',' & $VOL_INFO_NTFS_VERSION & ',' & $VOL_INFO_FLAGS & ',' & $FN_CTime_3 & ',' & $FN_ATime_3 & ',' & $FN_MTime_3 & ',' & $FN_RTime_3 & ',' & $FN_AllocSize_3 & ',' & $FN_RealSize_3 & ',' & $FN_Flags_3 & ',' & $FN_NameLength_3 & ',' & $FN_NameType_3 & ',' & $FN_FileName_3 & ',' & $INVALID_FILENAME_3 & ',' & _
			$FN_CTime_4 & ',' & $FN_ATime_4 & ',' & $FN_MTime_4 & ',' & $FN_RTime_4 & ',' & $FN_AllocSize_4 & ',' & $FN_RealSize_4 & ',' & $FN_Flags_4 & ',' & $FN_NameLength_4 & ',' & $FN_NameType_4 & ',' & $FN_FileName_4 & ',' & $DATA_Name_2 & ',' & $DATA_NonResidentFlag_2 & ',' & $DATA_Flags_2 & ',' & $DATA_LengthOfAttribute_2 & ',' & $DATA_IndexedFlag_2 & ',' & $DATA_StartVCN_2 & ',' & $DATA_LastVCN_2 & ',' & _
			$DATA_VCNs_2 & ',' & $DATA_CompressionUnitSize_2 & ',' & $DATA_AllocatedSize_2 & ',' & $DATA_RealSize_2 & ',' & $DATA_InitializedStreamSize_2 & ',' & $DATA_Name_3 & ',' & $DATA_NonResidentFlag_3 & ',' & $DATA_Flags_3 & ',' & $DATA_LengthOfAttribute_3 & ',' & $DATA_IndexedFlag_3 & ',' & $DATA_StartVCN_3 & ',' & $DATA_LastVCN_3 & ',' & $DATA_VCNs_3 & ',' & $DATA_CompressionUnitSize_3 & ',' & $DATA_AllocatedSize_3 & ',' & _
			$DATA_RealSize_3 & ',' & $DATA_InitializedStreamSize_3 & ',' & $STANDARD_INFORMATION_ON & ',' & $ATTRIBUTE_LIST_ON & ',' & $FILE_NAME_ON & ',' & $OBJECT_ID_ON & ',' & $SECURITY_DESCRIPTOR_ON & ',' & $VOLUME_NAME_ON & ',' & $VOLUME_INFORMATION_ON & ',' & $DATA_ON & ',' & $INDEX_ROOT_ON & ',' & $INDEX_ALLOCATION_ON & ',' & $BITMAP_ON & ',' & $REPARSE_POINT_ON & ',' & $EA_INFORMATION_ON & ',' & $EA_ON & ',' & $PROPERTY_SET_ON & ',' & $LOGGED_UTILITY_STREAM_ON & @CRLF)
EndFunc   ;==>_WriteCSV




