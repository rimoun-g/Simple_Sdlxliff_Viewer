#NoTrayIcon
#include <Array.au3>
#include <File.au3>
#include <Clipboard.au3>
#include <GUIConstantsEx.au3>


Local $file = ""


If $CmdLine[0] > 0 Then
    $file = ($CmdLine[1])
EndIf

$text = ""



; make sure file is not empty and its extension is sdlxliff
if $file <> "" AND StringLower(StringRight($file,8))= "sdlxliff" Then

	_FileReadToArray($file, $text)
; read file to array to get the first line to extract the information with regex

;read the last line only to extract segments
		$lines = FileReadLine($file,-1)

; extract the original file
if Ubound ($text) > 1 Then
#Region
$srcfile = StringRegExp($text[1],'original="(.*)(\.)(\w+)"',3)

if UBound($srcfile) > 1 Then
	$org = StringReplace(_ArrayToString($srcfile,""),"&amp;","&")
Else
	$org = "Not Found"
EndIf

#EndRegion

; extract the source language
#Region
$srclang = StringRegExp($text[1],'source-language="(\w+)-(\w+)"',3)


if UBound($srclang) > 1 Then
	$srlang = _ArrayToString($srclang,"-")
Else
	$srlang = "Not Found"
EndIf
#EndRegion


; extract the target language
#Region
$tgtlang = StringRegExp($text[1],'target-language="(\w+)-(\w+)"',3)

if UBound($tgtlang) > 1 Then
	$tglang = _ArrayToString($tgtlang,"-")
Else
	$tglang = "Not Found"
EndIf
#EndRegion

; extract username who created the file
#Region
Local $createdByName = "Not found"
 $CreatedBy = StringRegExp($lines,'(key="created_by">)(.*?)(</(\w+):(\w+)>)',3)
if UBound($CreatedBy) > 1 Then $createdByName = $CreatedBy[1]

;~ MsgBox(0,"",$createdByName)

#EndRegion

;extract the date of creation
#Region
Local $CreatedOn = "Not found"
 $CreatedOn = StringRegExp($lines,'(key="created_on">)(.*?)(</(\w+):(\w+)>)',3)

if UBound($CreatedOn) > 1 Then  $CreatedOn = $CreatedOn[1]

;~ MsgBox(0,"",$CreatedOn)

#EndRegion



#Region


; extract the segments through Microsoft XML Reader , and save the source in an array and the target in a differrent array
; then the target and source are mixed based on the number of sgements in the source
; before mixing them we add the information we extracted previously to the begining of the array
; Note the _ArrayDisplay() function has a limit of char per cell, so its unreliable to show full content of the sgements

Local $oXML = ObjCreate("Microsoft.XMLDOM")
$oXML.load($file)
Local $arr = []
Local $newarr = []

Local $finalArr = []


$sourceSegs = $oXML.SelectNodes("//source")

$targetSegs = $oXML.SelectNodes("//target")
For $i in $sourceSegs
		if $i.text <> ""  Then _ArrayAdd($arr, $i.text)
Next

For $i in $targetSegs
		if $i.text <> ""  Then _ArrayAdd($newarr, $i.text)
Next

_ArrayAdd($finalArr,"The **approximate** number of Segements is: ± " & (Ubound($arr) -1))
_ArrayAdd($finalArr,"The original file: '" & $org)
_ArrayAdd($finalArr,"The Language pair is : " & $srlang & " > " & $tglang)
_ArrayAdd($finalArr,"Created By : " & $createdByName)
_ArrayAdd($finalArr,"Created On : " & $CreatedOn)
_ArrayAdd($finalArr,"///////////////////////////////////////// Random Segments \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\" )

For $i = 1 To Ubound($arr) - 1

_arrayadd($finalArr, $arr[$i])
if Ubound($newarr) > $i then  _arrayadd($finalArr, $newarr[$i])
Next


_ArrayDisplay($finalArr,$file,"")

#EndRegion

EndIf
Else
	MsgBox(16,"Error","Invalid File")
EndIf