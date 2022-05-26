unit uProcesses_new;

interface

uses GnuGettext, Classes, SysUtils, Windows, uTools, PsAPI, JCLSysInfo, Variants;

type
  TQueryFullProcessImageName = function(hProcess: Thandle; dwFlags: DWORD; lpExeName: PChar; nSize: PDWORD): BOOL; stdcall;
  tProcesses = class
  public
    ProcessList2: TStrings;
    function GetProcessPath(PID: Cardinal): string;
    function GetProcessName(PID: Cardinal): string;
    procedure UpdateList;
    constructor Create;
    destructor Destroy; override;
  end;

var
  Processes: tProcesses;

implementation

{ tProcessList }

constructor tProcesses.Create;
begin
  ProcessList2 := TStringList.Create;
end;

destructor tProcesses.Destroy;
begin
  ProcessList2.Clear;
  FreeAndNil(ProcessList2);
  inherited;
end;

function tProcesses.GetProcessName(PID: Cardinal): string;
var
  name: string;
  index: integer;
begin
  index := ProcessList2.IndexOfObject(Pointer(PID));

  if (index >= 0) then
  begin
    name := ProcessList2[index];
    result := name;
  end
  else
    result := '';
end;

function tProcesses.GetProcessPath(PID: Cardinal): string;
var
  hProcess: THandle;
  value: array [0 .. MAX_PATH - 1] of Char;
  nSize: cardinal;
  QueryFullProcessImageName: TQueryFullProcessImageName;

begin
  hProcess := OpenProcess(PROCESS_QUERY_INFORMATION or PROCESS_VM_READ, False, PID);


  if hProcess <> 0 then
  begin
    try
      SetLength(result, MAX_PATH);
      FillChar(result[1], Length(result) * SizeOf(Char), 0);


      ZeroMemory(@value, MAX_PATH);
      nSize := MAX_PATH;
      @QueryFullProcessImageName := GetProcAddress(GetModuleHandle('kernel32'), 'QueryFullProcessImageNameW');

      if QueryFullProcessImageName(hProcess, 0, value, @nSize) then
        result := Trim(value)
       else
        result := 'Unable to get info';
    finally
      CloseHandle(hProcess)
    end;
  end
  else
    result := 'Unable to open process';
end;

procedure tProcesses.UpdateList;
begin
  ProcessList2.Clear;
  RunningProcessesList(ProcessList2, False);
end;

initialization

Processes := tProcesses.Create;

finalization

Processes.Free;

end.
