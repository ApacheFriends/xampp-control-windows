unit uFileZilla;

interface

uses GnuGettext, uBaseModule, SysUtils, Classes, Windows, ExtCtrls, StdCtrls, Buttons, uNetstatTable, uTools, uProcesses_new, uServices;

type
  tFileZilla = class(tBaseModule)
    OldPIDs, OldPorts: string;
    GlobalStatus: string;
    procedure ServiceInstall; override;
    procedure ServiceUnInstall; override;
    procedure Start; override;
    procedure Stop; override;
    procedure Admin; override;
    procedure CheckPorts;
    procedure UpdateStatus; override;
    procedure CheckIsService; reintroduce;
    procedure AddLog(Log: string; LogType: tLogType = ltDefault); reintroduce;
    constructor Create(pbbService: TBitBtn; pStatusPanel: tPanel; pPIDLabel, pPortLabel: tLabel; pStartStopButton, pAdminButton: TBitBtn);
    destructor Destroy; override;
  end;

implementation

uses uMain;

const
  cModuleName = 'FileZilla';

  { tFileZilla }

procedure tFileZilla.AddLog(Log: string; LogType: tLogType);
begin
  inherited AddLog('filezilla', Log, LogType);
end;

procedure tFileZilla.Admin;
var
  App: string;
begin
  App := BaseDir + 'filezillaftp\' + Config.BinaryNames.FileZillaAdmin;
  AddLog(Format(_('Executing "%s"'), [App]), ltDebug);
  ExecuteFile(App, '', '', SW_SHOW);
end;

procedure tFileZilla.CheckIsService;
var
  s: string;
  path: string;
begin
  inherited CheckIsService(RemoveWhiteSpace(Config.ServiceNames.FileZilla));
  if isService then
  begin
    s := _('Service installed');
    path := GetServicePath(RemoveWhiteSpace(Config.ServiceNames.FileZilla));
  end
  else
    s := _('Service not installed');
  AddLog(Format(_('Checking for service (name="%s"): %s'), [RemoveWhiteSpace(Config.ServiceNames.FileZilla), s]), ltDebug);
  if (path <> '') then
  begin
    if (Pos(LowerCase(BaseDir + 'FileZillaFTP\' + Config.BinaryNames.FileZilla), LowerCase(path)) <> 0) then
      AddLog(Format(_('Service Path: %s'), [path]), ltDebug)
    else
    begin
      pStatus.Color := cErrorColor;
      AddLog(Format(_('%s Service detected with wrong path'), [cModuleName]), ltError);
      AddLog(Format(_('Change XAMPP %s and Control Panel settings or'), [cModuleName]), ltError);
      AddLog(_('Uninstall/disable the other service manually first'), ltError);
      AddLog(Format(_('Found Path: %s'), [path]), ltError);
      AddLog(Format(_('Expected Path: "%sFileZillaFTP\%s"'), [BaseDir, Config.BinaryNames.FileZilla]), ltError);
    end
  end
  else
    AddLog(_('Service Path: Service Not Installed'), ltDebug);
end;

constructor tFileZilla.Create;
var
  ServerApp, ServerAppBackup: string;
begin
  inherited;
  ModuleName := cModuleName;
  isService := false;
  GlobalStatus := 'starting';
  AddLog(_('Initializing module...'), ltDebug);
  ServerApp := BaseDir + 'FileZillaFTP\' + Config.BinaryNames.FileZilla;
  ServerAppBackup := BaseDir + 'FileZillaFTP\FileZilla server.exe';
  AddLog(_('Checking for module existence...'), ltDebug);
  if not FileExists(ServerApp) then
  begin
    AddLog(_('Checking for alternate module existence...'), ltDebug);
    if not FileExists(ServerAppBackup) then
    begin
      pStatus.Color := cErrorColor;
      AddLog(Format(_('Problem detected: %s Not Found!'), [cModuleName]), ltError);
      AddLog(Format(_('Disabling %s buttons'), [cModuleName]), ltError);
      AddLog(_('Run this program from your XAMPP root directory!'), ltError);
      bAdmin.Enabled := false;
      bbService.Enabled := false;
      bStartStop.Enabled := false;
    end
    else
      ServerApp := ServerAppBackup;
  end;

  if not Config.EnableServices.FileZilla then
  begin
    AddLog(Format(_('%s Service is disabled.'), [cModuleName]), ltDebug);
    fmain.bFileZillaService.Enabled := false;
  end;

  AddLog(_('Checking for required tools...'), ltDebug);

  CheckIsService;
  CheckPorts;
end;

destructor tFileZilla.Destroy;
begin
  inherited;
end;

procedure tFileZilla.CheckPorts;
var
  PortBlocker: string;
  PortBlockerPID: integer;
  path: string;
  p: integer;
  ServerApp: string;
  pbpath: string;
  pbspath: string;
  Ports: array [0 .. 1] of integer;
begin
  ServerApp := BaseDir + 'FileZillaFTP\' + Config.BinaryNames.FileZilla;
  Ports[0] := Config.ServicePorts.FileZilla;
  Ports[1] := Config.ServicePorts.FileZillaAdmin;

  path := GetServicePath(RemoveWhiteSpace(Config.ServiceNames.FileZilla));

  if Config.EnableChecks.CheckDefaultPorts then
  begin
    AddLog(_('Checking default ports...'), ltDebug);
    for p := Low(Ports) to High(Ports) do
    begin
      PortBlockerPID := NetStatTable.isPortInUsePID(Ports[p]);
      if (PortBlockerPID > 0) then
      begin
        PortBlocker := Processes.GetProcessName(PortBlockerPID);
        AddLog(Format(_('Portblocker Detected: %s'), [PortBlocker]), ltDebug);
        AddLog(Format(_('Checking for App: %s'), [ServerApp]), ltDebug);
        if isService then
          AddLog(Format(_('Checking for Service: %s'), [path]), ltDebug);
        //if (Pos(LowerCase(ServerApp), LowerCase(PortBlocker)) <> 0) then
        pbpath := Processes.GetProcessPath(PortBlockerPID);
        pbspath := GetServiceWithPid(PortBlockerPID);
        AddLog(Format(_('Portblocker Path: %s'), [pbpath]), ltDebug);
        AddLog(Format(_('Portblocker Service Path: %s'), [pbspath]), ltDebug);
        if (Pos(LowerCase(ServerApp), LowerCase(pbpath)) <> 0) then
        begin
          AddLog(Format(_('XAMPP %s is already running on port %d'), [cModuleName, Ports[p]]), ltInfo);
        end
        //else if (Pos(LowerCase(PortBlocker), LowerCase(path)) <> 0) and (isService = True) then
        else if (Pos(LowerCase(pbspath), LowerCase(path)) <> 0) and (isService = True) and (Pos(LowerCase(ServerApp), LowerCase(pbspath)) <> 0) then
        begin
          AddLog(Format(_('XAMPP %s Service is already running on port %d'), [cModuleName, Ports[p]]), ltInfo);
          //AddLog(Format(_('Service Path: %s'), [GetServiceWithPid(PortBlockerPID)]), ltDebug);
        end
        else
        begin
          pStatus.Color := cErrorColor;
          if (pbspath <> '') then
            PortBlocker := pbspath
          else
            PortBlocker := pbpath;
          AddLog(_('Problem detected!'), ltError);
          AddLog(Format(_('Port %d in use by "%s"!'), [Ports[p], PortBlocker]), ltError);
          AddLog(Format(_('%s WILL NOT start without the configured ports free!'), [cModuleName]), ltError);
          AddLog(_('You need to uninstall/disable/reconfigure the blocking application'), ltError);
          AddLog(Format(_('or reconfigure %s and the Control Panel to listen on a different port'), [cModuleName]), ltError);
        end;
      end;
    end;
  end;
end;

procedure tFileZilla.ServiceInstall;
var
  App, Param1, Param2, Param3: string;
  RC: integer;
begin
  App := BaseDir + 'filezillaftp\' + Config.BinaryNames.FileZilla;
  Param1 := '-install auto';
  Param2 := '-servicename ' + RemoveWhiteSpace(Config.ServiceNames.FileZilla);
  Param3 := '-servicedisplayname ' + Config.ServiceNames.FileZilla;
  AddLog(_('Setting Service Name...'));
  AddLog(Format(_('Executing "%s %s"'), [App, Param2]), ltDebug);
  ExecuteFile(App, Param2, BaseDir, SW_HIDE);
  AddLog(_('Setting Service Display Name...'));
  AddLog(Format(_('Executing "%s %s"'), [App, Param3]), ltDebug);
  ExecuteFile(App, Param3, BaseDir, SW_HIDE);
  AddLog(_('Installing service...'));
  AddLog(Format(_('Executing "%s %s"'), [App, Param1]), ltDebug);
  RC := RunAsAdmin(App, Param1, SW_HIDE);
  if RC = 0 then
    AddLog(Format(_('Return code: %d'), [RC]), ltDebug)
  else
    AddLog(Format(_('There may be an error, return code: %d - %s'), [RC, SystemErrorMessage(RC)]), ltError);
end;

procedure tFileZilla.ServiceUnInstall;
var
  App, Param: string;
  RC: Cardinal;
begin
  App := BaseDir + 'filezillaftp\' + Config.BinaryNames.FileZilla;
  Param := '-uninstall';
  AddLog('Uninstalling service...');
  AddLog(Format(_('Executing "%s" "%s"'), [App, Param]), ltDebug);
  RC := RunAsAdmin(App, Param, SW_HIDE);
  if RC = 0 then
    AddLog(Format(_('Return code: %d'), [RC]), ltDebug)
  else
    AddLog(Format(_('There may be an error, return code: %d - %s'), [RC, SystemErrorMessage(RC)]), ltError);
end;

procedure tFileZilla.Start;
var
  App: string;
  RC: Cardinal;
begin
  GlobalStatus := 'starting';
  CheckPorts;
  if isService and Config.EnableServices.FileZilla then
  begin
    AddLog(Format(_('Attempting to start %s service...'), [cModuleName]));
    App := Format('start "%s"', [RemoveWhiteSpace(Config.ServiceNames.FileZilla)]);
    AddLog(Format(_('Executing "%s"'), ['net ' + App]), ltDebug);
    RC := RunAsAdmin('net', App, SW_HIDE);
    if RC = 0 then
      AddLog(Format(_('Return code: %d'), [RC]), ltDebug)
    else
      AddLog(Format(_('There may be an error, return code: %d - %s'), [RC, SystemErrorMessage(RC)]), ltError);
  end
  else
  begin
    App := BaseDir + 'filezillaftp\' + Config.BinaryNames.FileZilla + ' -compat -start';
    AddLog(Format(_('Attempting to start %s app...'), [cModuleName]));
    AddLog(Format(_('Executing "%s"'), [App]), ltDebug);
    RC := RunProcess(App, SW_HIDE, false);
    if RC = 0 then
      AddLog(Format(_('Return code: %d'), [RC]), ltDebug)
    else
      AddLog(Format(_('There may be an error, return code: %d - %s'), [RC, SystemErrorMessage(RC)]), ltError);
  end;
end;

procedure tFileZilla.Stop;
var
  App: string;
  RC: Cardinal;
begin
  GlobalStatus := 'stopping';
  if isService and Config.EnableServices.FileZilla then
  begin
    AddLog(Format(_('Attempting to stop %s service...'), [cModuleName]));
    App := Format('stop "%s"', [RemoveWhiteSpace(Config.ServiceNames.FileZilla)]);
    AddLog(Format(_('Executing "%s"'), ['net ' + App]), ltDebug);
    RC := RunAsAdmin('net', App, SW_HIDE);
    if RC = 0 then
      AddLog(Format(_('Return code: %d'), [RC]), ltDebug)
    else
      AddLog(Format(_('There may be an error, return code: %d - %s'), [RC, SystemErrorMessage(RC)]), ltError);
  end
  else
  begin
    App := BaseDir + 'filezillaftp\' + Config.BinaryNames.FileZilla + ' -compat -stop';
    AddLog(Format(_('Attempting to stop %s app...'), [cModuleName]));
    AddLog(Format(_('Executing "%s"'), [App]), ltDebug);
    RC := RunProcess(App, SW_HIDE, false);
    if RC = 0 then
      AddLog(Format(_('Return code: %d'), [RC]), ltDebug)
    else
      AddLog(Format(_('There may be an error, return code: %d - %s'), [RC, SystemErrorMessage(RC)]), ltError);
  end;
end;

procedure tFileZilla.UpdateStatus;
var
  p: integer;
  // ProcInfo: TProcInfo;
  s: string;
  Ports: string;
  pname: string;
  ppath: string;
  currPID: integer;
  ErrorStatus: integer;
begin
  isRunning := false;
  PIDList.Clear;
  ErrorStatus := 0;
  // for p := 0 to Processes.ProcessList.Count - 1 do
  // begin
  // ProcInfo := Processes.ProcessList[p];
  // if (pos(Config.BinaryNames.FileZilla, ProcInfo.Module) = 1) then
  // begin
  // if (pos(IntToStr(Config.ServicePorts.FileZilla),NetStatTable.GetPorts4PID(ProcInfo.PID)) <> 0) or
  // (pos(IntToStr(Config.ServicePorts.FileZillaAdmin),NetStatTable.GetPorts4PID(ProcInfo.PID)) <> 0) or
  // (pos(BaseDir, ProcInfo.ExePath) <> 0) then
  // begin
  // isRunning := true;
  // PIDList.Add(Pointer(ProcInfo.PID));
  // end;
  // end;
  // end;

  for p := 0 to Processes.ProcessList2.Count - 1 do
  begin
    pname := Processes.ProcessList2[p];
    if (Pos(LowerCase(Config.BinaryNames.FileZilla), LowerCase(pname)) = 1) then
    begin
      currPID := integer(Processes.ProcessList2.Objects[p]);
      if (isService) then
      begin
        ppath := LowerCase(GetServiceWithPid(currPID));
        if ((Pos(IntToStr(Config.ServicePorts.FileZilla), NetStatTable.GetPorts4PID(currPID)) <> 0) and (Pos(LowerCase(BaseDir), ppath) <> 0)) or
          ((Pos(IntToStr(Config.ServicePorts.FileZillaAdmin), NetStatTable.GetPorts4PID(currPID)) <> 0) and (Pos(LowerCase(BaseDir), ppath) <> 0)) or
          (Pos(LowerCase(BaseDir), ppath) <> 0) then
        begin
          isRunning := True;
          PIDList.Add(Pointer(currPID));
        end;
      end
      else
      begin
        ppath := LowerCase(Processes.GetProcessPath(currPID));
        if ((Pos(IntToStr(Config.ServicePorts.FileZilla), NetStatTable.GetPorts4PID(currPID)) <> 0) and (Pos(LowerCase(BaseDir), ppath) <> 0)) or
          ((Pos(IntToStr(Config.ServicePorts.FileZillaAdmin), NetStatTable.GetPorts4PID(currPID)) <> 0) and (Pos(LowerCase(BaseDir), ppath) <> 0)) or
          (Pos(LowerCase(BaseDir), ppath) <> 0) then
        begin
          isRunning := True;
          PIDList.Add(Pointer(currPID));
        end;
      end;
    end;
  end;


// Checking processes
s := '';
for p := 0 to PIDList.Count - 1 do
begin
  if p = 0 then
    s := IntToStr(integer(PIDList[p]))
  else
    s := s + #13 + IntToStr(integer(PIDList[p]));
end;
if s <> OldPIDs then
begin
  lPID.Caption := s;
  OldPIDs := s;
end;

// Checking netstats
s := '';
for p := 0 to PIDList.Count - 1 do
begin
  Ports := NetStatTable.GetPorts4PID(integer(PIDList[p]));
  if Ports <> '' then
    s := RemoveDuplicatePorts(Ports);
end;
if s <> OldPorts then
begin
  lPort.Caption := s;
  OldPorts := s;
end;

if byte(isRunning) <> oldIsRunningByte then
begin
  if oldIsRunningByte <> 2 then
  begin
    if isRunning then
      s := _('running')
    else
    begin
      s := _('stopped');
      if GlobalStatus = 'starting' then
        ErrorStatus := 1;
    end;
    AddLog(_('Status change detected:') + ' ' + s);
    if ErrorStatus = 1 then
    begin
      pStatus.Color := cErrorColor;
      AddLog(Format(_('Error: %s shutdown unexpectedly.'), [cModuleName]), ltError);
      AddLog(_('This may be due to a blocked port, missing dependencies, '), ltError);
      AddLog(_('improper privileges, a crash, or a shutdown by another method.'), ltError);
      AddLog(_('Press the Logs button to view error logs and check'), ltError);
      AddLog(_('the Windows Event Viewer for more clues'), ltError);
      AddLog(_('If you need more help, copy and post this'), ltError);
      AddLog(_('entire log window on the forums'), ltError);
    end;
  end;

  oldIsRunningByte := byte(isRunning);
  if isRunning then
  begin
    pStatus.Color := cRunningColor;
    bStartStop.Caption := _('Stop');
    bAdmin.Enabled := True;
    fmain.FileZillaTray.ImageIndex := 15;
    fmain.FileZillaTrayControl.Caption := _('Stop');
  end
  else
  begin
    pStatus.Color := cStoppedColor;
    bStartStop.Caption := _('Start');
    bAdmin.Enabled := false;
    fmain.FileZillaTray.ImageIndex := 16;
    fmain.FileZillaTrayControl.Caption := _('Start');
  end;
end;

if AutoStart then
begin
  AutoStart := false;
  if isRunning then
  begin
    AddLog(Format(_('Autostart aborted: %s is already running'), [cModuleName]), ltInfo);
  end
  else
  begin
    AddLog(_('Autostart active: starting...'));
    Start;
  end;
end;
end;

end.
