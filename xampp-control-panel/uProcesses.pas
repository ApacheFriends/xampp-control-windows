unit uProcesses;

interface

uses GnuGettext, TlHelp32, uTools, Classes, SysUtils, Windows, ExtCtrls, PsAPI;

type
  TProcInfo = class
    PID: integer;
    Module, ExePath: String;
    CanDelete: boolean;
  end;

  tProcesses = class
  public
    ProcessList: tList;
    function GetProcInfo(PID: integer): TProcInfo;
    procedure Update;
    procedure UpdateProcesses;
    constructor Create;
    destructor Destroy; override;
  end;

function GetProcessPath(PID: Cardinal): string;

var
  Processes: tProcesses;

implementation

uses uMain;

const
  cModuleName = 'procs';

  { tProcessList }

constructor tProcesses.Create;
begin
  ProcessList := tList.Create;
end;

destructor tProcesses.Destroy;
var
  ProcInfo: TProcInfo;
  p: integer;
begin
  for p := 0 to ProcessList.Count - 1 do
  begin
    ProcInfo := ProcessList[p];
    FreeAndNil(ProcInfo);
  end;
  FreeAndNil(ProcessList);
  inherited;
end;

function GetProcessPath(PID: Cardinal): string;
var
  hProcess: THandle;
begin
  hProcess := OpenProcess(PROCESS_QUERY_INFORMATION or PROCESS_VM_READ,False,PID);
  if hProcess <> 0 then
  begin
    try
      SetLength(Result,MAX_PATH);
      FillChar(Result[1],Length(Result) * SizeOf(Char), 0);
      if GetModuleFileNameEx(hProcess,0,PChar(Result),Length(Result)) > 0 then
        Result := Trim(Result)
      else
        Result := 'Unable to get info';
    finally
      CloseHandle(hProcess)
    end;
  end
  else
    Result := 'Unable to open process';
end;

function tProcesses.GetProcInfo(PID: integer): TProcInfo;
var
  ProcInfo: TProcInfo;
  p: integer;
begin
  for p := 0 to ProcessList.Count - 1 do
  begin
    ProcInfo := ProcessList[p];
    if ProcInfo.PID = PID then
    begin
      result := ProcInfo;
      exit;
    end;
  end;
  result := nil;
end;

procedure tProcesses.UpdateProcesses;
var
  hSnapShot: THandle;
  pe32: TProcessEntry32;
  ProcInfo: TProcInfo;
  i: integer;
begin

  for i := 0 to ProcessList.Count - 1 do
  begin
    ProcInfo := ProcessList[i];
    ProcInfo.CanDelete := true;
  end;

  hSnapShot := CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS,0);
  if hSnapShot <> INVALID_HANDLE_VALUE then
  begin
    try
      pe32.dwSize := SizeOf(pe32);
      if Process32First(hSnapshot,pe32) then
      repeat
        ProcInfo := TProcInfo.Create;
        ProcInfo.Module := LowerCase(Trim(pe32.szExeFile));
        //ProcInfo.ExePath := LowerCase(Trim(GetProcessPath(pe32.th32ProcessID)));
        ProcInfo.ExePath := LowerCase(Trim(pe32.szExeFile));
        ProcInfo.PID := pe32.th32ProcessID;
        if Length(ProcInfo.ExePath) <> 0 then
          ProcInfo.CanDelete := false
        else
          ProcInfo.CanDelete := true;
        ProcessList.Add(ProcInfo);
        pe32.dwSize := SizeOf(pe32);
      until Process32Next(hSnapshot,pe32) = False;
    finally
      CloseHandle(hSnapShot);
    end;
  end;

  i := 0;
  while i < ProcessList.Count do
  begin
    ProcInfo := ProcessList[i];
    if ProcInfo.CanDelete then
    begin
      fMain.AddLog(cModuleName, Format(_('Deleting PID-entry %d: %s'), [ProcInfo.PID, ProcInfo.ExePath]), ltDebugDetails);
      FreeAndNil(ProcInfo);
      ProcessList.Delete(i);
    end
    else
    begin
      inc(i);
    end;
  end;

end;

procedure tProcesses.Update;
var
  hProcessSnap: tHandle;
  TProcessEntry: TProcessEntry32;
  ProcInfo: TProcInfo;
  hModuleSnap: tHandle;
  ModuleEntry: MODULEENTRY32;
  i: integer;
  PID: Cardinal;
begin
   fMain.AddLog('processes', 'Checking processes...', ltDebugDetails);

  for i := 0 to ProcessList.Count - 1 do
  begin
    ProcInfo := ProcessList[i];
    ProcInfo.CanDelete := true;
  end;

  hProcessSnap := CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
  if (hProcessSnap = INVALID_HANDLE_VALUE) then
    exit;
  TProcessEntry.dwSize := SizeOf(TProcessEntry);
  if (Process32First(hProcessSnap, TProcessEntry)) then
  begin
    repeat
      PID := TProcessEntry.th32ProcessID;
      ProcInfo := GetProcInfo(PID);
      if ProcInfo <> nil then
      begin
        ProcInfo.CanDelete := false
      end
      else
      begin
        // hModuleSnap := INVALID_HANDLE_VALUE;
        hModuleSnap := CreateToolhelp32Snapshot(TH32CS_SNAPMODULE, TProcessEntry.th32ProcessID);
        if (hModuleSnap <> INVALID_HANDLE_VALUE) then
        begin
          ModuleEntry.dwSize := SizeOf(MODULEENTRY32);
          if (Module32First(hModuleSnap, &ModuleEntry)) then
          begin
            ProcInfo := TProcInfo.Create;
            ProcInfo.Module := LowerCase(ModuleEntry.szModule);
            ProcInfo.ExePath := LowerCase(ModuleEntry.szExePath);
            //ProcInfo.ExePath := LowerCase(GetProcessPath(TProcessEntry.th32ProcessID));
            ProcInfo.PID := TProcessEntry.th32ProcessID;
            ProcInfo.CanDelete := false;
            ProcessList.Add(ProcInfo);
          end
          else
          begin
            ProcInfo := nil;
          end;
        end
        else
        begin
          ProcInfo := TProcInfo.Create;
          ProcInfo.Module := LowerCase(TProcessEntry.szExeFile);
          ProcInfo.ExePath := LowerCase(TProcessEntry.szExeFile);
          //ProcInfo.ExePath := LowerCase(ModuleEntry.szExePath);
          //ProcInfo.ExePath := LowerCase(GetProcessPath(TProcessEntry.th32ProcessID));
          ProcInfo.PID := TProcessEntry.th32ProcessID;
          ProcInfo.CanDelete := false;
          ProcessList.Add(ProcInfo);
        end;
        if ProcInfo <> nil then
          fMain.AddLog(cModuleName, Format(_('Creating PID-entry %d: %s'), [ProcInfo.PID, ProcInfo.ExePath]), ltDebugDetails);
        CloseHandle(hModuleSnap);
      end;
    until not(Process32Next(hProcessSnap, TProcessEntry));
  end;
  CloseHandle(hProcessSnap);

  i := 0;
  while i < ProcessList.Count do
  begin
    ProcInfo := ProcessList[i];
    if ProcInfo.CanDelete then
    begin
      fMain.AddLog(cModuleName, Format(_('Deleting PID-entry %d: %s'), [ProcInfo.PID, ProcInfo.ExePath]), ltDebugDetails);
      FreeAndNil(ProcInfo);
      ProcessList.Delete(i);
    end
    else
    begin
      inc(i);
    end;
  end;
end;

initialization

Processes := tProcesses.Create;

finalization

Processes.Free;

end.
