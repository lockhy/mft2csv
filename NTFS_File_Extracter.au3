#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_UseX64=y
#AutoIt3Wrapper_Res_requestedExecutionLevel=asInvoker
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#include <StaticConstants.au3>
#include <EditConstants.au3>
#include <GuiEdit.au3>
#Include <WinAPIEx.au3>
;#Include <WinAPI.au3>
#Include <APIConstants.au3>
#Include <Date.au3>
#include <Array.au3>
#Include <String.au3>
; http://code.google.com/p/mft2csv/
; by Joakim Schicht
Global $HEADER_LSN,$HEADER_SequenceNo,$HEADER_Flags,$HEADER_RecordRealSize,$HEADER_RecordAllocSize,$HEADER_FileRef,$HEADER_NextAttribID,$HEADER_MFTREcordNumber
Global $SI_CTime,$SI_ATime,$SI_MTime,$SI_RTime,$SI_FilePermission,$SI_USN,$Errors,$DATA_AllocatedSize,$DATA_RealSize,$DATA_InitializedStreamSize,$RecordSlackSpace
Global $FN_CTime,$FN_ATime,$FN_MTime,$FN_RTime,$FN_AllocSize,$FN_RealSize,$FN_Flags,$FN_FileName,$DATA_VCNs,$DATA_NonResidentFlag,$FN_NameType
Global $FN_CTime_2,$FN_ATime_2,$FN_MTime_2,$FN_RTime_2,$FN_AllocSize_2,$FN_RealSize_2,$FN_Flags_2,$FN_NameLength_2,$FN_NameSpace_2,$FN_FileName_2,$FN_NameType_2
Global $DATA_NameLength,$DATA_NameRelativeOffset,$DATA_Flags,$DATA_NameSpace,$DATA_Name,$RecordActive,$DATA_CompressionUnitSize,$DATA_ON,$DATA_CompressedSize
Global $List[30], $Drive = DriveGetDrive('All'), $BrowsedFile
Global $tSTORAGE_DEVICE_NUMBER, $Volume, $hFile, $SectorsPerCluster, $testfile, $MFT_Record_Size, $RunListOffset
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
$Form = GUICreate("NTFS File Extracter v1.9 - by Joakim Schicht", 520, 250, -1, -1)
$Combo1 = GUICtrlCreateCombo("", 20, 20, 400, 25)
$ButtonRefresh = GUICtrlCreateButton("Refresh", 440, 20, 60, 20)
$ButtonGetMFT = GUICtrlCreateButton("Extract $MFT", 20, 50, 100, 20)
$ButtonGetAll = GUICtrlCreateButton("Extract All systemfiles", 130, 50, 120, 20)
$ButtonBrowse = GUICtrlCreateButton("Browse for file", 260, 50, 120, 20)
$LabelMFTnumber = GUICtrlCreateLabel("Set MFT record number:",20,90,120,20)
$InputMFTnumber = GUICtrlCreateInput("0",150,90,100,20)
$ButtonMFTnumber = GUICtrlCreateButton("Extract Record numbers $DATA", 270, 90, 170, 20)
Global $checkRuns = GUICtrlCreateCheckbox("Display runs", 400, 50, 100, 20)
GUICtrlSetState($checkRuns, $GUI_CHECKED)
;GUICtrlSetState($ButtonMFTnumber,$GUI_DISABLE)
;$Combo2 = GUICtrlCreateCombo("", 20, 75, 400, 25)
;GUICtrlSetState($Combo2,$GUI_DISABLE)
;$ButtonExtract = GUICtrlCreateButton("Extract systemfile", 20, 100, 100, 20)
;GUICtrlSetState($ButtonExtract,$GUI_DISABLE)
$myctredit = GUICtrlCreateEdit("Extracting files directly from Physical Disk.." & @CRLF, 0, 125, 520, 125, $ES_AUTOVSCROLL + $WS_VSCROLL)
_GUICtrlEdit_SetLimitText($myctredit, 128000)
_DisplayInfo("" & @CRLF)
_DisplayInfo("Selected output folder: " & $outputpath & @CRLF)
_GetPhysicalDrives()
_GetVolumes()

GUISetState(@SW_SHOW)

While 1
$nMsg = GUIGetMsg()

Select

	Case $nMsg = $ButtonRefresh
		_GetPhysicalDrives()
		_GetVolumes()

	Case $nMsg = $ButtonGetMFT
		_ExtractSystemfile(1,"$MFT",0)

	Case $nMsg = $ButtonGetAll
		_ExtractSystemfile(1,"ALL",0)

	Case $nMsg = $ButtonMFTnumber
		_ExtractSystemfile(2,_DecToLittleEndian(GUICtrlRead($InputMFTnumber)),0)

	Case $nMsg = $ButtonBrowse
		_BrowseTargetFile()

	Case $nMsg = $GUI_EVENT_CLOSE
		Exit

EndSelect
WEnd

Func _ExtractSystemfile($MFTmode,$TARGET_SYSFILE,$IsBrowse)
If $IsBrowse Then
	$TargetDrive = StringMid($BrowsedFile,1,2)
Else
	$TargetDrive = StringMid(GUICtrlRead($Combo1),1,2)
EndIf
if DriveGetFileSystem($TargetDrive) <> "NTFS" then
	_DisplayInfo("Error: Target volume " & $TargetDrive & " is not NTFS" & @crlf)
	Return
EndIf
_DisplayInfo("Target volume is: " & $TargetDrive & @crlf)
Global $tBuffer=DllStructCreate("byte[512]"),$nBytes
Global $hFile0 = _WinAPI_CreateFile("\\.\" & $TargetDrive,2,2,7)
If $hFile0 = 0 then
	_DisplayInfo("Error in function _WinAPI_CreateFile for: " & "\\.\" & $TargetDrive & @crlf)
	Return
EndIf
$read = _WinAPI_ReadFile($hFile0, DllStructGetPtr($tBuffer), 512, $nBytes)
If $read = 0 then
	_DisplayInfo("Error in function _WinAPI_ReadFile for: " & "\\.\" & $TargetDrive & @crlf)
	Return
EndIf
Global $bRaw = DllStructGetData($tBuffer,1)
_WinAPI_CloseHandle($hFile0)
; Good starting point from KaFu & tranexx at the AutoIt forum
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

ConsoleWrite("Jump:  " & DllStructGetData($tBootSectorSections, "Jump") & @CRLF)
ConsoleWrite("SystemName:  " & DllStructGetData($tBootSectorSections, "SystemName") & @CRLF)
ConsoleWrite("BytesPerSector:  " & DllStructGetData($tBootSectorSections, "BytesPerSector") & @CRLF)
ConsoleWrite("SectorsPerCluster:  " & DllStructGetData($tBootSectorSections, "SectorsPerCluster") & @CRLF)
ConsoleWrite("ReservedSectors:  " & DllStructGetData($tBootSectorSections, "ReservedSectors") & @CRLF)
ConsoleWrite("MediaDescriptor:  " & DllStructGetData($tBootSectorSections, "MediaDescriptor") & @CRLF)
ConsoleWrite("SectorsPerTrack:  " & DllStructGetData($tBootSectorSections, "SectorsPerTrack") & @CRLF)
ConsoleWrite("NumberOfHeads:  " & DllStructGetData($tBootSectorSections, "NumberOfHeads") & @CRLF)
ConsoleWrite("HiddenSectors:  " & DllStructGetData($tBootSectorSections, "HiddenSectors") & @CRLF)
ConsoleWrite("TotalSectors:  " & DllStructGetData($tBootSectorSections, "TotalSectors") & @CRLF)
ConsoleWrite("LogicalClusterNumberforthefileMFT:  " & DllStructGetData($tBootSectorSections, "LogicalClusterNumberforthefileMFT") & @CRLF)
ConsoleWrite("LogicalClusterNumberforthefileMFTMirr:  " & DllStructGetData($tBootSectorSections, "LogicalClusterNumberforthefileMFTMirr") & @CRLF)
ConsoleWrite("ClustersPerFileRecordSegment:  " & DllStructGetData($tBootSectorSections, "ClustersPerFileRecordSegment") & @CRLF)
ConsoleWrite("ClustersPerIndexBlock:  " & DllStructGetData($tBootSectorSections, "ClustersPerIndexBlock") & @CRLF)
ConsoleWrite("VolumeSerialNumber:  " & Ptr(DllStructGetData($tBootSectorSections, "NTFSVolumeSerialNumber")) & @CRLF)
ConsoleWrite("NTFSVolumeSerialNumber:  " & DllStructGetData($tBootSectorSections, "NTFSVolumeSerialNumber") & @CRLF)
ConsoleWrite("Checksum:  " & DllStructGetData($tBootSectorSections, "Checksum") & @CRLF)

Global $BytesPerSector = DllStructGetData($tBootSectorSections, "BytesPerSector")
Global $SectorsPerCluster = DllStructGetData($tBootSectorSections, "SectorsPerCluster")
Global $ClustersPerFileRecordSegment = DllStructGetData($tBootSectorSections, "ClustersPerFileRecordSegment")
Global $LogicalClusterNumberforthefileMFT = DllStructGetData($tBootSectorSections, "LogicalClusterNumberforthefileMFT")
$MFT_Offset = $BytesPerSector * $SectorsPerCluster * $LogicalClusterNumberforthefileMFT
ConsoleWrite("$MFT_Offset: " & $MFT_Offset & @CRLF)
;$MFT_Record_Size = $BytesPerSector * $SectorsPerCluster / $ClustersPerFileRecordSegment
;$MFT_Record_Size = $BytesPerSector * $SectorsPerCluster / 4
$MFT_Record_Size = 1024
ConsoleWrite("$MFT_Record_Size: " & $MFT_Record_Size & @crlf)
$MFT_Record_Size_Inv = $MFT_Record_Size/$BytesPerSector
$tBuffer = DllStructCreate("byte[" & $MFT_Record_Size & "]")
$hdd_handle = "\\.\" & $TargetDrive
ConsoleWrite($hdd_handle & @crlf)
$hFile = _WinAPI_CreateFile($hdd_handle, 2, 6, 6)
If $hFile = 0 Then
	_DisplayInfo("Error in function _WinAPI_CreateFile when trying to locate and process target file." & @crlf)
	Return
EndIf
ConsoleWrite("Harddisk Handle: " & $hFile & @crlf)
;$ExpectedRecords = $MFTSize/$MFT_Record_Size
If $TARGET_SYSFILE = "$MFT" Then
	$ExpectedRecords = 0
ElseIf $TARGET_SYSFILE = "ALL" Then
	$ExpectedRecords = 26
Else;If $TARGET_SYSFILE <> "$MFT" AND $TARGET_SYSFILE <> "ALL" Then
	$ExpectedRecords = $TARGET_SYSFILE
EndIf
ConsoleWrite("$ExpectedRecords = " & $ExpectedRecords & @CRLF)
If $MFTmode = 1 Then
	For $i = 0 to $ExpectedRecords
		$RecordOffsetDec = $MFT_Offset + $MFT_Record_Size * $i
		If $i > 15 AND $i < 24 Then ContinueLoop
;		If $i > 26 Then ExitLoop
		_WinAPI_SetFilePointerEx($hFile, $RecordOffsetDec)
		_WinAPI_ReadFile($hFile, DllStructGetPtr($tBuffer), $MFT_Record_Size, $nBytes)
		$MFTEntry = DllStructGetData($tBuffer, 1)
		If NOT (StringMid($MFTEntry,3,8) = '46494C45') Then
;			$RecordHealth = "BAAD"
			_DisplayInfo("Warning: Record has wrong signature" & @crlf)
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
			_DisplayInfo("Started searching through $MFT for the selected record number." & @crlf)
			ConsoleWrite("Started searching through $MFT for the selected record number." & @crlf)
			For $MFTruns = 1 To Ubound($MFT_RUN_Cluster)-1
				$MFTInnerloops = $MFT_RUN_Sectors[$MFTruns]*4
				$MFT_Offset_tmp = $MFT_RUN_Cluster[$MFTruns]*$SectorsPerCluster*512
				For $MFTInnerRuns = 0 To $MFTInnerloops
					_WinAPI_SetFilePointerEx($hFile, $MFT_Offset_tmp+($MFT_Record_Size*$MFTInnerRuns),$FILE_BEGIN)
					_WinAPI_ReadFile($hFile, DllStructGetPtr($tBuffer), $MFT_Record_Size, $nBytes)
					$MFTEntry = DllStructGetData($tBuffer, 1)
					If StringMid($MFTEntry,47,4) = "0100" AND StringMid($MFTEntry,91,8) = $TARGET_SYSFILE Then
						ConsoleWrite("Target found!!" & @crlf)
						_DisplayInfo("Target found!!" & @crlf)
						_ClearVar()
						_DecodeMFTRecord($MFTEntry,1)
						_DisplayInfo("Finished extraction of file." & @crlf & @crlf)
						ConsoleWrite("Finished extraction of file." & @crlf)
						Return
					EndIf
;					If NOT StringMid($MFTEntry,3,8) = '46494C45' Then
;						ConsoleWrite("Signature not found here (no valid record).. "& @crlf)
;						ContinueLoop
;					EndIf
				Next
			Next
		EndIf
		If $i = 0 AND $MFTmode = 2 Then
			_WinAPI_SetFilePointerEx($hFile, $RecordOffsetDec)
			_WinAPI_ReadFile($hFile, DllStructGetPtr($tBuffer), $MFT_Record_Size, $nBytes)
			$MFTEntry = DllStructGetData($tBuffer, 1)
			If NOT StringMid($MFTEntry,1,8) = '46494C45' Then
				ConsoleWrite("Signature not found here.. "& @crlf)
				ContinueLoop
			EndIf
			_ClearVar()
			_DecodeMFTRecord($MFTEntry,2)
		EndIf
	Next
EndIf
_WinAPI_CloseHandle($hFile)
_DisplayInfo("Finished extraction of files." & @crlf & @crlf)
ConsoleWrite("Finished extraction of files." & @crlf)
EndFunc

Func _DisplayInfo($DebugInfo)
GUICtrlSetData($myctredit, $DebugInfo, 1)
EndFunc

Func _GetPhysicalDrives()
$menu = ''
$entry = ''
For $i = 0 To UBound($Drive) - 1
    $List[$i] = ''
Next
If IsArray($Drive) Then
    For $i = 1 To $Drive[0]
        $tSTORAGE_DEVICE_NUMBER = _WinAPI_GetDriveNumber($Drive[$i])
        If Not @error Then
            $List[DllStructGetData($tSTORAGE_DEVICE_NUMBER, 'DeviceNumber')] &= StringUpper($Drive[$i]) & ' '
        EndIf
    Next
EndIf
For $i = 0 To UBound($Drive) - 1
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

Func _DecodeMFTRecord($MFTEntry,$MFTMode)
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
$UpdSeqArrOffset = StringMid($MFTEntry,11,4)
$UpdSeqArrOffset = Dec(StringMid($UpdSeqArrOffset,3,2) & StringMid($UpdSeqArrOffset,1,2))
$UpdSeqArrSize = StringMid($MFTEntry,15,4)
$UpdSeqArrSize = Dec(StringMid($UpdSeqArrSize,3,2) & StringMid($UpdSeqArrSize,1,2))
$UpdSeqArr = StringMid($MFTEntry,3+($UpdSeqArrOffset*2),$UpdSeqArrSize*2*2)
$UpdSeqArrPart0 = StringMid($UpdSeqArr,1,4)
$UpdSeqArrPart1 = StringMid($UpdSeqArr,5,4)
$UpdSeqArrPart2 = StringMid($UpdSeqArr,9,4)
$RecordEnd1 = StringMid($MFTEntry,1023,4)
$RecordEnd2 = StringMid($MFTEntry,2047,4)
If $RecordEnd1 <> $RecordEnd2 OR $UpdSeqArrPart0 <> $RecordEnd1 Then
	_DisplayInfo("Error the $MFT record is corrupt" & @CRLF)
	Return
EndIf
$MFTEntry = StringMid($MFTEntry,1,1022) & $UpdSeqArrPart1 & StringMid($MFTEntry,1027,1020) & $UpdSeqArrPart2 ; Stupid fixup to not corrupt decoding of attributes that are located past 0x1fd within record
Local $MFTHeader = StringMid($MFTEntry,1,32)
ConsoleWrite("$MFTHeader = " & $MFTHeader & @crlf)
$HEADER_LSN = StringMid($MFTEntry,19,16)
ConsoleWrite("$HEADER_LSN = " & $HEADER_LSN & @crlf)
$HEADER_LSN = StringMid($HEADER_LSN,15,2) & StringMid($HEADER_LSN,13,2) & StringMid($HEADER_LSN,11,2) & StringMid($HEADER_LSN,9,2) & StringMid($HEADER_LSN,7,2) & StringMid($HEADER_LSN,5,2) & StringMid($HEADER_LSN,3,2) & StringMid($HEADER_LSN,1,2)
ConsoleWrite("$HEADER_LSN = " & $HEADER_LSN & @crlf)
$HEADER_SequenceNo = StringMid($MFTEntry,35,4)
$HEADER_SequenceNo = Dec(StringMid($HEADER_SequenceNo,3,2) & StringMid($HEADER_SequenceNo,1,2))
;$HEADER_SequenceNo = Dec($HEADER_SequenceNo)
ConsoleWrite("$HEADER_SequenceNo = " & $HEADER_SequenceNo & @crlf)
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
	Case Else ;$HEADER_Flags <> '0000' AND $HEADER_Flags <> '0100' AND $HEADER_Flags <> '0200' AND $HEADER_Flags <> '0300'
		$HEADER_Flags = 'UNKNOWN'
		$RecordActive = 'UNKNOWN'
EndSelect
;#ce
ConsoleWrite("$HEADER_Flags = " & $HEADER_Flags & @crlf)
$HEADER_RecordRealSize = StringMid($MFTEntry,51,8)
$HEADER_RecordRealSize = Dec(StringMid($HEADER_RecordRealSize,7,2) & StringMid($HEADER_RecordRealSize,5,2) & StringMid($HEADER_RecordRealSize,3,2) & StringMid($HEADER_RecordRealSize,1,2))
;$HEADER_RecordRealSize = Dec($HEADER_RecordRealSize)
ConsoleWrite("$HEADER_RecordRealSize = " & $HEADER_RecordRealSize & @crlf)
$HEADER_RecordAllocSize = StringMid($MFTEntry,59,8)
$HEADER_RecordAllocSize = Dec(StringMid($HEADER_RecordAllocSize,7,2) & StringMid($HEADER_RecordAllocSize,5,2) & StringMid($HEADER_RecordAllocSize,3,2) & StringMid($HEADER_RecordAllocSize,1,2))
;$HEADER_RecordAllocSize = Dec($HEADER_RecordAllocSize)
ConsoleWrite("$HEADER_RecordAllocSize = " & $HEADER_RecordAllocSize & @crlf)
$HEADER_FileRef = StringMid($MFTEntry,67,16)
ConsoleWrite("$HEADER_FileRef = " & $HEADER_FileRef & @crlf)
$HEADER_NextAttribID = StringMid($MFTEntry,83,4)
ConsoleWrite("$HEADER_NextAttribID = " & $HEADER_NextAttribID & @crlf)
$HEADER_NextAttribID = StringMid($HEADER_NextAttribID,3,2) & StringMid($HEADER_NextAttribID,1,2)
$HEADER_MFTREcordNumber = StringMid($MFTEntry,91,8)
$HEADER_MFTREcordNumber = Dec(StringMid($HEADER_MFTREcordNumber,7,2) & StringMid($HEADER_MFTREcordNumber,5,2) & StringMid($HEADER_MFTREcordNumber,3,2) & StringMid($HEADER_MFTREcordNumber,1,2))
;$HEADER_MFTREcordNumber = Dec($HEADER_MFTREcordNumber)
ConsoleWrite("$HEADER_MFTREcordNumber = " & $HEADER_MFTREcordNumber & @crlf)
$NextAttributeOffset = (Dec(StringMid($MFTEntry,43,2))*2)+3
ConsoleWrite("$NextAttributeOffset = " & $NextAttributeOffset & @crlf)
ConsoleWrite("$NextAttributeOffset Hex = 0x" & Hex((($NextAttributeOffset-3)/2)) & @crlf)
$AttributeType = StringMid($MFTEntry,$NextAttributeOffset,8)
ConsoleWrite("$AttributeType = " & $AttributeType & @crlf)
$AttributeSize = StringMid($MFTEntry,$NextAttributeOffset+8,8)
ConsoleWrite("$AttributeSize = " & $AttributeSize & @crlf)
$AttributeSize = Dec(StringMid($AttributeSize,7,2) & StringMid($AttributeSize,5,2) & StringMid($AttributeSize,3,2) & StringMid($AttributeSize,1,2))
;$AttributeSize = Dec($AttributeSize)
ConsoleWrite("$AttributeSize = " & $AttributeSize & @crlf)
$AttributeKnown = 1
While $AttributeKnown = 1
;While $AttributeType <> $ATTRIBUTE_UNKNOWN
;While $NextAttributeOffset < 2048
	$NextAttributeType = StringMid($MFTEntry,$NextAttributeOffset,8)
	ConsoleWrite("$NextAttributeType = " & $NextAttributeType & @crlf)
	$AttributeType = $NextAttributeType
	$AttributeSize = StringMid($MFTEntry,$NextAttributeOffset+8,8)
	$AttributeSize = Dec(StringMid($AttributeSize,7,2) & StringMid($AttributeSize,5,2) & StringMid($AttributeSize,3,2) & StringMid($AttributeSize,1,2))
;	$AttributeSize = Dec($AttributeSize)
	ConsoleWrite("$AttributeSize = " & $AttributeSize & @crlf)
	ConsoleWrite("$NextAttributeOffset Dec = " & $NextAttributeOffset & @crlf)
	ConsoleWrite("$NextAttributeOffset Hex = 0x" & Hex((($NextAttributeOffset-3)/2)) & @crlf)
	Select
		Case $AttributeType = $STANDARD_INFORMATION
			$AttributeKnown = 1
			$STANDARD_INFORMATION_ON = "TRUE"
;			_Get_StandardInformation($MFTEntry,$NextAttributeOffset,$AttributeSize)

		Case $AttributeType = $ATTRIBUTE_LIST
			$AttributeKnown = 1
			$ATTRIBUTE_LIST_ON = "TRUE"
;			_Get_AttributeList()

		Case $AttributeType = $FILE_NAME
			$AttributeKnown = 1
			$FILE_NAME_ON = "TRUE"
			$FN_Number += 1 ; Need to come up with something smarter than this
			If $FN_Number > 4 Then ContinueCase
			_Get_FileName($MFTEntry,$NextAttributeOffset,$AttributeSize,$FN_Number)
			_DisplayInfo("Now processing: " & $FN_FileName & "..." & @crlf)
;			If $FN_FileName = "$LogFile" Then ExitLoop

		Case $AttributeType = $OBJECT_ID
			$AttributeKnown = 1
			$OBJECT_ID_ON = "TRUE"
;			_Get_ObjectID($MFTEntry,$NextAttributeOffset,$AttributeSize)

		Case $AttributeType = $SECURITY_DESCRIPTOR
			$AttributeKnown = 1
			$SECURITY_DESCRIPTOR_ON = "TRUE"
;			_Get_SecurityDescriptor()

		Case $AttributeType = $VOLUME_NAME
			$AttributeKnown = 1
			$VOLUME_NAME_ON = "TRUE"
;			_Get_VolumeName($MFTEntry,$NextAttributeOffset,$AttributeSize)

		Case $AttributeType = $VOLUME_INFORMATION
			$AttributeKnown = 1
			$VOLUME_INFORMATION_ON = "TRUE"
;			_Get_VolumeInformation($MFTEntry,$NextAttributeOffset,$AttributeSize)

		Case $AttributeType = $DATA
			$AttributeKnown = 1
			$DATA_ON = "TRUE"
			$DATA_Number += 1
;			MsgBox(0,"Info","Starting data extract")
			_Get_Data($MFTEntry,$NextAttributeOffset,$AttributeSize,$DATA_Number,$MFTMode)

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
	_DisplayInfo("No $DATA attribute present so nothing to extract for the file: " & $FN_FileName & @crlf)
EndIf
EndFunc

Func _Get_Data($MFTEntry,$DATA_Offset,$DATA_Size,$DATA_Number,$MFTMode)
Local $IsCompressed = 0, $RunListSectorsTotal, $NewRunOffsetBase
Global $RUN_Cluster[1], $RUN_Sectors[1], $RUN_Sparse[1]
If $MFTMode = 2 Then
	Global $MFT_RUN_Cluster[1], $MFT_RUN_Sectors[1], $MFT_RUN_Sparse[1]
EndIf
If $DATA_Number = 1 Then
;ConsoleWrite("$DATA_Size = " & $DATA_Size & @crlf)
$DATA_NonResidentFlag = StringMid($MFTEntry,$DATA_Offset+16,2)
ConsoleWrite("$DATA_NonResidentFlag = " & $DATA_NonResidentFlag & @crlf)
$DATA_NameLength = Dec(StringMid($MFTEntry,$DATA_Offset+18,2))
;$DATA_NameLength = Dec($DATA_NameLength)
ConsoleWrite("$DATA_NameLength = " & $DATA_NameLength & @crlf)
$DATA_NameRelativeOffset = StringMid($MFTEntry,$DATA_Offset+20,4)
ConsoleWrite("$DATA_NameRelativeOffset = " & $DATA_NameRelativeOffset & @crlf)
$DATA_NameRelativeOffset = Dec(StringMid($DATA_NameRelativeOffset,3,2) & StringMid($DATA_NameRelativeOffset,1,2))
;$DATA_NameRelativeOffset = Dec($DATA_NameRelativeOffset)
ConsoleWrite("$DATA_NameRelativeOffset = " & $DATA_NameRelativeOffset & @crlf)
$DATA_Flags = StringMid($MFTEntry,$DATA_Offset+24,4)
$DATA_Flags = StringMid($DATA_Flags,3,2) & StringMid($DATA_Flags,1,2)
ConsoleWrite("$DATA_Flags = " & $DATA_Flags & @crlf)
If BitAND("0x" & $DATA_Flags,0x0001) Then
	$IsCompressed = 1
	_DisplayInfo("Warning: Testing experimental extract of COMPRESSED file" & @crlf)
EndIf
;If BitAND("0x" & $DATA_Flags,0x4000) Then $AHoutput &= 'ENCRYPTED+'
If BitAND("0x" & $DATA_Flags,0x8000) Then
	ConsoleWrite("Error: Can't yet extract sparse files" & @crlf)
	_DisplayInfo("Error: Can't yet extract SPARSE files" & @crlf)
	Return
EndIf
$DATA_Flags = _AttribHeaderFlags("0x" & $DATA_Flags)
ConsoleWrite("$DATA_Flags = " & $DATA_Flags & @crlf)
If $DATA_NameLength > 0 Then
	$DATA_NameSpace = $DATA_NameLength-1
	$DATA_Name = StringMid($MFTEntry,$DATA_Offset+($DATA_NameRelativeOffset*2),($DATA_NameLength+$DATA_NameSpace)*2)
	$DATA_Name = _UnicodeHexToStr($DATA_Name)
EndIf
ConsoleWrite("$DATA_Name = " & $DATA_Name & @crlf)
If $DATA_NonResidentFlag = '01' Then
	$DATA_StartVCN = StringMid($MFTEntry,$DATA_Offset+32,16)
	ConsoleWrite("$DATA_StartVCN = " & $DATA_StartVCN & @crlf)
	$DATA_StartVCN = Dec(StringMid($DATA_StartVCN,15,2) & StringMid($DATA_StartVCN,13,2) & StringMid($DATA_StartVCN,11,2) & StringMid($DATA_StartVCN,9,2) & StringMid($DATA_StartVCN,7,2) & StringMid($DATA_StartVCN,5,2) & StringMid($DATA_StartVCN,3,2) & StringMid($DATA_StartVCN,1,2))
	ConsoleWrite("$DATA_StartVCN = " & $DATA_StartVCN & @crlf)
;	$DATA_StartVCN = Dec($DATA_StartVCN)
;	ConsoleWrite("$DATA_StartVCN = " & $DATA_StartVCN & @crlf)
	$DATA_LastVCN = StringMid($MFTEntry,$DATA_Offset+48,16)
	ConsoleWrite("$DATA_LastVCN = " & $DATA_LastVCN & @crlf)
	$DATA_LastVCN = Dec(StringMid($DATA_LastVCN,15,2) & StringMid($DATA_LastVCN,13,2) & StringMid($DATA_LastVCN,11,2) & StringMid($DATA_LastVCN,9,2) & StringMid($DATA_LastVCN,7,2) & StringMid($DATA_LastVCN,5,2) & StringMid($DATA_LastVCN,3,2) & StringMid($DATA_LastVCN,1,2))
	ConsoleWrite("$DATA_LastVCN = " & $DATA_LastVCN & @crlf)
;	$DATA_LastVCN = Dec($DATA_LastVCN)
;	ConsoleWrite("$DATA_LastVCN = " & $DATA_LastVCN & @crlf)
	$DATA_VCNs = $DATA_LastVCN - $DATA_StartVCN
	ConsoleWrite("$DATA_VCNs = " & $DATA_VCNs & @crlf)
	$DATA_CompressionUnitSize = StringMid($MFTEntry,$DATA_Offset+68,4)
	$DATA_CompressionUnitSize = Dec(StringMid($DATA_CompressionUnitSize,3,2) & StringMid($DATA_CompressionUnitSize,1,2))
;	$DATA_CompressionUnitSize = Dec($DATA_CompressionUnitSize)
	ConsoleWrite("$DATA_CompressionUnitSize = " & $DATA_CompressionUnitSize & @crlf)
	$DATA_AllocatedSize = StringMid($MFTEntry,$DATA_Offset+80,16)
	ConsoleWrite("$DATA_AllocatedSize = " & $DATA_AllocatedSize & @crlf)
	$DATA_AllocatedSize = Dec(StringMid($DATA_AllocatedSize,15,2) & StringMid($DATA_AllocatedSize,13,2) & StringMid($DATA_AllocatedSize,11,2) & StringMid($DATA_AllocatedSize,9,2) & StringMid($DATA_AllocatedSize,7,2) & StringMid($DATA_AllocatedSize,5,2) & StringMid($DATA_AllocatedSize,3,2) & StringMid($DATA_AllocatedSize,1,2))
	ConsoleWrite("$DATA_AllocatedSize = " & $DATA_AllocatedSize & @crlf)
;	$DATA_AllocatedSize = Dec($DATA_AllocatedSize)
;	ConsoleWrite("$DATA_AllocatedSize = " & $DATA_AllocatedSize & @crlf)
	$DATA_RealSize = StringMid($MFTEntry,$DATA_Offset+96,16)
	ConsoleWrite("$DATA_RealSize = " & $DATA_RealSize & @crlf)
	$DATA_RealSize = Dec(StringMid($DATA_RealSize,15,2) & StringMid($DATA_RealSize,13,2) & StringMid($DATA_RealSize,11,2) & StringMid($DATA_RealSize,9,2) & StringMid($DATA_RealSize,7,2) & StringMid($DATA_RealSize,5,2) & StringMid($DATA_RealSize,3,2) & StringMid($DATA_RealSize,1,2))
	ConsoleWrite("$DATA_RealSize = " & $DATA_RealSize & @crlf)
;	$DATA_RealSize = Dec($DATA_RealSize)
;	ConsoleWrite("$DATA_RealSize = " & $DATA_RealSize & @crlf)
	$DATA_InitializedStreamSize = StringMid($MFTEntry,$DATA_Offset+112,16)
	ConsoleWrite("$DATA_InitializedStreamSize = " & $DATA_InitializedStreamSize & @crlf)
	$DATA_InitializedStreamSize = Dec(StringMid($DATA_InitializedStreamSize,15,2) & StringMid($DATA_InitializedStreamSize,13,2) & StringMid($DATA_InitializedStreamSize,11,2) & StringMid($DATA_InitializedStreamSize,9,2) & StringMid($DATA_InitializedStreamSize,7,2) & StringMid($DATA_InitializedStreamSize,5,2) & StringMid($DATA_InitializedStreamSize,3,2) & StringMid($DATA_InitializedStreamSize,1,2))
	ConsoleWrite("$DATA_InitializedStreamSize = " & $DATA_InitializedStreamSize & @crlf)
;	$DATA_InitializedStreamSize = Dec($DATA_InitializedStreamSize)
;	ConsoleWrite("$DATA_InitializedStreamSize = " & $DATA_InitializedStreamSize & @crlf)
	$RunListOffset = StringMid($MFTEntry,$DATA_Offset+64,4)
	ConsoleWrite("$RunListOffset = " & $RunListOffset & @crlf)
	$RunListOffset = StringMid($RunListOffset,3,2) & StringMid($RunListOffset,1,2)
	$RunListOffset = Dec($RunListOffset)
	ConsoleWrite("$RunListOffset = " & $RunListOffset & @crlf)
	If $IsCompressed AND $RunListOffset = 72 Then
		$DATA_CompressedSize = StringMid($MFTEntry,$DATA_Offset+128,16)
		$DATA_CompressedSize = Dec(StringMid($DATA_CompressedSize,15,2) & StringMid($DATA_CompressedSize,13,2) & StringMid($DATA_CompressedSize,11,2) & StringMid($DATA_CompressedSize,9,2) & StringMid($DATA_CompressedSize,7,2) & StringMid($DATA_CompressedSize,5,2) & StringMid($DATA_CompressedSize,3,2) & StringMid($DATA_CompressedSize,1,2))
	EndIf
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
	If $RunListClusterLenght = 0 Then ; Then chunk is sparse
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
		ConsoleWrite("$RunListSectorsTotal = " & $RunListSectorsTotal & @crlf)
		If $RunListSectorsTotal >= $DATA_VCNs+1 Then
			ConsoleWrite("No more data runs." & @crlf)
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
	If $MFTMode = 2 Then
		_ArrayInsert($MFT_RUN_Cluster,1,$RunListCluster)
	EndIf
	_ArrayInsert($RUN_Cluster,1,$RunListCluster)
	ConsoleWrite("$RunListCluster = " & $RunListCluster & @crlf)
	ConsoleWrite("$DATA_VCNs = " & $DATA_VCNs & @crlf)
	If $RunListSectors = $DATA_VCNs+1 Then
		ConsoleWrite("No more data runs." & @crlf)
	Else
		ConsoleWrite("More data runs exist." & @crlf)
		$NewRunOffsetBase = $DATA_Offset+($RunListOffset*2)+2+($RunListSectorsLenght+$RunListClusterLenght)*2
;		_GetAllRuns($MFTEntry,$DATA_Offset,$DATA_Size,$DATA_VCNs,$NewRunOffsetBase)
		_GetAllRuns($MFTEntry,$DATA_Offset,$DATA_Size,$DATA_VCNs,$RunListOffset,$MFTMode,$IsCompressed)
	EndIf
	If $MFTMode = 2 Then Return
	_ReassembleDataRuns($DATA_VCNs,$IsCompressed)

ElseIf $DATA_NonResidentFlag = '00' Then
	ConsoleWrite("Processing resident data." & @crlf)
	$DATA_LengthOfAttribute = StringMid($MFTEntry,$DATA_Offset+32,8)
	ConsoleWrite("$DATA_LengthOfAttribute = " & $DATA_LengthOfAttribute & @crlf)
	$DATA_LengthOfAttribute = Dec(StringMid($DATA_LengthOfAttribute,7,2) & StringMid($DATA_LengthOfAttribute,5,2) & StringMid($DATA_LengthOfAttribute,3,2) & StringMid($DATA_LengthOfAttribute,1,2))
	ConsoleWrite("$DATA_LengthOfAttribute = " & $DATA_LengthOfAttribute & @crlf)
;	$DATA_LengthOfAttribute = Dec($DATA_LengthOfAttribute)
	$DATA_OffsetToAttribute = StringMid($MFTEntry,$DATA_Offset+40,4)
	$DATA_OffsetToAttribute = Dec(StringMid($DATA_OffsetToAttribute,3,2) & StringMid($DATA_OffsetToAttribute,1,2))
	ConsoleWrite("$DATA_OffsetToAttribute = " & $DATA_OffsetToAttribute & @crlf)
;	$DATA_OffsetToAttribute = Dec($DATA_OffsetToAttribute)
	$DATA_IndexedFlag = Dec(StringMid($MFTEntry,$DATA_Offset+44,2))
;	$DATA_IndexedFlag = Dec($DATA_IndexedFlag)
	If $DATA_LengthOfAttribute = 0 Then Return
	_ReassembleResidentData($MFTEntry,$DATA_Offset,$DATA_LengthOfAttribute,$IsCompressed)
EndIf
EndIf
EndFunc

Func _GetAllRuns($MFTEntry,$DATA_Offset,$DATA_Size,$DATA_VCNs,$RunListOffset,$MFTMode,$IsCompressed)
Local $RunListClusterNext, $RunListSectorsTotal, $NewRunOffsetBase
ConsoleWrite("Started function _GetAllRuns()" & @crlf)
Global $RUN_Cluster[1], $RUN_Sectors[1], $RUN_Sparse[1]
If $MFTMode = 2 Then
	Global $MFT_RUN_Cluster[1], $MFT_RUN_Sectors[1], $MFT_RUN_Sparse[1]
EndIf
$RunListID = StringMid($MFTEntry,$DATA_Offset+($RunListOffset*2),2)
ConsoleWrite("$RunListID = " & $RunListID & @crlf)
$RunListSectorsLenght = Dec(StringMid($RunListID,2,1))
ConsoleWrite("$RunListSectorsLenght = " & $RunListSectorsLenght & @crlf)
$RunListClusterLenght = Dec(StringMid($RunListID,1,1))
ConsoleWrite("$RunListClusterLenght = " & $RunListClusterLenght & @crlf)
$RunListSectors = StringMid($MFTEntry,$DATA_Offset+($RunListOffset*2)+2,$RunListSectorsLenght*2)
ConsoleWrite("$RunListSectors = " & $RunListSectors & @crlf)
$r = 1
If $RunListClusterLenght = 0 Then ;Then chunk is sparse
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
	ConsoleWrite("$RunListSectorsTotal = " & $RunListSectorsTotal & @crlf)
	If $RunListSectorsTotal >= $DATA_VCNs+1 Then
		ConsoleWrite("No more data runs." & @crlf)
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
ConsoleWrite("$RunListSectors = " & $RunListSectors & @crlf)
If $MFTMode = 2 Then
	_ArrayInsert($MFT_RUN_Sectors,1,$RunListSectors)
	_ArrayInsert($MFT_RUN_Sparse,1,0)
EndIf
_ArrayInsert($RUN_Sectors,1,$RunListSectors)
_ArrayInsert($RUN_Sparse,1,0)
$RunListCluster = StringMid($MFTEntry,$DATA_Offset+($RunListOffset*2)+2+($RunListSectorsLenght*2),$RunListClusterLenght*2)
ConsoleWrite("$RunListCluster = " & $RunListCluster & @crlf)
$entry = ''
For $u = 0 To $RunListClusterLenght-1
	$mod = StringMid($RunListCluster,($RunListClusterLenght*2)-(($u*2)+1),2)
	$entry &= $mod
Next
$RunListCluster = Dec($entry)
ConsoleWrite("$RunListCluster = " & $RunListCluster & @crlf)
If $MFTMode = 2 Then
	_ArrayInsert($MFT_RUN_Cluster,1,$RunListCluster)
EndIf
_ArrayInsert($RUN_Cluster,1,$RunListCluster)
If $RunListSectors = $DATA_VCNs+1 Then
	ConsoleWrite("No more data runs." & @crlf)
	Return
EndIf
$NewRunOffsetBase = $DATA_Offset+($RunListOffset*2)+2+($RunListSectorsLenght+$RunListClusterLenght)*2
ConsoleWrite("$NewRunOffsetBase = " & $NewRunOffsetBase & @crlf)
ConsoleWrite("$DATA_VCNs = " & $DATA_VCNs & @crlf)
$RunListSectorsTotal = $RunListSectors
While $RunListSectors < $DATA_VCNs+1
	$r += 1
	ConsoleWrite("$r = " & $r & @crlf)
	$RunListID = StringMid($MFTEntry,$NewRunOffsetBase,2)
	ConsoleWrite("$RunListID = " & $RunListID & @crlf)
	$RunListSectorsLenght = Dec(StringMid($RunListID,2,1))
	ConsoleWrite("$RunListSectorsLenght = " & $RunListSectorsLenght & @crlf)
	$RunListClusterLenght = Dec(StringMid($RunListID,1,1))
	ConsoleWrite("$RunListClusterLenght = " & $RunListClusterLenght & @crlf)
	$RunListSectors = StringMid($MFTEntry,$NewRunOffsetBase+2,$RunListSectorsLenght*2)
	ConsoleWrite("$RunListSectors = " & $RunListSectors & @crlf)
	If $RunListClusterLenght = 0 Then; Then chunk is sparse
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
		ConsoleWrite("$RunListSectorsTotal = " & $RunListSectorsTotal & @crlf)
		If $RunListSectorsTotal >= $DATA_VCNs+1 Then
			ConsoleWrite("No more data runs." & @crlf)
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
	ConsoleWrite("$RunListSectors = " & $RunListSectors & @crlf)
	If $MFTMode = 2 Then
		_ArrayInsert($MFT_RUN_Sectors,$r,$RunListSectors)
		_ArrayInsert($MFT_RUN_Sparse,$r,0)
	EndIf
	_ArrayInsert($RUN_Sectors,$r,$RunListSectors)
	_ArrayInsert($RUN_Sparse,$r,0)
	$RunListCluster = StringMid($MFTEntry,$NewRunOffsetBase+2+($RunListSectorsLenght*2),$RunListClusterLenght*2)
	ConsoleWrite("$RunListCluster = " & $RunListCluster & @crlf)
	$NegativeMove = 0
;Here we must read to check positive/negative relative move
	If Dec(StringMid($RunListCluster,StringLen($RunListCluster)-1,1)) > 7 Then
		$NegativeMove = 1
	EndIf
	ConsoleWrite("$NegativeMove = " & $NegativeMove & @crlf)
	$entry = ''
	For $u = 0 To $RunListClusterLenght-1
		$mod = StringMid($RunListCluster,($RunListClusterLenght*2)-(($u*2)+1),2)
	$entry &= $mod
	Next
	ConsoleWrite("$entry = " & $entry & @crlf)
	$RunListCluster = Dec($entry)
	ConsoleWrite("$RunListCluster = " & $RunListCluster & @crlf)
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
	ConsoleWrite("$RunListClusterNext = " & $RunListClusterNext & @crlf)
	If $MFTMode = 2 Then
		_ArrayInsert($MFT_RUN_Cluster,$r,$RunListClusterNext)
	EndIf
	_ArrayInsert($RUN_Cluster,$r,$RunListClusterNext)
	$RunListSectorsTotal += $RunListSectors
	ConsoleWrite("$RunListSectorsTotal = " & $RunListSectorsTotal & @crlf)
	If $RunListSectorsTotal = $DATA_VCNs+1 Then
		ConsoleWrite("No more data runs." & @crlf)
		Return
	EndIf
	$NewRunOffsetBase = $NewRunOffsetBase+2+($RunListSectorsLenght+$RunListClusterLenght)*2
	ConsoleWrite("$NewRunOffsetBase = " & $NewRunOffsetBase & @crlf)
WEnd
ConsoleWrite("DataRuns: Error - Something must have gone wrong. Should not be here..." & @crlf)
_DisplayInfo("DataRuns: Error - Something must have gone wrong. Should not be here..." & @crlf)
Return
EndFunc

Func _ReassembleDataRuns($DATA_VCNs, $IsCompressed)
Local $Decompressed, $FileName, $NextSector1, $NextSector2, $MFTTotalRuns, $TotalRuns
ConsoleWrite("Starting _ReassembleDataRuns()" & @crlf)
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
_ArrayDelete($RUN_Complete,1) ;Deleting left over
If GUICtrlRead($checkRuns) = 1 Then
	_ArrayDisplay($MFT_RUN_Complete,"MFT_RUN_Complete")
	_ArrayDisplay($RUN_Complete,"RUN_Complete")
EndIf
;$testfile = _WinAPI_CreateFile(@ScriptDir & "\" & $FN_FileName & ".bin",3,6,7)
If $FN_NameType = 'DOS' Then
	$FileName = $FN_FileName_2
Else
	$FileName = $FN_FileName
EndIf
If $FileName = "" Then $FileName = "dummy.bin"
$testfile = _WinAPI_CreateFile($outputpath & "\" & $FileName,3,6,7)
If $testfile = 0 Then
	_DisplayInfo("Error in function _WinAPI_CreateFile for: " & $outputpath & "\" & $FileName & @crlf)
	Return
EndIf
ConsoleWrite("$testfile = " & $testfile & @crlf)
#cs
If $IsCompressed = 1 Then
	$DATA_RealSize = $DATA_CompressedSize
EndIf
#ce
_WinAPI_SetFilePointer($testfile, $DATA_RealSize)
_WinAPI_SetEndOfFile($testfile)
_WinAPI_FlushFileBuffers($testfile)
_WinAPI_SetFilePointer($testfile, 0,$FILE_BEGIN)
$TargetOff = 0
$PlusSector = 0
If $DATA_RealSize <> $DATA_AllocatedSize Then
	$SlackPresent = 1
	$SlackSize = $DATA_AllocatedSize-$DATA_RealSize
Else;If $DATA_RealSize = $DATA_AllocatedSize Then
	$SlackPresent = 0
	$SlackSize = 0
EndIf
ConsoleWrite("$SlackSize = " & $SlackSize & @crlf)
For $runs = 1 To Ubound($RUN_Cluster)-1
	ConsoleWrite("Run " & $runs & " reassembling.." & @crlf)
	_DisplayInfo("Run " & $runs & " reassembling.." & @crlf)
	$StructSize = $RUN_Sectors[$runs]*$SectorsPerCluster*512
	$MaxStructSize = 40000000 ; Max size of chunk to put into memory
	If $runs = Ubound($RUN_Cluster)-1 Then
		$StructSize = $StructSize-$SlackSize
	EndIf
	If $StructSize > $MaxStructSize Then ; Compare size of run against a preconfiured max value
		$aa = $StructSize/$MaxStructSize
		$ab = Ceiling($aa)
		$ac = $aa-Floor($aa)
		$remainder = $ac*$MaxStructSize
		$ba = $SlackSize/512
		$bc = $ba-Floor($ba)
		$remainder1 = 512-($bc*512)
		_DisplayInfo("File needs to be extracted in pieces" & @CRLF)
		For $StructFix = 1 To $ab
			If $StructFix = $ab Then
				$NewStructSizeWrite = $remainder
				$NewStructSize = $remainder+(512-$remainder1)
			Else
				$NewStructSizeWrite = $MaxStructSize
				$NewStructSize = $MaxStructSize
			EndIf
			ConsoleWrite("$NewStructSize = " & $NewStructSize & @crlf)
			ConsoleWrite("$NewStructSizeWrite = " & $NewStructSizeWrite & @crlf)
			$tBuffer1 = DllStructCreate("byte[" & $NewStructSize & "]")
			If $StructFix = 1 Then $PlusSector = 0
			_WinAPI_SetFilePointerEx($hFile, ($RUN_Cluster[$runs]*$SectorsPerCluster*512)+($PlusSector),$FILE_BEGIN)
			_WinAPI_ReadFile($hFile, DllStructGetPtr($tBuffer1), $NewStructSize, $nBytes)
			$MFTFragment1 = DllStructGetData($tBuffer1, 1)
			ConsoleWrite("Size of buffer = " & DllStructGetSize($tBuffer1) & " for piece number: " & $StructFix & @crlf)
			_DisplayInfo("Size of buffer = " & DllStructGetSize($tBuffer1) & " for piece number: " & $StructFix & @crlf)
			If $IsCompressed AND ($NewStructSize > 0) AND (StringMid($MFTFragment1,5,1)='B') Then
				$Decompressed = _LZNTDecompress($MFTFragment1)
				If $Decompressed[0] = "" Then
					$Decompressed[1] = 0
				Else
					Local $DecompBuffer = DllStructCreate("byte[" & $Decompressed[1] & "]")
					DllStructSetData($DecompBuffer, 1, $Decompressed[0])
; For testing the of extracted data without decompression
;					Local $DecompBuffer = DllStructCreate("byte[" & BinaryLen($MFTFragment1) & "]")
;					DllStructSetData($DecompBuffer, 1, $MFTFragment1)
				EndIf
				_WinAPI_WriteFile($testfile, DllStructGetPtr($DecompBuffer), DllStructGetSize($DecompBuffer), $nBytes)
				_WinAPI_FlushFileBuffers($testfile)
				$PlusSector += $Decompressed[1]
				$TargetOff += $Decompressed[1]
			Else
				_WinAPI_WriteFile($testfile, DllStructGetPtr($tBuffer1), $NewStructSizeWrite, $nBytes)
				_WinAPI_FlushFileBuffers($testfile)
				$PlusSector += $NewStructSize
				$TargetOff += $NewStructSize
			EndIf
			_WinAPI_SetFilePointer($testfile, $TargetOff,$FILE_BEGIN)
		Next
	EndIf
	If $StructSize <= $MaxStructSize Then
		$ba = $SlackSize/512
		$bc = $ba-Floor($ba)
		$remainder1 = 512-($bc*512)
		If $runs = Ubound($RUN_Cluster)-1 Then
			$NewStructSizeWrite = $StructSize
			$NewStructSize = $StructSize+(512-$remainder1)
		Else
			$NewStructSizeWrite = $StructSize
			$NewStructSize = $StructSize
		EndIf
		$tBuffer1 = DllStructCreate("byte[" & $NewStructSize & "]")
		_WinAPI_SetFilePointerEx($hFile, $RUN_Cluster[$runs]*$SectorsPerCluster*512,$FILE_BEGIN)
		_WinAPI_ReadFile($hFile, DllStructGetPtr($tBuffer1), $NewStructSize, $nBytes)
		$MFTFragment1 = DllStructGetData($tBuffer1, 1)
		ConsoleWrite("DllStructGetData" & @crlf)
		ConsoleWrite("Size of buffer = " & DllStructGetSize($tBuffer1) & @crlf)
		_DisplayInfo("Size of buffer = " & DllStructGetSize($tBuffer1) & @crlf)
		If $IsCompressed AND ($NewStructSize > 0) AND (StringMid($MFTFragment1,5,1)='B') Then; each block is preceded by a 2-byte length. The lower twelve bits are the >length, the higher 4 bits are of unknown purpose
			$Decompressed = _LZNTDecompress($MFTFragment1)
			If $Decompressed[0] = "" Then
				$Decompressed[1] = 0
			Else
				Local $DecompBuffer = DllStructCreate("byte[" & $Decompressed[1] & "]")
				DllStructSetData($DecompBuffer, 1, $Decompressed[0])
; For testing the of extracted data without decompression
;				Local $DecompBuffer = DllStructCreate("byte[" & BinaryLen($MFTFragment1) & "]")
;				DllStructSetData($DecompBuffer, 1, $MFTFragment1)
			EndIf
			_WinAPI_WriteFile($testfile, DllStructGetPtr($DecompBuffer), DllStructGetSize($DecompBuffer), $nBytes)
			_WinAPI_FlushFileBuffers($testfile)
			$PlusSector += $Decompressed[1]
			$TargetOff += $Decompressed[1]
		Else
			_WinAPI_WriteFile($testfile, DllStructGetPtr($tBuffer1), $NewStructSizeWrite, $nBytes)
			_WinAPI_FlushFileBuffers($testfile)
			$TargetOff += $RUN_Sectors[$runs]*$SectorsPerCluster*512
		EndIf
		_WinAPI_SetFilePointer($testfile, $TargetOff,$FILE_BEGIN)
	EndIf
Next
_WinAPI_CloseHandle($testfile)
_DisplayInfo("Successfully extracted target file: " & $FileName & " to " & $outputpath & "\" & $FileName  & @CRLF)
_DisplayInfo("Size of extracted " & $FileName & " is " & $DATA_RealSize & " bytes" & @CRLF)
Return
EndFunc

Func _ReassembleResidentData($MFTEntry,$DATA_Offset,$ResidentSize,$IsCompressed) ;in blocks of 512 byte if using ReadFile
Local $FileName
ConsoleWrite("Starting _ReassembleResidentData()" & @crlf)
;$testfile = _WinAPI_CreateFile(@ScriptDir & "\" & $FN_FileName & ".bin",3,6,7)
If $FN_NameType = 'DOS' Then
	$FileName = $FN_FileName_2
Else
	$FileName = $FN_FileName
EndIf
$testfile = _WinAPI_CreateFile($outputpath & "\" & $FileName,3,6,7)
If $testfile = 0 Then
	_DisplayInfo("Error in function _WinAPI_CreateFile for: " & $outputpath & "\" & $FileName & @crlf)
	Return
EndIf
ConsoleWrite("$testfile = " & $testfile & @crlf)
_WinAPI_SetFilePointer($testfile, $ResidentSize)
_WinAPI_SetEndOfFile($testfile)
_WinAPI_FlushFileBuffers($testfile)
_WinAPI_SetFilePointer($testfile, 0,$FILE_BEGIN)
;$tBuffer = DllStructCreate("byte[" & ($RUN_Sectors[$runs]*$SectorsPerCluster*512) & "]")
$tBuffer = DllStructCreate("byte[" & $ResidentSize & "]")
;_WinAPI_ReadFile($hFile, DllStructGetPtr($tBuffer), ($RUN_Sectors[$runs]*$SectorsPerCluster*512), $nBytes)
;_WinAPI_ReadFile($hFile, DllStructGetPtr($tBuffer), $DATA_Offset+48, $nBytes)
;$MFTFragment1 = DllStructGetData($tBuffer, 1)
DllStructSetData($tBuffer, 1, '0x' & StringMid($MFTEntry,$DATA_Offset+48,($ResidentSize*2)))
ConsoleWrite("Size of buffer = " & DllStructGetSize($tBuffer) & @crlf)
;_DisplayInfo("Size of buffer = " & DllStructGetSize($tBuffer) & @crlf)
_WinAPI_WriteFile($testfile, DllStructGetPtr($tBuffer), DllStructGetSize($tBuffer), $nBytes)
_WinAPI_FlushFileBuffers($testfile)
_WinAPI_CloseHandle($testfile)
_DisplayInfo("Successfully extracted target file: " & $FileName & " to " & $outputpath & "\" & $FileName  & @CRLF)
_DisplayInfo("Size of extracted " & $FileName & " is " & $ResidentSize & " bytes" & @CRLF)

EndFunc

Func _Get_StandardInformation($MFTEntry,$SI_Offset,$SI_Size)
;Not really needed in this app
Return
EndFunc

Func _Get_FileName($MFTEntry,$FN_Offset,$FN_Size,$FN_Number)
If $FN_Number = 1 Then
	$FN_AllocSize = StringMid($MFTEntry,$FN_Offset+128,16)
	$FN_AllocSize = Dec(StringMid($FN_AllocSize,15,2) & StringMid($FN_AllocSize,13,2) & StringMid($FN_AllocSize,11,2) & StringMid($FN_AllocSize,9,2) & StringMid($FN_AllocSize,7,2) & StringMid($FN_AllocSize,5,2) & StringMid($FN_AllocSize,3,2) & StringMid($FN_AllocSize,1,2))
	;$FN_AllocSize = Dec($FN_AllocSize)
	ConsoleWrite("$FN_AllocSize = " & $FN_AllocSize & @crlf)
	$FN_RealSize = StringMid($MFTEntry,$FN_Offset+144,16)
	$FN_RealSize = Dec(StringMid($FN_RealSize,15,2) & StringMid($FN_RealSize,13,2) & StringMid($FN_RealSize,11,2) & StringMid($FN_RealSize,9,2) & StringMid($FN_RealSize,7,2) & StringMid($FN_RealSize,5,2) & StringMid($FN_RealSize,3,2) & StringMid($FN_RealSize,1,2))
	;$FN_RealSize = Dec($FN_RealSize)
	ConsoleWrite("$FN_RealSize = " & $FN_RealSize & @crlf)
	$FN_NameLength = StringMid($MFTEntry,$FN_Offset+176,2)
	$FN_NameLength = Dec($FN_NameLength)
	ConsoleWrite("$FN_NameLength = " & $FN_NameLength & @crlf)
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
		Case Else ;$FN_NameType <> '00' AND $FN_NameType <> '01' AND $FN_NameType <> '02' AND $FN_NameType <> '03'
			$FN_NameType = 'UNKNOWN'
	EndSelect
	ConsoleWrite("$FN_NameType = " & $FN_NameType & @crlf)
	$FN_NameSpace = $FN_NameLength-1 ;Not really
	ConsoleWrite("$FN_NameSpace = " & $FN_NameSpace & @crlf)
	$FN_FileName = StringMid($MFTEntry,$FN_Offset+180,($FN_NameLength+$FN_NameSpace)*2)
	ConsoleWrite("$FN_FileName = " & $FN_FileName & @crlf)
	$FN_FileName = _UnicodeHexToStr($FN_FileName)
	ConsoleWrite("$FN_FileName = " & $FN_FileName & @crlf)
	If StringLen($FN_FileName) <> $FN_NameLength Then $INVALID_FILENAME = 1
EndIf
If $FN_Number = 2 Then;Not really needed
	$FN_AllocSize_2 = StringMid($MFTEntry,$FN_Offset+128,16)
	$FN_AllocSize_2 = Dec(StringMid($FN_AllocSize_2,15,2) & StringMid($FN_AllocSize_2,13,2) & StringMid($FN_AllocSize_2,11,2) & StringMid($FN_AllocSize_2,9,2) & StringMid($FN_AllocSize_2,7,2) & StringMid($FN_AllocSize_2,5,2) & StringMid($FN_AllocSize_2,3,2) & StringMid($FN_AllocSize_2,1,2))
	$FN_RealSize_2 = StringMid($MFTEntry,$FN_Offset+144,16)
	$FN_RealSize_2 = Dec(StringMid($FN_RealSize_2,15,2) & StringMid($FN_RealSize_2,13,2) & StringMid($FN_RealSize_2,11,2) & StringMid($FN_RealSize_2,9,2) & StringMid($FN_RealSize_2,7,2) & StringMid($FN_RealSize_2,5,2) & StringMid($FN_RealSize_2,3,2) & StringMid($FN_RealSize_2,1,2))
	$FN_NameLength_2 = StringMid($MFTEntry,$FN_Offset+176,2)
	$FN_NameLength_2 = Dec($FN_NameLength_2)
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
	$FN_FileName_2 = StringMid($MFTEntry,$FN_Offset+180,($FN_NameLength_2+$FN_NameSpace_2)*2)
	$FN_FileName_2 = _UnicodeHexToStr($FN_FileName_2)
	If StringLen($FN_FileName_2) <> $FN_NameLength_2 Then $INVALID_FILENAME_2 = 1
EndIf
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
	$DATA_LengthOfAttribute = ""
	$DATA_OffsetToAttribute = ""
	$DATA_IndexedFlag = ""
	$DATA_LengthOfAttribute_2 = ""
	$DATA_OffsetToAttribute_2 = ""
	$DATA_IndexedFlag_2 = ""
	$DATA_CompressionUnitSize = ""
	$DATA_CompressionUnitSize_2 = ""
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
	$RunListSectorsTotal = ""
	$RunListSectors = ""
	$DATA_VCNs = ""
	$RunListID = ""
	$RunListSectorsLenght = ""
	$RunListSectors = ""
	$RunListCluster = ""
	$RunListSectorsTotal = ""
	$NewRunOffsetBase = ""
	$FN_Number = ""
	$DATA_Number = ""
	$DATA_CompressedSize = ""
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

Func _UnicodeHexToStr($UnicodeHex)
Local $UniConv
For $space = 1 To StringLen($UnicodeHex)
	$tmp = StringMid($UnicodeHex,$space,2)
	$space += 3
	$UniConv &= $tmp
Next
$UniConv = _HexToString($UniConv)
Return $UniConv
EndFunc


; #FUNCTION# ;===============================================================================
;
; Name...........: _LZNTDecompress
; Description ...: Decompresses input data.
; Syntax.........: _LZNTDecompress ($bBinary)
; Parameters ....: $vInput - Binary data to decompress.
; Return values .: Success - Returns decompressed binary data.
;                          - Sets @error to 0
;                  Failure - Returns empty string and sets @error:
;                  |1 - Error decompressing.
; Author ........: trancexx
; Related .......: _LZNTCompress
; Link ..........; http://msdn.microsoft.com/en-us/library/bb981784.aspx
;
;==========================================================================================
Func _LZNTDecompress($bBinary)
	Local $tOutput[2]
	If NOT IsBinary($bBinary) Then
		$bBinary = Binary($bBinary)
    EndIf
;	ConsoleWrite("BinaryLen($bBinary): " & BinaryLen($bBinary) & @CRLF)
    Local $tInput = DllStructCreate("byte[" & BinaryLen($bBinary) & "]")
    DllStructSetData($tInput, 1, $bBinary)
;	ConsoleWrite("DllStructGetData($tInput, 1): " & DllStructGetData($tInput, 1) & @CRLF)
;	ConsoleWrite("DllStructGetSize($tInput): " & DllStructGetSize($tInput) & @CRLF)
	$newsize = 16 * DllStructGetSize($tInput)
    Local $tBuffer = DllStructCreate("byte[" & $newsize & "]") ; initially oversizing buffer
;	ConsoleWrite("DllStructGetSize($tBuffer): " & DllStructGetSize($tBuffer) & @CRLF)
    Local $a_Call = DllCall("ntdll.dll", "int", "RtlDecompressBuffer", _
            "ushort", 2, _
            "ptr", DllStructGetPtr($tBuffer), _
            "dword", DllStructGetSize($tBuffer), _
            "ptr", DllStructGetPtr($tInput), _
            "dword", DllStructGetSize($tInput), _
            "dword*", 0)

    If @error Or $a_Call[0] Then
        Return SetError(1, 0, "") ; error decompressing
    EndIf
    Local $Decompressed = DllStructCreate("byte[" & $a_Call[6] & "]", DllStructGetPtr($tBuffer))
;	ConsoleWrite("DllStructGetSize($Decompressed): " & DllStructGetSize($Decompressed) & @CRLF)
	$tOutput[0] = DllStructGetData($Decompressed, 1)
	$tOutput[1] = DllStructGetSize($Decompressed)
    Return SetError(0, 0, $tOutput)

EndFunc   ;==>_LZNTDecompress

Func NT_SUCCESS($status)
    If 0 <= $status And $status <= 0x7FFFFFFF Then
        Return True
    Else
        Return False
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
Local $IsDirectory = 0
Global $BrowsedFile = FileOpenDialog("Select file",@ScriptDir,"All (*.*)")
If @error Then Return
$bIndexNumber = _GetIndexNumber($BrowsedFile,$IsDirectory)
If @error Then
	_DisplayInfo("Error: Something went wrong when retrieving the IndexNumber of file." & @CRLF)
	Return
EndIf
_DisplayInfo("Target file has IndexNumber: " & $bIndexNumber & @CRLF)
_ExtractSystemfile(2,_DecToLittleEndian($bIndexNumber),1)
EndFunc

Func _DecToLittleEndian($DecimalInput)
Local $dec = Hex($DecimalInput,8)
$dec = StringMid($dec,7,2) & StringMid($dec,5,2) & StringMid($dec,3,2) & StringMid($dec,1,2)
Return $dec
EndFunc
; This SwapEndian function was made to workaround 32-bit AutoIt limitation
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
; Original SwapEndian function
Func _SwapEndianNew($Data)
    Return Hex(Binary($Data))
EndFunc