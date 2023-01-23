#NoTrayIcon
#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Version=Beta
#AutoIt3Wrapper_Icon=icon.ico
#AutoIt3Wrapper_Res_Fileversion=0.0.0.1
#AutoIt3Wrapper_Res_Fileversion_AutoIncrement=p
#AutoIt3Wrapper_Res_ProductName=WG2MT
#AutoIt3Wrapper_Res_ProductVersion=0.0.0.1
#AutoIt3Wrapper_Res_Language=1058
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
#pragma compile(Out, WG2MT.exe)
##pragma compile(Icon, image/Setting_ico.ico)
;~ #pragma compile(UPX, True)  ; Commented out by AutoIt3Wrapper to be able to do the requested resource updates
#pragma compile(FileDescription, 'dima101097')
#pragma compile(Fileversion, 0.0.0.7)
FileChangeDir(@ScriptDir)
#include <GUIConstants.au3>
#include <Array.au3>
global $iFolder
GUICreate( "WireGuard2MikroTik", 400, 100 )
   GUICtrlCreateLabel ("Wireguard config:", 10, 30)
   Global $iFolders = GUICtrlCreateInput ($iFolder, 100, 25, 200)
   $folderChoose = GUICtrlCreateButton("Вибрати", 310, 23, 50, 25)
   $next= GUICtrlCreateButton("Далі", 10, 60, 50, 25)
GUISetState(@SW_SHOW)

Do
  $gMsg = GUIGetMsg()
   Switch $gMsg
		Case $folderChoose
			    GUICtrlSetData($iFolders, FileOpenDialog("Вкажіть файл конфігурації WireGuard", @WorkingDir & "\", "Конфігурація WireGuard (*.conf)", 1))
		Case $next
		   _next(GUICtrlRead($iFolders))
		Case $GUI_EVENT_CLOSE
	ExitLoop

   EndSwitch
Until $gMsg = $GUI_EVENT_CLOSE



Func _next ($iFolders)
	$save_file = FileSaveDialog("Папка збереження.", @ScriptDir, " MikroTik (*.rsc)", 2)
If @error Then
    MsgBox(4096, "", "Збереження відмінено.")
Else
    _toScript ($save_file,$iFolders)
EndIf
EndFunc


Func _toScript ($save_file, $iFolders)
	$localAdres = _regexp(IniRead ($iFolders,"Interface", "Address", ""),'[0-9]{0,3}\.[0-9]{0,3}\.[0-9]{0,3}\.[0-9]{0,3}')
	$PrivatKey =  IniRead ($iFolders,"Interface", "PrivateKey", "")
	$ListenPort = IniRead ($iFolders,"Interface", "ListenPort", "")
	$DNS = IniRead ($iFolders,"Interface", "DNS", "")

	$PublicKey = IniRead ($iFolders,"Peer", "PublicKey", "")
	$PresharedKey = IniRead ($iFolders,"Peer", "PresharedKey", "")
	$Endpoint = IniRead ($iFolders,"Peer", "Endpoint", "")
	$EndpointIP=_regexp($Endpoint,'(?:[a-z0-9](?:[a-z0-9-]{0,61}[a-z0-9])?\.)+[a-z0-9][a-z0-9-]{0,61}[a-z0-9]')
	$EndpointPort= _regexp($Endpoint,'\d{1,5}$')
	$AllowedIPs = IniRead ($iFolders,"Peer", "AllowedIPs", "")

	;$wgName = _regexp($save_file,'[A-Za-z0-9\.]{0,100}\.rsc$')
	$wgName = _regexp($save_file,'([^.\\]+)\.')
	if $EndpointPort = "" Then $EndpointPort = $ListenPort
	if $ListenPort = "" Then $ListenPort = $EndpointPort

	;MsgBox(0,"", "Local IP: " & $localAdres & @CR & "Listen PORT: " & $ListenPort & @CR & "DNS: " & $DNS & @CR & "Private KEY: " & $PrivatKey & @CR  & @CR & "Host IP/Domen: " & $EndpointIP & @CR & "Host PORT: " & $EndpointPort & @CR & "Allowed IPs: " & $AllowedIPs & @CR & "Public KEY: " & $PublicKey & @CR & "Preshared KEY: " & $PresharedKey,5)


	$hFile = FileOpen($save_file, 2)
	$sCode ='/interface wireguard add listen-port=' & $ListenPort & ' name="'& $wgName&'"' & ' private-key="' & $PrivatKey & '"' & @CRLF & _
			'/interface wireguard peers add allowed-address=' & $AllowedIPs & ' endpoint-address=' & $EndpointIP & ' endpoint-port=' & $EndpointPort & ' interface='& $wgName & ' preshared-key="'& $PresharedKey &'" public-key="' & $PublicKey & '"' & @CRLF & _
			'/ip address add address=' & $localAdres & '/24 interface="'& $wgName &'"'
	FileWrite($hFile, $sCode)
	FileClose($hFile)
	MsgBox (0,"","Завершено.",5)


EndFunc

Func _regexp (ByRef Const $text, ByRef Const $regexpPatern )
	local $res = StringRegExp ( $text,$regexpPatern ,$STR_REGEXPARRAYMATCH)
	If Not @error Then Return $res[0]
	Return SetError(1, 0, Null)
EndFunc