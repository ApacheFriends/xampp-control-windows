unit uServices;

interface

uses
  GnuGettext, WinSvc, Windows, uTools, JclSvcCtrl, SysUtils;

type
  TServiceStatus = (ssError, ssNotFound, ssUnknown, ssRunning, ssStopped);
  TStartStopService = (ssStart, ssStop);

function GetServiceStatus(name: string): TServiceStatus;
function GetServicePath(name: string): string;
//function StartService(name: string): Integer;
//function StopService(name: string): Integer;
function GetServiceWithPid(const PID: DWORD): string;
// function StartStopService(name: string; StartStopService: TStartStopService):boolean;

implementation

uses uMain;

const
  SERVICE_WIN32_OWN_PROCESS = $00000010;
  SERVICE_WIN32_SHARE_PROCESS = $00000020;

//function StartService(name: string): Integer;
//var
//  Manager: TJclSCManager;
//  Service: TJclNTService;
//begin
//  fMain.AddLog('service', Format(_('Searching for service %s'), [name]), ltDebug);
//  Manager := TJclSCManager.Create;
//  Manager.Refresh(True);
//  if Manager.FindService(name, Service) then
//  begin
//    fMain.AddLog('service', _('Found service, attempting to start'), ltDebug);
//    Service.Start;
//    Result := Service.Win32ExitCode;
//  end
//  else
//    Result := -1;
//  fMain.AddLog('service', Format(_('Return Code %d'), [Result]), ltDebug);
//  Manager.Free;
//end;

//function StopService(name: string): Integer;
//var
//  Manager: TJclSCManager;
//  Service: TJclNTService;
//begin
//  fMain.AddLog('service', Format(_('Searching for service %s'), [name]), ltDebug);
//  Manager := TJclSCManager.Create;
//  Manager.Refresh(True);
//  if Manager.FindService(name, Service) then
//  begin
//    fMain.AddLog('service', _('Found service, attempting to stop'), ltDebug);
//    Service.Stop;
//    Result := Service.Win32ExitCode;
//  end
//  else
//    Result := -1;
//  fMain.AddLog('service', Format(_('Return Code %d'), [Result]), ltDebug);
//  Manager.Free;
//end;

function GetServicePath(name: string): string;
var
  hSCM: SC_Handle;
  hService: SC_Handle;
  ServiceConfig: WinSvc.LPQUERY_SERVICE_CONFIG;
  bytesneeded: DWORD;
begin
  hSCM := OpenSCManager(nil, nil, SC_MANAGER_CONNECT or SC_MANAGER_ENUMERATE_SERVICE or SC_MANAGER_QUERY_LOCK_STATUS or STANDARD_RIGHTS_READ);
  if (hSCM = 0) then
  begin
    Result := 'ERROR: Not Able To Open Service Manager';
    exit;
  end;

  hService := OpenService(hSCM, PWideChar(name), SERVICE_QUERY_CONFIG);
  if (hService = 0) then
  begin
    CloseServiceHandle(hSCM);
    Result := 'ERROR: Service Not Found';
    exit;
  end;

  if (QueryServiceConfig(hService, nil, 0, bytesneeded) = False) then
  begin
    GetMem(ServiceConfig, bytesneeded);
    if (QueryServiceConfig(hService, ServiceConfig, bytesneeded, bytesneeded) = False) then
    begin
      CloseServiceHandle(hService);
      CloseServiceHandle(hSCM);
      Result := 'ERROR: Could Not Get Service Config';
      FreeMem(ServiceConfig);
    end
    else
    begin
      CloseServiceHandle(hService);
      CloseServiceHandle(hSCM);
      Result := ServiceConfig.lpBinaryPathName;
      FreeMem(ServiceConfig);
    end;
  end;

  CloseServiceHandle(hService);
  CloseServiceHandle(hSCM);
end;

function GetServiceWithPid(const PID: DWORD): string;
const
  cnMaxServices = 4096;
type
  TSvcA = array [0 .. cnMaxServices] of TEnumServiceStatus;
  PSvcA = ^TSvcA;
var
  j: Integer;
  nBytesNeeded, nServices, nResumeHandle: DWORD;
  ssa: PSvcA;
  hSCM: THandle;
  hSvc: THandle;
  ssp: SERVICE_STATUS_PROCESS;
  dwSize: DWORD;
begin
  Result := '';
  hSCM := OpenSCManager(nil, SERVICES_ACTIVE_DATABASE, SC_MANAGER_CONNECT or SC_MANAGER_ENUMERATE_SERVICE or SC_MANAGER_QUERY_LOCK_STATUS or STANDARD_RIGHTS_READ);
  if hSCM = 0 then
    exit('Unable to open Service Control Manager');

  nResumeHandle := 0;

  New(ssa);

  EnumServicesStatus(hSCM, SERVICE_WIN32_OWN_PROCESS or SERVICE_WIN32_SHARE_PROCESS, SERVICE_ACTIVE, ssa^[0], sizeof(ssa^), nBytesNeeded,
    nServices, nResumeHandle);

  for j := 0 to nServices - 1 do
  begin
    hSvc := OpenService(hSCM, PChar(StrPas(ssa^[j].lpServiceName)), SERVICE_QUERY_STATUS);
    if hSvc > 0 then
    begin
      try
        if QueryServiceStatusEx(hSvc, SC_STATUS_PROCESS_INFO, @ssp, sizeof(ssp), dwSize) then
        begin
          if (ssp.dwProcessId = PID) then
          begin
            Result := GetServicePath(ssa^[j].lpServiceName);
            break;
          end;
        end
        else
          Result := 'Unable to query service';
      finally
        CloseServiceHandle(hSvc);
      end;
    end
    else
      Result := Format('Unable to open service: %s',[ssa^[j].lpServiceName]);
  end; { for j }

  Dispose(ssa);
  CloseServiceHandle(hSCM);
end;

function GetServiceStatus(name: string): TServiceStatus;
var
  hSCM: THandle;
  hService: THandle;
  ServiceStatus: _SERVICE_STATUS;
begin
  hSCM := OpenSCManager(nil, nil, SC_MANAGER_CONNECT);
  if (hSCM = 0) then
  begin
    Result := ssError;
    exit;
  end;

  hService := OpenService(hSCM, @name[1], SERVICE_QUERY_STATUS);;
  if (hService = 0) then
  begin
    CloseServiceHandle(hSCM);
    Result := ssNotFound;
    exit;
  end;

  // The SERVICE exists and we have access

  if (QueryServiceStatus(hService, ServiceStatus)) then
  begin
    Result := ssUnknown;
    if (ServiceStatus.dwCurrentState = SERVICE_RUNNING) then
      Result := ssRunning;
    if (ServiceStatus.dwCurrentState = SERVICE_STOPPED) then
      Result := ssStopped;
  end
  else
  begin
    Result := ssError;
  end;

  CloseServiceHandle(hService);
  CloseServiceHandle(hSCM);
end;

//function ServiceDelete(name: string): boolean;
//var
//  hSCM: THandle;
//  hService: THandle;
//begin
//  Result := False;
//  hSCM := OpenSCManager(nil, nil, SC_MANAGER_CONNECT);
//  if (hSCM = 0) then
//    exit;
//
//  hService := OpenService(hSCM, @name[1], SERVICE_QUERY_STATUS);;
//  if (hService = 0) then
//  begin
//    CloseServiceHandle(hSCM);
//    exit;
//  end;
//  // The SERVICE exists and we have access
//
//  Result := (DeleteService(hService));
//
//  CloseServiceHandle(hService);
//  CloseServiceHandle(hSCM);
//end;

end.
