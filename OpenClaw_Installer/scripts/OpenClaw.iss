; OpenClaw Inno Setup Script
; 生成单一exe安装包

#define MyAppName "OpenClaw"
#define MyAppVersion "1.0.0"
#define MyAppPublisher "OpenClaw Team"
#define MyAppURL "https://github.com/ClsH/Claw"
#define MyAppExeName "OpenClaw.exe"

[Setup]
AppId={{A1B2C3D4-E5F6-7890-ABCD-EF1234567890}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppVerName={#MyAppName} {#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
AppSupportURL={#MyAppURL}
AppUpdatesURL={#MyAppURL}
DefaultDirName={autopf}\{#MyAppName}
DefaultGroupName={#MyAppName}
AllowNoIcons=yes
LicenseFile=..\docs\LICENSE.txt
OutputDir=..\output
OutputBaseFilename=OpenClaw_Setup_v{#MyAppVersion}
SetupIconFile=..\bin\OpenClaw.ico
Compression=lzma2
SolidCompression=yes
WizardStyle=modern
PrivilegesRequired=admin
ArchitecturesAllowed=x86compatible
ArchitecturesInstallIn64BitMode=x64

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"
Name: "chinesesimplified"; MessagesFile: "compiler:Languages\ChineseSimplified.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Files]
; OpenClaw 主程序和DLL
Source: "..\bin\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

; VC++ Redistributable (临时提取)
Source: "..\redist\vc_redist.x86.exe"; DestDir: "{tmp}"; Flags: deleteafterinstall

[Icons]
Name: "{group}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"
Name: "{group}\{cm:UninstallProgram,{#MyAppName}}"; Filename: "{uninstallexe}"
Name: "{autodesktop}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; Tasks: desktopicon

[Run]
; 安装 VC++ Redistributable
Filename: "{tmp}\vc_redist.x86.exe"; Parameters: "/install /quiet /norestart"; StatusMsg: "正在安装 Visual C++ Redistributable..."; Flags: runhidden waituntilterminated

; 安装完成后提示用户
Filename: "{app}\README.txt"; StatusMsg: "查看安装说明..."; Flags: postinstall skipifsilent

[Code]
function InitializeSetup(): Boolean;
begin
  Result := True;
end;

procedure CurStepChanged(CurStep: TSetupStep);
begin
  if CurStep = ssPostInstall then
  begin
    // 创建 data 目录
    ForceDirectories(ExpandConstant('{app}\data'));
    ForceDirectories(ExpandConstant('{app}\logs'));

    // 创建默认配置文件
    if not FileExists(ExpandConstant('{app}\openclaw.ini')) then
    begin
      SaveStringToFile(ExpandConstant('{app}\openclaw.ini'),
        '[General]' + #13#10 +
        'DataPath=data' + #13#10 +
        'Fullscreen=false' + #13#10 +
        'Width=800' + #13#10 +
        'Height=600' + #13#10 +
        'VSync=true' + #13#10 +
        'Antialiasing=false' + #13#10 +
        #13#10 +
        '[Controls]' + #13#10 +
        'Left=Left' + #13#10 +
        'Right=Right' + #13#10 +
        'Up=Up' + #13#10 +
        'Down=Down' + #13#10 +
        'Jump=Space' + #13#10 +
        'Fire=Z' + #13#10 +
        'Crouch=Control' + #13#10 +
        'Pause=Escape' + #13#10 +
        #13#10 +
        '[Audio]' + #13#10 +
        'MusicVolume=80' + #13#10 +
        'SfxVolume=100' + #13#10 +
        #13#10 +
        '[Video]' + #13#10 +
        'Quality=High' + #13#10,
        False);
    end;

    // 显示完成消息
    if not IsSilent() then
    begin
      MsgBox('OpenClaw 安装完成!' + #13#10 + #13#10 +
             '重要提示:' + #13#10 +
             '您需要将原版 Captain Claw 的 CLAW.REZ 文件' + #13#10 +
             '复制到以下目录:' + #13#10 +
             ExpandConstant('{app}\data') + #13#10 + #13#10 +
             '如需卸载，请通过"程序和功能"或运行 uninstall.bat',
             mbInformation, MB_OK);
    end;
  end;
end;

[UninstallDelete]
Type: filesandordirs; Name: "{app}"

[Registry]
; 注册卸载信息 (由Inno Setup自动处理)
