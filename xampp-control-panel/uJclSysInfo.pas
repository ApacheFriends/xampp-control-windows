unit uJclSysInfo;

interface

uses Winapi.Windows, System.Classes, Windows;


// Version Information
type
  TWindowsVersion =
   (wvUnknown, wvWin95, wvWin95OSR2, wvWin98, wvWin98SE, wvWinME,
    wvWinNT31, wvWinNT35, wvWinNT351, wvWinNT4, wvWin2000, wvWinXP,
    wvWin2003, wvWinXP64, wvWin2003R2, wvWinVista, wvWinServer2008,
    wvWin7, wvWinServer2008R2);
  TWindowsEdition =
   (weUnknown, weWinXPHome, weWinXPPro, weWinXPHomeN, weWinXPProN, weWinXPHomeK,
    weWinXPProK, weWinXPHomeKN, weWinXPProKN, weWinXPStarter, weWinXPMediaCenter,
    weWinXPTablet, weWinVistaStarter, weWinVistaHomeBasic, weWinVistaHomeBasicN,
    weWinVistaHomePremium, weWinVistaBusiness, weWinVistaBusinessN,
    weWinVistaEnterprise, weWinVistaUltimate, weWin7Starter, weWin7HomeBasic,
    weWin7HomePremium, weWin7Professional, weWin7Enterprise, weWin7Ultimate);
  TNtProductType =
   (ptUnknown, ptWorkStation, ptServer, ptAdvancedServer,
    ptPersonal, ptProfessional, ptDatacenterServer, ptEnterprise, ptWebEdition);
  TProcessorArchitecture =
   (paUnknown, // unknown processor
    pax8632,   // x86 32 bit processors (some P4, Celeron, Athlon and older)
    pax8664,   // x86 64 bit processors (latest P4, Celeron and Athlon64)
    paIA64);   // Itanium processors

var
  { in case of additions, don't forget to update initialization section! }
  IsWin95: Boolean = False;
  IsWin95OSR2: Boolean = False;
  IsWin98: Boolean = False;
  IsWin98SE: Boolean = False;
  IsWinME: Boolean = False;
  IsWinNT: Boolean = False;
  IsWinNT3: Boolean = False;
  IsWinNT31: Boolean = False;
  IsWinNT35: Boolean = False;
  IsWinNT351: Boolean = False;
  IsWinNT4: Boolean = False;
  IsWin2K: Boolean = False;
  IsWinXP: Boolean = False;
  IsWin2003: Boolean = False;
  IsWinXP64: Boolean = False;
  IsWin2003R2: Boolean = False;
  IsWinVista: Boolean = False;
  IsWinServer2008: Boolean = False;
  IsWin7: Boolean = False;
  IsWinServer2008R2: Boolean = False;

const
  PROCESSOR_ARCHITECTURE_INTEL = 0;
  {$EXTERNALSYM PROCESSOR_ARCHITECTURE_INTEL}
  PROCESSOR_ARCHITECTURE_AMD64 = 9;
  {$EXTERNALSYM PROCESSOR_ARCHITECTURE_AMD64}
  PROCESSOR_ARCHITECTURE_IA32_ON_WIN64 = 10;
  {$EXTERNALSYM PROCESSOR_ARCHITECTURE_IA32_ON_WIN64}
  PROCESSOR_ARCHITECTURE_IA64 = 6;
  {$EXTERNALSYM PROCESSOR_ARCHITECTURE_IA64}

function GetWindowsVersion: TWindowsVersion;
function GetWindowsEdition: TWindowsEdition;
function NtProductType: TNtProductType;
function GetWindowsVersionString: string;
function GetWindowsEditionString: string;
function GetWindowsProductString: string;
function NtProductTypeString: string;
function GetWindowsServicePackVersion: Integer;
function GetWindowsServicePackVersionString: string;
function GetOpenGLVersion(const Win: THandle; out Version, Vendor: AnsiString): Boolean;
function GetNativeSystemInfo(var SystemInfo: TSystemInfo): Boolean;
function GetProcessorArchitecture: TProcessorArchitecture;
function IsWindows64: Boolean;
{$ENDIF MSWINDOWS}

function GetOSVersionString: string;


implementation

uses Winapi.Windows, System.Classes, Windows;


//=== Version Information ====================================================

{ Q159/238

  Windows 95 retail, OEM    4.00.950                      7/11/95
  Windows 95 retail SP1     4.00.950A                     7/11/95-12/31/95
  OEM Service Release 2     4.00.1111* (4.00.950B)        8/24/96
  OEM Service Release 2.1   4.03.1212-1214* (4.00.950B)   8/24/96-8/27/97
  OEM Service Release 2.5   4.03.1214* (4.00.950C)        8/24/96-11/18/97
  Windows 98 retail, OEM    4.10.1998                     5/11/98
  Windows 98 Second Edition 4.10.2222A                    4/23/99
  Windows Millennium        4.90.3000
}
{ TODO : Distinquish between all these different releases? }

var
  KernelVersionHi: DWORD;

function GetWindowsVersion: TWindowsVersion;
var
  TrimmedWin32CSDVersion: string;
  SystemInfo: TSystemInfo;
  OSVersionInfoEx: TOSVersionInfoEx;
const
  SM_SERVERR2 = 89;
begin
  Result := wvUnknown;
  TrimmedWin32CSDVersion := Trim(Win32CSDVersion);
  case Win32Platform of
    VER_PLATFORM_WIN32_WINDOWS:
      case Win32MinorVersion of
        0..9:
          if (TrimmedWin32CSDVersion = 'B') or (TrimmedWin32CSDVersion = 'C') then
            Result := wvWin95OSR2
          else
            Result := wvWin95;
        10..89:
          // On Windows ME Win32MinorVersion can be 10 (indicating Windows 98
          // under certain circumstances (image name is setup.exe). Checking
          // the kernel version is one way of working around that.
          if KernelVersionHi = $0004005A then // 4.90.x.x
            Result := wvWinME
          else
          if (TrimmedWin32CSDVersion = 'A') or (TrimmedWin32CSDVersion = 'B') then
            Result := wvWin98SE
          else
            Result := wvWin98;
        90:
          Result := wvWinME;
      end;
    VER_PLATFORM_WIN32_NT:
      case Win32MajorVersion of
        3:
          case Win32MinorVersion of
            1:
              Result := wvWinNT31;
            5:
              Result := wvWinNT35;
            51:
              Result := wvWinNT351;
          end;
        4:
          Result := wvWinNT4;
        5:
          case Win32MinorVersion of
            0:
              Result := wvWin2000;
            1:
              Result := wvWinXP;
            2:
              begin
                OSVersionInfoEx.dwOSVersionInfoSize := SizeOf(OSVersionInfoEx);
                SystemInfo.dwOemId := 0;
                GetNativeSystemInfo(SystemInfo);
                if GetSystemMetrics(SM_SERVERR2) <> 0 then
                  Result := wvWin2003R2
                else
                if (SystemInfo.wProcessorArchitecture <> PROCESSOR_ARCHITECTURE_INTEL) and
                  GetVersionEx(OSVersionInfoEx) and (OSVersionInfoEx.wProductType = VER_NT_WORKSTATION) then
                  Result := wvWinXP64
                else
                  Result := wvWin2003;
              end;
          end;
        6:
          case Win32MinorVersion of
            0:
              begin
                OSVersionInfoEx.dwOSVersionInfoSize := SizeOf(OSVersionInfoEx);
                if GetVersionEx(OSVersionInfoEx) and (OSVersionInfoEx.wProductType = VER_NT_WORKSTATION) then
                  Result := wvWinVista
                else
                  Result := wvWinServer2008;
              end;
            1:
              begin
                OSVersionInfoEx.dwOSVersionInfoSize := SizeOf(OSVersionInfoEx);
                if GetVersionEx(OSVersionInfoEx) and (OSVersionInfoEx.wProductType = VER_NT_WORKSTATION) then
                  Result := wvWin7
                else
                  Result := wvWinServer2008R2;
              end;
          end;
      end;
  end;
end;

function GetWindowsEdition: TWindowsEdition;
const
  ProductName = 'SOFTWARE\Microsoft\Windows NT\CurrentVersion';
var
  Edition: string;
begin
  Result := weUnknown;
  Edition := RegReadStringDef(HKEY_LOCAL_MACHINE, ProductName, 'ProductName', '');
  if (pos('Windows XP', Edition) = 1) then
  begin
   // Windows XP Editions
   if (pos('Home Edition N', Edition) > 0) then
      Result :=  weWinXPHomeN
   else
   if (pos('Professional N', Edition) > 0) then
      Result :=  weWinXPProN
   else
   if (pos('Home Edition K', Edition) > 0) then
      Result :=  weWinXPHomeK
   else
   if (pos('Professional K', Edition) > 0) then
      Result :=  weWinXPProK
   else
   if (pos('Home Edition KN', Edition) > 0) then
      Result :=  weWinXPHomeKN
   else
   if (pos('Professional KN', Edition) > 0) then
      Result :=  weWinXPProKN
   else
   if (pos('Home', Edition) > 0) then
      Result :=  weWinXPHome
   else
   if (pos('Professional', Edition) > 0) then
      Result :=  weWinXPPro
   else
   if (pos('Starter', Edition) > 0) then
      Result :=  weWinXPStarter
   else
   if (pos('Media Center', Edition) > 0) then
      Result :=  weWinXPMediaCenter
   else
   if (pos('Tablet', Edition) > 0) then
      Result :=  weWinXPTablet;
  end
  else
  if (pos('Windows Vista', Edition) = 1) then
  begin
   // Windows Vista Editions
   if (pos('Starter', Edition) > 0) then
      Result := weWinVistaStarter
   else
   if (pos('Home Basic N', Edition) > 0) then
      Result := weWinVistaHomeBasicN
   else
   if (pos('Home Basic', Edition) > 0) then
      Result := weWinVistaHomeBasic
   else
   if (pos('Home Premium', Edition) > 0) then
      Result := weWinVistaHomePremium
   else
   if (pos('Business N', Edition) > 0) then
      Result := weWinVistaBusinessN
   else
   if (pos('Business', Edition) > 0) then
      Result := weWinVistaBusiness
   else
   if (pos('Enterprise', Edition) > 0) then
      Result := weWinVistaEnterprise
   else
   if (pos('Ultimate', Edition) > 0) then
      Result := weWinVistaUltimate;
  end
  else
  if (pos('Windows 7', Edition) = 1) then
  begin
   // Windows 7 Editions
   if (pos('Starter', Edition) > 0) then
      Result := weWin7Starter
   else
   if (pos('Home Basic', Edition) > 0) then
      Result := weWin7HomeBasic
   else
   if (pos('Home Premium', Edition) > 0) then
      Result := weWin7HomePremium
   else
   if (pos('Professional', Edition) > 0) then
      Result := weWin7Professional
   else
   if (pos('Enterprise', Edition) > 0) then
      Result := weWin7Enterprise
   else
   if (pos('Ultimate', Edition) > 0) then
      Result := weWin7Ultimate;
  end;
end;

function NtProductType: TNtProductType;
const
  ProductType = 'SYSTEM\CurrentControlSet\Control\ProductOptions';
var
  Product: string;
  OSVersionInfo: TOSVersionInfoEx;
  SystemInfo: TSystemInfo;
begin
  Result := ptUnknown;
  ResetMemory(OSVersionInfo, SizeOf(OSVersionInfo));
  ResetMemory(SystemInfo, SizeOf(SystemInfo));
  OSVersionInfo.dwOSVersionInfoSize := SizeOf(OSVersionInfo);
  GetNativeSystemInfo(SystemInfo);

  // Favor documented API over registry
  if IsWinNT4 and (GetWindowsServicePackVersion >= 6) then
  begin
    if GetVersionEx(OSVersionInfo) then
    begin
      if (OSVersionInfo.wProductType = VER_NT_WORKSTATION) then
        Result := ptWorkstation
      else
      if (OSVersionInfo.wSuiteMask and VER_SUITE_ENTERPRISE) = VER_SUITE_ENTERPRISE then
        Result := ptEnterprise
      else
        Result := ptServer;
    end;
  end
  else
  if IsWin2K then
  begin
    if GetVersionEx(OSVersionInfo) then
    begin
      if OSVersionInfo.wProductType  in [VER_NT_SERVER,VER_NT_DOMAIN_CONTROLLER] then
      begin
        if (OSVersionInfo.wSuiteMask and VER_SUITE_DATACENTER) <> 0 then
          Result := ptDatacenterServer
        else
        if (OSVersionInfo.wSuiteMask and VER_SUITE_ENTERPRISE) <> 0 then
          Result := ptAdvancedServer
        else
          Result := ptServer;
      end
      else
        Result := ptProfessional;
    end;
  end
  else
  if IsWinXP64 or IsWin2003 or IsWin2003R2 then // all (5.2)
  begin
    if GetVersionEx(OSVersionInfo) then
    begin
      if OSVersionInfo.wProductType in [VER_NT_SERVER,VER_NT_DOMAIN_CONTROLLER] then
      begin
        if (OSVersionInfo.wSuiteMask and VER_SUITE_DATACENTER) = VER_SUITE_DATACENTER then
          Result := ptDatacenterServer
        else
        if (OSVersionInfo.wSuiteMask and VER_SUITE_ENTERPRISE) = VER_SUITE_ENTERPRISE then
          Result := ptEnterprise
        else
        if (OSVersionInfo.wSuiteMask = VER_SUITE_BLADE) then
          Result := ptWebEdition
        else
          Result := ptServer;
      end
      else
      if (OSVersionInfo.wProductType = VER_NT_WORKSTATION) then
        Result := ptProfessional;
    end;
  end
  else
  if IsWinXP or IsWinVista or IsWin7 then // workstation
  begin
    if GetVersionEx(OSVersionInfo) then
    begin
      if OSVersionInfo.wProductType = VER_NT_WORKSTATION then
      begin
        if (OSVersionInfo.wSuiteMask and VER_SUITE_PERSONAL) = VER_SUITE_PERSONAL then
          Result := ptPersonal
        else
          Result := ptProfessional;
      end;
    end;
  end
  else
  if IsWinServer2008 or IsWinServer2008R2 then // server
  begin
    if OSVersionInfo.wProductType in [VER_NT_SERVER,VER_NT_DOMAIN_CONTROLLER] then
    begin
      if (OSVersionInfo.wSuiteMask and VER_SUITE_DATACENTER) = VER_SUITE_DATACENTER then
        Result := ptDatacenterServer
      else
      if (OSVersionInfo.wSuiteMask and VER_SUITE_ENTERPRISE) = VER_SUITE_ENTERPRISE then
        Result := ptEnterprise
      else
        Result := ptServer;
    end;
  end;

  if Result = ptUnknown then
  begin
    // Non Windows 2000/XP system or the above method failed, try registry
    Product := RegReadStringDef(HKEY_LOCAL_MACHINE, ProductType, 'ProductType', '');
    if CompareText(Product, 'WINNT') = 0 then
      Result :=  ptWorkStation
    else
    if CompareText(Product, 'SERVERNT') = 0 then
      Result := {ptServer} ptAdvancedServer
    else
    if CompareText(Product, 'LANMANNT') = 0 then
      Result := {ptAdvancedServer} ptServer
    else
      Result := ptUnknown;
  end;
end;

function GetWindowsVersionString: string;
begin
  case GetWindowsVersion of
    wvWin95:
      Result := LoadResString(@RsOSVersionWin95);
    wvWin95OSR2:
      Result := LoadResString(@RsOSVersionWin95OSR2);
    wvWin98:
      Result := LoadResString(@RsOSVersionWin98);
    wvWin98SE:
      Result := LoadResString(@RsOSVersionWin98SE);
    wvWinME:
      Result := LoadResString(@RsOSVersionWinME);
    wvWinNT31, wvWinNT35, wvWinNT351:
      Result := Format(LoadResString(@RsOSVersionWinNT3), [Win32MinorVersion]);
    wvWinNT4:
      Result := Format(LoadResString(@RsOSVersionWinNT4), [Win32MinorVersion]);
    wvWin2000:
      Result := LoadResString(@RsOSVersionWin2000);
    wvWinXP:
      Result := LoadResString(@RsOSVersionWinXP);
    wvWin2003:
      Result := LoadResString(@RsOSVersionWin2003);
    wvWin2003R2:
      Result := LoadResString(@RsOSVersionWin2003R2);
    wvWinXP64:
      Result := LoadResString(@RsOSVersionWinXP64);
    wvWinVista:
      Result := LoadResString(@RsOSVersionWinVista);
    wvWinServer2008:
      Result := LoadResString(@RsOSVersionWinServer2008);
    wvWin7:
      Result := LoadResString(@RsOSVersionWin7);
    wvWinServer2008R2:
      Result := LoadResString(@RsOSVersionWinServer2008R2);
  else
    Result := '';
  end;
end;

function GetWindowsEditionString: string;
begin
  case GetWindowsEdition of
    weWinXPHome:
      Result := LoadResString(@RsEditionWinXPHome);
    weWinXPPro:
      Result := LoadResString(@RsEditionWinXPPro);
    weWinXPHomeN:
      Result := LoadResString(@RsEditionWinXPHomeN);
    weWinXPProN:
      Result := LoadResString(@RsEditionWinXPProN);
    weWinXPHomeK:
      Result := LoadResString(@RsEditionWinXPHomeK);
    weWinXPProK:
      Result := LoadResString(@RsEditionWinXPProK);
    weWinXPHomeKN:
      Result := LoadResString(@RsEditionWinXPHomeKN);
    weWinXPProKN:
      Result := LoadResString(@RsEditionWinXPProKN);
    weWinXPStarter:
      Result := LoadResString(@RsEditionWinXPStarter);
    weWinXPMediaCenter:
      Result := LoadResString(@RsEditionWinXPMediaCenter);
    weWinXPTablet:
      Result := LoadResString(@RsEditionWinXPTablet);
    weWinVistaStarter:
      Result := LoadResString(@RsEditionWinVistaStarter);
    weWinVistaHomeBasic:
      Result := LoadResString(@RsEditionWinVistaHomeBasic);
    weWinVistaHomeBasicN:
      Result := LoadResString(@RsEditionWinVistaHomeBasicN);
    weWinVistaHomePremium:
      Result := LoadResString(@RsEditionWinVistaHomePremium);
    weWinVistaBusiness:
      Result := LoadResString(@RsEditionWinVistaBusiness);
    weWinVistaBusinessN:
      Result := LoadResString(@RsEditionWinVistaBusinessN);
    weWinVistaEnterprise:
      Result := LoadResString(@RsEditionWinVistaEnterprise);
    weWinVistaUltimate:
      Result := LoadResString(@RsEditionWinVistaUltimate);
    weWin7Starter:
      Result := LoadResString(@RsEditionWin7Starter);
    weWin7HomeBasic:
      Result := LoadResString(@RsEditionWin7HomeBasic);
    weWin7HomePremium:
      Result := LoadResString(@RsEditionWin7HomePremium);
    weWin7Professional:
      Result := LoadResString(@RsEditionWin7Professional);
    weWin7Enterprise:
      Result := LoadResString(@RsEditionWin7Enterprise);
    weWin7Ultimate:
      Result := LoadResString(@RsEditionWin7Ultimate);
  else
    Result := '';
  end;
end;

function GetWindowsProductString: string;
begin
  Result := GetWindowsVersionString;
  if (GetWindowsEditionString <> '') then
    Result := Result + ' ' + GetWindowsEditionString;
end;

function NtProductTypeString: string;
begin
  case NtProductType of
   ptWorkStation:
     Result := LoadResString(@RsProductTypeWorkStation);
   ptServer:
     Result := LoadResString(@RsProductTypeServer);
   ptAdvancedServer:
     Result := LoadResString(@RsProductTypeAdvancedServer);
   ptPersonal:
     Result := LoadResString(@RsProductTypePersonal);
   ptProfessional:
     Result := LoadResString(@RsProductTypeProfessional);
   ptDatacenterServer:
     Result := LoadResString(@RsProductTypeDatacenterServer);
   ptEnterprise:
     Result := LoadResString(@RsProductTypeEnterprise);
   ptWebEdition:
     Result := LoadResString(@RsProductTypeWebEdition);
  else
    Result := '';
  end;
end;

function GetWindowsServicePackVersion: Integer;
const
  RegWindowsControl = 'SYSTEM\CurrentControlSet\Control\Windows';
var
  SP: Integer;
  VersionInfo: TOSVersionInfoEx;
begin
  Result := 0;
  if (Win32Platform = VER_PLATFORM_WIN32_NT) and (Win32MajorVersion >= 5) then
  begin
    ResetMemory(VersionInfo, SizeOf(VersionInfo));
    VersionInfo.dwOSVersionInfoSize := SizeOf(VersionInfo);
    if GetVersionEx(VersionInfo) then
      Result := VersionInfo.wServicePackMajor;
  end
  else
  begin
    SP := RegReadIntegerDef(HKEY_LOCAL_MACHINE, RegWindowsControl, 'CSDVersion', 0);
    Result := StrToInt(IntToHex(SP, 4)) div 100;
  end;
end;

function GetWindowsServicePackVersionString: string;
var
  SP: Integer;
begin
  SP := GetWindowsServicePackVersion;
  if SP > 0 then
    Result := Format(LoadResString(@RsSPInfo), [SP])
  else
    Result := '';
end;

function GetNativeSystemInfo(var SystemInfo: TSystemInfo): Boolean;
type
  TGetNativeSystemInfo = procedure (var SystemInfo: TSystemInfo); stdcall;
var
  LibraryHandle: HMODULE;
  _GetNativeSystemInfo: TGetNativeSystemInfo;
begin
  Result := False;
  LibraryHandle := GetModuleHandle(kernel32);

  if LibraryHandle <> 0 then
  begin
    _GetNativeSystemInfo := GetProcAddress(LibraryHandle,'GetNativeSystemInfo');
    if Assigned(_GetNativeSystemInfo) then
    begin
      _GetNativeSystemInfo(SystemInfo);
      Result := True;
    end
    else
      GetSystemInfo(SystemInfo);
  end
  else
    GetSystemInfo(SystemInfo);
end;

function GetProcessorArchitecture: TProcessorArchitecture;
var
  ASystemInfo: TSystemInfo;
begin
  ASystemInfo.dwOemId := 0;
  GetNativeSystemInfo(ASystemInfo);
  case ASystemInfo.wProcessorArchitecture of
    PROCESSOR_ARCHITECTURE_INTEL:
      Result := pax8632;
    PROCESSOR_ARCHITECTURE_IA64:
      Result := paIA64;
    PROCESSOR_ARCHITECTURE_AMD64:
      Result := pax8664;
    else
      Result := paUnknown;
  end;
end;

function IsWindows64: Boolean;
var
  ASystemInfo: TSystemInfo;
begin
  ASystemInfo.dwOemId := 0;
  GetNativeSystemInfo(ASystemInfo);
  Result := ASystemInfo.wProcessorArchitecture in [PROCESSOR_ARCHITECTURE_IA64,PROCESSOR_ARCHITECTURE_AMD64];
end;

{$ENDIF MSWINDOWS}

function GetOSVersionString: string;
{$IFDEF UNIX}
var
  MachineInfo: utsname;
begin
  uname(MachineInfo);
  Result := Format('%s %s', [MachineInfo.sysname, MachineInfo.release]);
end;
{$ENDIF UNIX}
{$IFDEF MSWINDOWS}
begin
  Result := Format('%s %s', [GetWindowsVersionString, GetWindowsServicePackVersionString]);
end;
{$ENDIF MSWINDOWS}

//=== Initialization/Finalization ============================================

procedure InitSysInfo;
var
  SystemInfo: TSystemInfo;
  Kernel32FileName: string;
  VerFixedFileInfo: TVSFixedFileInfo;
begin
  { processor information related initialization }

  ResetMemory(SystemInfo, SizeOf(SystemInfo));
  GetSystemInfo(SystemInfo);
  ProcessorCount := SystemInfo.dwNumberOfProcessors;
  AllocGranularity := SystemInfo.dwAllocationGranularity;
  PageSize := SystemInfo.dwPageSize;

  { Windows version information }

  IsWinNT := Win32Platform = VER_PLATFORM_WIN32_NT;

  Kernel32FileName := GetModulePath(GetModuleHandle(kernel32));
  VerFixedFileInfo.dwFileDateLS := 0;
  if (not IsWinNT) and VersionFixedFileInfo(Kernel32FileName, VerFixedFileInfo) then
    KernelVersionHi := VerFixedFileInfo.dwProductVersionMS
  else
    KernelVersionHi := 0;

  case GetWindowsVersion of
    wvUnknown:
      ;
    wvWin95:
      IsWin95 := True;
    wvWin95OSR2:
      IsWin95OSR2 := True;
    wvWin98:
      IsWin98 := True;
    wvWin98SE:
      IsWin98SE := True;
    wvWinME:
      IsWinME := True;
    wvWinNT31:
      begin
        IsWinNT3 := True;
        IsWinNT31 := True;
      end;
    wvWinNT35:
      begin
        IsWinNT3 := True;
        IsWinNT35 := True;
      end;
    wvWinNT351:
      begin
        IsWinNT3 := True;
        IsWinNT35 := True;
        IsWinNT351 := True;
      end;
    wvWinNT4:
      IsWinNT4 := True;
    wvWin2000:
      IsWin2K := True;
    wvWinXP:
      IsWinXP := True;
    wvWin2003:
      IsWin2003 := True;
    wvWinXP64:
      IsWinXP64 := True;
    wvWin2003R2:
      IsWin2003R2 := True;
    wvWinVista:
      IsWinVista := True;
    wvWinServer2008:
      IsWinServer2008 := True;
    wvWin7:
      IsWin7 := True;
    wvWinServer2008R2:
      IsWinServer2008R2 := True;
  end;
end;

procedure FinalizeSysInfo;
begin
  UnloadSystemResourcesMeterLib;
end;

initialization
  InitSysInfo;
  {$IFDEF UNITVERSIONING}
  RegisterUnitVersion(HInstance, UnitVersioning);
  {$ENDIF UNITVERSIONING}

finalization
  {$IFDEF UNITVERSIONING}
  UnregisterUnitVersion(HInstance);
  {$ENDIF UNITVERSIONING}
  FinalizeSysInfo;

end.
