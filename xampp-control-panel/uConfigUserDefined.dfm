object fConfigUserDefined: TfConfigUserDefined
  Left = 487
  Top = 248
  Caption = 'User-defined log/config-files'
  ClientHeight = 306
  ClientWidth = 728
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -14
  Font.Name = 'Arial'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  OnKeyPress = FormKeyPress
  OnShow = FormShow
  DesignSize = (
    728
    306)
  PixelsPerInch = 120
  TextHeight = 16
  object lblDescription1: TLabel
    Left = 10
    Top = 10
    Width = 466
    Height = 19
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Caption = 
      'Enter user defined files. Files must be relative to xampp-basedi' +
      'r!'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -17
    Font.Name = 'Arial'
    Font.Style = []
    ParentFont = False
  end
  object lblDescription2: TLabel
    Left = 10
    Top = 35
    Width = 324
    Height = 19
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Caption = 'Example: "apache\conf\extra\httpd-info.conf"'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -17
    Font.Name = 'Arial'
    Font.Style = []
    ParentFont = False
  end
  object bSave: TBitBtn
    Left = 621
    Top = 264
    Width = 98
    Height = 33
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Anchors = [akRight, akBottom]
    Caption = 'Save'
    Glyph.Data = {
      36030000424D3603000000000000360000002800000010000000100000000100
      1800000000000003000074120000741200000000000000000000FFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF7FAF7F9FBF9FF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFF7FAF837833D347D3AF9FBF9FFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF8FBF8408E4754A35C4F9F5733
      7D39F8FBF9FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      F8FBF8499A515BAC6477CA8274C87E51A059347E3AF8FBF9FFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFF8FCF951A65A63B56D7ECE897BCC8776CA8176
      C98152A25A357F3BF9FBF9FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF9FCFA59B063
      6BBD7684D2907AC98560B26A63B46D78C98378CB8253A35C36803CF9FBF9FFFF
      FFFFFFFFFFFFFFFFFFFFD3ECD66CBD7679C98680CE8D53A75CB2D6B59CC9A05C
      AD677CCC8679CB8554A45D37813DF9FBF9FFFFFFFFFFFFFFFFFFFFFFFFD9EFDC
      6CBD756DC079B5DBB9FFFFFFFFFFFF98C79D5EAE687DCD897CCD8756A55F3882
      3EF9FBF9FFFFFFFFFFFFFFFFFFFFFFFFD5EDD8BEE2C3FFFFFFFFFFFFFFFFFFFF
      FFFF99C89D5FAF697FCE8A7ECE8957A66039833FF9FBF9FFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF99C89E60B06A81CF8D7FCF
      8B58A761398540F9FBF9FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFF99C99E62B26C82D18F7AC88557A6609FC4A2FFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF9ACA9F63B3
      6D5FAF69A5CBA9FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFF9ACA9FA5CEA9FFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF}
    ModalResult = 1
    TabOrder = 0
    OnClick = bSaveClick
    ExplicitTop = 312
  end
  object bAbort: TBitBtn
    Left = 515
    Top = 264
    Width = 98
    Height = 33
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Anchors = [akRight, akBottom]
    Caption = 'Abort'
    Glyph.Data = {
      36030000424D3603000000000000360000002800000010000000100000000100
      1800000000000003000074120000741200000000000000000000FFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFCECEFAF9F9FEFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFF8F8FEC6C5F8FFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      D1D0FB4F4CF24140EDF9F9FEFFFFFFFFFFFFFFFFFFFFFFFFF8F8FE2725E4312F
      EAC6C5F8FFFFFFFFFFFFFFFFFFD3D3FC5856F56361FA5855F64341EDF9F9FEFF
      FFFFFFFFFFF9F8FE2E2DE6413FF14C4AF6312FEAC6C5F8FFFFFFFFFFFFE3E3FD
      5B58F66562FA7170FF5956F64442EEF9F9FEF9F9FE3734E94745F26362FF4A48
      F42F2DE9DAD9FAFFFFFFFFFFFFFFFFFFE3E3FD5B59F66663FA7471FF5A58F645
      43EE403EEC504DF46867FF504EF53634EBDBDBFBFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFE3E3FD5C5AF66764FA7472FF7370FF706EFF6E6CFF5755F73F3DEEDCDC
      FBFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFE4E3FD5D5BF77976FF59
      56FF5754FF7270FF4846F0DEDEFCFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFAFAFF5E5BF67D79FF5E5BFF5B58FF7674FF4744EFF9F9FEFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFAFAFF6865F9706DFB807EFF7E
      7BFF7C79FF7977FF5E5CF74946EFF9F9FEFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FBFAFF706DFC7774FD8682FF7673FC6462F8605DF76D6AFA7B79FF605DF74A47
      EFF9F9FEFFFFFFFFFFFFFFFFFFFBFBFF7572FE7D7AFE8A87FF7C79FD6C69FBE5
      E4FEE4E4FE615EF86E6CFA7D7AFF615FF74B48F0FBFBFFFFFFFFFFFFFFEEEEFF
      7A77FF817EFF817EFE7471FDE6E6FEFFFFFFFFFFFFE4E4FE625FF86F6DFB7E7C
      FF625FF8B0AFF8FEFEFFFFFFFFFFFFFFEEEEFF7A77FF7976FEE7E7FFFFFFFFFF
      FFFFFFFFFFFFFFFFE4E4FE6461F86A68F98E8CF7E3E2FDFFFFFFFFFFFFFFFFFF
      FFFFFFEEEEFFE8E8FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFE5E4FEB8B8
      FCD7D6FDFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFF9F9FFFFFFFFFFFFFFFFFFFF}
    ModalResult = 3
    TabOrder = 1
    OnClick = bAbortClick
    ExplicitTop = 312
  end
  object pcUserDefConf: TPageControl
    Left = 8
    Top = 79
    Width = 712
    Height = 178
    ActivePage = pApache
    TabOrder = 2
    object pApache: TTabSheet
      Caption = 'Apache'
      ExplicitHeight = 166
      object pnlApache: TPanel
        Left = 0
        Top = 0
        Width = 701
        Height = 145
        ParentBackground = False
        TabOrder = 2
        object lblApacheConf: TLabel
          Left = 10
          Top = 13
          Width = 47
          Height = 18
          Margins.Left = 4
          Margins.Top = 4
          Margins.Right = 4
          Margins.Bottom = 4
          Caption = 'Config'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -15
          Font.Name = 'Arial'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object lblApacheLogs: TLabel
          Left = 358
          Top = 13
          Width = 35
          Height = 18
          Margins.Left = 4
          Margins.Top = 4
          Margins.Right = 4
          Margins.Bottom = 4
          Caption = 'Logs'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -15
          Font.Name = 'Arial'
          Font.Style = [fsBold]
          ParentFont = False
        end
      end
      object mLogsApache: TMemo
        Left = 358
        Top = 37
        Width = 341
        Height = 100
        Margins.Left = 4
        Margins.Top = 4
        Margins.Right = 4
        Margins.Bottom = 4
        ScrollBars = ssBoth
        TabOrder = 1
      end
      object mConfigApache: TMemo
        Left = 9
        Top = 37
        Width = 341
        Height = 100
        Margins.Left = 4
        Margins.Top = 4
        Margins.Right = 4
        Margins.Bottom = 4
        ScrollBars = ssBoth
        TabOrder = 0
      end
    end
    object pMySQL: TTabSheet
      Caption = 'MySQL'
      ImageIndex = 1
      ExplicitHeight = 186
      object pnlMySQL: TPanel
        Left = 0
        Top = 0
        Width = 701
        Height = 145
        ParentBackground = False
        TabOrder = 2
        object lblMySQLConf: TLabel
          Left = 10
          Top = 13
          Width = 47
          Height = 18
          Margins.Left = 4
          Margins.Top = 4
          Margins.Right = 4
          Margins.Bottom = 4
          Caption = 'Config'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -15
          Font.Name = 'Arial'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object lblMySQLLogs: TLabel
          Left = 358
          Top = 13
          Width = 35
          Height = 18
          Margins.Left = 4
          Margins.Top = 4
          Margins.Right = 4
          Margins.Bottom = 4
          Caption = 'Logs'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -15
          Font.Name = 'Arial'
          Font.Style = [fsBold]
          ParentFont = False
        end
      end
      object mConfigMySQL: TMemo
        Left = 9
        Top = 37
        Width = 341
        Height = 100
        Margins.Left = 4
        Margins.Top = 4
        Margins.Right = 4
        Margins.Bottom = 4
        ScrollBars = ssBoth
        TabOrder = 0
      end
      object mLogsMySQL: TMemo
        Left = 358
        Top = 37
        Width = 341
        Height = 100
        Margins.Left = 4
        Margins.Top = 4
        Margins.Right = 4
        Margins.Bottom = 4
        ScrollBars = ssBoth
        TabOrder = 1
      end
    end
    object pFileZilla: TTabSheet
      Caption = 'FileZilla'
      ImageIndex = 2
      ExplicitHeight = 186
      object pnlFileZilla: TPanel
        Left = 0
        Top = 0
        Width = 701
        Height = 145
        ParentBackground = False
        TabOrder = 2
        object lblFileZillaConf: TLabel
          Left = 10
          Top = 13
          Width = 47
          Height = 18
          Margins.Left = 4
          Margins.Top = 4
          Margins.Right = 4
          Margins.Bottom = 4
          Caption = 'Config'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -15
          Font.Name = 'Arial'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object lblFileZillaLogs: TLabel
          Left = 358
          Top = 13
          Width = 35
          Height = 18
          Margins.Left = 4
          Margins.Top = 4
          Margins.Right = 4
          Margins.Bottom = 4
          Caption = 'Logs'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -15
          Font.Name = 'Arial'
          Font.Style = [fsBold]
          ParentFont = False
        end
      end
      object mConfigFilezilla: TMemo
        Left = 9
        Top = 37
        Width = 341
        Height = 100
        Margins.Left = 4
        Margins.Top = 4
        Margins.Right = 4
        Margins.Bottom = 4
        ScrollBars = ssBoth
        TabOrder = 0
      end
      object mLogsFileZilla: TMemo
        Left = 358
        Top = 37
        Width = 341
        Height = 100
        Margins.Left = 4
        Margins.Top = 4
        Margins.Right = 4
        Margins.Bottom = 4
        ScrollBars = ssBoth
        TabOrder = 1
      end
    end
    object pMercury: TTabSheet
      Caption = 'Mercury'
      ImageIndex = 3
      ExplicitHeight = 186
      object pnlMercury: TPanel
        Left = 0
        Top = 0
        Width = 701
        Height = 145
        ParentBackground = False
        TabOrder = 2
        object lblMercuryConf: TLabel
          Left = 10
          Top = 13
          Width = 47
          Height = 18
          Margins.Left = 4
          Margins.Top = 4
          Margins.Right = 4
          Margins.Bottom = 4
          Caption = 'Config'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -15
          Font.Name = 'Arial'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object lblMercuryLogs: TLabel
          Left = 358
          Top = 13
          Width = 35
          Height = 18
          Margins.Left = 4
          Margins.Top = 4
          Margins.Right = 4
          Margins.Bottom = 4
          Caption = 'Logs'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -15
          Font.Name = 'Arial'
          Font.Style = [fsBold]
          ParentFont = False
        end
      end
      object mLogsMercury: TMemo
        Left = 358
        Top = 37
        Width = 341
        Height = 100
        Margins.Left = 4
        Margins.Top = 4
        Margins.Right = 4
        Margins.Bottom = 4
        ScrollBars = ssBoth
        TabOrder = 0
      end
      object mConfigMercury: TMemo
        Left = 9
        Top = 37
        Width = 341
        Height = 100
        Margins.Left = 4
        Margins.Top = 4
        Margins.Right = 4
        Margins.Bottom = 4
        ScrollBars = ssBoth
        TabOrder = 1
      end
    end
    object TabSheet5: TTabSheet
      Caption = 'Tomcat'
      ImageIndex = 4
      ExplicitHeight = 186
      object pnlTomcat: TPanel
        Left = 0
        Top = 0
        Width = 701
        Height = 145
        ParentBackground = False
        TabOrder = 2
        object lblTomcatConf: TLabel
          Left = 10
          Top = 13
          Width = 47
          Height = 18
          Margins.Left = 4
          Margins.Top = 4
          Margins.Right = 4
          Margins.Bottom = 4
          Caption = 'Config'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -15
          Font.Name = 'Arial'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object lblTomcatLogs: TLabel
          Left = 358
          Top = 13
          Width = 35
          Height = 18
          Margins.Left = 4
          Margins.Top = 4
          Margins.Right = 4
          Margins.Bottom = 4
          Caption = 'Logs'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -15
          Font.Name = 'Arial'
          Font.Style = [fsBold]
          ParentFont = False
        end
      end
      object mConfigTomcat: TMemo
        Left = 9
        Top = 37
        Width = 341
        Height = 100
        Margins.Left = 4
        Margins.Top = 4
        Margins.Right = 4
        Margins.Bottom = 4
        ScrollBars = ssBoth
        TabOrder = 0
      end
      object mLogsTomcat: TMemo
        Left = 358
        Top = 37
        Width = 341
        Height = 100
        Margins.Left = 4
        Margins.Top = 4
        Margins.Right = 4
        Margins.Bottom = 4
        ScrollBars = ssBoth
        TabOrder = 1
      end
    end
  end
end
