unit uApache;

interface

uses GnuGettext, uBaseModule, SysUtils, Classes, Windows, ExtCtrls, StdCtrls, Buttons, uNetstatTable, uTools, uProcesses_new, Messages, uServices;

type
  tApacheLogType = (altAccess, altError);

  tApache = class(tBaseModule)
    OldPIDs, OldPorts: string;
    OldPIDCount: integer;
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
  cModuleName = 'Apache';

  { tApache }

procedure tApache.AddLog(Log: string; LogType: tLogType = ltDefault);
begin
  inherited AddLog(cModuleName, Log, LogType);
end;

procedure tApache.Admin;
var
  App, Param: string;
begin
  inherited;
  if Config.ServicePorts.Apache = 80 then
    Param := 'http://localhost/'
  else
    Param := 'http://localhost:' + IntToStr(Config.ServicePorts.Apache) + '/';
  if Config.BrowserApp <> '' then
  begin
    App := Config.BrowserApp;
    ExecuteFile(App, Param, '', SW_SHOW);
    AddLog(Format(_('Executing "%s" "%s"'), [App, Param]), ltDebug);
  end
  else
  begin
    ExecuteFile(Param, '', '', SW_SHOW);
    AddLog(Format(_('Executing "%s"'), [Param]), ltDebug);
  end;
end;

procedure tApache.CheckIsService;
var
  s: string;
  path: string;
begin
  inherited CheckIsService(RemoveWhiteSpace(Config.ServiceNames.Apache));
  if isService then
  begin
    s := _('Service installed');
    path := GetServicePath(RemoveWhiteSpace(Config.ServiceNames.Apache));
  end
  else
    s := _('Service not installed');
  AddLog(Format(_('Checking for service (name="%s"): %s'), [RemoveWhiteSpace(Config.ServiceNames.Apache), s]), ltDebug);
  if (path <> '') then
  begin
    if (Pos(LowerCase(basedir + 'apache\bin\' + Config.BinaryNames.Apache), LowerCase(path)) <> 0) then
      AddLog(Format(_('Service Path: %s'), [path]), ltDebug)
    else
    begin
      pStatus.Color := cErrorColor;
      AddLog(Format(_('%s Service detected with wrong path'), [cModuleName]), ltError);
      AddLog(Format(_('Change XAMPP %s and Control Panel settings or'), [cModuleName]), ltError);
      AddLog(_('Uninstall/disable the other service manually first'), ltError);
      AddLog(Format(_('Found Path: %s'), [path]), ltError);
      AddLog(Format(_('Expected Path: "%sapache\bin\%s" -k runservice'), [basedir, Config.BinaryNames.Apache]), ltError);
    end
  end
  else
    AddLog(_('Service Path: Service Not Installed'), ltDebug);
end;

constructor tApache.Create;
var
  ServerApp: string;
begin
  inherited;
  ModuleName := cModuleName;
  OldPIDCount := 0;
  GlobalStatus := 'starting';
  AddLog(_('Initializing module...'), ltDebug);
  ServerApp := basedir + 'apache\bin\' + Config.BinaryNames.Apache;
  AddLog(_('Checking for module existence...'), ltDebug);
  if not FileExists(ServerApp) then
  begin
    pStatus.Color := cErrorColor;
    AddLog(Format(_('Problem detected: %s Not Found!'), [cModuleName]), ltError);
    AddLog(Format(_('Disabling %s buttons'), [cModuleName]), ltError);
    AddLog(_('Run this program from your XAMPP root directory!'), ltError);
    bAdmin.Enabled := False;
    bbService.Enabled := False;
    bStartStop.Enabled := False;
  end;

  if not Config.EnableServices.Apache then
  begin
    AddLog(Format(_('%s Service is disabled.'), [cModuleName]), ltDebug);
    fmain.bApacheService.Enabled := False;
  end;

  AddLog(_('Checking for required tools...'), ltDebug);

  CheckIsService;
  CheckPorts;
end;

destructor tApache.Destroy;
begin
  inherited;
end;

procedure tApache.CheckPorts;
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
  ServerApp := basedir + 'apache\bin\' + Config.BinaryNames.Apache;
  Ports[0] := Config.ServicePorts.Apache;
  Ports[1] := Config.ServicePorts.ApacheSSL;

  path := GetServicePath(RemoveWhiteSpace(Config.ServiceNames.Apache));

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
          AddLog(Format(_('Port %d in use by "%s" with PID %d!'), [Ports[p], PortBlocker, PortBlockerPID]), ltError);
          AddLog(Format(_('%s WILL NOT start without the configured ports free!'), [cModuleName]), ltError);
          AddLog(_('You need to uninstall/disable/reconfigure the blocking application'), ltError);
          AddLog(Format(_('or reconfigure %s and the Control Panel to listen on a different port'), [cModuleName]), ltError);
        end;
      end;
    end;
  end;
end;

procedure tApache.ServiceInstall;
var
  App, Param: string;
  RC: integer;
begin
  App := basedir + 'apache\bin\' + Config.BinaryNames.Apache;
  Param := '-k install -n "' + RemoveWhiteSpace(Config.ServiceNames.Apache) + '"';
  AddLog(_('Installing service...'));
  AddLog(Format(_('Executing "%s %s"'), [App, Param]), ltDebug);
  RC := RunAsAdmin(App, Param, SW_HIDE);
  if RC = 0 then
    AddLog(Format(_('Return code: %d'), [RC]), ltDebug)
  else
    AddLog(Format(_('There may be an error, return code: %d - %s'), [RC, SystemErrorMessage(RC)]), ltError);
end;

procedure tApache.ServiceUnInstall;
var
  App, Param: string;
  RC: Cardinal;
begin
  App := basedir + 'apache\bin\' + Config.BinaryNames.Apache;
  Param := '-k uninstall -n "' + RemoveWhiteSpace(Config.ServiceNames.Apache) + '"';
  AddLog(_('Uninstalling service...'));
  AddLog(Format(_('Executing "%s %s"'), [App, Param]), ltDebug);
  RC := RunAsAdmin(App, Param, SW_HIDE);
  if RC = 0 then
    AddLog(Format(_('Return code: %d'), [RC]), ltDebug)
  else
    AddLog(Format(_('There may be an error, return code: %d - %s'), [RC, SystemErrorMessage(RC)]), ltError);
end;

procedure tApache.Start;
var
  App, ErrMsg: string;
  RC: Cardinal;
begin
  GlobalStatus := 'starting';
  CheckPorts;
  if isService and Config.EnableServices.Apache then
  begin
    AddLog(Format(_('Attempting to start %s service...'), [cModuleName]));
    App := Format('start "%s"', [RemoveWhiteSpace(Config.ServiceNames.Apache)]);
    AddLog(Format(_('Executing "%s"'), ['net ' + App]), ltDebug);
    RC := RunAsAdmin('net', App, SW_HIDE);
    // RC := StartService(RemoveWhiteSpace(Config.ServiceNames.Apache));
    if (RC = 0) or (RC = 1077) then
      AddLog(Format(_('Return code: %d'), [RC]), ltDebug)
    else
    begin
      ErrMsg := SysUtils.SysErrorMessage(System.GetLastError);
      AddLog(Format(_('There may be an error, return code: %d - %s'), [RC, SystemErrorMessage(RC)]), ltError);
    end;
  end
  else
  begin
    AddLog(Format(_('Attempting to start %s app...'), [cModuleName]));
    App := basedir + 'apache\bin\' + Config.BinaryNames.Apache;
    AddLog(Format(_('Executing "%s"'), [App]), ltDebug);
    RC := RunProcess(App, SW_HIDE, False);
    if RC = 0 then
      AddLog(Format(_('Return code: %d'), [RC]), ltDebug)
    else
    begin
      ErrMsg := SysUtils.SysErrorMessage(System.GetLastError);
      AddLog(Format(_('There may be an error, return code: %d - %s'), [RC, SystemErrorMessage(RC)]), ltError);
    end;
  end;
end;

procedure tApache.Stop;
var
  i, pPID: integer;
  App: string;
  ErrMsg: string;
  RC: Cardinal;
begin
  GlobalStatus := 'stopping';
  if isService and Config.EnableServices.Apache then
  begin
    AddLog(Format(_('Attempting to stop %s service...'), [cModuleName]));
    App := Format('stop "%s"', [RemoveWhiteSpace(Config.ServiceNames.Apache)]);
    AddLog(Format(_('Executing "%s"'), ['net ' + App]), ltDebug);
    RC := RunAsAdmin('net', App, SW_HIDE);
    // RC := StopService(RemoveWhiteSpace(Config.ServiceNames.Apache));
    if RC = 0 then
      AddLog(Format(_('Return code: %d'), [RC]), ltDebug)
    else
    begin
      ErrMsg := SysUtils.SysErrorMessage(System.GetLastError);
      AddLog(Format(_('There may be an error, return code: %d - %s'), [RC, SystemErrorMessage(RC)]), ltError);
    end;
  end
  else
  begin
    if PIDList.Count > 0 then
    begin
      for i := 0 to PIDList.Count - 1 do
      begin
        pPID := integer(PIDList[i]);
        AddLog(_('Attempting to stop') + ' ' + cModuleName + ' ' + Format('(PID: %d)', [pPID]));
        // App := Format(basedir + 'apache\bin\pv.exe -f -k -q -i %d', [pPID]);
        // AddLog(Format(_('Executing "%s"'), [App]), ltDebug);
        // RC := RunProcess(App, SW_HIDE, false);
        if not TerminateProcessByID(pPID) then
        begin
          AddLog(Format(_('Problem killing PID %d'), [pPID]), ltError);
          AddLog(_('Check that you have the proper privileges'), ltError);
        end;
      end;
    end
    else
    begin
      AddLog(_('No PIDs found?!'));
    end;
  end;
end;

procedure tApache.UpdateStatus;
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
  isRunning := False;
  PIDList.Clear;
  ErrorStatus := 0;
  // for p := 0 to Processes.ProcessList.Count - 1 do
  // begin
  // ProcInfo := Processes.ProcessList[p];
  // if (pos(Config.BinaryNames.Apache, ProcInfo.Module) = 1) then
  // begin
  // if (pos(IntToStr(Config.ServicePorts.Apache),NetStatTable.GetPorts4PID(ProcInfo.PID)) <> 0) or
  // (pos(IntToStr(Config.ServicePorts.ApacheSSL),NetStatTable.GetPorts4PID(ProcInfo.PID)) <> 0) or
  // (pos(LowerCase(BaseDir), LowerCase(ProcInfo.ExePath)) <> 0) then
  // begin
  // isRunning := true;
  // PIDList.Add(Pointer(ProcInfo.PID));
  // end;
  // end;
  // end;

  for p := 0 to Processes.ProcessList2.Count - 1 do
  begin
    pname := Processes.ProcessList2[p];
    if (Pos(LowerCase(Config.BinaryNames.Apache), LowerCase(pname)) = 1) then
    begin
      currPID := integer(Processes.ProcessList2.Objects[p]);
      if (isService) then
      begin
        ppath := LowerCase(GetServiceWithPid(currPID));
        if ((Pos(IntToStr(Config.ServicePorts.Apache), NetStatTable.GetPorts4PID(currPID)) <> 0) and (Pos(LowerCase(basedir), ppath) <> 0)) or
          ((Pos(IntToStr(Config.ServicePorts.ApacheSSL), NetStatTable.GetPorts4PID(currPID)) <> 0) and (Pos(LowerCase(basedir), ppath) <> 0)) or
          (Pos(LowerCase(basedir), ppath) <> 0) then
        begin
          isRunning := True;
          PIDList.Add(Pointer(currPID));
        end;
      end
      else
      begin
        ppath := LowerCase(Processes.GetProcessPath(currPID));
        if ((Pos(IntToStr(Config.ServicePorts.Apache), NetStatTable.GetPorts4PID(currPID)) <> 0) and (Pos(LowerCase(basedir), ppath) <> 0)) or
          ((Pos(IntToStr(Config.ServicePorts.ApacheSSL), NetStatTable.GetPorts4PID(currPID)) <> 0) and (Pos(LowerCase(basedir), ppath) <> 0)) or
          (Pos(LowerCase(basedir), ppath) <> 0) then
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

  if (byte(isRunning) <> oldIsRunningByte) or (OldPIDCount <> PIDList.Count) then
  begin
    if (oldIsRunningByte <> 2) and (byte(isRunning) <> oldIsRunningByte) then
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
      if (PIDList.Count = 2) or ((PIDList.Count = 1) and (isService)) then
      begin
        pStatus.Color := cRunningColor;
        bStartStop.Caption := _('Stop');
        bAdmin.Enabled := True;
        fmain.ApacheTray.ImageIndex := 15;
        fmain.ApacheTrayControl.Caption := _('Stop');
      end
      else
      begin
        pStatus.Color := cPartialColor;
        bStartStop.Caption := _('Stop');
        bAdmin.Enabled := True;
      end;
    end
    else
    begin
      pStatus.Color := cStoppedColor;
      bStartStop.Caption := _('Start');
      bAdmin.Enabled := False;
      fmain.ApacheTray.ImageIndex := 16;
      fmain.ApacheTrayControl.Caption := _('Start');
    end;
  end;

  OldPIDCount := PIDList.Count;

  if AutoStart then
  begin
    AutoStart := False;
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
