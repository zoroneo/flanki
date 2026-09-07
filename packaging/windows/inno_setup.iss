#ifndef MyAppVersion
#define MyAppVersion "1.0.4"
#endif

[Setup]
AppId={{D37F2F12-887B-4B7C-901C-5B6081CA2857}
AppName=Flanki
AppVersion={#MyAppVersion}
AppPublisher=ZoroNeo
AppPublisherURL=https://github.com/zoroneo/flanki
AppSupportURL=https://github.com/zoroneo/flanki/issues
AppUpdatesURL=https://github.com/zoroneo/flanki/releases
DefaultDirName={autopf}\Flanki
DefaultGroupName=Flanki
DisableProgramGroupPage=yes
OutputDir=..\..\
OutputBaseFilename=flanki-setup-windows
SetupIconFile=..\..\windows\runner\resources\app_icon.ico
LicenseFile=..\..\LICENSE
Compression=lzma2/ultra64
SolidCompression=yes
WizardStyle=modern
ArchitecturesInstallIn64BitMode=x64compatible
CloseApplications=yes
RestartApplications=no

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Files]
Source: "..\..\build\windows\x64\runner\Release\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{autoprograms}\Flanki"; Filename: "{app}\flanki.exe"
Name: "{autodesktop}\Flanki"; Filename: "{app}\flanki.exe"; Tasks: desktopicon

[Run]
Filename: "{app}\flanki.exe"; Description: "{cm:LaunchProgram,Flanki}"; Flags: nowait postinstall skipifsilent
