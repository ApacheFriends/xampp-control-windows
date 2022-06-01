unit uTomcat;

interface

uses GnuGettext, uBaseModule, SysUtils, Classes, Windows, ExtCtrls, StdCtrls, Buttons, uNetstatTable, uTools, uProcesses_new, uServices;

type
  tTomcat = class(tBaseModule)
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

const cModuleName = 'Tomcat';

  { tTomcat }

procedure tTomcat.AddLog(Log: string; LogType: tLogType);
begin
  inherited AddLog(cModuleName, Log, LogType);
end;

procedure tTomcat.Admin;
var
  App, Param: string;
begin
  Param := 'http://localhost:' + IntToStr(Config.ServicePorts.TomcatHTTP) + '/';
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

procedure tTomcat.CheckIsService;
var
  s: string;
  path: string;
begin
  inherited CheckIsService(RemoveWhiteSpace(Config.ServiceNames.Tomcat));
  if isService then
  begin
    s := _('Service installed');
    path:=GetServicePath(RemoveWhiteSpace(Config.ServiceNames.Tomcat));
  end
  else
    s := _('Service not installed');
  AddLog(Format(_('Checking for service (name="%s"): %s'), [RemoveWhiteSpace(Config.ServiceNames.Tomcat), s]), ltDebug);
  if (path<>'') then
  begin
    if (Pos(LowerCase(basedir + 'tomcat\bin\' + Config.BinaryNames.Tomcat), LowerCase(path))<>0) then
      AddLog(Format(_('Service Path: %s'), [path]), ltDebug)
    else
    begin
      pStatus.Color := cErrorColor;
      AddLog(Format(_('%s Service detected with wrong path'),[cModuleName]), ltError);
      AddLog(Format(_('Change XAMPP %s and Control Panel settings or'),[cModuleName]), ltError);
      AddLog(_('Uninstall/disable the other service manually first'), ltError);
      AddLog(Format(_('Found Path: %s'), [Path]), ltError);
      AddLog(Format(_('Expected Path: %stomcat\bin\%s //RS//%s'), [basedir, Config.BinaryNames.Tomcat, Config.ServiceNames.Tomcat]), ltError);
    end
  end
  else
      AddLog(_('Service Path: Service Not Installed'), ltDebug);
end;

constructor tTomcat.Create(pbbService: TBitBtn; pStatusPanel: tPanel; pPIDLabel, pPortLabel: tLabel; pStartStopButton, pAdminButton: TBitBtn);
var
  ServerApp: string;
  ReqTools: array [0 .. 2] of string;
begin
  inherited;
  ModuleName := cModuleName;
  GlobalStatus := 'running';
  AddLog(_('Initializing module...'), ltDebug);
  ServerApp := basedir + 'tomcat\bin\' + Config.BinaryNames.Tomcat;
  ReqTools[0] := basedir + 'catalina_start.bat';
  ReqTools[1] := basedir + 'catalina_stop.bat';
  ReqTools[2] := basedir + 'catalina_service.bat';
  AddLog(_('Checking for module existence...'), ltDebug);
  if (not FileExists(ServerApp)) then
  begin
    pStatus.Color := cErrorColor;
    AddLog(Format(_('Problem detected: %s Not Found!'),[cModuleName]), ltError);
    AddLog(Format(_('Disabling %s buttons'),[cModuleName]), ltError);
    AddLog(_('Run this program from your XAMPP root directory!'), ltError);
    bAdmin.Enabled := False;
    bbService.Enabled := False;
    bStartStop.Enabled := False;
  end;

  if not Config.EnableServices.Tomcat then
  begin
    AddLog(Format(_('%s Service is disabled.'),[cModuleName]), ltDebug);
    fmain.bTomcatService.Enabled := false;
  end;

  AddLog(_('Checking for required tools...'), ltDebug);
  if not FileExists(ReqTools[0]) then
  begin
    pStatus.Color := cErrorColor;
    AddLog(_('Problem detected: Required Tool catalina_start.bat Not Found!'), ltError);
  end;
  if not FileExists(ReqTools[1]) then
  begin
    pStatus.Color := cErrorColor;
    AddLog(_('Problem detected: Required Tool catalina_stop.bat Not Found!'), ltError);
  end;
  if not FileExists(ReqTools[2]) then
  begin
    pStatus.Color := cErrorColor;
    AddLog(_('Problem detected: Required Tool catalina_service.bat Not Found!'), ltError);
  end;

  CheckIsService;
  CheckPorts;
end;

destructor tTomcat.Destroy;
begin
  inherited;
end;

procedure tTomcat.CheckPorts;
var
  PortBlocker: string;
  PortBlockerPID: integer;
  path: string;
  p: integer;
  ServerApp: string;
  pbpath: string;
  pbspath: string;
  Ports: array [0 .. 2] of integer;
begin
  ServerApp := basedir + 'tomcat\bin\' + Config.BinaryNames.Tomcat;
  Ports[0] := Config.ServicePorts.Tomcat;
  Ports[1] := Config.ServicePorts.TomcatHTTP;
  Ports[2] := Config.ServicePorts.TomcatAJP;

  path:=GetServicePath(RemoveWhiteSpace(Config.ServiceNames.Tomcat));

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
        if (pos(LowerCase('java.exe'), LowerCase(PortBlocker))<>0) or (pos(LowerCase('javaw.exe'), LowerCase(PortBlocker))<>0) then
        begin
          AddLog(Format(_('Java is already running on port %d!'), [Ports[p]]), ltInfo);
          AddLog(Format(_('Is %s already running?'),[cModuleName]), ltInfo);
        end
        else if (Pos(LowerCase(ServerApp), LowerCase(pbpath)) <> 0) then
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
          AddLog(Format(_('%s WILL NOT start without the configured ports free!'),[cModuleName]), ltError);
          AddLog(_('You need to uninstall/disable/reconfigure the blocking application'), ltError);
          AddLog(Format(_('or reconfigure %s and the Control Panel to listen on a different port'),[cModuleName]), ltError);
        end;
      end;
    end;
  end;
end;

procedure tTomcat.ServiceInstall;
var
  App, Param: string;
  RC: integer;
begin
  Param := '/c "' + basedir + 'catalina_service.bat" install ' + Config.ServiceNames.Tomcat;
  if FileExists('c:\Windows\sysnative\cmd.exe') then
    App := 'c:\Windows\sysnative\cmd.exe'
  else
    App := 'cmd';
  AddLog(_('Installing service...'));
  AddLog(Format(_('Executing "%s" "%s"'), [App, Param]), ltDebug);
  //RC:=ShellExecute_AndWait('open', App, Param, '', SW_HIDE, true);
  RC:=RunAsAdmin(App, Param, SW_HIDE);
  AddLog(Format(_('Return code: %d'), [RC]), ltDebug);
  if(RC<>0) then
  begin
    AddLog(Format(_('%s Service Install stopped with errors, return code: %d'), [cModuleName, RC]), ltError);
    AddLog(_('Make sure you have Java JDK or JRE installed and the required ports are free'), ltError);
    AddLog(_('Check the "/xampp/tomcat/logs" folder for more information'), ltError);
  end;
end;

procedure tTomcat.ServiceUnInstall;
var
  App, Param: string;
  RC: integer;
begin
  Param := '/c "' + basedir + 'catalina_service.bat" remove ' + Config.ServiceNames.Tomcat;
  if FileExists('c:\Windows\sysnative\cmd.exe') then
    App := 'c:\Windows\sysnative\cmd.exe'
  else
    App := 'cmd';
  AddLog(_('Uninstalling service...'));
  AddLog(Format(_('Executing "%s" "%s"'), [App, Param]), ltDebug);
  //RC:=ShellExecute_AndWait('open', App, Param, '', SW_HIDE, true);
  RC:=RunAsAdmin(App, Param, SW_HIDE);
  AddLog(Format(_('Return code: %d'), [RC]), ltDebug);
  if(RC<>0) then
  begin
    AddLog(Format(_('%s Service Uninstall stopped with errors, return code: %d'), [cModuleName, RC]), ltError);
    AddLog(_('Make sure you have Java JDK or JRE installed and the required ports are free'), ltError);
    AddLog(_('Check the "/xampp/tomcat/logs" folder for more information'), ltError);
  end;
end;

procedure tTomcat.Start;
var
  App, Param: string;
  RC: integer;
begin
  GlobalStatus := 'starting';
  CheckPorts;
  if isService and Config.EnableServices.Tomcat then
  begin
    AddLog(Format(_('Attempting to start %s service...'), [cModuleName]));
    App := Format('start "%s"', [RemoveWhiteSpace(Config.ServiceNames.Tomcat)]);
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
    Param := '/c "' + basedir + 'catalina_start.bat"';
    if FileExists('c:\Windows\sysnative\cmd.exe') then
      App := 'c:\Windows\sysnative\cmd.exe' // 64 bit? dann DIESE shell starten!
    else
      App := 'cmd';
    AddLog(Format(_('Executing "%s" "%s"'), [App, Param]), ltDebug);
    if Config.TomcatVisible then
      RC:=ShellExecute_AndWait('open', App, Param, '', SW_MINIMIZE, true)
    else
      RC:=ShellExecute_AndWait('open', App, Param, '', SW_HIDE, true);
      AddLog(Format(_('Return code: %d'), [RC]), ltDebug);
      if(RC<>0) then
      begin
        AddLog(Format(_('%s Started/Stopped with errors, return code: %d'), [cModuleName, RC]), ltError);
        AddLog(_('Make sure you have Java JDK or JRE installed and the required ports are free'), ltError);
        AddLog(_('Check the "/xampp/tomcat/logs" folder for more information'), ltError);
      end;
  end;
end;

procedure tTomcat.Stop;
var
  App, Param: string;
  RC: Cardinal;
begin
  GlobalStatus := 'stopping';
  if isService and Config.EnableServices.Tomcat then
  begin
    AddLog(Format(_('Attempting to stop %s service...'), [cModuleName]));
    App := Format('stop "%s"', [RemoveWhiteSpace(Config.ServiceNames.Tomcat)]);
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
    AddLog(Format(_('Attempting to stop %s'), [cModuleName]));
    Param := '/c "' + basedir + 'catalina_stop.bat"';
    if FileExists('c:\Windows\sysnative\cmd.exe') then
      App := 'c:\Windows\sysnative\cmd.exe'
    else
      App := 'cmd';
    AddLog(Format(_('Executing "%s" "%s"'), [App, Param]), ltDebug);
    ExecuteFile(App, Param, basedir, SW_HIDE);
  end;
end;

procedure tTomcat.UpdateStatus;
var
  p: integer;
  //ProcInfo: TProcInfo;
  s: string;
  Ports: string;
  pname: string;
  currPID: integer;
  ErrorStatus: integer;
begin
  isRunning := false;
  PIDList.Clear;
  ErrorStatus := 0;

  // Scan Process List
//  for p := 0 to Processes.ProcessList.Count - 1 do
//  begin
//    ProcInfo := Processes.ProcessList[p];
//    if (pos('java.exe', ProcInfo.Module) = 1) or (pos(Config.BinaryNames.Tomcat, ProcInfo.Module) = 1) then
//    begin
//      if (pos(IntToStr(Config.ServicePorts.TomcatHTTP), NetStatTable.GetPorts4PID(ProcInfo.PID)) <> 0) then
//      begin
//        isRunning := true;
//        PIDList.Add(Pointer(ProcInfo.PID));
//      end;
//    end;
//  end;

  for p := 0 to Processes.ProcessList2.Count - 1 do
  begin
    pname := Processes.ProcessList2[p];
    if (pos('java.exe', LowerCase(pname)) = 1) or (pos(LowerCase(Config.BinaryNames.Tomcat), LowerCase(pname)) = 1) then
    begin
      currPID := Integer(Processes.ProcessList2.Objects[p]);
      if (pos(IntToStr(Config.ServicePorts.TomcatHTTP), NetStatTable.GetPorts4PID(currPID)) <> 0) then
      begin
        isRunning := true;
        PIDList.Add(Pointer(currPID));
      end;
    end;
  end;

  // Update GUI PID List
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

  // Update GUI Ports List
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

  // Change Status
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
        AddLog(Format(_('Error: %s shutdown unexpectedly.'),[cModuleName]), ltError);
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
      bAdmin.Enabled := true;
      fMain.TomcatTray.ImageIndex := 15;
      fMain.TomcatTrayControl.Caption := _('Stop');
    end
    else
    begin
      pStatus.Color := cStoppedColor;
      bStartStop.Caption := _('Start');
      bAdmin.Enabled := false;
      fMain.TomcatTray.ImageIndex := 16;
      fMain.TomcatTrayControl.Caption := _('Start');
    end;
  end;

  if AutoStart then
  begin
    AutoStart := false;
    if isRunning then
    begin
      AddLog(Format(_('Autostart aborted: %s is already running'),[cModuleName]), ltInfo);
    end
    else
    begin
      AddLog(_('Autostart active: starting...'));
      Start;
    end;
  end;
end;

end.
