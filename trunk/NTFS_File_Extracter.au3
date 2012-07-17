#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Res_Description=Extract files from NTFS volumes
#AutoIt3Wrapper_Res_Fileversion=3.0.0.1
#AutoIt3Wrapper_Res_requestedExecutionLevel=asInvoker
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
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
Global $BrowsedFile,$TargetDrive = ""
Global $SectorsPerCluster,$MFT_Record_Size,$BytesPerCluster,$BytesPerSector,$MFT_Offset
Global $HEADER_LSN,$HEADER_SequenceNo,$HEADER_Flags,$HEADER_RecordRealSize,$HEADER_RecordAllocSize,$HEADER_FileRef
Global $HEADER_NextAttribID,$HEADER_MFTREcordNumber
Global $FN_CTime,$FN_ATime,$FN_MTime,$FN_RTime,$FN_AllocSize,$FN_RealSize,$FN_Flags,$FN_FileName,$FN_NameType
Global $DATA_NonResidentFlag,$DATA_NameLength,$DATA_NameRelativeOffset,$DATA_Flags,$DATA_Name,$RecordActive
Global $DATA_CompressionUnitSize,$DATA_ON,$DATA_CompressedSize,$DATA_LengthOfAttribute,$DATA_StartVCN,$DATA_LastVCN
Global $DATA_AllocatedSize,$DATA_RealSize,$DATA_InitializedStreamSize,$RunListOffset,$DataRun,$IsCompressed
Global $RUN_VCN[1],$RUN_Clusters[1],$MFT_RUN_Clusters[1],$MFT_RUN_VCN[1],$NameQ[5],$DataQ[1],$sBuffer,$AttrQ[1]
Global $SI_CTime,$SI_ATime,$SI_MTime,$SI_RTime,$SI_FilePermission,$SI_USN,$Errors,$RecordSlackSpace
Global $MFTSize;, $MFTRecordsArr[1][1]
Global $MFTRecordsArr1[65530][2],$MFTRecordsArr2[65530][2],$MFTRecordsArr3[65530][2],$MFTRecordsArr4[65530][2],$MFTRecordsArr5[65530][2],$MFTRecordsArr6[65530][2],$MFTRecordsArr7[65530][2],$MFTRecordsArr8[65530][2],$MFTRecordsArr9[65530][2],$MFTRecordsArr10[65530][2],$MFTRecordsArr11[65530][2],$MFTRecordsArr12[65530][2],$MFTRecordsArr13[65530][2],$MFTRecordsArr14[65530][2],$MFTRecordsArr15[65530][2],$MFTRecordsArr16[65530][2],$MFTRecordsArr17[65530][2],$MFTRecordsArr18[65530][2],$MFTRecordsArr19[65530][2],$MFTRecordsArr20[65530][2]
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
Global $outputpath = FileSelectFolder("Select output folder.", "",7,@scriptdir)
If @error Then Exit
$Form = GUICreate("NTFS File Extracter 3.1 - http://code.google.com/p/mft2csv/", 520, 250, -1, -1)
$Combo1 = GUICtrlCreateCombo("", 20, 20, 400, 25)
$ButtonRefresh = GUICtrlCreateButton("Refresh", 440, 20, 60, 20)
$ButtonGetMFT = GUICtrlCreateButton("Extract $MFT", 20, 50, 100, 20)
$ButtonGetAll = GUICtrlCreateButton("Extract All systemfiles", 130, 50, 120, 20)
$ButtonBrowse = GUICtrlCreateButton("Browse for file", 260, 50, 120, 20)
$ButtonOutput = GUICtrlCreateButton("Change output", 440, 50, 60, 40, 0x2000)
$LabelMFTnumber = GUICtrlCreateLabel("Set MFT record number:",20,90,120,20)
$InputMFTnumber = GUICtrlCreateInput("0",150,90,100,20)
$ButtonMFTnumber = GUICtrlCreateButton("Extract Record numbers $DATA", 270, 90, 170, 20)
$myctredit = GUICtrlCreateEdit("Extracting files from NTFS formatted volumes.." & @CRLF, 0, 125, 520, 125, $ES_AUTOVSCROLL + $WS_VSCROLL)
_GUICtrlEdit_SetLimitText($myctredit, 128000)
_DisplayInfo(@CRLF & "Selected output folder: " & $outputpath & @CRLF)
_GetPhysicalDrives()
_GetVolumes()
GUISetState(@SW_SHOW)

While 1		;jobloop
$nMsg = GUIGetMsg()
Select
	Case $nMsg = $ButtonRefresh
		 _GetPhysicalDrives()
		 _GetVolumes()
	Case $nMsg = $ButtonGetMFT
		 _ExtractSystemfile("$MFT")
	Case $nMsg = $ButtonGetAll
		 _ExtractSystemfile("ALL")
	Case $nMsg = $ButtonMFTnumber
		 _ExtractSystemfile(GUICtrlRead($InputMFTnumber))
	Case $nMsg = $ButtonBrowse
		 $BrowsedFile = _BrowseTargetFile()
		 $bIndexNumber = _GetIndexNumber($BrowsedFile)
		 If @error Then
			_DisplayInfo("Error: Something went wrong when retrieving the IndexNumber of file." & @CRLF)
		 Else
			_ExtractSystemfile($bIndexNumber)
		EndIf
	Case $nMsg = $ButtonOutput
		$outputpath = FileSelectFolder("Select output folder.", "",7,@scriptdir)
		_DisplayInfo(@CRLF & "New output folder: " & $outputpath & @CRLF)
	Case $nMsg = $GUI_EVENT_CLOSE
		 Exit
EndSelect
WEnd

Func _ExtractSystemfile($TargetFile)
	If $TargetDrive <> StringMid(GUICtrlRead($Combo1),1,2) Then	;Read boot sector and extract $MFT data
		$TargetDrive = StringMid(GUICtrlRead($Combo1),1,2)
		Global $DataQ[1], $RUN_VCN[1], $RUN_Clusters[1]
		If DriveGetFileSystem($TargetDrive) <> "NTFS" Then
			_DisplayInfo("Error: Target volume " & $TargetDrive & " is not NTFS" & @crlf)
			Return
		EndIf
		_DisplayInfo("Target volume is: " & $TargetDrive & @crlf)
		_ReadBootSector($TargetDrive)
		$BytesPerCluster = $SectorsPerCluster*$BytesPerSector
		$MFTEntry = _FindMFT(0)
		_DecodeMFTRecord($MFTEntry)
		_DecodeDataQEntry($DataQ[1])
		$MFTSize = $DATA_RealSize
		_ExtractDataRuns()
		$MFT_RUN_VCN = $RUN_VCN
		$MFT_RUN_Clusters = $RUN_Clusters
	EndIf
	If $TargetFile = "$MFT" Then
		_DisplayInfo("TargetFile is $MFT" & @CRLF)
		_ExtractSingleFile(0)
	ElseIf $TargetFile = "ALL" Then
		_DisplayInfo("TargetFiles are ALL meta files" & @CRLF)
		For $i = 0 To 26
			If ($i > 15 AND $i < 24) Or ($i = 8) Then ContinueLoop		;exclude $BadClus (has volume size ADS)
			_ExtractSingleFile($i)
		Next
	Else
		If $TargetFile > 24 Then _InitiateMftArray()
		If @error Then
			ConsoleWrite("Error when creating the MFT arrays" & @crlf)
			_DisplayInfo("Error when creating the MFT arrays" & @CRLF)
			Exit
		EndIf
		_DisplayInfo("TargetFile is " & $TargetFile & @CRLF)
		_ExtractSingleFile(Int($TargetFile,2))
	EndIf
	_DisplayInfo("Finished extraction of files." & @crlf & @crlf)
	ConsoleWrite("Finished extraction of files." & @crlf)
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
		ConsoleWrite("No $DATA attribute present for the file: " & $FN_FileName & @crlf)
		Return
	EndIf
	For $i = 1 To UBound($DataQ) - 1
		_DecodeDataQEntry($DataQ[$i])
		If $DATA_NonResidentFlag = '00' Then
			_ExtractResidentFile($DATA_Name, $DATA_LengthOfAttribute)
		Else
		Global $RUN_VCN[1], $RUN_Clusters[1]
		$TotalClusters = $DATA_LastVCN - $DATA_StartVCN + 1
		$Size = $DATA_RealSize
		_ExtractDataRuns()
		If $TotalClusters * $BytesPerCluster >= $Size Then
			ConsoleWrite(_ArrayToString($RUN_VCN) & @CRLF)
			ConsoleWrite(_ArrayToString($RUN_Clusters) & @CRLF)
			_ExtractFile()
		Else 		 ;code to handle attribute list
			$Flag = $IsCompressed		;preserve compression state
		 	For $j =$i + 1 To UBound($DataQ) - 1
				_DecodeDataQEntry($DataQ[$j])
				$TotalClusters += $DATA_LastVCN - $DATA_StartVCN + 1
				_ExtractDataRuns()
				If $TotalClusters * $BytesPerCluster >= $Size Then
					$DATA_RealSize = $Size
					$IsCompressed = $Flag
					ConsoleWrite(_ArrayToString($RUN_VCN) & @CRLF)
					ConsoleWrite(_ArrayToString($RUN_Clusters) & @CRLF)
					_ExtractFile()
					ExitLoop
				EndIf
			Next
			$i=$j
		EndIf
	EndIf
Next
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
	$FN_NameType = ""
	$DATA_NameLength = ""
	$DATA_NameRelativeOffset = ""
	$DATA_Flags = ""
	$DATA_Name = ""
	$DATA_NonResidentFlag = ""
	$DATA_AllocatedSize = ""
	$DATA_RealSize = ""
	$DATA_InitializedStreamSize = ""
	$DATA_LengthOfAttribute = ""
	$DATA_OffsetToAttribute = ""
	$DATA_IndexedFlag = ""
	$DATA_CompressionUnitSize = ""
	$DATA_CompressedSize = ""
	$RecordSlackSpace = ""
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
EndFunc

Func _DisplayInfo($DebugInfo)
	GUICtrlSetData($myctredit, $DebugInfo, 1)
EndFunc

Func _GetPhysicalDrives()
Local $List[30], $Drive = DriveGetDrive('All'), $tSTORAGE_DEVICE_NUMBER
If IsArray($Drive) Then
	For $i = 1 To $Drive[0]
		$tSTORAGE_DEVICE_NUMBER = _WinAPI_GetDriveNumber($Drive[$i])
		If Not @error Then
			$List[DllStructGetData($tSTORAGE_DEVICE_NUMBER, 'DeviceNumber')] &= StringUpper($Drive[$i]) & ' '
		EndIf
	Next
EndIf
For $i = 0 To UBound($List)-1
	If $List[$i] Then
		ConsoleWrite('\\.\PhysicalDrive' & $i & @CRLF)
		_DisplayInfo("Detected: " & '\\.\PhysicalDrive' & $i & @CRLF)
	EndIf
Next
EndFunc

Func _GetVolumes()
GUICtrlSetData($Combo1,"","")
$menu = ''
$entry = ''
$Text = ''
$var = DriveGetDrive( "all" )
If NOT @error Then
	For $i = 1 to $var[0]
		$DriveType = DriveGetType($var[$i])
		$DriveCapacity = DriveSpaceTotal($var[$i])
		$Bus = _WinAPI_GetDriveBusType($var[$i])
		$FileSystem = DriveGetFileSystem($var[$i])
		If $FileSystem = "NTFS" Then
			Switch $Bus
				Case $DRIVE_BUS_TYPE_UNKNOWN
					$Text = 'UNKNOWN'
				Case $DRIVE_BUS_TYPE_SCSI
					$Text = 'SCSI'
				Case $DRIVE_BUS_TYPE_ATAPI
					$Text = 'ATAPI'
				Case $DRIVE_BUS_TYPE_ATA
					$Text = 'ATA'
				Case $DRIVE_BUS_TYPE_1394
					$Text = '1394'
				Case $DRIVE_BUS_TYPE_SSA
					$Text = 'SSA'
				Case $DRIVE_BUS_TYPE_FIBRE
					$Text = 'FIBRE'
				Case $DRIVE_BUS_TYPE_USB
					$Text = 'USB'
				Case $DRIVE_BUS_TYPE_RAID
					$Text = 'RAID'
				Case $DRIVE_BUS_TYPE_ISCSI
					$Text = 'ISCSI'
				Case $DRIVE_BUS_TYPE_SAS
					$Text = 'SAS'
				Case $DRIVE_BUS_TYPE_SATA
					$Text = 'SATA'
				Case $DRIVE_BUS_TYPE_SD
					$Text = 'SD'
				Case $DRIVE_BUS_TYPE_MMC
					$Text = 'MMC'
			EndSwitch
			$entry = StringUpper($var[$i]) & "  (" & $DriveType & ")  - " & $Text & "  - " & Round($DriveCapacity,0) & " MB" & "  - " & $FileSystem & "|"
			$menu &=  $entry
		EndIf
	Next
Else
	_DisplayInfo("Error - something went wrong in Func _GetVolumes." & @CRLF)
	Return
EndIf
GUICtrlSetData($Combo1,$menu,StringMid($entry,1,StringLen($entry)-1))
EndFunc

Func _Get_StandardInformation($MFTEntry,$SI_Offset,$SI_Size)
;Not really needed in this app
Return
EndFunc

Func _AttribHeaderFlags($AHinput)
Local $AHoutput = ""
If BitAND($AHinput,0x0001) Then $AHoutput &= 'COMPRESSED+'
If BitAND($AHinput,0x4000) Then $AHoutput &= 'ENCRYPTED+'
If BitAND($AHinput,0x8000) Then $AHoutput &= 'SPARSE+'
$AHoutput = StringTrimRight($AHoutput,1)
Return $AHoutput
EndFunc

Func NT_SUCCESS($status)
	If 0 <= $status And $status <= 0x7FFFFFFF Then
		Return True
	Else
		Return False
	EndIf
EndFunc

Func _GetIndexNumber($file)
	Local $IndexNumber
	Local $hNTDLL = DllOpen("ntdll.dll")
	Local $szName = DllStructCreate("wchar[260]")
	Local $sUS = DllStructCreate($tagUNICODESTRING)
	Local $sOA = DllStructCreate($tagOBJECTATTRIBUTES)
	Local $sISB = DllStructCreate($tagIOSTATUSBLOCK)
	Local $buffer = DllStructCreate("byte[16384]")
	Local $ret, $FILE_MODE = $FILE_NON_DIRECTORY_FILE
	$file = "\??\" & $file
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
		_DisplayInfo("Error: NtOpenFile Failed" & @CRLF)
		Return SetError(1, 0, 0)
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
		_DisplayInfo("Error: NtQueryInformationFile Failed" & @CRLF)
		Return SetError(2, 0, 0)
	EndIf
	$ret = DllCall($hNTDLL, "int", "NtClose", "hwnd", $hFile)
	DllClose($hNTDLL)
	Return $IndexNumber
EndFunc

Func _BrowseTargetFile()
	$BrowsedFile = FileOpenDialog("Select file",StringMid(GUICtrlRead($combo1),1,2),"All (*.*)")
	_DisplayInfo("Target is " & $BrowsedFile & @CRLF)
	Return $BrowsedFile
EndFunc

Func _DecodeAttrList($TargetFile, $AttrList)
	Local $offset, $length, $nBytes, $hFile
	If StringMid($AttrList, 17, 2) = "00" Then		;attribute list is in $AttrList
		$offset = Dec(_SwapEndian(StringMid($AttrList, 41, 4)))
		$List = StringMid($AttrList, $offset*2+1)
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
	_DebugOut("$List", $List & @CRLF)
	$offset=0
	$str=""
	While StringLen($list) > $offset*2
		$ref=Dec(_SwapEndian(StringMid($List, $offset*2 + 33, 8)))
		If $ref <> $TargetFile Then		;new attribute
			If Not StringInStr($str, $ref) Then $str &= $ref & "-"
		EndIf
		$offset += Dec(_SwapEndian(StringMid($List, $offset*2 + 9, 4)))
	WEnd
	If $str = "" Then
		ConsoleWrite("No extra MFT records found" & @CRLF)
	Else
		$AttrQ = StringSplit(StringTrimRight($str,1), "-")
		ConsoleWrite("Extra MFT Records to be examined = " & _ArrayToString($AttrQ, @CRLF) & @CRLF)
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
	_DebugOut("Stripped Record", $MFTEntry)
	Return $MFTEntry
EndFunc

Func _DecodeDataQEntry($Entry)
	$DATA_NonResidentFlag = StringMid($Entry,17,2)
	ConsoleWrite("$DATA_NonResidentFlag = " & $DATA_NonResidentFlag & @crlf)
	$DATA_NameLength = Dec(StringMid($Entry,19,2))
	ConsoleWrite("$DATA_NameLength = " & $DATA_NameLength & @crlf)
	$DATA_NameRelativeOffset = StringMid($Entry,21,4)
	ConsoleWrite("$DATA_NameRelativeOffset = " & $DATA_NameRelativeOffset & @crlf)
	$DATA_NameRelativeOffset = Dec(_SwapEndian($DATA_NameRelativeOffset))
	ConsoleWrite("$DATA_NameRelativeOffset = " & $DATA_NameRelativeOffset & @crlf)
	If $DATA_NameLength > 0 Then
		$DATA_Name = _UnicodeHexToStr(StringMid($Entry,$DATA_NameRelativeOffset*2 + 1,$DATA_NameLength*4))
		$DATA_Name = $FN_FileName & "[" & $DATA_Name & "]"		;must be ADS
		ConsoleWrite("$DATA_Name = " & $DATA_Name & @crlf)
	Else
		$DATA_Name = $FN_FileName
	EndIf
	$DATA_Flags = _SwapEndian(StringMid($Entry,25,4))
	ConsoleWrite("$DATA_Flags = " & $DATA_Flags & @crlf)
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
	ConsoleWrite("File is " & $Flags & @CRLF)
	If $DATA_NonResidentFlag = '01' Then
		$DATA_StartVCN = StringMid($Entry,33,16)
		ConsoleWrite("$DATA_StartVCN = " & $DATA_StartVCN & @crlf)
		$DATA_StartVCN = Dec(_SwapEndian($DATA_StartVCN),2)
		ConsoleWrite("$DATA_StartVCN = " & $DATA_StartVCN & @crlf)
		$DATA_LastVCN = StringMid($Entry,49,16)
		ConsoleWrite("$DATA_LastVCN = " & $DATA_LastVCN & @crlf)
		$DATA_LastVCN = Dec(_SwapEndian($DATA_LastVCN),2)
		ConsoleWrite("$DATA_LastVCN = " & $DATA_LastVCN & @crlf)
		$DATA_VCNs = $DATA_LastVCN - $DATA_StartVCN
		ConsoleWrite("$DATA_VCNs = " & $DATA_VCNs & @crlf)
		$DATA_CompressionUnitSize = Dec(_SwapEndian(StringMid($Entry,69,4)))
		ConsoleWrite("$DATA_CompressionUnitSize = " & $DATA_CompressionUnitSize & @crlf)
		$IsCompressed = 0
		If $DATA_CompressionUnitSize = 4 Then $IsCompressed = 1
		$DATA_AllocatedSize = StringMid($Entry,81,16)
		ConsoleWrite("$DATA_AllocatedSize = " & $DATA_AllocatedSize & @crlf)
		$DATA_AllocatedSize = Dec(_SwapEndian($DATA_AllocatedSize),2)
		ConsoleWrite("$DATA_AllocatedSize = " & $DATA_AllocatedSize & @crlf)
		$DATA_RealSize = StringMid($Entry,97,16)
		ConsoleWrite("$DATA_RealSize = " & $DATA_RealSize & @crlf)
		$DATA_RealSize = Dec(_SwapEndian($DATA_RealSize),2)
		ConsoleWrite("$DATA_RealSize = " & $DATA_RealSize & @crlf)
		$DATA_InitializedStreamSize = StringMid($Entry,113,16)
		ConsoleWrite("$DATA_InitializedStreamSize = " & $DATA_InitializedStreamSize & @crlf)
		$DATA_InitializedStreamSize = Dec(_SwapEndian($DATA_InitializedStreamSize),2)
		ConsoleWrite("$DATA_InitializedStreamSize = " & $DATA_InitializedStreamSize & @crlf)
		$RunListOffset = StringMid($Entry,65,4)
		ConsoleWrite("$RunListOffset = " & $RunListOffset & @crlf)
		$RunListOffset = Dec(_SwapEndian($RunListOffset))
		ConsoleWrite("$RunListOffset = " & $RunListOffset & @crlf)
		If $IsCompressed AND $RunListOffset = 72 Then
			$DATA_CompressedSize = StringMid($Entry,129,16)
			$DATA_CompressedSize = Dec(_SwapEndian($DATA_CompressedSize),2)
		EndIf
		$DataRun = StringMid($Entry,$RunListOffset*2+1,(StringLen($Entry)-$RunListOffset)*2)
		ConsoleWrite("$DataRun = " & $DataRun & @crlf)
	ElseIf $DATA_NonResidentFlag = '00' Then
		$DATA_LengthOfAttribute = StringMid($Entry,33,8)
		ConsoleWrite("$DATA_LengthOfAttribute = " & $DATA_LengthOfAttribute & @crlf)
		$DATA_LengthOfAttribute = Dec(_SwapEndian($DATA_LengthOfAttribute),2)
		ConsoleWrite("$DATA_LengthOfAttribute = " & $DATA_LengthOfAttribute & @crlf)
		$DATA_OffsetToAttribute = Dec(_SwapEndian(StringMid($Entry,41,4)))
		ConsoleWrite("$DATA_OffsetToAttribute = " & $DATA_OffsetToAttribute & @crlf)
		$DATA_IndexedFlag = Dec(StringMid($Entry,45,2))
		$DataRun = StringMid($Entry,$DATA_OffsetToAttribute*2+1,$DATA_LengthOfAttribute*2)
		ConsoleWrite("$DataRun = " & $DataRun & @crlf)
	EndIf
EndFunc

Func _DecodeMFTRecord($MFTEntry)
Global $NameQ[5]		;clear name array
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
	_DisplayInfo("Error the $MFT record is corrupt" & @CRLF)
	Return
 Else
	$MFTEntry = StringMid($MFTEntry,1,1022) & $UpdSeqArrPart1 & StringMid($MFTEntry,1027,1020) & $UpdSeqArrPart2
EndIf
Local $MFTHeader = StringMid($MFTEntry,1,2+32)
ConsoleWrite("$MFTHeader = " & $MFTHeader & @crlf)
$HEADER_LSN = StringMid($MFTEntry,19,16)
ConsoleWrite("$HEADER_LSN = " & $HEADER_LSN & @crlf)
$HEADER_LSN = _SwapEndian($HEADER_LSN)
ConsoleWrite("$HEADER_LSN = " & $HEADER_LSN & @crlf)
$HEADER_SequenceNo = Dec(_SwapEndian(StringMid($MFTEntry,35,4)))
ConsoleWrite("$HEADER_SequenceNo = " & $HEADER_SequenceNo & @crlf)
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
ConsoleWrite("$HEADER_Flags = " & $HEADER_Flags & @crlf)
$HEADER_RecordRealSize = Dec(_SwapEndian(StringMid($MFTEntry,51,8)),2)
ConsoleWrite("$HEADER_RecordRealSize = " & $HEADER_RecordRealSize & @crlf)
$HEADER_RecordAllocSize = Dec(_SwapEndian(StringMid($MFTEntry,59,8)),2)
ConsoleWrite("$HEADER_RecordAllocSize = " & $HEADER_RecordAllocSize & @crlf)
$HEADER_FileRef = StringMid($MFTEntry,67,16)
ConsoleWrite("$HEADER_FileRef = " & $HEADER_FileRef & @crlf)
$HEADER_NextAttribID = StringMid($MFTEntry,83,4)
ConsoleWrite("$HEADER_NextAttribID = " & $HEADER_NextAttribID & @crlf)
$HEADER_NextAttribID = _SwapEndian($HEADER_NextAttribID)
$HEADER_MFTRecordNumber = Dec(_SwapEndian(StringMid($MFTEntry,91,8)),2)
ConsoleWrite("$HEADER_MFTRecordNumber = " & $HEADER_MFTRecordNumber & @crlf)
$AttributeOffset = (Dec(StringMid($MFTEntry,43,2))*2)+3
While 1
	$AttributeType = StringMid($MFTEntry,$AttributeOffset,8)
	ConsoleWrite("$AttributeType = " & $AttributeType & @crlf)
	If $AttributeType = $ATTRIBUTE_END_MARKER Then ExitLoop
	$AttributeSize = StringMid($MFTEntry,$AttributeOffset+8,8)
	ConsoleWrite("$AttributeSize = " & $AttributeSize & @crlf)
	$AttributeSize = Dec(_SwapEndian($AttributeSize),2)
	ConsoleWrite("$AttributeSize = " & $AttributeSize & @crlf)
	ConsoleWrite("$AttributeOffset Dec = " & $AttributeOffset & @crlf)
	ConsoleWrite("$AttributeOffset Hex = 0x" & Hex(Int(($AttributeOffset-3)/2),4) & @crlf)
	Select
		Case $AttributeType = $STANDARD_INFORMATION
			$STANDARD_INFORMATION_ON = "TRUE"
;			_Get_StandardInformation($MFTEntry,$NextAttributeOffset,$AttributeSize)
		Case $AttributeType = $ATTRIBUTE_LIST
			$ATTRIBUTE_LIST_ON = "TRUE"
			$AttrList = StringMid($MFTEntry,$AttributeOffset,$AttributeSize*2)
			_DecodeAttrList($HEADER_MFTRecordNumber, $AttrList)		;produces $AttrQ - extra record list
			$str = ""
			For $i = 1 To $AttrQ[0]
;			   $record = _FindFileMFTRecord($AttrQ[$i])
			   $record = _ProcessMftArray($AttrQ[$i])
			   $str &= _StripMftRecord($record)		;no header or end marker
			Next
			$str &= "FFFFFFFF"		;add end marker
			_DebugOut("$str", $str)
			$MFTEntry = StringMid($MFTEntry,1,($HEADER_RecordRealSize-8)*2+2) & $str       ;strip "FFFFFFFF..." first
   		Case $AttributeType = $FILE_NAME
			$FILE_NAME_ON = "TRUE"
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
		Case $AttributeType = $OBJECT_ID
			$OBJECT_ID_ON = "TRUE"
;			_Get_ObjectID($MFTEntry,$NextAttributeOffset,$AttributeSize)
		Case $AttributeType = $SECURITY_DESCRIPTOR
			$SECURITY_DESCRIPTOR_ON = "TRUE"
;			_Get_SecurityDescriptor()
		Case $AttributeType = $VOLUME_NAME
			$VOLUME_NAME_ON = "TRUE"
;			_Get_VolumeName($MFTEntry,$NextAttributeOffset,$AttributeSize)
		Case $AttributeType = $VOLUME_INFORMATION
			$VOLUME_INFORMATION_ON = "TRUE"
;			_Get_VolumeInformation($MFTEntry,$NextAttributeOffset,$AttributeSize)
		Case $AttributeType = $DATA
			$DATA_ON = "TRUE"
			_ArrayAdd($DataQ, StringMid($MFTEntry,$AttributeOffset,$AttributeSize*2))
		Case $AttributeType = $INDEX_ROOT
			$INDEX_ROOT_ON = "TRUE"
;			_Get_IndexRoot()
		Case $AttributeType = $INDEX_ALLOCATION
			$INDEX_ALLOCATION_ON = "TRUE"
;			_Get_IndexAllocation()
		Case $AttributeType = $BITMAP
			$BITMAP_ON = "TRUE"
;			_Get_Bitmap()
		Case $AttributeType = $REPARSE_POINT
			$REPARSE_POINT_ON = "TRUE"
;			_Get_ReparsePoint()
		Case $AttributeType = $EA_INFORMATION
			$EA_INFORMATION_ON = "TRUE"
;			_Get_EaInformation()
		Case $AttributeType = $EA
			$EA_ON = "TRUE"
;			_Get_Ea()
		Case $AttributeType = $PROPERTY_SET
			$PROPERTY_SET_ON = "TRUE"
;			_Get_PropertySet()
		Case $AttributeType = $LOGGED_UTILITY_STREAM
			$LOGGED_UTILITY_STREAM_ON = "TRUE"
;			_Get_LoggedUtilityStream()
		Case Else
			ExitLoop
	EndSelect
	$AttributeOffset += $AttributeSize*2
WEnd
EndFunc

Func _DecodeNameQ($NameQ)
	For $name = 1 To UBound($NameQ) - 1
		$NameString = $NameQ[$name]
		If $NameString = "" Then ContinueLoop
		$FN_AllocSize = Dec(_SwapEndian(StringMid($NameString,129,16)),2)
		ConsoleWrite("$FN_AllocSize = " & $FN_AllocSize & @crlf)
		$FN_RealSize = Dec(_SwapEndian(StringMid($NameString,145,16)),2)
		ConsoleWrite("$FN_RealSize = " & $FN_RealSize & @crlf)
		$FN_NameLength = Dec(StringMid($NameString,177,2))
		ConsoleWrite("$FN_NameLength = " & $FN_NameLength & @crlf)
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
		ConsoleWrite("$FN_NameSpace = " & $FN_NameSpace & @crlf)
		$FN_FileName = StringMid($NameString,181,$FN_NameLength*4)
		ConsoleWrite("$FN_FileName = " & $FN_FileName & @crlf)
		$FN_FileName = _UnicodeHexToStr($FN_FileName)
		ConsoleWrite("$FN_FileName = " & $FN_FileName & @crlf)
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
		ConsoleWrite("$RunListID = " & $RunListID & @crlf)
		$i += 2
		$RunListClustersLength = Dec(StringMid($RunListID,2,1))
		ConsoleWrite("$RunListClustersLength = " & $RunListClustersLength & @crlf)
		$RunListVCNLength = Dec(StringMid($RunListID,1,1))
		ConsoleWrite("$RunListVCNLength = " & $RunListVCNLength & @crlf)
		$RunListClusters = Dec(_SwapEndian(StringMid($DataRun,$i,$RunListClustersLength*2)),2)
		ConsoleWrite("$RunListClusters = " & $RunListClusters & @crlf)
		$i += $RunListClustersLength*2
		$RunListVCN = _SwapEndian(StringMid($DataRun, $i, $RunListVCNLength*2))
		;next line handles positive or negative move
		$BaseVCN += Dec($RunListVCN,2)-(($r>1) And (Dec(StringMid($RunListVCN,1,1))>7))*Dec(StringMid("10000000000000000",1,$RunListVCNLength*2+1),2)
		If $RunListVCN <> "" Then
			$RunListVCN = $BaseVCN
		Else
			$RunListVCN = 0			;$RUN_VCN[$r-1]		;0
		EndIf
		ConsoleWrite("$RunListVCN = " & $RunListVCN & @crlf)
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

Func _ExtractFile()
	Local $nBytes
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
		_DisplayInfo("Error in function _WinAPI_CreateFile for: " & $outputpath & "\" & $DATA_Name & @crlf)
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
   _DisplayInfo("Successfully extracted target file: " & $DATA_Name & " to " & $outputpath & "\" & $DATA_Name  & @CRLF)
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
	Local $nBytes
	$hTest = _WinAPI_CreateFile($outputpath & "\" & $Name,3,6,7)
	If $hTest = 0 Then
		ConsoleWrite("Error in function _WinAPI_CreateFile for: " & $outputpath & "\" & $Name & @crlf)
		Return
	EndIf
	ConsoleWrite("$hTest = " & $hTest & @crlf)
	_WinAPI_SetFilePointer($hTest, 0,$FILE_BEGIN)
	$tBuffer = DllStructCreate("byte[" & $Size & "]")
	DllStructSetData($tBuffer, 1, '0x' & $DataRun)
	ConsoleWrite("Size of buffer = " & $Size & @crlf)
	_WinAPI_WriteFile($hTest, DllStructGetPtr($tBuffer), $Size, $nBytes)
	_WinAPI_CloseHandle($hTest)
	ConsoleWrite("Successfully extracted target file: " & $Name & " to " & $outputpath & "\" & $Name  & @CRLF)
	ConsoleWrite("Size of extracted " & $Name & " is " & $Size & " bytes" & @CRLF)
EndFunc

Func _FindFileMFTRecord($TargetFile)
	Local $nBytes
	$tBuffer = DllStructCreate("byte[" & $MFT_Record_Size & "]")
	$hFile = _WinAPI_CreateFile("\\.\" & $TargetDrive, 2, 6, 6)
	If $hFile = 0 Then
		ConsoleWrite("Error in function _WinAPI_CreateFile when trying to locate target file." & @CRLF)
		_WinAPI_CloseHandle($hFile)
		Return ""
	EndIf
	_DisplayInfo("Selected record number " & $TargetFile & @CRLF)
	$TargetFile = _DecToLittleEndian($TargetFile)
	ConsoleWrite("Selected record number " & $TargetFile & @CRLF)
	ConsoleWrite("Started searching through $MFT for the selected record number " & $TargetFile & @CRLF)
	For $r = 1 To Ubound($MFT_RUN_VCN)-1
		_WinAPI_SetFilePointerEx($hFile, $MFT_RUN_VCN[$r]*$BytesPerCluster, $FILE_BEGIN)
		For $i = 0 To $MFT_RUN_Clusters[$r]*$BytesPerCluster Step $MFT_Record_Size
			_WinAPI_ReadFile($hFile, DllStructGetPtr($tBuffer), $MFT_Record_Size, $nBytes)
			$record = DllStructGetData($tBuffer, 1)
			;If $RecordActive = "ALLOCATED" AND StringMid($record,91,8) = $TargetFile Then
			If BitAND(Dec(StringMid($record,47,4)),Dec("0100")) AND StringMid($record,91,8) = $TargetFile Then
				ConsoleWrite("Target " & $TargetFile & " found" & @CRLF)
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
		ConsoleWrite("MFT record found" & @CRLF)
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
		_DisplayInfo("Error in function _WinAPI_CreateFile for: " & "\\.\" & $TargetDrive & @crlf)
		Return
	EndIf
	$read = _WinAPI_ReadFile($hFile, DllStructGetPtr($tBuffer), 512, $nBytes)
	If $read = 0 then
		_DisplayInfo("Error in function _WinAPI_ReadFile for: " & "\\.\" & $TargetDrive & @crlf)
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

	ConsoleWrite("Jump:  " & DllStructGetData($tBootSectorSections, "Jump") & @CRLF)
	ConsoleWrite("SystemName:  " & DllStructGetData($tBootSectorSections, "SystemName") & @CRLF)
	ConsoleWrite("BytesPerSector:  " & $BytesPerSector & @CRLF)
	ConsoleWrite("SectorsPerCluster:  " & $SectorsPerCluster & @CRLF)
	ConsoleWrite("ReservedSectors:  " & DllStructGetData($tBootSectorSections, "ReservedSectors") & @CRLF)
	ConsoleWrite("MediaDescriptor:  " & DllStructGetData($tBootSectorSections, "MediaDescriptor") & @CRLF)
	ConsoleWrite("SectorsPerTrack:  " & DllStructGetData($tBootSectorSections, "SectorsPerTrack") & @CRLF)
	ConsoleWrite("NumberOfHeads:  " & DllStructGetData($tBootSectorSections, "NumberOfHeads") & @CRLF)
	ConsoleWrite("HiddenSectors:  " & DllStructGetData($tBootSectorSections, "HiddenSectors") & @CRLF)
	ConsoleWrite("TotalSectors:  " & DllStructGetData($tBootSectorSections, "TotalSectors") & @CRLF)
	ConsoleWrite("LogicalClusterNumberforthefileMFT:  " & $LogicalClusterNumberforthefileMFT & @CRLF)
	ConsoleWrite("LogicalClusterNumberforthefileMFTMirr:  " & DllStructGetData($tBootSectorSections, "LogicalClusterNumberforthefileMFTMirr") & @CRLF)
	ConsoleWrite("ClustersPerFileRecordSegment:  " & $ClustersPerFileRecordSegment & @CRLF)
	ConsoleWrite("ClustersPerIndexBlock:  " & DllStructGetData($tBootSectorSections, "ClustersPerIndexBlock") & @CRLF)
	ConsoleWrite("VolumeSerialNumber:  " & Ptr(DllStructGetData($tBootSectorSections, "NTFSVolumeSerialNumber")) & @CRLF)
	ConsoleWrite("NTFSVolumeSerialNumber:  " & DllStructGetData($tBootSectorSections, "NTFSVolumeSerialNumber") & @CRLF)
	ConsoleWrite("Checksum:  " & DllStructGetData($tBootSectorSections, "Checksum") & @CRLF)

	$MFT_Offset = $BytesPerCluster * $LogicalClusterNumberforthefileMFT
	ConsoleWrite("$MFT_Offset: " & $MFT_Offset & @CRLF)
	If $ClustersPerFileRecordSegment > 127 Then
		$MFT_Record_Size = 2 ^ (256 - $ClustersPerFileRecordSegment)
	Else
		$MFT_Record_Size = $BytesPerCluster * $ClustersPerFileRecordSegment
	EndIf
	ConsoleWrite("$MFT_Record_Size: " & $MFT_Record_Size & @crlf)
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
	_DisplayInfo("Processing $MFT..." & @CRLF)
	$tBuffer = DllStructCreate("byte[" & $MFT_Record_Size & "]")
	$hFile = _WinAPI_CreateFile("\\.\" & $TargetDrive, 2, 6, 6)
	If $hFile = 0 Then
		ConsoleWrite("Error in function _WinAPI_CreateFile when building MFT array." & @CRLF)
		_DisplayInfo("Error in function _WinAPI_CreateFile when building MFT array." & @CRLF)
		_WinAPI_CloseHandle($hFile)
		Return SetError(1, 0, 0)
	EndIf
	If $MFTSize > 1342054400 Then
		ConsoleWrite("Warning: $MFT is too large to fit in the arrays" & @CRLF)
		_DisplayInfo("Warning: $MFT is too large to fit in the arrays" & @CRLF)
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
		_DisplayInfo("Error in function _WinAPI_CreateFile when trying to locate target file." & @CRLF)
		_WinAPI_CloseHandle($hFile)
		Return ""
	EndIf
	ConsoleWrite("Searching through the $MFT arrays for the selected record number " & $TargetFile & " -> " & _DecToLittleEndian($TargetFile) & @CRLF)
	_DisplayInfo("Searching through the $MFT arrays for the selected record number " & $TargetFile & " -> " & _DecToLittleEndian($TargetFile) & @CRLF)
	$TargetFile = _DecToLittleEndian($TargetFile)
	$LocalMftSearch = _SearchMftArray($TargetFile)
	If @error Then
		ConsoleWrite("Error: could not find target file in the MFT arrays" & @CRLF)
		_DisplayInfo("Error: could not find target file in the MFT arrays" & @CRLF)
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
		_DisplayInfo("Target " & $TargetFile & " found" & @CRLF)
		_WinAPI_CloseHandle($hFile)
		Return $record		;returns MFT record for file
	EndIf
	_WinAPI_CloseHandle($hFile)
	Return ""
EndFunc