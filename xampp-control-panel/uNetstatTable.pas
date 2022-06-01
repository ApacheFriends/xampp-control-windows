unit uNetstatTable;

interface

uses GnuGettext, SysUtils, Classes, Windows, Dialogs, uProcesses_new, WinSock;

const
  SIZE = 100000;
  MIB_TCP_STATE_LISTEN = 2;

type
  TCP_TABLE_CLASS = integer;

  PMIB_TCPROW_OWNER_PID = ^MIB_TCPROW_OWNER_PID;
  MIB_TCPROW_OWNER_PID = packed record
    dwState: DWORD;
    dwLocalAddr: DWORD;
    dwLocalPort: DWORD;
    dwRemoteAddr: DWORD;
    dwRemotePort: DWORD;
    dwOwningPid: DWORD;
  end;

  PMIB_TCPTABLE_OWNER_PID = ^MIB_TCPTABLE_OWNER_PID;
  MIB_TCPTABLE_OWNER_PID = packed record
    dwNumEntries: DWORD;
    table: array [0 .. SIZE - 1] of MIB_TCPROW_OWNER_PID;
    //table: array [0 .. 99999] of MIB_TCPROW_OWNER_PID;
  end;

  tNetstatTable = class
  private
    hLibModule: THandle;
    DLLProcPointer: Pointer;
    procedure LoadExIpHelperProcedures;
    procedure UnLoadExIpHelperProcedures;
  public
    pTcpTable: PMIB_TCPTABLE_OWNER_PID;
    updating_table: integer;
    updating: integer;
    procedure UpdateTable;
    function GetPorts4PID(pid: integer): string;
    function GetPortCount4PID(pid: integer): integer;
    function isPortInUse(port: integer): string;
    function isPortInUsePID(port: integer): integer;
    constructor Create;
    destructor Destroy; override;
  end;

var
  NetStatTable: tNetstatTable;

implementation

uses uTools, uMain;

const
  TCP_TABLE_OWNER_PID_ALL = 5;

var
  getting_data_1: integer;
  getting_data_2: integer;
  getting_data_3: integer;
  getting_data_4: integer;
  GetExtendedTcpTable:function(pTcpTable: Pointer; dwSize: PDWORD; bOrder: BOOL; lAf: ULONG; TableClass: TCP_TABLE_CLASS; Reserved: ULONG): DWORD; stdcall;

  { tNetStatTable }

constructor tNetstatTable.Create;
begin
  DLLProcPointer := nil;
  hLibModule := 0;
  pTcpTable := nil;
  updating := 0;
  updating_table := 0;
  getting_data_1 := 0;
  getting_data_2 := 0;
  getting_data_3 := 0;
  getting_data_4 := 0;
  try
    LoadExIpHelperProcedures;
  except
    fMain.AddLog('NetStatTable', 'Problem loading IP Library', ltError);
    raiseLastOSError();
  end;
end;

destructor tNetstatTable.Destroy;
begin
  try
    UnLoadExIpHelperProcedures;
    if (pTcpTable <> nil) then FreeMem(pTcpTable);
  except
  end;
  inherited;
end;

function tNetstatTable.GetPortCount4PID(pid: integer): integer;
var
  i: integer;
begin
  result := 0;
  if updating = 1 then
    exit;
  getting_data_1 := 1;
  //fMain.updateTimerNetworking(False);
  for i := 0 to NetStatTable.pTcpTable.dwNumEntries - 1 do
    if NetStatTable.pTcpTable.table[i].dwOwningPid = Cardinal(pid) then
      result := result + 1;
  getting_data_1 := 0;
  //fMain.updateTimerNetworking(True);
end;

function tNetstatTable.GetPorts4PID(pid: integer): string;
var
  i: integer;
  port: string;
begin
  result := '';
  if updating = 1 then
    exit;
  getting_data_2 := 1;
  //fMain.updateTimerNetworking(False);
  for i := 0 to NetStatTable.pTcpTable.dwNumEntries - 1 do
  begin
    if NetStatTable.pTcpTable.table[i].dwOwningPid = Cardinal(pid) then
    begin
      port := IntToStr(NetStatTable.pTcpTable.table[i].dwLocalPort);
      if result = '' then
        result := port
      else
        result := result + ', ' + port;
    end;
  end;
  getting_data_2 := 0;
  //fMain.updateTimerNetworking(True);
end;

function tNetstatTable.isPortInUse(port: integer): string;
var
  i: integer;
  path: string;
  pid: Cardinal;
begin
  result := '';
  if updating = 1 then
    exit;
  getting_data_3 := 1;
  //fMain.updateTimerNetworking(False);
  for i := 0 to NetStatTable.pTcpTable.dwNumEntries - 1 do
  begin
    if NetStatTable.pTcpTable.table[i].dwLocalPort = Cardinal(port) then
    begin
      pid := NetStatTable.pTcpTable.table[i].dwOwningPid;
      path := Processes.GetProcessName(pid);
      if path <> '' then
        result := path
      else
        result := _('unknown program');
      getting_data_3 := 0;
      exit;
    end;
  end;
  getting_data_3 := 0;
  //fMain.updateTimerNetworking(True);
end;

function tNetstatTable.isPortInUsePID(port: integer): integer;
var
  i: integer;
begin
  result := -1;
  if updating = 1 then
    exit;
  getting_data_4 := 1;
  //fMain.updateTimerNetworking(False);
  for i := 0 to NetStatTable.pTcpTable.dwNumEntries - 1 do
  begin
    if NetStatTable.pTcpTable.table[i].dwLocalPort = Cardinal(port) then
    begin
      result := NetStatTable.pTcpTable.table[i].dwOwningPid;
      getting_data_4 := 0;
      exit;
    end;
  end;
  getting_data_4 := 0;
  //fMain.updateTimerNetworking(True);
end;

procedure tNetstatTable.LoadExIpHelperProcedures;
begin
  hLibModule := LoadLibrary('iphlpapi.dll');
  //if hLibModule = 0 then
  //  exit;
  GetExtendedTcpTable := GetProcAddress(hLibModule, 'GetExtendedTcpTable');
  //DLLProcPointer := GetProcAddress(hLibModule, 'GetExtendedTcpTable');
  //if not Assigned(DLLProcPointer) then
  //begin
  //  ShowMessage(IntToStr(GetLastError));
  //end;
end;

procedure tNetstatTable.UnLoadExIpHelperProcedures;
begin
  if hLibModule > HINSTANCE_ERROR then
    FreeLibrary(hLibModule);
end;

procedure tNetstatTable.UpdateTable;
var
  dwSize: DWORD;
  Res: DWORD;
  //GetExtendedTcpTable: TGetExtendedTcpTable;
  i: integer;
  try_limit: integer;
  counter: integer;
  localPTcpTable: PMIB_TCPTABLE_OWNER_PID;
  auxPTcpTable: PMIB_TCPTABLE_OWNER_PID;
begin
  if updating = 1 then
    exit;

  if ((getting_data_1 = 1) or (getting_data_2 = 1) or (getting_data_3 = 1) or (getting_data_4 = 1)) then
    exit;

  if updating_table = 1 then
    exit;

  updating := 1;

  //if (DLLProcPointer = nil) or (hLibModule < HINSTANCE_ERROR) then
  if (hLibModule < HINSTANCE_ERROR) then
  begin
    exit;
  end;

  //GetExtendedTcpTable := DLLProcPointer;
  try
    try_limit := 10;
    counter := 0;
    dwSize := 0;
    Res := GetExtendedTcpTable(localPTcpTable, @dwSize, False, AF_INET, TCP_TABLE_OWNER_PID_ALL, 0);
    while ((Res = ERROR_INSUFFICIENT_BUFFER) and (counter < try_limit)) do
    begin
      GetMem(localPTcpTable, dwSize); // das API hat die "gewünschte" Grösse gesetzt
      Res := GetExtendedTcpTable(localPTcpTable, @dwSize, False, AF_INET, TCP_TABLE_OWNER_PID_ALL, 0);
      inc(counter);
    end;
    if (Res = NO_ERROR) then
    begin
      for i := 0 to localPTcpTable.dwNumEntries - 1 do
      begin
        localPTcpTable.table[i].dwLocalPort := ((localPTcpTable.table[i].dwLocalPort and $FF00) shr 8) or ((localPTcpTable.table[i].dwLocalPort and $00FF) shl 8);
        localPTcpTable.table[i].dwRemotePort := ((localPTcpTable.table[i].dwRemotePort and $FF00) shr 8) or ((localPTcpTable.table[i].dwRemotePort and $00FF) shl 8);
      end;

      auxPTcpTable := pTcpTable;
      pTcpTable := localPTcpTable;

      if auxPTcpTable <> nil then
      begin
        FreeMem(auxPTcpTable);
        auxPTcpTable := nil;
      end;

    end
    else if (Res = ERROR_NO_DATA) then
    begin
      if pTcpTable <> nil then
      begin
        FreeMem(pTcpTable);
        pTcpTable := nil;
      end;
      exit;
    end
    else
    begin
      fMain.AddLog('NetStatTable', Format('NetStat TCP service stopped. Please restart the control panel. Returned %d',[Res]), ltError);
      if pTcpTable <> nil then
      begin
        FreeMem(pTcpTable);
        pTcpTable := nil;
      end;
      exit;
      //raiseLastOSError(); // Error-Handling
    end;
  finally
    // If (pTcpTable <> Nil) Then FreeMem(pTcpTable);
  end;
  updating := 0;
end;

initialization

NetStatTable := tNetstatTable.Create;

finalization

NetStatTable.Free;

end.
