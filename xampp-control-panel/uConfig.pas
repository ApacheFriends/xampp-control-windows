unit uConfig;

interface

uses
  GnuGettext, Windows, Messages, SysUtils, Variants, Classes, Graphics,
  Controls, Forms,
  Dialogs, StdCtrls, Buttons, uTools;

type
  TfConfig = class(TForm)
    bSelectEditor: TBitBtn;
    eEditor: TEdit;
    OpenDialog: TOpenDialog;
    lblEditor: TLabel;
    bSave: TBitBtn;
    bAbort: TBitBtn;
    lblBrowser: TLabel;
    bSelectBrowser: TBitBtn;
    eBrowser: TEdit;
    cbDebug: TCheckBox;
    cbDebugDetails: TComboBox;
    grpAutostart: TGroupBox;
    cbASApache: TCheckBox;
    cbASMySQL: TCheckBox;
    cbASFileZilla: TCheckBox;
    cbASMercury: TCheckBox;
    lblAutostart: TLabel;
    cbCheckDefaultPorts: TCheckBox;
    bLanguage: TBitBtn;
    bConfigUserdefined: TBitBtn;
    cbTomcatVisible: TCheckBox;
    bLogSettings: TButton;
    bServiceSettings: TButton;
    cbASTomcat: TCheckBox;
    cbMinimized: TCheckBox;
    procedure bAbortClick(Sender: TObject);
    procedure bSaveClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure bSelectEditorClick(Sender: TObject);
    procedure bSelectBrowserClick(Sender: TObject);
    procedure cbDebugClick(Sender: TObject);
    procedure bLanguageClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure bConfigUserdefinedClick(Sender: TObject);
    procedure bLogSettingsClick(Sender: TObject);
    procedure bServiceSettingsClick(Sender: TObject);
  private
    { Private-Deklarationen }
  public
  end;

var
  fConfig: TfConfig;

implementation

uses uMain, uLanguage, uConfigUserDefined, uLogOptions, uServiceSettings;

{$R *.dfm}

procedure TfConfig.bSelectBrowserClick(Sender: TObject);
var
  dp: string;
begin
  dp := ExtractFilePath(eBrowser.Text);
  if dp <> '' then
  begin
    OpenDialog.InitialDir := dp;
    OpenDialog.FileName := ExtractFileName(eBrowser.Text);
  end;
  if OpenDialog.Execute then
    eBrowser.Text := OpenDialog.FileName;
end;

procedure TfConfig.bSelectEditorClick(Sender: TObject);
var
  dp: string;
begin
  dp := ExtractFilePath(eEditor.Text);
  if dp <> '' then
  begin
    OpenDialog.InitialDir := dp;
    OpenDialog.FileName := ExtractFileName(eEditor.Text);
  end;
  if OpenDialog.Execute then
    eEditor.Text := OpenDialog.FileName;
end;

procedure TfConfig.bServiceSettingsClick(Sender: TObject);
begin
  fServiceSettings.ShowModal;
end;

procedure TfConfig.bLogSettingsClick(Sender: TObject);
begin
  fLogOptions.ShowModal;
end;

procedure TfConfig.cbDebugClick(Sender: TObject);
begin
  cbDebugDetails.Visible := cbDebug.Checked;
end;

procedure TfConfig.bLanguageClick(Sender: TObject);
begin
  fLanguage.ShowModal;
end;

procedure TfConfig.bConfigUserdefinedClick(Sender: TObject);
begin
  fConfigUserDefined.ShowModal;
end;

procedure TfConfig.bSaveClick(Sender: TObject);
begin
  Config.EditorApp := Trim(eEditor.Text);
  Config.BrowserApp := Trim(eBrowser.Text);
  Config.ShowDebug := cbDebug.Checked;
  Config.DebugLevel := cbDebugDetails.ItemIndex;
  Config.EnableChecks.CheckDefaultPorts := cbCheckDefaultPorts.Checked;
  Config.TomcatVisible := cbTomcatVisible.Checked;
  Config.Minimized := cbMinimized.Checked;

  Config.ASApache := cbASApache.Checked;
  Config.ASMySQL := cbASMySQL.Checked;
  Config.ASFileZilla := cbASFileZilla.Checked;
  Config.ASMercury := cbASMercury.Checked;
  Config.ASTomcat := cbASTomcat.Checked;

  SaveSettings;
  Close;
end;

procedure TfConfig.bAbortClick(Sender: TObject);
begin
  Close;
end;

procedure TfConfig.FormCreate(Sender: TObject);
begin
  TranslateComponent(Self);
end;

procedure TfConfig.FormKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #27 then
  begin
    Key := #0;
    bAbort.Click;
  end;
end;

procedure TfConfig.FormShow(Sender: TObject);
begin
  eEditor.Text := Config.EditorApp;
  eBrowser.Text := Config.BrowserApp;
  cbDebug.Checked := Config.ShowDebug;
  cbDebugDetails.Visible := cbDebug.Checked;
  cbDebugDetails.ItemIndex := Config.DebugLevel;
  cbCheckDefaultPorts.Checked := Config.EnableChecks.CheckDefaultPorts;
  cbTomcatVisible.Checked := Config.TomcatVisible;
  cbMinimized.Checked := Config.Minimized;

  cbASApache.Checked := Config.ASApache;
  cbASMySQL.Checked := Config.ASMySQL;
  cbASFileZilla.Checked := Config.ASFileZilla;
  cbASMercury.Checked := Config.ASMercury;
  cbASTomcat.Checked := Config.ASTomcat;
end;

end.
