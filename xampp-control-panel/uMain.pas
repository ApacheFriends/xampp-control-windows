(*
  This work is licensed under the Creative Commons Attribution-ShareAlike 3.0 Unported License.
  To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/3.0/ or
  send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.

  Programmed by Steffen Strueber,

  Updates:
  3.0.2: May 10th 2011, Steffen Strueber
  3.0.3-3.2.1: hackattack142
*)

unit uMain;

interface

uses
  GnuGettext, Windows, Messages, SysUtils, Variants, Classes, Graphics,
  Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, ComCtrls, Buttons, uTools, uTomcat,
  uApache, uMySQL, uFileZilla, uMercury, uNetstat, uNetstatTable, Menus,
  IniFiles, AppEvnts, ImgList, JCLDebug, JCLSysInfo, uProcesses_new;

type
  TfMain = class(TForm)
    imgXAMPP: TImage;
    lHeader: TLabel;
    bConfig: TBitBtn;
    bSCM: TBitBtn;
    gbModules: TGroupBox;
    bApacheAction: TBitBtn;
    bApacheAdmin: TBitBtn;
    bMySQLAction: TBitBtn;
    bMySQLAdmin: TBitBtn;
    bFileZillaAction: TBitBtn;
    bFileZillaAdmin: TBitBtn;
    bMercuryAction: TBitBtn;
    bMercuryAdmin: TBitBtn;
    sbMain: TStatusBar;
    bQuit: TBitBtn;
    bHelp: TBitBtn;
    bExplorer: TBitBtn;
    pApacheStatus: TPanel;
    TimerUpdateStatus: TTimer;
    TrayIcon: TTrayIcon;
    bNetstat: TBitBtn;
    puSystray: TPopupMenu;
    miShowHide: TMenuItem;
    miTerminate: TMenuItem;
    N1: TMenuItem;
    bApacheConfig: TBitBtn;
    lPIDs: TLabel;
    lPorts: TLabel;
    lApachePIDs: TLabel;
    bApacheLogs: TBitBtn;
    lApachePorts: TLabel;
    bMySQLConfig: TBitBtn;
    bMySQLLogs: TBitBtn;
    bFileZillaConfig: TBitBtn;
    bFileZillaLogs: TBitBtn;
    bMercuryConfig: TBitBtn;
    reLog: TRichEdit;
    lMySQLPIDs: TLabel;
    lMySQLPorts: TLabel;
    lFileZillaPorts: TLabel;
    lFileZillaPIDs: TLabel;
    lMercuryPorts: TLabel;
    lMercuryPIDs: TLabel;
    pMySQLStatus: TPanel;
    pFileZillaStatus: TPanel;
    pMercuryStatus: TPanel;
    ApplicationEvents: TApplicationEvents;
    ImageList: TImageList;
    bMySQLService: TBitBtn;
    bFileZillaService: TBitBtn;
    lServices: TLabel;
    lModules: TLabel;
    lActions: TLabel;
    bApacheService: TBitBtn;
    bMercurylogs: TBitBtn;
    puGeneral: TPopupMenu;
    lTomcatPorts: TLabel;
    lTomcatPIDs: TLabel;
    bTomcatAction: TBitBtn;
    bTomcatAdmin: TBitBtn;
    bTomcatConfig: TBitBtn;
    pTomcatStatus: TPanel;
    bTomcatLogs: TBitBtn;
    bTomcatService: TBitBtn;
    bMercuryService: TBitBtn;
    bXamppShell: TBitBtn;
    puLog: TPopupMenu;
    LogCopy: TMenuItem;
    LogSelectAll: TMenuItem;
    N2: TMenuItem;
    ApacheTray: TMenuItem;
    MySQLTray: TMenuItem;
    FileZillaTray: TMenuItem;
    MercuryTray: TMenuItem;
    TomcatTray: TMenuItem;
    TomcatTrayControl: TMenuItem;
    MercuryTrayControl: TMenuItem;
    FileZillaTrayControl: TMenuItem;
    MySQLTrayControl: TMenuItem;
    ApacheTrayControl: TMenuItem;
    TimerUpdateNetworking: TTimer;
    procedure FormCreate(Sender: TObject);
    procedure bApacheActionClick(Sender: TObject);
    procedure TimerUpdateStatusTimer(Sender: TObject);
    procedure TimerUpdateNetworkingTimer(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure bNetstatClick(Sender: TObject);
    procedure miTerminateClick(Sender: TObject);
    procedure bQuitClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure miShowHideClick(Sender: TObject);
    procedure TrayIconDblClick(Sender: TObject);
    procedure bExplorerClick(Sender: TObject);
    procedure bSCMClick(Sender: TObject);
    procedure bApacheAdminClick(Sender: TObject);
    procedure bApacheConfigClick(Sender: TObject);
    procedure miGeneralClick(Sender: TObject);
    procedure bConfigClick(Sender: TObject);
    procedure bApacheLogsClick(Sender: TObject);
    procedure bMySQLActionClick(Sender: TObject);
    procedure bMySQLAdminClick(Sender: TObject);
    procedure bMySQLConfigClick(Sender: TObject);
    procedure bMySQLLogsClick(Sender: TObject);
    procedure bFileZillaActionClick(Sender: TObject);
    procedure bFileZillaAdminClick(Sender: TObject);
    procedure bFileZillaConfigClick(Sender: TObject);
    procedure bFileZillaLogsClick(Sender: TObject);
    procedure bMercuryActionClick(Sender: TObject);
    procedure bMercuryAdminClick(Sender: TObject);
    procedure bMercuryConfigClick(Sender: TObject);
    procedure bHelpClick(Sender: TObject);
    procedure bApacheServiceClick(Sender: TObject);
    procedure bMySQLServiceClick(Sender: TObject);
    procedure bFileZillaServiceClick(Sender: TObject);
    procedure bMercuryServiceClick(Sender: TObject);
    procedure bMercurylogsClick(Sender: TObject);
    procedure bXamppShellClick(Sender: TObject);
    procedure bTomcatConfigClick(Sender: TObject);
    procedure bTomcatLogsClick(Sender: TObject);
    procedure bTomcatActionClick(Sender: TObject);
    procedure bTomcatAdminClick(Sender: TObject);
    procedure bTomcatServiceClick(Sender: TObject);
    procedure ApplicationEventsException(Sender: TObject; E: Exception);
    procedure LogCopyClick(Sender: TObject);
    procedure LogSelectAllClick(Sender: TObject);
    procedure ApacheTrayControlClick(Sender: TObject);
    procedure MySQLTrayControlClick(Sender: TObject);
    procedure FileZillaTrayControlClick(Sender: TObject);
    procedure MercuryTrayControlClick(Sender: TObject);
    procedure TomcatTrayControlClick(Sender: TObject);
  private
    Apache: tApache;
    MySQL: tMySQL;
    FileZilla: tFileZilla;
    Mercury: tMercury;
    Tomcat: tTomcat;
    WindowsShutdownInProgress: Boolean;
    procedure UpdateStatusAll;
    function TryGuessXamppVersion: string;
    procedure EditConfigLogs(ConfigFile: string);
    procedure GeneralPUClear;
    procedure GeneralPUAdd(text: string = ''; hint: string = ''; tag: integer = 0);
    procedure GeneralPUAddUser(text: string; hint: string = '');
    procedure GeneralPUAddUserFromSL(sl: tStringList);
    procedure WMQueryEndSession(var Msg: TWMQueryEndSession); message WM_QueryEndSession; // detect Windows shutdown message
    procedure WriteLogToFile;
    procedure updateTimerStatus(enabled: Boolean);
  public
    procedure updateTimerNetworking(enabled: Boolean);
    procedure AddLog(module, log: string; LogType: tLogType = ltDefault); overload;
    procedure AddLog(log: string; LogType: tLogType = ltDefault); overload;
    procedure AdjustLogFont(Name: string; Size: integer);
  end;

var
  fMain: TfMain;

implementation

uses uConfig, uHelp;

{$R *.dfm}

///////////////////////////////////////////
// APACHE FUNCTIONS
///////////////////////////////////////////

procedure TfMain.bApacheServiceClick(Sender: TObject);
var
  oldIsService: Boolean;
begin
  oldIsService := Apache.isService;

  if Apache.isRunning then
  begin
    MessageDlg(_('Services cannot be installed or uninstalled while the service is running!'), mtError, [mbOk], 0);
    exit;
  end;

  if Apache.isService then
  begin
    if MessageDlg(Format(_('Click Yes to uninstall the %s service'), [Apache.ModuleName]), mtConfirmation, [mbYes, mbNo], 0) = mrYes then
    begin
      updateTimerStatus(False);
      Apache.ServiceUnInstall;
      updateTimerStatus(True);
    end
    else
      exit;
  end
  else
  begin
    if MessageDlg(Format(_('Click Yes to install the %s service'), [Apache.ModuleName]), mtConfirmation, [mbYes, mbNo], 0) = mrYes then
    begin
      updateTimerStatus(False);
      Apache.ServiceInstall;
      updateTimerStatus(True);
    end
    else
      exit;
  end;
  Apache.CheckIsService;
  if (oldIsService = Apache.isService) then
  begin
    Apache.AddLog(_('Service was NOT (un)installed!'), ltError);
    if (WinVersion.Major = 5) then // WinXP
      Apache.AddLog
        (_('One possible reason for failure: On windows security box you !!!MUST UNCHECK!!! the "Protect my computer and data from unauthorized program activity" checkbox!!!'),
        ltError);
  end
  else
  begin
    Apache.AddLog(_('Successful!'));
  end;
end;

procedure TfMain.bApacheActionClick(Sender: TObject);
begin
  if Apache.isRunning then
    Apache.Stop
  else
    Apache.Start;
end;

procedure TfMain.bApacheAdminClick(Sender: TObject);
begin
  Apache.Admin;
end;

procedure TfMain.bApacheConfigClick(Sender: TObject);
begin
  GeneralPUClear;
  GeneralPUAdd('Apache (httpd.conf)', 'apache/conf/httpd.conf');
  GeneralPUAdd('Apache (httpd-ssl.conf)', 'apache/conf/extra/httpd-ssl.conf');
  GeneralPUAdd('Apache (httpd-xampp.conf)', 'apache/conf/extra/httpd-xampp.conf');
  GeneralPUAdd('PHP (php.ini)', 'php/php.ini');
  GeneralPUAdd('phpMyAdmin (config.inc.php)', 'phpMyAdmin/config.inc.php');
  GeneralPUAddUserFromSL(Config.UserConfig.Apache);
  GeneralPUAdd();
  GeneralPUAdd(_('<Browse>') + ' [Apache]', 'apache', 1);
  GeneralPUAdd(_('<Browse>') + ' [PHP]', 'php', 1);
  GeneralPUAdd(_('<Browse>') + ' [phpMyAdmin]', 'phpMyAdmin', 1);
  puGeneral.Popup(Mouse.CursorPos.X, Mouse.CursorPos.Y);
end;

procedure TfMain.bApacheLogsClick(Sender: TObject);
begin
  GeneralPUClear;
  GeneralPUAdd('Apache (access.log)', 'apache\logs\access.log');
  GeneralPUAdd('Apache (error.log)', 'apache\logs\error.log');
  GeneralPUAdd('PHP (php_error_log)', 'php\logs\php_error_log');
  GeneralPUAddUserFromSL(Config.UserLogs.Apache);
  GeneralPUAdd();
  GeneralPUAdd(_('<Browse>') + ' [Apache]', 'apache\logs', 1);
  GeneralPUAdd(_('<Browse>') + ' [PHP]', 'php\logs', 1);
  puGeneral.Popup(Mouse.CursorPos.X, Mouse.CursorPos.Y);
end;

procedure TfMain.ApacheTrayControlClick(Sender: TObject);
begin
  if Apache.isRunning then
    Apache.Stop
  else
    Apache.Start;
end;

///////////////////////////////////////////
// MYSQL FUNCTIONS
///////////////////////////////////////////

procedure TfMain.bMySQLServiceClick(Sender: TObject);
var
  oldIsService: Boolean;
begin
  oldIsService := MySQL.isService;

  if MySQL.isRunning then
  begin
    MessageDlg(_('Services cannot be installed or uninstalled while the service is running!'), mtError, [mbOk], 0);
    exit;
  end;
  if MySQL.isService then
  begin
    if MessageDlg(Format(_('Click Yes to uninstall the %s service'), [MySQL.ModuleName]), mtConfirmation, [mbYes, mbNo], 0) = mrYes then
    begin
      updateTimerStatus(False);
      MySQL.ServiceUnInstall;
      updateTimerStatus(True);
    end
    else
      exit;
  end
  else
  begin
    if MessageDlg(Format(_('Click Yes to install the %s service'), [MySQL.ModuleName]), mtConfirmation, [mbYes, mbNo], 0) = mrYes then
    begin
      updateTimerStatus(False);
      MySQL.ServiceInstall;
      updateTimerStatus(True);
    end
    else
      exit;
  end;
  MySQL.CheckIsService;
  if (oldIsService = MySQL.isService) then
  begin
    MySQL.AddLog(_('Service was NOT (un)installed!'), ltError);
    if (WinVersion.Major = 5) then // WinXP
      MySQL.AddLog
        (_('One possible reason for failure: On windows security box you !!!MUST UNCHECK!!! the "Protect my computer and data from unauthorized program activity" checkbox!!!'),
        ltError);
  end
  else
  begin
    MySQL.AddLog(_('Successful!'));
  end;
end;

procedure TfMain.bMySQLActionClick(Sender: TObject);
begin
  if MySQL.isRunning then
    MySQL.Stop
  else
    MySQL.Start;
end;

procedure TfMain.bMySQLAdminClick(Sender: TObject);
begin
  MySQL.Admin;
end;

procedure TfMain.bMySQLConfigClick(Sender: TObject);
begin
  GeneralPUClear;
  GeneralPUAdd('my.ini', 'mysql\bin\my.ini');
  GeneralPUAddUserFromSL(Config.UserConfig.MySQL);
  GeneralPUAdd();
  GeneralPUAdd(_('<Browse>'), 'mysql', 1);
  puGeneral.Popup(Mouse.CursorPos.X, Mouse.CursorPos.Y);
end;

procedure TfMain.bMySQLLogsClick(Sender: TObject);
begin
  GeneralPUClear;
  GeneralPUAdd('mysql_error.log', 'mysql\data\mysql_error.log');
  GeneralPUAddUserFromSL(Config.UserLogs.MySQL);
  GeneralPUAdd();
  GeneralPUAdd(_('<Browse>'), 'mysql\data', 1);
  puGeneral.Popup(Mouse.CursorPos.X, Mouse.CursorPos.Y);
end;

procedure TfMain.MySQLTrayControlClick(Sender: TObject);
begin
  if MySQL.isRunning then
    MySQL.Stop
  else
    MySQL.Start;
end;

///////////////////////////////////////////
// FILEZILLA FUNCTIONS
///////////////////////////////////////////

procedure TfMain.bFileZillaServiceClick(Sender: TObject);
var
  oldIsService: Boolean;
begin
  oldIsService := FileZilla.isService;

  if FileZilla.isRunning then
  begin
    MessageDlg(_('Services cannot be installed or uninstalled while the service is running!'), mtError, [mbOk], 0);
    exit;
  end;
  if FileZilla.isService then
  begin
    if MessageDlg(Format(_('Click Yes to uninstall the %s service'), [FileZilla.ModuleName]), mtConfirmation, [mbYes, mbNo], 0) = mrYes then
    begin
      updateTimerStatus(False);
      FileZilla.ServiceUnInstall;
      updateTimerStatus(True);
    end
    else
      exit;
  end
  else
  begin
    if MessageDlg(Format(_('Click Yes to install the %s service'), [FileZilla.ModuleName]), mtConfirmation, [mbYes, mbNo], 0) = mrYes then
    begin
      updateTimerStatus(False);
      FileZilla.ServiceInstall;
      updateTimerStatus(True);
    end
    else
      exit;
  end;
  FileZilla.CheckIsService;
  if (oldIsService = FileZilla.isService) then
  begin
    FileZilla.AddLog(_('Service was NOT (un)installed!'), ltError);
    if (WinVersion.Major = 5) then // WinXP
      FileZilla.AddLog
        (_('One possible reason for failure: On windows security box you !!!MUST UNCHECK!!! the "Protect my computer and data from unauthorized program activity" checkbox!!!'),
        ltError);
  end
  else
  begin
    FileZilla.AddLog(_('Successful!'));
  end;
end;

procedure TfMain.bFileZillaActionClick(Sender: TObject);
begin
  if FileZilla.isRunning then
    FileZilla.Stop
  else
    FileZilla.Start;
end;

procedure TfMain.bFileZillaAdminClick(Sender: TObject);
begin
  FileZilla.Admin;
end;

procedure TfMain.bFileZillaConfigClick(Sender: TObject);
begin
  GeneralPUClear;
  GeneralPUAdd('FileZilla Server.xml', 'FileZillaFTP\FileZilla Server.xml');
  GeneralPUAddUserFromSL(Config.UserConfig.FileZilla);
  GeneralPUAdd();
  GeneralPUAdd(_('<Browse>'), 'FileZillaFTP', 1);
  puGeneral.Popup(Mouse.CursorPos.X, Mouse.CursorPos.Y);
end;

procedure TfMain.bFileZillaLogsClick(Sender: TObject);
begin
  GeneralPUClear;
  GeneralPUAddUserFromSL(Config.UserLogs.FileZilla);
  if DirectoryExists(BaseDir + 'FileZillaFTP\Logs') then
    GeneralPUAdd(_('<Browse>'), 'FileZillaFTP\Logs', 1);
  puGeneral.Popup(Mouse.CursorPos.X, Mouse.CursorPos.Y);
end;

procedure TfMain.FileZillaTrayControlClick(Sender: TObject);
begin
  if FileZilla.isRunning then
    FileZilla.Stop
  else
    FileZilla.Start;
end;

///////////////////////////////////////////
// MERCURY FUNCTIONS
///////////////////////////////////////////

procedure TfMain.bMercuryServiceClick(Sender: TObject);
begin
  MessageDlg(_('Mercury cannot be run as service!'), mtError, [mbOk], 0);
end;

procedure TfMain.bMercuryActionClick(Sender: TObject);
begin
  if Mercury.isRunning then
    Mercury.Stop
  else
    Mercury.Start;
end;

procedure TfMain.bMercuryAdminClick(Sender: TObject);
begin
  Mercury.Admin;
end;

procedure TfMain.bMercuryConfigClick(Sender: TObject);
begin
  GeneralPUClear;
  GeneralPUAdd('mercury.ini', 'MercuryMail\mercury.ini');
  GeneralPUAddUserFromSL(Config.UserConfig.Mercury);
  GeneralPUAdd();
  GeneralPUAdd(_('<Browse>'), 'MercuryMail', 1);
  puGeneral.Popup(Mouse.CursorPos.X, Mouse.CursorPos.Y);
end;

procedure TfMain.bMercurylogsClick(Sender: TObject);
begin
  GeneralPUClear;
  GeneralPUAddUserFromSL(Config.UserLogs.Mercury);
  GeneralPUAdd(_('<Browse>'), 'MercuryMail\LOGS', 1);
  puGeneral.Popup(Mouse.CursorPos.X, Mouse.CursorPos.Y);
end;

procedure TfMain.MercuryTrayControlClick(Sender: TObject);
begin
  if Mercury.isRunning then
    Mercury.Stop
  else
    Mercury.Start;
end;

///////////////////////////////////////////
// TOMCAT FUNCTIONS
///////////////////////////////////////////

procedure TfMain.bTomcatServiceClick(Sender: TObject);
var
  oldIsService: Boolean;
begin
  oldIsService := Tomcat.isService;

  if Tomcat.isRunning then
  begin
    MessageDlg(_('Services cannot be installed or uninstalled while the service is running!'), mtError, [mbOk], 0);
    exit;
  end;
  if Tomcat.isService then
  begin
    if MessageDlg(Format(_('Click Yes to uninstall the %s service'), [Tomcat.ModuleName]), mtConfirmation, [mbYes, mbNo], 0) = mrYes then
    begin
      updateTimerStatus(False);
      Tomcat.ServiceUnInstall;
      updateTimerStatus(True);
    end
    else
      exit;
  end
  else
  begin
    if MessageDlg(Format(_('Click Yes to install the %s service'), [Tomcat.ModuleName]), mtConfirmation, [mbYes, mbNo], 0) = mrYes then
    begin
      updateTimerStatus(False);
      Tomcat.ServiceInstall;
      updateTimerStatus(True);
    end
    else
      exit;
  end;
  Tomcat.CheckIsService;
  if (oldIsService = Tomcat.isService) then
  begin
    Tomcat.AddLog(_('Service was NOT (un)installed!'), ltError);
    if (WinVersion.Major = 5) then // WinXP
      Tomcat.AddLog
        (_('One possible reason for failure: On windows security box you !!!MUST UNCHECK!!! the "Protect my computer and data from unauthorized program activity" checkbox!!!'),
        ltError);
  end
  else
  begin
    Tomcat.AddLog(_('Successful!'));
  end;

end;

procedure TfMain.bTomcatActionClick(Sender: TObject);
begin
  if Tomcat.isRunning then
    Tomcat.Stop
  else
    Tomcat.Start;
end;

procedure TfMain.bTomcatAdminClick(Sender: TObject);
begin
  Tomcat.Admin;
end;

procedure TfMain.bTomcatConfigClick(Sender: TObject);
begin
  GeneralPUClear;
  GeneralPUAdd('server.xml', 'Tomcat\conf\server.xml');
  GeneralPUAdd('tomcat-users.xml', 'Tomcat\conf\tomcat-users.xml');
  GeneralPUAdd('web.xml', 'Tomcat\conf\web.xml');
  GeneralPUAdd('context.xml', 'Tomcat\conf\context.xml');
  GeneralPUAddUserFromSL(Config.UserConfig.Tomcat);
  GeneralPUAdd();
  GeneralPUAdd(_('<Browse>'), 'Tomcat\conf', 1);
  puGeneral.Popup(Mouse.CursorPos.X, Mouse.CursorPos.Y);
end;

procedure TfMain.bTomcatLogsClick(Sender: TObject);
begin
  GeneralPUClear;
  GeneralPUAddUserFromSL(Config.UserLogs.Tomcat);
  GeneralPUAdd();
  GeneralPUAdd(_('<Browse>'), 'tomcat\logs', 1);
  puGeneral.Popup(Mouse.CursorPos.X, Mouse.CursorPos.Y);
end;

procedure TfMain.TomcatTrayControlClick(Sender: TObject);
begin
  if Tomcat.isRunning then
    Tomcat.Stop
  else
    Tomcat.Start;
end;

///////////////////////////////////////////
// CONTROL PANEL FUNCTIONS
///////////////////////////////////////////

procedure TfMain.bConfigClick(Sender: TObject);
begin
  fConfig.Show;
end;

procedure TfMain.bNetstatClick(Sender: TObject);
begin
  fNetStat.Show;
  fNetStat.RefreshTable(True);
end;

procedure TfMain.bXamppShellClick(Sender: TObject);
const
  cBatchFileContents = '@ECHO OFF' + cr + '' + cr + 'GOTO weiter' + cr + ':setenv' + cr + 'SET "MIBDIRS=%~dp0php\extras\mibs"' + cr +
    'SET "MIBDIRS=%MIBDIRS:\=/%"' + cr + 'SET "MYSQL_HOME=%~dp0mysql\bin"' + cr + 'SET "OPENSSL_CONF=%~dp0apache\bin\openssl.cnf"' + cr +
    'SET "OPENSSL_CONF=%OPENSSL_CONF:\=/%"' + cr + 'SET "PHP_PEAR_SYSCONF_DIR=%~dp0php"' + cr + 'SET "PHP_PEAR_BIN_DIR=%~dp0php"' + cr +
    'SET "PHP_PEAR_TEST_DIR=%~dp0php\tests"' + cr + 'SET "PHP_PEAR_WWW_DIR=%~dp0php\www"' + cr + 'SET "PHP_PEAR_CFG_DIR=%~dp0php\cfg"' + cr +
    'SET "PHP_PEAR_DATA_DIR=%~dp0php\data"' + cr + 'SET "PHP_PEAR_DOC_DIR=%~dp0php\docs"' + cr + 'SET "PHP_PEAR_PHP_BIN=%~dp0php\php.exe"' + cr +
    'SET "PHP_PEAR_INSTALL_DIR=%~dp0php\pear"' + cr + 'SET "PHPRC=%~dp0php"' + cr + 'SET "TMP=%~dp0tmp"' + cr + 'SET "PERL5LIB="' + cr +
    'SET "Path=%~dp0;%~dp0php;%~dp0perl\site\bin;%~dp0perl\bin;%~dp0apache\bin;%~dp0mysql\bin;%~dp0FileZillaFTP;%~dp0MercuryMail;%~dp0sendmail;%~dp0webalizer;%~dp0tomcat\bin;%Path%"'
    + cr + 'GOTO :EOF' + cr + ':weiter' + cr + '' + cr + 'IF "%1" EQU "setenv" (' + cr + '    ECHO.' + cr +
    '    ECHO Setting environment for using XAMPP for Windows.' + cr + '    CALL :setenv' + cr + ') ELSE (' + cr + '    SETLOCAL' + cr +
    '    TITLE XAMPP for Windows' + cr + '    PROMPT %username%@%computername%$S$P$_#$S' + cr + '    START "" /B %COMSPEC% /K "%~f0" setenv'
    + cr + ')';
  cFilename = 'xampp_shell.bat';
var
  ts: tStringList;
  batchfile: string;
begin
  batchfile := BaseDir + cFilename;
  if not FileExists(batchfile) then
  begin
    if MessageDlg(Format(_('File "%s" not found. Should it be created now?'), [batchfile]), mtConfirmation, [mbYes, mbAbort], 0) <> mrYes then
      exit;
    ts := tStringList.Create;
    ts.text := cBatchFileContents;
    try
      ts.SaveToFile(batchfile);
    except
      on E: Exception do
      begin
        MessageDlg(_('Error') + ': ' + E.Message, mtError, [mbOk], 0);
      end;
    end;
    ts.Free;
  end;
  ExecuteFile(batchfile, '', '', SW_SHOW);
end;

procedure TfMain.bExplorerClick(Sender: TObject);
var
  App: string;
begin
  App := BaseDir;
  ExecuteFile(App, '', '', SW_SHOW);
  AddLog(Format(_('Executing "%s"'), [App]));
end;

procedure TfMain.bSCMClick(Sender: TObject);
var
  App: string;
begin
  App := 'services.msc';
  ExecuteFile(App, '', '', SW_SHOW);
  AddLog(Format(_('Executing "%s"'), [App]));
end;

procedure TfMain.bHelpClick(Sender: TObject);
begin
  fHelp.Show;
end;

procedure TfMain.bQuitClick(Sender: TObject);
begin
  miTerminateClick(Sender);
end;

///////////////////////////////////////////
// LOG FUNCTIONS
///////////////////////////////////////////

procedure TfMain.AddLog(module, log: string; LogType: tLogType = ltDefault);
begin
  if (not Config.ShowDebug) and (LogType = ltDebug) or (LogType = ltDebugDetails) then
    exit;
  if (LogType = ltDebugDetails) and (Config.DebugLevel = 0) then
    exit;

  with reLog do
  begin
    SelStart := GetTextLen;

    SelAttributes.Color := clGray;
    SelText := TimeToStr(Now) + '  ';

    SelAttributes.Color := clBlack;
    SelText := '[';

    SelAttributes.Color := clBlue;
    SelText := module;

    SelAttributes.Color := clBlack;
    SelText := '] ' + #9;

    case LogType of
      ltDefault:
        SelAttributes.Color := clBlack;
      ltInfo:
        SelAttributes.Color := clBlue;
      ltError:
        SelAttributes.Color := clRed;
      ltDebug:
        SelAttributes.Color := clGray;
      ltDebugDetails:
        SelAttributes.Color := clSilver;
    end;

    SelText := log + #13;

    SendMessage(Handle, EM_SCROLLCARET, 0, 0);
  end;

end;

procedure TfMain.AddLog(log: string; LogType: tLogType = ltDefault);
begin
  AddLog('main', log, LogType);
end;

procedure TfMain.WriteLogToFile;
var
  exec_name: string;
  LogFileName: string;
  f: TextFile;
  i: integer;
begin
  exec_name := ExtractFileName(Application.ExeName);
  while (length(exec_name) > 0) and (exec_name[length(exec_name)] <> '.') do
    exec_name := copy(exec_name, 1, length(exec_name) - 1);
  LogFileName := BaseDir + exec_name + 'log';
  AssignFile(f, LogFileName);
  if FileExists(LogFileName) then
    Append(f)
  else
    Rewrite(f);
  for i := 0 to reLog.Lines.count - 1 do
    Writeln(f, reLog.Lines[i]);
  Writeln(f, '');
  CloseFile(f);
end;

procedure TfMain.LogSelectAllClick(Sender: TObject);
begin
  reLog.SelectAll;
end;

procedure TfMain.LogCopyClick(Sender: TObject);
begin
  reLog.CopyToClipboard;
end;

procedure TfMain.AdjustLogFont(Name: string; Size: integer);
begin
  reLog.Font.Name := Name;
  reLog.Font.Size := Size;
end;

///////////////////////////////////////////
// POPUP MENU FUNCTIONS
///////////////////////////////////////////

procedure TfMain.GeneralPUAdd(text: string = ''; hint: string = ''; tag: integer = 0);
var
  mi: TMenuItem;
begin
  mi := TMenuItem.Create(puGeneral);
  mi.Caption := text;
  if text = '' then
  begin
    mi.Caption := '-';
  end
  else
  begin
    mi.hint := hint;
    mi.tag := tag;
    mi.OnClick := miGeneralClick;
  end;
  puGeneral.Items.Add(mi);
end;

procedure TfMain.GeneralPUAddUser(text: string; hint: string = '');
var
  myCaption: TranslatedUnicodeString;
  mi, miMain: TMenuItem;
begin
  myCaption := _('User defined');
  miMain := puGeneral.Items.Find(myCaption);
  if miMain = nil then
  begin
    GeneralPUAdd();
    miMain := TMenuItem.Create(puGeneral);
    miMain.Caption := myCaption;
    puGeneral.Items.Add(miMain);
  end;

  mi := TMenuItem.Create(miMain);
  mi.Caption := text;
  if hint <> '' then
    mi.hint := hint
  else
    mi.hint := text;
  mi.OnClick := miGeneralClick;
  miMain.Add(mi);
end;

procedure TfMain.GeneralPUAddUserFromSL(sl: tStringList);
var
  i: integer;
begin
  for i := 0 to sl.count - 1 do
    GeneralPUAddUser(sl[i]);
end;

procedure TfMain.GeneralPUClear;
begin
  puGeneral.Items.Clear;
end;

procedure TfMain.miGeneralClick(Sender: TObject);
var
  mi: TMenuItem;
  App: string;
begin
  if not(Sender is TMenuItem) then
    exit;
  mi := Sender as TMenuItem;
  if mi.tag = 0 then
    EditConfigLogs(mi.hint);
  if mi.tag = 1 then
  begin
    App := BaseDir + mi.hint;
    ExecuteFile(App, '', '', SW_SHOW);
    AddLog(Format(_('Executing "%s"'), [App]));
  end;
end;

procedure TfMain.EditConfigLogs(ConfigFile: string);
var
  App, Param: string;
begin
  App := Config.EditorApp;
  Param := BaseDir + ConfigFile;
  AddLog(Format(_('Executing %s %s'), [App, Param]), ltDebug);
  ExecuteFile(App, Param, '', SW_SHOW);
end;

///////////////////////////////////////////
// FORM GENERAL FUNCTIONS
///////////////////////////////////////////

procedure TfMain.updateTimerStatus(enabled: Boolean);
begin
  TimerUpdateStatus.Enabled := enabled;
end;

procedure TfMain.updateTimerNetworking(enabled: Boolean);
begin
  TimerUpdateNetworking.Enabled := enabled;
end;

procedure TfMain.miShowHideClick(Sender: TObject);
begin
  if Visible then
  begin
    Hide;
    if fMain.WindowState = wsMinimized then
      fMain.WindowState := wsNormal;
  end
  else
  begin
    Show;
    if fMain.WindowState = wsMinimized then
      fMain.WindowState := wsNormal;
    Application.BringToFront;
  end;
end;

procedure TfMain.ApplicationEventsException(Sender: TObject; E: Exception);
var
  ts: tStringList;
  i: integer;
begin
  // GlobalAddLog(Format('Exception in thread: %d / %s', [Thread.ThreadID, JclDebugThreadList.ThreadClassNames[Thread.ThreadID]]),0,'LogException');
  // Note: JclLastExceptStackList always returns list for *current* thread ID. To simplify getting the
  // stack of thread where an exception occured JclLastExceptStackList returns stack of the thread instead
  // of current thread when called *within* the JclDebugThreadList.OnSyncException handler. This is the
  // *only* exception to the behavior of JclLastExceptStackList described above.
  ts := tStringList.Create;

  AddLog('EXCEPTION', E.Message, ltError);

  JclLastExceptStackList.AddToStrings(ts, True, True, True);
  for i := 0 to ts.count - 1 do
    AddLog('EXCEPTION', ts[i], ltError);
  ts.Free;
end;

procedure TfMain.miTerminateClick(Sender: TObject);
begin
  Closing := True;
  Application.ProcessMessages;
  Application.Terminate;
end;

procedure TfMain.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caHide;
end;

procedure TfMain.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  if WindowsShutdownInProgress then
  begin
    CanClose := True;
  end
  else
  begin
    CanClose := false;
    Hide;
  end;
end;

procedure TfMain.FormCreate(Sender: TObject);
var
  isAdmin: Boolean;
  xamppVersion: string;
  CCVersion: string;
  Bitness: string;
  OSVersionInfoEx: TOSVersionInfoEx;
  dirlist: TStringList;
  index: Integer;
begin
  TranslateComponent(Self);

  if (Config.Minimized) then
  begin
    Hide;
    fMain.WindowState := wsMinimized;
  end;

  //ReportMemoryLeaksOnShutdown := true;

  BaseDir := LowerCase(ExtractFilePath(Application.ExeName));

  GlobalProgramVersion := GlobalProgramVersion + ' ' + Config.Edition;

  reLog.PopupMenu := puLog;
  reLog.Font.Name := Config.LogSettings.Font;
  reLog.Font.Size := Config.LogSettings.FontSize;

  AddLog(_('Initializing Control Panel'));

  self.Left := Config.WindowSettings.Left;
  self.Top := Config.WindowSettings.Top;

  if (Config.WindowSettings.Width <> -1) then
    self.Width := Config.WindowSettings.Width;
  if (Config.WindowSettings.Height <> -1) then
    self.Height := Config.WindowSettings.Height;

  WindowsShutdownInProgress := false;

  if IsWindows64 then
    Bitness := '64-bit'
  else
    Bitness := '32-bit';

  AddLog(Format(_('Windows Version: %s %s %s'), [GetWindowsProductString, GetWindowsServicePackVersionString, Bitness]));

  OSVersionInfoEx.dwOSVersionInfoSize := SizeOf(TOSVersionInfo);
  GetVersionEx(OSVersionInfoEx);

  if ((OSVersionInfoEx.dwMajorVersion = 5) and (OSVersionInfoEx.dwMinorVersion = 0)) or (OSVersionInfoEx.dwMajorVersion < 5) then
    AddLog(_('WARNING: Your Operating System is too old and is not supported'), ltError);

  xamppVersion := TryGuessXamppVersion;
  AddLog('XAMPP Version: ' + xamppVersion);

  if cCompileDate <> '' then
    CCVersion := GlobalProgramversion + Format(' [ Compiled: %s ]', [cCompileDate])
  else
    CCVersion := GlobalProgramversion;
  AddLog('Control Panel Version: ' + CCVersion);

  Caption := 'XAMPP Control Panel v' + GlobalProgramversion + Format('  [ Compiled: %s ]', [cCompileDate]);
  lHeader.Caption := 'XAMPP Control Panel v' + GlobalProgramversion;

  isAdmin := IsWindowsAdmin;
  if isAdmin then
  begin
      AddLog(_('Running with Administrator rights - good!'));
  end
  else
  begin
    AddLog(_('You are not running with administrator rights! This will work for'), ltInfo);
    AddLog(_('most application stuff but whenever you do something with services'), ltInfo);
    AddLog(_('there will be a security dialogue or things will break! So think '), ltInfo);
    AddLog(_('about running this application with administrator rights!'), ltInfo);
    fmain.bApacheService.Enabled := false;
    fmain.bMySQLService.Enabled := false;
    fmain.bFileZillaService.Enabled := false;
    fmain.bTomcatService.Enabled := false;
  end;

  AddLog(Format(_('XAMPP Installation Directory: "%s"'), [BaseDir]));

  if LastDelimiter(' ', Trim(BaseDir)) <> 0 then
    AddLog(_('WARNING: Your install directory contains spaces.  This may break programs/scripts'), ltInfo);

  if (LastDelimiter('(', Trim(BaseDir)) <> 0)
  or (LastDelimiter(')', Trim(BaseDir)) <> 0)
  or (LastDelimiter('!', Trim(BaseDir)) <> 0)
  or (LastDelimiter('@', Trim(BaseDir)) <> 0)
  or (LastDelimiter('#', Trim(BaseDir)) <> 0)
  or (LastDelimiter('$', Trim(BaseDir)) <> 0)
  or (LastDelimiter('%', Trim(BaseDir)) <> 0)
  or (LastDelimiter('^', Trim(BaseDir)) <> 0)
  or (LastDelimiter('&', Trim(BaseDir)) <> 0)
  or (LastDelimiter('*', Trim(BaseDir)) <> 0)
  or (LastDelimiter('<', Trim(BaseDir)) <> 0)
  or (LastDelimiter('>', Trim(BaseDir)) <> 0)
  or (LastDelimiter(',', Trim(BaseDir)) <> 0)
  or (LastDelimiter('?', Trim(BaseDir)) <> 0)
  or (LastDelimiter('[', Trim(BaseDir)) <> 0)
  or (LastDelimiter(']', Trim(BaseDir)) <> 0)
  or (LastDelimiter('{', Trim(BaseDir)) <> 0)
  or (LastDelimiter('}', Trim(BaseDir)) <> 0)
  or (LastDelimiter('=', Trim(BaseDir)) <> 0)
  or (LastDelimiter('+', Trim(BaseDir)) <> 0)
  or (LastDelimiter('`', Trim(BaseDir)) <> 0)
  or (LastDelimiter('~', Trim(BaseDir)) <> 0)
  or (LastDelimiter('|', Trim(BaseDir)) <> 0) then
    AddLog(_('WARNING: Your install directory contains special characters.  This may break programs/scripts'), ltInfo);

  if BaseDir[length(BaseDir)] <> '\' then
    BaseDir := BaseDir + '\';

  NetStatTable.UpdateTable;
  //Processes.Update;
  Processes.UpdateList;

  AddLog(_('Checking for prerequisites'));
  if Config.EnableChecks.Runtimes then
  begin
    dirlist := TStringList.Create;
    try
      GetSubDirectories(IncludeTrailingPathDelimiter(GetWinDir) + 'winsxs', dirlist);
      index := FindMatchText(dirlist, 'x86_microsoft.vc90.crt');
      if index = -1 then
      begin
        AddLog(_('Required XAMPP prerequisite not found!'), ltError);
        AddLog(_('You do not appear to have the Microsoft Visual C++ 2008 Runtimes installed'), ltError);
        AddLog(_('This is required for XAMPP to fully function'), ltError);
        AddLog(_('http://www.microsoft.com/download/en/details.aspx?id=5582'), ltError);
      end
      else
        AddLog(_('All prerequisites found'));
    finally
      FreeAndNil(dirlist);
    end;
  end
  else
  begin
    AddLog(_('VC++ checking is disabled'), ltDebug);
  end;

  AddLog(_('Initializing Modules'));
  if Config.EnableModules.Apache then
  begin
    Apache := tApache.Create(bApacheService, pApacheStatus, lApachePIDs, lApachePorts, bApacheAction, bApacheAdmin);
  end
  else
  begin
    AddLog(Format(_('The %s module is disabled'),[Config.ModuleNames.Apache]), ltInfo);
    fmain.ApacheTray.Enabled := false;
    fmain.bApacheService.Enabled := false;
    fmain.bApacheAction.Enabled := false;
    fmain.bApacheAdmin.Enabled := false;
    fmain.bApacheConfig.Enabled := false;
    fmain.bApacheLogs.Enabled := false;
  end;
  if Config.EnableModules.MySQL then
  begin
    MySQL := tMySQL.Create(bMySQLService, pMySQLStatus, lMySQLPIDs, lMySQLPorts, bMySQLAction, bMySQLAdmin);
  end
  else
  begin
    AddLog(Format(_('The %s module is disabled'),[Config.ModuleNames.MySQL]), ltInfo);
    fmain.MySQLTray.Enabled := false;
    fmain.bMySQLService.Enabled := false;
    fmain.bMySQLAction.Enabled := false;
    fmain.bMySQLAdmin.Enabled := false;
    fmain.bMySQLConfig.Enabled := false;
    fmain.bMySQLLogs.Enabled := false;
  end;
  if Config.EnableModules.FileZilla then
  begin
    FileZilla := tFileZilla.Create(bFileZillaService, pFileZillaStatus, lFileZillaPIDs, lFileZillaPorts, bFileZillaAction, bFileZillaAdmin);
  end
  else
  begin
    AddLog(Format(_('The %s module is disabled'),[Config.ModuleNames.FileZilla]), ltInfo);
    fmain.FileZillaTray.Enabled := false;
    fmain.bFileZillaService.Enabled := false;
    fmain.bFileZillaAction.Enabled := false;
    fmain.bFileZillaAdmin.Enabled := false;
    fmain.bFileZillaConfig.Enabled := false;
    fmain.bFileZillaLogs.Enabled := false;
  end;
  if Config.EnableModules.Mercury then
  begin
    Mercury := tMercury.Create(bMercuryService, pMercuryStatus, lMercuryPIDs, lMercuryPorts, bMercuryAction, bMercuryAdmin);
  end
  else
  begin
    AddLog(Format(_('The %s module is disabled'),[Config.ModuleNames.Mercury]), ltInfo);
    fmain.MercuryTray.Enabled := false;
    fmain.bMercuryAction.Enabled := false;
    fmain.bMercuryAdmin.Enabled := false;
    fmain.bMercuryConfig.Enabled := false;
    fmain.bMercurylogs.Enabled := false;
  end;
  if Config.EnableModules.Tomcat then
  begin
    Tomcat := tTomcat.Create(bTomcatService, pTomcatStatus, lTomcatPIDs, lTomcatPorts, bTomcatAction, bTomcatAdmin);
  end
  else
  begin
    AddLog(Format(_('The %s module is disabled'),[Config.ModuleNames.Tomcat]), ltInfo);
    fmain.TomcatTray.Enabled := false;
    fmain.bTomcatService.Enabled := false;
    fmain.bTomcatAction.Enabled := false;
    fmain.bTomcatAdmin.Enabled := false;
    fmain.bTomcatConfig.Enabled := false;
    fmain.bTomcatLogs.Enabled := false;
  end;

  if Config.EnableModules.Apache then
  begin
    if Config.ASApache then
    begin
      Apache.AutoStart := True;
      AddLog(Format(_('Enabling autostart for module "%s"'), [Config.ModuleNames.Apache]));
    end;
  end;
  if Config.EnableModules.MySQL then
  begin
    if Config.ASMySQL then
    begin
      MySQL.AutoStart := True;
      AddLog(Format(_('Enabling autostart for module "%s"'), [Config.ModuleNames.MySQL]));
    end;
  end;
  if Config.EnableModules.FileZilla then
  begin
    if Config.ASFileZilla then
    begin
      FileZilla.AutoStart := True;
      AddLog(Format(_('Enabling autostart for module "%s"'), [Config.ModuleNames.FileZilla]));
    end;
  end;
  if Config.EnableModules.Mercury then
  begin
    if Config.ASMercury then
    begin
      Mercury.AutoStart := True;
      AddLog(Format(_('Enabling autostart for module "%s"'), [Config.ModuleNames.Mercury]));
    end;
  end;
  if Config.EnableModules.Tomcat then
  begin
    if Config.ASTomcat then
    begin
      Tomcat.AutoStart := True;
      AddLog(Format(_('Enabling autostart for module "%s"'), [Config.ModuleNames.Tomcat]));
    end;
  end;

  AddLog(_('Starting') + ' Check-Timer');
  updateTimerStatus(True);
  updateTimerNetworking(True);
  AddLog(_('Control Panel Ready'));
end;

procedure TfMain.FormDestroy(Sender: TObject);
begin
  AddLog(_('Deinitializing Modules'));
  if Config.EnableModules.Apache then
  begin
    Apache.Free;
  end;
  if Config.EnableModules.MySQL then
  begin
    MySQL.Free;
  end;
  if Config.EnableModules.FileZilla then
  begin
    FileZilla.Free;
  end;
  if Config.EnableModules.Mercury then
  begin
    Mercury.Free;
  end;
  if Config.EnableModules.Tomcat then
  begin
    Tomcat.Free
  end;
  AddLog(_('Deinitializing Control Panel'));
  Config.WindowSettings.Left := self.Left;
  Config.WindowSettings.Top := self.Top;
  Config.WindowSettings.Width := self.Width;
  Config.WindowSettings.Height := self.Height;
  SaveSettings;
  WriteLogToFile;
end;

procedure TfMain.TimerUpdateStatusTimer(Sender: TObject);
begin
  UpdateStatusAll;
end;

procedure TfMain.TimerUpdateNetworkingTimer(Sender: TObject);
begin
  AddLog(_('Updating Networking Table...'), ltDebugDetails);
  NetStatTable.UpdateTable;
end;

procedure TfMain.TrayIconDblClick(Sender: TObject);
begin
  miShowHideClick(nil);
end;

function TfMain.TryGuessXamppVersion: string;
var
  ts: tStringList;
  s: string;
  p: integer;
begin
  result := '???';
  ts := tStringList.Create;
  try
    ts.LoadFromFile(BaseDir + '\readme_de.txt');
    if ts.count < 1 then
      exit;
    s := LowerCase(ts[0]);
    p := pos('version', s);
    if p = 0 then
    begin
      p := pos('portable', s);
      if p = 0 then
        exit;
      delete(s, 1, p + 8);
      p := pos(' ', s);
      if p = 0 then
        exit;
      result := copy(s, 1, p - 1) + ' Portable';
    end
    else
    begin
    delete(s, 1, p + 7);
    p := pos(' ', s);
    if p = 0 then
      exit;
    result := copy(s, 1, p - 1);
    end;
  except
  end;
  ts.Free;
end;

procedure TfMain.UpdateStatusAll;
begin
  //Processes.Update;
  Processes.UpdateList;

  // 1. Check Apache
  if Config.EnableModules.Apache then
  begin
    Apache.UpdateStatus;
  end;

  // 2. Check MySql
  if Config.EnableModules.MySQL then
  begin
    MySQL.UpdateStatus;
  end;

  // 3. Check Filezilla
  if Config.EnableModules.FileZilla then
  begin
    FileZilla.UpdateStatus;
  end;

  // 4. Check Mercury
  if Config.EnableModules.Mercury then
  begin
    Mercury.UpdateStatus;
  end;

  // 5. Check Tomcat
  if Config.EnableModules.Tomcat then
  begin
    Tomcat.UpdateStatus;
  end;
end;

procedure TfMain.WMQueryEndSession(var Msg: TWMQueryEndSession);
begin
  WindowsShutdownInProgress := True;
    miTerminateClick(nil);
  inherited;
end;

end.
