unit uHelp;

interface

uses
  GnuGettext, Windows, Messages, SysUtils, Variants, Classes, Graphics,
  Controls, Forms,
  Dialogs, StdCtrls, Buttons, Vcl.ExtCtrls, uTools;

type
  TfHelp = class(TForm)
    lblMainProg: TLabel;
    bHelpClose: TBitBtn;
    lblSecondProg: TLabel;
    lblHelpEng: TLabel;
    lblHelpGer: TLabel;
    lblHelpEngLink: TLabel;
    lblHelpGerLink: TLabel;
    bReadMe: TButton;
    procedure bHelpCloseClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure lblHelpEngLinkClick(Sender: TObject);
    procedure lblHelpGerLinkClick(Sender: TObject);
    procedure OpenReadme(Sender: TObject);
  private
    { Private-Deklarationen }
  public
    { Public-Deklarationen }
  end;

var
  fHelp: TfHelp;

implementation

{$R *.dfm}

procedure TfHelp.bHelpCloseClick(Sender: TObject);
begin
  Close;
end;

procedure TfHelp.OpenReadme(Sender: TObject);
begin
  if Config.Language = 'en' then
    ExecuteFile('readme_en.txt','','', SW_SHOW);
  if Config.Language = 'de' then
    ExecuteFile('readme_de.txt','','', SW_SHOW);
end;

procedure TfHelp.FormCreate(Sender: TObject);
begin
  TranslateComponent(Self);
end;

procedure TfHelp.lblHelpEngLinkClick(Sender: TObject);
var
  App: string;
begin
  if Config.BrowserApp <> '' then
  begin
    App := Config.BrowserApp;
    ExecuteFile(App, lblHelpEngLink.Caption, '', SW_SHOW);
  end
  else
  begin
    ExecuteFile(lblHelpEngLink.Caption, '', '', SW_SHOW);
  end;
end;

procedure TfHelp.lblHelpGerLinkClick(Sender: TObject);
var
  App: string;
begin
  if Config.BrowserApp <> '' then
  begin
    App := Config.BrowserApp;
    ExecuteFile(App, lblHelpGerLink.Caption, '', SW_SHOW);
  end
  else
  begin
    ExecuteFile(lblHelpGerLink.Caption, '', '', SW_SHOW);
  end;
end;

end.
