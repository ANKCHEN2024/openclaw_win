; OpenClaw Installer Script for Inno Setup
; Generates single exe installer with Chinese UI and accurate progress

#define MyAppName "OpenClaw"
#define MyAppVersion "2026.3.2"
#define MyAppPublisher "OpenClaw Team"
#define MyAppURL "https://github.com/openclaw/openclaw"
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
OutputDir=..\output
OutputBaseFilename=OpenClaw_Setup_v{#MyAppVersion}
Compression=lzma2
SolidCompression=yes
WizardStyle=modern
PrivilegesRequired=admin
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64
DisableProgramGroupPage=yes

[Languages]
Name: "chinese"; MessagesFile: "compiler:Languages\ChineseSimplified.isl"

[CustomMessages]
chinese.AppDescription=OpenClaw AI Gateway - 将聊天应用连接到AI助手
chinese.CreateDesktopIcon=创建桌面快捷方式(&D)
chinese.AdditionalIcons=其他图标:
chinese.UninstallProgram=卸载 OpenClaw
chinese.LaunchProgram=启动 OpenClaw Gateway
chinese.AutoStartTask=开机自动启动 OpenClaw
chinese.InstallingNode=正在安装 Node.js 22...
chinese.InstallingOpenClaw=正在安装 OpenClaw...
chinese.Configuring=正在配置 OpenClaw...
chinese.StartupOptions=启动选项:

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked
Name: "autostart"; Description: "{cm:AutoStartTask}"; GroupDescription: "{cm:StartupOptions}"; Flags: unchecked

[Files]
Source: "..\redist\node-v22.13.1-x64.msi"; DestDir: "{tmp}"; Flags: deleteafterinstall
Source: "..\api-guide.html"; DestDir: "{app}"; Flags: ignoreversion

[Icons]
Name: "{group}\OpenClaw Gateway"; Filename: "{cmd}"; Parameters: "/c npx openclaw gateway"; WorkingDir: "{userappdata}"; Comment: "{cm:LaunchProgram}"
Name: "{group}\{cm:UninstallProgram}"; Filename: "{uninstallexe}"
Name: "{autodesktop}\OpenClaw Gateway"; Filename: "{cmd}"; Parameters: "/c npx openclaw gateway"; Tasks: desktopicon; Comment: "{cm:LaunchProgram}"

[Run]
Filename: "msiexec.exe"; Parameters: "/i ""{tmp}\node-v22.13.1-x64.msi"" /quiet /norestart"; StatusMsg: "正在安装 Node.js 22 (1/3)"; Flags: runhidden waituntilterminated
Filename: "cmd.exe"; Parameters: "/c ""{app}\install_steps.bat"""; StatusMsg: "正在安装和配置 OpenClaw (2/3)"; Flags: runhidden waituntilterminated
Filename: "cmd.exe"; Parameters: "/c if exist ""{app}\start_minimized.bat"" schtasks /Create /TN ""OpenClaw Gateway"" /TR ""\""{app}\start_minimized.bat\"""" /SC ONLOGON /RL LIMITED /F"; StatusMsg: "正在设置开机自启动 (3/3)"; Tasks: autostart; Flags: runhidden waituntilterminated

[Code]
var
  ResultCode: Integer;

function InitializeSetup(): Boolean;
begin
  Result := True;
end;

procedure CurStepChanged(CurStep: TSetupStep);
var
  ConfigPath: String;
  ConfigContent: String;
  StartScript: String;
  StartMinimizedScript: String;
  InstallBatch: String;
  StatusText: String;
begin
  if CurStep = ssPostInstall then
  begin
    ForceDirectories(ExpandConstant('{app}'));
    ForceDirectories(ExpandConstant('{app}\config'));
    ForceDirectories(ExpandConstant('{app}\logs'));
    ForceDirectories(ExpandConstant('{app}\data'));
    ForceDirectories(ExpandConstant('{userappdata}\.openclaw'));

    StartScript := '@echo off' + #13#10 + 'cd /d "' + ExpandConstant('{app}') + '"' + #13#10 + 'title OpenClaw Gateway' + #13#10 + 'npx openclaw gateway' + #13#10 + 'pause';
    SaveStringToFile(ExpandConstant('{app}\start.bat'), StartScript, False);

    StartMinimizedScript := '@echo off' + #13#10 + 'start /min cmd /c "npx openclaw gateway"';
    SaveStringToFile(ExpandConstant('{app}\start_minimized.bat'), StartMinimizedScript, False);

    InstallBatch := 
      '@echo off' + #13#10 +
      'echo Installing OpenClaw...' + #13#10 +
      'npm install -g openclaw' + #13#10 +
      'echo.' + #13#10 +
      'echo Configuring...' + #13#10 +
      'npx openclaw doctor --fix' + #13#10 +
      'npx openclaw config set gateway.mode local' + #13#10 +
      'npx openclaw config set gateway.auth.mode none' + #13#10 +
      'npx openclaw config set agents.defaults.permissions.allowBrowser true' + #13#10 +
      'npx openclaw config set agents.defaults.permissions.allowReadFiles true' + #13#10 +
      'npx openclaw config set agents.defaults.permissions.allowWriteFiles true' + #13#10 +
      'npx openclaw config set agents.defaults.permissions.allowExecute true' + #13#10 +
      'npx openclaw config set agents.defaults.permissions.allowTerminal true' + #13#10 +
      'npx openclaw config set security.requireApproval false' + #13#10 +
      'npx openclaw config set channels.whatsapp.groupPolicy open' + #13#10 +
      'npx openclaw config set channels.telegram.groupPolicy open' + #13#10 +
      'npx openclaw config set channels.discord.groupPolicy open' + #13#10 +
      'echo Done.';

    SaveStringToFile(ExpandConstant('{app}\install_steps.bat'), InstallBatch, False);

    ConfigPath := ExpandConstant('{userappdata}\.openclaw\openclaw.json');
    ConfigContent :=
      '{' + #13#10 +
      '  "channels": {' + #13#10 +
      '    "whatsapp": {"enabled": false, "groupPolicy": "open"},' + #13#10 +
      '    "telegram": {"enabled": false, "groupPolicy": "open"},' + #13#10 +
      '    "discord": {"enabled": false, "groupPolicy": "open"},' + #13#10 +
      '    "imessage": {"enabled": false, "groupPolicy": "open"}' + #13#10 +
      '  },' + #13#10 +
      '  "gateway": {"mode": "local", "auth": {"mode": "none"}},' + #13#10 +
      '  "agents": {"defaults": {"permissions": {' + #13#10 +
      '    "allowBrowser": true,' + #13#10 +
      '    "allowReadFiles": true,' + #13#10 +
      '    "allowWriteFiles": true,' + #13#10 +
      '    "allowExecute": true,' + #13#10 +
      '    "allowTerminal": true,' + #13#10 +
      '    "maxConcurrentTools": 10,' + #13#10 +
      '    "maxDuration": 300000' + #13#10 +
      '  }}},' + #13#10 +
      '  "security": {"allowedUsers": [], "requireApproval": false},' + #13#10 +
      '  "server": {"port": 18789, "host": "127.0.0.1"}' + #13#10 +
      '}';

    SaveStringToFile(ConfigPath, ConfigContent, False);

    Exec('cmd.exe', '/c start /min npx openclaw gateway', '', SW_HIDE, ewNoWait, ResultCode);
    Sleep(3000);
    Exec('cmd.exe', '/c start http://127.0.0.1:18789/', '', SW_HIDE, ewNoWait, ResultCode);

    StatusText := 'OpenClaw Gateway started!' + #13#10 + 'Please check if browser opened automatically.';
    MsgBox('OpenClaw Installation Complete!' + #13#10 + #13#10 +
           'Agent permissions set to FULL' + #13#10 +
           'Token authentication disabled' + #13#10 + #13#10 +
           StatusText + #13#10 + #13#10 +
           'Control Panel: http://127.0.0.1:18789/' + #13#10 + #13#10 +
           'Start command: npx openclaw gateway',
           mbInformation, MB_OK);
    if MsgBox('Open API Guide?' + #13#10 + #13#10 +
              'Guide: Aliyun Bailian, SiliconFlow config, Model recommendations',
              mbConfirmation, MB_YESNO) = IDYES then
    begin
      Exec('cmd.exe', '/c start "" "' + ExpandConstant('{app}\api-guide.html') + '"', '', SW_HIDE, ewNoWait, ResultCode);
    end;
  end;
end;

procedure CurUninstallStepChanged(CurUninstallStep: TUninstallStep);
var
  ResultCode: Integer;
begin
  if CurUninstallStep = usPostUninstall then
  begin
    Exec('cmd.exe', '/c schtasks /Delete /TN "OpenClaw Gateway" /F', '', SW_HIDE, ewWaitUntilTerminated, ResultCode);
    MsgBox('OpenClaw has been successfully uninstalled!' + #13#10 + #13#10 + 'Thank you for using!',
           mbInformation, MB_OK);
  end;
end;

[UninstallDelete]
Type: filesandordirs; Name: "{app}"
Type: filesandordirs; Name: "{userappdata}\.openclaw"
