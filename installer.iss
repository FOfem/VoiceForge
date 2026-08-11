; ============================================================
; VoiceForge Windows Installer Script
; Uses Inno Setup to create professional installer
; ============================================================

[Setup]
AppName=VoiceForge
AppVersion=1.0.0
AppPublisher=ForraCorp
AppPublisherURL=https://github.com/FOfem/VoiceForge
AppSupportURL=https://github.com/FOfem/VoiceForge/issues
AppUpdatesURL=https://github.com/FOfem/VoiceForge/releases
AppCopyright=© 2026 ForraCorp
AppContact=fofem@forracorp.com
DefaultDirName={pf}\VoiceForge
DefaultGroupName=VoiceForge
AllowNoIcons=yes
UninstallDisplayIcon={app}\VoiceForge.exe
UninstallDisplayName=VoiceForge
Compression=lzma2
SolidCompression=yes
OutputDir=dist
OutputBaseFilename=VoiceForgeSetup
SetupIconFile=src\resources\icons\icon.ico
WizardImageFile=src\resources\icons\wizard.bmp
WizardSmallImageFile=src\resources\icons\wizard_small.bmp
MinVersion=10.0
ArchitecturesAllowed=x64
ArchitecturesInstallIn64BitMode=x64
PrivilegesRequired=admin

[Files]
Source: "dist\VoiceForge.exe"; DestDir: "{app}"
Source: "README.md"; DestDir: "{app}"
Source: "LICENSE"; DestDir: "{app}"
Source: "src\resources\icons\icon.ico"; DestDir: "{app}"

[Icons]
Name: "{group}\VoiceForge"; Filename: "{app}\VoiceForge.exe"; IconFilename: "{app}\icon.ico"
Name: "{group}\Uninstall VoiceForge"; Filename: "{uninstallexe}"
Name: "{commondesktop}\VoiceForge"; Filename: "{app}\VoiceForge.exe"; IconFilename: "{app}\icon.ico"
Name: "{userstartup}\VoiceForge"; Filename: "{app}\VoiceForge.exe"; IconFilename: "{app}\icon.ico"

[Run]
Filename: "{app}\VoiceForge.exe"; Description: "Launch VoiceForge"; Flags: postinstall nowait skipifsilent

[UninstallDelete]
Type: files; Name: "{app}\*.log"

[Registry]
Root: HKCU; Subkey: "Software\ForraCorp\VoiceForge"; Flags: uninsdeletekey
Root: HKCU; Subkey: "Software\ForraCorp\VoiceForge"; ValueType: string; ValueName: "InstallPath"; ValueData: "{app}"
Root: HKCU; Subkey: "Software\ForraCorp\VoiceForge"; ValueType: string; ValueName: "Version"; ValueData: "1.0.0"

[Code]
function InitializeSetup(): Boolean;
begin
  Result := True;
  // Check if Windows 10 or later
  if not (GetWindowsVersion >= 10000) then
  begin
    MsgBox('VoiceForge requires Windows 10 or later.', mbError, MB_OK);
    Result := False;
  end;
end;