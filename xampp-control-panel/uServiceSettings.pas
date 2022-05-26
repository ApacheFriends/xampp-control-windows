unit uServiceSettings;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, uTools, GnuGettext, Vcl.StdCtrls,
  Vcl.Buttons, Vcl.ComCtrls;

type
  TfServiceSettings = class(TForm)
    lMain: TLabel;
    bSave: TBitBtn;
    bCancel: TBitBtn;
    pcSettings: TPageControl;
    pApache: TTabSheet;
    pMySQL: TTabSheet;
    pFileZilla: TTabSheet;
    pMercury: TTabSheet;
    pTomcat: TTabSheet;
    gApache: TGroupBox;
    lApacheName: TLabel;
    lApacheMain: TLabel;
    lApacheSSL: TLabel;
    tApacheName: TEdit;
    tApacheMain: TEdit;
    tApacheSSL: TEdit;
    gMySQL: TGroupBox;
    lMySQLMain: TLabel;
    lMySQLName: TLabel;
    tMySQLMain: TEdit;
    tMySQLName: TEdit;
    gFileZilla: TGroupBox;
    lFileZillaMain: TLabel;
    lFileZillaName: TLabel;
    lFileZillaAdmin: TLabel;
    tFileZillaMain: TEdit;
    tFileZillaName: TEdit;
    tFileZillaAdmin: TEdit;
    gMercury: TGroupBox;
    lMercuryP1: TLabel;
    lMercuryP2: TLabel;
    lMercuryP3: TLabel;
    lMercuryP4: TLabel;
    lMercuryP5: TLabel;
    lMercuryP6: TLabel;
    lMercuryP7: TLabel;
    tMercuryP1: TEdit;
    tMercuryP2: TEdit;
    tMercuryP3: TEdit;
    tMercuryP4: TEdit;
    tMercuryP5: TEdit;
    tMercuryP6: TEdit;
    tMercuryP7: TEdit;
    gTomcat: TGroupBox;
    lTomcatMain: TLabel;
    lTomcatHTTP: TLabel;
    lTomcatAJP: TLabel;
    lTomcatName: TLabel;
    tTomcatMain: TEdit;
    tTomcatHTTP: TEdit;
    tTomcatAJP: TEdit;
    tTomcatName: TEdit;
    procedure FormCreate(Sender: TObject);
    procedure bCancelClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure bSaveClick(Sender: TObject);
  private
    function ValidateName(Name: string): Boolean;
    function ValidatePort(Port: string): Boolean;
  public
    { Public declarations }
  end;

var
  fServiceSettings: TfServiceSettings;

implementation

{$R *.dfm}

function TfServiceSettings.ValidateName(Name: string): Boolean;
begin
  if (Trim(Name) <> '') and (Pos(' ', Name) = 0) and (Pos('"', Name) = 0) then
    Result := True
  else
    Result := False;
end;

function TfServiceSettings.ValidatePort(Port: string): Boolean;
var
  i: integer;
begin
  if (TryStrToInt(Port, i) = True) and (Trim(Port) <> '') then
    Result := True
  else
    Result := False;
end;

procedure TfServiceSettings.bCancelClick(Sender: TObject);
begin
  Close;
end;

procedure TfServiceSettings.bSaveClick(Sender: TObject);
var
  error: boolean;
begin
  error := False;
  if ValidateName(tApacheName.Text) then
    Config.ServiceNames.Apache := tApacheName.Text
  else
  begin
    ShowMessage('Apache Name: "' + tApacheName.Text + '" is not a valid name.');
    error := True;
  end;
  if ValidatePort(tApacheMain.Text) then
    Config.ServicePorts.Apache := StrToInt(tApacheMain.Text)
  else
  begin
    ShowMessage('Apache Main: "' + tApacheMain.Text + '" is not a valid number.');
    error := True;
  end;
  if ValidatePort(tApacheSSL.Text) then
    Config.ServicePorts.ApacheSSL := StrToInt(tApacheSSL.Text)
  else
  begin
    ShowMessage('Apache SSL: "' + tApacheSSL.Text + '" is not a valid number.');
    error := True;
  end;

  if ValidateName(tMySQLName.Text) then
    Config.ServiceNames.MySQL := tMySQLName.Text
  else
  begin
    ShowMessage('MySQL Name: "' + tMySQLName.Text + '" is not a valid name.');
    error := True;
  end;
  if ValidatePort(tMySQLMain.Text) then
    Config.ServicePorts.MySQL := StrToInt(tMySQLMain.Text)
  else
  begin
    ShowMessage('MySQL: "' + tMySQLMain.Text + '" is not a valid number.');
    error := True;
  end;

  if ValidateName(tFileZillaName.Text) then
    Config.ServiceNames.FileZilla := tFileZillaName.Text
  else
  begin
    ShowMessage('FileZilla Name: "' + tFileZillaName.Text + '" is not a valid name.');
    error := True;
  end;
  if ValidatePort(tFileZillaMain.Text) then
    Config.ServicePorts.FileZilla := StrToInt(tFileZillaMain.Text)
  else
  begin
    ShowMessage('FileZilla Main: "' + tFileZillaMain.Text + '" is not a valid number.');
    error := True;
  end;
  if ValidatePort(tFileZillaAdmin.Text) then
    Config.ServicePorts.FileZillaAdmin := StrToInt(tFileZillaAdmin.Text)
  else
  begin
    ShowMessage('FileZilla Admin: "' + tFileZillaAdmin.Text + '" is not a valid number.');
    error := True;
  end;

  if ValidatePort(tMercuryP1.Text) then
    Config.ServicePorts.Mercury1 := StrToInt(tMercuryP1.Text)
  else
  begin
    ShowMessage('Mercury1: "' + tMercuryP1.Text + '" is not a valid number.');
    error := True;
  end;
  if ValidatePort(tMercuryP2.Text) then
    Config.ServicePorts.Mercury2 := StrToInt(tMercuryP2.Text)
  else
  begin
    ShowMessage('Mercury2: "' + tMercuryP2.Text + '" is not a valid number.');
    error := True;
  end;
  if ValidatePort(tMercuryP3.Text) then
    Config.ServicePorts.Mercury3 := StrToInt(tMercuryP3.Text)
  else
  begin
    ShowMessage('Mercury3: "' + tMercuryP3.Text + '" is not a valid number.');
    error := True;
  end;
  if ValidatePort(tMercuryP4.Text) then
    Config.ServicePorts.Mercury4 := StrToInt(tMercuryP4.Text)
  else
  begin
    ShowMessage('Mercury4: "' + tMercuryP4.Text + '" is not a valid number.');
    error := True;
  end;
  if ValidatePort(tMercuryP5.Text) then
    Config.ServicePorts.Mercury5 := StrToInt(tMercuryP5.Text)
  else
  begin
    ShowMessage('Mercury5: "' + tMercuryP5.Text + '" is not a valid number.');
    error := True;
  end;
  if ValidatePort(tMercuryP6.Text) then
    Config.ServicePorts.Mercury6 := StrToInt(tMercuryP6.Text)
  else
  begin
    ShowMessage('Mercury6: "' + tMercuryP6.Text + '" is not a valid number.');
    error := True;
  end;
  if ValidatePort(tMercuryP7.Text) then
    Config.ServicePorts.Mercury7 := StrToInt(tMercuryP7.Text)
  else
  begin
    ShowMessage('Mercury7: "' + tMercuryP7.Text + '" is not a valid number.');
    error := True;
  end;

  if ValidateName(tTomcatName.Text) then
    Config.ServiceNames.Tomcat := tTomcatName.Text
  else
  begin
    ShowMessage('Tomcat Name: "' + tTomcatName.Text + '" is not a valid name.');
    error := True;
  end;

  if ValidatePort(tTomcatMain.Text) then
    Config.ServicePorts.Tomcat := StrToInt(tTomcatMain.Text)
  else
  begin
    ShowMessage('Tomcat: "' + tTomcatMain.Text + '" is not a valid number.');
    error := True;
  end;

  if ValidatePort(tTomcatHTTP.Text) then
    Config.ServicePorts.TomcatHTTP := StrToInt(tTomcatHTTP.Text)
  else
  begin
    ShowMessage('Tomcat: "' + tTomcatHTTP.Text + '" is not a valid number.');
    error := True;
  end;

  if ValidatePort(tTomcatAJP.Text) then
    Config.ServicePorts.TomcatAJP := StrToInt(tTomcatAJP.Text)
  else
  begin
    ShowMessage('Tomcat: "' + tTomcatAJP.Text + '" is not a valid number.');
    error := True;
  end;

  if error = False then
  begin
    SaveSettings;
    Close;
  end;
end;

procedure TfServiceSettings.FormCreate(Sender: TObject);
begin
  TranslateComponent(Self);
end;

procedure TfServiceSettings.FormShow(Sender: TObject);
begin
  tApacheName.Text := Config.ServiceNames.Apache;
  tApacheMain.Text := IntToStr(Config.ServicePorts.Apache);
  tApacheSSL.Text := IntToStr(Config.ServicePorts.ApacheSSL);

  tMySQLName.Text := Config.ServiceNames.MySQL;
  tMySQLMain.Text := IntToStr(Config.ServicePorts.MySQL);

  tFileZillaName.Text := Config.ServiceNames.FileZilla;
  tFileZillaMain.Text := IntToStr(Config.ServicePorts.FileZilla);
  tFileZillaAdmin.Text := IntToStr(Config.ServicePorts.FileZillaAdmin);

  tMercuryP1.Text := IntToStr(Config.ServicePorts.Mercury1);
  tMercuryP2.Text := IntToStr(Config.ServicePorts.Mercury2);
  tMercuryP3.Text := IntToStr(Config.ServicePorts.Mercury3);
  tMercuryP4.Text := IntToStr(Config.ServicePorts.Mercury4);
  tMercuryP5.Text := IntToStr(Config.ServicePorts.Mercury5);
  tMercuryP6.Text := IntToStr(Config.ServicePorts.Mercury6);
  tMercuryP7.Text := IntToStr(Config.ServicePorts.Mercury7);

  tTomcatName.Text := Config.ServiceNames.Tomcat;
  tTomcatMain.Text := IntToStr(Config.ServicePorts.Tomcat);
  tTomcatHTTP.Text := IntToStr(Config.ServicePorts.TomcatHTTP);
  tTomcatAJP.Text := IntToStr(Config.ServicePorts.TomcatAJP);
end;

end.
