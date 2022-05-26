unit uLogOptions;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, GnuGettext, uTools, uMain,
  Vcl.Buttons;

type
  TfLogOptions = class(TForm)
    FontDialog: TFontDialog;
    lblLogFont: TLabel;
    tLogFont: TEdit;
    lblLogFontSize: TLabel;
    bSelect: TButton;
    tLogFontSize: TEdit;
    bSave: TBitBtn;
    bCancel: TBitBtn;
    procedure bSelectClick(Sender: TObject);
    procedure FontDialogApply(Sender: TObject; Wnd: HWND);
    procedure FontDialogClose(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure bCancelClick(Sender: TObject);
    procedure bSaveClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  fLogOptions: TfLogOptions;

implementation

{$R *.dfm}

procedure TfLogOptions.bCancelClick(Sender: TObject);
begin
  Close;
end;

procedure TfLogOptions.bSaveClick(Sender: TObject);
begin
  Config.LogSettings.Font := FontDialog.Font.Name;
  Config.LogSettings.FontSize := FontDialog.Font.Size;
  fMain.AdjustLogFont(FontDialog.Font.Name, FontDialog.Font.Size);
  SaveSettings;
  Close;
end;

procedure TfLogOptions.bSelectClick(Sender: TObject);
begin
  FontDialog.Execute();
end;

procedure TfLogOptions.FontDialogApply(Sender: TObject; Wnd: HWND);
begin
  tLogFont.Text := FontDialog.Font.Name;
  tLogFontSize.Text := IntToStr(FontDialog.Font.Size);
end;

procedure TfLogOptions.FontDialogClose(Sender: TObject);
begin
  tLogFont.Text := FontDialog.Font.Name;
  tLogFontSize.Text := IntToStr(FontDialog.Font.Size);
end;

procedure TfLogOptions.FormCreate(Sender: TObject);
begin
  TranslateComponent(Self);
end;

procedure TfLogOptions.FormShow(Sender: TObject);
begin
  tLogFont.Text := Config.LogSettings.Font;
  tLogFontSize.Text := IntToStr(Config.LogSettings.FontSize);
  FontDialog.Font.Name := Config.LogSettings.Font;
  FontDialog.Font.Size := Config.LogSettings.FontSize;
end;

end.
