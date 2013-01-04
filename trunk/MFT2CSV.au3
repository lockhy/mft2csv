#RequireAdmin
#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_UseX64=y
#AutoIt3Wrapper_Res_Comment=Decode $MFT and write to CSV
#AutoIt3Wrapper_Res_Description=Decode $MFT and write to CSV
#AutoIt3Wrapper_Res_Fileversion=2.0.0.0
#AutoIt3Wrapper_Res_requestedExecutionLevel=asInvoker
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
#include <array.au3>
#Include <WinAPIEx.au3> ; http://www.autoitscript.com/forum/topic/98712-winapiex-udf/
#include <String.au3>
#include <Date.au3>

; by Joakim Schicht & Ddan
; parts by trancexxx, Ascend4nt & others

Global $_COMMON_KERNEL32DLL=DllOpen("kernel32.dll")
Global $csv, $csvfile, $RecordOffset, $Signature, $Alternate_Data_Stream, $FN_FileNamePath, $UTCconfig
Global $HEADER_LSN, $HEADER_SequenceNo, $HEADER_Flags, $HEADER_RecordRealSize, $HEADER_RecordAllocSize, $HEADER_BaseRecord, $HEADER_NextAttribID, $HEADER_MFTREcordNumber, $Header_HardLinkCount, $HEADER_BaseRecSeqNo
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
Global Const $RecordSignatureBad = '42414144' ; BAAD signature
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
Global $tDelta = _WinTime_GetUTCToLocalFileTimeDelta() ; in offline mode we must read the values off the registry..

Global Const $GUI_EVENT_CLOSE = -3
Global Const $GUI_CHECKED = 1
Global Const $GUI_UNCHECKED = 4
Global Const $ES_AUTOVSCROLL = 64
Global Const $WS_VSCROLL = 0x00200000
Global Const $DT_END_ELLIPSIS = 0x8000

Global $TargetDrive = "", $MFT_Record_Size, $BytesPerCluster, $MFT_Offset, $MFT_Size
Global $FileTree[1], $hDisk, $rBuffer, $NonResidentFlag, $zPath, $sBuffer, $Total, $MFTTree[1]
Global $FN_FileName, $ADS_Name, $Reparse = ""
Global $DATA_LengthOfAttribute, $DATA_Clusters, $DATA_RealSize, $DATA_InitSize, $DataRun
Global $IsCompressed, $IsSparse, $subset, $logfile = 0, $subst, $active = False
Global $RUN_VCN[1], $RUN_Clusters[1], $MFT_RUN_Clusters[1], $MFT_RUN_VCN[1], $DataQ[1], $AttrQ[1]
Global $TargetImageFile, $Entries, $IsImage = False, $ImageOffset=0, $IsMftFile=False, $TargetMftFile
Global $begin, $ElapsedTime
Global $OverallProgress, $FileProgress, $CurrentProgress, $ProgressStatus, $ProgressFileName, $ProgressSize

Global Const $RecordSignature = '46494C45' ; FILE signature

Opt("GUIOnEventMode", 1)  ; Change to OnEvent mode

$Form = GUICreate("MFT2CSV", 560, 450, -1, -1)
GUISetOnEvent($GUI_EVENT_CLOSE, "_HandleExit", $Form)

$Combo = GUICtrlCreateCombo("", 20, 20, 400, 25)
$buttonDrive = GUICtrlCreateButton("Rescan Drives", 440, 20, 100, 20)
GUICtrlSetOnEvent($buttonDrive, "_HandleEvent")
$buttonImage = GUICtrlCreateButton("Choose Image", 440, 50, 100, 20)
GUICtrlSetOnEvent($buttonImage, "_HandleEvent")
$buttonMftFile = GUICtrlCreateButton("Choose $MFT", 440, 80, 100, 20)
GUICtrlSetOnEvent($buttonMftFile, "_HandleEvent")
$buttonOutput = GUICtrlCreateButton("Choose CSV", 440, 110, 100, 20)
GUICtrlSetOnEvent($buttonOutput, "_HandleEvent")
$buttonStart = GUICtrlCreateButton("Start Processing", 300, 80, 120, 40)
GUICtrlSetOnEvent($buttonStart, "_HandleEvent")
$Label1 = GUICtrlCreateLabel("Adjust timestamps to specific region:",20,90,180,20)
$Combo2 = GUICtrlCreateCombo("", 200, 90, 90, 25)
$myctredit = GUICtrlCreateEdit("Extracting files from NTFS formatted volume" & @CRLF, 0, 135, 560, 115, $ES_AUTOVSCROLL + $WS_VSCROLL)
_GetPhysicalDriveInfo()
_InjectTimeZoneInfo()

$LogState = True
GUISetState(@SW_SHOW, $Form)

While Not $active
   Sleep(1000)	;Wait for event
WEnd

$tDelta = _GetUTCRegion()-$tDelta
If @error Then
	_DisplayInfo("Error: Timezone configuration failed." & @CRLF)
Else
	_DisplayInfo("Timestamps presented in UTC: " & $UTCconfig & @CRLF)
EndIf
$tDelta = $tDelta*-1 ;Since delta is substracted from timestamp later on

$TimestampStart = @YEAR & "-" & @MON & "-" & @MDAY & "_" & @HOUR & "-" & @MIN & "-" & @SEC
$logfile = FileOpen(@ScriptDir & "\" & $TimestampStart & ".log",2)
$subset = 0

If $IsImage Then
   $ImageOffset = Int(StringMid(GUICtrlRead($Combo),10),2)
   _DisplayInfo(@CRLF & "Target is: " & GUICtrlRead($Combo) & @CRLF)
   _DebugOut("Target image file: " & $TargetImageFile)
   $hDisk = _WinAPI_CreateFile("\\.\" & $TargetImageFile,2,2,7)
   If $hDisk = 0 Then _DebugOut("Image Access Error")
ElseIf $IsMftFile Then
   _DebugOut("Target $MFT file: " & $TargetMftFile)
   $hDisk = _WinAPI_CreateFile("\\.\" & $TargetMftFile,2,2,7)
   If $hDisk = 0 Then _DebugOut("Disk Access Error")
Else
   $TargetDrive = StringMid(GUICtrlRead($Combo),1,2)
   _DebugOut("Target volume: " & $TargetDrive)
   $hDisk = _WinAPI_CreateFile("\\.\" & $TargetDrive,2,2,7)
   If $hDisk = 0 Then _DebugOut("Disk Access Error")
EndIf
_DebugOut("Timestamps presented in UTC " & $UTCconfig)
_DebugOut("Output CSV file: " & $csvfile)
_DebugOut("Operation started: " & $TimestampStart)
$begin1 = TimerInit()
_ExtractSystemfile()
_DebugOut("Total processing time is " & _WinAPI_StrFromTimeInterval(TimerDiff($begin1)))
_WinAPI_CloseHandle($hDisk)
If $logfile Then FileClose($logfile)
$active = False
Exit

Func _HandleEvent()
	If Not $active Then
		Switch @GUI_CTRLID
			Case $buttonDrive
				_GetPhysicalDriveInfo()
			Case $buttonImage
				_ProcessImage()
				$IsImage = True
			Case $buttonMftFile
				_SelectMftFile()
				$IsMftFile = True
			Case $buttonOutput
				_SelectCsv()
			Case $buttonStart
				If $csv = "" Then
					_DisplayInfo("Error: Output CSV not set " & @CRLF)
					Return
				EndIf
				$active = True
		EndSwitch
	EndIf
EndFunc

Func _HandleExit()
   If $logfile Then FileClose($logfile)
   If $hDisk Then _WinAPI_CloseHandle($hDisk)
   Exit
EndFunc

Func _ExtractSystemfile()
	Local $nBytes
	Global $DataQ[1], $RUN_VCN[1], $RUN_Clusters[1]
	_WriteCSVHeader()
	If (Not $IsImage and Not $IsMftFile) Then
		If DriveGetFileSystem($TargetDrive) <> "NTFS" Then		;read boot sector and extract $MFT data
			_DisplayInfo("Error: Target volume " & $TargetDrive & " is not NTFS" & @crlf)
			Return
		EndIf
		_DisplayInfo("Target volume is: " & $TargetDrive & @crlf)
	EndIf

	If Not $IsMftFile Then _WinAPI_SetFilePointerEx($hDisk, $ImageOffset, $FILE_BEGIN)
	$BootRecord = _GetDiskConstants()
	If $BootRecord = "" Then
		_DebugOut("Unable to read Boot Sector")
		Return
	EndIf
	$rBuffer = DllStructCreate("byte[" & $MFT_Record_Size & "]")     ;buffer for records

	$MFT = _ReadMFT()
	If $MFT = "" Then Return		;something wrong with record for $MFT
	$MFT = _DecodeMFTRecord($MFT, 0)        ;produces DataQ for $MFT, record 0
	If $MFT = "" Then Return

	_DecodeDataQEntry($DataQ[1])         ;produces datarun for $MFT
	$MFT_Size = $Data_RealSize
	_ExtractDataRuns()                   ;converts datarun to RUN_VCN[] and RUN_Clusters[]
	$MFT_RUN_VCN = $RUN_VCN
	$MFT_RUN_Clusters = $RUN_Clusters	;preserve values for $MFT
	$Progress = GUICtrlCreateLabel("Decoding $MFT info and writing to csv", 10, 250,540,20)
	GUICtrlSetFont($Progress, 12)
	$ProgressStatus = GUICtrlCreateLabel("", 10, 280, 540, 20)
	$ElapsedTime = GUICtrlCreateLabel("", 10, 295, 540, 20)
	$OverallProgress = GUICtrlCreateProgress(10, 320, 540, 30)

	_DoFileTree()                        ;creates folder structure
	$ProgressFileName = GUICtrlCreateLabel("", 10,  360, 540, 20, $DT_END_ELLIPSIS)
	$FileProgress = GUICtrlCreateProgress(10, 385, 540, 30)
	AdlibRegister("_ExtractionProgress", 500)
	$begin = TimerInit()

	For $i = 0 To UBound($FileTree)-1	;note $i is mft reference number
		$CurrentProgress = $i

		$Files = $Filetree[$i]
;		local $Names[1]

		If $IsMftFile Then
			_WinAPI_SetFilePointerEx($hDisk, $i*$MFT_Record_Size, $FILE_BEGIN)
			$RecordOffsetDec = $MFT_Record_Size * $i
		Else
			_WinAPI_SetFilePointerEx($hDisk, $MFTTree[$i], $FILE_BEGIN)
			$RecordOffsetDec = Int($MFTTree[$i])
		EndIf
		_WinAPI_ReadFile($hDisk, DllStructGetPtr($rBuffer), $MFT_Record_Size, $nBytes)
		$FN_FileNamePath = StringMid($Files, 1,StringInStr($Files, "?") - 1)
		$MFTEntry = DllStructGetData($rBuffer, 1)
		If (StringMid($MFTEntry, 3, 8) = '46494C45') Then
			$Signature = "GOOD"
		ElseIf (StringMid($MFTEntry, 3, 8) = '42414144') Then
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
		_ParserCodeOldVersion($MFTEntry)
		If $DATA_Number > 0 Then $Alternate_Data_Stream = $DATA_Number - 1
		$RecordOffset = "0x" & Hex($RecordOffsetDec)
		$CTimeTest = _Test_SI2FN_CTime($SI_CTime, $FN_CTime)
		_WriteCSV()
		$Signature = ""
	Next
	_WinAPI_CloseHandle($hDisk)
	AdlibUnRegister()
	GUIDelete($Progress)
	_DisplayInfo("Finished extraction of files." & @crlf & @crlf)
	_DebugOut("Finished extraction of files.")
EndFunc

Func _DoFileTree()
   Local $nBytes, $ParentRef, $FileRef, $BaseRef, $tag
   $Total = Int($MFT_Size/$MFT_Record_Size)
   Global $FileTree[$Total]
   Global $MFTTree[$Total]
   $ref = -1
   AdlibRegister("_DoFileTreeProgress", 500)
   $begin = TimerInit()
   For $r = 1 To Ubound($MFT_RUN_VCN)-1
		If Not $IsMftFile Then
			$Pos = $MFT_RUN_VCN[$r]*$BytesPerCluster
			_WinAPI_SetFilePointerEx($hDisk, $ImageOffset+$Pos, $FILE_BEGIN)
		Else
			$Pos=0
			_WinAPI_SetFilePointerEx($hDisk, $Pos, $FILE_BEGIN)
		EndIf
      For $i = 0 To $MFT_RUN_Clusters[$r]*$BytesPerCluster-$MFT_Record_Size Step $MFT_Record_Size
         $ref += 1
		 $CurrentProgress = $ref
		 _WinAPI_ReadFile($hDisk, DllStructGetPtr($rBuffer), $MFT_Record_Size, $nBytes)
         $record = DllStructGetData($rBuffer, 1)
		 $CurrentMFTOffset = DllCall('kernel32.dll', 'int', 'SetFilePointerEx', 'ptr', $hDisk, 'int64', 0, 'int64*', 0, 'dword', 1)
		 $MFTTree[$ref] = $CurrentMFTOffset[3]-$MFT_Record_Size
         If StringMid($record,3,8) <> $RecordSignature Then
			_DebugOut($ref & " The record signature is bad", StringMid($record, 1, 34))
			ContinueLoop
		 EndIf
		 $Flags = Dec(StringMid($record,47,4))
         $record = _DoFixup($record, $ref)
         If $record = "" then ContinueLoop   ;corrupt, failed fixup
         $FileRef = $ref
         $BaseRef = Dec(_SwapEndian(StringMid($record,67,8)),2)
         If $BaseRef <> 0 Then
            $FileTree[$FileRef] = $Pos + $i      ;may contain data attribute
            $FileRef = $BaseRef
         EndIf
		 $Offset = (Dec(StringMid($record,43,2))*2)+3
         $FileName = ""
		 While 1     ;only want names and reparse
            $Type = Dec(StringMid($record,$Offset,8),2)
            If $Type > Dec("C0000000",2) Then ExitLoop   ;no more names or reparse
            $Size = Dec(_SwapEndian(StringMid($record,$Offset+8,8)),2)
            If $Type = Dec("30000000",2) Then
               $attr = StringMid($record,$Offset,$Size*2)
                $ParentRef = Dec(_SwapEndian(StringMid($attr,49,8)),2)
               $NameSpace = StringMid($attr,179,2)
               If $NameSpace <> "02" Then
                  $NameLength = Dec(StringMid($attr,177,2))
                  $FileName = StringMid($attr,181,$NameLength*4)
                  $FileName = _UnicodeHexToStr($FileName)
                  $FileTree[$FileRef] &= "**" & $ParentRef & "*" & $FileName
               EndIf
            ElseIf $Type = Dec("C0000000",2) Then
			   $tag = StringMid($record,$Offset + 48,8)
			   $PrintNameOffset = Dec(_SwapEndian(StringMid($record,$Offset+72,4)),2)
			   $PrintNameLength = Dec(_SwapEndian(StringMid($record,$Offset+76,4)),2)
			   If $tag = "030000A0" Then	;JUNCTION
				  $PrintName = _UnicodeHexToStr(StringMid($record, $Offset+80+$PrintNameOffset*2, $PrintNameLength*2))
			   ElseIf $tag = "0C0000A0" Then	;SYMLINKD
				  $PrintName = _UnicodeHexToStr(StringMid($record, $Offset+80+$PrintNameOffset*2+8, $PrintNameLength*2))
			   Else
			   _DebugOut($ref & " Unhandled Reparse Tag: " & $tag, $record)
			   EndIf
			   $Reparse &= $ref & "*" & $tag & "*" & $PrintName & "?"
			EndIf
            $Offset += $Size*2
         WEnd
         If Not BitAND($Flags,Dec("0E00")) And $BaseRef = 0 And $FileTree[$FileRef] <> "" Then $FileTree[$FileRef] &= "?" & ($Pos + $i)     ;file also add FilePointer
         If StringInStr($FileTree[$FileRef], "**") = 1 Then $FileTree[$FileRef] = StringTrimLeft($FileTree[$FileRef],2)    ;remove leading **
      Next
   Next
   AdlibUnRegister()
   $FileTree[5] = StringMid($TargetDrive,1,1)
   $begin = TimerInit()
   AdlibRegister("_FolderStrucProgress", 500)
   For $i = 0 to UBound($FileTree)-1
      $CurrentProgress = $i
	  If StringInStr($FileTree[$i], "**") = 0 Then
         While StringInStr($FileTree[$i], "*") > 0   ;single file
            $Parent=StringMid($Filetree[$i], 1, StringInStr($FileTree[$i], "*")-1)
               $FileTree[$i] = StringReplace($FileTree[$i], $Parent & "*", $Filetree[$Parent] & "\")
         WEnd
      Else
         $Names = StringSplit($FileTree[$i], "**",3)     ;hard links
         $str = ""
		 For $n = 0 to UBound($Names) - 1
            While StringInStr($Names[$n], "*") > 0
               $Parent=StringMid($Names[$n], 1, StringInStr($Names[$n], "*")-1)
                  $Names[$n] = StringReplace($Names[$n], $Parent & "*", $Filetree[$Parent] & "\")
            WEnd
			$str &= $Names[$n] & "*"
         Next
		 $FileTree[$i] = StringTrimRight($str,1)
	  EndIf
  Next
  $FileTree[5] = $FileTree[5] & "\"
   AdlibUnRegister()
EndFunc

Func _DecodeAttrList($FileRef, $AttrList)
   Local $offset, $length, $nBytes, $List = "", $str = ""
   If StringMid($AttrList, 17, 2) = "00" Then		;attribute list is resident in AttrList
	  $offset = Dec(_SwapEndian(StringMid($AttrList, 41, 4)))
	  $List = StringMid($AttrList, $offset*2+1)		;gets list when resident
   Else			;attribute list is found from data run in $AttrList
	  $size = Dec(_SwapEndian(StringMid($AttrList, $offset*2 + 97, 16)))
	  $offset = ($offset + Dec(_SwapEndian(StringMid($AttrList, $offset*2 + 65, 4))))*2
	  $DataRun = StringMid($AttrList, $offset+1, StringLen($AttrList)-$offset)
	  Global $RUN_VCN[1], $RUN_Clusters[1]		;redim arrays
	  _ExtractDataRuns()
	  $cBuffer = DllStructCreate("byte[" & $BytesPerCluster & "]")
	  For $r = 1 To Ubound($RUN_VCN)-1
		 _WinAPI_SetFilePointerEx($hDisk, $ImageOffset+$RUN_VCN[$r]*$BytesPerCluster, $FILE_BEGIN)
		 For $i = 1 To $RUN_Clusters[$r]
			_WinAPI_ReadFile($hDisk, DllStructGetPtr($cBuffer), $BytesPerCluster, $nBytes)
			$List &= StringTrimLeft(DllStructGetData($cBuffer, 1),2)
		 Next
	  Next
	  $List = StringMid($List, 1, $size*2)
   EndIf
   If StringMid($List, 1, 8) <> "10000000" Then Return ""		;bad signature
   $offset = 0
   While StringLen($list) > $offset*2
	  $ref = Dec(_SwapEndian(StringMid($List, $offset*2 + 33, 8)))
	  If $ref <> $FileRef Then		;new attribute
		 If Not StringInStr($str, $ref) Then $str &= $ref & "-"
	  EndIf
	  $offset += Dec(_SwapEndian(StringMid($List, $offset*2 + 9, 4)))
   WEnd
   $AttrQ[0] = ""
   If $str <> "" Then $AttrQ = StringSplit(StringTrimRight($str,1), "-")
   Return $List
EndFunc

Func _StripMftRecord($record, $FileRef)
   $record = _DoFixup($record, $FileRef)
   If $record = "" then Return ""  ;corrupt, failed fixup
   $RecordSize = Dec(_SwapEndian(StringMid($record,51,8)),2)
   $HeaderSize = Dec(_SwapEndian(StringMid($record,43,4)),2)
   $record = StringMid($record,$HeaderSize*2+3,($RecordSize-$HeaderSize-8)*2)        ;strip "0x..." and "FFFFFFFF..."
   Return $record
EndFunc

Func _ExtractDataRuns()
   $r=UBound($RUN_Clusters)
   ReDim $RUN_Clusters[$r + 400], $RUN_VCN[$r + 400]
   $i=1
   $RUN_VCN[0] = 0
   $BaseVCN = $RUN_VCN[0]
   If $DataRun = "" Then $DataRun = "00"
   Do
	  $RunListID = StringMid($DataRun,$i,2)
	  If $RunListID = "00" Then ExitLoop
	  $i += 2
	  $RunListClustersLength = Dec(StringMid($RunListID,2,1))
	  $RunListVCNLength = Dec(StringMid($RunListID,1,1))
	  $RunListClusters = Dec(_SwapEndian(StringMid($DataRun,$i,$RunListClustersLength*2)),2)
	  $i += $RunListClustersLength*2
	  $RunListVCN = _SwapEndian(StringMid($DataRun, $i, $RunListVCNLength*2))
	  ;next line handles positive or negative move
	  $BaseVCN += Dec($RunListVCN,2)-(($r>1) And (Dec(StringMid($RunListVCN,1,1))>7))*Dec(StringMid("10000000000000000",1,$RunListVCNLength*2+1),2)
	  If $RunListVCN <> "" Then
		 $RunListVCN = $BaseVCN
	  Else
		 $RunListVCN = 0
	  EndIf
	  If (($RunListVCN=0) And ($RunListClusters>16) And (Mod($RunListClusters,16)>0)) Then
		 ;may be sparse section at end of Compression Signature
		 $RUN_Clusters[$r] = Mod($RunListClusters,16)
		 $RUN_VCN[$r] = $RunListVCN
		 $RunListClusters -= Mod($RunListClusters,16)
		 $r += 1
	  ElseIf (($RunListClusters>16) And (Mod($RunListClusters,16)>0)) Then
		 ;may be compressed data section at start of Compression Signature
		 $RUN_Clusters[$r] = $RunListClusters-Mod($RunListClusters,16)
		 $RUN_VCN[$r] = $RunListVCN
		 $RunListVCN += $RUN_Clusters[$r]
		 $RunListClusters = Mod($RunListClusters,16)
		 $r += 1
	  EndIf
	  ;just normal or sparse data
	  $RUN_Clusters[$r] = $RunListClusters
	  $RUN_VCN[$r] = $RunListVCN
	  $r += 1
	  $i += $RunListVCNLength*2
   Until $i > StringLen($DataRun)
   ReDim $RUN_Clusters[$r], $RUN_VCN[$r]
EndFunc

Func _DecodeDataQEntry($attr)		;processes data attribute
   $NonResidentFlag = StringMid($attr,17,2)
   $NameLength = Dec(StringMid($attr,19,2))
   $NameOffset = Dec(_SwapEndian(StringMid($attr,21,4)))
   If $NameLength > 0 Then		;must be ADS
	  $ADS_Name = _UnicodeHexToStr(StringMid($attr,$NameOffset*2 + 1,$NameLength*4))
	  $ADS_Name = $FN_FileName & "[ADS_" & $ADS_Name & "]"
   Else
	  $ADS_Name = $FN_FileName		;need to preserve $FN_FileName
   EndIf
   $Flags = StringMid($attr,25,4)
   If BitAND($Flags,"0100") Then $IsCompressed = 1
   If BitAND($Flags,"0080") Then $IsSparse = 1
   If $NonResidentFlag = '01' Then
	  $DATA_Clusters = Dec(_SwapEndian(StringMid($attr,49,16)),2) - Dec(_SwapEndian(StringMid($attr,33,16)),2) + 1
	  $DATA_RealSize = Dec(_SwapEndian(StringMid($attr,97,16)),2)
	  $DATA_InitSize = Dec(_SwapEndian(StringMid($attr,113,16)),2)
	  $Offset = Dec(_SwapEndian(StringMid($attr,65,4)))
	  $DataRun = StringMid($attr,$Offset*2+1,(StringLen($attr)-$Offset)*2)
   ElseIf $NonResidentFlag = '00' Then
	  $DATA_LengthOfAttribute = Dec(_SwapEndian(StringMid($attr,33,8)),2)
	  $Offset = Dec(_SwapEndian(StringMid($attr,41,4)))
	  $DataRun = StringMid($attr,$Offset*2+1,$DATA_LengthOfAttribute*2)
   EndIf
EndFunc

Func _DecodeMFTRecord($record, $FileRef)      ;produces DataQ
   $record = _DoFixup($record, $FileRef)
   If $record = "" then Return ""  ;corrupt, failed fixup
   $RecordSize = Dec(_SwapEndian(StringMid($record,51,8)),2)
   $AttributeOffset = (Dec(StringMid($record,43,2))*2)+3
   While 1		;only want Attribute List and Data Attributes
	  $Type = Dec(_SwapEndian(StringMid($record,$AttributeOffset,8)),2)
	  If $Type > 256 Then ExitLoop		;attributes may not be in numerical order
	  $AttributeSize = Dec(_SwapEndian(StringMid($record,$AttributeOffset+8,8)),2)
	  If $Type = 32 Then
		 $AttrList = StringMid($record,$AttributeOffset,$AttributeSize*2)	;whole attribute
		 $AttrList = _DecodeAttrList($FileRef, $AttrList)		;produces $AttrQ - extra record list
		 If $AttrList = "" Then
			_DebugOut($FileRef & " Bad Attribute List signature", $record)
			Return ""
		 Else
			If $AttrQ[0] = "" Then ContinueLoop		;no new records
			$str = ""
			For $i = 1 To $AttrQ[0]
			   If Not IsNumber($FileTree[$AttrQ[$i]]) Then
				  _DebugOut($FileRef & " Overwritten extra record (" & $AttrQ[$i] & ")", $record)
				  Return ""
			   EndIf
			   $rec = _GetAttrListMFTRecord($FileTree[$AttrQ[$i]])
			   If StringMid($rec,3,8) <> $RecordSignature Then
				  _DebugOut($FileRef & " Bad signature for extra record", $record)
				  Return ""
			   EndIf
			   If Dec(_SwapEndian(StringMid($rec,67,8)),2) <> $FileRef Then
				  _DebugOut($FileRef & " Bad extra record", $record)
				  Return ""
			   EndIf
			   $rec = _StripMftRecord($rec, $FileRef)
			   If $rec = "" Then
				  _DebugOut($FileRef & " Extra record failed Fixup", $record)
				  Return ""
			   EndIf
			   $str &= $rec		;no header or end marker
			Next
			$record = StringMid($record,1,($RecordSize-8)*2+2) & $str & "FFFFFFFF"       ;strip end first then add
		 EndIf
	  ElseIf $Type = 128 Then
		 ReDim $DataQ[UBound($DataQ) + 1]
		 $DataQ[UBound($DataQ) - 1] = StringMid($record,$AttributeOffset,$AttributeSize*2) 		;whole data attribute
	  EndIf
	  $AttributeOffset += $AttributeSize*2
   WEnd
   Return $record
EndFunc

Func _DoFixup($record, $FileRef)		;handles NT and XP style
   $UpdSeqArrOffset = Dec(_SwapEndian(StringMid($record,11,4)))
   $UpdSeqArrSize = Dec(_SwapEndian(StringMid($record,15,4)))
   $UpdSeqArr = StringMid($record,3+($UpdSeqArrOffset*2),$UpdSeqArrSize*2*2)
   $UpdSeqArrPart0 = StringMid($UpdSeqArr,1,4)
   $UpdSeqArrPart1 = StringMid($UpdSeqArr,5,4)
   $UpdSeqArrPart2 = StringMid($UpdSeqArr,9,4)
   $RecordEnd1 = StringMid($record,1023,4)
   $RecordEnd2 = StringMid($record,2047,4)
   If $UpdSeqArrPart0 <> $RecordEnd1 OR $UpdSeqArrPart0 <> $RecordEnd2 Then
      _DebugOut($FileRef & " The record failed Fixup", $record)
      Return ""
   EndIf
   Return StringMid($record,1,1022) & $UpdSeqArrPart1 & StringMid($record,1027,1020) & $UpdSeqArrPart2
EndFunc

Func _GetAttrListMFTRecord($Pos)
   Local $nBytes
   _WinAPI_SetFilePointerEx($hDisk, $ImageOffset+$Pos, $FILE_BEGIN)
   _WinAPI_ReadFile($hDisk, DllStructGetPtr($rBuffer), $MFT_Record_Size, $nBytes)
   $record = DllStructGetData($rBuffer, 1)
   Return $record		;returns MFT record for file
EndFunc

Func _ReadMFT()
   Local $nBytes
   If Not $IsMftFile Then
		_WinAPI_SetFilePointerEx($hDisk, $ImageOffset + $MFT_Offset)
	Else
		_WinAPI_SetFilePointerEx($hDisk, 0, $FILE_BEGIN)
	EndIf
   _WinAPI_ReadFile($hDisk, DllStructGetPtr($rBuffer), $MFT_Record_Size, $nBytes)
   $record = DllStructGetData($rBuffer, 1)
   If StringMid($record,3,8) = $RecordSignature And StringMid($record,47,4) = "0100" Then Return $record		;returns record for MFT
   _DebugOut("Check record for $MFT", $record)	;bad $MFT record
   Return ""
EndFunc

Func _GetDiskConstants()
	Local $nbytes
	$tBuffer = DllStructCreate("byte[512]")
	$read = _WinAPI_ReadFile($hDisk, DllStructGetPtr($tBuffer), 512, $nBytes)
	If $read = 0 Then Return ""
	$record = DllStructGetData($tBuffer, 1)
	$BytesPerSector = Dec(_SwapEndian(StringMid($record,25,4)),2)
	$SectorsPerCluster = Dec(_SwapEndian(StringMid($record,29,2)),2)
	$BytesPerCluster = $BytesPerSector * $SectorsPerCluster
	$LogicalClusterNumberforthefileMFT = Dec(_SwapEndian(StringMid($record,99,8)),2)
	$MFT_Offset = $BytesPerCluster * $LogicalClusterNumberforthefileMFT
	$ClustersPerFileRecordSegment = Dec(_SwapEndian(StringMid($record,131,8)),2)
	If $ClustersPerFileRecordSegment > 127 Then
		$MFT_Record_Size = 2 ^ (256 - $ClustersPerFileRecordSegment)
	Else
		$MFT_Record_Size = $BytesPerCluster * $ClustersPerFileRecordSegment
	EndIf
	If $IsMftFile Then
		Global $MFT_Record_Size = 1024
		Global $BytesPerCluster = 4096
		Global $MFT_Offset = 0
	EndIf
   Return $record
EndFunc

Func _DisplayInfo($DebugInfo)
   GUICtrlSetData($myctredit, $DebugInfo, 1)
EndFunc

Func _GetPhysicalDriveInfo()
   GUICtrlSetData($Combo,"","")
   Local $menu = '', $Drive = DriveGetDrive('All')
   If @error Then
	  _DisplayInfo("Error - something went wrong in Func _GetPhysicalDriveInfo" & @CRLF)
	  Return
   EndIf
   For $i = 1 to $Drive[0]
	  $DriveType = DriveGetType($Drive[$i])
	  $DriveCapacity = Round(DriveSpaceTotal($Drive[$i]),0)
	  If DriveGetFileSystem($Drive[$i]) = 'NTFS' Then
		 $menu &=  StringUpper($Drive[$i]) & "  (" & $DriveType & ")  - " & $DriveCapacity & " MB  - NTFS|"
	  EndIf
   Next
   If $menu Then
	  _DisplayInfo("NTFS drives detected" & @CRLF)
	  GUICtrlSetData($Combo, $menu, StringMid($menu, 1, StringInStr($menu, "|") -1))
	  $IsImage = False
   Else
	  _DisplayInfo("No NTFS drives detected" & @CRLF)
   EndIf
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

Func _DebugOut($text, $var="")
   If $var Then $var = _HexEncode($var) & @CRLF
   $text &= @CRLF & $var
   ConsoleWrite($text)
   If $logfile Then FileWrite($logfile, $text)
EndFunc

; start: by trancexxx --------------------------------------
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
EndFunc

Func _LZNTDecompress($tInput, $Size)	;note function returns a null string if error, or an array if no error
	Local $tOutput[2]
	Local $cBuffer = DllStructCreate("byte[" & $BytesPerCluster*16 & "]")
    Local $a_Call = DllCall("ntdll.dll", "int", "RtlDecompressBuffer", _
            "ushort", 2, _
            "ptr", DllStructGetPtr($cBuffer), _
            "dword", DllStructGetSize($cBuffer), _
            "ptr", DllStructGetPtr($tInput), _
            "dword", $Size, _
            "dword*", 0)

    If @error Or $a_Call[0] Then	;if $a_Call[0]=0 then output size is in $a_Call[6], otherwise $a_Call[6] is invalid
        Return SetError(1, 0, "") ; error decompressing
    EndIf
    Local $Decompressed = DllStructCreate("byte[" & $a_Call[6] & "]", DllStructGetPtr($cBuffer))
	$tOutput[0] = DllStructGetData($Decompressed, 1)
	$tOutput[1] = $a_Call[6]
    Return SetError(0, 0, $tOutput)
EndFunc
; end: by trancexxx -------------------------------------

Func _DoFileTreeProgress()
    GUICtrlSetData($ProgressStatus, "First examination of MFT record " & $CurrentProgress & " of " & $Total & " (step 1 of 3)")
    GUICtrlSetData($ElapsedTime, "Elapsed time = " & _WinAPI_StrFromTimeInterval(TimerDiff($begin)))
	GUICtrlSetData($OverallProgress, 100 * $CurrentProgress / $Total)
EndFunc

Func _FolderStrucProgress()
	GUICtrlSetData($ProgressStatus, "Resolving paths " & $CurrentProgress & " of " & $Total & " (step 2 of 3)")
	GUICtrlSetData($ElapsedTime, "Elapsed time = " & _WinAPI_StrFromTimeInterval(TimerDiff($begin)))
    GUICtrlSetData($OverallProgress, 100 * $CurrentProgress / $Total)
EndFunc

Func _ExtractionProgress()
	GUICtrlSetData($ProgressStatus, "Decoding record " & $CurrentProgress & " of " & $Total & " (step 3 of 3)")
	GUICtrlSetData($ElapsedTime, "Elapsed time = " & _WinAPI_StrFromTimeInterval(TimerDiff($begin)))
    GUICtrlSetData($OverallProgress, 100 * $CurrentProgress / $Total)
	GUICtrlSetData($ProgressFileName, $FN_FileName)
	GUICtrlSetData($FileProgress, 100 * ($DATA_RealSize - $ProgressSize) / $DATA_RealSize)
EndFunc

Func _ProcessImage()
	$TargetImageFile = FileOpenDialog("Select image file",@ScriptDir,"All (*.*)")
	If @error then Return
	_DisplayInfo("Selected disk image file: " & $TargetImageFile & @CRLF)
	GUICtrlSetData($Combo,"","")
	$Entries = ''
	_CheckMBR()
	GUICtrlSetData($Combo,$Entries,StringMid($Entries, 1, StringInStr($Entries, "|") -1))
	If $Entries = "" Then _DisplayInfo("Sorry, no NTFS volume found in that file." & @CRLF)
EndFunc   ;==>_ProcessImage

Func _CheckMBR()
	Local $nbytes, $PartitionNumber, $PartitionEntry,$FilesystemDescriptor
	Local $StartingSector,$NumberOfSectors
	Local $hImage = _WinAPI_CreateFile("\\.\" & $TargetImageFile,2,2,7)
	$tBuffer = DllStructCreate("byte[512]")
	Local $read = _WinAPI_ReadFile($hImage, DllStructGetPtr($tBuffer), 512, $nBytes)
	If $read = 0 Then Return ""
	Local $sector = DllStructGetData($tBuffer, 1)
	For $PartitionNumber = 0 To 3
		$PartitionEntry = StringMid($sector,($PartitionNumber*32)+3+892,32)
		If $PartitionEntry = "00000000000000000000000000000000" Then ExitLoop ; No more entries
		$FilesystemDescriptor = StringMid($PartitionEntry,9,2)
		$StartingSector = Dec(_SwapEndian(StringMid($PartitionEntry,17,8)),2)
		$NumberOfSectors = Dec(_SwapEndian(StringMid($PartitionEntry,25,8)),2)
		If ($FilesystemDescriptor = "EE" and $StartingSector = 1 and $NumberOfSectors = 4294967295) Then ; A typical dummy partition to prevent overwriting of GPT data, also known as "protective MBR"
			_CheckGPT($hImage)
		ElseIf $FilesystemDescriptor = "05" Or $FilesystemDescriptor = "0F" Then ;Extended partition
			_CheckExtendedPartition($StartingSector, $hImage)
		ElseIf $FilesystemDescriptor = "07" Then ;Marked as NTFS
			$Entries &= _GenComboDescription($StartingSector,$NumberOfSectors)
		EndIf
    Next
	If $Entries = "" Then ;Also check if pure partition image (without mbr)
		If _TestNTFS($hImage, 0) Then
			$ImageSize = _WinAPI_GetFileSizeEx($hImage)
			If not @error Then $Entries = _GenComboDescription(0,$ImageSize/512)
		EndIf
	EndIf
	_WinAPI_CloseHandle($hImage)
EndFunc   ;==>_CheckMBR

Func _CheckGPT($hImage) ; Assume GPT to be present at sector 1, which is not fool proof
   ;Actually it is. While LBA1 may not be at sector 1 on the disk, it will always be there in an image.
	Local $nbytes,$read,$sector,$GPTSignature,$StartLBA,$Processed=0,$FirstLBA,$LastLBA
	$tBuffer = DllStructCreate("byte[512]")
	$read = _WinAPI_ReadFile($hImage, DllStructGetPtr($tBuffer), 512, $nBytes)		;read second sector
	If $read = 0 Then Return ""
	$sector = DllStructGetData($tBuffer, 1)
	$GPTSignature = StringMid($sector,3,16)
	If $GPTSignature <> "4546492050415254" Then
		_DebugOut("Error: Could not find GPT signature:", StringMid($sector,3))
		Return
	EndIf
	$StartLBA = Dec(_SwapEndian(StringMid($sector,147,16)),2)
	$PartitionsInArray = Dec(_SwapEndian(StringMid($sector,163,8)),2)
	$PartitionEntrySize = Dec(_SwapEndian(StringMid($sector,171,8)),2)
	_WinAPI_SetFilePointerEx($hImage, $StartLBA*512, $FILE_BEGIN)
	$SizeNeeded = $PartitionsInArray*$PartitionEntrySize ;Set buffer size -> maximum number of partition entries that can fit in the array
	$tBuffer = DllStructCreate("byte[" & $SizeNeeded & "]")
	$read = _WinAPI_ReadFile($hImage, DllStructGetPtr($tBuffer), $SizeNeeded, $nBytes)
	If $read = 0 Then Return ""
	$sector = DllStructGetData($tBuffer, 1)
	Do
		$FirstLBA = Dec(_SwapEndian(StringMid($sector,67+($Processed*2),16)),2)
		$LastLBA = Dec(_SwapEndian(StringMid($sector,83+($Processed*2),16)),2)
		If $FirstLBA = 0 And $LastLBA = 0 Then ExitLoop ; No more entries
		$Processed += $PartitionEntrySize
		If Not _TestNTFS($hImage, $FirstLBA) Then ContinueLoop ;Continue the loop if filesystem not NTFS
		$Entries &= _GenComboDescription($FirstLBA,$LastLBA-$FirstLBA)
	Until $Processed >= $SizeNeeded
EndFunc   ;==>_CheckGPT

Func _CheckExtendedPartition($StartSector, $hImage)	;Extended partitions can only contain Logical Drives, but can be more than 4
   Local $nbytes,$read,$sector,$NextEntry=0,$StartingSector,$NumberOfSectors,$PartitionTable,$FilesystemDescriptor
   $tBuffer = DllStructCreate("byte[512]")
   While 1
	  _WinAPI_SetFilePointerEx($hImage, ($StartSector + $NextEntry) * 512, $FILE_BEGIN)
	  $read = _WinAPI_ReadFile($hImage, DllStructGetPtr($tBuffer), 512, $nBytes)
	  If $read = 0 Then Return ""
	  $sector = DllStructGetData($tBuffer, 1)
	  $PartitionTable = StringMid($sector,3+892,64)
	  $FilesystemDescriptor = StringMid($PartitionTable,9,2)
	  $StartingSector = $StartSector+$NextEntry+Dec(_SwapEndian(StringMid($PartitionTable,17,8)),2)
	  $NumberOfSectors = Dec(_SwapEndian(StringMid($PartitionTable,25,8)),2)
	  If $FilesystemDescriptor = "07" Then $Entries &= _GenComboDescription($StartingSector,$NumberOfSectors)
	  If StringMid($PartitionTable,33) = "00000000000000000000000000000000" Then ExitLoop ; No more entries
	  $NextEntry = Dec(_SwapEndian(StringMid($PartitionTable,49,8)),2)
   WEnd
EndFunc   ;==>_CheckExtendedPartition

Func _TestNTFS($hImage, $PartitionStartSector)
	Local $nbytes
	If $PartitionStartSector <> 0 Then
		_WinAPI_SetFilePointerEx($hImage, $PartitionStartSector*512, $FILE_BEGIN)
	Else
		_WinAPI_CloseHandle($hImage)
		$hImage = _WinAPI_CreateFile("\\.\" & $TargetImageFile,2,2,7)
	EndIf
	$tBuffer = DllStructCreate("byte[512]")
	$read = _WinAPI_ReadFile($hImage, DllStructGetPtr($tBuffer), 512, $nBytes)
	If $read = 0 Then Return ""
	$sector = DllStructGetData($tBuffer, 1)
	$TestSig = StringMid($sector,9,8)
	If $TestSig = "4E544653" Then Return 1		; Volume is NTFS
	_DebugOut("Could not find NTFS:", StringMid($sector,3))		; Volume is not NTFS
    Return 0
EndFunc   ;==>_TestNTFS

Func _GenComboDescription($StartSector,$SectorNumber)
	Return "Offset = " & $StartSector*512 & ": Volume size = " & Round(($SectorNumber*512)/1024/1024/1024,2) & " GB|"
EndFunc   ;==>_GenComboDescription

Func _SelectMftFile()
	$TargetMftFile = FileOpenDialog("Select image file",@ScriptDir,"All (*.*)")
	If @error then Return
	_DisplayInfo("Selected $MFT file: " & $TargetMftFile & @CRLF)
	GUICtrlSetData($Combo,"","")
	$Entries = ''
EndFunc   ;==>_SelectMftFile

Func _ParserCodeOldVersion($MFTEntry)
	$FN_Number = 0
	$DATA_Number = 0
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
	$HEADER_LSN = StringMid($MFTEntry, 19, 16)
	$HEADER_LSN = Dec(StringMid($HEADER_LSN, 15, 2) & StringMid($HEADER_LSN, 13, 2) & StringMid($HEADER_LSN, 11, 2) & StringMid($HEADER_LSN, 9, 2) & StringMid($HEADER_LSN, 7, 2) & StringMid($HEADER_LSN, 5, 2) & StringMid($HEADER_LSN, 3, 2) & StringMid($HEADER_LSN, 1, 2))
	$HEADER_SequenceNo = StringMid($MFTEntry, 35, 4)
	$HEADER_SequenceNo = Dec(StringMid($HEADER_SequenceNo, 3, 2) & StringMid($HEADER_SequenceNo, 1, 2))
	$Header_HardLinkCount = StringMid($MFTEntry,39,4)
	$Header_HardLinkCount = Dec(StringMid($Header_HardLinkCount,3,2) & StringMid($Header_HardLinkCount,1,2))
	$HEADER_Flags = StringMid($MFTEntry, 47, 4);00=deleted file,01=file,02=deleted folder,03=folder
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
	$HEADER_RecordRealSize = StringMid($MFTEntry, 51, 8)
	$HEADER_RecordRealSize = Dec(StringMid($HEADER_RecordRealSize, 7, 2) & StringMid($HEADER_RecordRealSize, 5, 2) & StringMid($HEADER_RecordRealSize, 3, 2) & StringMid($HEADER_RecordRealSize, 1, 2))
	$HEADER_RecordAllocSize = StringMid($MFTEntry, 59, 8)
	$HEADER_RecordAllocSize = Dec(StringMid($HEADER_RecordAllocSize, 7, 2) & StringMid($HEADER_RecordAllocSize, 5, 2) & StringMid($HEADER_RecordAllocSize, 3, 2) & StringMid($HEADER_RecordAllocSize, 1, 2))
	$HEADER_BaseRecord = StringMid($MFTEntry, 67, 12)
	$HEADER_BaseRecord = Dec(StringMid($HEADER_BaseRecord, 7, 2) & StringMid($HEADER_BaseRecord, 5, 2) & StringMid($HEADER_BaseRecord, 3, 2) & StringMid($HEADER_BaseRecord, 1, 2))
	$HEADER_BaseRecSeqNo = StringMid($MFTEntry, 79, 4)
	$HEADER_BaseRecSeqNo = Dec(StringMid($HEADER_BaseRecSeqNo, 3, 2) & StringMid($HEADER_BaseRecSeqNo, 1, 2))
	$HEADER_NextAttribID = StringMid($MFTEntry, 83, 4)
	$HEADER_NextAttribID = "0x"&StringMid($HEADER_NextAttribID, 3, 2) & StringMid($HEADER_NextAttribID, 1, 2)
	If $UpdSeqArrOffset = 48 Then
		$HEADER_MFTREcordNumber = StringMid($MFTEntry, 91, 8)
		$HEADER_MFTREcordNumber = Dec(StringMid($HEADER_MFTREcordNumber, 7, 2) & StringMid($HEADER_MFTREcordNumber, 5, 2) & StringMid($HEADER_MFTREcordNumber, 3, 2) & StringMid($HEADER_MFTREcordNumber, 1, 2))
	Else
		$HEADER_MFTREcordNumber = "NT style"
	EndIf
	$NextAttributeOffset = (Dec(StringMid($MFTEntry, 43, 2)) * 2) + 3
	$AttributeType = StringMid($MFTEntry, $NextAttributeOffset, 8)
	$AttributeSize = StringMid($MFTEntry, $NextAttributeOffset + 8, 8)
	$AttributeSize = Dec(StringMid($AttributeSize, 7, 2) & StringMid($AttributeSize, 5, 2) & StringMid($AttributeSize, 3, 2) & StringMid($AttributeSize, 1, 2))
	$AttributeKnown = 1
	While $AttributeKnown = 1
		$NextAttributeType = StringMid($MFTEntry, $NextAttributeOffset, 8)
		$AttributeType = $NextAttributeType
		$AttributeSize = StringMid($MFTEntry, $NextAttributeOffset + 8, 8)
		$AttributeSize = Dec(StringMid($AttributeSize, 7, 2) & StringMid($AttributeSize, 5, 2) & StringMid($AttributeSize, 3, 2) & StringMid($AttributeSize, 1, 2))
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
;				ConsoleWrite("No more attributes in this record." & @CRLF)

			Case $AttributeType <> $LOGGED_UTILITY_STREAM And $AttributeType <> $EA And $AttributeType <> $EA_INFORMATION And $AttributeType <> $REPARSE_POINT And $AttributeType <> $BITMAP And $AttributeType <> $INDEX_ALLOCATION And $AttributeType <> $INDEX_ROOT And $AttributeType <> $DATA And $AttributeType <> $VOLUME_INFORMATION And $AttributeType <> $VOLUME_NAME And $AttributeType <> $SECURITY_DESCRIPTOR And $AttributeType <> $OBJECT_ID And $AttributeType <> $FILE_NAME And $AttributeType <> $ATTRIBUTE_LIST And $AttributeType <> $STANDARD_INFORMATION And $AttributeType <> $PROPERTY_SET And $AttributeType <> $ATTRIBUTE_END_MARKER
				$AttributeKnown = 0
;				ConsoleWrite("Unknown attribute found in this record." & @CRLF)

		EndSelect

		$NextAttributeOffset = $NextAttributeOffset + ($AttributeSize * 2)
	WEnd
EndFunc

; start: by jennico (jennicoattminusonlinedotde) ---------------------------
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
; end: by jennico (jennicoattminusonlinedotde) ------------------------------------

Func _Get_StandardInformation($MFTEntry, $SI_Offset, $SI_Size)
	$SI_HEADER_Flags = StringMid($MFTEntry, $SI_Offset + 24, 4)
	$SI_HEADER_Flags = StringMid($SI_HEADER_Flags, 3, 2) & StringMid($SI_HEADER_Flags, 1, 2)
	$SI_HEADER_Flags = _AttribHeaderFlags("0x" & $SI_HEADER_Flags)
	;
	$SI_CTime = StringMid($MFTEntry, $SI_Offset + 48, 16)
	$SI_CTime = StringMid($SI_CTime, 15, 2) & StringMid($SI_CTime, 13, 2) & StringMid($SI_CTime, 11, 2) & StringMid($SI_CTime, 9, 2) & StringMid($SI_CTime, 7, 2) & StringMid($SI_CTime, 5, 2) & StringMid($SI_CTime, 3, 2) & StringMid($SI_CTime, 1, 2)
	$SI_CTime_tmp = _WinTime_UTCFileTimeToLocalFileTime("0x" & $SI_CTime)
	$SI_CTime = _WinTime_UTCFileTimeFormat(_HexToDec($SI_CTime) - $tDelta, $DateTimeFormat, 2)
	$SI_CTime = $SI_CTime & ":" & _FillZero(StringRight($SI_CTime_tmp, 4))
	$MSecTest = _Test_MilliSec($SI_CTime)
	;
	$SI_ATime = StringMid($MFTEntry, $SI_Offset + 64, 16)
	$SI_ATime = StringMid($SI_ATime, 15, 2) & StringMid($SI_ATime, 13, 2) & StringMid($SI_ATime, 11, 2) & StringMid($SI_ATime, 9, 2) & StringMid($SI_ATime, 7, 2) & StringMid($SI_ATime, 5, 2) & StringMid($SI_ATime, 3, 2) & StringMid($SI_ATime, 1, 2)
	$SI_ATime_tmp = _WinTime_UTCFileTimeToLocalFileTime("0x" & $SI_ATime)
	$SI_ATime = _WinTime_UTCFileTimeFormat(_HexToDec($SI_ATime) - $tDelta, $DateTimeFormat, 2)
	$SI_ATime = $SI_ATime & ":" & _FillZero(StringRight($SI_ATime_tmp, 4))
	;
	$SI_MTime = StringMid($MFTEntry, $SI_Offset + 80, 16)
	$SI_MTime = StringMid($SI_MTime, 15, 2) & StringMid($SI_MTime, 13, 2) & StringMid($SI_MTime, 11, 2) & StringMid($SI_MTime, 9, 2) & StringMid($SI_MTime, 7, 2) & StringMid($SI_MTime, 5, 2) & StringMid($SI_MTime, 3, 2) & StringMid($SI_MTime, 1, 2)
	$SI_MTime_tmp = _WinTime_UTCFileTimeToLocalFileTime("0x" & $SI_MTime)
	$SI_MTime = _WinTime_UTCFileTimeFormat(_HexToDec($SI_MTime) - $tDelta, $DateTimeFormat, 2)
	$SI_MTime = $SI_MTime & ":" & _FillZero(StringRight($SI_MTime_tmp, 4))
	;
	$SI_RTime = StringMid($MFTEntry, $SI_Offset + 96, 16)
	$SI_RTime = StringMid($SI_RTime, 15, 2) & StringMid($SI_RTime, 13, 2) & StringMid($SI_RTime, 11, 2) & StringMid($SI_RTime, 9, 2) & StringMid($SI_RTime, 7, 2) & StringMid($SI_RTime, 5, 2) & StringMid($SI_RTime, 3, 2) & StringMid($SI_RTime, 1, 2)
	$SI_RTime_tmp = _WinTime_UTCFileTimeToLocalFileTime("0x" & $SI_RTime)
	$SI_RTime = _WinTime_UTCFileTimeFormat(_HexToDec($SI_RTime) - $tDelta, $DateTimeFormat, 2)
	$SI_RTime = $SI_RTime & ":" & _FillZero(StringRight($SI_RTime_tmp, 4))
	;
	$SI_FilePermission = StringMid($MFTEntry, $SI_Offset + 112, 8)
	$SI_FilePermission = StringMid($SI_FilePermission, 7, 2) & StringMid($SI_FilePermission, 5, 2) & StringMid($SI_FilePermission, 3, 2) & StringMid($SI_FilePermission, 1, 2)
	$SI_FilePermission = _File_Permissions("0x" & $SI_FilePermission)
	$SI_MaxVersions = StringMid($MFTEntry, $SI_Offset + 120, 8)
	$SI_MaxVersions = Dec(StringMid($SI_MaxVersions, 7, 2) & StringMid($SI_MaxVersions, 5, 2) & StringMid($SI_MaxVersions, 3, 2) & StringMid($SI_MaxVersions, 1, 2))
	$SI_VersionNumber = StringMid($MFTEntry, $SI_Offset + 128, 8)
	$SI_VersionNumber = Dec(StringMid($SI_VersionNumber, 7, 2) & StringMid($SI_VersionNumber, 5, 2) & StringMid($SI_VersionNumber, 3, 2) & StringMid($SI_VersionNumber, 1, 2))
	$SI_ClassID = StringMid($MFTEntry, $SI_Offset + 136, 8)
	$SI_ClassID = Dec(StringMid($SI_ClassID, 7, 2) & StringMid($SI_ClassID, 5, 2) & StringMid($SI_ClassID, 3, 2) & StringMid($SI_ClassID, 1, 2))
	$SI_OwnerID = StringMid($MFTEntry, $SI_Offset + 144, 8)
	$SI_OwnerID = Dec(StringMid($SI_OwnerID, 7, 2) & StringMid($SI_OwnerID, 5, 2) & StringMid($SI_OwnerID, 3, 2) & StringMid($SI_OwnerID, 1, 2))
	$SI_SecurityID = StringMid($MFTEntry, $SI_Offset + 152, 8)
	$SI_SecurityID = Dec(StringMid($SI_SecurityID, 7, 2) & StringMid($SI_SecurityID, 5, 2) & StringMid($SI_SecurityID, 3, 2) & StringMid($SI_SecurityID, 1, 2))
	$SI_USN = StringMid($MFTEntry, $SI_Offset + 176, 16)
	$SI_USN = Dec(StringMid($SI_USN, 15, 2) & StringMid($SI_USN, 13, 2) & StringMid($SI_USN, 11, 2) & StringMid($SI_USN, 9, 2) & StringMid($SI_USN, 7, 2) & StringMid($SI_USN, 5, 2) & StringMid($SI_USN, 3, 2) & StringMid($SI_USN, 1, 2),2)
EndFunc   ;==>_Get_StandardInformation

Func _Get_AttributeList()
;	ConsoleWrite("Get_AttributeList Function not implemented yet." & @CRLF)
	Return
EndFunc   ;==>_Get_AttributeList

Func _Get_FileName($MFTEntry, $FN_Offset, $FN_Size, $FN_Number)
	If $FN_Number = 1 Then
		$FN_ParentReferenceNo = StringMid($MFTEntry, $FN_Offset + 48, 12)
		$FN_ParentReferenceNo = _HexToDec(StringMid($FN_ParentReferenceNo, 11, 2) & StringMid($FN_ParentReferenceNo, 9, 2) & StringMid($FN_ParentReferenceNo, 7, 2) & StringMid($FN_ParentReferenceNo, 5, 2) & StringMid($FN_ParentReferenceNo, 3, 2) & StringMid($FN_ParentReferenceNo, 1, 2))
		$FN_ParentSequenceNo = StringMid($MFTEntry, $FN_Offset + 60, 4)
		$FN_ParentSequenceNo = Dec(StringMid($FN_ParentSequenceNo, 3, 2) & StringMid($FN_ParentSequenceNo, 1, 2))
		;
		$FN_CTime = StringMid($MFTEntry, $FN_Offset + 64, 16)
		$FN_CTime = StringMid($FN_CTime, 15, 2) & StringMid($FN_CTime, 13, 2) & StringMid($FN_CTime, 11, 2) & StringMid($FN_CTime, 9, 2) & StringMid($FN_CTime, 7, 2) & StringMid($FN_CTime, 5, 2) & StringMid($FN_CTime, 3, 2) & StringMid($FN_CTime, 1, 2)
		$FN_CTime_tmp = _WinTime_UTCFileTimeToLocalFileTime("0x" & $FN_CTime)
		$FN_CTime = _WinTime_UTCFileTimeFormat(_HexToDec($FN_CTime) - $tDelta, $DateTimeFormat, 2)
		$FN_CTime = $FN_CTime & ":" & _FillZero(StringRight($FN_CTime_tmp, 4))
		;
		$FN_ATime = StringMid($MFTEntry, $FN_Offset + 80, 16)
		$FN_ATime = StringMid($FN_ATime, 15, 2) & StringMid($FN_ATime, 13, 2) & StringMid($FN_ATime, 11, 2) & StringMid($FN_ATime, 9, 2) & StringMid($FN_ATime, 7, 2) & StringMid($FN_ATime, 5, 2) & StringMid($FN_ATime, 3, 2) & StringMid($FN_ATime, 1, 2)
		$FN_ATime_tmp = _WinTime_UTCFileTimeToLocalFileTime("0x" & $FN_ATime)
		$FN_ATime = _WinTime_UTCFileTimeFormat(_HexToDec($FN_ATime) - $tDelta, $DateTimeFormat, 2)
		$FN_ATime = $FN_ATime & ":" & _FillZero(StringRight($FN_ATime_tmp, 4))
		;
		$FN_MTime = StringMid($MFTEntry, $FN_Offset + 96, 16)
		$FN_MTime = StringMid($FN_MTime, 15, 2) & StringMid($FN_MTime, 13, 2) & StringMid($FN_MTime, 11, 2) & StringMid($FN_MTime, 9, 2) & StringMid($FN_MTime, 7, 2) & StringMid($FN_MTime, 5, 2) & StringMid($FN_MTime, 3, 2) & StringMid($FN_MTime, 1, 2)
		$FN_MTime_tmp = _WinTime_UTCFileTimeToLocalFileTime("0x" & $FN_MTime)
		$FN_MTime = _WinTime_UTCFileTimeFormat(_HexToDec($FN_MTime) - $tDelta, $DateTimeFormat, 2)
		$FN_MTime = $FN_MTime & ":" & _FillZero(StringRight($FN_MTime_tmp, 4))
		;
		$FN_RTime = StringMid($MFTEntry, $FN_Offset + 112, 16)
		$FN_RTime = StringMid($FN_RTime, 15, 2) & StringMid($FN_RTime, 13, 2) & StringMid($FN_RTime, 11, 2) & StringMid($FN_RTime, 9, 2) & StringMid($FN_RTime, 7, 2) & StringMid($FN_RTime, 5, 2) & StringMid($FN_RTime, 3, 2) & StringMid($FN_RTime, 1, 2)
		$FN_RTime_tmp = _WinTime_UTCFileTimeToLocalFileTime("0x" & $FN_RTime)
		$FN_RTime = _WinTime_UTCFileTimeFormat(_HexToDec($FN_RTime) - $tDelta, $DateTimeFormat, 2)
		$FN_RTime = $FN_RTime & ":" & _FillZero(StringRight($FN_RTime_tmp, 4))
		;
		$FN_AllocSize = StringMid($MFTEntry, $FN_Offset + 128, 16)
		$FN_AllocSize = _HexToDec(StringMid($FN_AllocSize, 15, 2) & StringMid($FN_AllocSize, 13, 2) & StringMid($FN_AllocSize, 11, 2) & StringMid($FN_AllocSize, 9, 2) & StringMid($FN_AllocSize, 7, 2) & StringMid($FN_AllocSize, 5, 2) & StringMid($FN_AllocSize, 3, 2) & StringMid($FN_AllocSize, 1, 2))
		$FN_RealSize = StringMid($MFTEntry, $FN_Offset + 144, 16)
		$FN_RealSize = _HexToDec(StringMid($FN_RealSize, 15, 2) & StringMid($FN_RealSize, 13, 2) & StringMid($FN_RealSize, 11, 2) & StringMid($FN_RealSize, 9, 2) & StringMid($FN_RealSize, 7, 2) & StringMid($FN_RealSize, 5, 2) & StringMid($FN_RealSize, 3, 2) & StringMid($FN_RealSize, 1, 2))
		$FN_Flags = StringMid($MFTEntry, $FN_Offset + 160, 8)
		$FN_Flags = StringMid($FN_Flags, 7, 2) & StringMid($FN_Flags, 5, 2) & StringMid($FN_Flags, 3, 2) & StringMid($FN_Flags, 1, 2)
		$FN_Flags = _File_Permissions("0x" & $FN_Flags)
		$FN_NameLength = StringMid($MFTEntry, $FN_Offset + 176, 2)
		$FN_NameLength = Dec($FN_NameLength)
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
		$FN_NameSpace = $FN_NameLength - 1 ;Not really
		$FN_FileName = StringMid($MFTEntry, $FN_Offset + 180, ($FN_NameLength + $FN_NameSpace) * 2)
		$FN_FileName = _UnicodeHexToStr($FN_FileName)
		If StringLen($FN_FileName) <> $FN_NameLength Then $INVALID_FILENAME = 1
	EndIf
	If $FN_Number = 2 Then
		$FN_ParentReferenceNo_2 = StringMid($MFTEntry, $FN_Offset + 48, 12)
		$FN_ParentReferenceNo_2 = _HexToDec(StringMid($FN_ParentReferenceNo_2, 11, 2) & StringMid($FN_ParentReferenceNo_2, 9, 2) & StringMid($FN_ParentReferenceNo_2, 7, 2) & StringMid($FN_ParentReferenceNo_2, 5, 2) & StringMid($FN_ParentReferenceNo_2, 3, 2) & StringMid($FN_ParentReferenceNo_2, 1, 2))
		$FN_ParentSequenceNo_2 = StringMid($MFTEntry, $FN_Offset + 60, 4)
		$FN_ParentSequenceNo_2 = Dec(StringMid($FN_ParentSequenceNo_2, 3, 2) & StringMid($FN_ParentSequenceNo_2, 1, 2))
		$FN_CTime_2 = StringMid($MFTEntry, $FN_Offset + 64, 16)
		$FN_CTime_2 = StringMid($FN_CTime_2, 15, 2) & StringMid($FN_CTime_2, 13, 2) & StringMid($FN_CTime_2, 11, 2) & StringMid($FN_CTime_2, 9, 2) & StringMid($FN_CTime_2, 7, 2) & StringMid($FN_CTime_2, 5, 2) & StringMid($FN_CTime_2, 3, 2) & StringMid($FN_CTime_2, 1, 2)
		$FN_CTime_2_tmp = _WinTime_UTCFileTimeToLocalFileTime("0x" & $FN_CTime_2)
		$FN_CTime_2 = _WinTime_UTCFileTimeFormat(_HexToDec($FN_CTime_2) - $tDelta, $DateTimeFormat, 2)
		$FN_CTime_2 = $FN_CTime_2 & ":" & _FillZero(StringRight($FN_CTime_2_tmp, 4))
		;
		$FN_ATime_2 = StringMid($MFTEntry, $FN_Offset + 80, 16)
		$FN_ATime_2 = StringMid($FN_ATime_2, 15, 2) & StringMid($FN_ATime_2, 13, 2) & StringMid($FN_ATime_2, 11, 2) & StringMid($FN_ATime_2, 9, 2) & StringMid($FN_ATime_2, 7, 2) & StringMid($FN_ATime_2, 5, 2) & StringMid($FN_ATime_2, 3, 2) & StringMid($FN_ATime_2, 1, 2)
		$FN_ATime_2_tmp = _WinTime_UTCFileTimeToLocalFileTime("0x" & $FN_ATime_2)
		$FN_ATime_2 = _WinTime_UTCFileTimeFormat(_HexToDec($FN_ATime_2) - $tDelta, $DateTimeFormat, 2)
		$FN_ATime_2 = $FN_ATime_2 & ":" & _FillZero(StringRight($FN_ATime_2_tmp, 4))
		;
		$FN_MTime_2 = StringMid($MFTEntry, $FN_Offset + 96, 16)
		$FN_MTime_2 = StringMid($FN_MTime_2, 15, 2) & StringMid($FN_MTime_2, 13, 2) & StringMid($FN_MTime_2, 11, 2) & StringMid($FN_MTime_2, 9, 2) & StringMid($FN_MTime_2, 7, 2) & StringMid($FN_MTime_2, 5, 2) & StringMid($FN_MTime_2, 3, 2) & StringMid($FN_MTime_2, 1, 2)
		$FN_MTime_2_tmp = _WinTime_UTCFileTimeToLocalFileTime("0x" & $FN_MTime_2)
		$FN_MTime_2 = _WinTime_UTCFileTimeFormat(_HexToDec($FN_MTime_2) - $tDelta, $DateTimeFormat, 2)
		$FN_MTime_2 = $FN_MTime_2 & ":" & _FillZero(StringRight($FN_MTime_2_tmp, 4))
		;
		$FN_RTime_2 = StringMid($MFTEntry, $FN_Offset + 112, 16)
		$FN_RTime_2 = StringMid($FN_RTime_2, 15, 2) & StringMid($FN_RTime_2, 13, 2) & StringMid($FN_RTime_2, 11, 2) & StringMid($FN_RTime_2, 9, 2) & StringMid($FN_RTime_2, 7, 2) & StringMid($FN_RTime_2, 5, 2) & StringMid($FN_RTime_2, 3, 2) & StringMid($FN_RTime_2, 1, 2)
		$FN_RTime_2_tmp = _WinTime_UTCFileTimeToLocalFileTime("0x" & $FN_RTime_2)
		$FN_RTime_2 = _WinTime_UTCFileTimeFormat(_HexToDec($FN_RTime_2) - $tDelta, $DateTimeFormat, 2)
		$FN_RTime_2 = $FN_RTime_2 & ":" & _FillZero(StringRight($FN_RTime_2_tmp, 4))
		;
		$FN_AllocSize_2 = StringMid($MFTEntry, $FN_Offset + 128, 16)
		$FN_AllocSize_2 = _HexToDec(StringMid($FN_AllocSize_2, 15, 2) & StringMid($FN_AllocSize_2, 13, 2) & StringMid($FN_AllocSize_2, 11, 2) & StringMid($FN_AllocSize_2, 9, 2) & StringMid($FN_AllocSize_2, 7, 2) & StringMid($FN_AllocSize_2, 5, 2) & StringMid($FN_AllocSize_2, 3, 2) & StringMid($FN_AllocSize_2, 1, 2))
		$FN_RealSize_2 = StringMid($MFTEntry, $FN_Offset + 144, 16)
		$FN_RealSize_2 = _HexToDec(StringMid($FN_RealSize_2, 15, 2) & StringMid($FN_RealSize_2, 13, 2) & StringMid($FN_RealSize_2, 11, 2) & StringMid($FN_RealSize_2, 9, 2) & StringMid($FN_RealSize_2, 7, 2) & StringMid($FN_RealSize_2, 5, 2) & StringMid($FN_RealSize_2, 3, 2) & StringMid($FN_RealSize_2, 1, 2))
		$FN_Flags_2 = StringMid($MFTEntry, $FN_Offset + 160, 8)
		$FN_Flags_2 = _File_Permissions("0x" & $FN_Flags_2)
		$FN_NameLength_2 = StringMid($MFTEntry, $FN_Offset + 176, 2)
		$FN_NameLength_2 = Dec($FN_NameLength_2)
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
		$FN_FileName_2 = StringMid($MFTEntry, $FN_Offset + 180, ($FN_NameLength_2 + $FN_NameSpace_2) * 2)
		$FN_FileName_2 = _UnicodeHexToStr($FN_FileName_2)
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
	$GUID_ObjectID = StringMid($GUID_ObjectID, 1, 8) & "-" & StringMid($GUID_ObjectID, 9, 4) & "-" & StringMid($GUID_ObjectID, 13, 4) & "-" & StringMid($GUID_ObjectID, 17, 4) & "-" & StringMid($GUID_ObjectID, 21, 12)
	If $OBJECTID_Size - 24 = 32 Then
		$GUID_BirthVolumeID = StringMid($MFTEntry, $OBJECTID_Offset + 80, 32)
		$GUID_BirthVolumeID = StringMid($GUID_BirthVolumeID, 1, 8) & "-" & StringMid($GUID_BirthVolumeID, 9, 4) & "-" & StringMid($GUID_BirthVolumeID, 13, 4) & "-" & StringMid($GUID_BirthVolumeID, 17, 4) & "-" & StringMid($GUID_BirthVolumeID, 21, 12)
		$GUID_BirthObjectID = "NOT PRESENT"
		$GUID_BirthDomainID = "NOT PRESENT"
		Return
	EndIf
	If $OBJECTID_Size - 24 = 48 Then
		$GUID_BirthVolumeID = StringMid($MFTEntry, $OBJECTID_Offset + 80, 32)
		$GUID_BirthVolumeID = StringMid($GUID_BirthVolumeID, 1, 8) & "-" & StringMid($GUID_BirthVolumeID, 9, 4) & "-" & StringMid($GUID_BirthVolumeID, 13, 4) & "-" & StringMid($GUID_BirthVolumeID, 17, 4) & "-" & StringMid($GUID_BirthVolumeID, 21, 12)
		$GUID_BirthObjectID = StringMid($MFTEntry, $OBJECTID_Offset + 112, 32)
		$GUID_BirthObjectID = StringMid($GUID_BirthObjectID, 1, 8) & "-" & StringMid($GUID_BirthObjectID, 9, 4) & "-" & StringMid($GUID_BirthObjectID, 13, 4) & "-" & StringMid($GUID_BirthObjectID, 17, 4) & "-" & StringMid($GUID_BirthObjectID, 21, 12)
		$GUID_BirthDomainID = "NOT PRESENT"
		Return
	EndIf
	If $OBJECTID_Size - 24 = 64 Then
		$GUID_BirthVolumeID = StringMid($MFTEntry, $OBJECTID_Offset + 80, 32)
		$GUID_BirthVolumeID = StringMid($GUID_BirthVolumeID, 1, 8) & "-" & StringMid($GUID_BirthVolumeID, 9, 4) & "-" & StringMid($GUID_BirthVolumeID, 13, 4) & "-" & StringMid($GUID_BirthVolumeID, 17, 4) & "-" & StringMid($GUID_BirthVolumeID, 21, 12)
		$GUID_BirthObjectID = StringMid($MFTEntry, $OBJECTID_Offset + 112, 32)
		$GUID_BirthObjectID = StringMid($GUID_BirthObjectID, 1, 8) & "-" & StringMid($GUID_BirthObjectID, 9, 4) & "-" & StringMid($GUID_BirthObjectID, 13, 4) & "-" & StringMid($GUID_BirthObjectID, 17, 4) & "-" & StringMid($GUID_BirthObjectID, 21, 12)
		$GUID_BirthDomainID = StringMid($MFTEntry, $OBJECTID_Offset + 144, 32)
		$GUID_BirthDomainID = StringMid($GUID_BirthDomainID, 1, 8) & "-" & StringMid($GUID_BirthDomainID, 9, 4) & "-" & StringMid($GUID_BirthDomainID, 13, 4) & "-" & StringMid($GUID_BirthDomainID, 17, 4) & "-" & StringMid($GUID_BirthDomainID, 21, 12)
		Return
	EndIf
	$GUID_BirthVolumeID = "NOT PRESENT"
	$GUID_BirthObjectID = "NOT PRESENT"
	$GUID_BirthDomainID = "NOT PRESENT"
	Return
EndFunc   ;==>_Get_ObjectID

Func _Get_SecurityDescriptor()
;	ConsoleWrite("Get_SecurityDescriptor Function not implemented yet." & @CRLF)
	Return
EndFunc   ;==>_Get_SecurityDescriptor

Func _Get_VolumeName($MFTEntry, $VOLUME_NAME_Offset, $VOLUME_NAME_Size)
	If $VOLUME_NAME_Size - 24 > 0 Then
		$VOLUME_NAME_NAME = StringMid($MFTEntry, $VOLUME_NAME_Offset + 48, ($VOLUME_NAME_Size - 24) * 2)
		$VOLUME_NAME_NAME = _UnicodeHexToStr($VOLUME_NAME_NAME)
		Return
	EndIf
	$VOLUME_NAME_NAME = "EMPTY"
	Return
EndFunc   ;==>_Get_VolumeName

Func _Get_VolumeInformation($MFTEntry, $VOLUME_INFO_Offset, $VOLUME_INFO_Size)
	$VOL_INFO_NTFS_VERSION = Dec(StringMid($MFTEntry, $VOLUME_INFO_Offset + 64, 2)) & "," & Dec(StringMid($MFTEntry, $VOLUME_INFO_Offset + 66, 2))
	$VOL_INFO_FLAGS = StringMid($MFTEntry, $VOLUME_INFO_Offset + 68, 4)
	$VOL_INFO_FLAGS = StringMid($VOL_INFO_FLAGS, 3, 2) & StringMid($VOL_INFO_FLAGS, 1, 2)
	$VOL_INFO_FLAGS = _VolInfoFlag("0x" & $VOL_INFO_FLAGS)
	Return
EndFunc   ;==>_Get_VolumeInformation

Func _Get_Data($MFTEntry, $DATA_Offset, $DATA_Size, $DATA_Number)
	If $DATA_Number = 1 Then
		$DATA_NonResidentFlag = StringMid($MFTEntry, $DATA_Offset + 16, 2)
		$DATA_NameLength = Dec(StringMid($MFTEntry, $DATA_Offset + 18, 2))
		$DATA_NameRelativeOffset = StringMid($MFTEntry, $DATA_Offset + 20, 4)
		$DATA_NameRelativeOffset = Dec(StringMid($DATA_NameRelativeOffset, 3, 2) & StringMid($DATA_NameRelativeOffset, 1, 2))
		$DATA_Flags = StringMid($MFTEntry, $DATA_Offset + 24, 4)
		$DATA_Flags = StringMid($DATA_Flags, 3, 2) & StringMid($DATA_Flags, 1, 2)
		$DATA_Flags = _AttribHeaderFlags("0x" & $DATA_Flags)
		If $DATA_NameLength > 0 Then
			$DATA_NameSpace = $DATA_NameLength - 1
			$DATA_Name = StringMid($MFTEntry, $DATA_Offset + ($DATA_NameRelativeOffset * 2), ($DATA_NameLength + $DATA_NameSpace) * 2)
			$DATA_Name = _UnicodeHexToStr($DATA_Name)
		EndIf
		If $DATA_NonResidentFlag = '01' Then
			$DATA_StartVCN = StringMid($MFTEntry, $DATA_Offset + 32, 16)
			$DATA_StartVCN = _HexToDec(StringMid($DATA_StartVCN, 15, 2) & StringMid($DATA_StartVCN, 13, 2) & StringMid($DATA_StartVCN, 11, 2) & StringMid($DATA_StartVCN, 9, 2) & StringMid($DATA_StartVCN, 7, 2) & StringMid($DATA_StartVCN, 5, 2) & StringMid($DATA_StartVCN, 3, 2) & StringMid($DATA_StartVCN, 1, 2))
			$DATA_LastVCN = StringMid($MFTEntry, $DATA_Offset + 48, 16)
			$DATA_LastVCN = _HexToDec(StringMid($DATA_LastVCN, 15, 2) & StringMid($DATA_LastVCN, 13, 2) & StringMid($DATA_LastVCN, 11, 2) & StringMid($DATA_LastVCN, 9, 2) & StringMid($DATA_LastVCN, 7, 2) & StringMid($DATA_LastVCN, 5, 2) & StringMid($DATA_LastVCN, 3, 2) & StringMid($DATA_LastVCN, 1, 2))
			$DATA_VCNs = $DATA_LastVCN - $DATA_StartVCN
			$DATA_CompressionUnitSize = StringMid($MFTEntry, $DATA_Offset + 68, 4)
			$DATA_CompressionUnitSize = Dec(StringMid($DATA_CompressionUnitSize, 3, 2) & StringMid($DATA_CompressionUnitSize, 1, 2))
			$DATA_AllocatedSize = StringMid($MFTEntry, $DATA_Offset + 80, 16)
			$DATA_AllocatedSize = _HexToDec(StringMid($DATA_AllocatedSize, 15, 2) & StringMid($DATA_AllocatedSize, 13, 2) & StringMid($DATA_AllocatedSize, 11, 2) & StringMid($DATA_AllocatedSize, 9, 2) & StringMid($DATA_AllocatedSize, 7, 2) & StringMid($DATA_AllocatedSize, 5, 2) & StringMid($DATA_AllocatedSize, 3, 2) & StringMid($DATA_AllocatedSize, 1, 2))
			$DATA_RealSize = StringMid($MFTEntry, $DATA_Offset + 96, 16)
			$DATA_RealSize = _HexToDec(StringMid($DATA_RealSize, 15, 2) & StringMid($DATA_RealSize, 13, 2) & StringMid($DATA_RealSize, 11, 2) & StringMid($DATA_RealSize, 9, 2) & StringMid($DATA_RealSize, 7, 2) & StringMid($DATA_RealSize, 5, 2) & StringMid($DATA_RealSize, 3, 2) & StringMid($DATA_RealSize, 1, 2))
			$FileSizeBytes = $DATA_RealSize
			$DATA_InitializedStreamSize = StringMid($MFTEntry, $DATA_Offset + 112, 16)
			$DATA_InitializedStreamSize = _HexToDec(StringMid($DATA_InitializedStreamSize, 15, 2) & StringMid($DATA_InitializedStreamSize, 13, 2) & StringMid($DATA_InitializedStreamSize, 11, 2) & StringMid($DATA_InitializedStreamSize, 9, 2) & StringMid($DATA_InitializedStreamSize, 7, 2) & StringMid($DATA_InitializedStreamSize, 5, 2) & StringMid($DATA_InitializedStreamSize, 3, 2) & StringMid($DATA_InitializedStreamSize, 1, 2))
		ElseIf $DATA_NonResidentFlag = '00' Then
			$DATA_LengthOfAttribute = StringMid($MFTEntry, $DATA_Offset + 32, 8)
			$DATA_LengthOfAttribute = Dec(StringMid($DATA_LengthOfAttribute, 7, 2) & StringMid($DATA_LengthOfAttribute, 5, 2) & StringMid($DATA_LengthOfAttribute, 3, 2) & StringMid($DATA_LengthOfAttribute, 1, 2))
			$FileSizeBytes = $DATA_LengthOfAttribute
			$DATA_OffsetToAttribute = StringMid($MFTEntry, $DATA_Offset + 40, 4)
			$DATA_OffsetToAttribute = Dec(StringMid($DATA_OffsetToAttribute, 3, 2) & StringMid($DATA_OffsetToAttribute, 1, 2))
			$DATA_IndexedFlag = Dec(StringMid($MFTEntry, $DATA_Offset + 44, 2))
		EndIf
	EndIf
	If $DATA_Number = 2 Then
		$DATA_NonResidentFlag_2 = StringMid($MFTEntry, $DATA_Offset + 16, 2)
		$DATA_NameLength_2 = Dec(StringMid($MFTEntry, $DATA_Offset + 18, 2))
		$DATA_NameRelativeOffset_2 = StringMid($MFTEntry, $DATA_Offset + 20, 4)
		$DATA_NameRelativeOffset_2 = Dec(StringMid($DATA_NameRelativeOffset_2, 3, 2) & StringMid($DATA_NameRelativeOffset_2, 1, 2))
		$DATA_Flags_2 = StringMid($MFTEntry, $DATA_Offset + 24, 4)
		$DATA_Flags_2 = StringMid($DATA_Flags_2, 3, 2) & StringMid($DATA_Flags_2, 1, 2)
		$DATA_Flags_2 = _AttribHeaderFlags("0x" & $DATA_Flags_2)
		If $DATA_NameLength_2 > 0 Then
			$DATA_NameSpace_2 = $DATA_NameLength_2 - 1
			$DATA_Name_2 = StringMid($MFTEntry, $DATA_Offset + ($DATA_NameRelativeOffset_2 * 2), ($DATA_NameLength_2 + $DATA_NameSpace_2) * 2)
			$DATA_Name_2 = _UnicodeHexToStr($DATA_Name_2)
		EndIf
		If $DATA_NonResidentFlag_2 = '01' Then
			$DATA_StartVCN_2 = StringMid($MFTEntry, $DATA_Offset + 32, 16)
			$DATA_StartVCN_2 = StringMid($DATA_StartVCN_2, 15, 2) & StringMid($DATA_StartVCN_2, 13, 2) & StringMid($DATA_StartVCN_2, 11, 2) & StringMid($DATA_StartVCN_2, 9, 2) & StringMid($DATA_StartVCN_2, 7, 2) & StringMid($DATA_StartVCN_2, 5, 2) & StringMid($DATA_StartVCN_2, 3, 2) & StringMid($DATA_StartVCN_2, 1, 2)
			$DATA_StartVCN_2 = _HexToDec($DATA_StartVCN_2)
			$DATA_LastVCN_2 = StringMid($MFTEntry, $DATA_Offset + 48, 16)
			$DATA_LastVCN_2 = StringMid($DATA_LastVCN_2, 15, 2) & StringMid($DATA_LastVCN_2, 13, 2) & StringMid($DATA_LastVCN_2, 11, 2) & StringMid($DATA_LastVCN_2, 9, 2) & StringMid($DATA_LastVCN_2, 7, 2) & StringMid($DATA_LastVCN_2, 5, 2) & StringMid($DATA_LastVCN_2, 3, 2) & StringMid($DATA_LastVCN_2, 1, 2)
			$DATA_LastVCN_2 = _HexToDec($DATA_LastVCN_2)
			$DATA_VCNs_2 = $DATA_LastVCN_2 - $DATA_StartVCN_2
			$DATA_CompressionUnitSize_2 = StringMid($MFTEntry, $DATA_Offset + 68, 4)
			$DATA_CompressionUnitSize_2 = StringMid($DATA_CompressionUnitSize_2, 3, 2) & StringMid($DATA_CompressionUnitSize_2, 1, 2)
			$DATA_CompressionUnitSize_2 = Dec($DATA_CompressionUnitSize_2)
			$DATA_AllocatedSize_2 = StringMid($MFTEntry, $DATA_Offset + 80, 16)
			$DATA_AllocatedSize_2 = StringMid($DATA_AllocatedSize_2, 15, 2) & StringMid($DATA_AllocatedSize_2, 13, 2) & StringMid($DATA_AllocatedSize_2, 11, 2) & StringMid($DATA_AllocatedSize_2, 9, 2) & StringMid($DATA_AllocatedSize_2, 7, 2) & StringMid($DATA_AllocatedSize_2, 5, 2) & StringMid($DATA_AllocatedSize_2, 3, 2) & StringMid($DATA_AllocatedSize_2, 1, 2)
			$DATA_AllocatedSize_2 = _HexToDec($DATA_AllocatedSize_2)
			$DATA_RealSize_2 = StringMid($MFTEntry, $DATA_Offset + 96, 16)
			$DATA_RealSize_2 = StringMid($DATA_RealSize_2, 15, 2) & StringMid($DATA_RealSize_2, 13, 2) & StringMid($DATA_RealSize_2, 11, 2) & StringMid($DATA_RealSize_2, 9, 2) & StringMid($DATA_RealSize_2, 7, 2) & StringMid($DATA_RealSize_2, 5, 2) & StringMid($DATA_RealSize_2, 3, 2) & StringMid($DATA_RealSize_2, 1, 2)
			$DATA_RealSize_2 = _HexToDec($DATA_RealSize_2)
			$DATA_InitializedStreamSize_2 = StringMid($MFTEntry, $DATA_Offset + 112, 16)
			$DATA_InitializedStreamSize_2 = StringMid($DATA_InitializedStreamSize_2, 15, 2) & StringMid($DATA_InitializedStreamSize_2, 13, 2) & StringMid($DATA_InitializedStreamSize_2, 11, 2) & StringMid($DATA_InitializedStreamSize_2, 9, 2) & StringMid($DATA_InitializedStreamSize_2, 7, 2) & StringMid($DATA_InitializedStreamSize_2, 5, 2) & StringMid($DATA_InitializedStreamSize_2, 3, 2) & StringMid($DATA_InitializedStreamSize_2, 1, 2)
			$DATA_InitializedStreamSize_2 = _HexToDec($DATA_InitializedStreamSize_2)
		ElseIf $DATA_NonResidentFlag_2 = '00' Then
			$DATA_LengthOfAttribute_2 = StringMid($MFTEntry, $DATA_Offset + 32, 8)
			$DATA_LengthOfAttribute_2 = Dec(StringMid($DATA_LengthOfAttribute_2, 7, 2) & StringMid($DATA_LengthOfAttribute_2, 5, 2) & StringMid($DATA_LengthOfAttribute_2, 3, 2) & StringMid($DATA_LengthOfAttribute_2, 1, 2))
			$DATA_OffsetToAttribute_2 = StringMid($MFTEntry, $DATA_Offset + 40, 4)
			$DATA_OffsetToAttribute_2 = Dec(StringMid($DATA_OffsetToAttribute_2, 3, 2) & StringMid($DATA_OffsetToAttribute_2, 1, 2))
			$DATA_IndexedFlag_2 = Dec(StringMid($MFTEntry, $DATA_Offset + 44, 2))
		EndIf
	EndIf
	If $DATA_Number = 3 Then
		$DATA_NonResidentFlag_3 = StringMid($MFTEntry, $DATA_Offset + 16, 2)
		$DATA_NameLength_3 = Dec(StringMid($MFTEntry, $DATA_Offset + 18, 2))
		$DATA_NameRelativeOffset_3 = StringMid($MFTEntry, $DATA_Offset + 20, 4)
		$DATA_NameRelativeOffset_3 = Dec(StringMid($DATA_NameRelativeOffset_3, 3, 2) & StringMid($DATA_NameRelativeOffset_3, 1, 2))
		$DATA_Flags_3 = StringMid($MFTEntry, $DATA_Offset + 24, 4)
		$DATA_Flags_3 = StringMid($DATA_Flags_3, 3, 2) & StringMid($DATA_Flags_3, 1, 2)
		$DATA_Flags_3 = _AttribHeaderFlags("0x" & $DATA_Flags_3)
		If $DATA_NameLength_3 > 0 Then
			$DATA_NameSpace_3 = $DATA_NameLength_3 - 1
			$DATA_Name_3 = StringMid($MFTEntry, $DATA_Offset + ($DATA_NameRelativeOffset_3 * 2), ($DATA_NameLength_3 + $DATA_NameSpace_3) * 2)
			$DATA_Name_3 = _UnicodeHexToStr($DATA_Name_3)
		EndIf
		If $DATA_NonResidentFlag_3 = '01' Then
			$DATA_StartVCN_3 = StringMid($MFTEntry, $DATA_Offset + 32, 16)
			$DATA_StartVCN_3 = StringMid($DATA_StartVCN_3, 15, 2) & StringMid($DATA_StartVCN_3, 13, 2) & StringMid($DATA_StartVCN_3, 11, 2) & StringMid($DATA_StartVCN_3, 9, 2) & StringMid($DATA_StartVCN_3, 7, 2) & StringMid($DATA_StartVCN_3, 5, 2) & StringMid($DATA_StartVCN_3, 3, 2) & StringMid($DATA_StartVCN_3, 1, 2)
			$DATA_StartVCN_3 = _HexToDec($DATA_StartVCN_3)
			$DATA_LastVCN_3 = StringMid($MFTEntry, $DATA_Offset + 48, 16)
			$DATA_LastVCN_3 = StringMid($DATA_LastVCN_3, 15, 2) & StringMid($DATA_LastVCN_3, 13, 2) & StringMid($DATA_LastVCN_3, 11, 2) & StringMid($DATA_LastVCN_3, 9, 2) & StringMid($DATA_LastVCN_3, 7, 2) & StringMid($DATA_LastVCN_3, 5, 2) & StringMid($DATA_LastVCN_3, 3, 2) & StringMid($DATA_LastVCN_3, 1, 2)
			$DATA_LastVCN_3 = _HexToDec($DATA_LastVCN_3)
			$DATA_VCNs_3 = $DATA_LastVCN_3 - $DATA_StartVCN_3
			$DATA_CompressionUnitSize_3 = StringMid($MFTEntry, $DATA_Offset + 68, 4)
			$DATA_CompressionUnitSize_3 = StringMid($DATA_CompressionUnitSize_3, 3, 2) & StringMid($DATA_CompressionUnitSize_3, 1, 2)
			$DATA_CompressionUnitSize_3 = Dec($DATA_CompressionUnitSize_3)
			$DATA_AllocatedSize_3 = StringMid($MFTEntry, $DATA_Offset + 80, 16)
			$DATA_AllocatedSize_3 = StringMid($DATA_AllocatedSize_3, 15, 2) & StringMid($DATA_AllocatedSize_3, 13, 2) & StringMid($DATA_AllocatedSize_3, 11, 2) & StringMid($DATA_AllocatedSize_3, 9, 2) & StringMid($DATA_AllocatedSize_3, 7, 2) & StringMid($DATA_AllocatedSize_3, 5, 2) & StringMid($DATA_AllocatedSize_3, 3, 2) & StringMid($DATA_AllocatedSize_3, 1, 2)
			$DATA_AllocatedSize_3 = _HexToDec($DATA_AllocatedSize_3)
			$DATA_RealSize_3 = StringMid($MFTEntry, $DATA_Offset + 96, 16)
			$DATA_RealSize_3 = StringMid($DATA_RealSize_3, 15, 2) & StringMid($DATA_RealSize_3, 13, 2) & StringMid($DATA_RealSize_3, 11, 2) & StringMid($DATA_RealSize_3, 9, 2) & StringMid($DATA_RealSize_3, 7, 2) & StringMid($DATA_RealSize_3, 5, 2) & StringMid($DATA_RealSize_3, 3, 2) & StringMid($DATA_RealSize_3, 1, 2)
			$DATA_RealSize_3 = _HexToDec($DATA_RealSize_3)
			$DATA_InitializedStreamSize_3 = StringMid($MFTEntry, $DATA_Offset + 112, 16)
			$DATA_InitializedStreamSize_3 = StringMid($DATA_InitializedStreamSize_3, 15, 2) & StringMid($DATA_InitializedStreamSize_3, 13, 2) & StringMid($DATA_InitializedStreamSize_3, 11, 2) & StringMid($DATA_InitializedStreamSize_3, 9, 2) & StringMid($DATA_InitializedStreamSize_3, 7, 2) & StringMid($DATA_InitializedStreamSize_3, 5, 2) & StringMid($DATA_InitializedStreamSize_3, 3, 2) & StringMid($DATA_InitializedStreamSize_3, 1, 2)
			$DATA_InitializedStreamSize_3 = _HexToDec($DATA_InitializedStreamSize_3)
		ElseIf $DATA_NonResidentFlag_3 = '00' Then
			$DATA_LengthOfAttribute_3 = StringMid($MFTEntry, $DATA_Offset + 32, 8)
			$DATA_LengthOfAttribute_3 = Dec(StringMid($DATA_LengthOfAttribute_3, 7, 2) & StringMid($DATA_LengthOfAttribute_3, 5, 2) & StringMid($DATA_LengthOfAttribute_3, 3, 2) & StringMid($DATA_LengthOfAttribute_3, 1, 2))
			$DATA_OffsetToAttribute_3 = StringMid($MFTEntry, $DATA_Offset + 40, 4)
			$DATA_OffsetToAttribute_3 = Dec(StringMid($DATA_OffsetToAttribute_3, 3, 2) & StringMid($DATA_OffsetToAttribute_3, 1, 2))
			$DATA_IndexedFlag_3 = Dec(StringMid($MFTEntry, $DATA_Offset + 44, 2))
		EndIf
	EndIf
EndFunc   ;==>_Get_Data

Func _Get_IndexRoot()
;	ConsoleWrite("Get_IndexRoot Function not implemented yet." & @CRLF)
	Return
EndFunc   ;==>_Get_IndexRoot

Func _Get_IndexAllocation()
;	ConsoleWrite("Get_IndexAllocation Function not implemented yet." & @CRLF)
	Return
EndFunc   ;==>_Get_IndexAllocation

Func _Get_Bitmap()
;	ConsoleWrite("Get_Bitmap Function not implemented yet." & @CRLF)
	Return
EndFunc   ;==>_Get_Bitmap

Func _Get_ReparsePoint()
;	ConsoleWrite("Get_ReparsePoint Function not implemented yet." & @CRLF)
	Return
EndFunc   ;==>_Get_ReparsePoint

Func _Get_EaInformation()
;	ConsoleWrite("Get_EaInformation Function not implemented yet." & @CRLF)
	Return
EndFunc   ;==>_Get_EaInformation

Func _Get_Ea()
;	ConsoleWrite("Get_Ea Function not implemented yet." & @CRLF)
	Return
EndFunc   ;==>_Get_Ea

Func _Get_PropertySet()
;	ConsoleWrite("Get_PropertySet Function not implemented yet." & @CRLF)
	Return
EndFunc   ;==>_Get_PropertySet

Func _Get_LoggedUtilityStream()
;	ConsoleWrite("Get_LoggedUtilityStream Function not implemented yet." & @CRLF)
	Return
EndFunc   ;==>_Get_LoggedUtilityStream

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
	$Header_HardLinkCount = ""
	$HEADER_BaseRecSeqNo = ""
	$RecordActive = ""
	$HEADER_Flags = ""
	$HEADER_LSN = ""
	$HEADER_SequenceNo = ""
	$HEADER_RecordRealSize = ""
	$HEADER_RecordAllocSize = ""
	$HEADER_BaseRecord = ""
	$HEADER_NextAttribID = ""
	$HEADER_MFTREcordNumber = ""
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
	$FPoutput = StringTrimRight($FPoutput, 1)
	Return $FPoutput
EndFunc   ;==>_File_Permissions

Func _AttribHeaderFlags($AHinput)
	Local $AHoutput = ""
	If BitAND($AHinput, 0x0001) Then $AHoutput &= 'COMPRESSED+'
	If BitAND($AHinput, 0x4000) Then $AHoutput &= 'ENCRYPTED+'
	If BitAND($AHinput, 0x8000) Then $AHoutput &= 'SPARSE+'
	$AHoutput = StringTrimRight($AHoutput, 1)
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
	$FRFoutput = StringTrimRight($FRFoutput, 1)
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
	$VIFoutput = StringTrimRight($VIFoutput, 1)
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
	FileWriteLine($csv, '"' & $RecordOffset & '","' & $Signature & '","' & $IntegrityCheck & '","' & $HEADER_MFTREcordNumber & '","' & $HEADER_SequenceNo & '","' & $Header_HardLinkCount & '","' & $FN_ParentReferenceNo & '","' & $FN_ParentSequenceNo & '","' & $FN_FileName & '","' & $FN_FileNamePath & '","' & $HEADER_Flags & '","' & $RecordActive & '","' & $FileSizeBytes & '","' & $INVALID_FILENAME & '","' & $SI_FilePermission & '","' & $FN_Flags & '","' & $FN_NameType & '","' & $Alternate_Data_Stream & '","' & $SI_CTime & '","' & $SI_ATime & '","' & $SI_MTime & '","' & $SI_RTime & '","' & _
			$MSecTest & '","' & $FN_CTime & '","' & $FN_ATime & '","' & $FN_MTime & '","' & $FN_RTime & '","' & $CTimeTest & '","' & $FN_AllocSize & '","' & $FN_RealSize & '","' & $SI_USN & '","' & $DATA_Name & '","' & $DATA_Flags & '","' & $DATA_LengthOfAttribute & '","' & $DATA_IndexedFlag & '","' & $DATA_VCNs & '","' & $DATA_NonResidentFlag & '","' & $DATA_CompressionUnitSize & '","' & $HEADER_LSN & '","' & _
			$HEADER_RecordRealSize & '","' & $HEADER_RecordAllocSize & '","' & $HEADER_BaseRecord & '","' & $HEADER_BaseRecSeqNo & '","' & $HEADER_NextAttribID & '","' & $DATA_AllocatedSize & '","' & $DATA_RealSize & '","' & $DATA_InitializedStreamSize & '","' & $SI_HEADER_Flags & '","' & $SI_MaxVersions & '","' & $SI_VersionNumber & '","' & $SI_ClassID & '","' & $SI_OwnerID & '","' & $SI_SecurityID & '","' & $FN_CTime_2 & '","' & $FN_ATime_2 & '","' & _
			$FN_MTime_2 & '","' & $FN_RTime_2 & '","' & $FN_AllocSize_2 & '","' & $FN_RealSize_2 & '","' & $FN_Flags_2 & '","' & $FN_NameLength_2 & '","' & $FN_NameType_2 & '","' & $FN_FileName_2 & '","' & $INVALID_FILENAME_2 & '","' & $GUID_ObjectID & '","' & $GUID_BirthVolumeID & '","' & $GUID_BirthObjectID & '","' & $GUID_BirthDomainID & '","' & $VOLUME_NAME_NAME & '","' & $VOL_INFO_NTFS_VERSION & '","' & $VOL_INFO_FLAGS & '","' & $FN_CTime_3 & '","' & $FN_ATime_3 & '","' & $FN_MTime_3 & '","' & $FN_RTime_3 & '","' & $FN_AllocSize_3 & '","' & $FN_RealSize_3 & '","' & $FN_Flags_3 & '","' & $FN_NameLength_3 & '","' & $FN_NameType_3 & '","' & $FN_FileName_3 & '","' & $INVALID_FILENAME_3 & '","' & _
			$FN_CTime_4 & '","' & $FN_ATime_4 & '","' & $FN_MTime_4 & '","' & $FN_RTime_4 & '","' & $FN_AllocSize_4 & '","' & $FN_RealSize_4 & '","' & $FN_Flags_4 & '","' & $FN_NameLength_4 & '","' & $FN_NameType_4 & '","' & $FN_FileName_4 & '","' & $DATA_Name_2 & '","' & $DATA_NonResidentFlag_2 & '","' & $DATA_Flags_2 & '","' & $DATA_LengthOfAttribute_2 & '","' & $DATA_IndexedFlag_2 & '","' & $DATA_StartVCN_2 & '","' & $DATA_LastVCN_2 & '","' & _
			$DATA_VCNs_2 & '","' & $DATA_CompressionUnitSize_2 & '","' & $DATA_AllocatedSize_2 & '","' & $DATA_RealSize_2 & '","' & $DATA_InitializedStreamSize_2 & '","' & $DATA_Name_3 & '","' & $DATA_NonResidentFlag_3 & '","' & $DATA_Flags_3 & '","' & $DATA_LengthOfAttribute_3 & '","' & $DATA_IndexedFlag_3 & '","' & $DATA_StartVCN_3 & '","' & $DATA_LastVCN_3 & '","' & $DATA_VCNs_3 & '","' & $DATA_CompressionUnitSize_3 & '","' & $DATA_AllocatedSize_3 & '","' & _
			$DATA_RealSize_3 & '","' & $DATA_InitializedStreamSize_3 & '","' & $STANDARD_INFORMATION_ON & '","' & $ATTRIBUTE_LIST_ON & '","' & $FILE_NAME_ON & '","' & $OBJECT_ID_ON & '","' & $SECURITY_DESCRIPTOR_ON & '","' & $VOLUME_NAME_ON & '","' & $VOLUME_INFORMATION_ON & '","' & $DATA_ON & '","' & $INDEX_ROOT_ON & '","' & $INDEX_ALLOCATION_ON & '","' & $BITMAP_ON & '","' & $REPARSE_POINT_ON & '","' & $EA_INFORMATION_ON & '","' & $EA_ON & '","' & $PROPERTY_SET_ON & '","' & $LOGGED_UTILITY_STREAM_ON & '"' & @CRLF)
EndFunc

Func _SelectCsv()
$csvfile = FileSaveDialog("Choose a csv name.", @ScriptDir, "All (*.csv)", 2, "MFTdump.csv")
If @error Then Return
$csv = FileOpen($csvfile, 2)
If @error Then Return
_DisplayInfo("Output CSV file: " & $csvfile & @CRLF)
EndFunc

Func _WriteCSVHeader()
FileWriteLine($csv, "#	Timestamps presented in UTC " & $UTCconfig & @CRLF)
$csv_header = 'RecordOffset,Signature,IntegrityCheck,HEADER_MFTREcordNumber,HEADER_SequenceNo,Header_HardLinkCount,FN_ParentReferenceNo,FN_ParentSequenceNo,FN_FileName,FilePath,HEADER_Flags,RecordActive,FileSizeBytes,INVALID_FILENAME,SI_FilePermission,FN_Flags,FN_NameType,ADS,SI_CTime,SI_ATime,SI_MTime,SI_RTime,MSecTest,'
$csv_header &= 'FN_CTime,FN_ATime,FN_MTime,FN_RTime,CTimeTest,FN_AllocSize,FN_RealSize,SI_USN,DATA_Name,DATA_Flags,DATA_LengthOfAttribute,DATA_IndexedFlag,DATA_VCNs,DATA_NonResidentFlag,DATA_CompressionUnitSize,HEADER_LSN,HEADER_RecordRealSize,'
$csv_header &= 'HEADER_RecordAllocSize,HEADER_BaseRecord,HEADER_BaseRecSeqNo,HEADER_NextAttribID,DATA_AllocatedSize,DATA_RealSize,DATA_InitializedStreamSize,SI_HEADER_Flags,SI_MaxVersions,SI_VersionNumber,SI_ClassID,SI_OwnerID,SI_SecurityID,FN_CTime_2,FN_ATime_2,FN_MTime_2,'
$csv_header &= 'FN_RTime_2,FN_AllocSize_2,FN_RealSize_2,FN_Flags_2,FN_NameLength_2,FN_NameType_2,FN_FileName_2,INVALID_FILENAME_2,GUID_ObjectID,GUID_BirthVolumeID,GUID_BirthObjectID,GUID_BirthDomainID,VOLUME_NAME_NAME,VOL_INFO_NTFS_VERSION,VOL_INFO_FLAGS,FN_CTime_3,FN_ATime_3,FN_MTime_3,FN_RTime_3,FN_AllocSize_3,FN_RealSize_3,FN_Flags_3,FN_NameLength_3,FN_NameType_3,FN_FileName_3,INVALID_FILENAME_3,FN_CTime_4,'
$csv_header &= 'FN_ATime_4,FN_MTime_4,FN_RTime_4,FN_AllocSize_4,FN_RealSize_4,FN_Flags_4,FN_NameLength_4,FN_NameType_4,FN_FileName_4,DATA_Name_2,DATA_NonResidentFlag_2,DATA_Flags_2,DATA_LengthOfAttribute_2,DATA_IndexedFlag_2,DATA_StartVCN_2,DATA_LastVCN_2,'
$csv_header &= 'DATA_VCNs_2,DATA_CompressionUnitSize_2,DATA_AllocatedSize_2,DATA_RealSize_2,DATA_InitializedStreamSize_2,DATA_Name_3,DATA_NonResidentFlag_3,DATA_Flags_3,DATA_LengthOfAttribute_3,DATA_IndexedFlag_3,DATA_StartVCN_3,DATA_LastVCN_3,DATA_VCNs_3,'
$csv_header &= 'DATA_CompressionUnitSize_3,DATA_AllocatedSize_3,DATA_RealSize_3,DATA_InitializedStreamSize_3,STANDARD_INFORMATION_ON,ATTRIBUTE_LIST_ON,FILE_NAME_ON,OBJECT_ID_ON,SECURITY_DESCRIPTOR_ON,VOLUME_NAME_ON,VOLUME_INFORMATION_ON,DATA_ON,INDEX_ROOT_ON,INDEX_ALLOCATION_ON,BITMAP_ON,REPARSE_POINT_ON,EA_INFORMATION_ON,EA_ON,PROPERTY_SET_ON,LOGGED_UTILITY_STREAM_ON'
FileWriteLine($csv, $csv_header & @CRLF)
EndFunc

Func _InjectTimeZoneInfo()
$Regions = "UTC: -12.00|" & _
	"UTC: -11.00|" & _
	"UTC: -10.00|" & _
	"UTC: -9.30|" & _
	"UTC: -9.00|" & _
	"UTC: -8.00|" & _
	"UTC: -7.00|" & _
	"UTC: -6.00|" & _
	"UTC: -5.00|" & _
	"UTC: -4.30|" & _
	"UTC: -4.00|" & _
	"UTC: -3.30|" & _
	"UTC: -3.00|" & _
	"UTC: -2.00|" & _
	"UTC: -1.00|" & _
	"UTC: 0.00|" & _
	"UTC: 1.00|" & _
	"UTC: 2.00|" & _
	"UTC: 3.00|" & _
	"UTC: 3.30|" & _
	"UTC: 4.00|" & _
	"UTC: 4.30|" & _
	"UTC: 5.00|" & _
	"UTC: 5.30|" & _
	"UTC: 5.45|" & _
	"UTC: 6.00|" & _
	"UTC: 6.30|" & _
	"UTC: 7.00|" & _
	"UTC: 8.00|" & _
	"UTC: 8.45|" & _
	"UTC: 9.00|" & _
	"UTC: 9.30|" & _
	"UTC: 10.00|" & _
	"UTC: 10.30|" & _
	"UTC: 11.00|" & _
	"UTC: 11.30|" & _
	"UTC: 12.00|" & _
	"UTC: 12.45|" & _
	"UTC: 13.00|" & _
	"UTC: 14.00|"
GUICtrlSetData($Combo2,$Regions,"UTC: 0.00")
EndFunc

Func _GetUTCRegion()
	$UTCRegion = GUICtrlRead($Combo2)
	If $UTCRegion = "" Then Return SetError(1,0,0)
	$part1 = StringMid($UTCRegion,StringInStr($UTCRegion," ")+1)
	Global $UTCconfig = $part1
	If StringRight($part1,2) = "15" Then $part1 = StringReplace($part1,".15",".25")
	If StringRight($part1,2) = "30" Then $part1 = StringReplace($part1,".30",".50")
	If StringRight($part1,2) = "45" Then $part1 = StringReplace($part1,".45",".75")
	$DeltaTest = $part1*36000000000
	Return $DeltaTest
EndFunc

; start: by Ascend4nt -----------------------------
Func _WinTime_GetUTCToLocalFileTimeDelta()
	Local $iUTCFileTime=864000000000		; exactly 24 hours from the origin (although 12 hours would be more appropriate (max variance = 12))
	$iLocalFileTime=_WinTime_UTCFileTimeToLocalFileTime($iUTCFileTime)
	If @error Then Return SetError(@error,@extended,-1)
	Return $iLocalFileTime-$iUTCFileTime	; /36000000000 = # hours delta (effectively giving the offset in hours from UTC/GMT)
EndFunc

Func _WinTime_UTCFileTimeToLocalFileTime($iUTCFileTime)
	If $iUTCFileTime<0 Then Return SetError(1,0,-1)
	Local $aRet=DllCall($_COMMON_KERNEL32DLL,"bool","FileTimeToLocalFileTime","uint64*",$iUTCFileTime,"uint64*",0)
	If @error Then Return SetError(2,@error,-1)
	If Not $aRet[0] Then Return SetError(3,0,-1)
	Return $aRet[2]
EndFunc

Func _WinTime_UTCFileTimeFormat($iUTCFileTime,$iFormat=4,$iPrecision=0,$bAMPMConversion=False)
;~ 	If $iUTCFileTime<0 Then Return SetError(1,0,"")	; checked in below call

	; First convert file time (UTC-based file time) to 'local file time'
	Local $iLocalFileTime=_WinTime_UTCFileTimeToLocalFileTime($iUTCFileTime)
	If @error Then Return SetError(@error,@extended,"")
	; Rare occassion: a filetime near the origin (January 1, 1601!!) is used,
	;	causing a negative result (for some timezones). Return as invalid param.
	If $iLocalFileTime<0 Then Return SetError(1,0,"")

	; Then convert file time to a system time array & format & return it
	Local $vReturn=_WinTime_LocalFileTimeFormat($iLocalFileTime,$iFormat,$iPrecision,$bAMPMConversion)
	Return SetError(@error,@extended,$vReturn)
EndFunc

Func _WinTime_LocalFileTimeFormat($iLocalFileTime,$iFormat=4,$iPrecision=0,$bAMPMConversion=False)
;~ 	If $iLocalFileTime<0 Then Return SetError(1,0,"")	; checked in below call

	; Convert file time to a system time array & return result
	Local $aSysTime=_WinTime_LocalFileTimeToSystemTime($iLocalFileTime)
	If @error Then Return SetError(@error,@extended,"")

	; Return only the SystemTime array?
	If $iFormat=0 Then Return $aSysTime

	Local $vReturn=_WinTime_FormatTime($aSysTime[0],$aSysTime[1],$aSysTime[2],$aSysTime[3], _
		$aSysTime[4],$aSysTime[5],$aSysTime[6],$aSysTime[7],$iFormat,$iPrecision,$bAMPMConversion)
	Return SetError(@error,@extended,$vReturn)
EndFunc

Func _WinTime_LocalFileTimeToSystemTime($iLocalFileTime)
	Local $aRet,$stSysTime,$aSysTime[8]=[-1,-1,-1,-1,-1,-1,-1,-1]

	; Negative values unacceptable
	If $iLocalFileTime<0 Then Return SetError(1,0,$aSysTime)

	; SYSTEMTIME structure [Year,Month,DayOfWeek,Day,Hour,Min,Sec,Milliseconds]
	$stSysTime=DllStructCreate("ushort[8]")

	$aRet=DllCall($_COMMON_KERNEL32DLL,"bool","FileTimeToSystemTime","uint64*",$iLocalFileTime,"ptr",DllStructGetPtr($stSysTime))
	If @error Then Return SetError(2,@error,$aSysTime)
	If Not $aRet[0] Then Return SetError(3,0,$aSysTime)
	Dim $aSysTime[8]=[DllStructGetData($stSysTime,1,1),DllStructGetData($stSysTime,1,2),DllStructGetData($stSysTime,1,4),DllStructGetData($stSysTime,1,5), _
		DllStructGetData($stSysTime,1,6),DllStructGetData($stSysTime,1,7),DllStructGetData($stSysTime,1,8),DllStructGetData($stSysTime,1,3)]
	Return $aSysTime
EndFunc

Func _WinTime_FormatTime($iYear,$iMonth,$iDay,$iHour,$iMin,$iSec,$iMilSec,$iDayOfWeek,$iFormat=4,$iPrecision=0,$bAMPMConversion=False)
	Local Static $_WT_aMonths[12]=["January","February","March","April","May","June","July","August","September","October","November","December"]
	Local Static $_WT_aDays[7]=["Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday"]

	If Not $iFormat Or $iMonth<1 Or $iMonth>12 Or $iDayOfWeek>6 Then Return SetError(1,0,"")

	; Pad MM,DD,HH,MM,SS,MSMSMSMS as necessary
	Local $sMM=StringRight(0&$iMonth,2),$sDD=StringRight(0&$iDay,2),$sMin=StringRight(0&$iMin,2)
	; $sYY = $iYear	; (no padding)
	;	[technically Year can be 1-x chars - but this is generally used for 4-digit years. And SystemTime only goes up to 30827/30828]
	Local $sHH,$sSS,$sMS,$sAMPM

	; 'Extra precision 1': +SS (Seconds)
	If $iPrecision Then
		$sSS=StringRight(0&$iSec,2)
		; 'Extra precision 2': +MSMSMSMS (Milliseconds)
		If $iPrecision>1 Then
;			$sMS=StringRight('000'&$iMilSec,4)
			$sMS=StringRight('000'&$iMilSec,3);Fixed an erronous 0 in front of the milliseconds
		Else
			$sMS=""
		EndIf
	Else
		$sSS=""
		$sMS=""
	EndIf
	If $bAMPMConversion Then
		If $iHour>11 Then
			$sAMPM=" PM"
			; 12 PM will cause 12-12 to equal 0, so avoid the calculation:
			If $iHour=12 Then
				$sHH="12"
			Else
				$sHH=StringRight(0&($iHour-12),2)
			EndIf
		Else
			$sAMPM=" AM"
			If $iHour Then
				$sHH=StringRight(0&$iHour,2)
			Else
			; 00 military = 12 AM
				$sHH="12"
			EndIf
		EndIf
	Else
		$sAMPM=""
		$sHH=StringRight(0 & $iHour,2)
	EndIf

	Local $sDateTimeStr,$aReturnArray[3]

	; Return an array? [formatted string + "Month" + "DayOfWeek"]
	If BitAND($iFormat,0x10) Then
		$aReturnArray[1]=$_WT_aMonths[$iMonth-1]
		If $iDayOfWeek>=0 Then
			$aReturnArray[2]=$_WT_aDays[$iDayOfWeek]
		Else
			$aReturnArray[2]=""
		EndIf
		; Strip the 'array' bit off (array[1] will now indicate if an array is to be returned)
		$iFormat=BitAND($iFormat,0xF)
	Else
		; Signal to below that the array isn't to be returned
		$aReturnArray[1]=""
	EndIf

	; Prefix with "DayOfWeek "?
	If BitAND($iFormat,8) Then
		If $iDayOfWeek<0 Then Return SetError(1,0,"")	; invalid
		$sDateTimeStr=$_WT_aDays[$iDayOfWeek]&', '
		; Strip the 'DayOfWeek' bit off
		$iFormat=BitAND($iFormat,0x7)
	Else
		$sDateTimeStr=""
	EndIf

	If $iFormat<2 Then
		; Basic String format: YYYYMMDDHHMM[SS[MSMSMSMS[ AM/PM]]]
		$sDateTimeStr&=$iYear&$sMM&$sDD&$sHH&$sMin&$sSS&$sMS&$sAMPM
	Else
		; one of 4 formats which ends with " HH:MM[:SS[:MSMSMSMS[ AM/PM]]]"
		Switch $iFormat
			; /, : Format - MM/DD/YYYY
			Case 2
				$sDateTimeStr&=$sMM&'/'&$sDD&'/'
			; /, : alt. Format - DD/MM/YYYY
			Case 3
				$sDateTimeStr&=$sDD&'/'&$sMM&'/'
			; "Month DD, YYYY" format
			Case 4
				$sDateTimeStr&=$_WT_aMonths[$iMonth-1]&' '&$sDD&', '
			; "DD Month YYYY" format
			Case 5
				$sDateTimeStr&=$sDD&' '&$_WT_aMonths[$iMonth-1]&' '
			Case 6
				$sDateTimeStr&=$iYear&'-'&$sMM&'-'&$sDD
				$iYear=''
			Case Else
				Return SetError(1,0,"")
		EndSwitch
		$sDateTimeStr&=$iYear&' '&$sHH&':'&$sMin
		If $iPrecision Then
			$sDateTimeStr&=':'&$sSS
			If $iPrecision>1 Then $sDateTimeStr&=':'&$sMS
		EndIf
		$sDateTimeStr&=$sAMPM
	EndIf
	If $aReturnArray[1]<>"" Then
		$aReturnArray[0]=$sDateTimeStr
		Return $aReturnArray
	EndIf
	Return $sDateTimeStr
EndFunc
; end: by Ascend4nt ----------------------------