unit uMercury;

interface

uses GnuGettext, uBaseModule, SysUtils, Classes, Windows, ExtCtrls, StdCtrls,
  Buttons,
  uNetstatTable, uTools, uProcesses_new, uServices;

type
  tMercury = class(tBaseModule)
    OldPIDs, OldPorts: string;
    GlobalStatus: string;
    procedure ServiceInstall; override;
    procedure ServiceUnInstall; override;
    procedure Start; override;
    procedure Stop; override;
    procedure Admin; override;
    procedure CheckPorts;
    procedure UpdateStatus; override;
    procedure AddLog(Log: string; LogType: tLogType = ltDefault); reintroduce;
    constructor Create(pbbService: TBitBtn; pStatusPanel: tPanel; pPIDLabel, pPortLabel: tLabel; pStartStopButton, pAdminButton: TBitBtn);
    destructor Destroy; override;
  end;

implementation

uses uMain;

const
  cModuleName = 'Mercury';

var
  hWindow: HWND;

  { tMercury }

procedure tMercury.AddLog(Log: string; LogType: tLogType);
begin
  inherited AddLog('mercury', Log, LogType);
end;

function EnumProcess(hHwnd: HWND; lParam: integer): boolean; stdcall;
var
  pPid: DWORD;
  title, ClassName: string;
begin
  if (hHwnd = 0) then
  begin
    result := false;
  end
  else
  begin
    GetWindowThreadProcessId(hHwnd, pPid);
    SetLength(ClassName, 255);
    SetLength(ClassName, GetClassName(hHwnd, PChar(ClassName), Length(ClassName)));
    SetLength(title, 255);
    SetLength(title, GetWindowText(hHwnd, PChar(title), Length(title)));
    if title = 'Mercury/32' then
    begin
      hWindow := hHwnd;
    end;

    result := true;
  end;
end;

procedure tMercury.Admin;
begin
  hWindow := 0;
  EnumWindows(@EnumProcess, 0);
  if hWindow <> 0 then
    ShowWindow(hWindow, SW_SHOW);
end;

constructor tMercury.Create;
var
  ServerApp: string;
begin
  inherited;
  ModuleName := cModuleName;
  isService := false;
  GlobalStatus := 'starting';
  AddLog(_('Initializing module...'), ltDebug);
  ServerApp := basedir + 'MercuryMail\' + Config.BinaryNames.Mercury;
  AddLog(_('Checking for module existence...'), ltDebug);
  if not FileExists(ServerApp) then
  begin
    pStatus.Color := cErrorColor;
    AddLog(Format(_('Problem detected: %s Not Found!'),[cModuleName]), ltError);
    AddLog(Format(_('Disabling %s buttons'),[cModuleName]), ltError);
    AddLog(_('Run this program from your XAMPP root directory!'), ltError);
    bAdmin.Enabled := False;
    bbService.Enabled := False;
    bStartStop.Enabled := False;
  end;

  AddLog(_('Checking for required tools...'), ltDebug);

  CheckPorts;
end;

destructor tMercury.Destroy;
begin
  inherited;
end;

procedure tMercury.CheckPorts;
var
  PortBlocker: string;
  PortBlockerPID: integer;
  p: integer;
  ServerApp: string;
  pbpath: string;
  pbspath: string;
  Ports: array [0 .. 6] of integer;
begin
  ServerApp := basedir + 'MercuryMail\' + Config.BinaryNames.Mercury;
  Ports[0] := Config.ServicePorts.Mercury1;
  Ports[1] := Config.ServicePorts.Mercury2;
  Ports[2] := Config.ServicePorts.Mercury3;
  Ports[3] := Config.ServicePorts.Mercury4;
  Ports[4] := Config.ServicePorts.Mercury5;
  Ports[5] := Config.ServicePorts.Mercury6;
  Ports[6] := Config.ServicePorts.Mercury7;

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
        //if (Pos(LowerCase(ServerApp), LowerCase(PortBlocker)) <> 0) then
        pbpath := Processes.GetProcessPath(PortBlockerPID);
        pbspath := GetServiceWithPid(PortBlockerPID);
        AddLog(Format(_('Portblocker Path: %s'), [pbpath]), ltDebug);
        AddLog(Format(_('Portblocker Service Path: %s'), [pbspath]), ltDebug);
        if (Pos(LowerCase(ServerApp), LowerCase(pbpath)) <> 0) then
        begin
          AddLog(Format(_('XAMPP %s is already running on port %d'), [cModuleName, Ports[p]]), ltInfo);
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

procedure tMercury.ServiceInstall;
begin
  inherited;
end;

procedure tMercury.ServiceUnInstall;
begin
  inherited;
end;

procedure tMercury.Start;
var
  App: string;
  RC : Cardinal;
begin
  GlobalStatus := 'starting';
  CheckPorts;
  App := basedir + 'MercuryMail\' + Config.BinaryNames.Mercury;
  AddLog(Format(_('Attempting to start %s app...'), [cModuleName]));
  AddLog(Format(_('Executing "%s"'), [App]), ltDebug);
  RC := RunProcess(App, SW_HIDE, false);
  if RC = 0 then
    AddLog(Format(_('Return code: %d'), [RC]), ltDebug)
  else
    AddLog(Format(_('There may be an error, return code: %d - %s'), [RC, SystemErrorMessage(RC)]), ltError);
end;

procedure tMercury.Stop;
var
  i, pPID: Integer;
begin
  GlobalStatus := 'stopping';
  if PIDList.Count > 0 then
    begin
      for i := 0 to PIDList.Count - 1 do
      begin
        pPID := Integer(PIDList[i]);
        AddLog(_('Attempting to stop') + ' ' + cModuleName + ' ' + Format('(PID: %d)', [pPID]));
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

procedure tMercury.UpdateStatus;
var
  p: integer;
  //ProcInfo: TProcInfo;
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

//  for p := 0 to Processes.ProcessList.Count - 1 do
//  begin
//    ProcInfo := Processes.ProcessList[p];
//    if (pos(Config.BinaryNames.Mercury, ProcInfo.Module) = 1) then
//    begin
//      if (pos(IntToStr(Config.ServicePorts.Mercury1),NetStatTable.GetPorts4PID(ProcInfo.PID)) <> 0) or
//      (pos(IntToStr(Config.ServicePorts.Mercury2),NetStatTable.GetPorts4PID(ProcInfo.PID)) <> 0) or
//      (pos(IntToStr(Config.ServicePorts.Mercury3),NetStatTable.GetPorts4PID(ProcInfo.PID)) <> 0) or
//      (pos(IntToStr(Config.ServicePorts.Mercury4),NetStatTable.GetPorts4PID(ProcInfo.PID)) <> 0) or
//      (pos(IntToStr(Config.ServicePorts.Mercury5),NetStatTable.GetPorts4PID(ProcInfo.PID)) <> 0) or
//      (pos(IntToStr(Config.ServicePorts.Mercury6),NetStatTable.GetPorts4PID(ProcInfo.PID)) <> 0) or
//      (pos(IntToStr(Config.ServicePorts.Mercury7),NetStatTable.GetPorts4PID(ProcInfo.PID)) <> 0) or
//      (pos(BaseDir, ProcInfo.ExePath) <> 0) then
//      begin
//        isRunning := true;
//        PIDList.Add(Pointer(ProcInfo.PID));
//      end;
//    end;
//  end;

  for p := 0 to Processes.ProcessList2.Count - 1 do
  begin
    pname := Processes.ProcessList2[p];
    if (pos(LowerCase(Config.BinaryNames.Mercury), LowerCase(pname)) = 1) then
    begin
      currPID := Integer(Processes.ProcessList2.Objects[p]);
      ppath := LowerCase(Processes.GetProcessPath(currPID));
      if ((pos(IntToStr(Config.ServicePorts.Mercury1),NetStatTable.GetPorts4PID(currPID)) <> 0) and (pos(LowerCase(BaseDir), ppath) <> 0)) or
      ((pos(IntToStr(Config.ServicePorts.Mercury2),NetStatTable.GetPorts4PID(currPID)) <> 0) and (pos(LowerCase(BaseDir), ppath) <> 0)) or
      ((pos(IntToStr(Config.ServicePorts.Mercury3),NetStatTable.GetPorts4PID(currPID)) <> 0) and (pos(LowerCase(BaseDir), ppath) <> 0)) or
      ((pos(IntToStr(Config.ServicePorts.Mercury4),NetStatTable.GetPorts4PID(currPID)) <> 0) and (pos(LowerCase(BaseDir), ppath) <> 0)) or
      ((pos(IntToStr(Config.ServicePorts.Mercury5),NetStatTable.GetPorts4PID(currPID)) <> 0) and (pos(LowerCase(BaseDir), ppath) <> 0)) or
      ((pos(IntToStr(Config.ServicePorts.Mercury6),NetStatTable.GetPorts4PID(currPID)) <> 0) and (pos(LowerCase(BaseDir), ppath) <> 0)) or
      ((pos(IntToStr(Config.ServicePorts.Mercury7),NetStatTable.GetPorts4PID(currPID)) <> 0) and (pos(LowerCase(BaseDir), ppath) <> 0)) or
      (pos(LowerCase(BaseDir), ppath) <> 0) then
      begin
        isRunning := true;
        PIDList.Add(Pointer(currPID));
      end;
    end;
  end;

  s := '';
  // Checking processes
  for p := 0 to PIDList.Count - 1 do
  begin
    if p = 0 then
      s := InttoStr(integer(PIDList[p]))
    else
      s := s + #13 + InttoStr(integer(PIDList[p]));
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
      fMain.MercuryTray.ImageIndex := 15;
      fMain.MercuryTrayControl.Caption := _('Stop');
    end
    else
    begin
      pStatus.Color := cStoppedColor;
      bStartStop.Caption := _('Start');
      bAdmin.Enabled := false;
      fMain.MercuryTray.ImageIndex := 16;
      fMain.MercuryTrayControl.Caption := _('Start');
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
