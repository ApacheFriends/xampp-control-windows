object fHelp: TfHelp
  Left = 356
  Top = 94
  Caption = 'Help'
  ClientHeight = 263
  ClientWidth = 476
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -14
  Font.Name = 'Arial'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  DesignSize = (
    476
    263)
  PixelsPerInch = 120
  TextHeight = 16
  object lblMainProg: TLabel
    Left = 10
    Top = 16
    Width = 319
    Height = 25
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Caption = 'Programmed by Steffen Strueber'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -22
    Font.Name = 'Arial'
    Font.Style = []
    ParentFont = False
  end
  object lblSecondProg: TLabel
    Left = 9
    Top = 40
    Width = 267
    Height = 25
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Caption = 'Enhanced by hackattack142'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -22
    Font.Name = 'Arial'
    Font.Style = []
    ParentFont = False
  end
  object lblHelpEng: TLabel
    Left = 9
    Top = 83
    Width = 369
    Height = 21
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Caption = 'Need Help? Visit the XAMPP forums (English):'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -18
    Font.Name = 'Arial'
    Font.Style = []
    ParentFont = False
  end
  object lblHelpGer: TLabel
    Left = 9
    Top = 144
    Width = 374
    Height = 21
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Caption = 'Need Help? Visit the XAMPP forums (German):'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -18
    Font.Name = 'Arial'
    Font.Style = []
    ParentFont = False
  end
  object lblHelpEngLink: TLabel
    Left = 8
    Top = 112
    Width = 373
    Height = 19
    Caption = 'http://www.apachefriends.org/f/viewforum.php?f=16'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clMenuHighlight
    Font.Height = -17
    Font.Name = 'Arial'
    Font.Style = [fsUnderline]
    ParentFont = False
    OnClick = lblHelpEngLinkClick
  end
  object lblHelpGerLink: TLabel
    Left = 8
    Top = 173
    Width = 385
    Height = 19
    Caption = 'http://www.apachefriends.org/f/viewforum.php?f=4'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clMenuHighlight
    Font.Height = -17
    Font.Name = 'Arial'
    Font.Style = [fsUnderline]
    ParentFont = False
    OnClick = lblHelpGerLinkClick
  end
  object bHelpClose: TBitBtn
    Left = 361
    Top = 214
    Width = 98
    Height = 32
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Anchors = [akRight, akBottom]
    Caption = 'Close'
    TabOrder = 0
    OnClick = bHelpCloseClick
  end
  object bReadMe: TButton
    Left = 224
    Top = 214
    Width = 114
    Height = 32
    Caption = 'View ReadMe'
    TabOrder = 1
    OnClick = OpenReadme
  end
end
