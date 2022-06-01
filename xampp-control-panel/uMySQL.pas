unit uMySQL;

interface

uses GnuGettext, uBaseModule, SysUtils, Classes, Windows, ExtCtrls, StdCtrls, Buttons, uNetstatTable, uTools, uProcesses_new, uServices;

type
  tMySQL = class(tBaseModule)
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
  cModuleName = 'MySQL';

  { tMySQL }

procedure tMySQL.AddLog(Log: string; LogType: tLogType);
begin
  inherited AddLog('mysql', Log, LogType);
end;

procedure tMySQL.Admin;
var
  App, Param: string;
begin
  if Config.ServicePorts.Apache = 80 then
    Param := 'http://localhost/phpmyadmin/'
  else
    Param := 'http://localhost:' + IntToStr(Config.ServicePorts.Apache) + '/phpmyadmin';
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

procedure tMySQL.CheckIsService;
var
  s: string;
  path: string;
begin
  inherited CheckIsService(Config.ServiceNames.MySQL);
  if isService then
  begin
    s := _('Service installed');
    path := GetServicePath(Config.ServiceNames.MySQL);
  end
  else
    s := _('Service not installed');
  AddLog(Format(_('Checking for service (name="%s"): %s'), [Config.ServiceNames.MySQL, s]), ltDebug);
  if (path <> '') then
  begin
    if (Pos(LowerCase(basedir + 'mysql\bin\' + Config.BinaryNames.MySQL), LowerCase(path)) <> 0) then
      AddLog(Format(_('Service Path: %s'), [path]), ltDebug)
    else
    begin
      pStatus.Color := cErrorColor;
      AddLog(Format(_('%s Service detected with wrong path'), [cModuleName]), ltError);
      AddLog(Format(_('Change XAMPP %s and Control Panel settings or'), [cModuleName]), ltError);
      AddLog(_('Uninstall/disable the other service manually first'), ltError);
      AddLog(Format(_('Found Path: %s'), [path]), ltError);
      AddLog(Format(_('Expected Path: %smysql\bin\%s --defaults-file=%smysql\bin\my.ini %s'), [basedir, Config.BinaryNames.MySQL, basedir,
        Config.ServiceNames.MySQL]), ltError);
    end
  end
  else
    AddLog(_('Service Path: Service Not Installed'), ltDebug);
end;

constructor tMySQL.Create;
var
  ServerApp: string;
begin
  inherited;
  ModuleName := cModuleName;
  GlobalStatus := 'starting';
  AddLog(_('Initializing module...'), ltDebug);
  ServerApp := basedir + 'mysql\bin\' + Config.BinaryNames.MySQL;
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

  if not Config.EnableServices.MySQL then
  begin
    AddLog(Format(_('%s Service is disabled.'), [cModuleName]), ltDebug);
    fmain.bMySQLService.Enabled := False;
  end;

  AddLog(_('Checking for required tools...'), ltDebug);

  CheckIsService;
  CheckPorts;
end;

destructor tMySQL.Destroy;
begin
  inherited;
end;

procedure tMySQL.CheckPorts;
var
  PortBlocker: string;
  PortBlockerPID: integer;
  path: string;
  ServerApp: string;
  pbpath: string;
  pbspath: string;
  ServerPort: Integer;
begin
  ServerApp := basedir + 'mysql\bin\' + Config.BinaryNames.MySQL;

  path := GetServicePath(Config.ServiceNames.MySQL);

  if Config.EnableChecks.CheckDefaultPorts then
  begin
    ServerPort := Config.ServicePorts.MySQL;
    AddLog(_('Checking default ports...'), ltDebug);
    PortBlockerPID := NetStatTable.isPortInUsePID(ServerPort);
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
          AddLog(Format(_('XAMPP %s is already running on port %d'), [cModuleName, ServerPort]), ltInfo);
        end
        //else if (Pos(LowerCase(PortBlocker), LowerCase(path)) <> 0) and (isService = True) then
        else if (Pos(LowerCase(pbspath), LowerCase(path)) <> 0) and (isService = True) and (Pos(LowerCase(ServerApp), LowerCase(pbspath)) <> 0) then
        begin
          AddLog(Format(_('XAMPP %s Service is already running on port %d'), [cModuleName, ServerPort]), ltInfo);
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
        AddLog(Format(_('Port %d in use by "%s"!'), [ServerPort, PortBlocker]), ltError);
        AddLog(Format(_('%s WILL NOT start without the configured ports free!'), [cModuleName]), ltError);
        AddLog(_('You need to uninstall/disable/reconfigure the blocking application'), ltError);
        AddLog(Format(_('or reconfigure %s and the Control Panel to listen on a different port'), [cModuleName]), ltError);
      end;
    end;
  end;
end;

procedure tMySQL.ServiceInstall;
var
  App, Param: string;
  RC: Integer;
begin
  App := '"' + basedir + 'mysql\bin\' + Config.BinaryNames.MySQL + '"';
  Param := '--install "' + Config.ServiceNames.MySQL + '" --defaults-file="' + basedir + 'mysql\bin\my.ini"';
  AddLog(_('Installing service...'));
  AddLog(Format(_('Executing %s %s'), [App, Param]), ltDebug);
  RC := RunAsAdmin(App, Param, SW_HIDE);
  if RC = 0 then
    AddLog(Format(_('Return code: %d'), [RC]), ltDebug)
  else
    AddLog(Format(_('There may be an error, return code: %d - %s'), [RC, SystemErrorMessage(RC)]), ltError);
end;

procedure tMySQL.ServiceUnInstall;
var
  App, Param: string;
  RC: Cardinal;
begin
  App := basedir + 'mysql\bin\' + Config.BinaryNames.MySQL;
  Param := '--remove "' + Config.ServiceNames.MySQL + '"';
  AddLog('Uninstalling service...');
  AddLog(Format(_('Executing %s %s'), [App, Param]), ltDebug);
  RC := RunAsAdmin(App, Param, SW_HIDE);
  if RC = 0 then
    AddLog(Format(_('Return code: %d'), [RC]), ltDebug)
  else
    AddLog(Format(_('There may be an error, return code: %d - %s'), [RC, SystemErrorMessage(RC)]), ltError);
end;

procedure tMySQL.Start;
var
  App: string;
  RC: Cardinal;
begin
  GlobalStatus := 'starting';
  CheckPorts;
  if isService and Config.EnableServices.MySQL then
  begin
    AddLog(Format(_('Attempting to start %s service...'), [cModuleName]));
    App := Format('start "%s"', [Config.ServiceNames.MySQL]);
    AddLog(Format(_('Executing "%s"'), ['net ' + App]), ltDebug);
    RC := RunAsAdmin('net', App, SW_HIDE);
    if RC = 0 then
      AddLog(Format(_('Return code: %d'), [RC]), ltDebug)
    else
    begin
      AddLog(Format(_('There may be an error, return code: %d - %s'), [RC, SystemErrorMessage(RC)]), ltError);
    end;
  end
  else
  begin
    AddLog(Format(_('Attempting to start %s app...'), [cModuleName]));
    App := '"' + basedir + 'mysql\bin\' + Config.BinaryNames.MySQL + '" --defaults-file="' + basedir + 'mysql\bin\my.ini" --standalone';
    AddLog(Format(_('Executing "%s"'), [App]), ltDebug);
    RC := RunProcess(App, SW_HIDE, False);
    if RC = 0 then
      AddLog(Format(_('Return code: %d'), [RC]), ltDebug)
    else
    begin
      AddLog(Format(_('There may be an error, return code: %d - %s'), [RC, SystemErrorMessage(RC)]), ltError);
    end;
  end;
end;

procedure tMySQL.Stop;
var
  i, pPID: Integer;
  App: string;
  RC: Cardinal;
begin
  GlobalStatus := 'stopping';
  if isService and Config.EnableServices.MySQL then
  begin
    AddLog(Format(_('Attempting to stop %s service...'), [cModuleName]));
    App := Format('stop "%s"', [Config.ServiceNames.MySQL]);
    AddLog(Format(_('Executing "%s"'), ['net ' + App]), ltDebug);
    RC := RunAsAdmin('net', App, SW_HIDE);
    if RC = 0 then
      AddLog(Format(_('Return code: %d'), [RC]), ltDebug)
    else
    begin
      AddLog(Format(_('There may be an error, return code: %d - %s'), [RC, SystemErrorMessage(RC)]), ltError);
    end;
  end
  else
  begin
    if PIDList.Count > 0 then
    begin
      for i := 0 to PIDList.Count - 1 do
      begin
        pPID := Integer(PIDList[i]);
        AddLog(Format(_('Attempting to stop %s app...'), [cModuleName]));
        if not TerminateProcessByID(pPID) then
        begin
          AddLog(Format(_('There may be an error, return code: %d - %s'), [RC, SystemErrorMessage(RC)]), ltError);
        end;
      end;
    end
    else
    begin
      AddLog(_('No PIDs found?!'));
    end;


  end;
end;

procedure tMySQL.UpdateStatus;
var
  p: Integer;
  // ProcInfo: TProcInfo;
  s: string;
  ports: string;
  pname: string;
  ppath: string;
  currPID: Integer;
  ErrorStatus: Integer;
begin
  isRunning := False;
  PIDList.Clear;
  ErrorStatus := 0;
  // for p := 0 to Processes.ProcessList.Count - 1 do
  // begin
  // ProcInfo := Processes.ProcessList[p];
  // if (pos(Config.BinaryNames.MySQL, ProcInfo.Module) = 1) then
  // begin
  // if (pos(IntToStr(Config.ServicePorts.MySQL),NetStatTable.GetPorts4PID(ProcInfo.PID)) <> 0) or
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
    if (Pos(LowerCase(Config.BinaryNames.MySQL), LowerCase(pname)) = 1) then
    begin
      currPID := Integer(Processes.ProcessList2.Objects[p]);
      if (isService) then
      begin
        ppath := LowerCase(GetServiceWithPid(currPID));
        if ((Pos(IntToStr(Config.ServicePorts.MySQL), NetStatTable.GetPorts4PID(currPID)) <> 0) and (Pos(LowerCase(basedir), ppath) <> 0)) or
          (Pos(LowerCase(basedir), ppath) <> 0) then
        begin
          isRunning := True;
          PIDList.Add(Pointer(currPID));
        end;
      end
      else
      begin
        ppath := LowerCase(Processes.GetProcessPath(currPID));
        if ((Pos(IntToStr(Config.ServicePorts.MySQL), NetStatTable.GetPorts4PID(currPID)) <> 0) and (Pos(LowerCase(basedir), ppath) <> 0)) or
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
    s := IntToStr(Integer(PIDList[p]))
  else
    s := s + #13 + IntToStr(Integer(PIDList[p]));
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
  ports := NetStatTable.GetPorts4PID(Integer(PIDList[p]));
  if ports <> '' then
    s := RemoveDuplicatePorts(ports);
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
    fmain.MySQLTray.ImageIndex := 15;
    fmain.MySQLTrayControl.Caption := _('Stop');
  end
  else
  begin
    pStatus.Color := cStoppedColor;
    bStartStop.Caption := _('Start');
    bAdmin.Enabled := False;
    fmain.MySQLTray.ImageIndex := 16;
    fmain.MySQLTrayControl.Caption := _('Start');
  end;
end;

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
