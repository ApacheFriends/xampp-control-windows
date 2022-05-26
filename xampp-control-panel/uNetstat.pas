unit uNetstat;

interface

uses
  GnuGettext, Windows, Messages, SysUtils, Variants, Classes, Graphics,
  Controls, Forms,
  Dialogs, ComCtrls, StdCtrls, Buttons, uNetstatTable, uTools, ExtCtrls,
  uProcesses_new;

type
  tNetState = (nsActive, nsOld, nsNew, nsUpdatingActive, nsUpdatingNew);

  tNetEntry = class
    AddrStr: string;
    AddrR: Cardinal;
    Port: integer;
    PID: integer;
    ProcName: string;
    State: tNetState;
  end;

  TfNetstat = class(TForm)
    lvSockets: TListView;
    bRefresh: TBitBtn;
    sbMain: TStatusBar;
    TimerUpdate: TTimer;
    pnlActiveExample: TPanel;
    pnlOldExample: TPanel;
    pnlNewExample: TPanel;
    procedure bRefreshClick(Sender: TObject);
    procedure lvSocketsColumnClick(Sender: TObject; Column: TListColumn);
    procedure FormCreate(Sender: TObject);
    procedure TimerUpdateTimer(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure lvSocketsData(Sender: TObject; Item: TListItem);
    procedure lvSocketsCustomDrawItem(Sender: TCustomListView; Item: TListItem; State: TCustomDrawState; var DefaultDraw: Boolean);
    procedure cbShowCSRSSClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    NetEntryList: tList;
    procedure ClearnetEntryList;
    function FindNetEntry(AddrR: Cardinal; Port, PID: integer; ProcName: string): tNetEntry;
  public
    procedure RefreshTable(ResetStates: Boolean);
  end;

var
  fNetstat: TfNetstat;

implementation

uses uMain;

const
  cModuleName = 'netstat';

var
  LastSortID: integer;

{$R *.dfm}

procedure TfNetstat.bRefreshClick(Sender: TObject);
begin
  RefreshTable(true);
end;

procedure TfNetstat.cbShowCSRSSClick(Sender: TObject);
begin
  RefreshTable(true);
end;

procedure TfNetstat.ClearnetEntryList;
var
  i: integer;
  NE: tNetEntry;
begin
  lvSockets.Items.Count := 0;
  for i := 0 to NetEntryList.Count - 1 do
  begin
    NE := NetEntryList[i];
    NE.Free;
  end;
  NetEntryList.Clear;
end;

function TfNetstat.FindNetEntry(AddrR: Cardinal; Port, PID: integer; ProcName: string): tNetEntry;
var
  i: integer;
  NE: tNetEntry;
begin
  for i := 0 to NetEntryList.Count - 1 do
  begin
    NE := NetEntryList[i];
    if (NE.AddrR = AddrR) and (NE.Port = Port) and (NE.PID = PID) and (NE.ProcName = ProcName) then
    begin
      result := NE;
      exit;
    end;
  end;
  result := nil;
end;

procedure TfNetstat.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  ClearnetEntryList;
end;

procedure TfNetstat.FormCreate(Sender: TObject);
begin
  TranslateComponent(Self);
  NetEntryList := tList.Create;
  LastSortID := 0;
end;

procedure TfNetstat.FormDestroy(Sender: TObject);
begin
  NetEntryList.Free;
end;

procedure TfNetstat.FormShow(Sender: TObject);
begin
  TimerUpdate.Enabled := true;
end;

function smallnumber(i: Int64): integer;
begin
  if i > 0 then
    result := 1
  else if i < 0 then
    result := -1
  else
    result := 0;
end;

function CustomSortProc(Item1, Item2: Pointer): integer; // stdcall;
var
  NE1, NE2: tNetEntry;
begin
  NE1 := Item1;
  NE2 := Item2;

  case LastSortID of
    0:
      result := smallnumber(Int64(NE1.AddrR) - Int64(NE2.AddrR)) * 4 + smallnumber(NE1.Port - NE2.Port) * 2 + smallnumber(NE1.PID - NE2.PID) * 1;
    1:
      result := smallnumber(Int64(NE1.AddrR) - Int64(NE2.AddrR)) * 2 + smallnumber(NE1.Port - NE2.Port) * 4 + smallnumber(NE1.PID - NE2.PID) * 1;
    2:
      result := smallnumber(Int64(NE1.AddrR) - Int64(NE2.AddrR)) * 2 + smallnumber(NE1.Port - NE2.Port) * 1 + smallnumber(NE1.PID - NE2.PID) * 4;
    3:
      result := smallnumber(CompareText(NE1.ProcName, NE2.ProcName)) * 8 + smallnumber(Int64(NE1.AddrR) - Int64(NE2.AddrR)) * 4 +
        smallnumber(NE1.Port - NE2.Port) * 2 + smallnumber(NE1.PID - NE2.PID) * 1;
  else
    result := 0;
  end;
end;

procedure TfNetstat.lvSocketsColumnClick(Sender: TObject; Column: TListColumn);
begin
  LastSortID := Column.Index;
  NetEntryList.Sort(CustomSortProc);
  lvSockets.Refresh;
end;

procedure TfNetstat.lvSocketsCustomDrawItem(Sender: TCustomListView; Item: TListItem; State: TCustomDrawState; var DefaultDraw: Boolean);
var
  NE: tNetEntry;
begin
  NE := NetEntryList[Item.Index];

  case NE.State of
    nsActive:
      begin
        lvSockets.Canvas.Font.Color := clWindowText;
        lvSockets.Canvas.Brush.Color := clWindow;
      end;
    nsOld:
      begin
        lvSockets.Canvas.Font.Color := clWhite;
        lvSockets.Canvas.Brush.Color := clMaroon;
      end;
    nsNew:
      begin
        lvSockets.Canvas.Font.Color := clWindowText;
        lvSockets.Canvas.Brush.Color := clLime;
      end;
    nsUpdatingActive, nsUpdatingNew:
      begin
        lvSockets.Canvas.Font.Color := clGrayText;
        lvSockets.Canvas.Brush.Color := clBlue;
      end;
  end;

end;

procedure TfNetstat.lvSocketsData(Sender: TObject; Item: TListItem);
var
  NE: tNetEntry;
begin
  NE := NetEntryList[Item.Index];
  Item.Caption := NE.AddrStr;
  Item.SubItems.Add(IntToStr(NE.Port));
  Item.SubItems.Add(IntToStr(NE.PID));
  Item.SubItems.Add(NE.ProcName);
end;

procedure TfNetstat.RefreshTable(ResetStates: Boolean);
var
  i: integer;
  NE: tNetEntry;
  PID, Addr, AddrR, Port: Cardinal;
  PIDName: string;
  AddrStr: string;
  name: string;
begin
  //NetStatTable.UpdateTable;

  if NetStatTable.updating = 1 then
    exit;

  lvSockets.Items.BeginUpdate;

  //fMain.updateTimerNetworking(False);

  NetStatTable.updating_table := 1;

  if ResetStates then
    ClearnetEntryList;

  for i := 0 to NetEntryList.Count - 1 do
  begin
    NE := NetEntryList[i];
    if NE.State = nsActive then
      NE.State := nsUpdatingActive;
    if NE.State = nsNew then
      NE.State := nsUpdatingNew;
  end;

  for i := 0 to NetStatTable.pTcpTable.dwNumEntries - 1 do
  begin
    if NetStatTable.pTcpTable.table[i].dwOwningPid <> 0 then
    begin
      PID := NetStatTable.pTcpTable.table[i].dwOwningPid;
      Addr := NetStatTable.pTcpTable.table[i].dwLocalAddr;
      AddrR := ((Addr and $FF000000) shr 24) or ((Addr and $00FF0000) shr 08) or ((Addr and $0000FF00) shl 08) or ((Addr and $000000FF) shl 24);

      AddrStr := Cardinal2IP(Addr);
      Port := NetStatTable.pTcpTable.table[i].dwLocalPort;
      name := Processes.GetProcessName(PID);
      if name <> '' then
      begin
        PIDName := name;
        NE := FindNetEntry(AddrR, Port, PID, PIDName);
        if NE = nil then
        begin
          NE := tNetEntry.Create;
          NE.AddrStr := AddrStr;
          NE.AddrR := AddrR;
          NE.Port := Port;
          NE.PID := PID;
          NE.ProcName := PIDName;
          NE.State := nsNew;
          NetEntryList.Add(NE);
          lvSockets.Items.Count := lvSockets.Items.Count + 1;

          fMain.AddLog(cModuleName, Format(_('New listening socket: %s:%d'), [NE.AddrStr, NE.Port]), ltDebug);
        end
        else
        begin
          if NE.State = nsUpdatingActive then
            NE.State := nsActive;
          if NE.State = nsUpdatingNew then
            NE.State := nsNew;
        end;
      end;
    end;
  end;

  for i := 0 to NetEntryList.Count - 1 do
  begin
    NE := NetEntryList[i];
    if ResetStates then
      NE.State := nsActive;
    if (NE.State = nsUpdatingActive) or (NE.State = nsUpdatingNew) then
    begin
      NE.State := nsOld;
      fMain.AddLog(cModuleName, Format(_('Listening socket closed: %s:%d'), [NE.AddrStr, NE.Port]), ltDebug);
    end;
  end;

  NetStatTable.updating_table := 0;

  //fMain.updateTimerNetworking(True);

  NetEntryList.Sort(CustomSortProc);
  lvSockets.Items.EndUpdate;
  lvSockets.Refresh;
end;

procedure TfNetstat.TimerUpdateTimer(Sender: TObject);
begin
  if Visible then
  begin
    RefreshTable(false);
  end
  else
  begin
    TimerUpdate.Enabled := false;
  end;
end;

end.
