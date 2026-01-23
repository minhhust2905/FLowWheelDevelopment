; Script đóng gói FlowWheel - Tác giả: MinhEdward
#define MyAppName "FlowWheel"
#define MyAppVersion "1.0"
#define MyAppPublisher "MinhEdward"
#define MyAppURL "https://flowwheel-minhedward-prod.web.app/"
#define MyAppExeName "FlowWheel.exe"

[Setup]
AppId={{8C8147CF-DCD1-4C7E-B7C0-54FC3D18A27D}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
DefaultDirName={autopf}\{#MyAppName}
UninstallDisplayIcon={app}\{#MyAppExeName}
UninstallDisplayName={#MyAppName}
; Gom file gỡ cài đặt vào folder riêng cho gọn
UninstallFilesDir={app}\UninstallData
; Ghi đè thông tin để Windows hiện tên thân thiện thay vì unins000.exe
VersionInfoDescription={#MyAppName} Uninstaller
VersionInfoProductName={#MyAppName}
VersionInfoCompany={#MyAppPublisher}
VersionInfoCopyright=Copyright (C) 2026 {#MyAppPublisher}
OutputBaseFilename=FlowWheel_Setup
SetupIconFile=E:\FlowWheelDeliver\FlowWheel\resources\icons\FlowWheel.ico
LicenseFile=E:\FlowWheelDeliver\EULA_FlowWheel.rtf
SolidCompression=yes
WizardStyle=modern dynamic
CloseApplications=yes

[Languages]
Name: "vietnamese"; MessagesFile: "E:\FlowWheelDeliver\Vietnamese.isl"
Name: "english"; MessagesFile: "compiler:Default.isl"

[Files]
Source: "E:\FlowWheelDeliver\FlowWheel\{#MyAppExeName}"; DestDir: "{app}"; Flags: ignoreversion
Source: "E:\FlowWheelDeliver\FlowWheel\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs; Excludes: "{#MyAppExeName}"

[UninstallDelete]
; Xóa file config tự tạo và toàn bộ thư mục
Type: files; Name: "{app}\resources\config\flowwheel.ini"
Type: filesandordirs; Name: "{app}"

[Icons]
Name: "{autoprograms}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"
; Tạo lối tắt gỡ cài đặt với tên thân thiện trong Start Menu
Name: "{autoprograms}\Uninstall {#MyAppName}"; Filename: "{uninstallexe}"

[Run]
Filename: "{app}\{#MyAppExeName}"; Description: "{cm:LaunchProgram,{#StringChange(MyAppName, '&', '&&')}}"; Flags: nowait postinstall skipifsilent

[Code]
// Đóng FlowWheel ngay lập tức khi bấm Uninstall để không bị đè giao diện
function InitializeUninstall(): Boolean;
var
  ResultCode: Integer;
begin
  Exec('taskkill.exe', '/f /im {#MyAppExeName}', '', SW_HIDE, ewWaitUntilTerminated, ResultCode);
  Sleep(500); 
  Result := True;
end;

function IsVietnameseWindows: Boolean;
begin
  Result := (GetUILanguage = $042A);
end;

procedure CurStepChanged(CurStep: TSetupStep);
var
  LangFile: String;
begin
  if CurStep = ssPostInstall then
  begin
    LangFile := ExpandConstant('{app}\resources\config\flowwheel.ini');
    if IsVietnameseWindows then
      SaveStringToFile(LangFile, '[General]'#13#10'language=vi', True)
    else
      SaveStringToFile(LangFile, '[General]'#13#10'language=en', True);
  end;
end;